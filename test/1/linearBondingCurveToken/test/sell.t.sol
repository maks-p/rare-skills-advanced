// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import { LinearBondingCurveToken } from "src/1/LinearBondingCurveToken.sol";
import { LinearBondingCurveTokenTest } from "../LinearBondingCurveToken.t.sol";

import "forge-std/console.sol";

contract BuyTest is LinearBondingCurveTokenTest {
    function test__RevertsWhen_Sell_MinimumNotMet() external {
        /* Buy 1 token for 0.5 ETH */
        vm.prank(users.alice);
        linearBondingCurveToken.buy{ value: 0.5 ether }(0);

        vm.expectRevert(LinearBondingCurveToken.MinimumNotMet.selector);
        vm.prank(users.alice);
        linearBondingCurveToken.sell(1 ether, 0.5 ether + 1);
    }

    function test__RevertsWhen_Sell__InvalidAmount() external {
        /* Buy 1 token for 0.5 ETH */
        vm.prank(users.alice);
        linearBondingCurveToken.buy{ value: 0.5 ether }(0);

        vm.expectRevert(LinearBondingCurveToken.InvalidAmount.selector);
        vm.prank(users.alice);
        linearBondingCurveToken.sell(0, 0.5 ether);
    }

    function test__Sell() external {
        /* Buy 1 token for 0.5 ETH */
        vm.prank(users.alice);
        linearBondingCurveToken.buy{ value: 0.5 ether }(0);

        /* Sell 1 token for 0.5 ETH */
        vm.expectEmit(true, true, true, true, address(linearBondingCurveToken));
        emit TokensSold(users.alice, 1 ether);

        vm.prank(users.alice);
        linearBondingCurveToken.sell(1 ether, 0.5 ether);

        /* Confirm balances */
        assertEq(linearBondingCurveToken.balanceOf(users.alice), 0 ether);
        assertEq(linearBondingCurveToken.reserves(), 0 ether);

        /* Confirm burn */
        assertEq(linearBondingCurveToken.totalSupply(), 0 ether);
    }

    function test__Sell_ForProfit() external {
        /* Buy 1 token for 0.5 ETH */
        vm.prank(users.alice);
        linearBondingCurveToken.buy{ value: 0.5 ether }(0);

        /* Buy 1 token for 1.5 ETH */
        vm.prank(users.bob);
        linearBondingCurveToken.buy{ value: 1.5 ether }(0);

        /* Sell 1 token for 1.5 ETH */
        vm.expectEmit(true, true, true, true, address(linearBondingCurveToken));
        emit TokensSold(users.alice, 1 ether);

        vm.prank(users.alice);
        linearBondingCurveToken.sell(1 ether, 1.5 ether);

        /* Confirm balances */
        assertEq(linearBondingCurveToken.balanceOf(users.alice), 0 ether);
        assertEq(linearBondingCurveToken.reserves(), 0.5 ether);

        /* Confirm burn */
        assertEq(linearBondingCurveToken.totalSupply(), 1 ether);
    }
}
