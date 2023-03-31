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
    event Approval(address indexed owner, address indexed spender, uint256 value);

    modifier initializer() {
        erc20 = new ERC20("Bucharest Workshop Token", "BWT");
        _;
    }

    modifier symbolic() {
        kevm.infiniteGas();
        kevm.symbolicStorage(address(erc20));
        _;
    }

    modifier unchangedStorage(bytes32 storageSlot) {
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

    function testNameAndSymbol(bytes32 storageSlot)
      public
      initializer
      unchangedStorage(storageSlot) {
        assertEq(erc20.symbol(), "BWT");
        assertEq(erc20.name(), "Bucharest Workshop Token");
    }

    /****************************
    *
    * totalSupply()
    *
    ****************************/

    function testTotalSupply(bytes32 storageSlot)
      public
      initializer
      symbolic
      unchangedStorage(storageSlot) {
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
      symbolic
      unchangedStorage(storageSlot) {
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
      symbolic
      unchangedStorage(storageSlot) {
        vm.startPrank(address(0));
        vm.expectRevert("ERC20: transfer from the zero address");
        erc20.transfer(to, value);
    }

    function testTransferFailure_1(address from, uint256 value, bytes32 storageSlot)
      public
      initializer
      symbolic
      unchangedStorage(storageSlot) {
        vm.assume(from != address(0));
        vm.startPrank(address(from));
        vm.expectRevert("ERC20: transfer to the zero address");
        erc20.transfer(address(0), value);
    }

    function testTransferFailure_2(address alice, address bob, uint256 amount, bytes32 storageSlot)
      public
      initializer
      symbolic
      unchangedStorage(storageSlot) {
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
      symbolic
      //unchangedStorage(storageSlot)
      {
        vm.assume(alice != address(0));
        uint256 balanceA = erc20.balanceOf(alice);
        vm.assume(balanceA >= amount);
        vm.expectEmit(true, true, false, true);
        emit Transfer(alice, alice, amount);
        vm.startPrank(alice);
        erc20.transfer(alice, amount);
        assertEq(erc20.balanceOf(alice), balanceA);
    }

    function testTransferSuccess_2(address alice, address bob, uint256 amount, bytes32 storageSlot)
      public
      initializer
      symbolic
      //unchangedStorage(storageSlot)
      {
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
        assertEq(erc20.balanceOf(alice), balanceA - amount);
        assertEq(erc20.balanceOf(bob), balanceB + amount);
    }

    /****************************
    *
    * allowance() mandatory checks.
    *
    ****************************/

    function testAllowance(address alice, address bob, bytes32 storageSlot)
      public
      initializer
      symbolic
      unchangedStorage(storageSlot) {
        bytes32 storageLocation = keccak256(abi.encode(bob, keccak256(abi.encode(alice, ALLOWANCES_STORAGE_INDEX))));
        uint256 allowance = erc20.allowance(alice, bob);
        uint256 storageValue = uint256(vm.load(address(erc20), storageLocation));
        assertEq(allowance, storageValue);
    }

    /****************************
    *
    * approve() mandatory checks.
    *
    ****************************/

    function testApproveFailure_0(address spender, uint256 value, bytes32 storageSlot)
      public
      initializer
      symbolic
      unchangedStorage(storageSlot) {
        vm.startPrank(address(0));
        vm.expectRevert("ERC20: approve from the zero address");
        erc20.approve(spender, value);
    }

    function testApproveFailure_1(address owner, uint256 value, bytes32 storageSlot)
      public
      initializer
      symbolic
      unchangedStorage(storageSlot) {
        vm.assume(owner != address(0));
        vm.startPrank(owner);
        vm.expectRevert("ERC20: approve to the zero address");
        erc20.approve(address(0), value);
    }

    function testApproveSuccess(address owner, address spender, uint256 value, bytes32 storageSlot)
      public
      initializer
      symbolic
      unchangedStorage(storageSlot)
      {
        vm.assume(owner != address(0));
        vm.assume(spender != address(0));
        bytes32 storageLocation = keccak256(abi.encode(spender, keccak256(abi.encode(owner, ALLOWANCES_STORAGE_INDEX))));
        vm.assume(storageSlot != storageLocation);
        vm.startPrank(owner);
        vm.expectEmit(true, true, false, true);
        emit Approval(owner, spender, value); 
        erc20.approve(spender, value);
        assertEq(erc20.allowance(owner, spender), value);
      }

    // tests for _mint and _burn.
    // not compiling because both _mint and _burn declared as `internal`.
    /****************************
    *
    * mint()
    *
    ****************************/

    // function testMintFailure(uint256 amount, bytes32 storageSlot)
    //   public
    //   initializer
    //   symbolic
    //   unchangedStorage(storageSlot)
    //   {
    //     vm.startPrank(address(erc20));
    //     vm.expectRevert("ERC20: mint to the zero address");
    //     erc20._mint(address(0), amount);
    //   }

    // function testMintSuccess(address alice, uint256 amount, bytes32 storageSlot)
    //   public
    //   initializer
    //   symbolic
    //   unchangedStorage(storageSlot) {
    //     vm.assume(alice != address(0));
    //     bytes32 storageLocationBalanceA = getStorageLocationForKey(alice, BALANCES_STORAGE_INDEX);
    //     vm.assume(storageSlot != storageLocationBalanceA);
    //     vm.assume(storageSlot != TOTALSUPPLY_STORAGE_INDEX);
    //     uint256 totalSupply = erc20.totalSupply();
    //     uint256 balanceA = erc20.balanceOf(alice);
    //     vm.startPrank(address(erc20));
    //     vm.expectEmit(true, true, false, true);
    //     emit Transfer(address(0), alice, amount);
    //     erc20._mint(alice, amount);
    //     assertEq(erc20.totalSupply(), totalSupply + amount);
    //     assertEq(erc20.balanceOf(alice), balanceA + amount);
    //   }

    /****************************
    *
    * burn()
    *
    ****************************/

    // function testBurnFailure_0(uint256 amount, bytes32 storageSlot)
    //   public
    //   initializer
    //   symbolic
    //   unchangedStorage(storageSlot)
    //   {
    //     vm.startPrank(address(erc20));
    //     vm.expectRevert("ERC20: burn from the zero address");
    //     erc20._burn(address(0), amount);
    //   }

    // function testBurnFailure_1(address alice, uint256 amount, bytes32 storageSlot)
    //   public
    //   initializer
    //   symbolic
    //   unchangedStorage(storageSlot)
    //   {
    //     vm.assume(alice != address(0));
    //     vm.assume(erc20.balanceOf(alice) < amount);
    //     vm.startPrank(address(erc20));
    //     vm.expectRevert("ERC20: burn amount exceeds balance");
    //     erc20._burn(alice, amount);
    //   }

    // function testBurnSuccess(address alice, uint256 amount, bytes32 storageSlot)
    //   public
    //   initializer
    //   symbolic
    //   unchangedStorage(storageSlot)
    //   {
    //     vm.assume(alice != address(0));
    //     bytes32 storageLocationBalanceA = getStorageLocationForKey(alice, BALANCES_STORAGE_INDEX);
    //     vm.assume(storageSlot != storageLocationBalanceA);
    //     vm.assume(storageSlot != TOTALSUPPLY_STORAGE_INDEX);
    //     uint256 totalSupply = erc20.totalSupply();
    //     uint256 balanceA = erc20.balanceOf(alice);
    //     vm.assume(balanceA >= amount);
    //     vm.startPrank(address(erc20));
    //     vm.expectEmit(true, true, false, true);
    //     emit Transfer(alice, address(0), amount);
    //     erc20._burn(alice, amount);
    //     assertEq(erc20.totalSupply, totalSupply - amount);
    //     assertEq(erc20.balanceOf, balanceA - amount);
    //   }
}

