// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import {IPoolManager} from "v4-core/interfaces/IPoolManager.sol";
import {Hooks} from "@uniswap/v4-core/src/libraries/Hooks.sol";
import {HookMiner} from "../test/utils/HookMiner.sol";
import {IMarginHookManager} from "../src/interfaces/IMarginHookManager.sol";
import {MarginHookManager} from "../src/MarginHookManager.sol";
import {MirrorTokenManager} from "../src/MirrorTokenManager.sol";
import {MarginLiquidity} from "../src/MarginLiquidity.sol";
import {MarginChecker} from "../src/MarginChecker.sol";
import {MarginOracle} from "../src/MarginOracle.sol";
import {MarginFees} from "../src/MarginFees.sol";
import {MarginPositionManager} from "../src/MarginPositionManager.sol";
import {MarginRouter} from "../src/MarginRouter.sol";
import {BorrowPositionManager} from "../src/BorrowPositionManager.sol";

contract DeployAllScript is Script {
    error ManagerNotExist();

    address constant CREATE2_DEPLOYER = address(0x4e59b44847b379578588920cA78FbF26c0B4956C);
    address owner = 0x35D3F3497eC612b3Dd982819F95cA98e6a404Ce1;
    MirrorTokenManager mirrorTokenManager;
    MarginLiquidity marginLiquidity;
    MarginChecker marginChecker;
    MarginOracle marginOracle;
    MarginFees marginFees;

    function setUp() public {}

    function _getManager(uint256 chainId) internal pure returns (address manager) {
        if (chainId == 11155111) {
            manager = 0xE03A1074c86CFeDd5C142C4F04F1a1536e203543;
        }
    }

    function run(uint256 chainId) public {
        vm.startBroadcast();
        console.log(chainId);
        address manager = _getManager(chainId);
        if (manager == address(0)) {
            revert ManagerNotExist();
        }
        console2.log("poolManager:", manager);
        mirrorTokenManager = new MirrorTokenManager(owner);
        console2.log("mirrorTokenManager:", address(mirrorTokenManager));
        marginLiquidity = new MarginLiquidity(owner);
        console2.log("marginLiquidity:", address(marginLiquidity));
        marginChecker = new MarginChecker(owner);
        console2.log("marginChecker:", address(marginChecker));
        marginOracle = new MarginOracle();
        console2.log("marginOracle:", address(marginOracle));
        marginFees = new MarginFees(owner);
        console2.log("marginFees:", address(marginFees));

        BorrowPositionManager borrowPositionManager = new BorrowPositionManager(owner, marginChecker);
        console2.log("borrowPositionManager", address(borrowPositionManager));

        MarginPositionManager marginPositionManager = new MarginPositionManager(owner, marginChecker);
        console2.log("marginPositionManager", address(marginPositionManager));
        bytes memory constructorArgs =
            abi.encode(owner, manager, address(mirrorTokenManager), address(marginLiquidity), address(marginFees));

        uint160 flags =
            uint160(Hooks.BEFORE_ADD_LIQUIDITY_FLAG | Hooks.BEFORE_SWAP_FLAG | Hooks.BEFORE_SWAP_RETURNS_DELTA_FLAG);

        // Mine a salt that will produce a hook address with the correct flags
        bytes memory creationCode = vm.getCode("MarginHookManager.sol:MarginHookManager");
        (address hookAddress, bytes32 salt) = HookMiner.find(CREATE2_DEPLOYER, flags, creationCode, constructorArgs);

        // Deploy the hook using CREATE2
        bytes memory bytecode = abi.encodePacked(creationCode, constructorArgs);

        address deployedHook;
        assembly {
            deployedHook := create2(0, add(bytecode, 0x20), mload(bytecode), salt)
        }

        // verify proper create2 usage
        require(deployedHook == hookAddress, "DeployScript: hook address mismatch");
        marginPositionManager.setHook(hookAddress);
        MarginHookManager(hookAddress).addPositionManager(address(marginPositionManager));
        MarginHookManager(hookAddress).setMarginOracle(address(marginOracle));
        console2.log("hookAddress:", hookAddress);
        marginLiquidity.addHooks(hookAddress);
        mirrorTokenManager.addHooks(hookAddress);
        MarginRouter swapRouter = new MarginRouter(owner, IPoolManager(manager), IMarginHookManager(hookAddress));
        console2.log("swapRouter:", address(swapRouter));

        vm.stopBroadcast();
    }
}
