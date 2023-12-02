// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import { BaseTest } from "test/Base.t.sol";
import { EnumerablePrime } from "src/2/EnumerablePrime.sol";

contract EnumerablePrimeTest is BaseTest {
    /*--------------------------------------------------------------------------*/
    /* Events                                                                   */
    /*--------------------------------------------------------------------------*/

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /*--------------------------------------------------------------------------*/
    /* State                                                                    */
    /*--------------------------------------------------------------------------*/

    EnumerablePrime internal nft;

    /*--------------------------------------------------------------------------*/
    /* Set Up                                                                   */
    /*--------------------------------------------------------------------------*/

    function setUp() public virtual override {
        BaseTest.setUp();
        _deploy();
    }

    /*--------------------------------------------------------------------------*/
    /* Internal Helpers                                                         */
    /*--------------------------------------------------------------------------*/

    function _deploy() internal {
        vm.prank(users.deployer);
        nft = new EnumerablePrime();
        vm.label({ account: address(nft), newLabel: "Enumerable Prime" });
    }
}
