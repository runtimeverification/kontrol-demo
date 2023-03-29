// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../src/ERC20.sol";
import "../src/utils/KEVMCheats.sol";
import "forge-std/Test.sol";

contract ERC20Test is Test, KEVMCheats {

    uint8 constant BALANCES_STORAGE_INDEX = 0;
    uint256 constant ALLOWANCES_STORAGE_INDEX = 1;
    uint256 constant TOTALSUPPLY_STORAGE_INDEX = 2;
    ERC20 erc20;

    function getStorageLocationForKey(address _key, uint8 _index) public pure returns(bytes32) {
        // Returns the index hash of the storage slot of a map at location `index` and the key `_key`.
        // returns `keccak(#buf(32,_key) +Bytes #buf(32, index))
        return keccak256(abi.encode(_key, _index));
    }

    event Transfer(address indexed from, address indexed to, uint256 value);

    modifier initializer() {
        erc20 = new ERC20("Bucharest Workshop Token", "BWT");
        _;

    }
    modifier symbolic(bytes32 storageSlot) {
        kevm.infiniteGas();
        kevm.symbolicStorage(address(erc20));
        bytes32 initialStorage = vm.load(address(erc20), storageSlot);
        _;
        bytes32 finalStorage = vm.load(address(erc20), storageSlot);
        assertEq(initialStorage, finalStorage);
    }

    /****************************
    *
    * name() mandatory checks.
    *
    ****************************/

    function testName(bytes32 storageSlot)
      public
      initializer
      symbolic(storageSlot) {
        string memory returnedName = erc20.name();
        assertEq(returnedName, "Bucharest Workshop Token");
    }

    /****************************
    *
    * symbol() mandatory checks.
    *
    ****************************/

    function testSymbol(bytes32 storageSlot)
      public
      initializer
      symbolic(storageSlot) {
        string memory returnedSymbol = erc20.symbol();
        assertEq(returnedSymbol, "BWT");
    }

    /****************************
    *
    * totalSupply()
    *
    ****************************/

    function testTotalSupply(bytes32 storageSlot)
      public
      initializer
      symbolic(storageSlot) {
        uint256 totalSupply = erc20.totalSupply();
        uint256 storageValue = uint256(vm.load(address(erc20), bytes32(TOTALSUPPLY_STORAGE_INDEX)));
        assertEq(totalSupply, storageValue);
    }

    /****************************
    *
    * balanceOf()
    *
    ****************************/

    function testBalanceOf(address addr, bytes32 storageSlot)
      public
      initializer
      symbolic(storageSlot) {
        bytes32 storageLocation = getStorageLocationForKey(addr, BALANCES_STORAGE_INDEX); //compute the storage location of _balances[addr]
        uint256 balance = erc20.balanceOf(addr);
        uint256 storageValue = uint256(vm.load(address(erc20), storageLocation));
        assertEq(balance, storageValue);
    }

    /****************************
    *
    * transfer() mandatory checks.
    *
    ****************************/

    function testTransferFailure_0(address to, uint256 value, bytes32 storageSlot)
      public
      initializer
      symbolic(storageSlot) {
        vm.startPrank(address(0));
        vm.expectRevert("ERC20: transfer from the zero address");
        erc20.transfer(to, value);
    }

    function testTransferFailure_1(uint256 value, bytes32 storageSlot)
      public
      initializer
      symbolic(storageSlot) {
        vm.expectRevert("ERC20: transfer to the zero address");
        erc20.transfer(address(0), value);
    }

    function testTransferFailure_2(address alice, address bob, uint256 amount, bytes32 storageSlot)
      public
      initializer
      symbolic(storageSlot) {
        vm.assume(alice != address(0));
        vm.assume(bob != address(0));
        vm.assume(erc20.balanceOf(alice) < amount);
        vm.startPrank(alice);
        vm.expectRevert("ERC20: transfer amount exceeds balance");
        erc20.transfer(bob, amount);
    }

    function testTransferSuccess_1(address alice, uint256 amount, bytes32 storageSlot)
      public
      initializer
      symbolic(storageSlot) {
        vm.assume(alice != address(0));
        uint256 balanceA = erc20.balanceOf(alice);
        vm.assume(balanceA >= amount);
        vm.expectEmit(true, true, false, true);
        emit Transfer(alice, alice, amount);
        vm.startPrank(alice);
        erc20.transfer(alice, amount);
        assert(erc20.balanceOf(alice) == balanceA);
    }

    function testTransferSuccess_2(address alice, address bob, uint256 amount, bytes32 storageSlot)
      public
      initializer
      symbolic(storageSlot) {
        bytes32 storageLocationA = getStorageLocationForKey(alice, BALANCES_STORAGE_INDEX);
        bytes32 storageLocationB = getStorageLocationForKey(bob, BALANCES_STORAGE_INDEX);
        //I'm expecting the storage to change for _balances[alice] and _balances[bob]
        vm.assume(storageLocationA != storageSlot);
        vm.assume(storageLocationB != storageSlot);

        vm.assume(alice != address(0));
        vm.assume(bob != address(0));
        vm.assume(alice != bob);
        uint256 balanceA = erc20.balanceOf(alice);
        uint256 balanceB = erc20.balanceOf(bob);
        vm.assume(balanceA >= amount);
        vm.expectEmit(true, true, false, true);
        emit Transfer(alice, bob, amount);
        vm.startPrank(alice);
        erc20.transfer(bob, amount);
        assert(erc20.balanceOf(alice) == balanceA - amount);
        assert(erc20.balanceOf(bob) == balanceB + amount);
    }

    /****************************
    *
    * allowance() mandatory checks.
    *
    ****************************/

    function testAllowance(address alice, address bob, bytes32 storageSlot)
      public
      initializer
      symbolic(storageSlot) {
        bytes32 storageLocation = keccak256(abi.encode(bob, keccak256(abi.encode(alice, ALLOWANCES_STORAGE_INDEX))));
        uint256 allowance = erc20.allowance(alice, bob);
        uint256 storageValue = uint256(vm.load(address(erc20), storageLocation));
        assertEq(allowance, storageValue);
    }
}

