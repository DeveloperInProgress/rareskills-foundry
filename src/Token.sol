// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import "openzeppelin-contracts/token/ERC20/ERC20.sol";
import "openzeppelin-contracts/access/Ownable.sol";

contract Token is ERC20, Ownable{
    
    address [] private _blackList;
    
    constructor (string memory name, string memory symbol) ERC20(name, symbol) {
        this;
    }

    function mint(address _to, uint256 amount) external onlyOwner {
        ERC20._mint(_to, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        bool senderBlacklisted = addressInBlackList(from);
        require(!senderBlacklisted, "user is blocked from sending tokens");
    
        bool recieverBlacklisted = addressInBlackList(to);
        require(!recieverBlacklisted, "user is blocked from recieving tokens");
    }

    function addToBlackList(address user) external onlyOwner {
        bool blackListed = addressInBlackList(user);
        require(!blackListed, "User already blocked");
        _blackList.push(user);
    }
    
    function removeFromBlackList(address user) external onlyOwner {
        require(_blackList.length != 0, "Blacklist is empty");

        uint i;

        for(i = 0; i < _blackList.length; i++) {
            if (_blackList[i] == user) {
                break;
            }
        }
        
        require(i != _blackList.length, "User not in blacklist");

        _blackList[i] = _blackList[_blackList.length - 1];
        _blackList.pop();
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
