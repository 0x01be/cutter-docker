FROM alpine

RUN apk add --no-cache --virtual cutter-build-dependencies \
    git \
    build-base \
    cmake \
    curl \
    linux-headers \
    pkgconfig \
    python3-dev \
    qt5-qtbase \
    qt5-qtsvg-dev \
    qt5-qttools-dev \
    unzip \
    wget \
    bash

RUN apk add --no-cache --virtual cutter-edge-build-dependencies \
    --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing  \
    --repository http://dl-cdn.alpinelinux.org/alpine/edge/community  \
    --repository http://dl-cdn.alpinelinux.org/alpine/edge/main \
    radare2-dbg

ENV REVISION master

RUN git clone --recursive --branch ${REVISION} https://github.com/radareorg/cutter.git /cutter

WORKDIR /cutter

RUN bash build.sh

