// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import "openzeppelin-contracts/token/ERC20/ERC20.sol";
import "openzeppelin-contracts/access/AccessControl.sol";

//TODO: calculate price in decimals

contract TokenSale is ERC20, AccessControl {
    bytes32 public constant GOD_ROLE = keccak256("GOD");
    address [] private _blackList;
    uint256 public tokensPerEth = 10000;

    constructor (string memory name, string memory symbol) ERC20(name, symbol) {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setRoleAdmin(GOD_ROLE, DEFAULT_ADMIN_ROLE);
        grantRole(GOD_ROLE, msg.sender);
        _mint(address(this), 22_000_000);
    }   

    function buyTokens() public payable returns (uint256 tokenAmount) {
        require(msg.value > 0, "Send ETH to buy some tokens");

        uint256 amountToBuy = msg.value * tokensPerEth;

        uint256 vendorBalance = balanceOf(address(this));
        require(vendorBalance >= amountToBuy, "Vendor contract has not enough tokens in its balance");

        (bool sent) = _transfer(address(this), msg.sender, amountToBuy);
        require(sent, "Failed to transfer token to user");

        return amountToBuy;
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