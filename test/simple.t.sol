// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

contract Examples is Test {
    uint256 constant MAX_INT = (2 ** 256) - 1;
    uint constant WAD = 10 ** 18;

    function wmul(uint x, uint y) internal pure returns (uint z) {
        z = (x * y) / WAD;
    }

    function wdiv(uint x, uint y) internal pure returns (uint z) {
        z = (x * WAD) / y;
    }

    function test_assert_bool_failing(bool b) public {
        assert(b);
    }

    function test_assert_bool_passing(bool b) public {
        if (b) {
            assert(b);
        }
    }

    function test_wmul_increasing_overflow(uint a, uint b) public {
        uint c = wmul(a, b);
        assertTrue(a < c && b < c);
    }
    // { true #Equals ( ( 115792089237316195423570985008687907853269984665640564039457584007913129639935 /Int VV0_a_3c5818c8 ) ) <Int VV1_b_3c5818c8 }
    // { true #Equals ( ( maxUInt256 /Int VV0_a_3c5818c8 ) ) <Int VV1_b_3c5818c8 }

    function test_wmul_increasing(uint a, uint b) public {
        if (b <= MAX_INT / a) {
            uint c = wmul(a, b);
            assertTrue(a < c && b < c);
        }
    }
    // { true #Equals VV0_a_3c5818c8 ==K 0 }

    function test_wmul_increasing_positive(uint a, uint b) public {
        if (0 < a && 0 < b) {
            if (b <= MAX_INT / a) {
                uint c = wmul(a, b);
                assertTrue(a < c && b < c);
            }
        }
    }
    // { true #Equals ( ( ( ( VV0_a_3c5818c8 *Int VV1_b_3c5818c8 ) ) /Int 1000000000000000000 ) ) <=Int VV0_a_3c5818c8 }

    function test_wmul_increasing_gt_one(uint a, uint b) public {
        if (WAD < a && WAD < b) {
            if (b <= MAX_INT / a) {
                uint c = wmul(a, b);
                assertTrue(a < c && b < c);
            }
        }
    }
    // #Top

    function test_wmul_wdiv_inverse_underflow(uint a, uint b) public {
        if (0 < a && 0 < b) {
            if (b <= MAX_INT / a) {
                uint c = wdiv(wmul(a, b), b);
                assertEq(a, c);
            }
        }
    }
    // { true #Equals maxUInt256 /Word ( ( ( ( VV0_a_3c5818c8 *Int VV1_b_3c5818c8 ) ) /Int 1000000000000000000 ) ) <Int 1000000000000000000 }

    function test_wmul_wdiv_inverse(uint a, uint b) public {
        if (WAD < a && WAD < b) {
            if (b <= MAX_INT / a) {
                uint c = wdiv(wmul(a, b), b);
                assertEq(a, c);
            }
        }
    }
}

