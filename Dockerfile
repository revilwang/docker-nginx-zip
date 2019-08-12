FROM debian:buster-slim

LABEL maintainer="NGINX Docker Maintainers <docker-maint@nginx.com>"

ENV NGINX_VERSION 1.16.0

RUN addgroup --system --gid 101 nginx && \
    adduser --system --disabled-login --ingroup nginx --no-create-home --home /nonexistent --gecos "nginx user" --shell /bin/false --uid 101 nginx && \
    apt-get update && \
    apt-get install -y --no-install-recommends wget gcc g++ libc-dev make ca-certificates libfindbin-libs-perl unzip && \
    mkdir build && cd build && \
    wget https://ftp.pcre.org/pub/pcre/pcre-8.42.tar.gz && \
    tar -zxf pcre-8.42.tar.gz && \
    cd pcre-8.42 && ./configure && make && cd .. && \
    wget https://www.zlib.net/zlib-1.2.11.tar.gz && tar -zxf zlib-1.2.11.tar.gz && \
    cd zlib-1.2.11 && ./configure && make && cd .. && \
    wget https://www.openssl.org/source/old/1.1.1/openssl-1.1.1b.tar.gz && \
    tar -zxf openssl-1.1.1b.tar.gz && cd openssl-1.1.1b && \
    ./config && make && make install && cd .. && \
    wget https://github.com/evanmiller/mod_zip/archive/master.zip && unzip master.zip && \
    wget http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz && tar -zxf nginx-${NGINX_VERSION}.tar.gz && \
    cd nginx-${NGINX_VERSION} && \
    ./configure --user=nginx --group=nginx --with-pcre=../pcre-8.42 --with-zlib=../zlib-1.2.11 --with-http_ssl_module --with-stream --add-module=../mod_zip-master && \
    make && make install && cd .. && \
    ln -s /usr/local/nginx/sbin/nginx /usr/local/sbin/nginx && \
    cd .. && rm -rf build && \
    apt-get remove --purge --auto-remove -y wget gcc g++ libc-dev make ca-certificates libfindbin-libs-perl unzip && rm -rf /var/lib/apt/lists/*

# forward request and error logs to docker log collector
# RUN ln -sf /dev/stdout /var/log/nginx/access.log \
#     && ln -sf /dev/stderr /var/log/nginx/error.log

EXPOSE 80

STOPSIGNAL SIGTERM

CMD ["nginx", "-g", "daemon off;"]
