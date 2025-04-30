// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {TopToken} from "../src/TopToken.sol";

contract TopTokenScript is Script {
    TopToken public token;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        token = new TopToken();

        vm.stopBroadcast();
    }
}
