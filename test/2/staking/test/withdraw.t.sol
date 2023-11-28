// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import { Staking } from "src/2/Staking.sol";
import { StakingTest } from "test/2/staking/Staking.t.sol";

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract WithdrawStakedTest is StakingTest {
    function test__RevertsWhen_UnauthorizedCaller() external {
        /* Stake */
        vm.prank(users.alice);
        nft.safeTransferFrom(users.alice, address(staking), 0);

        assertEq(nft.balanceOf(address(staking)), 1);
        assertEq(nft.ownerOf(0), address(staking));

        assertEq(staking.stakingInfo(0).account, users.alice);

        skip(1 days);

        /* Withdraw */
        vm.expectRevert(Staking.UnauthorizedCaller.selector);
        vm.prank(users.bob);
        staking.withdrawERC721(0);
    }

    function test__WithdrawStake() external {
        /* Stake */
        vm.prank(users.alice);
        nft.safeTransferFrom(users.alice, address(staking), 0);

        assertEq(nft.balanceOf(address(staking)), 1);
        assertEq(nft.ownerOf(0), address(staking));

        assertEq(staking.stakingInfo(0).account, users.alice);

        skip(1 days);

        /* Withdraw */
        vm.prank(users.alice);
        staking.withdrawERC721(0);

        assertEq(nft.balanceOf(address(staking)), 0);
        assertEq(nft.ownerOf(0), users.alice);

        assertEq(staking.stakingInfo(0).account, address(0));

        assertEq(IERC20(staking.rewardToken()).balanceOf(users.alice), 10 ether);
    }

    function test__WithdrawStake_AfterRewardsWithdraw() external {
        /* Stake */
        vm.prank(users.alice);
        nft.safeTransferFrom(users.alice, address(staking), 0);

        assertEq(nft.balanceOf(address(staking)), 1);
        assertEq(nft.ownerOf(0), address(staking));

        assertEq(staking.stakingInfo(0).account, users.alice);

        skip(1 days);

        /* Withdraw reward */
        vm.prank(users.alice);
        staking.withdrawRewards(0);

        assertEq(IERC20(staking.rewardToken()).balanceOf(users.alice), 10 ether);

        skip(23 hours);

        /* Withdraw */
        vm.prank(users.alice);
        staking.withdrawERC721(0);

        assertEq(nft.balanceOf(address(staking)), 0);
        assertEq(nft.ownerOf(0), users.alice);

        assertEq(staking.stakingInfo(0).account, address(0));

        assertEq(IERC20(staking.rewardToken()).balanceOf(users.alice), 10 ether);
    }

    function test__WithdrawStake_7_days() external {
        /* Stake */
        vm.prank(users.alice);
        nft.safeTransferFrom(users.alice, address(staking), 0);

        assertEq(nft.balanceOf(address(staking)), 1);
        assertEq(nft.ownerOf(0), address(staking));

        assertEq(staking.stakingInfo(0).account, users.alice);

        skip(7 days);

        /* Withdraw */
        vm.prank(users.alice);
        staking.withdrawERC721(0);

        assertEq(nft.balanceOf(address(staking)), 0);
        assertEq(nft.ownerOf(0), users.alice);

        assertEq(staking.stakingInfo(0).account, address(0));

        assertEq(IERC20(staking.rewardToken()).balanceOf(users.alice), 70 ether);
    }

    function test__WithdrawStake_7_days_RoundDown() external {
        /* Stake */
        vm.prank(users.alice);
        nft.safeTransferFrom(users.alice, address(staking), 0);

        assertEq(nft.balanceOf(address(staking)), 1);
        assertEq(nft.ownerOf(0), address(staking));

        assertEq(staking.stakingInfo(0).account, users.alice);

        skip(7 days + 23 hours + 59 minutes + 59 seconds);

        /* Withdraw */
        vm.prank(users.alice);
        staking.withdrawERC721(0);

        assertEq(nft.balanceOf(address(staking)), 0);
        assertEq(nft.ownerOf(0), users.alice);

        assertEq(staking.stakingInfo(0).account, address(0));

        assertEq(IERC20(staking.rewardToken()).balanceOf(users.alice), 70 ether);
    }
}
