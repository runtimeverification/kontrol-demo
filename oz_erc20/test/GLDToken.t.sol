// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {GLDToken} from "../../../src/GLDToken.sol";
import {KontrolCheats} from "kontrol-cheatcodes/KontrolCheats.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC20Errors} from "@openzeppelin/contracts/interfaces/draft-IERC6093.sol";

contract GLDTokenTest is Test, KontrolCheats {
    GLDToken public gld;

    address constant DEPLOYED_ERC20 = address(491460923342184218035706888008750043977755113263);
    address constant FOUNDRY_TEST_CONTRACT = address(728815563385977040452943777879061427756277306518);
    address constant FOUNDRY_CHEAT_CODE = address(645326474426547203313410069153905908525362434349);

    uint256 constant BALANCES_STORAGE_INDEX = uint256(0);
    uint256 constant ALLOWANCES_STORAGE_INDEX = uint256(1);
    uint256 constant TOTAL_SUPPLY_STORAGE_INDEX = uint256(2);
    uint256 constant SUMOFALLBALANCES_STORAGE_INDEX = uint256(5);

    uint256 constant MAX_INT = 2 ** 256 - 1;

    /*
    Besides deploying the ERC20 contract, the setUp() function uses `kevm.symbolicStorage` cheat code to make
    storage of the contract abstract. This way, we assume that the contract could be in any possible state.
    Finally, with `vm.assume(gld.sumOfAllBalances() == gld.totalSupply)` we start with the precondition that
    the total supply is equal to the sum of all balances.
    */
    function setUp() public {
        gld = new GLDToken();
        kevm.symbolicStorage(address(gld));
        vm.assume(gld.sumOfAllBalances() == gld.totalSupply());
    }

    /*
    The _notBuiltinAddress is an optional function that is used only to trim redundant branches of symbolic
    execution.
    */
    function _notBuiltinAddress(address addr) internal pure {
        vm.assume(addr != FOUNDRY_CHEAT_CODE);
        vm.assume(addr != FOUNDRY_TEST_CONTRACT);
        vm.assume(addr != DEPLOYED_ERC20);
    }

    /*
    hashedLocation(account, storageSlot) is used to compute the storage location at which a mapping element
    is in the storage (i.e. _balances[0x000000000000000000000000000000000000001F])
    */
    function hashedLocation(address key, uint256 storageSlot) public pure returns (bytes32) {
        return keccak256(abi.encode(key, bytes32(storageSlot)));
    }

    /*
    This modifier asserts that for any given storage location storageSlot, the function that is executed
    does not modify the value at location storageSlot.
    */
    modifier unchangedStorage(bytes32 storageSlot) {
        bytes32 initialStorage = vm.load(address(gld), storageSlot);
        _;
        bytes32 finalStorage = vm.load(address(gld), storageSlot);
        assertEq(initialStorage, finalStorage);
    }

    /*
    Modifier used to check that the invariant holds through the execution of functions.
    It is not applied to functions that already have the `unchangedStorage` modifier.
    */
    modifier totalSupplyIsSumOfAllBalances() {
        _;
        assertEq(gld.totalSupply(), gld.sumOfAllBalances());
    }

    /*
     ∀ value, 0 <= value < pow256, the `gld.mint(address(0), value)` function shall revert.
     ∀ storageSlot, the storage does not change.
    */
    function testMintFailure(uint256 value, bytes32 storageSlot) public unchangedStorage(storageSlot) {
        vm.expectRevert(abi.encodeWithSelector(IERC20Errors.ERC20InvalidReceiver.selector, address(0)));
        gld.mint(address(0), value);
    }

    /*
      `kevm.symbolicStorage(account, storageSlot)` is enabling the whitelist storage feature.
      Only storage writes on that specific storageSlot in the specified accounts are enabled.
      The proof will revert if storage slots outside the whitelist are modified.
       ∀ value, ∀ account, account != 0, we expect the mint function to modify the following storage slots:
        - totalSupply - slot 2, 
        - sumOfAllBalances - slot 5,
        - _balances[account] - slot keccak256(abi.encode(account, bytes32(0)))
      The execution then splits on two branches, on the condition that totalSupply + value <= pow256 - 1.
      On one branch, we expect the function to go through, and update the fields accordingly.
      On the other branch, we expect the function to revert.
    */
    function testMintSuccess(address account, uint256 value) public totalSupplyIsSumOfAllBalances {
        vm.assume(account != address(0));
        kevm.allowChangesToStorage(address(gld), TOTAL_SUPPLY_STORAGE_INDEX);
        kevm.allowChangesToStorage(address(gld), SUMOFALLBALANCES_STORAGE_INDEX);
        bytes32 storageLocation = hashedLocation(account, BALANCES_STORAGE_INDEX);
        kevm.allowChangesToStorage(address(gld), uint256(storageLocation));
        uint256 balance = gld.balanceOf(account);
        uint256 totalSupply = gld.totalSupply();
        if (totalSupply <= MAX_INT - value) {
            // The ERC20._update internal function only has an overflow check for totalSupply
            // Assuming that balance does not overflow such that the proof can pass
            vm.assume(balance <= MAX_INT - value);
            vm.expectEmit(true, true, false, true);
            emit IERC20.Transfer(address(0), account, value);
            gld.mint(account, value);
            assertEq(gld.balanceOf(account), balance + value);
            assertEq(gld.totalSupply(), totalSupply + value);
        } else {
            vm.expectRevert();
            gld.mint(account, value);
            assertEq(gld.balanceOf(account), balance);
            assertEq(gld.totalSupply(), totalSupply);
        }
    }

    /* The testBurn proof is similar to the previous one. One difference is in the structure of the proof.
    The cases in which the account is/ is not equal to address(0) are put together in the same proof.
    The symbolic execution will branch on the if statements, exploring both cases.
    */
    function testBurn(address account, uint256 value) public totalSupplyIsSumOfAllBalances {
        kevm.allowChangesToStorage(address(gld), TOTAL_SUPPLY_STORAGE_INDEX);
        kevm.allowChangesToStorage(address(gld), SUMOFALLBALANCES_STORAGE_INDEX);
        bytes32 storageLocation = hashedLocation(account, BALANCES_STORAGE_INDEX);
        kevm.allowChangesToStorage(address(gld), uint256(storageLocation));
        uint256 initialBalance = gld.balanceOf(account);
        uint256 initialTotalSupply = gld.totalSupply();
        if (account == address(0)) {
            vm.expectRevert(abi.encodeWithSelector(IERC20Errors.ERC20InvalidSender.selector, address(0)));
            gld.burn(address(0), value);
            assertEq(gld.balanceOf(account), initialBalance);
            assertEq(gld.totalSupply(), initialTotalSupply);
        } else {
            if (value <= initialTotalSupply) {
                vm.assume(value <= initialBalance);
                vm.expectEmit(true, true, false, true);
                emit IERC20.Transfer(account, address(0), value);
                gld.burn(account, value);
                assertEq(gld.balanceOf(account), initialBalance - value);
                assertEq(gld.totalSupply(), initialTotalSupply - value);
            } else {
                vm.expectRevert();
                gld.burn(account, value);
                assertEq(gld.balanceOf(account), initialBalance);
                assertEq(gld.totalSupply(), initialTotalSupply);
            }
        }
    }

    /* transfer proofs */

    /* ∀ to, ∀ value, the transfer(to, value) will revert if the sender is address(0).
    The storage remains unchaged.
    */
    function testTransferFailure_0(address to, uint256 value, bytes32 storageSlot)
        public
        unchangedStorage(storageSlot)
    {
        vm.startPrank(address(0));
        vm.expectRevert(abi.encodeWithSelector(IERC20Errors.ERC20InvalidSender.selector, address(0)));
        gld.transfer(to, value);
    }

    /* ∀ from, ∀ value, the transfer(address(0), value) will revert for any msg.sender `from`.
    The storage remains unchanged.
    */
    function testTransferFailure_1(address from, uint256 value, bytes32 storageSlot)
        public
        unchangedStorage(storageSlot)
    {
        _notBuiltinAddress(from);
        vm.assume(from != address(0));
        vm.startPrank(address(from));
        vm.expectRevert(abi.encodeWithSelector(IERC20Errors.ERC20InvalidReceiver.selector, address(0)));
        gld.transfer(address(0), value);
    }

    /* ∀ alice, ∀ bob, ∀ amount, where alice != 0, bob != 0 and _balances[alice] < amount, the
    transfer(bob, value) call will revert for any msg.sender `alice`.
    The storage remains unchanged.
    */
    function testTransferFailure_2(address alice, address bob, uint256 amount, bytes32 storageSlot)
        public
        unchangedStorage(storageSlot)
    {
        _notBuiltinAddress(alice);
        _notBuiltinAddress(bob);
        vm.assume(alice != address(0));
        vm.assume(bob != address(0));
        uint256 balanceAlice = gld.balanceOf(alice);
        vm.assume(balanceAlice < amount);
        vm.startPrank(alice);
        vm.expectRevert(
            abi.encodeWithSelector(IERC20Errors.ERC20InsufficientBalance.selector, alice, gld.balanceOf(alice), amount)
        );
        gld.transfer(bob, amount);
    }

    /* ∀ alice, ∀ amount, where alice != 0, and _balances[alice] >= amount, the
    transfer(alice, value) call will succeed for any msg.sender `alice`.
    The storage remains unchanged.
    */
    function testTransferSuccess_0(address alice, uint256 amount, bytes32 storageSlot)
        public
        unchangedStorage(storageSlot)
    {
        _notBuiltinAddress(alice);
        vm.assume(alice != address(0));
        uint256 balanceAlice = gld.balanceOf(alice);
        vm.assume(balanceAlice >= amount);
        vm.expectEmit(true, true, false, true);
        emit IERC20.Transfer(alice, alice, amount);
        vm.prank(alice);
        bool status = gld.transfer(alice, amount);
        assertTrue(status);
    }

    /* ∀ alice, ∀ amount, where alice != 0, and _balances[alice] >= amount, the
    transfer(bob, value) call will succeed for any msg.sender `alice`.
    The function will modify the following storage slots:
        - _balances[alice] - slot keccak256(abi.encode(alice, bytes32(0))),
        - _balances[bob] - slot keccak256(abi.encode(bob, bytes32(0)))
    The function explores both cases in which the receiver balance could or could not overflow.
    Finally, the totalSupplyIsSumOfAllBalances modifier is checked.
    */
    function testTransferSuccess_1(address alice, address bob, uint256 amount) public totalSupplyIsSumOfAllBalances {
        _notBuiltinAddress(alice);
        _notBuiltinAddress(bob);
        vm.assume(alice != bob);
        vm.assume(alice != address(0));
        vm.assume(bob != address(0));
        bytes32 balanceOfAliceStorageLocation = hashedLocation(alice, BALANCES_STORAGE_INDEX);
        bytes32 balanceOfBobStorageLocation = hashedLocation(bob, BALANCES_STORAGE_INDEX);
        kevm.allowChangesToStorage(address(gld), uint256(balanceOfAliceStorageLocation));
        kevm.allowChangesToStorage(address(gld), uint256(balanceOfBobStorageLocation));
        uint256 balanceAlice = gld.balanceOf(alice);
        uint256 balanceBob = gld.balanceOf(bob);
        vm.assume(balanceAlice >= amount);
        vm.assume(balanceBob <= MAX_INT - amount);
        if (balanceBob <= MAX_INT - amount) {
            vm.expectEmit(true, true, false, true);
            emit IERC20.Transfer(alice, bob, amount);
            vm.prank(alice);
            bool status = gld.transfer(bob, amount);
            assertTrue(status);
            assertEq(gld.balanceOf(alice), balanceAlice - amount);
            assertEq(gld.balanceOf(bob), balanceBob + amount);
        } else {
            vm.expectRevert();
            vm.prank(alice);
            gld.transfer(bob, amount);
        }
    }

    /* ∀ spender, ∀ value, the approve(spender, value) call will revert when the msg.sender is address(0).
    The storage remains unchanged.
    */
    function testApproveFailure_0(address spender, uint256 value, bytes32 storageSlot)
        public
        unchangedStorage(storageSlot)
    {
        vm.startPrank(address(0));
        vm.expectRevert(abi.encodeWithSelector(IERC20Errors.ERC20InvalidApprover.selector, address(0)));
        gld.approve(spender, value);
    }

    /* ∀ owner, ∀ value, the approve(address(0), value) call will revert for any msg.sender `owner`.
    The storage remains unchanged.
    */
    function testApproveFailure_1(address owner, uint256 value, bytes32 storageSlot)
        public
        unchangedStorage(storageSlot)
    {
        _notBuiltinAddress(owner);
        vm.assume(owner != address(0));
        vm.startPrank(owner);
        vm.expectRevert(abi.encodeWithSelector(IERC20Errors.ERC20InvalidSpender.selector, address(0)));
        gld.approve(address(0), value);
    }

    /* ∀ owner, ∀ spender, ∀ amount, where owner != 0 and spender != 0, the approve(spender, value) call
    succeed for any msg.sender `owner`.
    The function will modify the following storage slots:
        - _allowances[owner][spender] = slot keccak256(abi.encode(spender, keccak256(abi.encode(owner, bytes32(1)))))
    The function explores both cases in which the receiver balance could or could not overflow.
    Finally, the totalSupplyIsSumOfAllBalances modifier is checked, but this is not requires as the whitelist storage
    guarantees that both the totalSupply and the _balances fields remain unchanged.
    */
    function testApproveSuccess(address owner, address spender, uint256 value) public totalSupplyIsSumOfAllBalances {
        _notBuiltinAddress(owner);
        _notBuiltinAddress(spender);
        vm.assume(owner != address(0));
        vm.assume(spender != address(0));
        bytes32 storageLocation = hashedLocation(spender, uint256(hashedLocation(owner, ALLOWANCES_STORAGE_INDEX)));
        kevm.allowChangesToStorage(address(gld), uint256(storageLocation));
        vm.startPrank(owner);
        vm.expectEmit(true, true, false, true);
        emit IERC20.Approval(owner, spender, value);
        bool status = gld.approve(spender, value);
        assertTrue(status);
        assertEq(gld.allowance(owner, spender), value);
    }

    /* transferFrom proofs.
       The transfer logic has already been detailed above. The following proofs only reason about the
       allowance.
    */

    /* ∀ spender, ∀ owner, ∀ alice, ∀ amount, where alice, owner and spender != address(0),
    the transferFrom(spender, alice, amount) call will revert for any msg.sender `owner` when
    the currentAllowance = _allowances[owner][spender] is less than the amount to be sent.
    The storage remains unchanged.
    */
    function testTransferFromFailure(address spender, address owner, address alice, uint256 amount, bytes32 storageSlot)
        public
        unchangedStorage(storageSlot)
    {
        _notBuiltinAddress(spender);
        _notBuiltinAddress(owner);
        _notBuiltinAddress(alice);
        vm.assume(spender != address(0));
        vm.assume(owner != address(0));
        vm.assume(alice != address(0));
        uint256 currentAllowance = gld.allowance(owner, spender);
        vm.assume(currentAllowance < amount);
        vm.startPrank(spender);
        vm.expectRevert(
            abi.encodeWithSelector(IERC20Errors.ERC20InsufficientAllowance.selector, spender, currentAllowance, amount)
        );
        gld.transferFrom(owner, alice, amount);
    }

    /* ∀ spender, ∀ owner, ∀ alice, ∀ amount, where alice, owner and spender != address(0),
    the transferFrom(spender, alice, amount) call will succeed for any msg.sender `owner` when
    the currentAllowance = _allowances[owner][spender] is higher than the amount to be sent and
    when the initial balance of the owner _balances[owner] is higher than the amount to be sent.
    The function will only modify the following storage locations:
    - _balances[owner] - slot keccak256(abi.encode(owner, bytes32(0)))
    - _balances[alice] - slot keccak256(abi.encode(owner, bytes32(0)))
    - _allowances[owner][spender] - slot keccak256(abi.encode(spender, keccak256(abi.encode(owner, bytes32(1)))))
    The function explores both cases in which the allowance is infinite and in which it isn't.
    Finally, the totalSupplyIsSumOfAllBalances asserts that the invariant still holds.
    */
    function testTransferFromSuccess(address spender, address owner, address alice, uint256 amount)
        public
        totalSupplyIsSumOfAllBalances
    {
        _notBuiltinAddress(spender);
        _notBuiltinAddress(owner);
        _notBuiltinAddress(alice);
        vm.assume(spender != address(0));
        vm.assume(owner != address(0));
        vm.assume(alice != address(0));
        bytes32 storageLocationOwner = hashedLocation(owner, BALANCES_STORAGE_INDEX);
        bytes32 storageLocationAlice = hashedLocation(alice, BALANCES_STORAGE_INDEX);
        bytes32 storageLocationInitialAllowance =
            hashedLocation(spender, uint256(hashedLocation(owner, ALLOWANCES_STORAGE_INDEX)));
        kevm.allowChangesToStorage(address(gld), uint256(storageLocationOwner));
        kevm.allowChangesToStorage(address(gld), uint256(storageLocationAlice));
        kevm.allowChangesToStorage(address(gld), uint256(storageLocationInitialAllowance));
        vm.assume(gld.balanceOf(owner) >= amount);
        uint256 initialAllowance = gld.allowance(owner, spender);
        vm.assume(initialAllowance >= amount);
        vm.startPrank(spender);
        bool status = gld.transferFrom(owner, alice, amount);
        assertTrue(status);
        if (initialAllowance == MAX_INT) {
            assertEq(gld.allowance(owner, spender), initialAllowance);
        } else {
            assertEq(gld.allowance(owner, spender), initialAllowance - amount);
        }
    }

    /* ∀ functionSelector a bytes4 value, the execution shall revert if functionSelector is not
    any of the known selectors:
        - "allowance(address,address)": 0xdd62ed3e
        - "approve(address,uint256)": 0x095ea7b3
        - "balanceOf(address)": 0x70a08231
        - "burn(address,uint256)": 0x9dc29fac
        - "decimals()": 0x313ce567
        - "mint(address,uint256)": 0x40c10f19
        - "name()": 0x06fdde03
        - "sumOfAllBalances()": 0xa9cf70b7
        - "symbol()": 0x95d89b41
        - "totalSupply()": 0x18160ddd
        - "transfer(address,uint256)": 0xa9059cbb
        - "transferFrom(address,address,uint256)": 0x23b872dd
    */
    function testCallback(bytes4 functionSelector) public {
        vm.assume(functionSelector != 0xdd62ed3e);
        vm.assume(functionSelector != 0x095ea7b3);
        vm.assume(functionSelector != 0x70a08231);
        vm.assume(functionSelector != 0x9dc29fac);
        vm.assume(functionSelector != 0x313ce567);
        vm.assume(functionSelector != 0x40c10f19);
        vm.assume(functionSelector != 0x06fdde03);
        vm.assume(functionSelector != 0xa9cf70b7);
        vm.assume(functionSelector != 0x95d89b41);
        vm.assume(functionSelector != 0x18160ddd);
        vm.assume(functionSelector != 0xa9059cbb);
        vm.assume(functionSelector != 0x23b872dd);
        vm.expectRevert();
        address(gld).call(abi.encodeWithSelector(functionSelector));
    }
}
