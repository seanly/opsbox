FROM rockylinux:9-minimal

RUN set -eux \
    ;microdnf update -y \
    ;microdnf install epel-release -y \ 
    ;microdnf install neovim procps net-tools telnet curl wget tar bzip2 -y

ARG JDK_VERSION=17

RUN \
    ( \
    set -x; cd "$(mktemp -d)" && \
    OS="$(uname | tr '[:upper:]' '[:lower:]')" && \
    ARCH="$(uname -m | sed -e 's/x86_64/x64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/aarch64/')" && \
    ORACLE_JDK_URL=https://download.oracle.com/java/${JDK_VERSION}/latest/jdk-${JDK_VERSION}_${OS}-${ARCH}_bin.tar.gz && \
    curl -sLf ${ORACLE_JDK_URL} -o /tmp/jdk-bin.tar.gz && \
    mkdir -p /usr/local/jdk17; tar -zxvf /tmp/jdk-bin.tar.gz --strip-component=1 -C /usr/local/jdk17 \
    )

ENV JAVA_HOME=/usr/local/jdk17
