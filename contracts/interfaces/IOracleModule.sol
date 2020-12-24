// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

interface IOracleModule {
    function getPrice(address _reserve)
        external
        returns (uint256 price_, uint8 decimals_);
}
