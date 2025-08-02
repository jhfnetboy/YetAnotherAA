// BLS聚合签名的类型定义

export interface AggregateSignatureResult {
    aggPk: Uint8Array;
    hashedMsg: Uint8Array;
    aggSig: Uint8Array;
}

export interface SolidityG1Point {
    X: bigint;
    Y: bigint;
}

export interface SolidityG2Point {
    X: [bigint, bigint];
    Y: [bigint, bigint];
}

export interface SolidityArguments {
    aggPk: SolidityG1Point;
    hashedMsg: SolidityG2Point;
    aggSig: SolidityG2Point;
} 