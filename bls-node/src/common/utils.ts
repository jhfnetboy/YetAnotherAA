import { sha256 } from '@noble/hashes/sha256';
import { SolidityG1Point, SolidityG2Point, SolidityArguments } from './types';

// --- Constants for EIP-2537 compatibility ---
export const FP_BYTE_LENGTH = 48;
export const FP2_BYTE_LENGTH = 96;
export const G1_POINT_BYTE_LENGTH = 96;
export const G2_POINT_BYTE_LENGTH = 192;

// Helper to convert Uint8Array to hex string for ABI encoding
export function toHex(bytes: Uint8Array): string {
    return '0x' + Buffer.from(bytes).toString('hex');
}

// Helper to convert hex string to BigInt
export function hexToBigInt(hex: string): bigint {
    return BigInt(hex);
}

// Helper to create random bytes
export function randomBytes(length: number): Uint8Array {
    const bytes = new Uint8Array(length);
    for (let i = 0; i < length; i++) {
        bytes[i] = Math.floor(Math.random() * 256);
    }
    return bytes;
}

// Helper to convert EIP-2537 format to Solidity arguments
export function toSolidityArguments(
    aggPk: Uint8Array,
    hashedMsg: Uint8Array,
    aggSig: Uint8Array
): SolidityArguments {
    const aggPkSolidity: SolidityG1Point = {
        X: hexToBigInt(toHex(aggPk.slice(0, 64))),
        Y: hexToBigInt(toHex(aggPk.slice(64, 128))),
    };

    const hashedMsgSolidity: SolidityG2Point = {
        X: [hexToBigInt(toHex(hashedMsg.slice(0, 64))), hexToBigInt(toHex(hashedMsg.slice(64, 128)))],
        Y: [hexToBigInt(toHex(hashedMsg.slice(128, 192))), hexToBigInt(toHex(hashedMsg.slice(192, 256)))],
    };

    const aggSigSolidity: SolidityG2Point = {
        X: [hexToBigInt(toHex(aggSig.slice(0, 64))), hexToBigInt(toHex(aggSig.slice(64, 128)))],
        Y: [hexToBigInt(toHex(aggSig.slice(128, 192))), hexToBigInt(toHex(aggSig.slice(192, 256)))],
    };

    return {
        aggPk: aggPkSolidity,
        hashedMsg: hashedMsgSolidity,
        aggSig: aggSigSolidity,
    };
}

// Helper to validate aggregate signature format
export function validateFormat(result: any) {
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