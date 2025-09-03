# YetAnotherAA 项目状态报告

## Quick start
  1. ./scripts/start-all.sh - 一键启动所有服务（后台运行）
  2. ./scripts/stop-all.sh - 停止所有服务
  3. ./scripts/status.sh - 检查服务状态
  4. ./scripts/start-step-by-step.sh - 分步启动指导
  5. STARTUP.md - 完整启动文档

## 项目概览

YetAnotherAA 是一个先进的 **ERC-4337 账户抽象系统**，集成了 **BLS12-381 聚合签名**。这是一个 monorepo 架构，包含四个主要组件：

### 架构组成

1. **Validator (Solidity智能合约)** - 部署在 Sepolia 测试网：
   - `AAStarValidator.sol`: BLS签名验证器，支持动态gas计算
   - `AAStarAccountV6.sol`: ERC-4337账户实现，双重验证机制
   - `AAStarAccountFactoryV6.sol`: 智能账户工厂合约

2. **Signer Service (NestJS + ES modules)** - BLS签名节点服务：
   - 独立节点身份，具有唯一的BLS密钥对
   - RESTful API，端口3001
   - Gossip网络用于节点发现
   - WebSocket支持实时通信

3. **Backend API (NestJS + CommonJS)** - 主应用服务器：
   - 用户认证（JWT和WebAuthn/passkeys）
   - ERC-4337账户管理
   - 转账操作和UserOperation处理
   - JSON文件存储（可迁移到数据库）
   - 端口3000

4. **Frontend (Next.js 15)** - 现代Web界面：
   - React 19 + TypeScript
   - Tailwind CSS样式
   - WebAuthn/passkey集成
   - 端口8080

## 技术特性

### BLS签名系统
- 705字节签名格式：`[nodeIdsLength][nodeIds][blsSignature(256)][messagePoint(256)][aaSignature(65)]`
- 双重验证：ECDSA验证userOpHash + BLS验证messagePoint
- 动态gas计算，含25%安全边际
- 从gossip网络自动选择节点

### ERC-4337集成
- 兼容EntryPoint v0.6：`0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789`
- 精确的gas估算算法优化
- 支持paymaster集成
- 已在Sepolia测试网成功验证

### 开发工作流
项目使用npm workspaces管理monorepo，包含完整的脚本：
- 根级命令用于格式化、检查、构建和测试所有工作区
- 各工作区独立的开发命令
- GitHub Actions CI/CD集成

## 启动指南

### 环境要求
- Node.js 18+
- npm 9+
- 确保端口 3000, 3001, 8080 可用

### 端口分配
- **Frontend**: 8080
- **Backend API**: 3000
- **Signer Service**: 3001

### 启动命令

#### 方法1：分别启动每个服务（推荐）

打开3个终端窗口，按以下顺序启动：

```bash
# 终端1 - BLS签名服务 (端口3001)
cd signer
PORT=3001 npm run start:dev

# 终端2 - 后端API (端口3000) 
cd aastar
npm run start:dev

# 终端3 - 前端应用 (端口8080)
cd aastar-frontend
npm run dev
```

#### 方法2：使用环境变量配置

在各服务目录创建 `.env` 文件：

**signer/.env:**
```env
PORT=3001
```

**aastar/.env:**
```env
PORT=3000
```

然后正常启动：
```bash
# 在各自目录下
npm run start:dev
```

### 访问地址

服务启动后，可以访问：

- **前端应用**: http://localhost:8080
- **后端API**: http://localhost:3000/api/v1
- **后端Swagger文档**: http://localhost:3000/api-docs
- **签名服务API**: http://localhost:3001
- **签名服务Swagger文档**: http://localhost:3001/api

## 故障排除

### 端口3000冲突问题

**问题描述**：启动时报错端口3000已被占用

**原因**：signer服务和aastar后端API默认都使用端口3000

**解决方案**：

1. **检查端口占用**：
```bash
# macOS/Linux
lsof -i :3000

# Windows
netstat -ano | findstr :3000
```

