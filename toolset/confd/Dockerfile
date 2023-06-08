FROM rockylinux:9-minimal

RUN set -eux \
  ; microdnf install -y curl

ARG CONFD_VERSION=0.16.0

ENV CONFD_DOC_URL=https://github.com/kelseyhightower/confd/blob/master/docs/quick-start-guide.md

RUN \
    ( \
    set -x; cd "$(mktemp -d)" && \
    OS="$(uname | tr '[:upper:]' '[:lower:]')" && \
    ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" && \
    IMAGE_SYNCER_URL=https://github.com/kelseyhightower/confd/releases/download/v${CONFD_VERSION}/confd-${CONFD_VERSION}-${OS}-${ARCH} && \
    curl -sLf ${IMAGE_SYNCER_URL} -o /usr/bin/confd && \
    chmod 750 /usr/bin/confd \
    )
