// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../src/ERC20.sol";
import "../src/utils/KEVMCheats.sol";
import "forge-std/Test.sol";

contract ERC20Test is Test, KEVMCheats {

    uint8 constant BALANCES_STORAGE_INDEX = 0;
    uint256 constant TOTALSUPPLY_STORAGE_INDEX = 2;
    
    function getStorageLocationForKey(address _key, uint8 _index) public pure returns(bytes32) {
        // Returns the index hash of the storage slot of a map at location `index` and the key `_key`.
        // returns `keccak(#buf(32,_key) +Bytes #buf(32, index))
        return keccak256(abi.encode(_key, _index));
    }

    event Transfer(address indexed from, address indexed to, uint256 value);

    /****************************
    *
    * name() mandatory checks.
    *
    ****************************/

    function testName() public {
        ERC20 erc20 = new ERC20("Bucharest Workshop Token", "BWT");
        string memory returnedName = erc20.name();
        assertEq(returnedName, "Bucharest Workshop Token");
    }

    /****************************
    *
    * symbol() mandatory checks.
    *
    ****************************/

    function testSymbol() public {
        ERC20 erc20 = new ERC20("Bucharest Workshop Token", "BWT");
        string memory returnedSymbol = erc20.symbol();
        assertEq(returnedSymbol, "BWT");
    }

    /****************************
    *
    * totalSupply()
    *
    ****************************/

    function testTotalSupply(uint256 amount) public {
        //kevm.infiniteGas();
        ERC20 erc20 = new ERC20("Bucharest Workshop Token", "BWT");
        //kevm.symbolicStorage(address(erc20));
        bytes32 storageValue = vm.load(address(erc20), bytes32(TOTALSUPPLY_STORAGE_INDEX));
        vm.assume(uint256(storageValue) == amount);
        uint256 totalSupply = erc20.totalSupply();
        assertEq(totalSupply, amount);
    }

    /****************************
    *
    * balanceOf()
    *
    ****************************/

    function testBalanceOf(address addr, uint256 amount) public {
        kevm.infiniteGas();
        ERC20 erc20 = new ERC20("Bucharest Workshop Token", "BWT");
        kevm.symbolicStorage(address(erc20));
        bytes32 storageLocation = getStorageLocationForKey(addr, BALANCES_STORAGE_INDEX);
        vm.assume(uint256(vm.load(address(erc20), storageLocation)) == amount);
        uint256 balance = erc20.balanceOf(addr);
        assertEq(balance, amount);
    }

    /****************************
    *
    * transfer() mandatory checks.
    *
    ****************************/

    function testTransferFailure_0(address from, uint256 value) public {
        kevm.infiniteGas();
        ERC20 erc20 = new ERC20("Bucharest Workshop Token", "BWT");
        kevm.symbolicStorage(address(erc20));
        vm.startPrank(address(0));
        vm.expectRevert("ERC20: transfer from the zero address");
        erc20.transfer(from, value);
    }

    function testTransferFailure_1(uint256 value) public {
        kevm.infiniteGas();
        ERC20 erc20 = new ERC20("Bucharest Workshop Token", "BWT");
        kevm.symbolicStorage(address(erc20));
        vm.expectRevert("ERC20: transfer to the zero address");
        erc20.transfer(address(0), value);
    }

    function testTransferFailure_2(address alice, address bob, uint256 amount) public {
        kevm.infiniteGas();
        vm.assume(alice != address(0));
        vm.assume(bob != address(0));
        bytes32 storageIndexA = getStorageLocationForKey(alice, BALANCES_STORAGE_INDEX);
        ERC20 erc20 = new ERC20("Bucharest Workshop Token", "BWT");
        kevm.symbolicStorage(address(erc20));
        vm.assume(uint256(vm.load(address(erc20), storageIndexA)) < amount);
        vm.startPrank(alice);
        vm.expectRevert("ERC20: transfer amount exceeds balance");
        erc20.transfer(bob, amount);
    }

    function testTransferSuccess() public {
        address alice = address (1231231231);
        address bob = address(23111111);
        uint256 amount = 200;
        uint256 balanceA = 400;
        uint256 balanceB = 400;
        bytes32 storageIndexA = getStorageLocationForKey(alice, BALANCES_STORAGE_INDEX);
        bytes32 storageIndexB = getStorageLocationForKey(bob  , BALANCES_STORAGE_INDEX);
        ERC20 erc20 = new ERC20("Bucharest Workshop Token", "BWT");
        vm.assume(uint256(vm.load(address(erc20), storageIndexA)) == balanceA);
        vm.assume(uint256(vm.load(address(erc20), storageIndexB)) == balanceB);
        vm.startPrank(address(alice));
        erc20.transfer(bob, amount);
        assert(uint256(vm.load(address(erc20), storageIndexA)) == balanceA - amount);
        assert(uint256(vm.load(address(erc20), storageIndexB)) == balanceB + amount);
    }

    // function testTransferSuccess(address alice, address bob, uint256 balanceA, uint256 balanceB, uint256 amount) public {
    //     bytes32 storageIndexA = getStorageLocationForKey(alice, BALANCES_STORAGE_INDEX);
    //     bytes32 storageIndexB = getStorageLocationForKey(bob  , BALANCES_STORAGE_INDEX);
    //     ERC20 erc20 = new ERC20("Bucharest Workshop Token", "BWT");
    //     vm.assume(uint256(vm.load(address(erc20), storageIndexA)) == balanceA);
    //     vm.assume(uint256(vm.load(address(erc20), storageIndexB)) == balanceB);
    //     vm.assume(amount <= balanceA);
    //     vm.assume(alice != address(0));
    //     vm.assume(bob != address(0));
    //     vm.startPrank(address(alice));
    //     erc20.transfer(alice, amount);
    //     assert(uint256(vm.load(address(erc20), storageIndexA)) == balanceA - amount);
    //     assert(uint256(vm.load(address(erc20), storageIndexB)) == balanceB + amount);
    // }

}

