// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../src/ERC20.sol";
import "forge-std/Test.sol";

contract ERC20Test is Test {

    ERC20 erc20 = new ERC20("Bucharest Hackaton Token", "BHT");

    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    /****************************
    *
    * transfer() mandatory checks.
    *
    ****************************/

    /// @notice Property test: A successful transfer of 0 amount MUST emit the Transfer event.
    function testZeroTransferPossible(address alice, address bob) 
    public {
        vm.expectEmit(true, true, true, true);
        emit Transfer(alice, bob, 0);
        vm.startPrank(alice);
        bool result = erc20.transfer(bob, 0);
        vm.stopPrank();
        assertTrue(result);
    }

    /// @notice Property test: A successful transfer of positive amount MUST emit the Transfer event.
    function testPositiveTransferEventEmission(address alice, address bob, uint256 amount, uint256 balance1, uint256 balance2) 
    public initializeStateTwoUsers(balance1, balance2, alice, bob) {

        vm.assume(amount > 0);
        vm.assume(amount <= erc20.balanceOf(alice));
        vm.expectEmit(true, true, true, true);
        emit Transfer(alice, bob, amount);
        vm.startPrank(alice);
        bool result = erc20.transfer(bob, 0);
        vm.stopPrank();
        assertTrue(result);
    }

    /// @notice Parameterized initialization of the balances of two dummy users, 
    modifier initializeStateTwoUsers(uint256 balance1, uint256 balance2, address alice, address bob) 
    {
        vm.assume(balance1 <= type(uint256).max - balance2);
        vm.assume(erc20.totalSupply() <= type(uint256).max - balance1 - balance2);
        // Give balance1 tokens to Alice
        deal(address(erc20), alice, balance1, false);
        // Give balance2 tokens to Bob
        deal(address(erc20), bob, balance2, false);
        _;
    }
}
