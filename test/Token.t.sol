// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import "src/Token.sol";

contract TokenTest is Test {
    Token internal token;

    uint256 internal alicePrivateKey;
    uint256 internal bobPrivateKey;

    address internal alice;
    address internal bob;

    function setUp() public {
        token = new Token("Flawed", "FLW");

        alicePrivateKey = 0xA11CE;
        bobPrivateKey = 0xB0B;

        alice  = vm.addr(alicePrivateKey);
        bob = vm.addr(bobPrivateKey);

        token.mint(alice, 1e18);
        token.mint(bob, 1e18);
        token.addToBlackList(alice);
    }

    function testRevert_blockedSender() public {
        vm.expectRevert("user is blocked from sending tokens");
        vm.prank(alice);
        token.transfer(
            bob,
            1e18
        );
    }

    function testRevert_blockedReciever() public {
        vm.expectRevert("user is blocked from recieving tokens");
        vm.prank(bob);
        token.transfer(
            alice,
            1e18
        );
    }

    function testRevert_duplicateBlocking() public {
        vm.expectRevert("User already blocked");
        token.addToBlackList(alice);
    }

    function testRevert_nonAdminBlocking() public {
        vm.expectRevert("Ownable: caller is not the owner");
        vm.prank(alice);
        token.addToBlackList(bob);
    }

    function test_removeFromBlockList() public {
        token.removeFromBlackList(alice);
        vm.prank(alice);
        token.transfer(bob, 1e18);
    }

    function testRevert_removeNonExistentFromBlockList() public {
        token.addToBlackList(bob);
        token.removeFromBlackList(alice);
        vm.expectRevert("User not in blacklist");
        token.removeFromBlackList(alice);
    }

    function testRevert_removeFromEmptyBlackList() public {
        token.removeFromBlackList(alice);
        vm.expectRevert("Blacklist is empty");
        token.removeFromBlackList(alice);
    }
}

