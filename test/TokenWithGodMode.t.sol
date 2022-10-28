// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import "src/TokenWithGodMode.sol";

contract TokenWithGodModeTest is Test {
    TokenWithGodMode internal token;

    uint256 internal alicePrivateKey;
    uint256 internal bobPrivateKey;
    uint256 internal godPrivateKey;

    address internal alice;
    address internal bob;
    address internal god;

    function setUp() public {
        token = new TokenWithGodMode("Flawed", "FLW");

        alicePrivateKey = 0xA11CE;
        bobPrivateKey = 0xB0B;
        godPrivateKey = 0xF0D;

        alice  = vm.addr(alicePrivateKey);
        bob = vm.addr(bobPrivateKey);
        god = vm.addr(godPrivateKey);

        token.assignGodRole(god);

        token.mint(alice, 1e18);
        token.mint(bob, 1e18);
    }

    function test_transferGodMode() public {
        vm.prank(god);
        token.transferGodMode(alice, bob, 1e18);

        uint bobBalance = token.balanceOf(bob);

        assertEq(bobBalance, 2e18);
    }

    function testRevert_transferGodModeNotGod() public {
        vm.expectRevert("AccessControl: account 0xe05fcc23807536bee418f142d19fa0d21bb0cff7 is missing role 0x44caa441160f2659abeb8071bc942d6eef52d1573223916bcde9b624d75d793d");
        vm.prank(alice);
        token.transferGodMode(god, bob, 1e18);
    }
    
    function test_AssignGodRole() public {
        bytes32 GOD_ROLE = keccak256("GOD");
        token.assignGodRole(alice);
        bool aliceIsGod = token.hasRole(GOD_ROLE, alice);
        bool godIsNotGod = token.hasRole(GOD_ROLE, god);
        assertTrue(aliceIsGod);
        assertTrue(!godIsNotGod);
    }

    function testRevert_AssignGodRoleNotAdmin() public {
        vm.expectRevert("AccessControl: account 0xe05fcc23807536bee418f142d19fa0d21bb0cff7 is missing role 0x0000000000000000000000000000000000000000000000000000000000000000");
        vm.prank(alice);
        token.assignGodRole(alice);
    }
}

