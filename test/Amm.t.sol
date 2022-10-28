// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "openzeppelin-contracts/utils/math/SafeMath.sol";
import "src/TokenWithGodMode.sol";
import "openzeppelin-contracts/token/ERC20/extensions/IERC20Metadata.sol";

import "src/AMM.sol";

interface IERC20Mintable is IERC20Metadata {
    function mint(address to, uint256 amount) external;
}

contract AMMTest is Test {
    address tokenAaddr;
    address tokenBaddr;

    TokenWithGodMode internal tokenA;
    TokenWithGodMode internal tokenB;
    
    AMM amm;

    uint256 internal alicePrivateKey;
    address internal alice;

    function setUp() public {
        tokenA = new TokenWithGodMode("TokenA", "TA");
        tokenB = new TokenWithGodMode("TokenB", "TB");

        tokenAaddr = address(tokenA);
        tokenBaddr = address(tokenB);

        tokenA.mint(address(this), 1_000_000e18);
        tokenB.mint(address(this), 1_000_000e18);

        amm = new AMM(tokenAaddr, tokenBaddr);

        tokenA.approve(address(amm), 1_000_000e18);
        tokenB.approve(address(amm), 1_000_000e18);

        amm.initialize();

        alicePrivateKey = 0xA11CE;    
        alice  = vm.addr(alicePrivateKey);
    }

    function test_swapAtoB() public {
        uint256 amountToSwap = 1_000_000e18;
        deal(tokenAaddr, alice, amountToSwap);
        vm.prank(alice);
        amm.swapTokenAToTokenB(amountToSwap);

        uint256 aliceTokenBBalance = tokenB.balanceOf(alice);
        assertEq(aliceTokenBBalance, 500_000);

        uint256 ammTokenABalance = tokenA.balanceOf(address(amm));
        assertEq(ammTokenABalance, 2_000_000);

        uint256 ammTokenBBalance = tokenB.balanceOf(address(amm));
        assertEq(ammTokenBBalance, 500_000);
    }
}