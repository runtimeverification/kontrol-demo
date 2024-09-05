// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {KontrolCheats} from "kontrol-cheatcodes/KontrolCheats.sol";
import {TestToken} from "../src/TestToken.sol";

contract TestTokenTest is Test, KontrolCheats {
    TestToken public token;

    /*
    Should be executed with `kontrol prove --run-constructor`:
    string tokenName = "TestToken";
    */

    function _notBuiltinOrPrecompiledAddress(address addr) internal view {
        vm.assume(addr != address(vm));
        vm.assume(addr != address(this));
        vm.assume(addr != address(token));
        vm.assume(uint256(uint160(addr)) == 0 || 9 < uint256(uint160(addr)));
    }

    function setUp() public {
        uint8 decimals = freshUInt8();
        token = new TestToken("TestToken", "TT", decimals);
    }

    function test_approve(address from, address to, uint256 amount) public {
        // Overwrite the storage of the token contract with symbolic storage
        kevm.symbolicStorage(address(token));

        vm.assume(from != address(0));
        vm.assume(to != address(0));
        _notBuiltinOrPrecompiledAddress(from);
        _notBuiltinOrPrecompiledAddress(to);

        vm.prank(from);
        token.approve(to, amount);

        uint256 toAllowance = token.allowance(from, to);
        assert(toAllowance == amount);
    }

    function test_pause(address from) public {
        vm.assume(from != address(0));
        _notBuiltinOrPrecompiledAddress(from);

        /*
        https://book.getfoundry.sh/cheatcodes/expect-revert:
        After calling expectRevert, calls to other cheatcodes before the reverting call are ignored.
        This means, for example, we can call prank immediately before the reverting call.
        */
        vm.prank(from);
        vm.expectRevert();
        token.pause();
    }

    function test_transfer(address from, address to, uint256 amount) public {
        // Overwrite the storage of the token contract with symbolic storage
        kevm.symbolicStorage(address(token));

        _notBuiltinOrPrecompiledAddress(from);
        _notBuiltinOrPrecompiledAddress(to);

        // `from` and `to` are different, non-zero addresses
        vm.assume(from != to);
        /* 
            This would cause branching:
            vm.assume(from != address(0) && to != address(0));
        */
        vm.assume(from != address(0));
        vm.assume(to != address(0));
        
        // `from` has enough tokens
        vm.assume(amount <= token.balanceOf(from));
        // no overflow occurs on transfer
        unchecked {
            vm.assume(token.balanceOf(to) <= token.balanceOf(to) + amount);
            // vm.assume(token.balanceOf(to) + amount <= 2**256 - 1);
        }

        uint256 prev_from = token.balanceOf(from);
        uint256 prev_to   = token.balanceOf(to);

        vm.prank(from);
        token.transfer(to, amount);

        assertEq(token.balanceOf(from), prev_from - amount);
        assertEq(token.balanceOf(to),   prev_to   + amount);
    }

function test_transfer_revertOnOverflow(address from, address to, uint256 amount) public {
        // Overwrite the storage of the token contract with symbolic storage
        kevm.symbolicStorage(address(token));

        // Avoding vacuous nodes
        vm.assume(from != address(0));
        vm.assume(to != address(0));

        _notBuiltinOrPrecompiledAddress(from);
        _notBuiltinOrPrecompiledAddress(to);

        // `from` and `to` are different, non-zero addresses
        vm.assume(from != to);
        
        // `from` has enough tokens
        vm.assume(amount <= token.balanceOf(from));
        // no overflow occurs on transfer
        // not wrapped in `unchecked`:
        // unchecked {
            vm.assume(token.balanceOf(to) <= token.balanceOf(to) + amount);
            // vm.assume(token.balanceOf(to) + amount <= 2**256 - 1);
        // }

        uint256 prev_from = token.balanceOf(from);
        uint256 prev_to   = token.balanceOf(to);

        vm.prank(from);
        token.transfer(to, amount);

        assertEq(token.balanceOf(from), prev_from - amount);
        assertEq(token.balanceOf(to),   prev_to   + amount);
    }
}