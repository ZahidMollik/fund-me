// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./priceConverter.sol";

error notOwner();
contract FundMe{
    using PriceConverter for uint256;
    uint256 constant public MINIMUM_USD=5e18;
    address[] public funders;
    mapping(address=>uint256)public fundersToBalance;
    address immutable public i_owner;

    constructor(){
        i_owner=msg.sender;
    }

    modifier onlyOwner(){
        // require(msg.sender==i_owner,"only owner can access");
        if(msg.sender!=i_owner){revert notOwner();}
        _;
    }

    function fund()public payable {
        require(msg.value.getConversionRate()>=MINIMUM_USD,"You need to spend more ETH");
        funders.push(msg.sender);
        fundersToBalance[msg.sender]+=msg.value;
    }

    function withdraw()public onlyOwner{
        for(uint256 index=0;index<funders.length;index++){
            address funder=funders[index];
            fundersToBalance[funder]=0;
        }

        funders= new address[](0);

         (bool success,)=payable(msg.sender).call{value:address(this).balance}("");
         require(success,"fail to withdraw");
    }

    function getVersion() public view returns (uint256){
        return AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306).version();
    }

    receive() external payable{
        fund();
    }

    fallback() external payable { 
        fund();
    }
}