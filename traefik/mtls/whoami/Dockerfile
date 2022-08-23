ARG DOCKER_ID

# build stage
FROM golang:1.19-alpine3.16 as builder

RUN apk add --no-cache git
WORKDIR /app
COPY go.mod ./
RUN GOSUMDB=off go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 GOPROXY=direct GOSUMDB=off go build -o main .

# final stage
FROM alpine:3.16 as production
WORKDIR /app
COPY --from=builder /app/main .
ENTRYPOINT ["/app/main"]
CMD [""]
