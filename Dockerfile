FROM ubuntu:16.04

RUN apt-get update && apt-get install -y \
    build-essential \
    ca-certificates \
    cmake \
    curl \
    git \
    python3

# Install gosu so the entrypoint can switch to a non-root account at runtime. 
RUN gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4
RUN curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/1.4/gosu-$(dpkg --print-architecture)" \
    && curl -o /usr/local/bin/gosu.asc -SL "https://github.com/tianon/gosu/releases/download/1.4/gosu-$(dpkg --print-architecture).asc" \
    && gpg --verify /usr/local/bin/gosu.asc \
    && rm /usr/local/bin/gosu.asc \
    && chmod +x /usr/local/bin/gosu

# Install Vivado from an install tar.gz downloaded from a URL
ARG VIVADO_URL
RUN test -n "${VIVADO_URL}"
ARG VIVADO_VERSION=2017.2
ARG VIVADO_RELEASE=0616_1
ARG VIVADO_INSTALLER_DIR=Xilinx_Vivado_SDK_${VIVADO_VERSION}_${VIVADO_RELEASE}
ENV VIVADO_BIN=/opt/Xilinx/Vivado/${VIVADO_VERSION}/bin

COPY install_config.txt /staging/
RUN curl "${VIVADO_URL}" | tar -C /staging -zxf - && \
        /staging/${VIVADO_INSTALLER_DIR}/xsetup \
	-b Install \
	-a XilinxEULA,3rdPartyEULA,WebTalkTerms \
	-c /staging/install_config.txt && \
    rm -rf /staging

# Setup an entrypoint that creates a non-root user and switches to it.
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
