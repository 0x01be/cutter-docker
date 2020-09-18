FROM alpine

RUN apk add --no-cache --virtual cutter-build-dependencies \
    git \
    build-base \
    cmake \
    curl \
    linux-headers \
    pkgconfig \
    python3-dev \
    py3-pip \
    qt5-qtbase \
    qt5-qtsvg-dev \
    qt5-qttools-dev \
    unzip \
    wget \
    bash \
    bison \
    flex \
    openssl-dev \
    autoconf \
    automake \
    libtool \
    pkgconfig \
    python3-dev \
    m4 \
    zlib-dev \
    graphviz \
    meson

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

ENV BUILD_SYSTEM cmake
RUN cmake \
    -DCMAKE_INSTALL_PREFIX=/opt/cutter \
    -DCUTTER_USE_BUNDLED_RADARE2=OFF \
    -DCUTTER_ENABLE_PYTHON=ON \
    -DCUTTER_ENABLE_PYTHON_BINDING=ON \
    -DCUTTER_ENABLE_KSYNTAXHIGHLIGHTING=ON \
    -DCUTTER_ENABLE_GRAPHVIZ=ON \
    -DCUTTER_EXTRA_PLUGIN_DIRS=/opt/cutter/plugins/ \
    -DCUTTER_ENABLE_CRASH_REPORTS=OFF \
    -DCUTTER_PACKAGE_DEPENDENCIES=OFF \
    ../src
RUN cmake --build .

RUN r2pm init
RUN pip3 install --prefix='/opt/angr' angr 
RUN pip3 install --prefix='/opt/angrdbg' angr 

WORKDIR /

