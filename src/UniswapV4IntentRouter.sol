// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;

import {
    PathKey,
    PoolKey,
    Currency,
    BalanceDelta,
    ISignatureTransfer,
    IUniswapV4IntentRouter
} from "./interfaces/IUniswapV4IntentRouter.sol";
import {LibZip} from "@solady/src/utils/LibZip.sol";
import {Locker} from "@v4-periphery/src/libraries/Locker.sol";
import {Multicallable} from "@solady/src/utils/Multicallable.sol";
import {
    IPoolManager,
    SwapFlags,
    BaseData,
    BaseSwapIntentRouter
} from "./base/BaseSwapIntentRouter.sol";

/// @title Uniswap V4 Swap Router
contract UniswapV4IntentRouter is IUniswapV4IntentRouter, BaseSwapIntentRouter, Multicallable {
    modifier setMsgSender() {
        Locker.set(msg.sender);
        _;
        Locker.set(address(0));
    }

    constructor(IPoolManager manager, ISignatureTransfer _permit2)
        payable
        BaseSwapIntentRouter(manager, _permit2)
    {}

    /// -----------------------

    /// @inheritdoc IUniswapV4IntentRouter
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
        override(IUniswapV4IntentRouter)
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

    /// @inheritdoc IUniswapV4IntentRouter
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
        override(IUniswapV4IntentRouter)
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

    /// @inheritdoc IUniswapV4IntentRouter
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
        override(IUniswapV4IntentRouter)
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

    /// @inheritdoc IUniswapV4IntentRouter
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        bool zeroForOne,
        PoolKey calldata poolKey,
        bytes calldata hookData,
        address receiver,
        uint256 solverDeadline,
        uint256 deadline,
        bool intentSwap
    )
        public
        payable
        virtual
        override(IUniswapV4IntentRouter)
        checkDeadline(deadline)
        setMsgSender
        returns (BalanceDelta)
    {
        // Build the flags
        uint8 flags = SwapFlags.SINGLE_SWAP;
        if (intentSwap) {
            flags |= SwapFlags.INTENT;
        }
        return _unlockAndDecode(
            abi.encode(
                BaseData({
                    amount: amountIn,
                    amountLimit: amountOutMin,
                    payer: msg.sender,
                    receiver: receiver,
                    flags: flags
                }),
                zeroForOne,
                poolKey,
                hookData
            )
        );
    }

    /// @inheritdoc IUniswapV4IntentRouter
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
        override(IUniswapV4IntentRouter)
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

    /// @inheritdoc IUniswapV4IntentRouter
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
        override(IUniswapV4IntentRouter)
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

    /// @inheritdoc IUniswapV4IntentRouter
    function swap(bytes calldata data, uint256 deadline)
        public
        payable
        virtual
        override(IUniswapV4IntentRouter)
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

    /// @inheritdoc IUniswapV4IntentRouter
    function msgSender() public view virtual returns (address) {
        return Locker.get();
    }

    /// @inheritdoc IUniswapV4IntentRouter
    fallback() external payable virtual {
        LibZip.cdFallback();
    }

    /// @inheritdoc IUniswapV4IntentRouter
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
