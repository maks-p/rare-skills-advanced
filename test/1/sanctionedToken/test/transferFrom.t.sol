// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import { SanctionedToken } from "src/1/SanctionedToken.sol";
import { SanctionedTokenTest } from "../SanctionedToken.t.sol";

contract TransferFromTest is SanctionedTokenTest {
    function test__RevertsWhen_TransferFrom_ToUnsanctionedAccount() external {
        /* Approve token contract to from alice's account */
        vm.prank(users.alice);
        sanctionedToken.approve(users.deployer, 1 ether);

        /* Sanction bob */
        vm.prank(users.deployer);
        sanctionedToken.sanction(users.bob);

        uint256 bobBalance = sanctionedToken.balanceOf(users.bob);

        /* Attempt transferFrom */
        vm.expectRevert(abi.encodeWithSelector(SanctionedToken.SanctionedAddress.selector, address(users.bob)));
        vm.prank(users.deployer);
        sanctionedToken.transferFrom(users.alice, users.bob, 1 ether);

        assertEq(sanctionedToken.balanceOf(users.bob), bobBalance);
    }

    function test__RevertsWhen_TransferFrom_FromUnsactionedAccount() external {
        /* Approve token contract to from alice's account */
        vm.prank(users.alice);
        sanctionedToken.approve(users.deployer, 1 ether);

        /* Sanction alice */
        vm.prank(users.deployer);
        sanctionedToken.sanction(users.alice);

        uint256 aliceBalance = sanctionedToken.balanceOf(users.alice);

        /* Attempt transferFrom */
        vm.expectRevert(abi.encodeWithSelector(SanctionedToken.SanctionedAddress.selector, address(users.alice)));
        vm.prank(users.deployer);
        sanctionedToken.transferFrom(users.alice, users.bob, 1 ether);

        assertEq(sanctionedToken.balanceOf(users.bob), aliceBalance);
    }

    function test__TransferFrom() external {
        /* Approve token contract to from alice's account */
        vm.prank(users.alice);
        sanctionedToken.approve(users.deployer, 1 ether);

        uint256 aliceBalance = sanctionedToken.balanceOf(users.alice);
        uint256 bobBalance = sanctionedToken.balanceOf(users.bob);

        /* Nobody sanctioned */
        vm.prank(users.deployer);
        sanctionedToken.transferFrom(users.alice, users.bob, 1 ether);

        assertEq(sanctionedToken.balanceOf(users.alice), aliceBalance - 1 ether);
        assertEq(sanctionedToken.balanceOf(users.bob), bobBalance + 1 ether);
    }
}
