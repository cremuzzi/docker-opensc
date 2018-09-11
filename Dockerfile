FROM alpine:3.8

WORKDIR /usr/src/build

RUN apk add --no-cache \
        libressl-dev \
        pcsc-lite \
        pcsc-lite-dev \
        readline-dev \
        zlib-dev \
    && apk add --no-cache --virtual .build-deps \
        autoconf \
        automake \
        build-base \
        curl \
        gettext \
        libtool \
        m4

RUN curl -fsL https://github.com/OpenSC/OpenSC/releases/download/0.18.0/opensc-0.18.0.tar.gz  -o opensc-0.18.0.tar.gz \
    && tar -zxf opensc-0.18.0.tar.gz \
    && rm opensc-0.18.0.tar.gz \
    && cd opensc-0.18.0 \
    && ./bootstrap

RUN cd opensc-0.18.0 \
    && ./configure \
        --host=x86_64-pc-linux-musl \
        --prefix=/usr \
        --sysconfdir=/etc \
        --disable-man \
        --enable-zlib \
        --enable-readline \
        --enable-openssl \
        --enable-pcsc \
        --enable-sm \
        LDFLAGS='-Wl,--as-needed' \
        CFLAGS='-fno-strict-aliasing -Os -fomit-frame-pointer -Wall -Wextra -Wno-unused-parameter -Werror=declaration-after-statement' \
    && make

RUN apk del .build-deps
