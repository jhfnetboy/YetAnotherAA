import { SecretKey } from '@chainsafe/blst';
import { generateAggregateSignature } from '../src/signature';
import { randomBytes, toSolidityArguments, validateFormat } from '../src/common/utils';

describe('integration.spec.ts', () => {
    describe('集成测试', () => {
        it('应该完成完整的聚合签名流程', async () => {
            // 1. 生成密钥对
            const sk1 = SecretKey.fromKeygen(randomBytes(32));
            const sk2 = SecretKey.fromKeygen(randomBytes(32));
            const sk3 = SecretKey.fromKeygen(randomBytes(32));
            
            const secretKeys = [sk1.toBytes(), sk2.toBytes(), sk3.toBytes()];
            const message = Buffer.from("集成测试消息");
            const messages = [message, message, message];
            
            // 2. 生成聚合签名
            const result = await generateAggregateSignature(secretKeys, messages);
            
            // 3. 验证格式
            const consoleSpy = jest.spyOn(console, 'log').mockImplementation();
            validateFormat(result);
            expect(consoleSpy).toHaveBeenCalledWith('✅ 格式验证通过');
            consoleSpy.mockRestore();
            
            // 4. 转换为Solidity格式
            const solidityArgs = toSolidityArguments(result.aggPk, result.hashedMsg, result.aggSig);
            
            // 5. 验证Solidity格式
            expect(solidityArgs.aggPk.X).toBeDefined();
            expect(solidityArgs.aggPk.Y).toBeDefined();
            expect(solidityArgs.hashedMsg.X).toHaveLength(2);
            expect(solidityArgs.hashedMsg.Y).toHaveLength(2);
            expect(solidityArgs.aggSig.X).toHaveLength(2);
            expect(solidityArgs.aggSig.Y).toHaveLength(2);
        });

        it('应该处理不同数量的签名者', async () => {
            const testCases = [2, 3, 5, 10];
            
            for (const numSigners of testCases) {
                const secretKeys: Uint8Array[] = [];
                const messages: Uint8Array[] = [];
                
                for (let i = 0; i < numSigners; i++) {
                    const sk = SecretKey.fromKeygen(randomBytes(32));
                    secretKeys.push(sk.toBytes());
                    messages.push(Buffer.from(`消息${i + 1}`));
                }
                
                const result = await generateAggregateSignature(secretKeys, messages);
                
                expect(result.aggPk.length).toBe(128);
                expect(result.hashedMsg.length).toBe(256);
                expect(result.aggSig.length).toBe(256);
            }
        });
    });
}); 