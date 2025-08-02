# BLS聚合签名项目

这是一个使用TypeScript实现的BLS（Boneh-Lynn-Shacham）聚合签名项目，支持EIP-2537兼容的签名格式。

## 功能特性

- 生成BLS密钥对
- 创建聚合签名
- 支持EIP-2537格式的序列化
- 与以太坊智能合约兼容

## 安装依赖

```bash
npm install
```

## 使用方法

### 开发模式运行
```bash
npm run dev
```

### 运行示例
```bash
npm run example
```

### 运行测试
```bash
npm test
```

### 运行测试（监视模式）
```bash
npm run test:watch
```

### 运行测试（覆盖率报告）
```bash
npm run test:coverage
```

### 构建并运行
```bash
npm run build
npm start
```

## 项目结构

```
bls-node/
├── src/
│   ├── signature.ts    # 主要的BLS签名实现
│   ├── signature.spec.ts # signature.ts的单元测试
│   ├── types.ts        # TypeScript类型定义
│   ├── utils.ts        # 工具函数
│   ├── utils.spec.ts   # utils.ts的单元测试
│   ├── integration.spec.ts # 集成测试
│   └── setup.ts        # 测试设置
├── examples/
│   └── example.ts      # 使用示例
├── package.json        # 项目配置
├── tsconfig.json       # TypeScript配置
├── jest.config.js      # Jest配置
└── README.md          # 项目说明
```

## 主要功能

### 1. 密钥生成
```typescript
const sk = SecretKey.fromKeygen();
const pk = sk.toPublicKey();
```

### 2. 聚合签名生成
```typescript
const { aggPk, hashedMsg, aggSig } = await generateAggregateSignature(secretKeys, messages);
```

### 3. 转换为Solidity格式
```typescript
const solidityArgs = toSolidityArguments(aggPk, hashedMsg, aggSig);
```

### 4. EIP-2537格式序列化
- G1点序列化为128字节
- G2点序列化为256字节
- 支持以太坊智能合约集成

## 依赖项

- `@chainsafe/blst`: BLS签名库
- `@noble/hashes`: 哈希函数库
- `typescript`: TypeScript编译器
- `ts-node`: TypeScript运行时

## 测试

项目使用Jest作为测试框架，包含以下测试：

- **单元测试**: 测试各个函数的功能
- **集成测试**: 测试完整的聚合签名流程
- **错误处理测试**: 测试异常情况
- **格式验证测试**: 测试EIP-2537格式兼容性

### 测试覆盖率

当前测试覆盖率达到：
- 语句覆盖率: 81.3%
- 分支覆盖率: 64.28%
- 函数覆盖率: 92.85%
- 行覆盖率: 80.5%

## 注意事项

- 确保正确清理BLS对象以避免内存泄漏
- 聚合签名要求所有签名者签名相同的消息
- 输出格式与以太坊EIP-2537预编译合约兼容 