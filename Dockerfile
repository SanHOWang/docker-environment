FROM ubuntu:24.04

ARG UID=1001
ARG GID=1001
ARG USERNAME=user

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Taipei

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        tzdata \
        sudo && \
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

USER ${USERNAME}
WORKDIR /home/${USERNAME}
