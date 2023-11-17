// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import { LinearBondingCurveToken } from "src/1/LinearBondingCurveToken.sol";
import { LinearBondingCurveTokenTest } from "../LinearBondingCurveToken.t.sol";

contract BuyTest is LinearBondingCurveTokenTest {
    function test__RevertsWhen_Buy_MinimumNotMet() external {
        vm.expectRevert(LinearBondingCurveToken.MinimumNotMet.selector);
        vm.prank(users.alice);
        linearBondingCurveToken.buy{ value: 0.5 ether }(1 ether + 1);
    }

    function test__RevertsWhen_Buy_InvalidAmount() external {
        vm.expectRevert(LinearBondingCurveToken.InvalidAmount.selector);
        vm.prank(users.alice);
        linearBondingCurveToken.buy{ value: 0 }(0);
    }

    function test__Buy() external {
        /* Buy 1 token for 0.5 ETH */
        vm.prank(users.alice);
        uint256 amount1 = linearBondingCurveToken.buy{ value: 0.5 ether }(0);
        assertEq(amount1, 1 ether);
        assertEq(linearBondingCurveToken.balanceOf(users.alice), 1 ether);
        assertEq(linearBondingCurveToken.reserves(), 0.5 ether);

        /* Buy 1 token for 1.5 ETH */
        vm.prank(users.bob);
        uint256 amount2 = linearBondingCurveToken.buy{ value: 1.5 ether }(0);
        assertEq(amount2, 1 ether);
        assertEq(linearBondingCurveToken.balanceOf(users.bob), 1 ether);
        assertEq(linearBondingCurveToken.reserves(), 2 ether);

        /* Buy 1 token for 2.5 ETH */
        vm.prank(users.charlie);
        uint256 amount3 = linearBondingCurveToken.buy{ value: 2.5 ether }(0);
        assertEq(amount3, 1 ether);
        assertEq(linearBondingCurveToken.balanceOf(users.charlie), 1 ether);
        assertEq(linearBondingCurveToken.reserves(), 4.5 ether);

        /* Confirm total supply */
        assertEq(linearBondingCurveToken.totalSupply(), 3 ether);
    }

    function test__Buy_NonIncremental() external {
        /* Buy 1 token for 0.5 ETH */
        vm.prank(users.alice);
        uint256 amount1 = linearBondingCurveToken.buy{ value: 0.5 ether }(0);

        /* Confirm balances */
        assertEq(amount1, 1 ether);
        assertEq(linearBondingCurveToken.balanceOf(users.alice), 1 ether);
        assertEq(linearBondingCurveToken.reserves(), 0.5 ether);

        /* Buy 5 tokens for 17.5 ETH */
        vm.prank(users.bob);
        uint256 amount2 = linearBondingCurveToken.buy{ value: 17.5 ether }(0);

        /* Confirm balances */
        assertEq(amount2, 5 ether, "amount2");
        assertEq(linearBondingCurveToken.balanceOf(users.bob), 5 ether, "bob balanceOf");
        assertEq(linearBondingCurveToken.reserves(), 18 ether, "reserves");

        /* Confirm total supply */
        assertEq(linearBondingCurveToken.totalSupply(), 6 ether, "totalSupply");
    }
}
