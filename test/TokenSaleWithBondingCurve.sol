// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "openzeppelin-contracts/utils/math/SafeMath.sol";

import "src/TokenSaleWithBondingCurve.sol";

contract TokenSaleWithBondingCurveTest is Test {
    using SafeMath for uint256;

    TokenSaleWithBondingCurve sale;
    uint256 internal alicePrivateKey;

    address internal alice;

    function setUp() public {
        sale = new TokenSaleWithBondingCurve("Flawed", "FLW");

        alicePrivateKey = 0xA11CE;    
        alice  = vm.addr(alicePrivateKey);
    }

    function test_buyTokens() public {
        uint256 tokenPrice = sale.tokenPrice();
        hoax(alice, 1e18);
        
        sale.buyTokens{value: 1e18}();
        uint256 balance = sale.balanceOf(alice);
        uint256 expected = tokenPrice.mul(1e18);

        assertEq(balance, expected);

        uint256 priceApres = sale.tokenPrice();
        uint256 priceExpected = 1+1e18;

        assertEq(priceApres, priceExpected);
    }

    function test_sellTokens() public {
        uint256 amountToSell = 100e18;
        sale.mint(alice, amountToSell);
        deal(address(sale), amountToSell); //add eth balance to contract
        
        uint256 price = sale.tokenPrice();
        uint256 ethToSend = (amountToSell).div(price);
        uint256 fee = ethToSend.div(10);
        ethToSend = ethToSend.sub(fee);
        
        vm.prank(alice);
        sale.sellTokens(amountToSell);
        uint256 balance = alice.balance;
        
        assertEq(ethToSend, balance);
        assertEq(address(sale).balance, amountToSell.sub(ethToSend));
    
        uint256 priceApres = sale.tokenPrice();
        uint256 priceExpected = 1; // All minted tokens were sold

        assertEq(priceExpected, priceApres);
    }   

    function testRevert_SellTokensNotEnoughBalance() public {
        uint256 amountToSell = 100e18;
        sale.mint(alice, amountToSell-100);
        vm.expectRevert("Insufficient balance");
        vm.prank(alice);
        sale.sellTokens(amountToSell);
    }
}
