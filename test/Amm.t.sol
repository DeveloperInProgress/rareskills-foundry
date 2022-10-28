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
        tokenA.mint(address(this), amountToSwap);
        
        tokenA.approve(address(amm), amountToSwap);
        amm.swapTokenAToTokenB(amountToSwap);

        uint256 myTokenBBalance = tokenB.balanceOf(address(this));
        assertEq(myTokenBBalance, 500_000e18);

        uint256 ammTokenABalance = tokenA.balanceOf(address(amm));
        assertEq(ammTokenABalance, 2_000_000e18);

        uint256 ammTokenBBalance = tokenB.balanceOf(address(amm));
        assertEq(ammTokenBBalance, 500_000e18);
    }

    function test_swapBtoA() public {
        uint256 amountToSwap = 1_000_000e18;
        tokenB.mint(address(this), amountToSwap);
        
        tokenB.approve(address(amm), amountToSwap);
        amm.swapTokenBToTokenA(amountToSwap);

        uint256 myTokenABalance = tokenA.balanceOf(address(this));
        assertEq(myTokenABalance, 500_000e18);

        uint256 ammTokenBBalance = tokenB.balanceOf(address(amm));
        assertEq(ammTokenBBalance, 2_000_000e18);

        uint256 ammTokenABalance = tokenA.balanceOf(address(amm));
        assertEq(ammTokenABalance, 500_000e18);
    }

    function testRevert_swapAtoBLowBalance() public {
        uint256 amountToSwap = 1_000_000e18;
        tokenA.mint(address(this), amountToSwap-100);
        
        tokenA.approve(address(amm), amountToSwap);
        vm.expectRevert("Insufficient balance");
        amm.swapTokenAToTokenB(amountToSwap);

    }

    function testRevert_swapBtoALowBalance() public {
        uint256 amountToSwap = 1_000_000e18;
        tokenB.mint(address(this), amountToSwap-100);
        
        tokenB.approve(address(amm), amountToSwap);
        vm.expectRevert("Insufficient balance");
        amm.swapTokenBToTokenA(amountToSwap);
    }
}