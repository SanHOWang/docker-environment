# --------- Stage base ---------
FROM ubuntu:24.04 AS base

ARG UID=1001
ARG GID=1001
ARG USERNAME=user

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Taipei

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        tzdata sudo && \
    ln -fs /usr/share/zoneinfo/$TZ /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata

RUN if getent group ${GID}; then \
        echo "GID ${GID} already exists" && exit 1; \
    else \
        groupadd -g ${GID} ${USERNAME}; \
    fi && \
    if getent passwd ${UID}; then \
        echo "UID ${UID} already exists" && exit 1; \
    else \
        useradd -m -u ${UID} -g ${GID} -s /bin/bash ${USERNAME}; \
    fi && \
    echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# --------- Stage common_pkg_provider ---------
FROM base AS common_pkg_provider

# 安裝常用 CLI 工具與 Python/PIP
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        vim git curl wget ca-certificates bzip2 \
        build-essential python3 python3-pip && \
    ln -sf /usr/bin/python3 /usr/bin/python && \
    ln -sf /usr/bin/pip3 /usr/bin/pip && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# 安裝 Miniconda（根據 CPU 架構）
ARG TARGETARCH
ENV CONDA_DIR=/opt/conda

RUN case "${TARGETARCH}" in \
      "amd64") ARCH="x86_64" ;; \
      "arm64") ARCH="aarch64" ;; \
      *) echo "Unsupported arch: ${TARGETARCH}" && exit 1 ;; \
    esac && \
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-${ARCH}.sh -O miniconda.sh && \
    bash miniconda.sh -b -p ${CONDA_DIR} && \
    rm miniconda.sh && \
    ln -s ${CONDA_DIR}/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> /etc/bash.bashrc && \
    echo "conda activate base" >> /etc/bash.bashrc

# 驗證工具版本與 Conda 環境
#TODO
RUN vim --version && \
    git --version && \
    curl --version && \
    wget --version && \
    gcc --version && \
    g++ --version && \
    make --version && \
    python3 --version && \
    pip --version && \
    ${CONDA_DIR}/bin/conda --version && \
    ${CONDA_DIR}/bin/conda list


FROM common_pkg_provider AS verilator_provider

RUN apt-get update && apt-get install -y --no-install-recommends \
    autoconf flex bison libfl-dev help2man perl python3 \
    zlib1g zlib1g-dev libfl2 && \
    rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/verilator/verilator.git /tmp/verilator && \
    cd /tmp/verilator && \
    git checkout v5.024 && \
    autoconf && \
    ./configure && \
    make -j$(nproc) && \
    make install && \
    rm -rf /tmp/verilator

FROM common_pkg_provider AS systemc_provider

ARG SYSTEMC_VERSION=2.3.4
ARG SYSTEMC_HOME=/opt/systemc

RUN apt-get update && apt-get install -y --no-install-recommends \
    autoconf automake libtool m4 pkg-config && \
    rm -rf /var/lib/apt/lists/*

RUN wget https://github.com/accellera-official/systemc/archive/refs/tags/${SYSTEMC_VERSION}.tar.gz -O systemc.tar.gz && \
    tar -xzf systemc.tar.gz && \
    rm systemc.tar.gz && \
    mv systemc-${SYSTEMC_VERSION} ${SYSTEMC_HOME} && \
    cd ${SYSTEMC_HOME} && \
    autoreconf -i && \
    mkdir -p build && cd build && \
    ../configure --prefix=${SYSTEMC_HOME}/install && \
    make -j$(nproc) && \
    make install && \
    rm -rf ${SYSTEMC_HOME}/build

# --------- Stage final_image ---------
# ToDo
FROM base AS final_image
ARG CONDA_DIR=/opt/conda
ARG SYSTEMC_HOME=/opt/systemc/install
ARG USERNAME=user

# Copy 全部依賴工具與環境（包含 libs）
COPY --from=common_pkg_provider /usr /usr
COPY --from=common_pkg_provider /etc/alternatives /etc/alternatives
COPY --from=common_pkg_provider ${CONDA_DIR} ${CONDA_DIR}
COPY --from=common_pkg_provider /etc/profile.d/conda.sh /etc/profile.d/conda.sh

# Copy Verilator + SystemC
COPY --from=verilator_provider /usr/local /usr/local
COPY --from=systemc_provider ${SYSTEMC_HOME} ${SYSTEMC_HOME}

# 把 eman.sh 複製進去並加執行權限
COPY eman.sh /home/${USERNAME}/eman.sh
RUN chmod +x /home/${USERNAME}/eman.sh
#TODO
#要加環境變數
#不會放在user下

# 設定環境變數
ENV PATH="${CONDA_DIR}/bin:$PATH"
ENV SYSTEMC_HOME=${SYSTEMC_HOME}
#TODO
#架構要增加
ENV LD_LIBRARY_PATH="${SYSTEMC_HOME}/lib-linux64"

# 切換使用者
USER ${USERNAME}
WORKDIR /home/${USERNAME}

# Optional: 測試用
# RUN verilator --version && gcc --version && conda --version