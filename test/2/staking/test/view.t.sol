// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import { StakingTest } from "test/2/staking/Staking.t.sol";

contract StakeTest is StakingTest {
    function test__StakingToken() external {
        assertEq(staking.stakingToken(), address(nft));
    }

    function test__StakingInfo() external {
        vm.prank(users.alice);
        nft.safeTransferFrom(users.alice, address(staking), 0);

        assertEq(nft.balanceOf(address(staking)), 1);
        assertEq(nft.ownerOf(0), address(staking));
    }

    function test__CurrentReward_SingleStake() external {
        vm.prank(users.alice);
        nft.safeTransferFrom(users.alice, address(staking), 0);
        assertEq(staking.currentReward(0), 0);

        skip(1 days);
        assertEq(staking.currentReward(0), 10 ether);

        skip(1 days);
        assertEq(staking.currentReward(0), 20 ether);

        skip(1 days - 1);
        assertEq(staking.currentReward(0), 20 ether);
    }
}
