FROM alpine

#RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories
RUN apk update && apk add --update --no-cache curl 

ARG NERDCTL_VERSION=1.2.1

RUN \
    ( \
    set -x; cd "$(mktemp -d)" && \
    OS="$(uname | tr '[:upper:]' '[:lower:]')" && \
    ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" && \
    NERDCTL_URL=https://github.com/containerd/nerdctl/releases/download/v${NERDCTL_VERSION}/nerdctl-${NERDCTL_VERSION}-linux-${ARCH}.tar.gz && \
    mkdir -p /opt/nerdctl && \
    curl -sLf ${NERDCTL_URL} | tar -xzf - -C /opt/nerdctl/ && \
    chmod +x /opt/nerdctl/* \ 
    )
