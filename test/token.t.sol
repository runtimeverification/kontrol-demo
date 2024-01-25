// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/token.sol";

contract TokenTest is Test {
    Token token; // Contract under test

    address Alice;
    address Bob;
    address Eve;

    function setUp() public {
        token = new Token();
        Alice = makeAddr("Alice");
        Bob = makeAddr("Bob");
        Eve = makeAddr("Eve");
        token.mint(Alice, 10 ether);
        token.mint(Bob, 20 ether);
        token.mint(Eve, 30 ether);
    }

    function testTransfer(address from, address to, uint256 amount) public {
        // This proof has a high number of branches when executed with kontrol due to the 
        // fact that both `from` and `to` args could be each of the following addresses 
        // (Alice, Bob, Eve, address(this), address(vm), address(token)).

        // The first four `vm.assume` calls allow the symbolic arguments `from` and `to` to
        // take values that have been initialized in the token storage with a valid balance.

        // This is a toy example to show how branchings and constraints work.

        vm.assume(from == Alice || from == Bob || from == Eve);
        vm.assume(to == Alice || to == Bob || to == Eve);
        vm.assume(from != address(this) && from != address(vm) && from != address(token));
        vm.assume(to != address(this) && to != address(vm) && to != address(token));
        vm.assume(to != from);

        vm.assume(token.balanceOf(from) >= amount);

        uint256 preBalanceFrom = token.balanceOf(from);
        uint256 preBalanceTo = token.balanceOf(to);

        vm.prank(from);
        token.transfer(to, amount);

        if(from == to) {
            assertEq(token.balanceOf(from), preBalanceFrom);
            assertEq(token.balanceOf(to), preBalanceTo);
        } else {
            assertEq(token.balanceOf(from), preBalanceFrom - amount);
            assertEq(token.balanceOf(to), preBalanceTo + amount);
        }
    }
}
