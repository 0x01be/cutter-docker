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
    bash \
    bison \
    flex \
    libressl-dev \
    autoconf \
    automake \
    libtool \
    pkgconfig \
    python3-dev \
    m4 \
    zlib-dev

RUN apk add --no-cache --virtual cutter-edge-build-dependencies \
    --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing  \
    --repository http://dl-cdn.alpinelinux.org/alpine/edge/community  \
    --repository http://dl-cdn.alpinelinux.org/alpine/edge/main \
    radare2-dbg \
    radare2-dev \
    capstone-dev \
    libzip-dev

ENV CUTTER_REVISION master
RUN git clone --recursive --branch ${CUTTER_REVISION} https://github.com/radareorg/cutter.git /cutter

ENV R2GHIDRA_REVISION master
RUN git clone --recursive --branch ${R2GHIDRA_REVISION} https://github.com/radareorg/r2ghidra.git /r2ghidra

ENV RETDEC_REVISION master
RUN git clone --depth 1 --branch ${RETDEC_REVISION} https://github.com/avast/retdec-r2plugin.git /r2retdec

WORKDIR /r2retdec/build

RUN cmake \
    -DCMAKE_INSTALL_PREFIX=/opt/r2retdec \
    -DBUILD_CUTTER_PLUGIN=ON \
    ..
RUN make install

WORKDIR /r2ghidra/build

RUN cmake \
    -DCMAKE_INSTALL_PREFIX=/opt/r2ghidra \
    -DBUILD_CUTTER_PLUGIN=ON \
    -DCUTTER_SOURCE_DIR=/cutter \
    ..
#RUN make install

WORKDIR /cutter

RUN lrelease ./src/Cutter.pro

WORKDIR /cutter/build/

RUN qmake ../src/Cutter.pro
RUN make

RUN r2pm init

