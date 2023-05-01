# Protoc Compiler

This image provides a dockerized protoc compiler, with Python (3) and pip pre-installed. The intended use for this image is to provide a ready to use protoc executable. 
The python setup is useful when developing protoc plugins in Python. 
Run this container to compile protobuf files. Alternatively, extend this image to set up a development environment for protoc plugin development.


```dockerfile
FROM leadtech/protoc:latest

ENV PROTOCOL_BUFFERS_PYTHON_IMPLEMENTATION=python
ADD . /opt/proto
WORKDIR /opt/proto

RUN pip3 install -r requirements.txt
```