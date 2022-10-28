// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import "openzeppelin-contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "openzeppelin-contracts/utils/math/SafeMath.sol";
import "openzeppelin-contracts/access/Ownable.sol";
import "@openzeppelin-contracts/proxy/utils/Initializable.sol";

contract AMM is Initalizable {
    using SafeMath for uint256;
    using SafeMath for uint8;

    IERC20Metadata public immutable tokenA;
    IERC20Metadata public immutable tokenB;

    constructor(
        address tokenAaddr,
        address tokenBaddr
    ) {
        require(tokenAaddr != address(0), "Token address passed as null address");
        require(tokenBaddr != address(0), "Token address passed as null address");

        tokenA = IERC20Metadata(tokenAaddr);
        tokenB = IERC20Metadata(tokenBaddr);
    }   

    function initialize() public initalizer {
        uint8 tokenAdecimals = tokenA.decimals();
        uint256 requiredTknABits = (10**tokenAdecimals).mul(1_000_000);

        uint8 tokenBdecimals = tokenB.decimals();
        uint256 requiredTknBBits = (10**tokenBdecimals).mul(1_000_000);

        //deposit TokenA

        uint256 tokenAbalance = tokenA.balanceOf(msg.sender);
        require(tokenAbalance >= requiredTknABits, "not enough balance");
        tokenA.transferFrom(msg.sender, address(this), requiredTknABits);

        //deposit TokenB

        uint256 tokenBbalance = tokenB.balanceOf(msg.sender);
        require(tokenBbalance >= requiredTknBBits, "not enough balance");
        tokenB.transferFrom(msg.sender, address(this), requiredTknBBits);
    }

    function swapTokenAToTokenB(uint256 _amount) external {
        uint256 tokenABalance = tokenA.balanceOf(address(this));
        uint256 tokenBBalance = tokenB.balanceOf(address(this));

        uint256 updatedTokenABalance = tokenABalance + _amount;
        uint256 tokenBAmountToReceive = tokenBBalance.mul(_amount).div(updatedTokenABalance);

        tokenA.transferFrom(address(this), msg.sender, _amount);
        tokenB.transfer(msg.sender, tokenBAmountToReceive);
    }  

    function swapTokenBToTokenA(uint256 _amount) external {
        uint256 tokenABalance = tokenA.balanceOf(address(this));
        uint256 tokenBBalance = tokenB.balanceOf(address(this));

        uint256 updatedTokenBBalance = tokenBBalance + _amount;
        uint256 tokenAAmountToReceive = tokenABalance.mul(_amount).div(updatedTokenBBalance);

        tokenB.transferFrom(address(this), msg.sender, _amount);
        tokenA.transfer(msg.sender, tokenAAmountToReceive);
    }  
}