FROM golang:1.19.3-alpine as builder

WORKDIR /app

COPY go.mod .
COPY go.sum .
RUN go mod download

COPY *.go .

RUN go build -o /dummy-app

FROM alpine:latest

COPY --from=builder /dummy-app /dummy-app

EXPOSE 8080/tcp

CMD ["/dummy-app"]