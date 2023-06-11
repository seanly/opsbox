FROM alpine

#RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories
RUN apk update && apk add --update --no-cache curl 

ARG KB_VERSION=v3.10.0

RUN \
    ( \
    set -x; cd "$(mktemp -d)" && \
    OS="$(uname | tr '[:upper:]' '[:lower:]')" && \
    ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" && \
    KB_URL=https://github.com/kubernetes-sigs/kubebuilder/releases/download/${KB_VERSION}/kubebuilder_${OS}_${ARCH} && \
    curl -sLf ${KB_URL} -o /usr/bin/kubebuilder && \
    chmod +x /usr/bin/kubebuilder \
    )
