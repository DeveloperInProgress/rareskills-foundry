// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import "src/TokenSale.sol";

contract TokenSaleTest is Test {
    TokenSale sale;
    uint256 internal alicePrivateKey;

    address internal alice;

    function setUp() public {
        sale = new TokenSale("Flawed", "FLW");

        alicePrivateKey = 0xA11CE;    
        alice  = vm.addr(alicePrivateKey);

    }

    function test_buyTokens() public {
        hoax(alice, 1e18);
        sale.buyTokens{value: 1e18}();
        uint256 balance = sale.balanceOf(alice);
        assertEq(balance, 10000e18);
    }

    function testRevert_buyMoreThanTotalSupply() public {
        hoax(alice, 23000e18);
        vm.expectRevert("Vendor contract has not enough tokens in its balance");
        sale.buyTokens{value: 23000e18}();
    }
}
