FROM golang:1.20.5-bullseye AS build

ARG TAG=0.0.1

# Remove support for SQLite.
ENV CGO_ENABLED=0
RUN git clone -b next https://github.com/seanly/mindoc /code
WORKDIR /code

RUN go env && \
    go mod tidy -v && \
    go build -v -o mindoc_linux_amd64 -ldflags "-w -s -X 'main.VERSION=$TAG' -X 'main.BUILD_TIME=`date`' -X 'main.GO_VERSION=`go version`'" && \
    mkdir -p dist/__default_assets__; \
    cp -r mindoc_linux_amd64 dist/;\
    cp -r start.sh dist/;\
    cp -r LICENSE.md dist/;\
    cp -r lib dist/;\
    cp -r simsun.ttc dist/;\
    cp -r conf dist/__default_assets__/;\
    cp -r static dist/__default_assets__/;\
    cp -r views dist/__default_assets__/;\
    cp -r uploads dist/__default_assets__/

RUN ./mindoc_linux_amd64 version

FROM ubuntu:focal

ARG DEBIAN_FRONTEND=noninteractive

SHELL ["/bin/bash", "-c"]
RUN apt-get update && \
    apt install -y apt-transport-https ca-certificates curl wget xz-utils

ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt install -y --no-install-recommends tzdata && \
    dpkg-reconfigure --frontend noninteractive tzdata

RUN apt install -y libgl-dev libnss3-dev libxcomposite-dev libxrandr-dev libxi-dev libxdamage-dev \
     fonts-wqy-microhei fonts-wqy-zenhei \
     locales language-pack-zh-hans language-pack-zh-hans-base

RUN locale-gen "zh_CN.UTF-8"
RUN update-locale LANG=zh_CN.UTF-8
ENV LANG=zh_CN.UTF-8
ENV LANGUAGE=zh_CN:en
ENV LC_ALL=zh_CN.UTF-8

ENV CALIBRE_URL=https://download.calibre-ebook.com/5.44.0/calibre-5.44.0-x86_64.txz
RUN mkdir -p /opt/calibre && curl -sLf ${CALIBRE_URL} | tar -xJof - -C /opt/calibre 

ENV PATH=$PATH:/opt/calibre
ENV QTWEBENGINE_CHROMIUM_FLAGS="--no-sandbox"
ENV QT_QPA_PLATFORM='offscreen'
RUN ebook-convert --version

EXPOSE 8181/tcp

WORKDIR /mindoc

COPY --from=build /code/dist/ /mindoc/

ENV ZONEINFO=/mindoc/lib/time/zoneinfo.zip
RUN chmod +x /mindoc/start.sh;\
    mkdir -p /usr/share/fonts/win/; \
    cp -r simsun.ttc /usr/share/fonts/win/simsun.ttc; \
    chmod a+r /usr/share/fonts/win/simsun.ttc

ENTRYPOINT ["/bin/bash", "/mindoc/start.sh"]
