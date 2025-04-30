// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {KontrolCheats} from "kontrol-cheatcodes/KontrolCheats.sol";
import {TopToken} from "../src/TopToken.sol";

contract TopTokenTest is Test, KontrolCheats {
    TopToken public token;
    address public owner;
    address public victim;
    address public recipient;
    uint256 user_supply;

    function setUp() public {
        owner = address(100);
        victim = address(101);
        recipient = address(102);
        user_supply = 100 * 10 ** 18;
        // impersonare Owner
        vm.startPrank(owner);
        token = new TopToken();

        token.transfer(victim, user_supply);

        vm.stopPrank();
    }

    function test_transfer(uint256 amount) public {
        vm.assume(amount <= user_supply);
        assertEq(token.balanceOf(victim), user_supply);

        // impersonare user normal
        vm.startPrank(victim);
        bool success = token.transfer(recipient, amount);
        vm.stopPrank();
        assertTrue(success);
        assertEq(token.balanceOf(victim), user_supply - amount);
        assertEq(token.balanceOf(recipient), amount);
    }

    function test_symbolic_storage_transfer(uint256 amount) public {
        vm.assume(amount <= user_supply);

        kevm.symbolicStorage(address(token));

        assertEq(token.balanceOf(victim), user_supply);

        // impersonare user normal
        vm.startPrank(victim);
        bool success = token.transfer(recipient, amount);
        vm.stopPrank();
        assertTrue(success);
        assertEq(token.balanceOf(victim), user_supply - amount);
        assertEq(token.balanceOf(recipient), amount);
    }

}
