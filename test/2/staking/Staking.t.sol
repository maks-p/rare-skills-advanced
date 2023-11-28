// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import { BaseTest } from "test/Base.t.sol";
import { Staking } from "src/2/Staking.sol";
import { ZeroNft } from "src/2/ZeroNft.sol";
import { RewardToken } from "src/2/RewardToken.sol";

contract StakingTest is BaseTest {
    bytes32 constant MERKLE_ROOT = 0xbbd05a79246fc22f82cc928695be86973e4fa4e65c3e630e68293434f2d42ee2;

    /*--------------------------------------------------------------------------*/
    /* Events                                                                   */
    /*--------------------------------------------------------------------------*/

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /*--------------------------------------------------------------------------*/
    /* State                                                                    */
    /*--------------------------------------------------------------------------*/

    ZeroNft internal nft;
    Staking internal staking;

    /*--------------------------------------------------------------------------*/
    /* Set Up                                                                   */
    /*--------------------------------------------------------------------------*/

    function setUp() public virtual override {
        BaseTest.setUp();
        _deployZeroNft();
        _deploy();

        _mintNft();
    }

    /*--------------------------------------------------------------------------*/
    /* Internal Helpers                                                         */
    /*--------------------------------------------------------------------------*/

    function _deployZeroNft() internal {
        vm.prank(users.deployer);

        nft = new ZeroNft(MERKLE_ROOT);
        vm.label({ account: address(nft), newLabel: "Zero NFT" });

        vm.warp(nft.publicMintStart());
    }

    function _deploy() internal {
        vm.prank(users.deployer);
        staking = new Staking(address(nft));
        vm.label({ account: address(staking), newLabel: "Staking" });
    }

    function _mintNft() internal {
        vm.prank(users.alice);
        nft.mint{ value: 0.05 ether }(1);

        vm.prank(users.bob);
        nft.mint{ value: 0.05 ether }(1);

        vm.prank(users.charlie);
        nft.mint{ value: 0.05 ether }(1);

        vm.prank(users.alice);
        nft.mint{ value: 0.05 ether }(1);
    }
}
