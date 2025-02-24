// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.24;

import {IPoolManager} from "v4-core/interfaces/IPoolManager.sol";
import {IImmutableState} from "v4-periphery/src/interfaces/IImmutableState.sol";
import {Currency} from "v4-core/types/Currency.sol";
import {PoolId} from "v4-core/types/PoolId.sol";

import {AddLiquidityParams, RemoveLiquidityParams} from "../types/LiquidityParams.sol";
import {MarginParams, ReleaseParams} from "../types/MarginParams.sol";
import {HookStatus} from "../types/HookStatus.sol";
import {IMarginFees} from "../interfaces/IMarginFees.sol";
import {IMarginLiquidity} from "../interfaces/IMarginLiquidity.sol";

interface IMarginHookManager is IImmutableState {
    /// @notice Get current margin oracle address
    function marginOracle() external view returns (address);

    /// @notice Get current IMarginFees
    function marginFees() external view returns (IMarginFees);

    /// @notice Get current IMarginLiquidity
    function marginLiquidity() external view returns (IMarginLiquidity);

    /// @notice Get status of a pool
    /// @param poolId The poolId of the pool to query
    /// @return status The current status of the pool
    function getStatus(PoolId poolId) external view returns (HookStatus memory);

    /// @notice Get the reserves of a pool
    /// @param poolId The poolId of the pool to query
    /// @return _reserve0 The reserve of the first token in the pool
    /// @return _reserve1 The reserve of the second token in the pool
    function getReserves(PoolId poolId) external view returns (uint256 _reserve0, uint256 _reserve1);

    /// @notice Given an output amount of an asset and pair reserve, returns a required input amount of the other asset
    /// @param poolId The poolId of the pool to query
    /// @param zeroForOne If true, the input asset is the first token of the pair, otherwise it is the second token
    /// @param amountOut an output amount
    /// @return amountIn a required input amount
    function getAmountIn(PoolId poolId, bool zeroForOne, uint256 amountOut) external view returns (uint256 amountIn);

    /// @notice Given an input amount of an asset and pair reserve, returns the expected output amount of the other asset
    /// @param poolId The poolId of the pool to query
    /// @param zeroForOne If true, the input asset is the first token of the pair, otherwise it is the second token
    /// @param amountIn a input amount
    /// @return amountOut an output amount
    function getAmountOut(PoolId poolId, bool zeroForOne, uint256 amountIn) external view returns (uint256 amountOut);

    /// @notice Add liquidity to a pool
    /// @param params The parameters for the add liquidity hook
    /// @return liquidity The amount of liquidity minted
    function addLiquidity(AddLiquidityParams calldata params) external payable returns (uint256 liquidity);

    /// @notice Remove liquidity from a pool
    /// @param params The parameters for the remove liquidity hook
    /// @return amount0 The amount of token0 repaid
    /// @return amount1 The amount of token1 repaid
    function removeLiquidity(RemoveLiquidityParams calldata params)
        external
        returns (uint256 amount0, uint256 amount1);

    /// @notice Margin
    /// @param params The parameters for the margin hook
    /// @return The updated parameters for the margin hook
    function margin(MarginParams memory params) external returns (MarginParams memory);

    /// @notice Release
    /// @param params The parameters for the release hook
    /// @return The amount of tokens repaid
    function release(ReleaseParams memory params) external payable returns (uint256);
}
