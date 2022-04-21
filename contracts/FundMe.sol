pragma solidity ^0.6.6;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.6/vendor/SafeMathChainlink.sol";

contract FundMe {

    using SafeMathChainlink for uint256;

    mapping(address => uint256) public addressToAmountFunded;
    AggregatorV3Interface public priceFeed;
    address public owner;

    // array of all contracts that have funded us
    // must be rest to zero whenever withdraw function is called
    address[] public funders;
    // tutto quello che viene inserito qui viene eseguito al deploy
    constructor(address _priceFeed) public {
        priceFeed= AggregatorV3Interface(_priceFeed);
        owner = msg.sender;
    }

    function fund() payable public {
        uint256 minimumUSD = 50 * (10 ** 18); // lower limit of fund/payment in USD 50ETH
        require(getConversionRate(msg.value)>= minimumUSD,"You need to spend more than 50 ETH");
        addressToAmountFunded[msg.sender] += msg.value;
        funders.push(msg.sender);
        // what the eth->usd conversion rate is

    }
    function getEntranceFee() public view returns (uint256) {
        // minimumUSD
        uint256 minimumUSD = 50 * 10**18;
        uint256 price = getPrice();
        uint256 precision = 1 * 10**18;
        return (minimumUSD * precision) / price;
    }
    // modifiers change behavior of functions
    modifier onlyOwner {
        require(msg.sender == owner,"You must be the owner of contract to get money");
        _;
    }
    function withdraw() payable onlyOwner public {
        // only want the contract owner
        // require msg.sender == owner of contract
        // require(msg.sender == owner,"You must be the owner of contract to get money");
        msg.sender.transfer(address(this).balance);
        // reset all funds of all contracts to zero
        for (uint256 funderIndex=0;funderIndex<funders.length;funderIndex++) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        // funders new blank array
        funders = new address[](0);
    }

    function getVersion() public view returns(uint256) {
        // AggregatorV3Interface priceFeed = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
        return priceFeed.version();
    }

    function getPrice() public view returns(uint256) {
        // AggregatorV3Interface priceFeed = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
        (,int256 answer,,,) = priceFeed.latestRoundData();
        return uint256(answer * 10000000000);
        
    }
    // converts from ETH to USD
    function getConversionRate(uint256 ethAmount) public view returns(uint256) {
        uint256 ethPrice = getPrice();
        uint256 ethAmountInUsd = (ethAmount * ethPrice) / 1000000000000000000;
        return ethAmountInUsd;
    }
}