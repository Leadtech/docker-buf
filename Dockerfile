FROM debian:11.6-slim

ENV BUF_VERSION=v1.16.0 \
    # Configure protoc installation
    PROTOC_INSTALL_VERSIONS="21.12 22.2" \
    DEFAULT_PROTOC_VERSION=22.2 \
    PROTOC_HOME=/opt/protoc \
    # Configure Golang
    GOROOT=/opt/go \
    GOPATH=/opt/go/packages

WORKDIR /opt/

# Install dependencies & python
RUN mkdir -p \
      /usr/share/man/man1/  \
      "$PROTOC_HOME/bin" \
    && apt-get update -qqy \
    && apt-get install -qqy \
      bash \
      curl \
      wget \
      python3-dev  \
      python3-pip  \
      apt-transport-https \
      git \
      unzip \
    && pip3 install -U crcmod \
    && rm -rf /var/lib/apt/lists/* \
    # Clean up
    && apt-get clean \
    # Install Golang
    && wget https://go.dev/dl/go1.20.linux-amd64.tar.gz \
    && tar -xvf go1.20.linux-amd64.tar.gz \
    && rm go1.20.linux-amd64.tar.gz

ENV PATH="/opt/bin:$GOPATH/bin:$GOROOT/bin:$PROTOC_HOME/bin:$PATH"

# Install buf
RUN go install github.com/bufbuild/buf/cmd/buf@${BUF_VERSION}

# Prepare image
ADD .docker /opt/docker

RUN chmod ug+x /opt/docker/entrypoint.sh \
    # Make sure go binaries are executable
    /opt/docker/init \
    # Make sure go binaries are executable
    $GOROOT/bin \
    $GOPATH/bin -R \
    # Pre-install protoc releases
    && /opt/docker/init/5-install-protoc.sh

# If you extend this image, don't override the entrypoint.
# Instead add your startup scripts to /opt/docker/init/
# The scripts are sorted, so you can suffix the files to control the execution order.
# Startup scripts must have the *.sh file extension.
ENTRYPOINT ["/opt/docker/entrypoint.sh"]
CMD ["/bin/bash"]
