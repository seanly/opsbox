FROM alpine

#RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories
RUN apk update && apk add --update --no-cache curl 

ARG RESTIC_VERSION=0.15.1

RUN \
    ( \
    set -x; cd "$(mktemp -d)" && \
    OS="$(uname | tr '[:upper:]' '[:lower:]')" && \
    ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" && \
    RESTIC_URL=https://github.com/restic/restic/releases/download/v${RESTIC_VERSION}/restic_${RESTIC_VERSION}_linux_${ARCH}.bz2 && \
    curl -fsSLO ${RESTIC_URL} && \
    bzip2 -d restic_${RESTIC_VERSION}_linux_${ARCH}.bz2 && \
    mv restic_${RESTIC_VERSION}_linux_${ARCH} /usr/bin/restic && \
    chmod 750 /usr/bin/restic \
    )
