import { SecretKey } from '@chainsafe/blst';
import { generateAggregateSignature } from '../src/signature';
import { randomBytes, toSolidityArguments } from '../src/common/utils';

/**
 * 示例：如何使用BLS聚合签名
 */
async function exampleUsage() {
    console.log('=== BLS聚合签名示例 ===\n');

    // 1. 生成多个密钥对
    console.log('1. 生成密钥对...');
    const numSigners = 3;
    const secretKeys: Uint8Array[] = [];
    const publicKeys: string[] = [];

    for (let i = 0; i < numSigners; i++) {
        const sk = SecretKey.fromKeygen(randomBytes(32));
        const pk = sk.toPublicKey();
        
        secretKeys.push(sk.toBytes());
        publicKeys.push(pk.toHex());
        
        console.log(`   签名者 ${i + 1}:`);
        console.log(`     私钥长度: ${sk.toBytes().length} 字节`);
        console.log(`     公钥: ${pk.toHex()}`);
    }

    // 2. 准备要签名的消息
    console.log('\n2. 准备消息...');
    const message = Buffer.from("这是一个需要多签的消息");
    const messages = Array(numSigners).fill(message); // 所有签名者签名相同消息
    
    console.log(`   消息: "${message.toString()}"`);
    console.log(`   消息长度: ${message.length} 字节`);

    // 3. 生成聚合签名
    console.log('\n3. 生成聚合签名...');
    const result = await generateAggregateSignature(secretKeys, messages);
    
    console.log(`   聚合公钥长度: ${result.aggPk.length} 字节`);
    console.log(`   哈希消息长度: ${result.hashedMsg.length} 字节`);
    console.log(`   聚合签名长度: ${result.aggSig.length} 字节`);

    // 4. 转换为Solidity格式
    console.log('\n4. 转换为Solidity格式...');
    const solidityArgs = toSolidityArguments(result.aggPk, result.hashedMsg, result.aggSig);
    
    console.log('   Solidity参数已准备就绪');
    console.log(`   聚合公钥 X: ${solidityArgs.aggPk.X}`);
    console.log(`   聚合公钥 Y: ${solidityArgs.aggPk.Y}`);

    // 5. 验证输出格式
    console.log('\n5. 验证EIP-2537格式...');
    console.log(`   聚合公钥 (EIP-2537): 0x${Buffer.from(result.aggPk).toString('hex')}`);
    console.log(`   哈希消息 (EIP-2537): 0x${Buffer.from(result.hashedMsg).toString('hex')}`);
    console.log(`   聚合签名 (EIP-2537): 0x${Buffer.from(result.aggSig).toString('hex')}`);

    console.log('\n=== 示例完成 ===');
    console.log('\n注意:');
    console.log('- 这个示例使用了简化的哈希到曲线函数');
    console.log('- 在实际应用中，应使用RFC 9380兼容的hash_to_curve函数');
    console.log('- 聚合签名格式与以太坊EIP-2537预编译合约兼容');
}

/**
 * 示例：生成随机密钥对
 */
function generateKeyPair() {
    const sk = SecretKey.fromKeygen(randomBytes(32));
    const pk = sk.toPublicKey();
    
    return {
        secretKey: sk.toBytes(),
        publicKey: pk.toBytes(),
        secretKeyHex: sk.toHex(),
        publicKeyHex: pk.toHex()
    };
}

/**
 * 示例：验证聚合签名格式
 */
function validateFormat(result: any) {
    const errors = [];
    
    if (result.aggPk.length !== 128) {
        errors.push(`聚合公钥长度错误: 期望128字节，实际${result.aggPk.length}字节`);
    }
    
    if (result.hashedMsg.length !== 256) {
        errors.push(`哈希消息长度错误: 期望256字节，实际${result.hashedMsg.length}字节`);
    }
    
    if (result.aggSig.length !== 256) {
        errors.push(`聚合签名长度错误: 期望256字节，实际${result.aggSig.length}字节`);
    }
    
    if (errors.length === 0) {
        console.log('✅ 格式验证通过');
    } else {
        console.log('❌ 格式验证失败:');
        errors.forEach(error => console.log(`   ${error}`));
    }
}

// 运行示例
if (require.main === module) {
    exampleUsage().catch(console.error);
}

export { exampleUsage, generateKeyPair, validateFormat }; 