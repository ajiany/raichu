-- PostgreSQL 初始化脚本
-- 这个文件会在容器首次启动时自动执行

-- 创建示例用户
CREATE USER root WITH PASSWORD '123456';

-- 为用户赋予数据库权限
GRANT ALL PRIVILEGES ON DATABASE common TO root;

-- 创建示例表
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 为root用户赋予表权限
GRANT ALL PRIVILEGES ON TABLE users TO root;
GRANT USAGE, SELECT ON SEQUENCE users_id_seq TO root;

-- 插入示例数据
INSERT INTO users (username, email) VALUES 
    ('admin', 'admin@example.com'),
    ('demo_user', 'demo@example.com');

-- 创建索引
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_email ON users(email);
