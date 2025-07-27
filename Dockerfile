# --------- Stage conda_provider ---------
FROM ubuntu:24.04 AS conda_provider

# 安裝常用 CLI 工具與 Python/PIP
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        wget ca-certificates && \
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
    # 執行 conda init bash
    ${CONDA_DIR}/bin/conda init bash

# 把 Conda 加入 PATH（供其他 RUN 使用）
ENV PATH=${CONDA_DIR}/condabin:${PATH}

# --------- Stage verilator_provider ---------
FROM ubuntu:24.04 AS verilator_provider

ENV CORE_TOOLS="git help2man perl python3 build-essential ca-certificates"
ENV LEXER_TOOLS="flex bison libfl2 libfl-dev"
ENV BUILD_TOOLS="autoconf"
ENV ZLIB_TOOLS="zlib1g zlib1g-dev"

RUN apt-get update && apt-get install -y --no-install-recommends \
    ${CORE_TOOLS} \
    ${LEXER_TOOLS} \
    ${BUILD_TOOLS} \
    ${ZLIB_TOOLS} && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

ARG VERILATOR_VERSION="v5.024"
ARG VERILATOR_URL="https://github.com/verilator/verilator.git"

RUN git clone https://github.com/verilator/verilator && \
    unset VERILATOR_ROOT && \
    cd verilator && \
    git pull && \
    git checkout ${VERILATOR_VERSION} &&\
    autoconf &&\
    ./configure --prefix=/usr/local/verilator && \
    make -j$(nproc) && \
    make install && \
    cd .. && \
    rm -rf verilator

FROM ubuntu:24.04 AS systemc_provider

ARG SYSTEMC_VERSION=2.3.4
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential tar wget cmake ca-certificates && \
    rm -rf /var/lib/apt/lists/*

RUN wget https://github.com/accellera-official/systemc/archive/refs/tags/${SYSTEMC_VERSION}.tar.gz -O systemc.tar.gz && \
    tar -xzf systemc.tar.gz && \
    cmake -S systemc-${SYSTEMC_VERSION} \
          -B build \
          -DCMAKE_INSTALL_PREFIX=/usr/local/systemc-${SYSTEMC_VERSION} \
          -DCMAKE_CXX_EXTENSIONS=OFF && \
    cmake --build build --parallel && \
    cmake --install build && \
    rm -rf build systemc.tar.gz systemc-${SYSTEMC_VERSION}

# --------- Stage base ---------
FROM ubuntu:24.04 AS base

ARG UID=1001
ARG GID=1001
ARG USERNAME=user

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Taipei

# Set environment variables
ENV USER=${USERNAME} \
    HOME=/home/${USERNAME} \
    PATH="${PATH}:/home/${USERNAME}/.local/bin" \
    TZ=${TZ} \
    LC_ALL=en_US.UTF-8

# 安裝基本工具、時區設定、中文 locale 支援
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        tzdata sudo locales && \
    ln -fns /usr/share/zoneinfo/${TZ} /etc/localtime && \
    echo "${TZ}" > /etc/timezone && \
    dpkg-reconfigure -f noninteractive tzdata && \
    sed -i 's/# en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen && \
    sed -i 's/# zh_TW.UTF-8/zh_TW.UTF-8/' /etc/locale.gen && \
    sed -i 's/# zh_TW BIG5/zh_TW BIG5/' /etc/locale.gen && \
    locale-gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8

RUN mkdir -p /etc/sudoers.d && \
    groupadd -g ${GID} "${USERNAME}" && \
    useradd -u ${UID} -m -s /bin/bash -g ${GID} "${USERNAME}" && \
    echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/"${USERNAME}" && \
    chmod 0440 /etc/sudoers.d/"${USERNAME}" && \
    passwd -d "${USERNAME}" && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# User account configuration
RUN mkdir -p /home/"${USERNAME}"/.ssh && \
    mkdir -p /home/"${USERNAME}"/.vscode-server && \
    mkdir -p /home/"${USERNAME}"/projects
RUN chown -R ${UID}:${GID} /home/"${USERNAME}"

ENV CORE_TOOLS="apt-utils sudo vim git gdb"
ENV WEB_TOOLS="curl wget ca-certificates"
ENV DEVELOPMENT_TOOLS="build-essential"
ENV PYTHON_PACKAGES="python3 python3-pip"

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      ${CORE_TOOLS} \
      ${WEB_TOOLS} \
      ${DEVELOPMENT_TOOLS} \
      ${PYTHON_PACKAGES} && \
    rm -rf /var/lib/apt/lists/*

    ### 1. Copy and setup Miniconda
COPY --from=conda_provider /opt/conda /opt/conda
RUN chown -R ${UID}:${GID} /opt/conda
ENV CONDA_HOME=/opt/conda
ENV PATH=${CONDA_HOME}/condabin:${PATH}

### 2. Copy and setup Verilator
COPY --from=verilator_provider /usr/local/verilator /usr/local/verilator
ENV VERILATOR_HOME=/usr/local/verilator
ENV PATH=${VERILATOR_HOME}/bin:${PATH}

### 3. Copy and setup SystemC
ARG SYSTEMC_VERSION=2.3.4
ENV SYSTEMC_HOME=/usr/local/systemc-${SYSTEMC_VERSION}
COPY --from=systemc_provider ${SYSTEMC_HOME} ${SYSTEMC_HOME}

ENV SYSTEMC_CXXFLAGS="-I${SYSTEMC_HOME}/include"
ENV SYSTEMC_LDFLAGS="-L${SYSTEMC_HOME}/lib \
                     -L${SYSTEMC_HOME}/lib-linux \
                     -L${SYSTEMC_HOME}/lib-linux64 \
                     -lsystemc"

# Expose SystemC headers and libraries path to the toolchain
ENV CPATH="${SYSTEMC_HOME}/include:" \
    LIBRARY_PATH="${SYSTEMC_HOME}/lib:${SYSTEMC_HOME}/lib-linux:${SYSTEMC_HOME}/lib-linux64:"
# Register runtime library paths and refresh the dynamic linker cache
RUN for d in lib lib-linux lib-linux64; do \
        if [ -d "${SYSTEMC_HOME}/${d}" ]; then \
            echo "${SYSTEMC_HOME}/${d}" > /etc/ld.so.conf.d/systemc-${d}.conf; \
        fi; \
    done && ldconfig

# Copy the eman script to the container
COPY ./scripts/eman.sh /usr/local/bin/eman
RUN chmod +x /usr/local/bin/eman
# Make sure the eman script can be executed by the user
ENV PATH="/usr/local/bin:${PATH}"

# 切換使用者
USER ${USERNAME}
WORKDIR /home/${USERNAME}

# Optional: 測試用
# RUN verilator --version && gcc --version && conda --version