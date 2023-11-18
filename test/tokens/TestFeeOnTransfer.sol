// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.21;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @title Test ERC20 Token
 */
contract TestFeeOnTransfer is ERC20 {
    /*--------------------------------------------------------------------------*/
    /* Constructor                                                              */
    /*--------------------------------------------------------------------------*/

    /**
     * @notice Constructor
     * @notice name Token name
     * @notice symbol Token symbol
     */
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        /* Mint token supply to deployer to distribute */
        _mint(msg.sender, 100_000 ether);
    }

    /**
     * @notice Fee on transfer implementation
     * @param from From
     * @param to To
     * @param value Value
     */
    function _update(address from, address to, uint256 value) internal override {
        uint256 tax = (value * 500) / 10_000;

        super._update(from, to, value - tax);
        super._update(from, address(this), tax);
    }
}
