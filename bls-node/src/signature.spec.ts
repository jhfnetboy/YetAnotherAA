import { SecretKey } from '@chainsafe/blst';
import { generateAggregateSignature } from './signature';
import { randomBytes, toSolidityArguments, validateFormat, toHex, hexToBigInt } from './common/utils';
import { AggregateSignatureResult } from './common/types';

describe('signature.ts', () => {
    describe('generateAggregateSignature', () => {
        it('应该成功生成聚合签名', async () => {
            // 准备测试数据
            const sk1 = SecretKey.fromKeygen(randomBytes(32));
            const sk2 = SecretKey.fromKeygen(randomBytes(32));
            
            const secretKeys = [sk1.toBytes(), sk2.toBytes()];
            const message = Buffer.from("测试消息");
            const messages = [message, message];
            
            // 执行测试
            const result = await generateAggregateSignature(secretKeys, messages);
            
            // 验证结果
            expect(result).toBeDefined();
            expect(result.aggPk).toBeDefined();
            expect(result.hashedMsg).toBeDefined();
            expect(result.aggSig).toBeDefined();
            
            expect(result.aggPk.length).toBe(128);
            expect(result.hashedMsg.length).toBe(256);
            expect(result.aggSig.length).toBe(256);
        });

        it('应该处理多个签名者', async () => {
            // 准备测试数据
            const numSigners = 5;
            const secretKeys: Uint8Array[] = [];
            const messages: Uint8Array[] = [];
            
            for (let i = 0; i < numSigners; i++) {
                const sk = SecretKey.fromKeygen(randomBytes(32));
                secretKeys.push(sk.toBytes());
                messages.push(Buffer.from(`消息${i + 1}`));
            }
            
            // 执行测试
            const result = await generateAggregateSignature(secretKeys, messages);
            
            // 验证结果
            expect(result.aggPk.length).toBe(128);
            expect(result.hashedMsg.length).toBe(256);
            expect(result.aggSig.length).toBe(256);
        });

        it('应该抛出错误当输入为空', async () => {
            await expect(generateAggregateSignature([], [])).rejects.toThrow(
                "Invalid input: secretKeys and messages must be non-empty and have matching lengths."
            );
        });

        it('应该抛出错误当密钥和消息数量不匹配', async () => {
            const sk1 = SecretKey.fromKeygen(randomBytes(32));
            const secretKeys = [sk1.toBytes()];
            const messages = [Buffer.from("消息1"), Buffer.from("消息2")];
            
            await expect(generateAggregateSignature(secretKeys, messages)).rejects.toThrow(
                "Invalid input: secretKeys and messages must be non-empty and have matching lengths."
            );
        });
    });
}); 