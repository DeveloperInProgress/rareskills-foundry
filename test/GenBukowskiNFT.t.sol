// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.13;

import "forge-std/Test.sol";

import "src/GenBukowskiNFT.sol";

contract GenBukowskiNFTTest is Test {
    GenBukowskiNFT nft;

    function setUp() public {
        nft = new GenBukowskiNFT();
    }

    function test_mint() public {
        nft.mint();
        assertEq(nft.tokenSupply(), 1);
        assertEq(nft.balanceOf(address(this)), 1);
    }

    function testRevert_mintMoreThanSupply() public {
        for (uint i = 0; i < 10; i++) {
            nft.mint();
        }
        assertEq(nft.tokenSupply(), 10);
        assertEq(nft.balanceOf(address(this)), 10);
        vm.expectRevert("No more tokens available");
        nft.mint();
    }
}