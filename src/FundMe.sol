// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract FundMe{
    uint256 public MINIMUM_USD=5e18;
    address[] public funders;
    mapping(address=>uint256)public fundersToBalance;
    address public owner;

    constructor(){
        owner=msg.sender;
    }

    function fund()public payable {
        require(getConversionRate(msg.value)>=MINIMUM_USD,"not enough eth");
        funders.push(msg.sender);
        fundersToBalance[msg.sender]+=msg.value;
    }

    function withdraw()public{
        for(uint256 index=0;index<funders.length;index++){
            address funder=funders[index];
            fundersToBalance[funder]=0;
        }

         funders=new address[](0);

         (bool success,)=payable(msg.sender).call{value:address(this).balance}("");
         require(success,"fail to withdraw");
    }

    function getPrice() public view returns(uint256) {
        //ETH/USD address- 0x694AA1769357215DE4FAC081bf1f309aDC325306
       AggregatorV3Interface priceFeed=AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
       (,int256 price,,,)=priceFeed.latestRoundData();
       return uint256(price*1e10);
    }

    function getConversionRate(uint256 ethAmount) public view returns(uint256){
        uint256 ethPrice=getPrice();
        uint256 ethAmountUsd=(ethAmount*ethPrice)/1e18;
        return ethAmountUsd;
    }

    function getVersion() public view returns (uint256){
        return AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306).version();
    }
}