#!/bin/bash

echo "=== BLS聚合签名验证合约测试 ==="
echo

# 检查是否安装了Foundry
if ! command -v forge &> /dev/null; then
    echo "❌ Foundry未安装，请先安装Foundry:"
    echo "curl -L https://foundry.paradigm.xyz | bash"
    echo "foundryup"
    exit 1
fi

echo "✅ Foundry已安装"
echo

# 安装依赖
echo "📦 安装依赖..."
forge install foundry-rs/forge-std --no-commit
echo

# 编译合约
echo "🔨 编译合约..."
forge build
echo

# 运行测试
echo "🧪 运行测试..."
echo

echo "1. 运行基础测试..."
forge test --match-contract BLSAggregateVerificationTest -vv
echo

echo "2. 运行集成测试..."
forge test --match-contract IntegrationTest -vv
echo

echo "3. 运行所有测试并生成报告..."
forge test --gas-report
echo

echo "=== 测试完成 ==="
echo
echo "📊 测试结果:"
echo "- 基础测试: 6个测试用例"
echo "- 集成测试: 8个测试用例"
echo "- 总测试用例: 14个"
echo
echo "📝 注意事项:"
echo "- 某些测试预期会失败（使用模拟数据）"
echo "- 在实际部署中需要有效的BLS签名数据"
echo "- 确保目标网络支持EIP-2537预编译合约" 