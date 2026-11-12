FROM --platform=$BUILDPLATFORM golang:1-alpine@sha256:eb61c3873c97416fff0116553fff65d67a3549f72e11d9758849a689cdd8b523 AS build_base

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
