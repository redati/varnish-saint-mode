# docker build -t misaelgomes/varnish-saint-mode .
#https://raw.githubusercontent.com/emgag/docker-varnish/master/6.4/Dockerfile

FROM debian:buster-slim


ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=America/Sao_Paulo
# syntax=docker/dockerfile:experimental


#
# install varnish build deps
#
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        automake \
        autotools-dev \
        build-essential \
        ca-certificates \
        curl \
        git \
        libedit-dev \
        libgetdns-dev \
        libjemalloc-dev \
        libmhash-dev \
        libncurses-dev \
        libpcre3-dev \
        libtool \
        pkg-config \
        python3 \
        python3-docutils \
        python3-sphinx \
    && apt-get autoremove -y

#
# install varnish
#
ENV VARNISH_VERSION=6.4.0
ENV VARNISH_SHA256SUM=f636ba2d881b146f480fb52efefae468b36c2c3e6620d07460f9ccbe364a76c2

RUN mkdir -p /usr/local/src && \
    cd /usr/local/src && \
    curl -sfLO https://varnish-cache.org/_downloads/varnish-${VARNISH_VERSION}.tgz && \
    echo "${VARNISH_SHA256SUM} varnish-${VARNISH_VERSION}.tgz" | sha256sum -c - && \
    tar -xzf varnish-${VARNISH_VERSION}.tgz && \
    cd varnish-${VARNISH_VERSION} && \
    ./autogen.sh && \
    ./configure && \
    make install && \
    cd /usr/local/src && \
    rm -rf varnish-*

#
# install stock varnish module library
#
ENV VARNISHMODULES_BRANCH=6.4
ENV VARNISHMODULES_COMMIT=0032ed81820cbc7d8d0bdda8f0a14dc968a9de4f

RUN cd /usr/local/src/ && \
    git clone -b ${VARNISHMODULES_BRANCH} https://github.com/varnish/varnish-modules.git && \
    cd varnish-modules && \
    git reset --hard ${VARNISHMODULES_COMMIT} && \
    ./bootstrap && \
    ./configure && \
    make install && \
    cd /usr/local/src && \
    rm -rf varnish-modules && \
    ldconfig


#
# install libvmod-dynamic
#
ENV LIBVMOD_DYNAMIC_BRANCH=master
ENV LIBVMOD_DYNAMIC_COMMIT=71820eb7f91ad7e87755d02e522893a9e12dd55b

RUN cd /usr/local/src/ && \
    git clone -b ${LIBVMOD_DYNAMIC_BRANCH} https://github.com/nigoroll/libvmod-dynamic.git && \
    cd libvmod-dynamic && \
    git reset --hard ${LIBVMOD_DYNAMIC_COMMIT} && \
    ./autogen.sh && \
    ./configure && \
    make install && \
    cd /usr/local/src && \
    rm -rf libvmod-dynamic && \
    ldconfig

#
# install libvmod-digest
#
ENV LIBVMOD_DIGEST_BRANCH=6.3
ENV LIBVMOD_DIGEST_COMMIT=1793bea9e9b7c7dce4d8df82397d22ab9fa296f0

RUN cd /usr/local/src/ && \
    git clone -b ${LIBVMOD_DIGEST_BRANCH} https://github.com/varnish/libvmod-digest.git && \
    cd libvmod-digest && \
    git reset --hard ${LIBVMOD_DIGEST_COMMIT} && \
    ./autogen.sh && \
    ./configure && \
    make install && \
    cd /usr/local/src && \
    rm -rf libvmod-digest && \
    ldconfig

#
# install libvmod-querystring
#
ENV LIBVMOD_QUERYSTRING_VERSION=2.0.1
ENV LIBVMOD_QUERYSTRING_SHA256SUM=34540b0fb515bfbf9aaa4154be5372ce5aa8c7050f35f07dc186c85bb7e976c0

RUN cd /usr/local/src/ && \
    curl -sfLO https://github.com/Dridi/libvmod-querystring/releases/download/v${LIBVMOD_QUERYSTRING_VERSION}/vmod-querystring-${LIBVMOD_QUERYSTRING_VERSION}.tar.gz && \
    echo "${LIBVMOD_QUERYSTRING_SHA256SUM} vmod-querystring-${LIBVMOD_QUERYSTRING_VERSION}.tar.gz" | sha256sum -c - && \
    tar -xzf vmod-querystring-${LIBVMOD_QUERYSTRING_VERSION}.tar.gz && \
    cd vmod-querystring-${LIBVMOD_QUERYSTRING_VERSION} && \
    ./configure && \
    make install && \
    cd /usr/local/src && \
    rm -rf vmod-querystring* && \
    ldconfig

# init
COPY init.sh /init.sh

RUN useradd -r -s /bin/false vcache
RUN mkdir /etc/varnish

ENV VARNISH_CONFIG  /etc/varnish/default.vcl
ENV VARNISH_STORAGE malloc,100m
ENV VARNISH_LISTEN  :80
ENV VARNISH_MANAGEMENT_LISTEN 127.0.0.1:6082

EXPOSE 80
EXPOSE 6082

CMD ["/init.sh"]