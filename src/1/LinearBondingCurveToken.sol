// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { Math } from "@openzeppelin/contracts/utils/math/Math.sol";

/**
 * @title Linear Bonding Curve Token
 * @author Maks Pazuniak
 * @notice Simple linear bonding curve token
 *
 * @dev Simple linear bonding curve model: y = x => Price = Total Supply
 *      Reserve tokens are held in ETH
 */
contract LinearBondingCurveToken is ERC20 {
    /*--------------------------------------------------------------------------*/
    /* Constants                                                                */
    /*--------------------------------------------------------------------------*/

    uint256 internal constant FIXED_POINT_SCALE = 1e18;

    /*--------------------------------------------------------------------------*/
    /* State                                                                    */
    /*--------------------------------------------------------------------------*/

    /**
     * @notice Eth Reserves held by contract
     */
    uint256 internal _reserves;

    /*--------------------------------------------------------------------------*/
    /* Events                                                                   */
    /*--------------------------------------------------------------------------*/

    /**
     * @notice Emitted when tokens are purchased
     *
     * @param account Account
     * @param amount Amount of tokens purchased
     */
    event TokensPurchased(address indexed account, uint256 amount);

    /**
     * @notice Emitted when tokens are sold
     *
     * @param account Account
     * @param amount Amount of tokens sold
     */
    event TokensSold(address indexed account, uint256 amount);

    /*--------------------------------------------------------------------------*/
    /* Errors                                                                   */
    /*--------------------------------------------------------------------------*/

    /**
     * @notice Unauthorized caller
     */
    error UnauthorizedCaller();

    /**
     * @notice Minimum not met
     */
    error MinimumNotMet();

    /**
     * @notice Eth transfer failed
     */
    error TransferFailed();

    /**
     * @notice Invalid amount
     */
    error InvalidAmount();

    /*--------------------------------------------------------------------------*/
    /* Constructor                                                              */
    /*--------------------------------------------------------------------------*/

    /**
     * @notice Constructor
     *
     * @param name_ ERC20 Name
     * @param symbol_  ERC20 Symbol
     */
    constructor(string memory name_, string memory symbol_) ERC20(name_, symbol_) { }

    /*--------------------------------------------------------------------------*/
    /* Getters                                                                  */
    /*--------------------------------------------------------------------------*/

    /**
     * @notice Get spot price
     *
     * @dev y = x => Price = Total Supply
     *
     * @return Spot price
     */
    function spotPrice() external view returns (uint256) {
        return totalSupply();
    }

    /**
     * @notice Get reserves
     */
    function reserves() external view returns (uint256) {
        return _reserves;
    }

    /*--------------------------------------------------------------------------*/
    /* API                                                                      */
    /*--------------------------------------------------------------------------*/

    /**
     * @notice Buy tokens
     *
     * @param minimum Minimum amount of tokens acceptable
     *
     * @return Amount of tokens purchased
     */
    function buy(uint256 minimum) external payable returns (uint256) {
        if (msg.value == 0) revert InvalidAmount();

        /* Compute tokens out */
        uint256 amount = _computeTokensOut(msg.value);

        /* Revert if minimum not met */
        if (amount < minimum) revert MinimumNotMet();

        /* Update state */
        _reserves += msg.value;

        /* Mint tokens */
        _mint(msg.sender, amount);

        emit TokensPurchased(msg.sender, amount);

        return amount;
    }

    /**
     * @notice Sell tokens
     *
     * @param amount Amount of tokens to sell
     * @param minimum Minimum amount out of ETH acceptable
     */
    function sell(uint256 amount, uint256 minimum) external {
        if (amount == 0 || balanceOf(msg.sender) < amount) {
            revert InvalidAmount();
        }

        /* Get reserve tokens returned */
        uint256 reserveTokensReturned = _computeReserveTokensReturned(amount);

        /* Revert if minimum not met */
        if (reserveTokensReturned < minimum) revert MinimumNotMet();

        /* Update state */
        _reserves -= reserveTokensReturned;

        /* Burn tokens */
        _burn(msg.sender, amount);

        /* Transfer ETH */
        (bool success,) = msg.sender.call{ value: reserveTokensReturned }("");
        if (!success) revert TransferFailed();

        emit TokensSold(msg.sender, amount);
    }

    /*--------------------------------------------------------------------------*/
    /* Internal Helpers                                                         */
    /*--------------------------------------------------------------------------*/

    /**
     * @notice Compute tokens out
     *
     * @dev Derived from trapezoidal approximation of integral (reserveTokensIn + _reserves):
     *
     *      (a + b) / 2 * h = (a + b) / 2 * (b - a) = 1/2 * (b^2 - a^2)
     *
     *      1/2 * b^2 = Balance of reserve tokens after purchase
     *      1/2 * a^2 = Balance of reserve tokens before purchase
     *
     *      1/2 * b^2 = reserveTokensIn + _reserves
     *      b = sqrt(2 * (reserveTokensIn + _reserves))
     *
     *      tokensOut = b - a = sqrt(2 * (reserveTokensIn + _reserves)) - totalSupply();
     *
     * @param reserveTokensIn Reserve tokens in
     *
     * @return Tokens out
     */
    function _computeTokensOut(uint256 reserveTokensIn) internal view returns (uint256) {
        return Math.sqrt(2 * FIXED_POINT_SCALE * (reserveTokensIn + _reserves)) - totalSupply();
    }

    /**
     * @notice Compute reserve tokens returned
     *
     * @dev See _computeTokensOut()
     *
     * @param amount Amount of token being sold
     */
    function _computeReserveTokensReturned(uint256 amount) internal view returns (uint256) {
        uint256 delta = totalSupply() - amount;
        return _reserves - (delta ** 2) / (2 * FIXED_POINT_SCALE);
    }
}
