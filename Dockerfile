# Utiliser une image de base plus légère
FROM --platform=$BUILDPLATFORM ubuntu:20.04

LABEL maintainer="DYLANE BENGONO <chaneldylanebengono@gmail.com>"

# Désactiver les invites interactives
ENV DEBIAN_FRONTEND=noninteractive

# Installer les dépendances nécessaires et nettoyer dans une seule couche
RUN apt-get update && apt-get install -y --no-install-recommends \
    git libtool pkg-config autoconf gettext \
    libpcap-dev g++ vim make cmake wget libssl-dev \
    liblzma-dev python3-pip unzip protobuf-compiler \
    golang nano net-tools automake build-essential \
    && rm -rf /var/lib/apt/lists/*

# Déterminer l'architecture et télécharger la version appropriée de Go
RUN ARCH=$(dpkg --print-architecture) && \
    if [ "$ARCH" = "amd64" ]; then \
    GO_BIN=go1.22.4.linux-amd64.tar.gz; \
    elif [ "$ARCH" = "arm64" ]; then \
    GO_BIN=go1.22.4.linux-arm64.tar.gz; \
    else \
    echo "Unsupported architecture"; exit 1; \
    fi && \
    wget https://go.dev/dl/${GO_BIN} && \
    tar -xvf ${GO_BIN} && \
    mv go /usr/local && \
    rm -rf ${GO_BIN}
ENV PATH=$PATH:/usr/local/go/bin
RUN ln -s /usr/local/go/bin/go /usr/local/bin/go

# Installer protoc-gen-go et protoc-gen-go-grpc tools
RUN go install github.com/golang/protobuf/protoc-gen-go@v1.5.2 && \
    go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@v1.1.0 && \
    mv /root/go/bin/protoc-gen-go /usr/local/bin/ && \
    mv /root/go/bin/protoc-gen-go-grpc /usr/local/bin/

# Créer des répertoires de travail
RUN mkdir /work /packages

# Copier les règles Snort
COPY rules/snort3.rules /work/

# Construire libdaq
ENV LIBDAQ_VERSION=3.0.15
RUN cd /work && wget https://github.com/snort3/libdaq/archive/refs/tags/v${LIBDAQ_VERSION}.tar.gz && \
    tar -xvf v${LIBDAQ_VERSION}.tar.gz && \
    cd libdaq-${LIBDAQ_VERSION} && ./bootstrap && ./configure && make && make install && \
    cd /work && rm -rf v${LIBDAQ_VERSION}.tar.gz

# Installer libdnet
ENV LIBDNET_VERSION=1.14
RUN cd /work && wget https://github.com/ofalk/libdnet/archive/refs/tags/libdnet-${LIBDNET_VERSION}.tar.gz && \
    tar -xvf libdnet-${LIBDNET_VERSION}.tar.gz && \
    cd libdnet-libdnet-${LIBDNET_VERSION} && \
    wget -O config.guess 'https://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.guess;hb=HEAD' && \
    wget -O config.sub 'https://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.sub;hb=HEAD' && \
    ./configure && make && make install && \
    cd /work && rm -rf libdnet-libdnet-${LIBDNET_VERSION} libdnet-${LIBDNET_VERSION}.tar.gz

# Installer flex
ENV FLEX_VERSION=2.6.4
RUN cd /work && wget https://github.com/westes/flex/files/981163/flex-${FLEX_VERSION}.tar.gz && \
    tar -xvf flex-${FLEX_VERSION}.tar.gz && \
    cd flex-${FLEX_VERSION} && ./configure && make && make install && \
    cd /work && rm -rf flex-${FLEX_VERSION} flex-${FLEX_VERSION}.tar.gz

# Installer hwloc
ENV HWLOC_VERSION=2.5.0
RUN cd /work && wget https://download.open-mpi.org/release/hwloc/v2.5/hwloc-${HWLOC_VERSION}.tar.gz && \
    tar -xvf hwloc-${HWLOC_VERSION}.tar.gz && \
    cd hwloc-${HWLOC_VERSION} && ./configure && make && make install && \
    cd /work && rm -rf hwloc-${HWLOC_VERSION} hwloc-${HWLOC_VERSION}.tar.gz

# Installer LuaJIT
ENV LUAJIT_VERSION=2.1.0-beta3
RUN cd /work && git clone https://luajit.org/git/luajit.git && \
    cd luajit && make && make install && \
    cd /work && rm -rf luajit

# Installer PCRE
ENV PCRE_VERSION=8.45
RUN cd /work && wget https://sourceforge.net/projects/pcre/files/pcre/${PCRE_VERSION}/pcre-${PCRE_VERSION}.tar.gz && \
    tar -xvf pcre-${PCRE_VERSION}.tar.gz && \
    cd pcre-${PCRE_VERSION} && ./configure && make && make install && \
    cd /work && rm -rf pcre-${PCRE_VERSION} pcre-${PCRE_VERSION}.tar.gz

# Installer zlib
ENV ZLIB_VERSION=1.2.13
RUN cd /work && wget https://github.com/madler/zlib/releases/download/v${ZLIB_VERSION}/zlib-${ZLIB_VERSION}.tar.gz && \
    tar -xvf zlib-${ZLIB_VERSION}.tar.gz && \
    cd zlib-${ZLIB_VERSION} && ./configure && make && make install && \
    cd /work && rm -rf zlib-${ZLIB_VERSION} zlib-${ZLIB_VERSION}.tar.gz

# Installer Snort 3
ENV SNORT_VER=3.3.1.0
RUN cd /work && wget https://github.com/snort3/snort3/archive/refs/tags/${SNORT_VER}.tar.gz && \
    tar -xvf ${SNORT_VER}.tar.gz && \
    cd snort3-${SNORT_VER} && chmod +x configure_cmake.sh && ./configure_cmake.sh --prefix=/usr/local && \
    cd build && make -j$(nproc) VERBOSE=1 install && \
    cd /work && rm -rf snort3-${SNORT_VER} ${SNORT_VER}.tar.gz

# Déplacer les règles Snort vers le répertoire approprié
RUN mv /work/snort3.rules /usr/local/etc/snort
