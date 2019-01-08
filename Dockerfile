FROM ubuntu:16.04

RUN apt-get update && \
    apt-get install -y \
	# Tools used during docker build
        ca-certificates \
        curl \
	jq \
	# Source control
        git \
	# prjxray build tools
        build-essential \
        python \
        cmake \
	clang-format \
	# Python needs
	python3 \
	virtualenv \
	python3-virtualenv \
	python3-yaml \
        # vpr build tools
	bison \
	flex \
	fontconfig && \
    rm -rf /var/lib/apt

# Install gosu so the entrypoint can switch to a non-root account at runtime. 
RUN gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4
RUN curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/1.4/gosu-$(dpkg --print-architecture)" \
    && curl -o /usr/local/bin/gosu.asc -SL "https://github.com/tianon/gosu/releases/download/1.4/gosu-$(dpkg --print-architecture).asc" \
    && gpg --verify /usr/local/bin/gosu.asc \
    && rm /usr/local/bin/gosu.asc \
    && chmod +x /usr/local/bin/gosu

# Install Google Cloud SDK to enable downloading Vivado installer from GCS buckets.
RUN mkdir -p /staging
RUN curl https://dl.google.com/dl/cloudsdk/release/google-cloud-sdk.tar.gz | \
    tar -C /staging -zxf -
RUN /staging/google-cloud-sdk/install.sh

# Install Vivado from an install tar.gz downloaded from a URL
ARG VIVADO_URL
RUN test -n "${VIVADO_URL}"
ARG VIVADO_VERSION=2017.2
ARG VIVADO_RELEASE=0616_1
ARG VIVADO_INSTALLER_DIR=Xilinx_Vivado_SDK_${VIVADO_VERSION}_${VIVADO_RELEASE}
ENV VIVADO_BIN=/opt/Xilinx/Vivado/${VIVADO_VERSION}/bin
ENV PATH=$PATH:$VIVADO_BIN

COPY install_config.txt /staging/
# Use a wildcard for the token so the copy won't fail if it doesn't exist.
COPY stream_url.sh *_token /staging/
RUN /staging/stream_url.sh "${VIVADO_URL}" | tar -C /staging -zxf - && \
    /staging/${VIVADO_INSTALLER_DIR}/xsetup \
        -b Install \
        -a XilinxEULA,3rdPartyEULA,WebTalkTerms \
        -c /staging/install_config.txt && \
    rm -rf /staging

# Setup an entrypoint that creates a non-root user and switches to it.
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
