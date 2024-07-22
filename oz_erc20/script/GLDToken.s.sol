// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {GLDToken} from "../src/GLDToken.sol";

contract CounterScript is Script {
    GLDToken public gld;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        gld = new GLDToken();

        vm.stopBroadcast();
    }
}
