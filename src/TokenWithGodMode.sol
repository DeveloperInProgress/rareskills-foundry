// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import "openzeppelin-contracts/token/ERC20/ERC20.sol";
import "openzeppelin-contracts/access/AccessControl.sol";

contract TokenWithGodMode is ERC20, AccessControl {
    bytes32 public constant GOD_ROLE = keccak256("GOD");
    address [] private _blackList;

    constructor (string memory name, string memory symbol) ERC20(name, symbol) {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setRoleAdmin(GOD_ROLE, DEFAULT_ADMIN_ROLE);
        grantRole(GOD_ROLE, msg.sender);
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

    //TODO: remove from blacklist
    
    function addressInBlackList(address user) private view returns (bool) {
        for (uint i = 0; i < _blackList.length; i++) {
            if (user == _blackList[i]) {
                return true;
            }
        }

        return false;
    }
}