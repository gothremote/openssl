# our chosen base image
FROM debian:10-slim AS builder

# Reusable layer for base update
RUN apt-get update && apt-get -y dist-upgrade && apt-get clean

# build and install
WORKDIR /source/

# First install needed package for liboqs and the OpanSSL fork
RUN apt-get install -y --no-install-recommends git astyle cmake gcc libtool ninja-build libssl-dev python3-pytest python3-pytest-xdist unzip xsltproc doxygen graphviz
RUN apt-get install -y --no-install-recommends apt-transport-https ca-certificates build-essential
RUN update-ca-certificates

# Reusable layer for base update
RUN apt-get update && apt-get -y dist-upgrade && apt-get clean

#Clone the repositories
RUN git clone https://github.com/open-quantum-safe/liboqs.git
##TODO FIX build from source
RUN mkdir -p /source/openssl
COPY . /source/openssl/

WORKDIR /source/
# Build and install liboqs correctly
RUN cd liboqs && mkdir build && cd build && cmake -GNinja -DCMAKE_INSTALL_PREFIX=/source/openssl/oqs .. && ninja && ninja install

# BUild and install custon OpenSSL Lib
WORKDIR /source/
RUN cd openssl && ./Configure no-shared linux-x86_64 -lm && make && make install