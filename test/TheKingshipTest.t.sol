// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {TheKingship} from "../src/TheKingship.sol";
import {Test} from "forge-std/Test.sol";
import {DeployTheKingship} from "../script/DeployTheKingship.s.sol";

contract TheKingshipTest is Test {
    TheKingship public theKingship;
    DeployTheKingship public deployer;
    address public USER = makeAddr("USER");

    string public constant PUG_URI = "ipfs://QmZT57nEYVGVJDdF2WZeLLHuF6WRrzLw2R7U3vAxFkJHCq/";

    function setUp() public {
        deployer = new DeployTheKingship();
        theKingship = deployer.run();
    }

    function testNameIsCorrect() public view {
        string memory actualName = "TheKingship";
        string memory expectedName = theKingship.name();
        // Compare the 'keccak256' hashes directly
        bool namesMatch = keccak256(abi.encodePacked(actualName)) == keccak256(abi.encodePacked(expectedName));
        assert(namesMatch);
    }

    function testCanMintAndHaveBalance() public {
        vm.prank(USER);
        vm.deal(USER, 1 ether);
        theKingship.safeMint{value: 0.02 ether}(1);
        assert(theKingship.balanceOf(USER) == 1);
    }

    function testTokenURIIsCorrect() public {
        vm.prank(USER);
        vm.deal(USER, 1 ether);
        theKingship.safeMint{value: 0.02 ether}(1);
        assert(keccak256(abi.encodePacked(theKingship.tokenURI(0))) == keccak256(abi.encodePacked(PUG_URI)));
    }
}
