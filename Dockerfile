FROM --platform=$BUILDPLATFORM golang:1-alpine@sha256:91eda9776261207ea25fd06b5b7fed8d397dd2c0a283e77f2ab6e91bfa71079d AS build_base

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
