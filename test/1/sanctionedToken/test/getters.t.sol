// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import { SanctionedTokenTest } from "../SanctionedToken.t.sol";

contract GettersTest is SanctionedTokenTest {
    function test__IsSanctioned_ReturnsSanctionedAccont() external {
        vm.prank(users.deployer);
        sanctionedToken.sanction(users.alice);

        assertTrue(sanctionedToken.isSanctioned(users.alice));
    }

    function test__IsSanctioned_ReturnsUnsanctionedAccont() external {
        assertFalse(sanctionedToken.isSanctioned(users.bob));
    }

    function test__Admin() external {
        assertEq(sanctionedToken.admin(), users.deployer);
    }
}
