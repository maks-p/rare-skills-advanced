// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import { StakingTest } from "test/2/staking/Staking.t.sol";

contract StakeTest is StakingTest {
    function test__Stake() external {
        vm.prank(users.alice);
        nft.safeTransferFrom(users.alice, address(staking), 0);

        assertEq(nft.balanceOf(address(staking)), 1);
        assertEq(nft.ownerOf(0), address(staking));

        assertEq(staking.stakingInfo(0).account, users.alice);
        assertEq(staking.stakingInfo(0).depositTime, block.timestamp);
    }

    function test__StakeMultiple() external {
        vm.prank(users.alice);
        nft.safeTransferFrom(users.alice, address(staking), 0);

        assertEq(nft.balanceOf(address(staking)), 1);
        assertEq(nft.ownerOf(0), address(staking));

        assertEq(staking.stakingInfo(0).account, users.alice);
        assertEq(staking.stakingInfo(0).depositTime, block.timestamp);

        vm.prank(users.bob);
        nft.safeTransferFrom(users.bob, address(staking), 1);

        assertEq(nft.balanceOf(address(staking)), 2);
        assertEq(nft.ownerOf(1), address(staking));

        assertEq(staking.stakingInfo(1).account, users.bob);
        assertEq(staking.stakingInfo(1).depositTime, block.timestamp);
    }

    function test__StakeMultiple_SingleAccount() external {
        vm.prank(users.alice);
        nft.safeTransferFrom(users.alice, address(staking), 0);

        vm.prank(users.alice);
        nft.safeTransferFrom(users.alice, address(staking), 3);

        assertEq(nft.balanceOf(address(staking)), 2);
        assertEq(nft.ownerOf(0), address(staking));
        assertEq(nft.ownerOf(3), address(staking));

        assertEq(staking.stakingInfo(0).account, users.alice);
        assertEq(staking.stakingInfo(0).depositTime, block.timestamp);

        assertEq(staking.stakingInfo(3).account, users.alice);
        assertEq(staking.stakingInfo(3).depositTime, block.timestamp);
    }
}
