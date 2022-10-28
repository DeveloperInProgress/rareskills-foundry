// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import "openzeppelin-contracts/token/ERC20/ERC20.sol";
import "openzeppelin-contracts/access/AccessControl.sol";
import "openzeppelin-contracts/security/ReentrancyGuard.sol";
import "openzeppelin-contracts/utils/math/SafeMath.sol";
import "./TokenWithGodMode.sol";

contract TokenSaleWithBondingCurve is TokenWithGodMode, ReentrancyGuard {
    
    using SafeMath for uint256;

    uint256 private _sellBackFees;

    constructor (string memory name, string memory symbol) TokenWithGodMode(name, symbol) {}   

    function tokenPrice() public view returns (uint256) {
        return (totalSupply()).add(1);
    }

    function buyTokens() public payable returns (uint256) {
        
        uint256 weiAmount = msg.value;
        
        require(weiAmount > 0, "Send ETH to buy some tokens");

        uint256 tokensPerEth = tokenPrice();
        uint256 tokens = weiAmount.mul(tokensPerEth);

        _mint(msg.sender, tokens);

        return tokens;
    }

    function sellTokens(uint256 amount) public nonReentrant returns (uint256)  {
        uint256 balance = balanceOf(msg.sender);
        require(balance >= amount, "Insufficient balance");

        uint256 price = tokenPrice();
        uint256 ethToSend = amount.div(price);
        uint256 fees = ethToSend.div(10);
    	ethToSend = ethToSend.sub(fees);
        (bool sent, bytes memory data) = (msg.sender).call{value: ethToSend}("");
        require(sent, "Failed to send ether");

        _burn(msg.sender, amount);
        _sellBackFees = _sellBackFees.add(fees);

        return ethToSend;
    }

    function withdrawSellBackFees() external onlyRole(DEFAULT_ADMIN_ROLE) {
        (bool sent, bytes memory data) = (msg.sender).call{value: _sellBackFees}("");
        require(sent, "Failed to send ether");
        _sellBackFees = 0;
    }
 
}