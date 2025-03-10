//SPDX-License-Identifier:MIT
pragma solidity ^0.8.26;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library PriceConverter{
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
}