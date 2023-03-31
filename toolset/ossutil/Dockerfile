FROM alpine

#RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories
RUN apk update && apk add --update --no-cache curl 

ARG OSSUTIL_VERSION=1.7.15

RUN \
    ( \
    set -x; cd "$(mktemp -d)" && \
    OS="$(uname | tr '[:upper:]' '[:lower:]')" && \
    ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" && \
    OSSUTIL_URL=https://gosspublic.alicdn.com/ossutil/${OSSUTIL_VERSION}/ossutil-v${OSSUTIL_VERSION}-linux-${ARCH}.zip  && \
    wget ${OSSUTIL_URL} && \
    unzip -d /tmp/ ossutil-v${OSSUTIL_VERSION}-linux-${ARCH}.zip && \
    chmod 750 /tmp/ossutil-v${OSSUTIL_VERSION}-linux-${ARCH}/* && \
    cp -r /tmp/ossutil-v${OSSUTIL_VERSION}-linux-${ARCH}/* /usr/bin/ \
    )
