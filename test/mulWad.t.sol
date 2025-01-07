pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";

/// @author Modified from Solady (https://github.com/vectorized/solady/blob/main/src/utils/FixedPointMathLib.sol)
/// @author Modified from Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/FixedPointMathLib.sol)
contract MulWadTest is Test {
    /// @dev The scalar of ETH and most ERC20s.
    uint256 internal constant WAD = 1e18;

    /// @dev Equivalent to `(x * y) / WAD` rounded down.
    // `mulWad` modified for illustration purposes
    function modified_mulWad(uint256 x, uint256 y) public pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            if or(mul(y, gt(x, div(not(0), y))), eq(x, 0xfffffffffff)) {
                mstore(0x00, 0xbac65e5b) // `MulWadFailed()`.
                revert(0x1c, 0x04)
            }
            z := div(mul(x, y), WAD)
        }
    }

    /// @dev Equivalent to `(x * y) / WAD` rounded down.
    function mulWad(uint256 x, uint256 y) public pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            if mul(y, gt(x, div(not(0), y))) {
                mstore(0x00, 0xbac65e5b) // `MulWadFailed()`.
                revert(0x1c, 0x04)
            }
            z := div(mul(x, y), WAD)
        }
    }

    function test_mulWad(uint256 x, uint256 y) public {
        if (y == 0 || x <= type(uint256).max / y) {
            uint256 zSpec = (x * y) / WAD;
            uint256 zImpl = mulWad(x, y);
            assert(zImpl == zSpec);
        } else {
            vm.expectRevert();
            this.mulWad(x, y);
        }
    }
}