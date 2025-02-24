// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {PoolId} from "v4-core/types/PoolId.sol";

/// @notice A margin position is a position that is open on a pool.
struct MarginPosition {
    /// @notice The pool ID of the pool on which the position is open.
    PoolId poolId;
    /// @notice true: currency1 is marginToken, false: currency0 is marginToken
    bool marginForOne;
    /// @notice marginAmount1 + ... + marginAmountN
    uint128 marginAmount;
    /// @notice marginTotal1 + ... + marginTotalN
    uint128 marginTotal;
    /// @notice The borrow amount of the margin position including interest.
    uint128 borrowAmount;
    /// @notice The raw amount of borrowed tokens.
    uint128 rawBorrowAmount;
    /// @notice Last cumulative interest was accrued.
    uint256 rateCumulativeLast;
}

/// @notice A margin position with PnL.
struct MarginPositionVo {
    /// @notice The margin position.
    MarginPosition position;
    /// @notice The PnL of the position.
    int256 pnl;
}

/// @notice The parameters for burning margin positions.
struct BurnParams {
    /// @notice The pool ID of the pool on which the position is open.
    PoolId poolId;
    /// @notice true: currency1 is marginToken, false: currency0 is marginToken
    bool marginForOne;
    /// @notice The ids of the positions to be burned.
    uint256[] positionIds;
    /// @notice The signatures of the operator.
    bytes signature;
}
