# Spark docker compose说明




1.  `docker-compose.yml` 文件：

```yaml:docker-compose.yml
version: '3'

services:
  spark-master:
    image: bitnami/spark:latest
    environment:
      - SPARK_MODE=master
      - SPARK_RPC_AUTHENTICATION_ENABLED=no
      - SPARK_RPC_ENCRYPTION_ENABLED=no
      - SPARK_LOCAL_STORAGE_ENCRYPTION_ENABLED=no
      - SPARK_SSL_ENABLED=no
    ports:
      - '8080:8080'  # Spark Web UI
      - '7077:7077'  # Spark master port
    volumes:
      - ./data:/opt/spark/data  # 数据目录挂载
      - ./apps:/opt/spark/apps  # 应用目录挂载

  spark-worker-1:
    image: bitnami/spark:latest
    environment:
      - SPARK_MODE=worker
      - SPARK_MASTER_URL=spark://spark-master:7077
      - SPARK_WORKER_MEMORY=1G
      - SPARK_WORKER_CORES=1
      - SPARK_RPC_AUTHENTICATION_ENABLED=no
      - SPARK_RPC_ENCRYPTION_ENABLED=no
      - SPARK_LOCAL_STORAGE_ENCRYPTION_ENABLED=no
      - SPARK_SSL_ENABLED=no
    ports:
      - '8081:8081'  # Worker Web UI
    volumes:
      - ./data:/opt/spark/data
      - ./apps:/opt/spark/apps
    depends_on:
      - spark-master

  jupyter:
    image: jupyter/pyspark-notebook:latest
    ports:
      - '8888:8888'
    volumes:
      - ./notebooks:/home/jovyan/work
      - ./data:/home/jovyan/data
    environment:
      - SPARK_OPTS="--master=spark://spark-master:7077"
    depends_on:
      - spark-master
```

2. 创建必要的目录：

```bash
mkdir data apps notebooks
```

3. 启动服务：

```bash
docker-compose up -d
```

这个配置包含了：

- **Spark Master**: Spark 集群的主节点
- **Spark Worker**: 一个工作节点（可以根据需要添加更多）
- **Jupyter Notebook**: 包含 PySpark 的 Jupyter 环境，方便开发

4. 访问各个服务：
- Spark Web UI: http://localhost:8080
- Jupyter Notebook: http://localhost:8888 (需要从控制台日志获取 token)
  - 进入jupyter容器 docker exec -it $(docker ps | grep jupyter | awk '{print $1}') bash
  - 在容器内执行 jupyter server list

# 在容器内执行
jupyter server list

1. 如果需要扩展 worker 节点，可以使用：

```bash
docker-compose up -d --scale spark-worker-1=3
```

6. 如果需要安装额外的 Python 包，可以创建一个自定义的 Dockerfile：

```dockerfile:Dockerfile
FROM jupyter/pyspark-notebook:latest

# 安装额外的 Python 包
RUN pip install \
    pandas \
    numpy \
    scikit-learn \
    matplotlib
```

然后在 docker-compose.yml 中更新 jupyter 服务：

```yaml:docker-compose.yml
  jupyter:
    build: .
    # ... 其他配置保持不变
```

**注意事项：**

1. **内存配置**
   - 可以通过 `SPARK_WORKER_MEMORY` 调整 worker 节点的内存
   - 根据您的机器配置适当调整

2. **数据持久化**
   - `./data` 目录用于存储数据文件
   - `./apps` 目录用于存储 Spark 应用
   - `./notebooks` 目录用于存储 Jupyter notebooks

3. **安全配置**
   - 示例中禁用了认证和加密，生产环境建议启用
   - 可以通过环境变量配置安全选项

4. **网络配置**
   - 确保端口没有被其他服务占用
   - 可以根据需要修改端口映射

要停止服务：

```bash
docker-compose down
```

这个设置提供了一个完整的 Spark 开发环境，您可以通过 Jupyter Notebook 进行交互式开发，或者通过提交应用到 Spark 集群来运行任务。需要根据具体需求调整配置参数。
