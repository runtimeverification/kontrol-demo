// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <0.9.0;
pragma experimental ABIEncoderV2;

/**
 * @dev Provides special functions that will modify the internal state
 * of the EVM when invoked. These functions are only supported by the
 * KEVM semantics (yet), and are not supported by `forge`.

 * The KEVM execution will intercept calls to the `kevm` address and
 * will modify the state according to the called function.
 */

interface KEVMCheatsBase {
    // Expects a call using the CALL opcode to an address with the specified calldata.
    function expectRegularCall(address,bytes calldata) external;
    // Expects a call using the CALL opcode to an address with the specified msg.value and calldata.
    function expectRegularCall(address,uint256,bytes calldata) external;
    // Expects a static call to an address with the specified calldata.
    function expectStaticCall(address,bytes calldata) external;
    // Expects a delegate call to an address with the specified calldata.
    function expectDelegateCall(address,bytes calldata) external;
    // Expects that no contract calls are made after invoking the cheatcode.
    function expectNoCall() external;
    // Expects the given address to deploy a new contract, using the CREATE opcode, with the specified value and bytecode.
    function expectCreate(address,uint256,bytes calldata) external;
    // Expects the given address to deploy a new contract, using the CREATE2 opcode, with the specified value and bytecode (appended with a bytes32 salt).
    function expectCreate2(address,uint256,bytes calldata) external;
    // Makes the storage of the given address completely symbolic.
    function symbolicStorage(address) external;
    // Adds an address to the whitelist.
    function allowCallsToAddress(address) external;
    // Adds an address and a storage slot to the whitelist.
    function allowChangesToStorage(address,uint256) external;
    // Set the current <gas> cell
    function infiniteGas() external;
}

abstract contract KEVMCheats {
    KEVMCheatsBase public constant kevm = KEVMCheatsBase(address(uint160(uint256(keccak256("hevm cheat code")))));
}
