FROM alpine

RUN apk add --no-cache --virtual cutter-build-dependencies \
    git \
    build-base \
    autoconf \
    automake \
    libtool \
    pkgconfig \
    cmake \
    unzip \
    wget \
    bash \
    bison \
    flex \
    curl \
    linux-headers \
    pkgconfig \
    python3-dev \
    py3-pip \
    qt5-qtbase \
    qt5-qtsvg-dev \
    qt5-qttools-dev \
    openssl-dev \
    m4 \
    zlib-dev \
    graphviz-dev

RUN apk add --no-cache --virtual cutter-edge-build-dependencies \
    --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing  \
    --repository http://dl-cdn.alpinelinux.org/alpine/edge/community  \
    --repository http://dl-cdn.alpinelinux.org/alpine/edge/main \
    radare2-dbg \
    radare2-dev \
    capstone-dev \
    libzip-dev \
    libshiboken2-dev \
    py3-shiboken2 \
    shiboken2

ENV CUTTER_REVISION master
RUN git clone --recursive --branch ${CUTTER_REVISION} https://github.com/radareorg/cutter.git /cutter

WORKDIR /cutter

RUN lrelease-qt5 ./src/Cutter.pro

WORKDIR /cutter/build/

ENV BUILD_SYSTEM cmake
ENV PLUGINS_DIR /opt/cutter/plugins
RUN cmake \
    -DCMAKE_INSTALL_PREFIX=/opt/cutter \
    -DCUTTER_USE_BUNDLED_RADARE2=OFF \
    -DCUTTER_ENABLE_PYTHON=ON \
    -DCUTTER_ENABLE_PYTHON_BINDINGS=ON \
    -DCUTTER_ENABLE_KSYNTAXHIGHLIGHTING=OFF \
    -DCUTTER_ENABLE_GRAPHVIZ=ON \
    -DCUTTER_EXTRA_PLUGIN_DIRS=${PLUGINS_DIR} \
    -DCUTTER_ENABLE_CRASH_REPORTS=OFF \
    -DCUTTER_PACKAGE_DEPENDENCIES=OFF \
    ../src
RUN make install

RUN mkdir -p /opt/cutter/plugins/python

RUN apk add --no-cache --virtual anglr-build-dependencies \
    py3-wheel \
    py3-z3 \
    z3-dev
RUN pip3 install --prefix='/opt/angr' angr 
RUN pip3 install --prefix='/opt/angr' angrdbg
RUN git clone --depth 1 https://github.com/yossizap/angrcutter.git /angrcutter

RUN pip3 install --prefix='/opt/jupyter' jupyter
RUN git clone --depth 1 https://github.com/radareorg/cutter-jupyter.git /jupytercutter

RUN git clone --depth 1 https://github.com/yossizap/cutterref.git /cutterref

RUN git clone --depth 1 https://github.com/JavierYuste/radare2-deep-graph.git /deep-graph

RUN git clone --recursive https://github.com/radareorg/r2ghidra.git /r2ghidra
WORKDIR /r2ghidra/build
RUN cmake \
    -DCMAKE_INSTALL_PREFIX=/opt/r2ghidra \
    -DBUILD_CUTTER_PLUGIN=ON \
    -DCUTTER_SOURCE_DIR=/cutter \
    ..
#RUN make install

# Consumes too much memory to build
#ENV RETDEC_REVISION master
#RUN git clone --depth 1 --branch ${RETDEC_REVISION} https://github.com/avast/retdec-r2plugin.git /r2retdec
#WORKDIR /r2retdec/build
#RUN cmake \
#    -DCMAKE_INSTALL_PREFIX=/opt/r2retdec \
#    -DBUILD_CUTTER_PLUGIN=ON \
#    ..
#RUN make install

WORKDIR /

