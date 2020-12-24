// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

interface IZTokenCore {
    function availableBalanceOf(address _user) external view returns (uint256);
}
