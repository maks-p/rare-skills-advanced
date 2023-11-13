// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import { GodMode } from "src/1/GodMode.sol";
import { GodModeTest } from "../GodMode.t.sol";

contract AdminTest is GodModeTest {
    function test__RevertsWhen__SetGod_Unauthorized() external {
        vm.expectRevert(GodMode.UnauthorizedCaller.selector);
        vm.prank(users.alice);
        godMode.setGod(users.alice);
    }

    function test__SetGod() external {
        /* Setup event */
        vm.expectEmit(true, true, true, true, address(godMode));
        emit NewGod(users.alice);

        vm.prank(users.deployer);
        godMode.setGod(users.alice);

        assertEq(godMode.god(), users.alice);
    }

    function test__SetGod_Unset() external {
        vm.prank(users.deployer);
        godMode.setGod(users.alice);

        assertEq(godMode.god(), users.alice);

        /* Setup event */
        vm.expectEmit(true, true, true, true, address(godMode));
        emit NewGod(address(0));

        vm.prank(users.deployer);
        godMode.setGod(address(0));

        assertEq(godMode.god(), address(0));
    }
}
