// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import "openzeppelin-contracts/token/ERC20/ERC20.sol";
import "openzeppelin-contracts/access/AccessControl.sol";

contract TokenWithGodMode is ERC20, AccessControl {
    bytes32 public constant GOD_ROLE = keccak256("GOD");
    address [] private _blackList;
    address public godUser;

    constructor (string memory name, string memory symbol) ERC20(name, symbol) {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setRoleAdmin(GOD_ROLE, DEFAULT_ADMIN_ROLE);
        grantRole(GOD_ROLE, msg.sender);
        godUser = msg.sender;
    }   

    function mint(address _to, uint256 amount) external onlyRole(DEFAULT_ADMIN_ROLE) {
        ERC20._mint(_to, amount);
    }

    function transferGodMode(
        address from,
        address to,
        uint256 amount
    ) external onlyRole(GOD_ROLE) {
        _transfer(from, to, amount);
    }

    function assignGodRole(
        address user
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(user != address(0), "Null address error");
        grantRole(GOD_ROLE, user);
        revokeRole(GOD_ROLE, godUser);
        godUser = user;
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

    function addToBlackList(address user) external onlyRole(DEFAULT_ADMIN_ROLE) {
        bool blackListed = addressInBlackList(user);
        require(!blackListed, "User already blocked");
        _blackList.push(user);
    }
    
    function removeFromBlackList(address user) external onlyRole(DEFAULT_ADMIN_ROLE) {
        uint i;
        for(i = 0; i < _blackList.length; i++) {
            if (_blackList[i] == user) {
                break;
            }
        }
        
        require(i != _blackList.length, "User not in blacklist");

        address lastUser = _blackList[_blackList.length - 1];
        _blackList[i] = lastUser;
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