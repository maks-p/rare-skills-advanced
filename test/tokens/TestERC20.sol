// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.21;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @title Test ERC20 Token
 */
contract TestERC20 is ERC20 {
    /*--------------------------------------------------------------------------*/
    /* Constructor                                                              */
    /*--------------------------------------------------------------------------*/

    /**
     * @notice TestERC20
     * @notice name Token name
     * @notice symbol Token symbol
     */
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        /* Mint token supply to deployer to distribute */
        _mint(msg.sender, 100_000 ether);
    }
}
