// SPDX-License-Identifier: MIT

pragma solidity ^0.8.21;

import {Script} from "forge-std/Script.sol";
import {TheKingship} from "../src/TheKingship.sol";

contract DeployTheKingship is Script {
    function run() external returns (TheKingship) {
        vm.startBroadcast();
        TheKingship theKingShip = new TheKingship(msg.sender);
        vm.stopBroadcast();
        return theKingShip;
    }
}
