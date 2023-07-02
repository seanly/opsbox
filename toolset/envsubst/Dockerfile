# https://github.com/drone/envsubst
FROM golang:1.20.5 as go-builder

WORKDIR /build

# Install the dependencies
RUN git clone https://github.com/drone/envsubst /build
RUN go mod download

RUN CGO_ENABLED=0 GOOS=linux go build -o /usr/bin/envsubst cmd/envsubst/main.go \
   && go clean -cache
