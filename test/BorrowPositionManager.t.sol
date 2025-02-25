// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

// Local
import {MarginHookManager} from "../src/MarginHookManager.sol";
import {MirrorTokenManager} from "../src/MirrorTokenManager.sol";
import {MarginPositionManager} from "../src/MarginPositionManager.sol";
import {MarginRouter} from "../src/MarginRouter.sol";
import {HookStatus} from "../src/types/HookStatus.sol";
import {BorrowParams} from "../src/types/BorrowParams.sol";
import {MarginParams} from "../src/types/MarginParams.sol";
import {MarginPosition, MarginPositionVo} from "../src/types/MarginPosition.sol";
import {BorrowPosition, BorrowPositionVo} from "../src/types/BorrowPosition.sol";
import {BurnParams} from "../src/types/BurnParams.sol";
import {AddLiquidityParams, RemoveLiquidityParams} from "../src/types/LiquidityParams.sol";
// Solmate
import {MockERC20} from "solmate/src/test/utils/mocks/MockERC20.sol";
// Forge
import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
// V4
import {PoolManager} from "@uniswap/v4-core/src/PoolManager.sol";
import {Hooks} from "@uniswap/v4-core/src/libraries/Hooks.sol";
import {IHooks} from "@uniswap/v4-core/src/interfaces/IHooks.sol";
import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {PoolId, PoolIdLibrary} from "v4-core/types/PoolId.sol";
import {Currency, CurrencyLibrary} from "@uniswap/v4-core/src/types/Currency.sol";
import {PoolKey} from "@uniswap/v4-core/src/types/PoolKey.sol";

import {BalanceDelta, BalanceDeltaLibrary} from "v4-core/types/BalanceDelta.sol";

import {HookMiner} from "./utils/HookMiner.sol";
import {DeployHelper} from "./utils/DeployHelper.sol";

contract BorrowPositionManagerTest is DeployHelper {
    function setUp() public {
        deployHookAndRouter();
        initPoolLiquidity();
    }

    function testBorrowTokens() public {
        address user = address(this);
        uint256 rate = marginFees.getBorrowRate(address(hookManager), key.toId(), false);
        assertEq(rate, 50000);
        uint256 positionId;
        uint256 borrowAmount;
        uint256 payValue = 0.01 ether;
        tokenA.approve(address(borrowPositionManager), payValue);
        tokenB.approve(address(borrowPositionManager), payValue);
        BorrowParams memory params = BorrowParams({
            poolId: key.toId(),
            marginForOne: false,
            marginAmount: payValue,
            borrowAmount: 0,
            borrowMinAmount: 0,
            recipient: user,
            deadline: block.timestamp + 1000
        });

        (positionId, borrowAmount) = borrowPositionManager.borrow(params);
        console.log(
            "hookManager.balance:%s,borrowPositionManager.balance:%s",
            address(hookManager).balance,
            address(borrowPositionManager).balance
        );
        console.log("positionId:%s,borrowAmount:%s", positionId, borrowAmount);
        BorrowPosition memory position = borrowPositionManager.getPosition(positionId);
        console.log(
            "positionId:%s,position.borrowAmount:%s,rateCumulativeLast:%s",
            positionId,
            position.borrowAmount,
            position.rateCumulativeLast
        );

        tokenA.approve(address(borrowPositionManager), payValue);
        tokenB.approve(address(borrowPositionManager), payValue);
        params = BorrowParams({
            poolId: key.toId(),
            marginForOne: false,
            marginAmount: payValue,
            borrowAmount: 0,
            borrowMinAmount: 0,
            recipient: user,
            deadline: block.timestamp + 1000
        });

        (positionId, borrowAmount) = borrowPositionManager.borrow(params);
        console.log(
            "hookManager.balance:%s,borrowPositionManager.balance:%s",
            address(hookManager).balance,
            address(borrowPositionManager).balance
        );
        position = borrowPositionManager.getPosition(positionId);
        console.log(
            "positionId:%s,position.borrowAmount:%s,rateCumulativeLast:%s",
            positionId,
            position.borrowAmount,
            position.rateCumulativeLast
        );
        (uint256 _reserves0, uint256 _reserves1) = hookManager.getReserves(key.toId());
        console.log("_reserves0:%s,_reserves1:%s", _reserves0, _reserves1);
        HookStatus memory _status = hookManager.getStatus(key.toId());
        console.log("reserve0:%s,reserve1:%s", uint256(_status.realReserve0), uint256(_status.realReserve1));
        console.log(
            "mirrorReserve0:%s,mirrorReserve1:%s", uint256(_status.mirrorReserve0), uint256(_status.mirrorReserve1)
        );
    }

    function testBorrowRepayTokens() public {
        testBorrowTokens();
        address user = address(this);
        uint256 positionId = borrowPositionManager.getPositionId(key.toId(), false, user);
        assertGt(positionId, 0);
        BorrowPosition memory position = borrowPositionManager.getPosition(positionId);
        uint256 repay = 0.01 ether;
        borrowPositionManager.repay(positionId, repay, UINT256_MAX);
        BorrowPosition memory newPosition = borrowPositionManager.getPosition(positionId);
        assertEq(position.borrowAmount - newPosition.borrowAmount, repay);
        repay = position.borrowAmount + 0.01 ether;
        borrowPositionManager.repay(positionId, repay, UINT256_MAX);
        newPosition = borrowPositionManager.getPosition(positionId);
        assertEq(newPosition.borrowAmount, 0);
    }
}
