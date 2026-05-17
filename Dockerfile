# 阶段一：编译 (使用 1.23 版本)
FROM golang:1.23-alpine AS builder

RUN apk add --no-cache git

WORKDIR /src
COPY . .

# 设置代理
ENV GOPROXY=https://goproxy.cn,direct
RUN go mod download

# ⚠️ 关键修改：明确指定 ./cmd/server 为构建目标
RUN CGO_ENABLED=0 GOOS=linux GOARCH=arm64 go build -ldflags="-s -w" -o /app/vmqfox ./cmd/server

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