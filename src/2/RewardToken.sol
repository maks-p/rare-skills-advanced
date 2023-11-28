// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @title Reward Token
 * @author Maks Pazuniak
 * @notice ERC20 used for Staking
 */
contract RewardToken is ERC20 {
    /*--------------------------------------------------------------------------*/
    /* State                                                                    */
    /*--------------------------------------------------------------------------*/

    address internal immutable _staking;

    /*--------------------------------------------------------------------------*/
    /* Errors                                                                   */
    /*--------------------------------------------------------------------------*/

    /**
     * @notice Only the admin can call this function
     */
    error UnauthorizedCaller();

    /*--------------------------------------------------------------------------*/
    /* Constructor                                                              */
    /*--------------------------------------------------------------------------*/

    /**
     * @notice Constructor
     *
     * @param name_ ERC20 Name
     * @param symbol_  ERC20 Symbol
     */
    constructor(string memory name_, string memory symbol_) ERC20(name_, symbol_) {
        /* Set staking */
        _staking = msg.sender;
    }

    /*--------------------------------------------------------------------------*/
    /* API                                                                      */
    /*--------------------------------------------------------------------------*/

    /**
     * @notice Mint tokens
     *
     * @param account The account to mint to
     * @param amount The amount to mint
     */
    function mint(address account, uint256 amount) external {
        /* Validate caller */
        if (msg.sender != _staking) revert UnauthorizedCaller();

        /* Mint tokens */
        _mint(account, amount);
    }
}
