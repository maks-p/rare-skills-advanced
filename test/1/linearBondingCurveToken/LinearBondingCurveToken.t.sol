// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import { BaseTest } from "test/Base.t.sol";
import { LinearBondingCurveToken } from "src/1/LinearBondingCurveToken.sol";

contract LinearBondingCurveTokenTest is BaseTest {
    /*--------------------------------------------------------------------------*/
    /* Events                                                                   */
    /*--------------------------------------------------------------------------*/

    event TokensPurchased(address indexed account, uint256 amount);
    event TokensSold(address indexed account, uint256 amount);

    /*--------------------------------------------------------------------------*/
    /* State                                                                    */
    /*--------------------------------------------------------------------------*/

    LinearBondingCurveToken internal linearBondingCurveToken;

    /*--------------------------------------------------------------------------*/
    /* Set Up                                                                   */
    /*--------------------------------------------------------------------------*/

    function setUp() public virtual override {
        BaseTest.setUp();

        _deployLinearBondingCurveToken();
    }

    /*--------------------------------------------------------------------------*/
    /* Internal Helpers                                                         */
    /*--------------------------------------------------------------------------*/

    function _deployLinearBondingCurveToken() internal {
        vm.prank(users.deployer);
        linearBondingCurveToken = new LinearBondingCurveToken(
            "Linear Bonding Curve Token",
            "LBCT"
        );
        vm.label({ account: address(linearBondingCurveToken), newLabel: "LinearBondingCurveToken" });
    }
}
