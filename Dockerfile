FROM --platform=$BUILDPLATFORM golang:1-alpine@sha256:b8c9b82affbbb82a020bbcf998dad2ba9516944ac7e883524642a481a9505e9c AS build_base

RUN apk add --no-cache git gcc ca-certificates libc-dev
WORKDIR /build
COPY go.mod go.sum ./
RUN go mod download
COPY ./ ./

ENV CGO_ENABLED=0
ARG TARGETOS TARGETARCH
RUN GOOS=$TARGETOS GOARCH=$TARGETARCH go build -ldflags "-w -s" -trimpath -buildvcs=false -o speedtest .

FROM scratch
WORKDIR /app
COPY --from=build_base /build/speedtest ./
# remember sensitive something will be here
COPY settings.toml ./

EXPOSE 8080

CMD ["./speedtest"]
