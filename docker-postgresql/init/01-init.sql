-- PostgreSQL 初始化脚本
-- 这个文件会在容器首次启动时自动执行

-- 启用 pgvector 扩展
CREATE EXTENSION IF NOT EXISTS vector;

-- 创建示例用户
CREATE USER root WITH PASSWORD '123456';

-- 为用户赋予数据库权限
GRANT ALL PRIVILEGES ON DATABASE common TO root;
