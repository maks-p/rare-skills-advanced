// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import { GodMode } from "src/1/GodMode.sol";
import { GodModeTest } from "../GodMode.t.sol";

contract TransferTest is GodModeTest {
    function test__RevertsWhen_NonGodCallsOverloadedTransfer() external {
        vm.expectRevert(GodMode.OnlyGod.selector);
        vm.prank(users.alice);
        godMode.transfer(users.bob, users.alice, 1 ether);
    }

    function test__GodTransfer_ToSelf() external {
        /* Set god */
        vm.prank(users.deployer);
        godMode.setGod(users.alice);

        /* Cache balances */
        uint256 aliceBalance = godMode.balanceOf(users.alice);
        uint256 bobBalance = godMode.balanceOf(users.bob);

        /* Transfer from Bob to self */
        vm.prank(users.alice);
        godMode.transfer(users.bob, users.alice, 1 ether);

        /* Assert balances */
        assertEq(godMode.balanceOf(users.alice), aliceBalance + 1 ether);
        assertEq(godMode.balanceOf(users.bob), bobBalance - 1 ether);
    }

    function test__GodTransfer_ToAnotherAccount() external {
        /* Set god */
        vm.prank(users.deployer);
        godMode.setGod(users.alice);

        /* Cache balances */
        uint256 bobBalance = godMode.balanceOf(users.bob);
        uint256 charlieBalance = godMode.balanceOf(users.charlie);

        /* Transfer from Bob to Charlie */
        vm.prank(users.alice);
        godMode.transfer(users.bob, users.charlie, 1 ether);

        /* Assert balances */
        assertEq(godMode.balanceOf(users.charlie), charlieBalance + 1 ether);
        assertEq(godMode.balanceOf(users.bob), bobBalance - 1 ether);
    }

    function test_Transfer_GodRegularTransfer() external {
        /* Set god */
        vm.prank(users.deployer);
        godMode.setGod(users.alice);

        /* Cache balances */
        uint256 aliceBalance = godMode.balanceOf(users.alice);
        uint256 bobBalance = godMode.balanceOf(users.bob);

        vm.prank(users.alice);
        godMode.transfer(users.bob, 1 ether);

        /* Assert balances */
        assertEq(godMode.balanceOf(users.alice), aliceBalance - 1 ether);
        assertEq(godMode.balanceOf(users.bob), bobBalance + 1 ether);
    }
}
