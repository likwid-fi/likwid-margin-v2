// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.26;

import {IERC6909Claims} from "v4-core/interfaces/external/IERC6909Claims.sol";
import {PoolId} from "v4-core/types/PoolId.sol";

interface IMarginLiquidity is IERC6909Claims {
    function mint(address receiver, uint256 id, uint256 amount) external;

    function burn(address sender, uint256 id, uint256 amount) external;

    function mintFee(address feeTo, uint256 _kLast, uint256 uPoolId, uint256 _reserve0, uint256 _reserve1)
        external
        returns (bool feeOn);

    function addLiquidity(address receiver, uint256 id, uint8 level, uint256 amount) external;

    function removeLiquidity(address sender, uint256 id, uint8 level, uint256 amount) external;

    function getPoolId(PoolId poolId) external pure returns (uint256 uPoolId);

    function getLevelPool(uint256 uPoolId, uint8 level) external pure returns (uint256 lPoolId);

    function getSupplies(uint256 uPoolId)
        external
        view
        returns (uint256 totalSupply, uint256 retainSupply0, uint256 retainSupply1);

    function getPoolSupplies(address hook, PoolId poolId)
        external
        view
        returns (uint256 totalSupply, uint256 retainSupply0, uint256 retainSupply1);
}
