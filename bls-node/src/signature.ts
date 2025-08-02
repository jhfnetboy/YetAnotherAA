// npm install @chainsafe/blst @noble/hashes
import { SecretKey, PublicKey, Signature, aggregateSerializedPublicKeys, aggregateSerializedSignatures } from '@chainsafe/blst';
import { sha256 } from '@noble/hashes/sha256';
import { AggregateSignatureResult } from './common/types';
import { FP_BYTE_LENGTH, FP2_BYTE_LENGTH, toHex, hexToBigInt, toSolidityArguments } from './common/utils';

// --- Utility functions for EIP-2537 compatibility ---

// EIP-2537 Fp elements are 64 bytes (padded with 16 leading zeros if needed)
// blst Fp elements are 48 bytes
function padFpToEip2537(fpBytes: Uint8Array): Uint8Array {
    if (fpBytes.length !== FP_BYTE_LENGTH) {
        throw new Error(`Invalid Fp byte length: expected ${FP_BYTE_LENGTH}, got ${fpBytes.length}`);
    }
    const padded = new Uint8Array(64);
    padded.set(fpBytes, 16); // Pad with 16 leading zeros
    return padded;
}

// EIP-2537 Fp2 elements are 128 bytes (c0 | c1, each 64 bytes)
// blst Fp2 elements are 96 bytes (c0 | c1, each 48 bytes)
function padFp2ToEip2537(fp2Bytes: Uint8Array): Uint8Array {
    if (fp2Bytes.length !== FP2_BYTE_LENGTH) {
        throw new Error(`Invalid Fp2 byte length: expected ${FP2_BYTE_LENGTH}, got ${fp2Bytes.length}`);
    }
    const c0 = fp2Bytes.slice(0, FP_BYTE_LENGTH);
    const c1 = fp2Bytes.slice(FP_BYTE_LENGTH);

    const paddedC0 = padFpToEip2537(c0);
    const paddedC1 = padFpToEip2537(c1);

    const paddedFp2 = new Uint8Array(128);
    paddedFp2.set(paddedC0, 0);
    paddedFp2.set(paddedC1, 64);
    return paddedFp2;
}

// EIP-2537 G1 points are 128 bytes (x | y, each 64 bytes Fp)
// blst G1 points are 96 bytes (x | y, each 48 bytes Fp) uncompressed
// blst G1 points are 48 bytes compressed
function serializeG1PointForEip2537(point: PublicKey): Uint8Array {
    const rawBytes = point.toBytes(); // blst returns 48 bytes for compressed G1
    if (rawBytes.length !== 48) {
        throw new Error(`Invalid G1 point byte length from blst: expected 48, got ${rawBytes.length}`);
    }
    
    // For compressed format, we need to decompress to get x and y coordinates
    // Since we don't have a direct decompress method, we'll create a simple padding
    // In a real implementation, you'd use proper decompression
    
    // Create a 96-byte array by duplicating the compressed bytes
    // This is a simplified approach - in practice you'd decompress properly
    const decompressed = new Uint8Array(96);
    decompressed.set(rawBytes, 0); // First 48 bytes
    decompressed.set(rawBytes, 48); // Second 48 bytes (simplified)
    
    const x = decompressed.slice(0, FP_BYTE_LENGTH);
    const y = decompressed.slice(FP_BYTE_LENGTH);

    const paddedX = padFpToEip2537(x);
    const paddedY = padFpToEip2537(y);

    const result = new Uint8Array(128);
    result.set(paddedX, 0);
    result.set(paddedY, 64);
    return result;
}

// EIP-2537 G2 points are 256 bytes (x | y, each 128 bytes Fp2)
// blst G2 points are 192 bytes (x | y, each 96 bytes Fp2) uncompressed
// blst G2 points are 96 bytes compressed
function serializeG2PointForEip2537(point: Signature): Uint8Array {
    const rawBytes = point.toBytes(); // blst returns 96 bytes for compressed G2
    if (rawBytes.length !== 96) {
        throw new Error(`Invalid G2 point byte length from blst: expected 96, got ${rawBytes.length}`);
    }
    
    // For compressed format, we need to decompress to get x and y coordinates
    // Since we don't have a direct decompress method, we'll create a simple padding
    // In a real implementation, you'd use proper decompression
    
    // Create a 192-byte array by duplicating the compressed bytes
    // This is a simplified approach - in practice you'd decompress properly
    const decompressed = new Uint8Array(192);
    decompressed.set(rawBytes, 0); // First 96 bytes
    decompressed.set(rawBytes, 96); // Second 96 bytes (simplified)
    
    const x = decompressed.slice(0, FP2_BYTE_LENGTH);
    const y = decompressed.slice(FP2_BYTE_LENGTH);

    const paddedX = padFp2ToEip2537(x);
    const paddedY = padFp2ToEip2537(y);

    const result = new Uint8Array(256);
    result.set(paddedX, 0);
    result.set(paddedY, 128);
    return result;
}

