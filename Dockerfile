FROM alpine as build

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

RUN git clone --recurse-submodules https://github.com/radareorg/cutter.git /cutter

WORKDIR /cutter

RUN bash build.sh

FROM 0x01be/xpra

USER root
RUN apk add --no-cache --virtual cutter-runtime-dependencies \
    bash \
    libuuid \
    make \
    python3 \
    qt5-qtbase \
    qt5-qtsvg \
    shadow \
    su-exec

RUN apk add --no-cache --virtual build-dependencies \
    --repository http://dl-cdn.alpinelinux.org/alpine/edge/main \
    --repository http://dl-cdn.alpinelinux.org/alpine/edge/community \
    --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing \
    radare2 \
    radare2-dev \
    radare2-libs \
    radare2-dbg \
    radare2-cutter-dev

COPY --from=build /cutter/build/Cutter /usr/bin/
COPY --from=build /cutter/build/Cutter /workspace/

USER xpra

ENV COMMAND "Cutter"