2. **杀死占用进程**（如需要）：
```bash
# macOS/Linux
kill -9 <PID>

# Windows
taskkill /PID <PID> /F
```

3. **使用正确的端口启动**：
```bash
# Signer服务必须使用3001端口
cd signer && PORT=3001 npm run start:dev

# Backend API使用3000端口
cd aastar && npm run start:dev
```

### 常见错误及解决

1. **EADDRINUSE错误**
   - 确保使用正确的PORT环境变量
   - 检查并关闭占用端口的进程

2. **CORS错误**
   - 确保后端API在前端之前启动
   - 检查API_BASE_URL配置

3. **连接拒绝错误**
   - 确保所有服务都已启动
   - 检查防火墙设置

## 项目状态

### 已完成功能
- ✅ 生产就绪的智能合约已部署到Sepolia
- ✅ 完整的BLS签名聚合功能
- ✅ 全栈应用所有组件集成
- ✅ 链上成功验证转账
- ✅ WebAuthn/passkey认证实现

### 开发环境配置文件

根目录 `.env` 文件包含了必要的配置：
- Sepolia RPC URL
- 合约地址
- BLS服务配置

### 数据存储

当前使用JSON文件存储（位于各服务的 `/data` 目录）：
- `users.json` - 用户账户（bcrypt加密密码）
- `accounts.json` - ERC-4337账户映射
- `transfers.json` - 交易历史
- `bls-config.json` - BLS节点配置

准备好随时迁移到MongoDB/PostgreSQL。

## 完整用户流程

1. 启动所有服务：Signer (3001) → Backend (3000) → Frontend (8080)
2. 访问 http://localhost:8080
3. 注册新账户或登录
4. 创建ERC-4337智能账户
5. 为账户充值并执行转账
6. 查看转账历史和状态

## 技术亮点

- 多节点BLS签名聚合
- ERC-4337账户抽象
- 无gas交易支持
- 实时gossip网络
- 完整的用户界面
- 无CORS问题（API代理）

## 项目文件结构

```
.
├── .claude/                 # Claude配置目录
├── .env                     # 环境变量
├── .git/                    # Git仓库
├── .github/                 # GitHub Actions工作流
├── .gitignore              # Git忽略规则
├── .prettierrc             # Prettier格式化配置
├── .vscode/                # VS Code设置
├── CLAUDE.md               # Claude助手指令
├── README.md               # 项目文档
├── aastar/                 # 后端API (NestJS)
├── aastar-frontend/        # 前端应用 (Next.js)
├── deploy/                 # 部署配置
├── node_modules/           # 依赖
├── package.json            # 根package.json (workspaces)
├── package-lock.json       # 锁文件
├── scripts/                # 实用脚本
├── signer/                 # BLS签名服务
├── validator/              # Solidity智能合约
└── worker/                 # Worker目录
```

## 开发命令参考

### 根级别（所有工作区）
```bash
npm run format          # 格式化所有代码
npm run format:check    # 检查格式
npm run lint           # 检查所有工作区
npm run lint:fix       # 修复lint问题
npm run build          # 构建所有工作区
npm run test           # 运行所有测试
npm run ci             # CI管道（格式检查+lint+构建+测试）
```

### 各服务独立命令
```bash
# Validator (Solidity)
cd validator
forge build            # 构建合约
forge test            # 运行测试

# Signer服务
cd signer
npm run start:dev     # 开发模式
npm run build         # 构建TypeScript
npm run test          # 运行测试

# 后端API
cd aastar
npm run start:dev     # 开发模式（热重载）
npm run test:ci       # 运行测试（含覆盖率）

# 前端
cd aastar-frontend
npm run dev           # 开发服务器（turbo）
npm run build         # 生产构建
npm run start         # 启动生产服务器
```

---

**项目状态**: ✅ 生产就绪 | **最后更新**: 2025年8月 | **网络**: Sepolia测试网