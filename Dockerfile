FROM 0x01be/cutter:build as build

FROM 0x01be/xpra

COPY --from=build /opt/cutter/ /opt/cutter/

RUN apk add --no-cache --virtual cutter-runtime-dependencies \
    bash \
    libuuid \
    make \
    shadow \
    su-exec \
    graphviz &&\
    apk add --no-cache --virtual build-dependencies \
    --repository http://dl-cdn.alpinelinux.org/alpine/edge/main \
    --repository http://dl-cdn.alpinelinux.org/alpine/edge/community \
    --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing \
    radare2 \
    radare2-dev \
    radare2-libs \
    radare2-dbg \
    radare2-cutter-dev \
    python3 \
    qt5-qtbase \
    qt5-qtsvg &&\
    chown -R ${USER}:${USER} /opt/cutter/plugins &&\
    chown -R ${USER}:${USER} ${WORKSPACE}

USER ${USER}
ENV PATH=${PATH}:/opt/cutter/bin/:/opt/angr/bin/:/opt/jupyter/bin/ \
    PYTHONPATH=/opt/jupyter/lib/python3.8/site-packages:/opt/angr/lib/python3.8/site-packages:/usr/lib/python3.8/site-packages \
    COMMAND=Cutter

