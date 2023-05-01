# Protoc Compiler

This image provides a dockerized protoc compiler, Buf, Golang, Python and pip pre-installed.
Run this container to compile protobuf files. 

## Plugin Development

You can extend this image to run the compiler of Buf commands with custom protoc plugins. 
Golang and Python are pre-installed. 

```dockerfile
FROM leadtech/protoc:buf

# Needed for custom protoc plugins written in python
ENV PROTOCOL_BUFFERS_PYTHON_IMPLEMENTATION=python

ADD . /opt/my-proto-project
WORKDIR /opt/my-proto-project

RUN pip3 install -r requirements.txt
```