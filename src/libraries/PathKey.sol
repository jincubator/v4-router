//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Currency} from "@v4/src/types/Currency.sol";
import {IHooks} from "@v4/src/interfaces/IHooks.sol";
import {PoolKey} from "@v4/src/types/PoolKey.sol";

struct PathKey {
    Currency intermediateCurrency;
    uint24 fee;
    int24 tickSpacing;
    IHooks hooks;
    bytes hookData;
}

/// @title PathKey Library
/// @notice Functions for working with PathKeys
/// @dev FORK OF v4-periphery/src/libraries/PathKeyLibrary.sol but `PathKey calldata` is now `PathKey memory`
/// TODO: use periphery's implementation, and roll our own CalldataDecoder for loading PathKey calldata
library PathKeyLibrary {
    /// @notice Get the pool and swap direction for a given PathKey
    /// @param params the given PathKey
    /// @param currencyIn the input currency
    /// @return poolKey the pool key of the swap
    /// @return zeroForOne the direction of the swap, true if currency0 is being swapped for currency1
    function getPoolAndSwapDirection(PathKey memory params, Currency currencyIn)
        internal
        pure
        returns (PoolKey memory poolKey, bool zeroForOne)
    {
        Currency currencyOut = params.intermediateCurrency;
        (Currency currency0, Currency currency1) =
            currencyIn < currencyOut ? (currencyIn, currencyOut) : (currencyOut, currencyIn);

        zeroForOne = currencyIn == currency0;
        poolKey = PoolKey(currency0, currency1, params.fee, params.tickSpacing, params.hooks);
    }
}
