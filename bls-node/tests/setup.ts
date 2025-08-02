// Jest测试设置文件

// 设置全局测试超时
jest.setTimeout(10000);

// 简单的测试工具函数
export const testUtils = {
    // 创建测试用的随机字节数组
    createRandomBytes: (length: number): Uint8Array => {
        const bytes = new Uint8Array(length);
        for (let i = 0; i < length; i++) {
            bytes[i] = Math.floor(Math.random() * 256);
        }
        return bytes;
    },

    // 创建测试用的消息
    createTestMessage: (content: string): Buffer => {
        return Buffer.from(content, 'utf8');
    },

    // 验证字节数组长度
    validateByteLength: (bytes: Uint8Array, expectedLength: number): boolean => {
        return bytes.length === expectedLength;
    }
}; 