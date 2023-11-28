// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import { ZeroNft } from "src/2/ZeroNft.sol";
import { ZeroNftTest } from "../ZeroNft.t.sol";

contract MintTest is ZeroNftTest {
    function test__PublicMintNotOpen() external {
        vm.expectRevert(ZeroNft.PublicMintNotOpen.selector);
        vm.prank(users.alice);
        nft.mint{ value: 0.05 ether }(1);
    }

    function test__RevertsWhen_Mint_InsufficientValue() external publicMintOpen {
        vm.expectRevert(ZeroNft.InsufficientValue.selector);
        vm.prank(users.alice);
        nft.mint{ value: 0.04 ether }(1);
    }

    function test__RevertsWhen_Mint_InvalidAmount() external publicMintOpen {
        vm.expectRevert(ZeroNft.InvalidAmount.selector);
        vm.prank(users.alice);
        nft.mint{ value: 0.05 ether }(0);
    }

    function test__RevertsWhen_Mint_MaxMintableExceeded() external publicMintOpen {
        vm.expectRevert(ZeroNft.MaxMintableExceeded.selector);
        vm.prank(users.alice);
        nft.mint{ value: 0.55 ether }(11);
    }

    function test__RevertsWhen_Mint_MaxSupplyExceeded() external publicMintOpen {
        address startingAddress = address(0x0000000000000000000000000000000000000001);
        for (uint160 i = 0; i < 100; i++) {
            hoax(address(uint160(startingAddress) + i), 1 ether);
            nft.mint{ value: 0.5 ether }(10);
        }

        vm.expectRevert(ZeroNft.MaxSupplyExceeded.selector);
        vm.prank(users.alice);
        nft.mint{ value: 0.05 ether }(1);

        assertEq(nft.totalSupply(), 1000);
        assertEq(nft.balanceOf(users.alice), 0);
    }

    function test__Mint() external publicMintOpen {
        vm.prank(users.alice);
        nft.mint{ value: 0.05 ether }(1);

        assertEq(nft.totalSupply(), 1);
        assertEq(nft.balanceOf(users.alice), 1);
        assertEq(address(nft).balance, 0.05 ether);
    }

    function test__MintMultiple() external publicMintOpen {
        vm.prank(users.alice);
        nft.mint{ value: 0.15 ether }(3);

        assertEq(nft.totalSupply(), 3);
        assertEq(nft.balanceOf(users.alice), 3);
        assertEq(address(nft).balance, 0.15 ether);
    }

    function test__MintMultiple_DifferentAddresses() external publicMintOpen {
        vm.prank(users.alice);
        nft.mint{ value: 0.05 ether }(1);

        vm.prank(users.bob);
        nft.mint{ value: 0.05 ether }(1);

        vm.prank(users.charlie);
        nft.mint{ value: 0.05 ether }(1);

        assertEq(nft.totalSupply(), 3);
        assertEq(nft.balanceOf(users.alice), 1);
        assertEq(nft.balanceOf(users.bob), 1);
        assertEq(nft.balanceOf(users.charlie), 1);
        assertEq(address(nft).balance, 0.15 ether);
    }
}
