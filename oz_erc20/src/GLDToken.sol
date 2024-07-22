// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract GLDToken is ERC20 {
    uint256 public sumOfAllBalances;

    constructor() ERC20("Gold", "GLD") {}

    /**
     * @dev Publicly exposed mint function of the contract for example purposes.
     */
    function mint(address account, uint256 value) public {
        _mint(account, value);
        sumOfAllBalances += value;
    }

    /**
     * @dev Publicly exposed burn function of the contract for example purposes
     */
    function burn(address account, uint256 value) public {
        _burn(account, value);
        sumOfAllBalances -= value;
    }
}
