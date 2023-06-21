# Build dapper
FROM golang:1.20.5 as go-builder

WORKDIR /build

# Install the dependencies
RUN git clone -b secret https://github.com/seanly/dapper /build
RUN go mod download

RUN set -eux \
    ; VERSION=$(git rev-parse --short HEAD) \
    ; OS="$(uname | tr '[:upper:]' '[:lower:]')" \
    ; ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" \
    ;case "$ARCH" in \
		arm64) \
            CGO_ENABLED=0 GOARCH=${ARCH} go build \
                -a -tags netgo -installsuffix netgo \
                -ldflags "-X main.VERSION=$VERSION" -o /usr/bin/dapper main.go;; \
		amd64) \
            CGO_ENABLED=0 GOARCH=${ARCH} go build \
                -a -tags netgo -installsuffix netgo \
                -ldflags "-X main.VERSION=$VERSION -extldflags '-static -s'" -o /usr/bin/dapper main.go ;;\
		*) echo >&2 "error: unsupported architecture: '$arch'"; exit 1 ;; \
	esac; \
    CGO_ENABLED=0 GOARCH=${ARCH} GOOS=darwin go build -ldflags "-X main.VERSION=$VERSION"  -o ./bin/dapper-Darwin-${ARCH} main.go