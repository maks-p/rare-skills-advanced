// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import { ERC721Enumerable } from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import { ERC721 } from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import { Ownable2Step } from "@openzeppelin/contracts/access/Ownable2Step.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

contract Enumerable is ERC721Enumerable, Ownable2Step {
    /*--------------------------------------------------------------------------*/
    /* Constants                                                                */
    /*--------------------------------------------------------------------------*/

    /**
     * @notice The max supply of tokens
     */
    uint256 public constant MAX_SUPPLY = 100;

    /**
     * @notice Price per token
     */
    uint256 public constant PRICE = 0.05 ether;

    /**
     * @notice Max mintable per transaction
     *
     * @dev This does not guard against sybil attacks
     */
    uint256 public constant MAX_MINTABLE = 2;

    /*--------------------------------------------------------------------------*/
    /* State                                                                    */
    /*--------------------------------------------------------------------------*/

    /**
     * @notice The token id
     */
    uint256 internal _tokenId;

    /*--------------------------------------------------------------------------*/
    /* Errors                                                                   */
    /*--------------------------------------------------------------------------*/

    /**
     * @notice Invalid amount
     */
    error InvalidAmount();

    /**
     * @notice Max supply exceeded
     */
    error MaxSupplyExceeded();

    /**
     * @notice Max mintable exceeded
     */
    error MaxMintableExceeded();

    /**
     * @notice Insufficient funds
     */
    error InsufficientValue();

    /**
     * @notice Transfer failed
     */
    error TransferFailed();

    /*--------------------------------------------------------------------------*/
    /* Constructor                                                              */
    /*--------------------------------------------------------------------------*/

    constructor() ERC721("Enumberable", "ENUM") Ownable(msg.sender) { }

    /*--------------------------------------------------------------------------*/
    /* External                                                                 */
    /*--------------------------------------------------------------------------*/

    /**
     * @notice Mint a new token
     *
     * @param amount The amount to mint
     */
    function mint(uint256 amount) external payable {
        /* Invalid amout */
        if (amount == 0) revert InvalidAmount();

        /* Validate price */
        if (msg.value < PRICE * amount) revert InsufficientValue();

        /* Optimistically mint tokens */
        for (uint256 i; i < amount; i++) {
            _safeMint(msg.sender, ++_tokenId);
        }

        /* Validate max mintable not exceeded - does not guard against sybil attacks */
        if (amount > MAX_MINTABLE || balanceOf(msg.sender) > MAX_MINTABLE) revert MaxMintableExceeded();

        /* Validate subsequent tokenId does not exceed max supply */
        if (_tokenId > MAX_SUPPLY) revert MaxSupplyExceeded();
    }

    /*--------------------------------------------------------------------------*/
    /* Internal                                                                 */
    /*--------------------------------------------------------------------------*/

    /**
     * @dev See {ERC721-_baseURI}.
     */
    function _baseURI() internal pure override returns (string memory) {
        return "https://enumberable-nft.app/";
    }

    /*--------------------------------------------------------------------------*/
    /* Admin                                                                    */
    /*--------------------------------------------------------------------------*/

    /**
     * @notice Withdraw funds
     * @param to To
     * @param amount Amount
     */
    function withdraw(address to, uint256 amount) external onlyOwner {
        if (amount > address(this).balance) revert InsufficientValue();

        (bool success,) = to.call{ value: amount }("");
        if (!success) revert TransferFailed();
    }
}
