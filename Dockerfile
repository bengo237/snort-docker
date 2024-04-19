# Snort in Docker
ARG UBUNTU_VERSION="focal-20230126"
FROM ubuntu:${UBUNTU_VERSION}
LABEL maintainer="Dylane Bengono <chaneldylanebengono@gmail.com>"
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt -y install \
    git libtool pkg-config autoconf gettext \
    libpcap-dev g++ vim make cmake wget libssl-dev \
    liblzma-dev pip unzip protobuf-compiler \
    golang-goprotobuf-dev

ENV GO_BIN=go1.20.linux-amd64.tar.gz
RUN wget https://dl.google.com/go/${GO_BIN} \
    && tar -xvf ${GO_BIN} \
    && mv go /usr/local \
    && rm -rf ${GO_BIN}
RUN export PATH=$PATH:/usr/local/go/bin
RUN ln -s /usr/local/go/bin/go /usr/local/bin/go

RUN go install github.com/golang/protobuf/protoc-gen-go@latest
RUN go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
RUN cp /root/go/bin/protoc-gen-go /usr/local/bin/.
RUN cp /root/go/bin/protoc-gen-go-grpc /usr/local/bin/.

RUN mkdir /work
RUN mkdir /packages

# build libdaq
ENV LIBDAQ_VERSION=3.0.10
RUN cd /work && wget https://github.com/snort3/libdaq/archive/refs/tags/v${LIBDAQ_VERSION}.tar.gz
RUN cd /work && tar -xvf v${LIBDAQ_VERSION}.tar.gz
RUN cd /work/libdaq-${LIBDAQ_VERSION} && ./bootstrap && ./configure && make && make install
RUN cd /work && rm -rf v${LIBDAQ_VERSION}.tar.gz

RUN cd /work && wget https://github.com/ofalk/libdnet/archive/refs/tags/libdnet-1.14.tar.gz
RUN cd /work && tar -xvf libdnet-1.14.tar.gz && cd libdnet-libdnet-1.14 && ./configure && make && make install
RUN cd /work && rm -rf libdnet-libdnet-1.14 && rm libdnet-1.14.tar.gz

RUN cd /work && wget https://github.com/westes/flex/files/981163/flex-2.6.4.tar.gz
RUN cd /work && tar -xvf flex-2.6.4.tar.gz && cd flex-2.6.4 && ./configure && make && make install
RUN cd /work && rm -rf flex-2.6.4 && rm flex-2.6.4.tar.gz

RUN cd /work && wget https://download.open-mpi.org/release/hwloc/v2.5/hwloc-2.5.0.tar.gz
RUN cd /work && tar -xvf hwloc-2.5.0.tar.gz && cd hwloc-2.5.0 && ./configure && make && make install
RUN cd /work && rm -rf hwloc-2.5.0 && rm hwloc-2.5.0.tar.gz

RUN cd /work && wget https://luajit.org/download/LuaJIT-2.1.0-beta3.tar.gz
RUN cd /work && tar -xvf LuaJIT-2.1.0-beta3.tar.gz && cd LuaJIT-2.1.0-beta3 && make && make install
RUN cd /work && rm -rf LuaJIT-2.1.0-beta3 && rm LuaJIT-2.1.0-beta3.tar.gz

RUN cd /work && wget https://sourceforge.net/projects/pcre/files/pcre/8.45/pcre-8.45.tar.gz
RUN cd /work && tar -xvf pcre-8.45.tar.gz && cd pcre-8.45 && ./configure && make && make install
RUN cd /work && rm -rf pcre-8.45 && rm pcre-8.45.tar.gz

RUN cd /work && wget https://github.com/madler/zlib/releases/download/v1.2.13/zlib-1.2.13.tar.gz
RUN cd /work && tar -xvf zlib-1.2.13.tar.gz && cd zlib-1.2.13 && ./configure && make && make install
RUN cd /work && rm -rf zlib-1.2.13 && rm zlib-1.2.13.tar.gz

ENV SNORT_VER=3.1.53.0
RUN cd /work && wget https://github.com/snort3/snort3/archive/refs/tags/${SNORT_VER}.tar.gz
RUN cd /work && tar -xvf ${SNORT_VER}.tar.gz && cd snort3-${SNORT_VER} && export my_path=/usr/local && ./configure_cmake.sh --prefix=$my_path
RUN cd /work/snort3-${SNORT_VER}/build && make -j 6 install
# Add the snort3-community-rules folder to the Docker image
ADD snort/snort3-community-rules/ /work/snort3-3.1.53.0/

RUN tar -zcvpf /packages/libpcre.tar.gz /usr/local/lib/libpcre.so*
RUN tar -zcvpf /packages/libluajit.tar.gz /usr/local/lib/libluajit*.so*
RUN tar -zcvpf /packages/libhwloc.tar.gz /usr/local/lib/libhwloc.so*
RUN tar -zcvpf /packages/libdnet.tar.gz /usr/local/lib/libdnet.so*
RUN tar -zcvpf /packages/snort3.tar.gz /usr/local/bin/snort /usr/local/lib/daq /usr/local/etc/snort/ /usr/local/lib/libdaq.so*