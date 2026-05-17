# 阶段一：编译
FROM golang:1.23-alpine AS builder

RUN apk add --no-cache git

WORKDIR /src

# 💡 优化：先拷贝依赖文件，利用 Docker 缓存
COPY go.mod go.sum ./
# 去掉了 GOPROXY 设置，直接下载
RUN go mod download

# 拷贝源码并编译
COPY . .
RUN CGO_ENABLED=0 GOOS=linux GOARCH=arm64 go build -ldflags="-s -w" -o /app/vmqcj ./cmd/server

# 阶段二：运行
FROM alpine:latest

RUN apk add --no-cache ca-certificates tzdata
ENV TZ=Asia/Shanghai

WORKDIR /app

# 从编译阶段拷贝二进制文件
COPY --from=builder /app/vmqcj /app/vmqcj

RUN chmod +x /app/vmqcj

# 暴露端口
EXPOSE 8080

CMD ["/app/vmqcj"]