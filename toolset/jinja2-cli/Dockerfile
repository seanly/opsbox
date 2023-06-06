FROM alpine:3.17.2

RUN apk update && \
    apk add --update --no-cache python3 py3-pip curl wget jq && \
    pip3 install jinja2-cli[yaml,toml,xml,hjson,json5]==0.8.2
