FROM alpine:3.9

ARG LIBP11_VERSION=0.4.10
ARG OPENSC_VERSION=0.19.0

LABEL maintainer="Carlos Remuzzi <carlosremuzzi@gmail.com>"
LABEL version=${OPENSC_VERSION}

WORKDIR /usr/src/build

RUN apk add --no-cache \
        ccid \
        openssl \
        pcsc-lite \
        pcsc-lite-dev \
    && apk add --no-cache --virtual .build-deps \
        autoconf \
        automake \
        build-base \
        curl \
        gettext \
        openssl-dev \
        libtool \
        m4 \
        readline-dev \
        zlib-dev \
    && curl -fsL https://github.com/OpenSC/OpenSC/releases/download/${OPENSC_VERSION}/opensc-${OPENSC_VERSION}.tar.gz  -o opensc-${OPENSC_VERSION}.tar.gz \
    && tar -zxf opensc-${OPENSC_VERSION}.tar.gz \
    && rm opensc-${OPENSC_VERSION}.tar.gz \
    && cd opensc-${OPENSC_VERSION} \
    && ./bootstrap \
    && ./configure \
        --host=x86_64-alpine-linux-musl \
        --prefix=/usr \
        --sysconfdir=/etc \
        --disable-man \
        --enable-zlib \
        --enable-readline \
        --enable-openssl \
        --enable-pcsc \
        --enable-sm \
        CC='gcc' \
    && make \
    && make install \
    && curl -fsL https://github.com/OpenSC/libp11/releases/download/libp11-${LIBP11_VERSION}/libp11-${LIBP11_VERSION}.tar.gz -o libp11-${LIBP11_VERSION}.tar.gz \
    && tar -zxf libp11-${LIBP11_VERSION}.tar.gz \
    && rm libp11-${LIBP11_VERSION}.tar.gz \
    && cd libp11-${LIBP11_VERSION} \
    && ./configure \
    && make \
    && make install \
    && apk del .build-deps \
    && rm -r /usr/src/build \
    && addgroup -g 1000 opensc \
    && adduser -u 1000 -G opensc -s /bin/sh -D opensc \
    && mkdir -p /run/pcscd \
    && chown -R nobody:nobody /run/pcscd

WORKDIR /

CMD ["pcscd","-f","-i"]
