// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.13;

import "forge-std/Test.sol";

import "src/NFTWithStaking.sol";

contract NFTWithStakingTest is Test {
    TokenBoy token;
    NFTBoy nft;
    StakingBoy staking;

    uint256 internal alicePrivateKey;
    address internal alice;
    
    function setUp() public {
        token = new TokenBoy();
        nft = new NFTBoy();
        staking = new StakingBoy(
            address(token),
            address(nft)
        );

        alicePrivateKey = 0xA11CE;
        alice  = vm.addr(alicePrivateKey);

        bytes32 MINTER_ROLE = keccak256("MINTER_ROLE");

        token.grantRole(MINTER_ROLE, address(staking));
    }

    function test_canStake() public {
        nft.mint(0);
        nft.safeTransferFrom(address(this), address(staking), 0);
        assertEq(staking.balanceOf(address(this)), 1);
    }

    function test_canWithdraw() public {
        vm.startPrank(alice);
        nft.mint(0);
        nft.safeTransferFrom(address(alice), address(staking), 0);
        staking.withdrawNFT(0);
        assertEq(nft.balanceOf(address(alice)), 1);
    }

    function test_rewardsGrowEveryDay() public {
        vm.startPrank(alice);
        nft.mint(0);
        nft.safeTransferFrom(address(alice), address(staking), 0);
        
    }

    function test_getRewards() public {
        vm.startPrank(alice);
        nft.mint(0);
        nft.safeTransferFrom(address(alice), address(staking), 0);
        
        skip(86400);
        staking.withdrawRewards();
        assertEq(token.balanceOf(alice), 10e18);
    }

    function test_getRewardsMultipleStaking() public {
        vm.startPrank(alice);
        nft.mint(0);
        nft.safeTransferFrom(address(alice), address(staking), 0);
        
        //Token 0: 24 hours
        skip(86400);
        nft.mint(1);
        nft.safeTransferFrom(address(alice), address(staking), 1);

        //Token 0: 36 hours, Token 1: 12 hours
        skip(43200);
        nft.mint(2);
        nft.safeTransferFrom(address(alice), address(staking), 2);

        //Token 1: 48 hours, Token 2: 24 hours, Token 3: 12 hours
        skip(43200);

        staking.withdrawRewards();
        //total days: 3
        assertEq(token.balanceOf(alice), 30e18);

        assertEq(staking.timeSinceLastRewardCollected(0), 0);
        assertEq(staking.timeSinceLastRewardCollected(1), 0);
        //12 hours unrewarded time remains for token 2
        assertEq(staking.timeSinceLastRewardCollected(2), 43200);
    }

    function test_updateTimeSinceRewardIncreasesInMultipleOfDay() public {
        vm.startPrank(alice);
        nft.mint(0);
        nft.safeTransferFrom(address(alice), address(staking), 0);
        
        //36 hours
        skip(86400 + 43200);
        //rewarded for first 24 hours, unrewarded time: 12 hours 
        staking.withdrawRewards();

        assertEq(staking.timeSinceLastRewardCollected(0), 43200);
    }

    function test_withdrawalSendRewardAmount() public {
        vm.startPrank(alice);
        nft.mint(0);
        nft.safeTransferFrom(address(alice), address(staking), 0);
        
        skip(86400);
        staking.withdrawNFT(0);
        assertEq(token.balanceOf(alice), 10e18);
    }

    function testRevert_wrongNft() public {
        NFTBoy wrongNFT = new NFTBoy();
        vm.startPrank(alice);
        wrongNFT.mint(0);
        vm.expectRevert("Wrong NFT");
        wrongNFT.safeTransferFrom(address(alice), address(staking), 0);
    }

    function testRevert_withdrawUnstakedNFT() public {
        vm.startPrank(alice);
        nft.mint(0);
        vm.expectRevert("Invalid TokenID");
        staking.withdrawNFT(0);
    }
}