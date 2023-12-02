// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import { ERC721Enumerable } from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import { ERC721 } from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import { Ownable2Step } from "@openzeppelin/contracts/access/Ownable2Step.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { BitMaps } from "@openzeppelin/contracts/utils/structs/BitMaps.sol";
import { Math } from "@openzeppelin/contracts/utils/math/Math.sol";

contract EnumerablePrime is ERC721Enumerable, Ownable2Step {
    using BitMaps for BitMaps.BitMap;

    /*--------------------------------------------------------------------------*/
    /* Constants                                                                */
    /*--------------------------------------------------------------------------*/

    /**
     * @notice The max supply of tokens
     */
    uint256 public constant MAX_SUPPLY = 1_000;

    /**
     * @notice Price per token
     */
    uint256 public constant PRICE = 0.05 ether;

    /*--------------------------------------------------------------------------*/
    /* State                                                                    */
    /*--------------------------------------------------------------------------*/

    /**
     * @notice The token id
     */
    uint256 internal _tokenId;

    /**
     * @notice Primes
     */
    BitMaps.BitMap internal _primes;

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
    /* View                                                                     */
    /*--------------------------------------------------------------------------*/

    function prime(address account) external returns (uint256 count) {
        for (uint256 i; i < balanceOf(account); i++) {
            if (_isPrime(tokenOfOwnerByIndex(account, i))) {
                count++;
            }
        }
    }

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

        /* Validate subsequent tokenId does not exceed max supply */
        if (_tokenId > MAX_SUPPLY) revert MaxSupplyExceeded();
    }

    /*--------------------------------------------------------------------------*/
    /* Internal                                                                 */
    /*--------------------------------------------------------------------------*/

    /**
     * @notice Is prime
     *
     * @dev https://stackoverflow.com/questions/62150130/algorithm-of-checking-if-the-number-is-prime
     */
    function _isPrime(uint256 value) internal returns (bool) {
        if (_primes.get(value)) return true;

        if (value < 2) return false;

        if (value == 2 || value == 3) {
            _primes.set(value);
            return true;
        }

        if (value % 2 == 0 || value % 3 == 0) return false;

        for (uint256 i = 5; i * i <= value; i += 6) {
            if (value % i == 0 || value % (i + 2) == 0) {
                return false;
            }
        }

        _primes.set(value);
        return true;
    }

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
