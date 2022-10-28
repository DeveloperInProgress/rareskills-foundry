// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import "openzeppelin-contracts/token/ERC20/ERC20.sol";
import "openzeppelin-contracts/access/AccessControl.sol";
import "openzeppelin-contracts/utils/math/SafeMath.sol";
import "./TokenWithGodMode.sol";

contract TokenSale is TokenWithGodMode {
    using SafeMath for uint256;
    using SafeMath for uint8;

    uint256 public constant rate = 10000;

    constructor (string memory name, string memory symbol) TokenWithGodMode(name, symbol) {
        uint256 tokensToMint = 22_000_000e18;
        _mint(address(this), tokensToMint);
    }   

    function buyTokens() public payable returns (uint256 tokenAmount) {
        uint256 weiAmount = msg.value;
        
        require(weiAmount > 0, "Send ETH to buy some tokens");
        
        uint256 tokens = weiAmount.mul(rate);
         
        uint256 vendorBalance = balanceOf(address(this));
        require(vendorBalance >= tokens, "Vendor contract has not enough tokens in its balance");

        _transfer(address(this), msg.sender, tokens);

        return tokens;
    }
}