FROM alpine

#RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories
RUN apk update && apk add --update --no-cache curl 

ARG MKCERT_VERSION=v1.4.4

ENV MKCERT_DOC=https://github.com/FiloSottile/mkcert

RUN \
    ( \
    set -x; cd "$(mktemp -d)" && \
    OS="$(uname | tr '[:upper:]' '[:lower:]')" && \
    ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" && \
    MKCERT_URL=https://github.com/FiloSottile/mkcert/releases/download/v1.4.4/mkcert-${MKCERT_VERSION}-linux-${ARCH} && \
    curl -sLf ${MKCERT_URL} -o /usr/bin/mkcert && \
    chmod +x /usr/bin/mkcert \
    )
