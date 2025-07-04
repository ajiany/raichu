#!/bin/bash

# 停止所有容器
echo "正在停止所有容器..."
docker compose down

# 清理卷和数据目录
echo "正在清理卷和数据..."
docker volume prune -f
rm -rf ./data

# 重建数据目录
echo "正在创建数据目录..."
mkdir -p data/zookeeper{1,2,3}/{data,log}
mkdir -p data/kafka{1,2,3}

# 设置目录权限
echo "设置目录权限..."
chmod -R 777 ./data

# 启动所有服务
echo "启动Kafka集群..."
docker compose up -d

# 等待服务健康检查
echo "等待服务启动..."
sleep 10

# 检查服务状态
echo "检查服务状态..."
docker compose ps

echo "完成! 如果所有服务显示为'running'，集群已成功启动"