// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

interface IReserveModule {
    function freezeUserLiquidityETH(address _user, uint256 _amountETH)
        external
        returns (
            address[] memory newFrozenAssets_,
            uint256[] memory newFrozenAmounts_,
            uint256[] memory newFrozenRates_,
            uint256 assetsNumber_
        );

    function getAssetValueETH(address _reserve, uint256 _amount)
        external
        returns (
            uint256 amount_,
            uint256 price_,
            uint8 decimals_
        );

    function getUserAvailableBalance(address _reserve, address _user)
        external
        view
        returns (uint256 availableBalance_);
}
