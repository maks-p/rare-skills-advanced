// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import { BaseTest } from "test/Base.t.sol";
import { GodMode } from "src/1/GodMode.sol";

contract GodModeTest is BaseTest {
    /*--------------------------------------------------------------------------*/
    /* Events                                                                   */
    /*--------------------------------------------------------------------------*/

    event NewGod(address indexed account);

    /*--------------------------------------------------------------------------*/
    /* State                                                                    */
    /*--------------------------------------------------------------------------*/

    GodMode internal godMode;

    /*--------------------------------------------------------------------------*/
    /* Set Up                                                                   */
    /*--------------------------------------------------------------------------*/

    function setUp() public virtual override {
        BaseTest.setUp();

        _deployGodMode();
        _distributegodMode();
    }

    /*--------------------------------------------------------------------------*/
    /* Internal Helpers                                                         */
    /*--------------------------------------------------------------------------*/

    function _deployGodMode() internal {
        vm.prank(users.deployer);
        godMode = new GodMode("God Mode", "GOD");
        vm.label({ account: address(godMode), newLabel: "GodMode" });
    }

    function _distributegodMode() internal {
        vm.startPrank(users.deployer);
        godMode.transfer(users.alice, 100 ether);
        godMode.transfer(users.bob, 100 ether);
        godMode.transfer(users.charlie, 100 ether);
        vm.stopPrank();
    }
}
