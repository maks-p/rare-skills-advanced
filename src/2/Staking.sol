// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import { IERC721Receiver } from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

import { RewardToken } from "src/2/RewardToken.sol";

import "forge-std/console.sol";

/**
 * @title NFT Staking Contract
 * @author Maks Pazuniak
 */

contract Staking is IERC721Receiver {
    /*--------------------------------------------------------------------------*/
    /* Structs                                                                  */
    /*--------------------------------------------------------------------------*/

    /**
     * @notice Staking info
     * @param depositTime Deposit timestamp
     * @param withdrawn Amount withdrawn
     * @param account Account that deposited
     */
    struct StakingInfo {
        uint256 depositTime;
        uint256 withdrawn;
        address account;
    }

    /*--------------------------------------------------------------------------*/
    /* Constants                                                                */
    /*--------------------------------------------------------------------------*/

    /**
     * @notice Reward accrual period
     */
    uint256 public constant REWARD_ACCRUAL_PERIOD = 1 days;

    /**
     * @notice The reward per accrual period
     */
    uint256 internal constant REWARD_ACCRUAL_RATE = 10 ether;

    /**
     * @notice The reward token
     */
    RewardToken internal immutable _rewardToken;

    /**
     * @notice The staked token
     */
    IERC721 internal immutable _stakingToken;

    /*--------------------------------------------------------------------------*/
    /* State                                                                    */
    /*--------------------------------------------------------------------------*/

    /**
     * @notice Mapping of token id to staking info
     */
    mapping(uint256 => StakingInfo) internal _stakingInfo;

    /*--------------------------------------------------------------------------*/
    /* Errors                                                                   */
    /*--------------------------------------------------------------------------*/

    /**
     * @notice Only the admin can call this function
     */
    error UnauthorizedCaller();

    /**
     * @notice Zero reward
     */
    error ZeroReward();

    /*--------------------------------------------------------------------------*/
    /* Constructor                                                              */
    /*--------------------------------------------------------------------------*/

    /**
     * @notice Constructor for Staking contract
     */
    constructor(address stakedToken_) {
        /* Deploy reward token */
        _rewardToken = new RewardToken("Reward Token", "RWD");

        /* Set staked token */
        _stakingToken = IERC721(stakedToken_);
    }

    /*--------------------------------------------------------------------------*/
    /* View                                                                     */
    /*--------------------------------------------------------------------------*/

    /**
     * @notice Reward token
     */
    function rewardToken() external view returns (address) {
        return address(_rewardToken);
    }

    /**
     * @notice Staking token
     */
    function stakingToken() external view returns (address) {
        return address(_stakingToken);
    }

    /**
     * @notice Staking info
     * @param tokenId Token id
     * @return Staking info
     */
    function stakingInfo(uint256 tokenId) external view returns (StakingInfo memory) {
        return _stakingInfo[tokenId];
    }

    /**
     * @notice Current reward
     */
    function currentReward(uint256 tokenId) external view returns (uint256) {
        return _currentReward(tokenId);
    }

    /*--------------------------------------------------------------------------*/
    /* External                                                                 */
    /*--------------------------------------------------------------------------*/

    /**
     * @dev See {IERC721Receiver-onERC721Received}.
     */
    function onERC721Received(address, address from, uint256 tokenId, bytes calldata) external returns (bytes4) {
        if (msg.sender != address(_stakingToken)) revert UnauthorizedCaller();

        StakingInfo memory stakingInfo_ = StakingInfo({ depositTime: block.timestamp, withdrawn: 0, account: from });
        _stakingInfo[tokenId] = stakingInfo_;

        return IERC721Receiver.onERC721Received.selector;
    }

    /**
     * @notice Withdraw staked ERC721 token
     * @param tokenId Token id
     */
    function withdrawERC721(uint256 tokenId) external {
        if (_stakingInfo[tokenId].account != msg.sender) revert UnauthorizedCaller();

        _withdrawRewards(tokenId, msg.sender);

        delete _stakingInfo[tokenId];

        _stakingToken.safeTransferFrom(address(this), msg.sender, tokenId);
    }

    /**
     * @notice Withdraw rewards
     * @param tokenId Token id
     */
    function withdrawRewards(uint256 tokenId) external {
        if (_stakingInfo[tokenId].account != msg.sender) revert UnauthorizedCaller();

        _withdrawRewards(tokenId, msg.sender);
    }

    /*--------------------------------------------------------------------------*/
    /* Internal                                                                 */
    /*--------------------------------------------------------------------------*/

    /**
     * @notice Helper function to calculate current reward
     *
     * @param tokenId Token id
     */
    function _currentReward(uint256 tokenId) internal view returns (uint256) {
        StakingInfo storage stakingInfo_ = _stakingInfo[tokenId];

        /* Get periods floor */
        uint256 periods = (block.timestamp - stakingInfo_.depositTime) / REWARD_ACCRUAL_PERIOD;

        /* Calculate total rewards earned */
        uint256 reward = periods * REWARD_ACCRUAL_RATE;

        /* Return net reward owned */
        return reward - stakingInfo_.withdrawn;
    }

    /**
     * @notice Helper function to withdraw rewards
     *
     * @param tokenId Token id
     */
    function _withdrawRewards(uint256 tokenId, address account) internal {
        /* Get current reward*/
        uint256 reward = _currentReward(tokenId);

        if (reward > 0) {
            /* Update state */
            _stakingInfo[tokenId].withdrawn += reward;

            /* Mint reward */
            _rewardToken.mint(account, reward);
        }
    }
}
