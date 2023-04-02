FROM alpine

#RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories
RUN apk update && apk add --update --no-cache curl 

ARG DAPPER_VERSION=v0.6.0

RUN \
    ( \
    set -x; cd "$(mktemp -d)" && \
    ARCH="$(uname -m)" && \
    DAPPER_URL=https://github.com/rancher/dapper/releases/download/${DAPPER_VERSION}/dapper-Linux-${ARCH} && \
    wget -O /usr/bin/dapper ${DAPPER_URL} && \
    chmod +x /usr/bin/dapper \
    )
