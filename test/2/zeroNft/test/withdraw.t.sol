// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import { ZeroNft } from "src/2/ZeroNft.sol";
import { ZeroNftTest } from "../ZeroNft.t.sol";

contract WithdrawTest is ZeroNftTest {
    function test__Withdraw() external publicMintOpen {
        vm.prank(users.alice);
        nft.mint{ value: 0.05 ether }(1);

        /* Withdraw */
        uint256 startBal = address(users.deployer).balance;

        vm.prank(users.deployer);
        nft.withdraw(users.deployer, 0.05 ether);

        assertEq(address(nft).balance, 0);
        assertEq(address(users.deployer).balance, startBal + 0.05 ether);
    }
}
