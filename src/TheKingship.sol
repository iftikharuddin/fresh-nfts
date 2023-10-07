// SPDX-License-Identifier: MIT

pragma solidity ^0.8.21;

import {ERC721A} from "../lib/ERC721A/contracts/ERC721A.sol";
import {IERC721R} from "../lib/ERC721R/contracts/IERC721R.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Address} from "@openzeppelin/contracts/utils/Address.sol";

contract TheKingship is ERC721A, Ownable {
    uint256 public constant mintPrice = 0.02 ether;
    uint256 public constant maxMintPerUser = 5;
    uint256 public constant maxMintSupply = 1000;
    uint256 public constant refundPeriod = 3 minutes;
    address public refundAddress;
    uint256 public refundEndTimestamp;

    mapping(uint256 => uint256) public refundEndTimestamps;
    mapping(uint256 => bool) public hasRefunded;

    constructor(address initialOwner) ERC721A("TheKingship", "TKS") Ownable(initialOwner) {
        refundAddress = address(this);
        refundEndTimestamp = block.timestamp + refundPeriod;
    }

    function _baseURI() internal pure override returns (string memory) {
        return "ipfs://QmZT57nEYVGVJDdF2WZeLLHuF6WRrzLw2R7U3vAxFkJHCq/?pub.json";
    }

    function safeMint(uint256 quantity) public payable {
        require(msg.value >= quantity * mintPrice, "Not enough funds!");
        require(_numberMinted(msg.sender) * quantity <= maxMintPerUser, "You cannot mint more, limit reached!");
        require(_totalMinted() + quantity <= maxMintSupply, "We sold out!");
        _safeMint(msg.sender, quantity);
        refundEndTimestamp = block.timestamp + refundPeriod;
        for (uint256 i = _nextTokenId() - quantity; i < _nextTokenId(); i++) {
            refundEndTimestamps[i] = refundEndTimestamp;
        }
    }

    function refund(uint256 tokenId) external {
        // you have to be the owner of the NFT
        require(block.timestamp < getRefundDeadline(tokenId), "Refund Period Expired");
        require(msg.sender == ownerOf(tokenId), "Not your NFT");
        uint256 refundAmount = getRefundAmount(tokenId);

        // transfer ownership of NFT
        transferFrom(msg.sender, refundAddress, tokenId);

        //mark refunded
        hasRefunded[tokenId] = true;
        // refund the Price
        Address.sendValue(payable(msg.sender), refundAmount);
    }

    function getRefundDeadline(uint256 tokenId) public view returns (uint256) {
        if (hasRefunded[tokenId]) {
            return 0;
        }
        return refundEndTimestamps[tokenId];
    }

    function getRefundAmount(uint256 tokenId) public view returns (uint256) {
        if (hasRefunded[tokenId]) {
            return 0;
        }
        return mintPrice;
    }

    function withdraw() external onlyOwner {
        require(block.timestamp > refundEndTimestamp, "It's not past the refund period");
        uint256 balance = address(this).balance;
        Address.sendValue(payable(msg.sender), balance);
    }
}
