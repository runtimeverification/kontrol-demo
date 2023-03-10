// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../src/ERC20.sol";
import "../src/utils/KEVMCheats.sol";
import "forge-std/Test.sol";

contract ERC20Test is Test, KEVMCheats {

    ERC20 erc20 = new ERC20("Bucharest Hackathon Token", "BHT");
    address alice = address(12314);
    address bob = address(123423514);

    event Transfer(address indexed from, address indexed to, uint256 value);

    /****************************
    *
    * transfer() mandatory checks.
    *
    ****************************/

    /// @notice Property test: A successful transfer of 0 amount MUST emit the Transfer event.
    function testZeroTransferPossible()
    public {
        //kevm.infiniteGas(); // uncomment this for KEVM-Foundry
        vm.expectEmit(true, true, true, true);
        emit Transfer(alice, bob, 0);
        vm.startPrank(alice);
        bool result = erc20.transfer(bob, 0);
        vm.stopPrank();
        assertTrue(result);
    }

    /// @notice Property test: A successful transfer of positive amount MUST emit the Transfer event.
    function testPositiveTransferEventEmission(uint256 amount, uint256 balance1, uint256 balance2) 
    public initializeStateTwoUsers(balance1, balance2, alice, bob){
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

