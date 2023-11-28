// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import { BaseTest } from "test/Base.t.sol";
import { ZeroNft } from "src/2/ZeroNft.sol";

contract ZeroNftTest is BaseTest {
    bytes32 constant MERKLE_ROOT = 0xbbd05a79246fc22f82cc928695be86973e4fa4e65c3e630e68293434f2d42ee2;

    /*--------------------------------------------------------------------------*/
    /* Events                                                                   */
    /*--------------------------------------------------------------------------*/

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /*--------------------------------------------------------------------------*/
    /* Modifiers                                                                */
    /*--------------------------------------------------------------------------*/

    modifier publicMintOpen() {
        vm.warp(nft.publicMintStart());
        _;
    }

    /*--------------------------------------------------------------------------*/
    /* State                                                                    */
    /*--------------------------------------------------------------------------*/

    ZeroNft internal nft;

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
        nft = new ZeroNft(MERKLE_ROOT);
        vm.label({ account: address(nft), newLabel: "Zero NFT" });
    }
}
