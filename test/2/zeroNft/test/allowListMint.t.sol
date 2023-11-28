// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import { ZeroNft } from "src/2/ZeroNft.sol";
import { ZeroNftTest } from "../ZeroNft.t.sol";

contract TransferTest is ZeroNftTest {
    address public allowListMinter0 = address(0x0000000000000000000000000000000000000001);
    address public allowListMinter1 = address(0x0000000000000000000000000000000000000002);

    function test__RevertsWhen_InvalidProof_User() external {
        bytes32[] memory proof = new bytes32[](3);
        proof[0] = 0x33315c1f1a6d5b277b76b7fd6d2e3fe0edab24f1a5660e6f947129816fcdb250;
        proof[1] = 0x68e70e602c1e40c237fd5767c6c84d5e4823c508813c69ddae4e2fbe28669d0b;
        proof[2] = 0x01f81368740181c69073fe2541cba98f5c2d1132b0f9cf3efd26d384b5a4e3ff;

        uint256 index = 0;
        uint256 amount = 2;

        vm.expectRevert(ZeroNft.InvalidProof.selector);
        vm.prank(users.alice); // Invalid User
        nft.allowListMint{ value: 0.06 ether }(proof, index, amount);
    }

    function test__RevertsWhen_InvalidProof_Amount() external {
        bytes32[] memory proof = new bytes32[](3);
        proof[0] = 0x33315c1f1a6d5b277b76b7fd6d2e3fe0edab24f1a5660e6f947129816fcdb250;
        proof[1] = 0x68e70e602c1e40c237fd5767c6c84d5e4823c508813c69ddae4e2fbe28669d0b;
        proof[2] = 0x01f81368740181c69073fe2541cba98f5c2d1132b0f9cf3efd26d384b5a4e3ff;

        uint256 index = 0;
        uint256 amount = 3; // Invalid Amount

        assertEq(nft.totalSupply(), 0);
        assertEq(nft.balanceOf(allowListMinter0), 0);

        vm.expectRevert(ZeroNft.InvalidProof.selector);
        hoax(allowListMinter0, 1 ether);
        nft.allowListMint{ value: 0.09 ether }(proof, index, amount);
    }

    function test__RevertsWhen_InvalidProof_Index() external {
        bytes32[] memory proof = new bytes32[](3);
        proof[0] = 0x33315c1f1a6d5b277b76b7fd6d2e3fe0edab24f1a5660e6f947129816fcdb250;
        proof[1] = 0x68e70e602c1e40c237fd5767c6c84d5e4823c508813c69ddae4e2fbe28669d0b;
        proof[2] = 0x01f81368740181c69073fe2541cba98f5c2d1132b0f9cf3efd26d384b5a4e3ff;

        uint256 index = 1; // Invalid index
        uint256 amount = 2;

        assertEq(nft.totalSupply(), 0);
        assertEq(nft.balanceOf(allowListMinter0), 0);

        vm.expectRevert(ZeroNft.InvalidProof.selector);
        hoax(allowListMinter0, 1 ether);
        nft.allowListMint{ value: 0.06 ether }(proof, index, amount);
    }

    function test__RevertsWhen_InvalidProof_SecondAttempt() external {
        bytes32[] memory proof = new bytes32[](3);
        proof[0] = 0x33315c1f1a6d5b277b76b7fd6d2e3fe0edab24f1a5660e6f947129816fcdb250;
        proof[1] = 0x68e70e602c1e40c237fd5767c6c84d5e4823c508813c69ddae4e2fbe28669d0b;
        proof[2] = 0x01f81368740181c69073fe2541cba98f5c2d1132b0f9cf3efd26d384b5a4e3ff;

        uint256 index = 0;
        uint256 amount = 2;

        assertEq(nft.totalSupply(), 0);
        assertEq(nft.balanceOf(allowListMinter0), 0);

        hoax(allowListMinter0, 1 ether);
        nft.allowListMint{ value: 0.06 ether }(proof, index, amount);

        assertEq(nft.totalSupply(), 2);
        assertEq(nft.balanceOf(allowListMinter0), 2);

        vm.expectRevert(ZeroNft.AlreadyClaimed.selector);
        hoax(allowListMinter0, 1 ether);
        nft.allowListMint{ value: 0.06 ether }(proof, index, amount);
    }

    function test__AllowListMint() external {
        bytes32[] memory proof = new bytes32[](3);
        proof[0] = 0x33315c1f1a6d5b277b76b7fd6d2e3fe0edab24f1a5660e6f947129816fcdb250;
        proof[1] = 0x68e70e602c1e40c237fd5767c6c84d5e4823c508813c69ddae4e2fbe28669d0b;
        proof[2] = 0x01f81368740181c69073fe2541cba98f5c2d1132b0f9cf3efd26d384b5a4e3ff;

        uint256 index = 0;
        uint256 amount = 2;

        assertEq(nft.totalSupply(), 0);
        assertEq(nft.balanceOf(allowListMinter0), 0);

        hoax(allowListMinter0, 1 ether);
        nft.allowListMint{ value: 0.06 ether }(proof, index, amount);

        assertEq(nft.totalSupply(), 2);
        assertEq(nft.balanceOf(allowListMinter0), 2);
    }
}
