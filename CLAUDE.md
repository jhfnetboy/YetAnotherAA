# CLAUDE.md

此文件为 Claude Code (claude.ai/code) 在该仓库中工作提供指导。

## 语言偏好

- **对话语言**: 请使用中文与用户交流
- **代码和注释**: 使用英文编写

## 项目概览

YetAnotherAA 是一个生产就绪的实现，结合了 WebAuthn/Passkey 生物识别认证、BLS 聚合签名、ERC-4337 账户抽象和 KMS 密钥管理。这是一个包含 3 个主要工作区组件的 monorepo，共同提供具有增强安全性的无密码区块链认证和企业级密钥管理。

### 核心创新

1. **KMS 集成** - 生产环境使用密钥管理服务安全存储私钥
2. **统一 Creator/Signer** - 用户钱包同时作为创建者和签名者，完全自主控制
3. **无 Gas 部署** - 通过 Paymaster 赞助账户部署，用户无需持有 ETH
4. **多版本支持** - 兼容 EntryPoint v0.6、v0.7、v0.8

## 开发命令

### 根目录命令

- `npm run format` - 使用 Prettier 格式化所有代码
- `npm run format:check` - 检查代码格式
- `npm run lint` - 在所有工作区运行 linting
- `npm run lint:fix` - 修复所有工作区的 linting 问题
- `npm run build` - 构建所有工作区
- `npm run test` - 在所有工作区运行测试
- `npm run test:ci` - 在所有工作区运行 CI 测试
- `npm run ci` - 完整 CI 流水线（格式检查、lint、构建、测试）

### 工作区特定命令

每个工作区可以使用 `-w <workspace>` 定位：

**AAStar 后端 (aastar/):**

- `npm run start:dev -w aastar` - 启动开发服务器（端口 3000）
- `npm run build -w aastar` - 构建 NestJS 应用
- `npm run test -w aastar` - 运行 Jest 测试
- `npm run type-check -w aastar` - TypeScript 类型检查

**BLS 签名服务 (signer/):**

- `npm run start:dev -w signer` - 启动 BLS 签名服务（端口 3001）
- `npm run build -w signer` - 构建签名服务
- `npm run generate-eoa -w signer` - 为开发生成 EOA 密钥

**前端 (aastar-frontend/):**

- `npm run dev -w aastar-frontend` - 启动 Next.js 开发服务器（端口 8080）
- `npm run build -w aastar-frontend` - 构建 Next.js 应用
- `npm run type-check -w aastar-frontend` - TypeScript 类型检查

### 智能合约开发 (validator/)

使用 Foundry 工具链：

- `cd validator && forge build` - 编译 Solidity 合约
- `cd validator && forge test` - 运行合约测试
- `cd validator && forge script script/DeployValidator.s.sol --rpc-url $RPC_URL --broadcast` - 部署合约

## 架构概览

### 核心组件

