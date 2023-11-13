// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import { SanctionedToken } from "src/1/SanctionedToken.sol";
import { SanctionedTokenTest } from "../SanctionedToken.t.sol";

contract AdminTest is SanctionedTokenTest {
    function test__RevertsWhen_Sanction_Unauthorized() external {
        vm.expectRevert(SanctionedToken.UnauthorizedCaller.selector);
        vm.prank(users.alice);
        sanctionedToken.sanction(users.alice);
    }

    function test__RevertsWhen_UnSanction_Unauthorized() external {
        vm.prank(users.deployer);
        sanctionedToken.sanction(users.alice);

        vm.expectRevert(SanctionedToken.UnauthorizedCaller.selector);
        vm.prank(users.alice);
        sanctionedToken.unsanction(users.alice);
    }

    function test__Sanction_SanctionsAccount() external {
        /* Setup event */
        vm.expectEmit(true, true, true, true, address(sanctionedToken));
        emit Sanctioned(users.alice);

        vm.prank(users.deployer);
        sanctionedToken.sanction(users.alice);

        assertTrue(sanctionedToken.isSanctioned(users.alice));
    }

    function test__Unsanction_SanctionsAccount() external {
        vm.prank(users.deployer);
        sanctionedToken.sanction(users.alice);

        /* Setup event */
        vm.expectEmit(true, true, true, true, address(sanctionedToken));
        emit Unsanctioned(users.alice);

        vm.prank(users.deployer);
        sanctionedToken.unsanction(users.alice);

        assertFalse(sanctionedToken.isSanctioned(users.alice));
    }
}
