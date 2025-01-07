// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.13;

import "forge-std/Test.sol";

contract ArithmeticTest is Test {
    // This test requires a lemma:
    function test_xor(uint256 a, uint256 b) external {
        vm.assume(a == b);
        uint256 res = a ^ b;
        assertEq(res, 0);
    }
}