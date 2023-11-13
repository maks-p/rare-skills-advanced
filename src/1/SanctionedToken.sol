// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @title Sanctioned Token
 * @author Maks Pazuniak
 * @notice Simple ERC20 token with a sanctioning mechanism
 */
contract SanctionedToken is ERC20 {
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
     * @notice Mapping of sanctioned accounts
     *
     * @dev Sanctioned accounts cannot transfer or approve tokens
     */
    mapping(address => bool) internal _sanctions;

    /*--------------------------------------------------------------------------*/
    /* Events                                                                   */
    /*--------------------------------------------------------------------------*/

    /**
     * @notice Emitted when an account is sanctioned
     * @param account The  account that was sanctioned
     */
    event Sanctioned(address indexed account);

    /**
     * @notice Emitted when an account is unsanctioned
     * @param account The  account that was unsanctioned
     */
    event Unsanctioned(address indexed account);

    /*--------------------------------------------------------------------------*/
    /* Errors                                                                   */
    /*--------------------------------------------------------------------------*/

    /**
     * @notice Only the admin can call this function
     */
    error UnauthorizedCaller();

    /**
     * @notice The account is sanctioned
     * @param account The account that is sanctioned
     */
    error SanctionedAddress(address account);

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
     * @notice Get sanctioned status of account
     *
     * @param account The account to check
     * @return Sanctioned status
     */
    function isSanctioned(address account) external view returns (bool) {
        return _sanctions[account];
    }

    /**
     * @notice Get admin
     *
     * @return Admin
     */
    function admin() external view returns (address) {
        return _admin;
    }

    /*--------------------------------------------------------------------------*/
    /* API                                                                      */
    /*--------------------------------------------------------------------------*/

    /**
     * @notice Approve `spender` to transfer `amount` on behalf of `msg.sender`
     *
     * @dev Overrides OpenZeppelin ERC20 implemention
     *      Sanctioned accounts cannot approve or be approved
     *
     * @param spender Account approved to spend tokens on behalf of owner
     * @param value  Value
     * @return Success
     */
    function approve(address spender, uint256 value) public override returns (bool) {
        if (_sanctions[msg.sender]) revert SanctionedAddress(msg.sender);
        if (_sanctions[spender]) revert SanctionedAddress(spender);

        return super.approve(spender, value);
    }

    /*--------------------------------------------------------------------------*/
    /* Internal                                                                 */
    /*--------------------------------------------------------------------------*/

    /**
     * @notice Transfer `value` from `from` to `to`
     *
     * @dev Overrides OpenZeppelin internal implemention
     *     Sanctioned accounts cannot participate in transfer, mint or burn
     *
     * @param from From
     * @param to To
     * @param value Value
     */
    function _update(address from, address to, uint256 value) internal override {
        if (_sanctions[from]) revert SanctionedAddress(from);
        if (_sanctions[to]) revert SanctionedAddress(to);

        super._update(from, to, value);
    }

    /*--------------------------------------------------------------------------*/
    /* Admin                                                                    */
    /*--------------------------------------------------------------------------*/

    /**
     * @notice Sanction account
     *
     * @param account The account to sanction
     */
    function sanction(address account) external {
        if (msg.sender != _admin) revert UnauthorizedCaller();
        _sanctions[account] = true;

        emit Sanctioned(account);
    }

    /**
     * @notice Unsanction account
     *
     * @param account The account to unsanction
     */
    function unsanction(address account) external {
        if (msg.sender != _admin) revert UnauthorizedCaller();
        _sanctions[account] = false;

        emit Unsanctioned(account);
    }
}
