// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import { Enumerable } from "src/2/Enumerable.sol";
import { EnumerableTest } from "../Enumerable.t.sol";

contract MintTest is EnumerableTest {
    function test__RevertsWhen_Mint_InsufficientValue() external {
        vm.expectRevert(Enumerable.InsufficientValue.selector);
        vm.prank(users.alice);
        nft.mint{ value: 0.04 ether }(1);
    }

    function test__RevertsWhen_Mint_InvalidAmount() external {
        vm.expectRevert(Enumerable.InvalidAmount.selector);
        vm.prank(users.alice);
        nft.mint{ value: 0.05 ether }(0);
    }

    function test__RevertsWhen_Mint_MaxMintableExceeded() external {
        vm.expectRevert(Enumerable.MaxMintableExceeded.selector);
        vm.prank(users.alice);
        nft.mint{ value: 0.55 ether }(11);
    }

    function test__RevertsWhen_Mint_MaxSupplyExceeded() external {
        address startingAddress = address(0x0000000000000000000000000000000000000001);
        for (uint160 i = 0; i < 50; i++) {
            hoax(address(uint160(startingAddress) + i), 1 ether);
            nft.mint{ value: 0.5 ether }(2);
        }

        vm.expectRevert(Enumerable.MaxSupplyExceeded.selector);
        vm.prank(users.alice);
        nft.mint{ value: 0.05 ether }(1);

        assertEq(nft.totalSupply(), 100);
        assertEq(nft.balanceOf(users.alice), 0);
    }

    function test__Mint() external {
        vm.prank(users.alice);
        nft.mint{ value: 0.05 ether }(1);

        assertEq(nft.ownerOf(1), users.alice);
        assertEq(nft.tokenOfOwnerByIndex(users.alice, 0), 1);
        assertEq(nft.tokenByIndex(0), 1);
        assertEq(nft.totalSupply(), 1);
        assertEq(nft.balanceOf(users.alice), 1);
        assertEq(address(nft).balance, 0.05 ether);
    }

    function test__MintMultiple() external {
        vm.prank(users.alice);
        nft.mint{ value: 0.1 ether }(2);

        assertEq(nft.totalSupply(), 2);
        assertEq(nft.balanceOf(users.alice), 2);
        assertEq(address(nft).balance, 0.1 ether);
    }

    function test__Enumerable() external {
        vm.prank(users.alice);
        nft.mint{ value: 0.05 ether }(1);

        vm.prank(users.bob);
        nft.mint{ value: 0.05 ether }(1);

        vm.prank(users.alice);
        nft.mint{ value: 0.05 ether }(1);

        assertEq(nft.totalSupply(), 3);
        assertEq(nft.balanceOf(users.alice), 2);
        assertEq(nft.balanceOf(users.bob), 1);

        /* Get token ids owned by alice */
        uint256 balanceOf = nft.balanceOf(users.alice);

        uint256[] memory tokenIds = new uint256[](balanceOf);
        for (uint256 i; i < balanceOf; i++) {
            uint256 tokenId = nft.tokenOfOwnerByIndex(users.alice, i);
            tokenIds[i] = tokenId;
            assertEq(nft.ownerOf(tokenId), users.alice);
        }

        assertEq(tokenIds[0], 1);
        assertEq(tokenIds[1], 3);
    }
}
