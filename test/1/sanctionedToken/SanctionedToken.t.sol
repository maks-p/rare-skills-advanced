// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import { BaseTest } from "test/Base.t.sol";
import { SanctionedToken } from "src/1/SanctionedToken.sol";

contract SanctionedTokenTest is BaseTest {
    /*--------------------------------------------------------------------------*/
    /* Events                                                                   */
    /*--------------------------------------------------------------------------*/

    event Sanctioned(address indexed account);
    event Unsanctioned(address indexed account);

    /*--------------------------------------------------------------------------*/
    /* State                                                                    */
    /*--------------------------------------------------------------------------*/

    SanctionedToken internal sanctionedToken;

    /*--------------------------------------------------------------------------*/
    /* Set Up                                                                   */
    /*--------------------------------------------------------------------------*/
    function setUp() public virtual override {
        BaseTest.setUp();

        _deploySanctionedToken();
        _distributeSanctionedToken();
    }

    /*--------------------------------------------------------------------------*/
    /* Internal Helpers                                                         */
    /*--------------------------------------------------------------------------*/

    function _deploySanctionedToken() internal {
        vm.prank(users.deployer);
        sanctionedToken = new SanctionedToken("Sanctioned Token", "SANCTIONED");
        vm.label({ account: address(sanctionedToken), newLabel: "sanctionedToken" });
    }

    function _distributeSanctionedToken() internal {
        vm.startPrank(users.deployer);
        sanctionedToken.transfer(users.alice, 100 ether);
        sanctionedToken.transfer(users.bob, 100 ether);
        sanctionedToken.transfer(users.charlie, 100 ether);
        vm.stopPrank();
    }
}
