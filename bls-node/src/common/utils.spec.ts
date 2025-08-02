import { toSolidityArguments, validateFormat, toHex, hexToBigInt, randomBytes } from './utils';
import { AggregateSignatureResult } from './types';

describe('utils.ts', () => {
    describe('toSolidityArguments', () => {
        it('应该正确转换为Solidity格式', () => {
            // 准备测试数据
            const aggPk = new Uint8Array(128);
            const hashedMsg = new Uint8Array(256);
            const aggSig = new Uint8Array(256);
            
            // 填充一些测试数据
            for (let i = 0; i < 128; i++) {
                aggPk[i] = i % 256;
            }
            for (let i = 0; i < 256; i++) {
                hashedMsg[i] = i % 256;
                aggSig[i] = i % 256;
            }
            
            // 执行测试
            const result = toSolidityArguments(aggPk, hashedMsg, aggSig);
            
            // 验证结果
            expect(result).toBeDefined();
            expect(result.aggPk).toBeDefined();
            expect(result.hashedMsg).toBeDefined();
            expect(result.aggSig).toBeDefined();
            
            expect(typeof result.aggPk.X).toBe('bigint');
            expect(typeof result.aggPk.Y).toBe('bigint');
            expect(Array.isArray(result.hashedMsg.X)).toBe(true);
            expect(Array.isArray(result.hashedMsg.Y)).toBe(true);
            expect(Array.isArray(result.aggSig.X)).toBe(true);
            expect(Array.isArray(result.aggSig.Y)).toBe(true);
            
            expect(result.hashedMsg.X.length).toBe(2);
            expect(result.hashedMsg.Y.length).toBe(2);
            expect(result.aggSig.X.length).toBe(2);
            expect(result.aggSig.Y.length).toBe(2);
        });
    });

    describe('validateFormat', () => {
        it('应该通过格式验证当数据正确', () => {
            const mockResult: AggregateSignatureResult = {
                aggPk: new Uint8Array(128),
                hashedMsg: new Uint8Array(256),
                aggSig: new Uint8Array(256)
            };
            
            // 使用console.log的mock来捕获输出
            const consoleSpy = jest.spyOn(console, 'log').mockImplementation();
            
            validateFormat(mockResult);
            
            expect(consoleSpy).toHaveBeenCalledWith('✅ 格式验证通过');
            
            consoleSpy.mockRestore();
        });

        it('应该失败格式验证当数据不正确', () => {
            const mockResult: AggregateSignatureResult = {
                aggPk: new Uint8Array(64), // 错误长度
                hashedMsg: new Uint8Array(128), // 错误长度
                aggSig: new Uint8Array(128) // 错误长度
            };
            
            const consoleSpy = jest.spyOn(console, 'log').mockImplementation();
            
            validateFormat(mockResult);
            
            expect(consoleSpy).toHaveBeenCalledWith('❌ 格式验证失败:');
            expect(consoleSpy).toHaveBeenCalledWith(expect.stringContaining('聚合公钥长度错误'));
            expect(consoleSpy).toHaveBeenCalledWith(expect.stringContaining('哈希消息长度错误'));
            expect(consoleSpy).toHaveBeenCalledWith(expect.stringContaining('聚合签名长度错误'));
            
            consoleSpy.mockRestore();
        });
    });

    describe('工具函数', () => {
        it('toHex应该正确转换字节数组', () => {
            const bytes = new Uint8Array([0x01, 0x02, 0x03, 0x04]);
            const result = toHex(bytes);
            expect(result).toBe('0x01020304');
        });

        it('hexToBigInt应该正确转换十六进制字符串', () => {
            const hex = '0x01020304';
            const result = hexToBigInt(hex);
            expect(result).toBe(BigInt('0x01020304'));
        });

        it('randomBytes应该生成指定长度的随机字节', () => {
            const length = 32;
            const result = randomBytes(length);
            expect(result.length).toBe(length);
            expect(result instanceof Uint8Array).toBe(true);
        });
    });
}); 