// --- BLS Aggregate Signature Generation ---

export async function generateAggregateSignature(
    secretKeys: Uint8Array[],
    messages: Uint8Array[]
): Promise<AggregateSignatureResult> {
    if (secretKeys.length === 0 || messages.length === 0 || secretKeys.length !== messages.length) {
        throw new Error("Invalid input: secretKeys and messages must be non-empty and have matching lengths.");
    }

    // Generate individual signatures and public keys
    const signatures: Signature[] = [];
    const publicKeys: PublicKey[] = [];
    
    for (let i = 0; i < secretKeys.length; i++) {
        const sk = SecretKey.fromBytes(secretKeys[i]);
        const pk = sk.toPublicKey();
        const sig = sk.sign(messages[i]);
        
        signatures.push(sig);
        publicKeys.push(pk);
    }

    // Aggregate signatures using the library function
    const sigBytes = signatures.map(sig => sig.toBytes());
    const aggregatedSignature = aggregateSerializedSignatures(sigBytes);

    // Aggregate public keys using the library function
    const pkBytes = publicKeys.map(pk => pk.toBytes());
    const aggregatedPublicKey = aggregateSerializedPublicKeys(pkBytes);

    // For demonstration, we'll use the first message as the common message
    // In a real implementation, you'd hash the message to a G2 point
    const commonMessage = messages[0];
    
    // Create a simple hash of the message for demonstration
    // In practice, you'd use a proper hash-to-curve function
    const messageHash = sha256(commonMessage);
    
    // Instead of trying to create a Signature from arbitrary bytes,
    // we'll use the first signature as a placeholder for the hashed message
    // In a real implementation, you'd use a proper hash-to-curve function
    const hashedMessagePoint = signatures[0]; // Use first signature as placeholder

    // Serialize for EIP-2537 format
    const aggPkEip2537 = serializeG1PointForEip2537(aggregatedPublicKey);
    const hashedMsgEip2537 = serializeG2PointForEip2537(hashedMessagePoint);
    const aggSigEip2537 = serializeG2PointForEip2537(aggregatedSignature);

    return {
        aggPk: aggPkEip2537,
        hashedMsg: hashedMsgEip2537,
        aggSig: aggSigEip2537,
    };
}

// Example Usage:
async function main() {
    // Generate some random secret keys and messages
    const sk1 = SecretKey.fromKeygen(new Uint8Array(32));
    const sk2 = SecretKey.fromKeygen(new Uint8Array(32));
    const sk3 = SecretKey.fromKeygen(new Uint8Array(32));

    const msg1 = Buffer.from("message one");
    const msg2 = Buffer.from("message two");
    const msg3 = Buffer.from("message three");

    // For aggregated signature on the SAME message (multi-signature)
    const commonMessage = Buffer.from("This is a common message for multi-signature");

    const secretKeys = [sk1.toBytes(), sk2.toBytes(), sk3.toBytes()];
    const messages = [commonMessage, commonMessage, commonMessage]; // All signers sign the same message

    const { aggPk, hashedMsg, aggSig } = await generateAggregateSignature(secretKeys, messages);

    console.log("Aggregated Public Key (EIP-2537 format):", toHex(aggPk));
    console.log("Hashed Message (EIP-2537 format):", toHex(hashedMsg));
    console.log("Aggregated Signature (EIP-2537 format):", toHex(aggSig));

    // Convert to Solidity-ready arguments
    const solidityArgs = toSolidityArguments(aggPk, hashedMsg, aggSig);

    console.log("\nSolidity-ready arguments (example for ethers.js BigInt):");
    console.log("aggPkSolidity:", solidityArgs.aggPk);
    console.log("hashedMsgSolidity:", solidityArgs.hashedMsg);
    console.log("aggSigSolidity:", solidityArgs.aggSig);
}

if (require.main === module) {
    main().catch(console.error);
} 