// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./utils/IERC20.sol";

contract ExclusiveToken {
    address immutable owner;
    mapping(address => uint256) public balanceOf;

    constructor() {
        owner = msg.sender;
    }

    function mint(address user, uint256 amount) external {
        require(msg.sender == owner, "Only owner can mint");

        /* Address taken from https://etherscan.io/token/0xbc6da0fe9ad5f3b0d58160288917aa56653660e9 */
        address alUSD        = 0xBC6DA0FE9aD5f3b0d58160288917AA56653660E9;
        uint256 alUSDBalance = IERC20(alUSD).balanceOf(user);
        bool hasAlUSD        = 0 < alUSDBalance;

        require(hasAlUSD, "User doesn't hold alUSD");

        balanceOf[user] += amount;
    }

    function transfer(address to, uint amount) external {
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
    }

    // Other functions...
}
