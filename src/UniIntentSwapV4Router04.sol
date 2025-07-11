// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;

import {
    PathKey,
    PoolKey,
    Currency,
    BalanceDelta,
    ISignatureTransfer,
    IUniIntentSwapV4Router04
} from "./interfaces/IUniIntentSwapV4Router04.sol";
import {LibZip} from "@solady/src/utils/LibZip.sol";
import {Locker} from "@v4-periphery/src/libraries/Locker.sol";
import {Multicallable} from "@solady/src/utils/Multicallable.sol";
import {IPoolManager, SwapFlags, BaseData, BaseSwapRouter} from "./base/BaseSwapRouter.sol";

/// @title Uniswap V4 Swap Router
contract UniIntentSwapV4Router04 is IUniIntentSwapV4Router04, BaseSwapRouter, Multicallable {
    modifier setMsgSender() {
        Locker.set(msg.sender);
        _;
        Locker.set(address(0));
    }

    constructor(IPoolManager manager, ISignatureTransfer _permit2)
        payable
        BaseSwapRouter(manager, _permit2)
    {}

    /// -----------------------

    /// @inheritdoc IUniIntentSwapV4Router04
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        Currency startCurrency,
        PathKey[] calldata path,
        address receiver,
        uint256 deadline
    )
        public
        payable
        virtual
        override(IUniIntentSwapV4Router04)
        checkDeadline(deadline)
        setMsgSender
        returns (BalanceDelta)
    {
        return _unlockAndDecode(
            abi.encode(
                BaseData({
                    amount: amountIn,
                    amountLimit: amountOutMin,
                    payer: msg.sender,
                    receiver: receiver,
                    flags: 0
                }),
                startCurrency,
                path
            )
        );
    }

    /// @inheritdoc IUniIntentSwapV4Router04
    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        Currency startCurrency,
        PathKey[] calldata path,
        address receiver,
        uint256 deadline
    )
        public
        payable
        virtual
        override(IUniIntentSwapV4Router04)
        checkDeadline(deadline)
        setMsgSender
        returns (BalanceDelta)
    {
        return _unlockAndDecode(
            abi.encode(
                BaseData({
                    amount: amountOut,
                    amountLimit: amountInMax,
                    payer: msg.sender,
                    receiver: receiver,
                    flags: SwapFlags.EXACT_OUTPUT
                }),
                startCurrency,
                path
            )
        );
    }

    /// @inheritdoc IUniIntentSwapV4Router04
    function swap(
        int256 amountSpecified,
        uint256 amountLimit,
        Currency startCurrency,
        PathKey[] calldata path,
        address receiver,
        uint256 deadline
    )
        public
        payable
        virtual
        override(IUniIntentSwapV4Router04)
        checkDeadline(deadline)
        setMsgSender
        returns (BalanceDelta)
    {
        return _unlockAndDecode(
            abi.encode(
                BaseData({
                    amount: amountSpecified > 0 ? uint256(amountSpecified) : uint256(-amountSpecified),
                    amountLimit: amountLimit,
                    payer: msg.sender,
                    receiver: receiver,
                    flags: amountSpecified > 0 ? SwapFlags.EXACT_OUTPUT : 0
                }),
                startCurrency,
                path
            )
        );
    }

    /// -----------------------

    /// @inheritdoc IUniIntentSwapV4Router04
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        bool zeroForOne,
        PoolKey calldata poolKey,
        bytes calldata hookData,
        address receiver,
        uint256 deadline
    )
        public
        payable
        virtual
        override(IUniIntentSwapV4Router04)
        checkDeadline(deadline)
        setMsgSender
        returns (BalanceDelta)
    {
        return _unlockAndDecode(
            abi.encode(
                BaseData({
                    amount: amountIn,
                    amountLimit: amountOutMin,
                    payer: msg.sender,
                    receiver: receiver,
                    flags: SwapFlags.SINGLE_SWAP
                }),
                zeroForOne,
                poolKey,
                hookData
            )
        );
    }

    /// @inheritdoc IUniIntentSwapV4Router04
    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        bool zeroForOne,
        PoolKey calldata poolKey,
        bytes calldata hookData,
        address receiver,
        uint256 deadline
    )
        public
        payable
        virtual
        override(IUniIntentSwapV4Router04)
        checkDeadline(deadline)
        setMsgSender
        returns (BalanceDelta)
    {
        return _unlockAndDecode(
            abi.encode(
                BaseData({
                    amount: amountOut,
                    amountLimit: amountInMax,
                    payer: msg.sender,
                    receiver: receiver,
                    flags: SwapFlags.SINGLE_SWAP | SwapFlags.EXACT_OUTPUT
                }),
                zeroForOne,
                poolKey,
                hookData
            )
        );
    }

    /// @inheritdoc IUniIntentSwapV4Router04
    function swap(
        int256 amountSpecified,
        uint256 amountLimit,
        bool zeroForOne,
        PoolKey calldata poolKey,
        bytes calldata hookData,
        address receiver,
        uint256 deadline
    )
        public
        payable
        virtual
        override(IUniIntentSwapV4Router04)
        checkDeadline(deadline)
        setMsgSender
        returns (BalanceDelta)
    {
        return _unlockAndDecode(
            abi.encode(
                BaseData({
                    amount: amountSpecified > 0 ? uint256(amountSpecified) : uint256(-amountSpecified),
                    amountLimit: amountLimit,
                    payer: msg.sender,
                    receiver: receiver,
                    flags: SwapFlags.SINGLE_SWAP | (amountSpecified > 0 ? SwapFlags.EXACT_OUTPUT : 0)
                }),
                zeroForOne,
                poolKey,
                hookData
            )
        );
    }

    /// -----------------------

    /// @inheritdoc IUniIntentSwapV4Router04
    function swap(bytes calldata data, uint256 deadline)
        public
        payable
        virtual
        override(IUniIntentSwapV4Router04)
        checkDeadline(deadline)
        setMsgSender
        returns (BalanceDelta)
    {
        // equivalent to `require(abi.decode(data, (BaseData)).payer == msg.sender, Unauthorized())`
        assembly ("memory-safe") {
            if iszero(eq(calldataload(164), caller())) {
                mstore(0x00, 0x82b42900) // `Unauthorized()`.
                revert(0x1c, 0x04)
            }
        }
        return _unlockAndDecode(data);
    }

    /// -----------------------

    /// @inheritdoc IUniIntentSwapV4Router04
    function msgSender() public view virtual returns (address) {
        return Locker.get();
    }

    /// @inheritdoc IUniIntentSwapV4Router04
    fallback() external payable virtual {
        LibZip.cdFallback();
    }

    /// @inheritdoc IUniIntentSwapV4Router04
    receive() external payable virtual {
        IPoolManager _poolManager = poolManager;
        assembly ("memory-safe") {
            if iszero(eq(caller(), _poolManager)) {
                mstore(0x00, 0x82b42900) // `Unauthorized()`
                revert(0x1c, 0x04)
            }
        }
    }
}
