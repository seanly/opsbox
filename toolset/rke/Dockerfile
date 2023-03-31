FROM alpine

#RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories
RUN apk update && apk add --update --no-cache curl 

ARG RKE_VERSION=v1.3.8

RUN \
    ( \
    set -x; cd "$(mktemp -d)" && \
    OS="$(uname | tr '[:upper:]' '[:lower:]')" && \
    ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" && \
    RKE_URL=https://github.com/rancher/rke/releases/download/${RKE_VERSION}/rke_linux-${ARCH} && \
    wget -O /usr/bin/rke ${RKE_URL} && \
    chmod +x /usr/bin/rke \
    )
