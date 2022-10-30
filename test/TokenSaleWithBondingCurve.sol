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
        uint256 purchaseReturn = sale.computePurchaseReturns(1e18);
        hoax(alice, 1e18);
        
        sale.buyTokens{value: 1e18}();
        uint256 balance = sale.balanceOf(alice);

        assertEq(balance, purchaseReturn);
    }

    function test_sellTokens() public {
        uint256 purchaseReturn = sale.computePurchaseReturns(100e18);
        startHoax(alice, 100e18);
        sale.buyTokens{value: 100e18}();
        
        uint256 saleReturn = sale.computeSaleReturns(purchaseReturn/2);
        uint256 ethToSend = sale.sellTokens(purchaseReturn/2);
        
        uint256 saleReturnAfterFee = saleReturn - saleReturn.div(10);
        assertEq(ethToSend, saleReturnAfterFee);
        assertEq(alice.balance, ethToSend);
    }   

    function testRevert_SellTokensNotEnoughBalance() public {
        uint256 amountToSell = 100e18;
        sale.mint(alice, amountToSell-100);
        vm.expectRevert("Insufficient balance");
        vm.prank(alice);
        sale.sellTokens(amountToSell);
    }
}
