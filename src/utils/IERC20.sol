// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

/// Incomplete IERC20 interface
interface IERC20 {

    //mapping(address => uint256) public balanceOf;
    function balanceOf (address account) external returns (uint256);

}
