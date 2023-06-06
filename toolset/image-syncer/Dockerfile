FROM rockylinux:9-minimal

RUN set -eux \
  ; microdnf install -y curl tar gzip

ARG IMAGE_SYNCER_VERSION=v1.3.1

RUN \
    ( \
    set -x; cd "$(mktemp -d)" && \
    OS="$(uname | tr '[:upper:]' '[:lower:]')" && \
    ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" && \
    IMAGE_SYNCER_URL=https://github.com/AliyunContainerService/image-syncer/releases/download/${IMAGE_SYNCER_VERSION}/image-syncer-${IMAGE_SYNCER_VERSION}-${OS}-${ARCH}.tar.gz && \
    curl -sLf ${IMAGE_SYNCER_URL} -o /tmp/image-syncer.tar.gz && \
    tar -zxvf /tmp/image-syncer.tar.gz -C /usr/bin/ image-syncer \
    )






