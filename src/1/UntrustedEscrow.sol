// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title Untrusted Escrow
 * @author Maks Pazuniak
 * @notice Untrusted escrow contract
 */

contract UntrustedEscrow is ReentrancyGuard {
    using SafeERC20 for IERC20;

    /*--------------------------------------------------------------------------*/
    /* Structures                                                               */
    /*--------------------------------------------------------------------------*/

    /**
     * @notice Escrow status
     * @param None Escrow does not exist
     * @param Open Escrow is open
     * @param Closed Escrow is closed - claimed by seller
     */
    enum EscrowStatus {
        None,
        Open,
        Closed
    }

    /**
     * @notice Escrow receipt
     *
     * @dev Buyer is not strictly required, but is retained for future use
     *
     * @param token The token being escrowed
     * @param seller The seller
     * @param buyer The buyer
     * @param amount The amount of tokens being escrowed
     * @param expiration The expiration of the escrow
     */
    struct EscrowReceipt {
        address token;
        address seller;
        address buyer;
        uint256 amount;
        uint64 expiration;
    }

    /*--------------------------------------------------------------------------*/
    /* Constants                                                                */
    /*--------------------------------------------------------------------------*/

    /**
     * @notice Escrow duration
     */
    uint256 internal constant ESCROW_DURATION = 3 days;

    /**
     * @notice Escrow receipt length
     */
    uint256 internal constant ESCROW_RECEIPT_LENGTH = 100;

    /*--------------------------------------------------------------------------*/
    /* State                                                                    */
    /*--------------------------------------------------------------------------*/

    /**
     * @notice Mapping of escrow hash to escrow status
     */
    mapping(bytes32 => EscrowStatus) _escrows;

    /*--------------------------------------------------------------------------*/
    /* Events                                                                   */
    /*--------------------------------------------------------------------------*/

    /**
     * @notice Escrow Deposited
     *
     * @param escrowHash Esrow hash
     * @param escrowReceipt Escrow receipt
     */
    event EscrowDeposited(bytes32 escrowHash, bytes escrowReceipt);

    /**
     * @notice Escrow Deposited
     *
     * @param escrowHash Esrow hash
     * @param escrowReceipt Escrow receipt
     */
    event EscrowWithdrawn(bytes32 escrowHash, bytes escrowReceipt);

    /*--------------------------------------------------------------------------*/
    /* Errors                                                                   */
    /*--------------------------------------------------------------------------*/

    /**
     * @notice Invalid escrow
     */
    error InvalidEscrow();

    /**
     * @notice Invalid escrow receipt
     */
    error InvalidEscrowReceipt();

    /**
     * @notice Invalid caller
     */
    error InvalidCaller();

    /**
     * @notice Escrow not expired
     */
    error EscrowNotExpired();

    /*--------------------------------------------------------------------------*/
    /* Getters                                                                  */
    /*--------------------------------------------------------------------------*/

    /**
     * @notice Escrow duration
     * @return Escrow duration
     */
    function escrowDuration() external pure returns (uint256) {
        return ESCROW_DURATION;
    }

    /**
     * @notice Escrow status
     * @param escrowHash Escrow hash
     * @return Escrow status
     */
    function escrowStatus(bytes32 escrowHash) external view returns (EscrowStatus) {
        return _escrows[escrowHash];
    }

    /*--------------------------------------------------------------------------*/
    /* API                                                                      */
    /*--------------------------------------------------------------------------*/

    /**
     * @notice Deposit tokens into escrow - buyer deposits
     *
     * @dev Buyer must approve tokens before calling this function
     *      Fee-on-transfer tokens are supported under the assumption that the
     *      behavior is agreed upon by the buyer and seller
     *
     * @param token The token being escrowed
     * @param seller The seller
     * @param amount The amount of tokens being escrowed
     * @return The escrow hash
     * @return The encoded escrow receipt
     */
    function deposit(
        address token,
        address seller,
        uint256 amount
    )
        external
        nonReentrant
        returns (bytes32, bytes memory)
    {
        /* Validate amount */
        if (amount == 0) revert InvalidEscrow();

        /* Cache token balance */
        uint256 reserve = IERC20(token).balanceOf(address(this));

        /* Transfer tokens */
        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);

        /* Compute amount deposited - handles fee-on-transfer tokens */
        uint256 deposited = IERC20(token).balanceOf(address(this)) - reserve;

        /* Create escrow hash */
        bytes memory encodedReceipt = _encode({ token: token, seller: seller, buyer: msg.sender, amount: deposited });
        bytes32 escrowHash = _hash(encodedReceipt);

        /* Only one escrow with same params allowed */
        if (_escrows[escrowHash] != EscrowStatus.None) revert InvalidEscrow();

        /* Set escrow status */
        _escrows[escrowHash] = EscrowStatus.Open;

        emit EscrowDeposited(escrowHash, encodedReceipt);

        return (escrowHash, encodedReceipt);
    }

    /**
     * @notice Seller withdraws tokens from escrow
     * @param encodedReceipt Encoded escrow receipt
     */
    function withdraw(bytes calldata encodedReceipt) external nonReentrant {
        /* Validate receipt length */
        if (encodedReceipt.length != ESCROW_RECEIPT_LENGTH) {
            revert InvalidEscrowReceipt();
        }

        /* Hash encocded receipt */
        bytes32 escrowHash = _hash(encodedReceipt);

        /* Validate escrow */
        if (_escrows[escrowHash] != EscrowStatus.Open) {
            revert InvalidEscrowReceipt();
        }

        /* Decode receipt */
        address token = address(bytes20(encodedReceipt[0:20]));
        address seller = address(bytes20(encodedReceipt[20:40]));
        /* skip buyer at 40:60 */
        uint256 amount = uint256(bytes32(encodedReceipt[60:92]));
        uint64 expiration = uint64(bytes8(encodedReceipt[92:100]));

        /* Validate caller */
        if (msg.sender != seller) revert InvalidCaller();

        /* Validate expiration */
        if (block.timestamp < expiration) revert EscrowNotExpired();

        /* Set escrow status */
        _escrows[escrowHash] = EscrowStatus.Closed;

        /* Transfer tokens */
        IERC20(token).safeTransfer(seller, amount);

        emit EscrowWithdrawn(escrowHash, encodedReceipt);
    }

    /*--------------------------------------------------------------------------*/
    /* Internal Helpers                                                         */
    /*--------------------------------------------------------------------------*/

    /**
     * @notice Tightly packed encoding of escrow receipt
     * @param token Token
     * @param seller Seller
     * @param buyer Buyer
     * @param amount Amount
     * @return Encoded escrow receipt
     *
     * Tightly packed structure:
     *
     * bytes 0:20 - token
     * bytes 20:40 - seller
     * bytes 40:60 - buyer
     * bytes 60:92 - amount
     * bytes 92:100 - expiration
     */
    function _encode(
        address token,
        address seller,
        address buyer,
        uint256 amount
    )
        internal
        view
        returns (bytes memory)
    {
        uint64 expiration = uint64(block.timestamp + ESCROW_DURATION);

        return abi.encodePacked(token, seller, buyer, amount, expiration);
    }

    /**
     * @notice Compute escrow receipt hash
     * @param encodedReceipt Encoded escrow receipt
     * @return Escrow receipt hash
     */
    function _hash(bytes memory encodedReceipt) internal view returns (bytes32) {
        return keccak256(abi.encodePacked(block.chainid, encodedReceipt));
    }
}
