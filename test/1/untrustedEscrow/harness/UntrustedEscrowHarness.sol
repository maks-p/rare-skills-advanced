// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.21;

import { UntrustedEscrow } from "src/1/UntrustedEscrow.sol";

contract UntrustedEscrowHarness is UntrustedEscrow {
    constructor() UntrustedEscrow() { }

    function encodeEscrowReceipt(
        address token,
        address buyer,
        address seller,
        uint256 amount
    )
        external
        view
        returns (bytes memory)
    {
        return _encode(token, buyer, seller, amount);
    }

    function hashEncodedEscrowReceipt(bytes calldata encodedEscrowReceipt) external view returns (bytes32) {
        return _hash(encodedEscrowReceipt);
    }
}
