// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import { SanctionedToken } from "src/1/SanctionedToken.sol";
import { SanctionedTokenTest } from "../SanctionedToken.t.sol";

contract TransferTest is SanctionedTokenTest {
    function test__RevertsWhen_Transfer_ToUnsanctionedAccount() external {
        vm.prank(users.deployer);
        sanctionedToken.sanction(users.alice);

        uint256 aliceBalance = sanctionedToken.balanceOf(users.alice);

        vm.expectRevert(abi.encodeWithSelector(SanctionedToken.SanctionedAddress.selector, address(users.alice)));
        vm.prank(users.alice);
        sanctionedToken.transfer(users.bob, 1 ether);

        assertEq(sanctionedToken.balanceOf(users.alice), aliceBalance);
    }

    function test__RevertsWhen_Transfer_FromUnsactionedAccount() external {
        vm.prank(users.deployer);
        sanctionedToken.sanction(users.alice);

        uint256 aliceBalance = sanctionedToken.balanceOf(users.alice);

        vm.expectRevert(abi.encodeWithSelector(SanctionedToken.SanctionedAddress.selector, address(users.alice)));
        vm.prank(users.alice);
        sanctionedToken.transfer(users.bob, 1 ether);

        assertEq(sanctionedToken.balanceOf(users.alice), aliceBalance);
    }

    function test__Transfer() external {
        uint256 aliceBalance = sanctionedToken.balanceOf(users.alice);
        uint256 bobBalance = sanctionedToken.balanceOf(users.bob);

        vm.prank(users.alice);
        sanctionedToken.transfer(users.bob, 1 ether);

        assertEq(sanctionedToken.balanceOf(users.alice), aliceBalance - 1 ether);
        assertEq(sanctionedToken.balanceOf(users.bob), bobBalance + 1 ether);
    }
}
