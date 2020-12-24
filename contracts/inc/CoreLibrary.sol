// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

import "@openzeppelin/contracts-upgradeable/math/SafeMathUpgradeable.sol";

library CoreLibrary {
    using SafeMathUpgradeable for uint256;

    struct UserReserveData {
        uint256 freezeAmount;
        uint256 blockedAmount;
        uint256 userCurrentLiquidityIndex;
        uint40 lastUpdateTimestamp;
        bool collateralEnabled;
        bool collateralChanged;
    }

    struct ReserveData {
        uint256 lastLiquidityIndex;
        uint256 currentLiquidityIndex;
        uint256 totalLoans;
        uint256 decimals;
        address zTokenAddress;
        uint40 lastUpdateTimestamp;
        bool loanEnabled;
        bool collateralEnabled;
        bool isActive;
        bool isFreezed;
    }

    function init(
        ReserveData storage _self,
        address _zTokenAddress,
        uint256 _decimals
    ) external {
        require(
            _self.zTokenAddress == address(0),
            "Reserve has already been initialized"
        );

        _self.zTokenAddress = _zTokenAddress;
        _self.decimals = _decimals;
        _self.isActive = true;
        _self.isFreezed = false;
        _self.collateralEnabled = true;
    }
}
