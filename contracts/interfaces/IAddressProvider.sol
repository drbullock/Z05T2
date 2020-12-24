// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

interface IAddressProvider {
    function getAddress(bytes32 _key) external view returns (address);
}
