// SPDX-License-Identifier: MIT
// Adapted from https://github.com/ethereum-optimism/optimism

pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "kontrol-cheatcodes/KontrolCheats.sol";

import "../src/Portal.sol";

contract PortalTest is Test, KontrolCheats {
    Portal portalContract;

    function setUp() public {
        portalContract = new Portal();
    }

    // Anyone can call donateETH successfully 
    function test_donateETH(address sender, uint256 tokens) external
    {
        vm.assume(sender != address(this));
        vm.assume(sender != address(vm));
        vm.assume(sender != address(portalContract));

        vm.prank(sender);

        portalContract.donateETH{value: tokens}();
    }

    function test_donateETH(uint256 tokens, uint256 balance) external
    {
        address sender = kevm.freshAddress();       
        vm.assume(sender != address(portalContract)); 

        vm.deal(sender, balance);
        vm.prank(sender);
        portalContract.donateETH{value: tokens}();
    }

    function test_donateETH_successful(uint256 tokens, uint256 balance) external
    {
        address sender = kevm.freshAddress();       
        vm.assume(sender != address(portalContract)); 

        vm.deal(sender, balance);
        vm.assume(balance >= tokens);
        vm.prank(sender);
        portalContract.donateETH{value: tokens}();
    }

    /// @custom:kontrol-array-length-equals _withdrawalProof: 2,
    /// @custom:kontrol-bytes-length-equals _withdrawalProof: 32,
    /// @custom:kontrol-bytes-length-equals data: 32,
    function test_withdrawalPaused(
        Types.WithdrawalTransaction calldata _tx,
        uint256 _l2OutputIndex,
        Types.OutputRootProof calldata _outputRootProof,
        bytes[] calldata _withdrawalProof
    )
        external
    {
        portalContract.pause();

        vm.expectRevert();
        portalContract.proveWithdrawalTransaction(_tx, _l2OutputIndex, _outputRootProof, _withdrawalProof);
    }

    /// @custom:kontrol-array-length-equals _withdrawalProof: 2,
    /// @custom:kontrol-bytes-length-equals _withdrawalProof: 32,
    /// @custom:kontrol-bytes-length-equals data: 32,
    function test_withdrawal(
        Types.WithdrawalTransaction calldata _tx,
        uint256 _l2OutputIndex,
        Types.OutputRootProof calldata _outputRootProof,
        bytes[] calldata _withdrawalProof
    )
        external
    {
        kevm.symbolicStorage(address(portalContract));

        if (portalContract.paused())
            vm.expectRevert();

        portalContract.proveWithdrawalTransaction(_tx, _l2OutputIndex, _outputRootProof, _withdrawalProof);
    }
}



