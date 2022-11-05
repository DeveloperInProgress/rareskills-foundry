// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.13;

import "forge-std/Test.sol";

import "src/EnumerableNFT.sol";

contract EnumerableNFTTest is Test {
    EnumerableNFT nft;
    NFTGame game; 

    uint256 internal alicePrivateKey;
    address internal alice;

    function setUp() public {
        nft = new EnumerableNFT();
        game = new NFTGame(address(nft));

        alicePrivateKey = 0xA11CE;
        alice = vm.addr(alicePrivateKey);
    }

    function test_primeNumberTokenIDs() public {
        vm.startPrank(alice);
        nft.mint(1);
        nft.mint(2);
        nft.mint(5);
        nft.mint(9);
        nft.mint(13);
        nft.mint(19);
        nft.mint(20);

        uint256 primes = game.getNumberOfPrimeNumberTokenId(address(alice));
        //prime numbers: 2 5 13 19
        assertEq(primes, 4);
    }
}