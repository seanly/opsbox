FROM alpine

#RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories
RUN apk update && apk add --update --no-cache curl 

COPY ./rootfs /

ARG DOCKER_VERSION=20.10.9

RUN \
    ( \
    ARCH="$(uname -m)" && \
    DOCKER_URL=https://download.docker.com/linux/static/stable/${ARCH}/docker-${DOCKER_VERSION}.tgz && \
    mkdir -p /install/docker/usr/bin && \
    curl -sLf ${DOCKER_URL} | tar -xvzf - --strip-components=1 -C /install/docker/usr/bin/ && \
    mkdir -p /package && \
    tar -zcvf /package/docker.tar.gz -C/install/ . \
    )
