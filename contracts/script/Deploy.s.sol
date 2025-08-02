// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../signature-verify.sol";

contract DeployScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // 部署BLS聚合签名验证合约
        BLSAggregateVerification verifier = new BLSAggregateVerification();
        
        console.log("BLS Aggregate Signature Verification Contract Deployed:");
        console.log("Contract Address:", address(verifier));
        console.log("Deployer:", vm.addr(deployerPrivateKey));

        vm.stopBroadcast();
    }
} 