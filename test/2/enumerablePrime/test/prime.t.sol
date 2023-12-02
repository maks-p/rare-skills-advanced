// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import { EnumerablePrime } from "src/2/EnumerablePrime.sol";
import { EnumerablePrimeTest } from "../EnumerablePrime.t.sol";

contract PrimeTest is EnumerablePrimeTest {
    function test__Prime_UpTo11() external {
        vm.prank(users.alice);
        nft.mint{ value: 0.55 ether }(11);

        assertEq(nft.ownerOf(11), users.alice);
        assertEq(nft.balanceOf(users.alice), 11);

        uint256 prime = nft.prime(users.alice);
        assertEq(prime, 5);
    }

    function test__Prime_UpTo100() external {
        vm.prank(users.alice);
        nft.mint{ value: 5 ether }(100);

        assertEq(nft.ownerOf(100), users.alice);
        assertEq(nft.balanceOf(users.alice), 100);

        uint256 prime = nft.prime(users.alice);
        assertEq(prime, 25);
    }
}
