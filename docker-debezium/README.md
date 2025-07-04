# 生产级 Kafka 集群与 ClickHouse 集成

本仓库包含一个用于生产环境的 Apache Kafka 集群与 ClickHouse 集成的 Docker Compose 配置。该设置包括多个 broker、ZooKeeper 集群、Kafka Connect 和监控工具。

## 架构

基础设施包括：

- **ZooKeeper 集群**：由3个 ZooKeeper 节点组成的可靠协调集群
- **Kafka 集群**：由3个 Kafka broker 组成的高可用设置
- **Kafka Connect**：用于与 ClickHouse 进行数据集成
- **Kafka UI**：用于监控和管理 Kafka 生态系统的 Web 界面

## 主要特性

### 高可用性
- 3个 ZooKeeper 节点组成集群
- 3个 Kafka broker 与复制因子3
- 最小同步副本数（ISR）设置为2
- 所有组件使用持久化存储卷
- 服务故障自动重启机制
- 序列化的节点启动顺序

### 数据持久性
- 所有系统主题的复制因子为3
- 事务状态日志复制因子为3
- 数据保留配置为7天（168小时）
- 为生产工作负载优化的分段大小

### 性能优化
- 最大消息大小设置为10MB
- 优化的副本获取和套接字请求大小
- 调整日志分段大小和保留检查间隔

### 稳定性增强
- ZooKeeper集群参数优化（INIT_LIMIT和SYNC_LIMIT）
- Kafka节点错开启动时间，确保有序初始化
- 配置合理的会话和连接超时设置
- 启用自动领导者再平衡和受控关闭
- 每个节点配置了资源限制，防止资源竞争
- Kafka Connect生产者重试机制

### 安全考虑
本设置专注于高可用性。对于完整的生产部署，建议添加：

- 用于客户端和 broker 间通信的 SASL/SCRAM 认证
- 用于传输中数据的 TLS/SSL 加密
- 用于授权的访问控制列表（ACLs）
- 网络隔离

## 使用说明

### 前提条件
- 安装 Docker 和 Docker Compose
- 至少 8GB 可用内存
- 最少 50GB 磁盘空间

### 安全启动和重启集群
使用以下脚本可确保干净启动集群：

```bash
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
sleep 30

# 检查服务状态
echo "检查服务状态..."
docker compose ps
```

保存这个脚本为`restart-kafka-cluster.sh`，并使其可执行：
```bash
chmod +x restart-kafka-cluster.sh
```

### 验证设置
```bash
# 检查所有容器是否运行
docker compose ps

# 验证 ZooKeeper 集群
docker exec -it zookeeper1 bash -c "echo stat | nc localhost 2181"

# 验证 Kafka 集群
docker exec -it kafka1 kafka-topics --bootstrap-server kafka1:9092,kafka2:9093,kafka3:9094 --list
```

### 访问 Kafka UI
在浏览器中访问 http://localhost:8080 来访问 Kafka UI 仪表板。

### 创建主题
```bash
# 创建一个复制因子为3的新主题
docker exec -it kafka1 kafka-topics --bootstrap-server kafka1:9092,kafka2:9093,kafka3:9094 \
  --create --topic my-topic --partitions 6 --replication-factor 3
```

### 配置 ClickHouse 连接器
要配置 ClickHouse sink 连接器：

1. 访问 Kafka Connect REST API，地址为 http://localhost:8083
2. 通过 POST 请求提交连接器配置到 `/connectors`
3. 或使用 Kafka UI 配置连接器

## 扩展考虑

此设置为生产环境提供了坚实的基础。如需进一步扩展：

- 增加 Kafka broker 的数量
- 调整高吞吐量主题的分区数
- 考虑将 Kafka Connect 分离到专用集群
- 监控资源使用情况并根据需要添加容量

## 监控

Kafka UI 提供基本的监控功能。对于生产环境中的高级监控，考虑添加：

- 用于 Kafka 指标的 JMX 导出器
- 日志聚合系统（例如 ELK 堆栈）
- 健康检查和告警系统

## 故障排除

如果遇到启动问题，尝试以下步骤：

1. 使用`restart-kafka-cluster.sh`脚本重启整个集群
2. 检查各组件日志: `docker logs <container_name>`
3. 确保宿主机有足够资源（CPU/内存/磁盘空间）
4. 验证网络端口没有冲突
