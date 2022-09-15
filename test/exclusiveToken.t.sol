// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/exclusiveToken.sol";

contract ExclusiveTokenTest is Test {
    ExclusiveToken token; // Contract under test

    address Alice = makeAddr("Alice");
    address Bob = makeAddr("Bob");
    address Eve = makeAddr("Eve");

    function setUp() public {
        token = new ExclusiveToken();
    }

    function testMint(address user, uint256 amount) public {

        /* Address taken from https://etherscan.io/token/0xbc6da0fe9ad5f3b0d58160288917aa56653660e9 */
        address alUSD        = 0xBC6DA0FE9aD5f3b0d58160288917AA56653660E9;
        uint256 alUSDBalance = IERC20(alUSD).balanceOf(user);
        bool hasAlUSD        = 0 < alUSDBalance;

        uint256 preBalanceUser = token.balanceOf(user);

        if(hasAlUSD) {
            token.mint(user, amount);
            assertEq(token.balanceOf(user), preBalanceUser + amount);
        } else {
            vm.expectRevert("User doesn't hold alUSD");
            token.mint(user, amount);
            assertEq(token.balanceOf(user), preBalanceUser);
        }

        /* Check that the zero address has some DAI */
        /* Address taken from https://etherscan.io/token/0x6b175474e89094c44da98b954eedeac495271d0f */
        assertLt(0, IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F).balanceOf(address(0)));
    }
}
