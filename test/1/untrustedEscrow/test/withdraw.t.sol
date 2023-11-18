// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import { UntrustedEscrow } from "src/1/UntrustedEscrow.sol";
import { UntrustedEscrowTest } from "../UntrustedEscrow.t.sol";

import "forge-std/console.sol";

contract WithdrawTest is UntrustedEscrowTest {
    function test__RevertsWhen_Withdraw_InvalidReceiptLength() external {
        _createEscrow({ token: address(testToken), seller: users.bob, buyer: users.alice, amount: 1 ether });

        bytes memory invalidEscrowReceipt = _escrowReceiptInvalidLength({
            token: address(testToken),
            seller: users.bob,
            buyer: users.alice,
            amount: 1 ether
        }); // -> invalid escrow receipt length

        vm.expectRevert(UntrustedEscrow.InvalidEscrowReceipt.selector);
        vm.prank(users.bob);
        untrustedEscrow.withdraw(invalidEscrowReceipt);
    }

    function test__RevertsWhen_Withdraw_InvalidEscrowReceipt() external {
        _createEscrow({ token: address(testToken), seller: users.bob, buyer: users.alice, amount: 1 ether });

        bytes memory invalidEscrowReceipt =
            _escrowReceipt({ token: address(testToken), seller: users.bob, buyer: users.alice, amount: 1 ether + 1 }); // ->
            // invalid escrow receipt

        vm.warp(block.timestamp + 3 days);

        vm.expectRevert(UntrustedEscrow.InvalidEscrowReceipt.selector);
        vm.prank(users.bob);
        untrustedEscrow.withdraw(invalidEscrowReceipt);
    }

    function test__RevertsWhen_Withdraw_EscrowNotExpired() external {
        (, bytes memory escrowReceipt) =
            _createEscrow({ token: address(testToken), seller: users.bob, buyer: users.alice, amount: 1 ether });

        vm.warp(block.timestamp + 3 days - 1); // -> escrow not expired

        vm.expectRevert(UntrustedEscrow.EscrowNotExpired.selector);
        vm.prank(users.bob);
        untrustedEscrow.withdraw(escrowReceipt);
    }

    function test__RevertsWhen_Withdraw_InvalidCaller() external {
        (, bytes memory escrowReceipt) =
            _createEscrow({ token: address(testToken), seller: users.bob, buyer: users.alice, amount: 1 ether });

        vm.warp(block.timestamp + 3 days);

        vm.expectRevert(UntrustedEscrow.InvalidCaller.selector);
        vm.prank(users.charlie); // -> invalid caller
        untrustedEscrow.withdraw(escrowReceipt);
    }

    function test__RevertsWhen_WithdrawAgain() external {
        (, bytes memory escrowReceipt) =
            _createEscrow({ token: address(testToken), seller: users.bob, buyer: users.alice, amount: 1 ether });

        vm.warp(block.timestamp + 3 days);

        /* Withdraw */
        vm.expectEmit(true, true, true, true, address(untrustedEscrow));
        emit EscrowWithdrawn({ escrowHash: _escrowReceiptHash(escrowReceipt), escrowReceipt: escrowReceipt });
        vm.prank(users.bob);
        untrustedEscrow.withdraw(escrowReceipt);

        /* Verify escrow status */
        UntrustedEscrow.EscrowStatus escrowStatus = untrustedEscrow.escrowStatus(_escrowReceiptHash(escrowReceipt));
        assertEq(uint8(escrowStatus), uint8(2));

        /* Withdraw again */
        vm.expectRevert(UntrustedEscrow.InvalidEscrowReceipt.selector);
        vm.prank(users.bob);
        untrustedEscrow.withdraw(escrowReceipt);
    }

    function test__Withdraw() external {
        uint256 aliceStartingBal = testToken.balanceOf(users.alice);
        uint256 bobStartingBal = testToken.balanceOf(users.bob);

        (, bytes memory escrowReceipt) =
            _createEscrow({ token: address(testToken), seller: users.bob, buyer: users.alice, amount: 1 ether });

        vm.warp(block.timestamp + 3 days);

        /* Withdraw */
        vm.expectEmit(true, true, true, true, address(untrustedEscrow));
        emit EscrowWithdrawn({ escrowHash: _escrowReceiptHash(escrowReceipt), escrowReceipt: escrowReceipt });
        vm.prank(users.bob);
        untrustedEscrow.withdraw(escrowReceipt);

        /* Confirm balances */
        assertEq(testToken.balanceOf(address(untrustedEscrow)), 0 ether);
        assertEq(testToken.balanceOf(users.bob), bobStartingBal + 1 ether);
        assertEq(testToken.balanceOf(users.alice), aliceStartingBal - 1 ether);

        /* Verify escrow status */
        UntrustedEscrow.EscrowStatus escrowStatus = untrustedEscrow.escrowStatus(_escrowReceiptHash(escrowReceipt));
        assertEq(uint8(escrowStatus), uint8(2));
    }

    function test__Withdraw_FeeOnTransfer() external {
        uint256 aliceStartingBal = testFeeOnTransfer.balanceOf(users.alice);
        uint256 bobStartingBal = testFeeOnTransfer.balanceOf(users.bob);

        (, bytes memory escrowReceipt) =
            _createEscrow({ token: address(testFeeOnTransfer), seller: users.bob, buyer: users.alice, amount: 1 ether });

        vm.warp(block.timestamp + 3 days);

        /* Withdraw */
        vm.expectEmit(true, true, true, true, address(untrustedEscrow));
        emit EscrowWithdrawn({ escrowHash: _escrowReceiptHash(escrowReceipt), escrowReceipt: escrowReceipt });
        vm.prank(users.bob);
        untrustedEscrow.withdraw(escrowReceipt);

        /* Confirm balances */
        assertEq(testFeeOnTransfer.balanceOf(address(untrustedEscrow)), 0 ether);
        assertEq(testFeeOnTransfer.balanceOf(users.bob), bobStartingBal + 0.9025 ether); // Fee on transfer
        assertEq(testFeeOnTransfer.balanceOf(users.alice), aliceStartingBal - 1 ether); // Alice still sends 1 ether
    }
}
