FROM debian:11.6-slim

ENV PROTOC_VERSION="21.12"

ADD .docker /docker

RUN mkdir -p /usr/share/man/man1/ /opt/protoc

RUN apt-get update -qqy
RUN apt-get install -qqy bash curl wget gcc
RUN apt-get install -qqy make python3-dev python3-pip
RUN apt-get install -qqy apt-transport-https lsb-release openssh-client
RUN apt-get install -qqy git gnupg autoconf automake libtool g++ unzip
RUN pip3 install -U crcmod

RUN wget https://github.com/protocolbuffers/protobuf/releases/download/v${PROTOC_VERSION}/protoc-${PROTOC_VERSION}-linux-x86_64.zip
RUN unzip protoc-${PROTOC_VERSION}-linux-x86_64.zip -d /opt/protoc && rm protoc-${PROTOC_VERSION}-linux-x86_64.zip
RUN chmod ug+x /opt/protoc/bin/ -R

RUN rm -rf /var/lib/apt/lists/* && apt-get clean

WORKDIR /opt/
ENV PATH="$PATH:/opt/protoc/bin/"

ENTRYPOINT ["/bin/bash"]

