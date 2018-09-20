FROM alpine:3.8

LABEL maintainer="Carlos Remuzzi <carlosremuzzi@gmail.com>"
LABEL version=0.18.0

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

COPY add-ecc-curves.patch libressl-2.7.patch  ./

RUN curl -fsL https://github.com/OpenSC/OpenSC/releases/download/0.18.0/opensc-0.18.0.tar.gz  -o opensc-0.18.0.tar.gz \
    && tar -zxf opensc-0.18.0.tar.gz \
    && rm opensc-0.18.0.tar.gz \
    && mv *.patch opensc-0.18.0 \
    && cd opensc-0.18.0 \
    && patch src/tools/pkcs11-tool.c -i add-ecc-curves.patch \
    && patch src/libopensc/sc-ossl-compat.h -i libressl-2.7.patch \
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
        LDFLAGS='-Wl,--as-needed' \
        CFLAGS='-fno-strict-aliasing -Os -fomit-frame-pointer -Werror=declaration-after-statement' \
    && make \
    && make install \
    && apk del .build-deps \
    && rm -r /usr/src/build

RUN addgroup -g 1000 opensc \
    && adduser -u 1000 -G opensc -s /bin/sh -D opensc \
    && mkdir -p /run/pcscd \
    && chown -R nobody:nobody /run/pcscd

WORKDIR /home/opensc

USER opensc

CMD ["pcscd","-f","-i"]
