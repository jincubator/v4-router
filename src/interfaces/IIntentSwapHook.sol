// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.30;

import {IBaseHook} from "./IBaseHook.sol";
import {IntentSwap, IntentSwapAction, IntentSwapStatus} from "../types/IntentSwap.sol";
import {PoolId, PoolIdLibrary} from "@uniswap/v4-core/src/types/PoolId.sol";
import {PoolKey} from "@uniswap/v4-core/src/types/PoolKey.sol";

/// @title IIntentSwap
/// @author jincubator
/// @notice Inteface for IntentSwapHook handling intents on Unichain
interface IIntentSwapHook is IBaseHook {
    // events
    event IntentSwapCreated(bytes32 indexed intentSwapHash, IntentSwap indexed intentSwap);
    event IntentSwapSolved(bytes32 indexed intentSwapHash);
    event IntentSwapExpired(bytes32 indexed intentSwapHash);

    // structures

    // errors
    error UnableToDecodeIntentSwap();
    error InvalidIntentSwap();
    error IntentSwapSolverDeadlineExpired(uint256 swapDeadline);
    error IntentSwapDeadlineExpired(uint256 solveDeadline);
    error IntentSolvDeadlineGreaterThanSwapDeadline(uint256 solveDeadline, uint256 swapDeadline);
    error IntentAlreadyExists(bytes32 intentSwapHash);
    error InvalidIntentSwapAction(IntentSwapAction intentSwapAction);
    error IncorrectPoolId(PoolId poolId, PoolKey key);

    // functions

    /**
     * @dev Helper function to get a unique salt
     */
    function getSalt() external view returns (bytes32 salt);

    /**
     * @dev Helper function to decode hookdata into IntentSwap
     * @param hookData containing encoded intentSwap
     * @return intentSwap the decoded intentSwap
     */
    function decodeIntentSwap(bytes calldata hookData)
        external
        view
        returns (IntentSwap memory intentSwap);

    /**
     * @dev pure function to calculate the intentSwapHash from SwapParams
     * need to ensure uniqueness by using a salt
     * @param intentSwap IntentSwap Information
     * @return intentSwapHash bytes 32 value of the keccak256 of the intentSwap
     */
    function getIntentSwapHash(IntentSwap calldata intentSwap)
        external
        pure
        returns (bytes32 intentSwapHash);

    /**
     * @dev view function to retrieve intentSwap Info
     * @param poolId the pool the intent is for
     * @param intentSwapHash the hash of the intentSwap
     * @param intentSwap the intentSwap
     * need to ensure uniqueness by using a counter?
     */
    function getIntentSwap(PoolId poolId, bytes32 intentSwapHash)
        external
        view
        returns (IntentSwap memory intentSwap);
    /**
     * @dev IntentSwap creation creates an intentSwap called when intentSwapAction indicates create
     * @param intentSwapHash the kecakk256 of the intent being created used for validation purposes
     * @param intentSwap contains all the information for the intentSwap
     * @return specifiedAmount the specified currency amount
     */
    function createIntentSwap(
        PoolKey calldata key,
        bytes32 intentSwapHash,
        IntentSwap calldata intentSwap
    ) external returns (uint256 specifiedAmount);
}
