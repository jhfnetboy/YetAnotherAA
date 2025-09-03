# YetAnotherAA 启动指南

## 🚀 快速启动

### 自动启动（推荐）

```bash
# 一键启动所有服务
./scripts/start-all.sh

# 如果需要清理前端缓存
./scripts/start-all.sh --clean
```

### 分步启动

如果你想一步步启动并确认每个服务：

```bash
# 使用交互式启动脚本
./scripts/start-step-by-step.sh
```

### 手动启动

如果你想在单独的终端窗口中启动每个服务：

#### 1. Signer Node 1 (终端1)
```bash
cd signer
NODE_STATE_FILE=./node_dev_001.json PORT=3001 GOSSIP_PORT=8001 GOSSIP_BOOTSTRAP_PEERS="" npm run start:dev
```

#### 2. Signer Node 2 (终端2)
```bash
cd signer
NODE_STATE_FILE=./node_dev_002.json PORT=3002 GOSSIP_PORT=8002 GOSSIP_BOOTSTRAP_PEERS="ws://localhost:8001" npm run start:dev
```

#### 3. Signer Node 3 (终端3)
```bash
cd signer
NODE_STATE_FILE=./node_dev_003.json PORT=3003 GOSSIP_PORT=8003 GOSSIP_BOOTSTRAP_PEERS="ws://localhost:8001" npm run start:dev
```

#### 4. Backend API (终端4)
```bash
cd aastar
PORT=3000 NODE_ENV=development JWT_SECRET=your-development-jwt-secret-key BLS_SIGNER_URL=http://localhost:3001 npm run start:dev
```

#### 5. Frontend (终端5)
```bash
cd aastar-frontend
PORT=8080 npm run dev
```

## 🛠️ 管理命令

```bash
# 检查所有服务状态
./scripts/status.sh

# 停止所有服务
./scripts/stop-all.sh

# 查看日志（如果使用自动启动）
tail -f logs/*.log
```

## 📍 访问地址

启动成功后可以访问：

- **应用主界面**: http://localhost:8080
- **Backend API**: http://localhost:3000/api/v1
- **API文档**: http://localhost:3000/api-docs
- **Signer Node 1**: http://localhost:3001/api
- **Signer Node 2**: http://localhost:3002/api
- **Signer Node 3**: http://localhost:3003/api

## 🔧 故障排除

### 端口冲突

如果遇到端口被占用错误：

```bash
# 检查端口占用
lsof -i :3000  # 或其他端口

# 停止占用进程
kill -9 <PID>

# 或使用停止脚本
./scripts/stop-all.sh
```

### 前端构建错误

```bash
# 清理并重新安装前端依赖
cd aastar-frontend
rm -rf node_modules .next
npm install
```

### Signer节点连接问题

确保启动顺序：
1. 先启动 Node 1（bootstrap节点）
2. 再启动 Node 2 和 Node 3
3. 检查 gossip 连接消息

## ⚠️ 重要说明

- 端口 3000-3003, 8001-8003, 8080 必须可用
- 必须按正确顺序启动服务（Signer节点 → Backend → Frontend）
- 首次启动可能需要几秒钟时间来建立 gossip 连接