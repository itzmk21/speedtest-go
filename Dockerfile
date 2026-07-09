FROM --platform=$BUILDPLATFORM golang:1-alpine@sha256:0178a641fbb4858c5f1b48e34bdaabe0350a330a1b1149aabd498d0699ff5fb2 AS build_base

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
