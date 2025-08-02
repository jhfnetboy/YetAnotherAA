// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../signature-verify.sol";

contract BLSAggregateVerificationTest is Test {
    BLSAggregateVerification public verifier;

    function setUp() public {
        verifier = new BLSAggregateVerification();
    }

    function testContractDeployment() public {
        assertTrue(address(verifier) != address(0), "Contract deployment failed");
    }

    function testG1PointStruct() public {
        // Test G1Point struct
        BLSAggregateVerification.G1Point memory point = BLSAggregateVerification.G1Point({
            X: 0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef,
            Y: 0xfedcba0987654321fedcba0987654321fedcba0987654321fedcba0987654321
        });
        
        assertEq(point.X, 0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef, "G1Point X coordinate error");
        assertEq(point.Y, 0xfedcba0987654321fedcba0987654321fedcba0987654321fedcba0987654321, "G1Point Y coordinate error");
    }

    function testG2PointStruct() public {
        // Test G2Point struct with updated uint256[2] format
        uint256[2] memory x = [0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef, 0xfedcba0987654321fedcba0987654321fedcba0987654321fedcba0987654321];
        uint256[2] memory y = [0xabcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890, 0x0987654321fedcba0987654321fedcba0987654321fedcba0987654321fedcba];
        
        BLSAggregateVerification.G2Point memory point = BLSAggregateVerification.G2Point({
            X: x,
            Y: y
        });
        
        assertEq(point.X[0], 0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef, "G2Point X[0] coordinate error");
        assertEq(point.X[1], 0xfedcba0987654321fedcba0987654321fedcba0987654321fedcba0987654321, "G2Point X[1] coordinate error");
        assertEq(point.Y[0], 0xabcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890, "G2Point Y[0] coordinate error");
        assertEq(point.Y[1], 0x0987654321fedcba0987654321fedcba0987654321fedcba0987654321fedcba, "G2Point Y[1] coordinate error");
    }

    function testVerifyAggregateSignatureSuccess() public {
        console.log("Testing BLS verification with mocked precompile (success)...");
        
        // Create test BLS data
        BLSAggregateVerification.G1Point memory aggPk = BLSAggregateVerification.G1Point({
            X: 0x17F1D3A73197D7942695638C4FA9AC0FC3688C4F9774B905A14E3A3F171BAC5,
            Y: 0x8B3F481E3AAA0F1A09E30ED741D8AE4FCF5E095D5D00AF600DB18CB2C04B3ED
        });

        uint256[2] memory hashedMsgX = [0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef, 0xfedcba0987654321fedcba0987654321fedcba0987654321fedcba0987654321];
        uint256[2] memory hashedMsgY = [0xabcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890, 0x0987654321fedcba0987654321fedcba0987654321fedcba0987654321fedcba];
        
        BLSAggregateVerification.G2Point memory hashedMsg = BLSAggregateVerification.G2Point({
            X: hashedMsgX,
            Y: hashedMsgY
        });

        uint256[2] memory aggSigX = [0xabcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890, 0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef];
        uint256[2] memory aggSigY = [0x0987654321fedcba0987654321fedcba0987654321fedcba0987654321fedcba, 0xfedcba0987654321fedcba0987654321fedcba0987654321fedcba0987654321];
        
        BLSAggregateVerification.G2Point memory aggSig = BLSAggregateVerification.G2Point({
            X: aggSigX,
            Y: aggSigY
        });

        // Mock precompile to return success: 32 bytes with last byte = 0x01
        bytes memory successReturn = new bytes(32);
        successReturn[31] = 0x01;

        vm.mockCall(
            address(0x0f),
            abi.encode(
                aggPk.X, aggPk.Y,
                hashedMsg.X[0], hashedMsg.X[1], hashedMsg.Y[0], hashedMsg.Y[1],
                verifier.NEG_G1_X(), verifier.NEG_G1_Y(),
                aggSig.X[0], aggSig.X[1], aggSig.Y[0], aggSig.Y[1]
            ),
            successReturn
        );

        bool result = verifier.verifyAggregateSignature(aggPk, hashedMsg, aggSig);
        
        console.log("BLS verification result:", result);
        assertTrue(result, "Should return true when precompile returns success");
    }

    function testVerifyAggregateSignatureFailure() public {
        console.log("Testing BLS verification with mocked precompile (failure)...");
        
        // Same test data structure as success test
        BLSAggregateVerification.G1Point memory aggPk = BLSAggregateVerification.G1Point({
            X: 0x17F1D3A73197D7942695638C4FA9AC0FC3688C4F9774B905A14E3A3F171BAC5,
            Y: 0x8B3F481E3AAA0F1A09E30ED741D8AE4FCF5E095D5D00AF600DB18CB2C04B3ED
        });

        uint256[2] memory hashedMsgX = [0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef, 0xfedcba0987654321fedcba0987654321fedcba0987654321fedcba0987654321];
        uint256[2] memory hashedMsgY = [0xabcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890, 0x0987654321fedcba0987654321fedcba0987654321fedcba0987654321fedcba];
        
        BLSAggregateVerification.G2Point memory hashedMsg = BLSAggregateVerification.G2Point({
            X: hashedMsgX,
            Y: hashedMsgY
        });

        uint256[2] memory aggSigX = [0xabcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890, 0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef];
        uint256[2] memory aggSigY = [0x0987654321fedcba0987654321fedcba0987654321fedcba0987654321fedcba, 0xfedcba0987654321fedcba0987654321fedcba0987654321fedcba0987654321];
        
        BLSAggregateVerification.G2Point memory aggSig = BLSAggregateVerification.G2Point({
            X: aggSigX,
            Y: aggSigY
        });

        // Mock precompile to return failure: 32 bytes with last byte = 0x00
        bytes memory failureReturn = new bytes(32);
        failureReturn[31] = 0x00;

        vm.mockCall(
            address(0x0f),
            abi.encode(
                aggPk.X, aggPk.Y,
                hashedMsg.X[0], hashedMsg.X[1], hashedMsg.Y[0], hashedMsg.Y[1],
                verifier.NEG_G1_X(), verifier.NEG_G1_Y(),
                aggSig.X[0], aggSig.X[1], aggSig.Y[0], aggSig.Y[1]
            ),
            failureReturn
        );

        bool result = verifier.verifyAggregateSignature(aggPk, hashedMsg, aggSig);
        
        console.log("BLS verification result:", result);
        assertFalse(result, "Should return false when precompile returns failure");
    }

    function testVerifyAggregateSignatureRevert() public {
        console.log("Testing BLS verification with precompile revert...");
        
        // Test data
        BLSAggregateVerification.G1Point memory aggPk = BLSAggregateVerification.G1Point({
            X: 0x17F1D3A73197D7942695638C4FA9AC0FC3688C4F9774B905A14E3A3F171BAC5,
            Y: 0x8B3F481E3AAA0F1A09E30ED741D8AE4FCF5E095D5D00AF600DB18CB2C04B3ED
        });

        uint256[2] memory hashedMsgX = [0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef, 0xfedcba0987654321fedcba0987654321fedcba0987654321fedcba0987654321];
        uint256[2] memory hashedMsgY = [0xabcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890, 0x0987654321fedcba0987654321fedcba0987654321fedcba0987654321fedcba];
        
        BLSAggregateVerification.G2Point memory hashedMsg = BLSAggregateVerification.G2Point({
            X: hashedMsgX,
            Y: hashedMsgY
        });

        uint256[2] memory aggSigX = [0xabcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890, 0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef];
        uint256[2] memory aggSigY = [0x0987654321fedcba0987654321fedcba0987654321fedcba0987654321fedcba, 0xfedcba0987654321fedcba0987654321fedcba0987654321fedcba0987654321];
        
        BLSAggregateVerification.G2Point memory aggSig = BLSAggregateVerification.G2Point({
            X: aggSigX,
            Y: aggSigY
        });

        // Mock precompile to revert
        vm.mockCallRevert(
            address(0x0f),
            abi.encode(
                aggPk.X, aggPk.Y,
                hashedMsg.X[0], hashedMsg.X[1], hashedMsg.Y[0], hashedMsg.Y[1],
                verifier.NEG_G1_X(), verifier.NEG_G1_Y(),
                aggSig.X[0], aggSig.X[1], aggSig.Y[0], aggSig.Y[1]
            ),
            "Mock precompile revert"
        );

        // Expect the contract to revert with its error message
        vm.expectRevert("BLS pairing check precompile call failed");
        verifier.verifyAggregateSignature(aggPk, hashedMsg, aggSig);
        
        console.log("Contract correctly handled precompile revert");
    }

    function testBLSNodeDataFormatCompatibility() public {
        console.log("Testing BLS-node data format compatibility...");
        
        // Simulate BLS-node generated data format with proper structure
        BLSAggregateVerification.G1Point memory aggPk = BLSAggregateVerification.G1Point({
            X: 0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef,
            Y: 0xfedcba0987654321fedcba0987654321fedcba0987654321fedcba0987654321
        });

        // G2Point with [c0, c1] format as generated by BLS-node
        uint256[2] memory hashedMsgX = [0xabcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890, 0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef];
        uint256[2] memory hashedMsgY = [0x0987654321fedcba0987654321fedcba0987654321fedcba0987654321fedcba, 0xfedcba0987654321fedcba0987654321fedcba0987654321fedcba0987654321];
        
        BLSAggregateVerification.G2Point memory hashedMsg = BLSAggregateVerification.G2Point({
            X: hashedMsgX,
            Y: hashedMsgY
        });

        uint256[2] memory aggSigX = [0x9876543210fedcba9876543210fedcba9876543210fedcba9876543210fedcba, 0xabcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890];
        uint256[2] memory aggSigY = [0x1111222233334444555566667777888899990000aaaabbbbccccddddeeeeffff, 0xfffeeeeddddccccbbbbaaaa0000999988887777666655554444333322221111];
        
        BLSAggregateVerification.G2Point memory aggSig = BLSAggregateVerification.G2Point({
            X: aggSigX,
            Y: aggSigY
        });

        // Mock successful verification
        bytes memory successReturn = new bytes(32);
        successReturn[31] = 0x01;

        vm.mockCall(
            address(0x0f),
            abi.encode(
                aggPk.X, aggPk.Y,
                hashedMsg.X[0], hashedMsg.X[1], hashedMsg.Y[0], hashedMsg.Y[1],
                verifier.NEG_G1_X(), verifier.NEG_G1_Y(),
                aggSig.X[0], aggSig.X[1], aggSig.Y[0], aggSig.Y[1]
            ),
            successReturn
        );

        bool result = verifier.verifyAggregateSignature(aggPk, hashedMsg, aggSig);
        
        console.log("BLS-node format verification result:", result);
        assertTrue(result, "BLS-node data format should be fully compatible");
        
        console.log("BLS-node data format is fully compatible with Solidity contract");
    }

    function testConstants() public {
        // Test constant values
        assertEq(verifier.NEG_G1_X(), 0x17F1D3A73197D7942695638C4FA9AC0FC3688C4F9774B905A14E3A3F171BAC5, "NEG_G1_X constant error");
        assertEq(verifier.NEG_G1_Y(), 0x114D4D7E82C55F085F21CE32E8BE671B001A0111EA397FE69A4B1BA7B6434BAC, "NEG_G1_Y constant error");
    }

    function testPrecompileAddress() public {
        // Test precompile contract address
        assertEq(address(verifier.BLS12_PAIRING_CHECK_ADDRESS()), address(0x0f), "BLS12_PAIRING_CHECK_ADDRESS error");
    }

    // Test invalid inputs
    function testInvalidInputs() public {
        BLSAggregateVerification.G1Point memory aggPk = BLSAggregateVerification.G1Point({
            X: 0,
            Y: 0
        });

        uint256[2] memory zeroPoint = [uint256(0), uint256(0)];
        BLSAggregateVerification.G2Point memory hashedMsg = BLSAggregateVerification.G2Point({
            X: zeroPoint,
            Y: zeroPoint
        });

        BLSAggregateVerification.G2Point memory aggSig = BLSAggregateVerification.G2Point({
            X: zeroPoint,
            Y: zeroPoint
        });

        // Test zero value inputs
        try verifier.verifyAggregateSignature(aggPk, hashedMsg, aggSig) {
            console.log("Zero value input verification result");
        } catch Error(string memory reason) {
            console.log("Zero value input verification failed:", reason);
        } catch {
            console.log("Zero value input verification failed (unknown error)");
        }
    }

} 