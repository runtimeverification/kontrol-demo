// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../src/ERC20.sol";
import "../src/utils/KEVMCheats.sol";
import "forge-std/Test.sol";

contract ERC20Test is Test, KEVMCheats {

    address alice = address(12314);
    address bob = address(123423514);

    event Transfer(address indexed from, address indexed to, uint256 value);

    /****************************
    *
    * name() mandatory checks.
    *
    ****************************/

    function testName() public {
        ERC20 erc20 = new ERC20("Bucharest Hackathon Token", "BHT");
        string memory returnedName = erc20.name();
        assertEq(returnedName, "Bucharest Hackathon Token");
    }

    /****************************
    *
    * symbol() mandatory checks.
    *
    ****************************/

    function testSymbol() public {
        ERC20 erc20 = new ERC20("Bucharest Hackathon Token", "BHT");
        string memory returnedSymbol = erc20.symbol();
        assertEq(returnedSymbol, "BHT");
    }

    /****************************
    *
    * transfer() mandatory checks.
    *
    ****************************/

    /// @notice Property test: A successful transfer of 0 amount MUST emit the Transfer event.
    function testZeroTransferPossible() public {
        ERC20 erc20 = new ERC20("Bucharest Hackathon Token", "BHT");
        // kevm.symbolicStorage(address(erc20));
        kevm.infiniteGas();
        vm.expectEmit(true, true, true, true);
        emit Transfer(alice, bob, 0);
        vm.startPrank(alice);
        bool result = erc20.transfer(bob, 0);
        vm.stopPrank();
        assertTrue(result);
    }
}

