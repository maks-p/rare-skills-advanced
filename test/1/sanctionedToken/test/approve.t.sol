// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import { SanctionedToken } from "src/1/SanctionedToken.sol";
import { SanctionedTokenTest } from "../SanctionedToken.t.sol";

contract ApproveTest is SanctionedTokenTest {
    function test__RevertsWhen_Approve_UnsanctionedSpender() external {
        /* Sanction bob */
        vm.prank(users.deployer);
        sanctionedToken.sanction(users.bob);

        /* Attempt approval */
        vm.expectRevert(abi.encodeWithSelector(SanctionedToken.SanctionedAddress.selector, address(users.bob)));
        vm.prank(users.alice);
        sanctionedToken.approve(users.bob, 1 ether);

        assertEq(sanctionedToken.allowance(users.alice, users.bob), 0);
    }

    function test__RevertsWhen_Approve_FromUnsactionedAccount() external {
        /* Sanction alice */
        vm.prank(users.deployer);
        sanctionedToken.sanction(users.alice);

        /* Attempt approval */
        vm.expectRevert(abi.encodeWithSelector(SanctionedToken.SanctionedAddress.selector, address(users.alice)));
        vm.prank(users.alice);
        sanctionedToken.approve(users.bob, 1 ether);

        assertEq(sanctionedToken.allowance(users.alice, users.bob), 0);
    }

    function test__Approve() external {
        /* Approve token contract to from alice's account */
        vm.prank(users.alice);
        sanctionedToken.approve(users.deployer, 1 ether);

        assertEq(sanctionedToken.allowance(users.alice, users.deployer), 1 ether);

        uint256 deployerBalance = sanctionedToken.balanceOf(users.deployer);
        uint256 aliceBalance = sanctionedToken.balanceOf(users.alice);

        /* Deployer transfers from alice's account */
        vm.prank(users.deployer);
        sanctionedToken.transferFrom(users.alice, users.deployer, 1 ether);

        assertEq(sanctionedToken.balanceOf(users.deployer), deployerBalance + 1 ether);
        assertEq(sanctionedToken.balanceOf(users.alice), aliceBalance - 1 ether);
    }
}
