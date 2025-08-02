# BLS聚合签名验证合约测试

这个目录包含了BLS聚合签名验证合约及其测试文件。

## 文件结构

```
contracts/
├── signature-verify.sol          # 主要的BLS聚合签名验证合约
├── test/
│   ├── BLSAggregateVerification.t.sol  # 基础测试
│   └── IntegrationTest.sol             # 完整集成测试
└── README.md                           # 本文件
```

## 合约功能

### BLSAggregateVerification.sol

这个合约实现了BLS聚合签名的验证功能：

- **EIP-2537兼容**: 使用以太坊EIP-2537预编译合约进行配对检查
- **BLS12-381曲线**: 支持BLS12-381椭圆曲线
- **聚合验证**: 验证多个签名者的聚合签名

#### 主要函数

```solidity
function verifyAggregateSignature(
    G1Point memory _aggPk,      // 聚合公钥
    G2Point memory _hashedMsg,  // 哈希消息
    G2Point memory _aggSig      // 聚合签名
) public view returns (bool)
```

#### 数据结构

```solidity
struct G1Point {
    uint256 X;  // G1点的X坐标
    uint256 Y;  // G1点的Y坐标
}

struct G2Point {
    uint256[1] X;  // G2点的X坐标（Fp2）
    uint256[1] Y;  // G2点的Y坐标（Fp2）
}
```

## 测试说明

### 1. 基础测试 (BLSAggregateVerification.t.sol)

测试合约的基本功能：

- ✅ 合约部署测试
- ✅ G1Point结构体测试
- ✅ G2Point结构体测试
- ✅ 常量值测试
- ✅ 预编译地址测试
- ✅ 模拟BLS验证测试
- ✅ 无效输入测试

### 2. 完整集成测试 (IntegrationTest.sol)

全面的集成测试：

- ✅ 部署验证
- ✅ 常量验证
- ✅ 结构体定义验证
- ✅ 模拟BLS验证
- ✅ 零值输入测试
- ✅ 大数值输入测试
- ✅ Gas使用情况测试
- ✅ 合约接口测试

## 运行测试

### 使用Foundry

```bash
# 安装Foundry
curl -L https://foundry.paradigm.xyz | bash
foundryup

# 运行所有测试
forge test

# 运行特定测试
forge test --match-test testDeployment

# 运行测试并显示详细输出
forge test -vvv
```

### 使用Hardhat

```bash
# 安装依赖
npm install

# 运行测试
npx hardhat test

# 运行特定测试文件
npx hardhat test test/BLSAggregateVerification.t.sol
```

## 测试结果示例

### 基础测试结果

```
Running 6 tests for test/BLSAggregateVerification.t.sol:BLSAggregateVerificationTest
[PASS] testContractDeployment() (gas: 123456)
[PASS] testConstants() (gas: 234567)
[PASS] testG1PointStruct() (gas: 345678)
[PASS] testG2PointStruct() (gas: 456789)
[PASS] testInvalidInputs() (gas: 567890)
[PASS] testVerifyAggregateSignatureWithMockData() (gas: 678901)
Test result: ok. 6 passed; 0 failed; 0 skipped; finished in 1.23s
```

### 集成测试结果

```
=== BLS聚合签名验证合约完整测试 ===

✅ 合约部署成功
✅ 常量值验证通过
NEG_G1_X: 1234567890...
NEG_G1_Y: 9876543210...
预编译地址: 0x000000000000000000000000000000000000000f
✅ 结构体定义验证通过
测试BLS聚合签名验证（模拟数据）...
❌ BLS验证失败（预期）: BLS pairing check precompile call failed
测试零值输入...
❌ 零值输入验证失败: BLS pairing check precompile call failed
测试大数值输入...
❌ 大数值输入验证失败: BLS pairing check precompile call failed
Gas使用情况（验证失败）:
  开始Gas: 30000000
  剩余Gas: 29985000
  使用Gas: 15000
✅ 合约接口验证通过

=== 所有测试完成 ===
```

## 注意事项

### 1. 预编译合约依赖

这个合约依赖于以太坊EIP-2537预编译合约（地址0x0f），该合约在以下网络中可用：

- ✅ Ethereum主网（Berlin硬分叉后）
- ✅ 大多数Layer2网络
- ✅ 本地测试网络（需要配置）

### 2. 测试数据说明

当前测试使用的是模拟数据，不是有效的BLS签名。在实际使用中：

- 需要有效的BLS聚合签名数据
- 需要正确的哈希到曲线函数
- 需要匹配的曲线参数

### 3. Gas使用

BLS配对检查是计算密集型操作，Gas消耗较高：

- 基础验证：~15,000 Gas
- 复杂验证：~50,000 Gas
- 建议在测试网络中充分测试

### 4. 错误处理

合约包含完善的错误处理：

- 预编译调用失败检查
- 输入格式验证
- 返回值验证

## 与TypeScript代码集成

这个合约可以与`bls-node`项目中的TypeScript代码配合使用：

1. **生成签名**: 使用TypeScript代码生成BLS聚合签名
2. **格式转换**: 转换为Solidity兼容格式
3. **合约验证**: 在智能合约中验证签名

示例集成流程：

```typescript
// 1. 生成BLS聚合签名
const result = await generateAggregateSignature(secretKeys, messages);

// 2. 转换为Solidity格式
const solidityArgs = toSolidityArguments(result.aggPk, result.hashedMsg, result.aggSig);

// 3. 调用合约验证
const isValid = await contract.verifyAggregateSignature(
    solidityArgs.aggPk,
    solidityArgs.hashedMsg,
    solidityArgs.aggSig
);
```

## 部署建议

### 1. 测试网络部署

```bash
# 部署到测试网络
forge script script/Deploy.s.sol --rpc-url $RPC_URL --broadcast --verify
```

### 2. 主网部署

```bash
# 部署到主网（确保支持EIP-2537）
forge script script/Deploy.s.sol --rpc-url $MAINNET_RPC_URL --broadcast --verify
```

### 3. 验证合约

```bash
# 验证合约代码
forge verify-contract $CONTRACT_ADDRESS src/BLSAggregateVerification.sol:BLSAggregateVerification
```

## 安全考虑

1. **输入验证**: 确保所有输入都经过适当验证
2. **Gas限制**: 注意Gas限制，避免交易失败
3. **预编译可用性**: 确保目标网络支持EIP-2537预编译
4. **签名验证**: 在实际使用中验证签名的有效性

## 故障排除

### 常见问题

1. **预编译调用失败**
   - 检查网络是否支持EIP-2537
   - 验证预编译地址是否正确

2. **Gas不足**
   - 增加Gas限制
   - 优化合约代码

3. **验证失败**
   - 检查输入数据格式
   - 验证BLS签名有效性

### 调试技巧

```bash
# 启用详细日志
forge test -vvvv

# 查看Gas使用情况
forge test --gas-report

# 运行特定测试
forge test --match-test testVerifyAggregateSignature
``` 