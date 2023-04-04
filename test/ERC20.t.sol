// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../src/ERC20.sol";
import "../src/utils/KEVMCheats.sol";
import "forge-std/Test.sol";

contract ERC20Test is Test, KEVMCheats {

    bytes32 constant BALANCES_STORAGE_INDEX = 0;
    bytes32 constant ALLOWANCES_STORAGE_INDEX = bytes32(uint256(1));
    bytes32 constant TOTALSUPPLY_STORAGE_INDEX = bytes32(uint256(2));
    ERC20 erc20;

    function hashedLocation(address _key, bytes32 _index) public pure returns(bytes32) {
        // Returns the index hash of the storage slot of a map at location `index` and the key `_key`.
        // returns `keccak(#buf(32,_key) +Bytes #buf(32, index))
        return keccak256(abi.encode(_key, _index));
    }

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    modifier initializer() {
        erc20 = new ERC20("Token Example", "TKN");
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
    * decimals() mandatory checks.
    *
    ****************************/

    function testDecimals(bytes32 storageSlot)
      public
      initializer
      symbolic
      unchangedStorage(storageSlot) {
        assertEq(erc20.decimals(), 18);
    }

    /****************************
    *
    * name() and symbol() mandatory checks.
    *
    ****************************/

    function testNameAndSymbol(bytes32 storageSlot)
      public
      initializer
      unchangedStorage(storageSlot) {
        assertEq(erc20.symbol(), "TKN");
        assertEq(erc20.name(), "Token Example");
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
        uint256 storageValue = uint256(vm.load(address(erc20), TOTALSUPPLY_STORAGE_INDEX));
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
        bytes32 storageLocation = hashedLocation(addr, BALANCES_STORAGE_INDEX); //compute the storage location of _balances[addr]
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

    function testTransferSuccess_0(address alice, uint256 amount, bytes32 storageSlot)
      public
      initializer
      symbolic
      unchangedStorage(storageSlot) {
        vm.assume(alice != address(0));
        uint256 balanceA = erc20.balanceOf(alice);
        vm.assume(balanceA >= amount);
        vm.expectEmit(true, true, false, true);
        emit Transfer(alice, alice, amount);
        vm.startPrank(alice);
        erc20.transfer(alice, amount);
        assertEq(erc20.balanceOf(alice), balanceA);
    }

    function testTransferSuccess_1(address alice, address bob, uint256 amount)//, bytes32 storageSlot)
      public
      initializer
      symbolic
      //unchangedStorage(storageSlot)
      {
        //bytes32 storageLocationA = hashedLocation(alice, BALANCES_STORAGE_INDEX);
        //bytes32 storageLocationB = hashedLocation(bob, BALANCES_STORAGE_INDEX);
        //I'm expecting the storage to change for _balances[alice] and _balances[bob]
        //vm.assume(storageLocationA != storageSlot);
        //vm.assume(storageLocationB != storageSlot);
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

    function testAllowance(address owner, address spender, bytes32 storageSlot)
      public
      initializer
      symbolic
      unchangedStorage(storageSlot) {
        bytes32 storageLocation = hashedLocation(spender, hashedLocation(owner, ALLOWANCES_STORAGE_INDEX));
        uint256 allowance = erc20.allowance(owner, spender);
        uint256 storageValue = uint256(vm.load(address(erc20), storageLocation));
        assertEq(allowance, storageValue);
    }

    /****************************
    *
    * approve() mandatory checks.
    *
    ****************************/

    function testApproveFailure_0(address spender, uint256 amount, bytes32 storageSlot)
      public
      initializer
      symbolic
      unchangedStorage(storageSlot) {
        vm.startPrank(address(0));
        vm.expectRevert("ERC20: approve from the zero address");
        erc20.approve(spender, amount);
    }

    function testApproveFailure_1(address owner, uint256 amount, bytes32 storageSlot)
      public
      initializer
      symbolic
      unchangedStorage(storageSlot) {
        vm.assume(owner != address(0));
        vm.startPrank(owner);
        vm.expectRevert("ERC20: approve to the zero address");
        erc20.approve(address(0), amount);
    }

    function testApproveSuccess(address owner, address spender, uint256 amount, bytes32 storageSlot)
      public
      initializer
      symbolic
      unchangedStorage(storageSlot) {
        vm.assume(owner != address(0));
        vm.assume(spender != address(0));
        bytes32 storageLocation = hashedLocation(spender, hashedLocation(owner, ALLOWANCES_STORAGE_INDEX));
        vm.assume(storageSlot != storageLocation);
        vm.startPrank(owner);
        vm.expectEmit(true, true, false, true);
        emit Approval(owner, spender, amount); 
        erc20.approve(spender, amount);
        assertEq(erc20.allowance(owner, spender), amount);
      }

    /****************************
    *
    * transferFrom() mandatory checks.
    *
    ****************************/

    function testTransferFromFailure(address spender, address owner, address alice, uint256 amount, bytes32 storageSlot)
      public
      initializer
      symbolic
      unchangedStorage(storageSlot) {
        vm.assume(spender != address(0));
        vm.assume(owner != address(0));
        vm.assume(alice != address(0));
        vm.assume(erc20.allowance(owner, spender) < amount);
        vm.startPrank(spender);
        vm.expectRevert("ERC20: insufficient allowance");
        erc20.transferFrom(owner, alice, amount);
      }

    function testTransferFromSuccess_0(address spender, address owner, address alice, uint256 amount, bytes32 storageSlot)
      public
      initializer
      symbolic
      unchangedStorage(storageSlot) {
        vm.assume(spender != address(0));
        vm.assume(owner != address(0));
        vm.assume(alice != address(0));
        bytes32 storageLocationO = hashedLocation(owner, BALANCES_STORAGE_INDEX);
        bytes32 storageLocationA = hashedLocation(alice, BALANCES_STORAGE_INDEX);
        vm.assume(storageSlot != storageLocationO);
        vm.assume(storageSlot != storageLocationA);
        vm.assume(erc20.allowance(owner, spender) == type(uint256).max);
        vm.assume(erc20.balanceOf(owner) >= amount);
        vm.startPrank(spender);
        erc20.transferFrom(owner, alice, amount);
      }

    function testTransferFromSuccess_1(address spender, address owner, address alice, uint256 amount, bytes32 storageSlot)
      public
      initializer
      symbolic
      unchangedStorage(storageSlot) {
        vm.assume(spender != address(0));
        vm.assume(owner != address(0));
        vm.assume(alice != address(0));
        bytes32 storageLocationO = hashedLocation(owner, BALANCES_STORAGE_INDEX);
        bytes32 storageLocationA = hashedLocation(alice, BALANCES_STORAGE_INDEX);
        bytes32 storageLocationAllowance = hashedLocation(spender, hashedLocation(owner, ALLOWANCES_STORAGE_INDEX));
        vm.assume(storageSlot != storageLocationO);
        vm.assume(storageSlot != storageLocationA);
        vm.assume(storageSlot != storageLocationAllowance);
        vm.assume(erc20.allowance(owner, spender) != type(uint256).max);
        vm.assume(erc20.allowance(owner, spender) >= amount);
        vm.assume(erc20.balanceOf(owner) >= amount);
        uint256 allowance = erc20.allowance(owner, spender);
        vm.startPrank(spender);
        erc20.transferFrom(owner, alice, amount);
        assertEq(erc20.allowance(owner,spender), allowance - amount);
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
    //     bytes32 storageLocationBalanceA = hashedLocation(alice, BALANCES_STORAGE_INDEX);
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
    //     bytes32 storageLocationBalanceA = hashedLocation(alice, BALANCES_STORAGE_INDEX);
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

