// SPDX-License-Identifier: MIT
// (The MIT License)

// Copyright 2020-2024 Optimism

// Permission is hereby granted, free of charge, to any person obtaining
// a copy of this software and associated documentation files (the
// "Software"), to deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so, subject to
// the following conditions:

// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
// CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
// TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

pragma solidity ^0.8.13;

library Types {
    struct OutputRootProof {
        bytes32 version;
        bytes32 stateRoot;
        bytes32 messagePasserStorageRoot;
        bytes32 latestBlockhash;
    }

    struct WithdrawalTransaction {
        uint256 nonce;
        address sender;
        address target;
        uint256 value;
        uint256 gasLimit;
        bytes data;
    }
}

// Adapted from https://github.com/ethereum-optimism/optimism
contract Portal  {
    bool public paused;
    address public guardian;

    /// @notice Emitted when a withdrawal transaction is proven.
    event WithdrawalProven(address indexed from, address indexed to);

    /// @notice Emitted when the conract is paused.
    event Paused();

    /// @notice Reverts when paused.
    modifier whenNotPaused() {
        require(paused == false, "Portal: paused");
        _;
    }

    constructor() {
        guardian = msg.sender;
    }

    /// @notice Pauses this contract.
    function pause()
        external
        whenNotPaused
    {
        require(msg.sender == guardian, "Portal: not a guardian");
        paused = true;
        // Emit a `Paused` event.
        emit Paused();
    }

    /// @notice Accepts ETH value without triggering a deposit to L2.
    ///         This function mainly exists for the sake of the migration between the legacy
    ///         Optimism system and Bedrock.
    function donateETH() external payable {
        // Intentionally empty.
    }

   /// @notice Proves a withdrawal transaction.
    function proveWithdrawalTransaction(
        Types.WithdrawalTransaction memory _tx,
        uint256 _l2OutputIndex,
        Types.OutputRootProof calldata _outputRootProof,
        bytes[] calldata _withdrawalProof
    )
        external
        whenNotPaused
    {
        // Implementation omitted
        // Emit a `WithdrawalProven` event.
        emit WithdrawalProven(_tx.sender, _tx.target);
    }
}