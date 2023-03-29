// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../src/ERC20.sol";
import "../src/utils/KEVMCheats.sol";
import "forge-std/Test.sol";

contract ERC20Test is Test, KEVMCheats {

    uint8 constant BALANCES_STORAGE_INDEX = 0;
    uint256 constant ALLOWANCES_STORAGE_INDEX = 1;
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
        kevm.infiniteGas();
        ERC20 erc20 = new ERC20("Bucharest Workshop Token", "BWT");
        kevm.symbolicStorage(address(erc20));
        vm.store(address(erc20), bytes32(TOTALSUPPLY_STORAGE_INDEX), bytes32(amount));
        uint256 totalSupply = erc20.totalSupply();
        assertEq(totalSupply, amount);
    }

    /****************************
    *
    * balanceOf()
    *
    ****************************/

    function testBalanceOf(address addr, uint256 amount, bytes32 storageSlot) public {
        kevm.infiniteGas();
        ERC20 erc20 = new ERC20("Bucharest Workshop Token", "BWT");
        kevm.symbolicStorage(address(erc20));
        bytes32 storageLocation = getStorageLocationForKey(addr, BALANCES_STORAGE_INDEX); //compute the storage location of _balances[addr]
        vm.store(address(erc20), storageLocation, bytes32(amount));
        bytes32 initialStorage = vm.load(address(erc20), storageSlot);
        uint256 balance = erc20.balanceOf(addr);
        bytes32 finalStorage = vm.load(address(erc20), storageSlot);
        assertEq(balance, amount);
        assertEq(initialStorage, finalStorage);
    }

    /****************************
    *
    * transfer() mandatory checks.
    *
    ****************************/

    function testTransferFailure_0(address to, uint256 value) public {
        kevm.infiniteGas();
        ERC20 erc20 = new ERC20("Bucharest Workshop Token", "BWT");
        kevm.symbolicStorage(address(erc20));
        vm.startPrank(address(0));
        vm.expectRevert("ERC20: transfer from the zero address");
        erc20.transfer(to, value);
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
        ERC20 erc20 = new ERC20("Bucharest Workshop Token", "BWT");
        kevm.symbolicStorage(address(erc20));
        vm.assume(erc20.balanceOf(alice) < amount);
        vm.startPrank(alice);
        vm.expectRevert("ERC20: transfer amount exceeds balance");
        erc20.transfer(bob, amount);
    }

    function testTransferSuccess_1(address alice, uint256 amount, uint256 balanceA) public {
        kevm.infiniteGas();
        vm.assume(alice != address(0));
        vm.assume(amount <= balanceA);
        ERC20 erc20 = new ERC20("Bucharest Workshop Token", "BWT");
        kevm.symbolicStorage(address(erc20));
        vm.assume(erc20.balanceOf(alice) == balanceA);
        vm.startPrank(alice);
        erc20.transfer(alice, amount);
        assert(erc20.balanceOf(alice) == balanceA);
    }

    function testTransferSuccess_2(address alice, address bob, uint256 amount, uint256 balanceA, uint256 balanceB) public {
        kevm.infiniteGas();
        vm.assume(alice != address(0));
        vm.assume(bob != address(0));
        vm.assume(alice != bob);
        vm.assume(amount <= balanceA);
        ERC20 erc20 = new ERC20("Bucharest Workshop Token", "BWT");
        kevm.symbolicStorage(address(erc20));
        vm.assume(erc20.balanceOf(alice) == balanceA);
        vm.assume(erc20.balanceOf(bob) == balanceB);
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

    function testAllowance(address alice, address bob, uint256 amount) public {
        kevm.infiniteGas();
        ERC20 erc20 = new ERC20("Bucharest Workshop Token", "BWT");
        kevm.symbolicStorage(address(erc20));
        bytes32 storageLocation = keccak256(abi.encode(alice, bob, ALLOWANCES_STORAGE_INDEX));
        vm.store(address(erc20), storageLocation, bytes32(amount));
        uint256 allowance = erc20.allowance(alice, bob);
        assertEq(allowance, amount);
    }
}

