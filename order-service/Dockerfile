# Build stage
FROM golang:1.22.0-alpine AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY *.go ./
COPY config.yaml ./
RUN CGO_ENABLED=0 GOOS=linux go build -o order-service .

# Runtime stage
FROM alpine:latest
WORKDIR /app
COPY --from=builder /app/order-service .
COPY config.yaml ./

EXPOSE 8081
CMD ["./order-service"]
