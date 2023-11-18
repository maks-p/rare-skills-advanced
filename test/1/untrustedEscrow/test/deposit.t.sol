// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import { UntrustedEscrow } from "src/1/UntrustedEscrow.sol";
import { UntrustedEscrowTest } from "../UntrustedEscrow.t.sol";

contract DepositTest is UntrustedEscrowTest {
    function test__RevertsWhen_Deposit_InvalidAmount() external {
        vm.expectRevert(UntrustedEscrow.InvalidEscrow.selector);
        vm.prank(users.alice);
        untrustedEscrow.deposit(address(testToken), users.bob, 0);
    }

    function test__RevertsWhen_Deposit_EscrowAlreadyExists() internal {
        vm.prank(users.alice);
        untrustedEscrow.deposit(address(testToken), users.bob, 1 ether);

        vm.expectRevert(UntrustedEscrow.InvalidEscrow.selector);
        vm.prank(users.alice);
        untrustedEscrow.deposit(address(testToken), users.bob, 1 ether);
    }

    function test__Deposit_StandardERC20() external {
        /* Create escrow receipt + hash */
        bytes memory escrowReceipt =
            _escrowReceipt({ token: address(testToken), seller: users.bob, buyer: users.alice, amount: 1 ether });
        bytes32 escrowHash = _escrowReceiptHash(escrowReceipt);

        /* Deposit 1 ether */
        vm.expectEmit(true, true, true, true, address(untrustedEscrow));
        emit EscrowDeposited({ escrowHash: _escrowReceiptHash(escrowReceipt), escrowReceipt: escrowReceipt });

        vm.prank(users.alice);
        untrustedEscrow.deposit(address(testToken), users.bob, 1 ether);

        /* Confirm balances */
        assertEq(testToken.balanceOf(address(untrustedEscrow)), 1 ether);

        /* Confirm escrow receipt */
        UntrustedEscrow.EscrowStatus escrowStatus = untrustedEscrow.escrowStatus(escrowHash);
        assertEq(uint8(escrowStatus), uint8(1));
    }

    function test__Deposit_StandardERC20_ValidDuplicate() external {
        /* Create escrow receipt + hash */
        bytes memory escrowReceipt =
            _escrowReceipt({ token: address(testToken), seller: users.bob, buyer: users.alice, amount: 1 ether });
        bytes32 escrowHash = _escrowReceiptHash(escrowReceipt);

        /* Deposit 1 ether */
        vm.expectEmit(true, true, true, true, address(untrustedEscrow));
        emit EscrowDeposited({ escrowHash: _escrowReceiptHash(escrowReceipt), escrowReceipt: escrowReceipt });

        vm.prank(users.alice);
        untrustedEscrow.deposit(address(testToken), users.bob, 1 ether);

        /* Confirm balances */
        assertEq(testToken.balanceOf(address(untrustedEscrow)), 1 ether);

        /* Confirm escrow receipt */
        UntrustedEscrow.EscrowStatus escrowStatus = untrustedEscrow.escrowStatus(escrowHash);
        assertEq(uint8(escrowStatus), uint8(1));

        vm.warp(block.timestamp + 1);

        /* Create escrow receipt + hash */
        bytes memory escrowReceipt2 =
            _escrowReceipt({ token: address(testToken), seller: users.bob, buyer: users.alice, amount: 1 ether });
        bytes32 escrowHash2 = _escrowReceiptHash(escrowReceipt);

        /* Deposit 1 ether */
        vm.expectEmit(true, true, true, true, address(untrustedEscrow));
        emit EscrowDeposited({ escrowHash: _escrowReceiptHash(escrowReceipt2), escrowReceipt: escrowReceipt2 });

        vm.prank(users.alice);
        untrustedEscrow.deposit(address(testToken), users.bob, 1 ether);

        /* Confirm balances */
        assertEq(testToken.balanceOf(address(untrustedEscrow)), 2 ether);

        /* Confirm escrow receipt */
        UntrustedEscrow.EscrowStatus escrowStatus2 = untrustedEscrow.escrowStatus(escrowHash2);
        assertEq(uint8(escrowStatus2), uint8(1));
    }

    function test__Deposit_FeeOnTransfer() external {
        uint256 feeOnTransferStartingBal = testFeeOnTransfer.balanceOf(address(testFeeOnTransfer));
        /* Create escrow receipt + hash */
        bytes memory escrowReceipt = _escrowReceipt({
            token: address(testFeeOnTransfer),
            seller: users.bob,
            buyer: users.alice,
            amount: 0.95 ether
        });
        bytes32 escrowHash = _escrowReceiptHash(escrowReceipt);

        /* Deposit 1 ether */
        vm.expectEmit(true, true, true, true, address(untrustedEscrow));
        emit EscrowDeposited({ escrowHash: _escrowReceiptHash(escrowReceipt), escrowReceipt: escrowReceipt });

        vm.prank(users.alice);
        untrustedEscrow.deposit(address(testFeeOnTransfer), users.bob, 1 ether);

        /* Confirm balances */
        assertEq(testFeeOnTransfer.balanceOf(address(untrustedEscrow)), 0.95 ether);
        assertEq(testFeeOnTransfer.balanceOf(address(testFeeOnTransfer)), feeOnTransferStartingBal + 0.05 ether);

        /* Confirm escrow receipt */
        UntrustedEscrow.EscrowStatus escrowStatus = untrustedEscrow.escrowStatus(escrowHash);
        assertEq(uint8(escrowStatus), uint8(1));
    }
}
