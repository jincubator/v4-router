// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.26;

import {PoolId, PoolIdLibrary} from "v4-core/src/types/PoolId.sol";
import {SwapParams, ModifyLiquidityParams} from "v4-core/src/types/PoolOperation.sol";

// enums
enum IntentSwapStatus {
    DoesNotExist,
    Created,
    SolverDeadlineExpired,
    SwapDeadlineExpired
}

enum IntentSwapAction {
    Create, //Creates new SwapIntent
    Solve, // Solver Provides Required Output Tokens and claims Input Tokens
    Execute, // Off Chain Worker(OCW) executes original swap on pool after solver deadline expired
    Sweep // Off Chain Worker(OCW) calls this to sweep all Intents that have expired returning funds to all swappers
        // Remove, // Off Chain Worker(OCW) Similar to Sweep but for a specific IntentSwap

}

struct IntentSwap {
    // bytes32 intentSwapHash - not in structure as will be key for mapping
    // IntentSwapStatus intentSwapStatus; - not in structure as changes would effect the hash
    bytes32 salt;
    PoolId poolId;
    uint256 swapDeadline;
    uint256 solveDeadline;
    address swapper; //sender on original swap
    SwapParams swapParams;
}
