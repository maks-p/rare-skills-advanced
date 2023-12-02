// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import { BaseTest } from "test/Base.t.sol";
import { Enumerable } from "src/2/Enumerable.sol";

contract EnumerableTest is BaseTest {
    /*--------------------------------------------------------------------------*/
    /* Events                                                                   */
    /*--------------------------------------------------------------------------*/

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /*--------------------------------------------------------------------------*/
    /* State                                                                    */
    /*--------------------------------------------------------------------------*/

    Enumerable internal nft;

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
        nft = new Enumerable();
        vm.label({ account: address(nft), newLabel: "Enumerable NFT" });
    }
}