1. **validator/** - 实现 BLS 签名验证和 ERC-4337 账户抽象的 Solidity 智能合约
2. **aastar/** - 提供 WebAuthn 认证、账户管理和转账服务的 NestJS 后端 API
3. **signer/** - 带有 gossip 网络多节点协调的 NestJS BLS 签名服务
4. **aastar-frontend/** - 具有生物识别认证和交易界面的 Next.js 前端

### 关键架构模式

**认证流程：**

- WebAuthn/Passkey 注册和登录（设置后无需密码）
- 所有交易的强制生物识别验证
- JWT 令牌结合 passkey 验证用于敏感操作

**密钥管理（重要更新）：**

- **运行时无需私钥** - 用户钱包自动生成（KMS 或本地）
- **KMS 集成** - 生产环境私钥托管在安全的密钥管理服务
- **统一所有权** - 用户钱包 = creator = signer（移除了独立的 deployer）
- **私钥仅用于合约部署** - validator/ 目录下的一次性部署操作

**签名聚合：**

- 来自多个节点的 BLS12-381 签名
- 用于节点发现和协调的 gossip 网络
- 基于节点数量的动态 gas 计算（EIP-2537）

**账户抽象：**

- ERC-4337 兼容的 UserOperations（v0.6/v0.7/v0.8）
- 用于 BLS 签名验证的自定义验证器合约
- 双重签名机制：AA 签名验证 userOpHash，BLS 签名验证 messagePoint
- **Paymaster 赞助部署** - 账户创建无需 ETH

### 数据库架构

- 支持 JSON 文件存储（开发）和 PostgreSQL（生产）
- 通过 DATABASE_TYPE 环境变量配置
- 实体：User、Account、Transfer、Passkey、UserToken、BlsConfig

### 安全模型

- **登录**：需要生物识别验证（Face ID、Touch ID、Windows Hello）
- **交易**：执行前强制 passkey 验证
- **多设备**：用户可以在多个设备上注册 passkey
- **无密码回退**：所有敏感操作都需要生物识别认证
- **密钥管理**：
  - 生产环境：KMS 托管私钥，零暴露风险
  - 开发环境：本地生成，加密存储
  - 统一所有权：用户完全控制账户（creator = signer）

## 开发设置

1. **安装依赖**: `npm install`（安装所有工作区）
2. **环境设置**:
   - **推荐方式**: 使用 VS Code 调试面板（`.vscode/launch.json` 已配置）
   - **替代方式**: 复制 `.env.example` 到 `.env` 并配置
   - **重要**: 运行时**不需要配置私钥** - 用户钱包自动生成
3. **按顺序启动服务**:
   - 签名服务: `npm run start:dev -w signer`（端口 3001-3003）
   - 后端: `npm run start:dev -w aastar`（端口 3000）
   - 前端: `npm run dev -w aastar-frontend`（端口 8080）
4. **部署合约**（仅一次性设置）:
   - 使用 validator/ 目录下的 Foundry 脚本
   - 这是**唯一**需要私钥的步骤

## 测试策略

- **单元测试**: 后端服务和组件的 Jest
- **集成测试**: WebAuthn 流程和 BLS 签名聚合
- **合约测试**: 智能合约验证的 Foundry
- **E2E 测试**: 生物识别认证流程的浏览器自动化

## 关键技术

- **前端**: Next.js 15、TypeScript、TailwindCSS、WebAuthn API
- **后端**: NestJS、TypeScript、WebAuthn (@simplewebauthn)、Ethers.js
- **密码学**: BLS12-381 (@noble/curves)、ECC secp256k1
- **区块链**: Ethereum、ERC-4337、Foundry/Solidity
- **数据库**: PostgreSQL/JSON 文件存储，使用 TypeORM 抽象

## 常见开发模式

**WebAuthn 实现：**

- 始终使用 `userVerification: "required"` 进行强制生物识别验证
- 为认证流程实现适当的超时和错误处理
- 使用可发现凭据（`residentKey: "required"`）

**BLS 签名：**

- 聚合前验证所有公钥
- 使用恒定时间操作以确保安全
- 使用 nonces 实现重放保护

**智能合约安全：**

- 遵循 checks-effects-interactions 模式
- 实现适当的访问控制和重入防护
- 所有关键操作都需要所有者权限

## 部署注意事项

- **合约部署**（一次性）:
  - 部署您自己的合约，切勿使用参考地址
  - 这是**唯一**需要私钥的步骤
  - 使用 validator/ 目录下的 Foundry 脚本

- **生产环境配置**:
  - 启用 `KMS_ENABLED=true` 使用密钥管理服务
  - 使用 `DB_TYPE=postgres` 连接生产数据库
  - 配置 Paymaster 以支持无 Gas 部署
  - 部署多个 BLS 签名节点（建议 3+ 节点）

- **环境要求**:
  - Node.js >=20.19.0、npm >=10.0.0
  - **需要 HTTPS**: WebAuthn 仅在 HTTPS（或 localhost）上工作
  - **跨浏览器**: 在 Chrome、Safari、Firefox、Edge 上测试 WebAuthn 兼容性

- **安全最佳实践**:
  - 生产环境必须使用 KMS 管理用户钱包
  - BLS 节点状态文件包含私钥，需要安全备份
  - 合约部署者私钥仅用于部署，部署后应安全存储

## VS Code Launch Configuration（多版本 EntryPoint 支持）

### 环境变量配置格式

```json
// v0.6 配置（向后兼容，无版本后缀）
"ENTRY_POINT_ADDRESS": "0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789",
"AASTAR_ACCOUNT_FACTORY_ADDRESS": "0xab18406D34B918A0431116755C45AC7af99DcDa6",
"VALIDATOR_CONTRACT_ADDRESS": "0xD9756c11686B59F7DDf39E6360230316710485af",

// v0.7 配置
"ENTRY_POINT_V7_ADDRESS": "0x0000000071727De22E5E9d8BAf0edAc6f37da032",
"AASTAR_ACCOUNT_FACTORY_V7_ADDRESS": "0xAae813Ae38418f38701142cEab08D4F52383bF34",
"VALIDATOR_CONTRACT_V7_ADDRESS": "0xD9756c11686B59F7DDf39E6360230316710485af",

// v0.8 配置
"ENTRY_POINT_V8_ADDRESS": "0x0576a174D229E3cFA37253523E645A78A0C91B57",
"AASTAR_ACCOUNT_FACTORY_V8_ADDRESS": "0x5675f3e1C97bE92F22315a5af58c9A8f1007F242",
"VALIDATOR_CONTRACT_V8_ADDRESS": "0xD9756c11686B59F7DDf39E6360230316710485af",

// 默认版本设置
"DEFAULT_ENTRYPOINT_VERSION": "0.7"
```

### 启动配置选项

在 VS Code 中使用"运行和调试"面板（Ctrl/Cmd + Shift + D）：

- **Start All:JSON** - 使用 JSON 文件存储（开发环境）
- **Start All:LocalDB** - 使用本地 PostgreSQL
- **Start All:RemoteDB** - 使用远程数据库

### 版本选择

- **默认版本**：通过 `DEFAULT_ENTRYPOINT_VERSION` 控制（推荐 "0.7"）
- **用户选择**：前端创建账户时可以覆盖默认版本

## Pimlico Bundler 集成（EntryPoint v0.7 & v0.8）

### UserOperation 结构差异

**v0.6 标准格式：**

```javascript
{
  (sender,
    nonce,
    initCode,
    callData,
    callGasLimit,
    verificationGasLimit,
    preVerificationGas,
    maxFeePerGas,
    maxPriorityFeePerGas,
    paymasterAndData,
    signature);
}
```

**v0.7/v0.8 Unpacked 格式（发送给 Bundler）：**

```javascript
{
  (sender,
    nonce,
    factory, // 从 initCode 分离
    factoryData, // 从 initCode 分离
    callData,
    callGasLimit,
    verificationGasLimit,
    preVerificationGas,
    maxFeePerGas,
    maxPriorityFeePerGas,
    paymaster, // 从 paymasterAndData 分离
    paymasterVerificationGasLimit, // 从 paymasterAndData 分离
    paymasterPostOpGasLimit, // 从 paymasterAndData 分离（可选）
    paymasterData, // 从 paymasterAndData 分离
    signature);
}
```

### 关键实现差异

1. **Factory 方法名**：
   - v0.6: `createAccountWithAAStarValidator`
   - v0.7/v0.8: `createAccount`

2. **InitCode 处理（v0.7/v0.8）**：

   ```javascript
   const factory = initCode.slice(0, 42); // 前20字节
   const factoryData = "0x" + initCode.slice(42); // 剩余部分
   ```

3. **PaymasterAndData 处理（v0.7/v0.8）**：
   ```javascript
   const paymaster = paymasterAndData.slice(0, 42);
   const paymasterVerificationGasLimit = "0x" + paymasterAndData.slice(42, 106);
   const paymasterPostOpGasLimit = "0x" + paymasterAndData.slice(106, 170);
   const paymasterData = "0x" + paymasterAndData.slice(170);
   ```

### Factory ABI 定义

```javascript
// v0.7/v0.8
export const FACTORY_ABI_V7_V8 = [
  "function getAddress(address creator, address signer, address validator, bool useAAStarValidator, uint256 salt) view returns (address)",
  "function createAccount(address creator, address signer, address aaStarValidator, bool useAAStarValidator, uint256 salt) returns (address)",
];

// v0.6
export const FACTORY_ABI_V6 = [
  "function getAddress(address creator, address signer, address validator, bool useAAStarValidator, uint256 salt) view returns (address)",
  "function createAccountWithAAStarValidator(address creator, address signer, address aaStarValidator, bool useAAStarValidator, uint256 salt) returns (address)",
];
```

### Pimlico Bundler RPC 端点

- **Sepolia**: `https://api.pimlico.io/v2/11155111/rpc?apikey=YOUR_API_KEY`
- 支持的 EntryPoint 版本：
  - v0.6: `0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789`
  - v0.7: `0x0000000071727De22E5E9d8BAf0edAc6f37da032`
  - v0.8: `0x0576a174D229E3cFA37253523E645A78A0C91B57`

### 常见错误处理

**AA13 initCode failed or OOG**：

- 确保 v0.7/v0.8 使用 `createAccount` 方法
- 正确拆分 initCode 为 factory 和 factoryData
- 增加 verificationGasLimit

**AA33 reverted**：

- 检查账户是否成功部署
- 验证签名格式是否正确
- 确认 validator 合约地址正确

### 重要提醒

- Pimlico
  bundler 负责将 UnpackedUserOperation 打包成 PackedUserOperation 后发送给 EntryPoint 合约
- 始终根据 EntryPoint 版本选择正确的 UserOperation 格式
- v0.7/v0.8 的 gas 估算可能与 v0.6 不同，需要相应调整

## KMS 集成说明

### 配置

```bash
# 启用 KMS（生产环境推荐）
KMS_ENABLED=true
KMS_ENDPOINT=https://kms.aastar.io
```

### 工作原理

1. **用户注册时**:
   - KMS 模式：调用 KMS API 创建新密钥，返回地址和 keyId
   - 本地模式：使用 ethers.js 生成钱包，加密存储私钥

2. **交易签名时**:
   - KMS 模式：发送哈希到 KMS 服务进行签名
   - 本地模式：使用解密后的私钥本地签名

3. **优势**:
   - 私钥永不离开 KMS 安全环境
   - 符合企业安全合规要求
   - 支持密钥轮换和审计

### 统一 Creator/Signer 架构

传统方式需要单独的 deployer 钱包来创建账户，现在：

- **用户钱包 = Creator = Signer**
- 账户通过 Paymaster 赞助部署，无需 deployer 持有 ETH
- 用户从创建开始就完全控制账户
- 简化了信任模型，无需依赖第三方 deployer

```typescript
// Factory.getAddress() 和 createAccount() 调用示例
const accountAddress = await factory.getAddress(
  userWallet.address, // creator = signer
  userWallet.address, // signer
  validatorAddress,
  true,
  salt
);
```
