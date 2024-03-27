// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./PriceConvertor.sol";

contract fundMe {
    using PriceConvertor for uint256;
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwnerCan {
        require(msg.sender == owner,"Sender is not owner");
        _;
    }

    uint256 public minimumUsd = 50;
    address[] public funders;
    mapping (address => uint256) public addressToAmountFunded;

    function fund() public payable {
        require(msg.value.getConversionRate() >= 1e18, "Didn't semd enough !");
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] = msg.value;
    }

    function withDraw() public onlyOwnerCan{

        for(uint256 funderIndex = 0; funderIndex < funders.length; funderIndex = funderIndex + 1){
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }

        //resetting array
        funders = new address[](0);
        (bool callSuccess,) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess,"Call Success failed");
    }

}
