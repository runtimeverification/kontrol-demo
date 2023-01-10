// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

contract Examples is Test {
    uint256 constant MAX_INT = (2 ** 256) - 1;
    uint constant WAD = 10 ** 18;

    function wmul(uint x, uint y) internal pure returns (uint z) {
        z = (x * y) / WAD;
    }

    function test_assert_bool_failing(bool b) public {
        assert(b);
    }

    function test_assert_bool_passing(bool b) public {
        if (b) {
            assert(b);
        }
    }

    function test_wmul_strictly_increasing(uint a, uint b) public {
        if (b <= MAX_INT / a) {
            uint c = wmul(a, b);
            assertTrue(a < c && b < c);
        }
    }

    function test_wmul_increasing(uint a, uint b) public {
        if (0 < a && 0 < b) {
            if (b <= MAX_INT / a) {
                uint c = wmul(a, b);
                assertTrue(a < c && b < c);
            }
        }
    }

    function test_wmul_increasing_2(uint a, uint b) public {
        if (WAD <= a && WAD <= b) {
            if (b <= MAX_INT / a) {
                uint c = wmul(a, b);
                assertTrue(a < c && b < c);
            }
        }
    }
}

