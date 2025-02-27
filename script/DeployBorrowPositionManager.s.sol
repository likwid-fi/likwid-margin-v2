// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";

import {MarginChecker} from "../src/MarginChecker.sol";
import {BorrowPositionManager} from "../src/BorrowPositionManager.sol";
import {IMarginChecker} from "../src/interfaces/IMarginChecker.sol";
import {MarginHookManager} from "../src/MarginHookManager.sol";

contract DeployBorrowPositionManagerScript is Script {
    BorrowPositionManager borrowPositionManager;
    address owner = 0x35D3F3497eC612b3Dd982819F95cA98e6a404Ce1;
    address checker = 0x0085dd2dA42ee35B22B90a5C3d3b092D80521A80;
    address hookAddress = 0x5B775Dee7ACA25bc05a0094a11BB122e02A28888;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        borrowPositionManager = new BorrowPositionManager(owner, IMarginChecker(checker));
        // marginPositionManager = new MarginPositionManager(owner, IMarginChecker(checker));
        console2.log("borrowPositionManager:", address(borrowPositionManager));
        borrowPositionManager.setHook(hookAddress);
        MarginHookManager(hookAddress).addPositionManager(address(borrowPositionManager));
        vm.stopBroadcast();
    }
}
