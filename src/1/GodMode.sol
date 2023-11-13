// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @title God Mode
 * @author Maks Pazuniak
 * @notice Simple ERC20 token with god mode ability
 */
contract GodMode is ERC20 {
    /*--------------------------------------------------------------------------*/
    /* Constants                                                                */
    /*--------------------------------------------------------------------------*/

    /**
     * @notice The admin of the contract
     */
    address internal immutable _admin;

    /*--------------------------------------------------------------------------*/
    /* State                                                                    */
    /*--------------------------------------------------------------------------*/

    /**
     * @notice God mode account
     *
     * @dev Account can transfer tokens to or from any address
     */
    address internal _god;

    /*--------------------------------------------------------------------------*/
    /* Events                                                                   */
    /*--------------------------------------------------------------------------*/

    /**
     * @notice Emitted when god is set
     * @param account The new god
     */
    event NewGod(address indexed account);

    /*--------------------------------------------------------------------------*/
    /* Errors                                                                   */
    /*--------------------------------------------------------------------------*/

    /**
     * @notice Only the admin can call this function
     */
    error UnauthorizedCaller();

    /**
     * @notice Only god can call
     */
    error OnlyGod();

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
        /* Set admin */
        _admin = msg.sender;

        /* Mint initial supply */
        _mint(msg.sender, 1_000_000 ether);
    }

    /*--------------------------------------------------------------------------*/
    /* Getters                                                                  */
    /*--------------------------------------------------------------------------*/

    /**
     * @notice Get admin
     *
     * @return Admin
     */
    function admin() external view returns (address) {
        return _admin;
    }

    /**
     * @notice Get god
     *
     * @return God
     */
    function god() external view returns (address) {
        return _god;
    }

    /*--------------------------------------------------------------------------*/
    /* API                                                                      */
    /*--------------------------------------------------------------------------*/

    /**
     * @notice Overloaded transfer function that only god can call
     *
     * @dev God can transfer any amount from any account to any account
     *
     * @param from From
     * @param to To
     * @param value Value
     */
    function transfer(address from, address to, uint256 value) public returns (bool) {
        if (msg.sender != _god) revert OnlyGod();
        _transfer(from, to, value);
        return true;
    }

    /*--------------------------------------------------------------------------*/
    /* Admin                                                                    */
    /*--------------------------------------------------------------------------*/

    /**
     * @notice Sanction account
     *
     * @dev Set to address(0) to disable god mode
     *
     * @param account The account to sanction
     */
    function setGod(address account) external {
        if (msg.sender != _admin) revert UnauthorizedCaller();
        _god = account;

        emit NewGod(account);
    }
}
