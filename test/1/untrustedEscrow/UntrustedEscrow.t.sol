// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import { BaseTest } from "test/Base.t.sol";
import { UntrustedEscrow } from "src/1/UntrustedEscrow.sol";
import { UntrustedEscrowHarness } from "test/1/untrustedEscrow/harness/UntrustedEscrowHarness.sol";

import { TestERC20 } from "test/tokens/TestERC20.sol";
import { TestFeeOnTransfer } from "test/tokens/TestFeeOnTransfer.sol";

import "forge-std/console.sol";

contract UntrustedEscrowTest is BaseTest {
    /*--------------------------------------------------------------------------*/
    /* Events                                                                   */
    /*--------------------------------------------------------------------------*/

    event EscrowDeposited(bytes32 escrowHash, bytes escrowReceipt);
    event EscrowWithdrawn(bytes32 escrowHash, bytes escrowReceipt);

    /*--------------------------------------------------------------------------*/
    /* State                                                                    */
    /*--------------------------------------------------------------------------*/

    UntrustedEscrow internal untrustedEscrow;
    TestERC20 internal testToken;
    TestFeeOnTransfer internal testFeeOnTransfer;

    UntrustedEscrowHarness internal untrustedEscrowHarness;

    /*--------------------------------------------------------------------------*/
    /* Set Up                                                                   */
    /*--------------------------------------------------------------------------*/

    function setUp() public virtual override {
        BaseTest.setUp();

        _deployUntrustedEscrow();
        _deployTestERC20();
        _deployFeeOnTransfer();
        _setAllowances();
    }

    /*--------------------------------------------------------------------------*/
    /* Internal Deployment Helpers                                                         */
    /*--------------------------------------------------------------------------*/

    function _deployUntrustedEscrow() internal {
        vm.prank(users.deployer);
        untrustedEscrow = new UntrustedEscrow();
        vm.label({ account: address(untrustedEscrow), newLabel: "UntrustedEscrow" });
    }

    function _deployUntrustedEscrowHarness() internal {
        vm.prank(users.deployer);
        untrustedEscrowHarness = new UntrustedEscrowHarness();
        vm.label({ account: address(untrustedEscrowHarness), newLabel: "UntrustedEscrowHarness" });
    }

    function _deployTestERC20() internal {
        /* Deploy test ERC20 */
        testToken = new TestERC20("TestToken", "testToken");
        vm.label({ account: address(testToken), newLabel: "TestToken" });

        /* Transfer tokens */
        testToken.transfer(address(users.alice), 1000 ether);
        testToken.transfer(address(users.bob), 1000 ether);
        testToken.transfer(address(users.charlie), 1000 ether);
        testToken.transfer(address(users.user_0), 1000 ether);
        testToken.transfer(address(users.user_1), 1000 ether);
        testToken.transfer(address(users.user_2), 1000 ether);
        testToken.transfer(address(users.user_3), 1000 ether);
    }

    function _deployFeeOnTransfer() internal {
        /* Deploy test Fee On transfer Token */
        testFeeOnTransfer = new TestFeeOnTransfer("TestFeeOnTransfer", "testFeeOnTransfer");
        vm.label({ account: address(testFeeOnTransfer), newLabel: "TestFeeOnTransfer" });

        /* Transfer tokens */
        testFeeOnTransfer.transfer(address(users.alice), 1000 ether);
        testFeeOnTransfer.transfer(address(users.bob), 1000 ether);
        testFeeOnTransfer.transfer(address(users.charlie), 1000 ether);
        testFeeOnTransfer.transfer(address(users.user_0), 1000 ether);
        testFeeOnTransfer.transfer(address(users.user_1), 1000 ether);
        testFeeOnTransfer.transfer(address(users.user_2), 1000 ether);
        testFeeOnTransfer.transfer(address(users.user_3), 1000 ether);
    }

    function _setAllowances() internal {
        /* Test ERC20 Approvals */
        vm.prank(users.alice);
        testToken.approve(address(untrustedEscrow), type(uint256).max);
        vm.prank(users.bob);
        testToken.approve(address(untrustedEscrow), type(uint256).max);
        vm.prank(users.charlie);
        testToken.approve(address(untrustedEscrow), type(uint256).max);
        vm.prank(users.user_0);
        testToken.approve(address(untrustedEscrow), type(uint256).max);
        vm.prank(users.user_1);
        testToken.approve(address(untrustedEscrow), type(uint256).max);
        vm.prank(users.user_2);
        testToken.approve(address(untrustedEscrow), type(uint256).max);

        /* Fee On Transfer Approvals */
        vm.prank(users.alice);
        testFeeOnTransfer.approve(address(untrustedEscrow), type(uint256).max);
        vm.prank(users.bob);
        testFeeOnTransfer.approve(address(untrustedEscrow), type(uint256).max);
        vm.prank(users.charlie);
        testFeeOnTransfer.approve(address(untrustedEscrow), type(uint256).max);
        vm.prank(users.user_0);
        testFeeOnTransfer.approve(address(untrustedEscrow), type(uint256).max);
        vm.prank(users.user_1);
        testFeeOnTransfer.approve(address(untrustedEscrow), type(uint256).max);
        vm.prank(users.user_2);
        testFeeOnTransfer.approve(address(untrustedEscrow), type(uint256).max);
    }

    /*--------------------------------------------------------------------------*/
    /* Internal Test Helpers                                                         */
    /*--------------------------------------------------------------------------*/
    function _escrowReceipt(
        address token,
        address seller,
        address buyer,
        uint256 amount
    )
        internal
        view
        returns (bytes memory)
    {
        uint64 expiration = uint64(block.timestamp + untrustedEscrow.escrowDuration());

        return abi.encodePacked(token, seller, buyer, amount, expiration);
    }

    function _escrowReceiptHash(bytes memory encodedReceipt) internal view returns (bytes32) {
        return keccak256(abi.encodePacked(block.chainid, encodedReceipt));
    }

    function _escrowReceiptInvalidLength(
        address token,
        address seller,
        address buyer,
        uint256 amount
    )
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodePacked(token, seller, buyer, amount);
    }

    function _createEscrow(
        address token,
        address seller,
        address buyer,
        uint256 amount
    )
        internal
        returns (bytes32, bytes memory)
    {
        /* Deposit amount */
        vm.prank(buyer);
        return untrustedEscrow.deposit(token, seller, amount);
    }
}
