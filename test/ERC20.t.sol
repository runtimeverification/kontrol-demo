// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../src/ERC20.sol";
import "kontrol-cheatcodes/KontrolCheats.sol";
import "forge-std/Test.sol";

contract ERC20Test is Test, KontrolCheats {

    uint256 constant MAX_INT = 2**256 - 1;
    bytes32 constant BALANCES_STORAGE_INDEX = 0;
    bytes32 constant ALLOWANCES_STORAGE_INDEX = bytes32(uint256(1));
    bytes32 constant TOTALSUPPLY_STORAGE_INDEX = bytes32(uint256(2));
    address constant DEPLOYED_ERC20 = address(491460923342184218035706888008750043977755113263);
    address constant FOUNDRY_TEST_CONTRACT = address(728815563385977040452943777879061427756277306518);
    address constant FOUNDRY_CHEAT_CODE = address(645326474426547203313410069153905908525362434349);

    ERC20 erc20;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function _notBuiltinAddress(address addr) internal {
        vm.assume( addr != FOUNDRY_CHEAT_CODE);
        vm.assume( addr != FOUNDRY_TEST_CONTRACT);
        vm.assume( addr != DEPLOYED_ERC20);
    }

    function hashedLocation(address _key, bytes32 _index) public pure returns(bytes32) {
        // Returns the index hash of the storage slot of a map at location `index` and the key `_key`.
        // returns `keccak(#buf(32,_key) +Bytes #buf(32, index))
        return keccak256(abi.encode(_key, _index));
    }

    function setUp() public {
        erc20 = new ERC20("Token Example", "TKN");
    }

    modifier symbolic() {
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
      symbolic
      unchangedStorage(storageSlot) {
        //compute the storage location of _balances[addr]
        bytes32 storageLocation = hashedLocation(addr, BALANCES_STORAGE_INDEX);
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
      symbolic
      unchangedStorage(storageSlot) {
        vm.startPrank(address(0));
        vm.expectRevert("ERC20: transfer from the zero address");
        erc20.transfer(to, value);
    }

    function testTransferFailure_1(address from, uint256 value, bytes32 storageSlot)
      public
      symbolic
      unchangedStorage(storageSlot) {
        _notBuiltinAddress(from);
        vm.assume(from != address(0));
        vm.startPrank(address(from));
        vm.expectRevert("ERC20: transfer to the zero address");
        erc20.transfer(address(0), value);
    }

    function testTransferFailure_2(address alice, address bob, uint256 amount, bytes32 storageSlot)
      public
      symbolic
      unchangedStorage(storageSlot) {
        _notBuiltinAddress(alice);
        _notBuiltinAddress(bob);
        vm.assume(alice != address(0));
        vm.assume(bob != address(0));
        vm.assume(erc20.balanceOf(alice) < amount);
        vm.startPrank(alice);
        vm.expectRevert("ERC20: transfer amount exceeds balance");
        erc20.transfer(bob, amount);
    }

    function testTransferSuccess_0(address alice, uint256 amount, bytes32 storageSlot)
      public
      symbolic
      unchangedStorage(storageSlot) {
        _notBuiltinAddress(alice);
        vm.assume(alice != address(0));
        uint256 balanceAlice = erc20.balanceOf(alice);
        vm.assume(balanceAlice >= amount);
        vm.expectEmit(true, true, false, true);
        emit Transfer(alice, alice, amount);
        vm.startPrank(alice);
        erc20.transfer(alice, amount);
        assertEq(erc20.balanceOf(alice), balanceAlice);
    }

    function testTransferSuccess_1(address alice, address bob, uint256 amount, bytes32 storageSlot)
      public
      symbolic
      unchangedStorage(storageSlot)
      {
        _notBuiltinAddress(alice);
        _notBuiltinAddress(bob);
        bytes32 storageLocationAlice = hashedLocation(alice, BALANCES_STORAGE_INDEX);
        bytes32 storageLocationBob = hashedLocation(bob, BALANCES_STORAGE_INDEX);
        //I'm expecting the storage to change for _balances[alice] and _balances[bob]
        vm.assume(storageLocationAlice != storageSlot);
        vm.assume(storageLocationBob != storageSlot);
        vm.assume(alice != address(0));
        vm.assume(bob != address(0));
        vm.assume(alice != bob);
        vm.assume(storageLocationAlice != storageLocationBob);
        uint256 balanceAlice = erc20.balanceOf(alice);
        uint256 balanceBob = erc20.balanceOf(bob);
        vm.assume(balanceAlice >= amount);
        vm.assume(balanceBob <= MAX_INT - amount);
        vm.expectEmit(true, true, false, true);
        emit Transfer(alice, bob, amount);
        vm.startPrank(alice);
        erc20.transfer(bob, amount);
        assertEq(erc20.balanceOf(alice), balanceAlice - amount);
        assertEq(erc20.balanceOf(bob), balanceBob + amount);
    }

    /****************************
    *
    * allowance() mandatory checks.
    *
    ****************************/

    function testAllowance(address owner, address spender, bytes32 storageSlot)
      public
      symbolic
      unchangedStorage(storageSlot) {
        _notBuiltinAddress(owner);
        _notBuiltinAddress(spender);
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
      symbolic
      unchangedStorage(storageSlot) {
        _notBuiltinAddress(spender);
        vm.startPrank(address(0));
        vm.expectRevert("ERC20: approve from the zero address");
        erc20.approve(spender, amount);
    }

    function testApproveFailure_1(address owner, uint256 amount, bytes32 storageSlot)
      public
      symbolic
      unchangedStorage(storageSlot) {
        _notBuiltinAddress(owner);
        vm.assume(owner != address(0));
        vm.startPrank(owner);
        vm.expectRevert("ERC20: approve to the zero address");
        erc20.approve(address(0), amount);
    }

    function testApproveSuccess(address owner, address spender, uint256 amount, bytes32 storageSlot)
      public
      symbolic
      unchangedStorage(storageSlot) {
        _notBuiltinAddress(owner);
        _notBuiltinAddress(spender);

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
      symbolic
      unchangedStorage(storageSlot) {
        _notBuiltinAddress(spender);
        _notBuiltinAddress(owner);
        _notBuiltinAddress(alice);
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
      symbolic
      unchangedStorage(storageSlot) {
        _notBuiltinAddress(spender);
        _notBuiltinAddress(owner);
        _notBuiltinAddress(alice);
        vm.assume(spender != address(0));
        vm.assume(owner != address(0));
        vm.assume(alice != address(0));
        bytes32 storageLocationOwner = hashedLocation(owner, BALANCES_STORAGE_INDEX);
        bytes32 storageLocationAlice = hashedLocation(alice, BALANCES_STORAGE_INDEX);
        bytes32 storageLocationAllowance = hashedLocation(spender, hashedLocation(owner, ALLOWANCES_STORAGE_INDEX));
        vm.assume(storageSlot != storageLocationOwner);
        vm.assume(storageSlot != storageLocationAlice);
        vm.assume(storageLocationAllowance != storageLocationOwner);
        vm.assume(storageLocationAllowance != storageLocationAlice);
        vm.assume(erc20.allowance(owner, spender) == MAX_INT);
        vm.assume(erc20.balanceOf(owner) >= amount);
        vm.startPrank(spender);
        erc20.transferFrom(owner, alice, amount);
        assertEq(erc20.allowance(owner, spender), MAX_INT);
      }

    function testTransferFromSuccess_1(address spender, address owner, address alice, uint256 amount, bytes32 storageSlot)
      public
      symbolic
      unchangedStorage(storageSlot) {
        _notBuiltinAddress(spender);
        _notBuiltinAddress(owner);
        _notBuiltinAddress(alice);
        vm.assume(spender != address(0));
        vm.assume(owner != address(0));
        vm.assume(alice != address(0));
        bytes32 storageLocationOwner = hashedLocation(owner, BALANCES_STORAGE_INDEX);
        bytes32 storageLocationAlice = hashedLocation(alice, BALANCES_STORAGE_INDEX);
        bytes32 storageLocationAllowance = hashedLocation(spender, hashedLocation(owner, ALLOWANCES_STORAGE_INDEX));
        vm.assume(storageSlot != storageLocationOwner);
        vm.assume(storageSlot != storageLocationAlice);
        vm.assume(storageSlot != storageLocationAllowance);
        vm.assume(storageLocationAllowance != storageLocationOwner);
        vm.assume(storageLocationAllowance != storageLocationAlice);
        vm.assume(erc20.allowance(owner, spender) != MAX_INT);
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

