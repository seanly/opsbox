# Build forego
FROM golang:1.20.5 as go-builder

WORKDIR /build

# Install the dependencies
RUN git clone https://github.com/nginx-proxy/forego /build
RUN go mod download

RUN CGO_ENABLED=0 GOOS=linux go build -o /usr/bin/forego . \
   && go clean -cache
