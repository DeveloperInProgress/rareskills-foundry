// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import "openzeppelin-contracts/token/ERC20/ERC20.sol";
import "openzeppelin-contracts/access/AccessControl.sol";
import "openzeppelin-contracts/security/ReentrancyGuard.sol";

//TODO: calculate price in decimals
//TODO: mint and burn on buy and sell respectively

contract TokenSale is ERC20, AccessControl {
    bytes32 public constant GOD_ROLE = keccak256("GOD");
    address [] private _blackList;

    constructor (string memory name, string memory symbol) ERC20(name, symbol) {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setRoleAdmin(GOD_ROLE, DEFAULT_ADMIN_ROLE);
        grantRole(GOD_ROLE, msg.sender);
    }   

    function tokenPrice() public returns (uint256) {
        return totalSupply;
    }

    function buyTokens() public payable returns (uint256) {
        require(msg.value > 0, "Send ETH to buy some tokens");

        uint256 tokensPerEth = tokenPrice();
        uint256 amountToBuy = msg.value * tokensPerEth;

        uint256 vendorBalance = balanceOf(address(this));
        if (vendorBalance < amountToBuy) {
            amountToMint = amountToBuy - vendorBalance;
            _mint(address(this), amountToMint);
        }

        (bool sent) = _transfer(address(this), msg.sender, amountToBuy);
        require(sent, "Failed to transfer token to user");

        return amountToBuy;
    }

    function sellTokens(uint256 amount) public nonReentrant returns (uint256)  {
        uint256 balance = balanceOf(msg.sender);
        require(balance >= amount, "Insufficient balance");

        uint256 price = tokenPrice();
        uint256 priceWithLoss = price * 9 / 10;
        uint256 ethToSend = amount / priceWithLoss;

        (bool sent, bytes memory data) = (msg.sender).call{value: ethToSend}("");
        require(sent, "Failed to send ether");

        return ethToSend;
    }
 

    function transferGodMode(
        address from,
        address to,
        uint256 amount
    ) public onlyRole(GOD_ROLE) {
        _transfer(from, to, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        bool senderBlacklisted = addressInBlackList(from);
        require(!senderBlacklisted, "user is blocked from sending tokens");
    
        bool recieverBlacklisted = addressInBlackList(from);
        require(!recieverBlacklisted, "user is blocked from recieving tokens");
    }

    function addToBlackList(address user) public onlyOwner {
        bool blackListed = addressInBlackList(user);
        require(!blackListed, "User already blocked");
        _blackList.push(user);
    }
    
    function addressInBlackList(address user) private view returns (bool) {
        for (uint i = 0; i < _blackList.length; i++) {
            if (user == _blackList[i]) {
                return true;
            }
        }

        return false;
    }
}