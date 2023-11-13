// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import { GodModeTest } from "../GodMode.t.sol";

contract GettersTest is GodModeTest {
    function test__God_ReturnsCorrectAccount() external {
        vm.prank(users.deployer);
        godMode.setGod(users.alice);

        assertEq(godMode.god(), users.alice);
    }

    function test__God_ReturnsAddressZero() external {
        assertEq(godMode.god(), address(0));
    }

    function test__Admin() external {
        assertEq(godMode.admin(), users.deployer);
    }
}
