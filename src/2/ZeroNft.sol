// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import { ERC721 } from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import { ERC2981 } from "@openzeppelin/contracts/token/common/ERC2981.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { Ownable2Step } from "@openzeppelin/contracts/access/Ownable2Step.sol";
import { MerkleProof } from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import { BitMaps } from "@openzeppelin/contracts/utils/structs/BitMaps.sol";

/**
 * @title Zero NFT
 * @author Maks Pazuniak
 */
contract ZeroNft is ERC721, ERC2981, Ownable2Step {
    using BitMaps for BitMaps.BitMap;

    /*--------------------------------------------------------------------------*/
    /* Constants                                                                */
    /*--------------------------------------------------------------------------*/

    /**
     * @notice The max supply of tokens
     */
    uint256 public constant MAX_SUPPLY = 1_000;

    /**
     * @notice Max mintable per transaction
     *
     * @dev This does not guard against sybil attacks
     */
    uint256 public constant MAX_MINTABLE = 10;

    /**
     * @notice Price per token
     */
    uint256 public constant PRICE = 0.05 ether;

    /**
     * @notice Allowlist price per token
     */
    uint256 public constant ALLOWLIST_PRICE = 0.03 ether;

    /**
     * @notice Allowlist period
     */
    uint256 public constant ALLOWLIST_PERIOD = 3 days;

    /**
     * @notice The merkle root
     */
    bytes32 public immutable merkleRoot;

    /**
     * @notice Public mint start time
     */
    uint256 internal immutable _publicMintStart;

    /*--------------------------------------------------------------------------*/
    /* State                                                                    */
    /*--------------------------------------------------------------------------*/

    /**
     * @notice The token id
     */
    uint256 internal _tokenId;

    /**
     * @notice The allowlist
     */
    BitMaps.BitMap internal _allowlist;

    /*--------------------------------------------------------------------------*/
    /* Errors                                                                   */
    /*--------------------------------------------------------------------------*/

    /**
     * @notice Only the admin can call this function
     */
    error UnauthorizedCaller();

    /**
     * @notice Public mint not open
     */
    error PublicMintNotOpen();

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
     * @notice Already claimed
     */
    error AlreadyClaimed();

    /**
     * @notice Invalid proof
     */
    error InvalidProof();

    /**
     * @notice Transfer failed
     */
    error TransferFailed();

    /*--------------------------------------------------------------------------*/
    /* Constructor                                                              */
    /*--------------------------------------------------------------------------*/

    /**
     * @notice Constructor for Zero NFT
     */
    constructor(bytes32 merkleRoot_) ERC721("Zero NFT", "ZERO") Ownable(msg.sender) {
        /* Set merkle root */
        merkleRoot = merkleRoot_;

        /* Set default royalty to 2.5% */
        _setDefaultRoyalty(msg.sender, 250);

        /* Set allowlist period end */
        _publicMintStart = block.timestamp + ALLOWLIST_PERIOD;
    }

    /*--------------------------------------------------------------------------*/
    /* View                                                                     */
    /*--------------------------------------------------------------------------*/

    /**
     * @notice Get the total supply
     */
    function totalSupply() external view returns (uint256) {
        return _tokenId;
    }

    /**
     * @notice Get the public mint start time
     */
    function publicMintStart() external view returns (uint256) {
        return _publicMintStart;
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
        /* Validate public mint period */
        if (block.timestamp < _publicMintStart) revert PublicMintNotOpen();

        /* Invalid amout */
        if (amount == 0) revert InvalidAmount();

        /* Validate price */
        if (msg.value < PRICE * amount) revert InsufficientValue();

        /* Optimistically mint tokens */
        for (uint256 i; i < amount; i++) {
            _safeMint(msg.sender, _tokenId++);
        }

        /* Validate max mintable not exceeded - does not guard against sybil attacks */
        if (amount > MAX_MINTABLE || balanceOf(msg.sender) > MAX_MINTABLE) revert MaxMintableExceeded();

        /* Validate subsequent tokenId does not exceed max supply */
        if (_tokenId > MAX_SUPPLY) revert MaxSupplyExceeded();
    }

    /**
     * @notice Mint a new token - allowlist
     *
     * @param proof The merkle proof
     * @param index The index
     * @param amount The amount to mint
     */
    function allowListMint(bytes32[] calldata proof, uint256 index, uint256 amount) external payable {
        /* Validate price */
        if (msg.value < ALLOWLIST_PRICE * amount) revert InsufficientValue();

        /* Verify unclaimed */
        if (_allowlist.get(index)) revert AlreadyClaimed();

        /* Verify proof */
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(msg.sender, index, amount))));
        if (!MerkleProof.verify(proof, merkleRoot, leaf)) revert InvalidProof();

        /* Mark as claimed */
        _allowlist.set(index);

        /* Optimistically mint tokens */
        for (uint256 i; i < amount; i++) {
            _safeMint(msg.sender, _tokenId++);
        }

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
        return "https://zero-nft.app/";
    }

    /*--------------------------------------------------------------------------*/
    /* Interface                                                                */
    /*--------------------------------------------------------------------------*/

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, ERC2981) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    /*--------------------------------------------------------------------------*/
    /* Admin                                                                    */
    /*--------------------------------------------------------------------------*/
    /**
     * @dev See {ERC2981-_setDefaultRoyalty}.
     */
    function setDefaultRoyalty(address receiver, uint96 feeNumerator) external onlyOwner {
        _setDefaultRoyalty(receiver, feeNumerator);
    }

    /**
     * @dev See {ERC2981-_deleteDefaultRoyalty}.
     */
    function deleteDefaultRoyalty() external onlyOwner {
        _deleteDefaultRoyalty();
    }

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
