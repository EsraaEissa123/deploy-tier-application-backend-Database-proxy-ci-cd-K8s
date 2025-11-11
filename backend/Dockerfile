FROM golang:1.21-alpine AS builder

RUN apk add --no-cache git

WORKDIR /app

COPY backend/go.mod backend/go.sum ./
RUN go mod download

COPY backend/ .

RUN CGO_ENABLED=0 go build -o /blog-api .

FROM alpine:latest

RUN apk --no-cache add ca-certificates

RUN mkdir -p /var/run/secrets/kubernetes.io/serviceaccount

COPY --from=builder /blog-api /usr/local/bin/

RUN chmod +x /usr/local/bin/blog-api

ENTRYPOINT ["/usr/local/bin/blog-api"]

EXPOSE 8000