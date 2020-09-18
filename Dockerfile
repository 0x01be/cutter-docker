FROM 0x01be/cutter:build as build

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
    su-exec \
    graphviz

RUN apk add --no-cache --virtual build-dependencies \
    --repository http://dl-cdn.alpinelinux.org/alpine/edge/main \
    --repository http://dl-cdn.alpinelinux.org/alpine/edge/community \
    --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing \
    radare2 \
    radare2-dev \
    radare2-libs \
    radare2-dbg \
    radare2-cutter-dev

COPY --from=build /opt/ /opt/

USER xpra
ENV PATH $PATH:/opt/cutter/bin/:/opt/angr/bin/:/opt/jupyter/bin/

WORKDIR /workspace

ENV COMMAND "Cutter"

