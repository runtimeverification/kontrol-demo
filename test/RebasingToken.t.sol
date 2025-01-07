pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";

contract RebasingTokenTest is Test {
    function test_balanceToRebasingCredits(uint256 rebasingCreditsPerToken, uint256 balance) public {
        vm.assume(rebasingCreditsPerToken <= 1e27 && rebasingCreditsPerToken >= 1e18);
        vm.assume(balance <= 1e25);

        uint256 rebasingCredits = ((balance) * rebasingCreditsPerToken + 1e18 - 1) / 1e18;
        uint256 actualBalance = (rebasingCredits * 1e18) / rebasingCreditsPerToken;
        assert(actualBalance == balance);
    }

    function test_balanceToRebasingCredits_reverts(uint256 rebasingCreditsPerToken, uint256 balance) public {
        vm.assume(rebasingCreditsPerToken <= 1e27); // && rebasingCreditsPerToken >= 1e18);
        vm.assume(balance <= 1e25);

        uint256 rebasingCredits = ((balance) * rebasingCreditsPerToken + 1e18 - 1) / 1e18;
        uint256 actualBalance = (rebasingCredits * 1e18) / rebasingCreditsPerToken;
        assert(actualBalance == balance);
    }
}