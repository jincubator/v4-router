# SwapFlags

[Git Source](https://github.com/z0r0z/v4-router/blob/2136c4940d470a172e9d496b4ec339d98f9187ae/src/libraries/SwapFlags.sol)

Library for managing swap configuration flags using bitwise operations

_Provides constants and utilities for working with swap flags encoded as uint8_

## State Variables

### SINGLE_SWAP

Flag indicating a single pool swap vs multi-hop swap

_Bit position 0 (0b00001)_

```solidity
uint8 constant SINGLE_SWAP = 1 << 0;
```

### EXACT_OUTPUT

Flag indicating exact output swap vs exact input swap

_Bit position 1 (0b00010)_

```solidity
uint8 constant EXACT_OUTPUT = 1 << 1;
```

### INPUT_6909

Flag indicating input token is ERC6909

_Bit position 2 (0b00100)_

```solidity
uint8 constant INPUT_6909 = 1 << 2;
```

### OUTPUT_6909

Flag indicating output token is ERC6909

_Bit position 3 (0b01000)_

```solidity
uint8 constant OUTPUT_6909 = 1 << 3;
```

### PERMIT2

Flag indicating swap uses Permit2 for token approvals

_Bit position 4 (0b10000)_

```solidity
uint8 constant PERMIT2 = 1 << 4;
```

## Functions

### unpackFlags

Unpacks individual boolean flags from packed uint8

```solidity
function unpackFlags(uint8 flags)
    internal
    pure
    returns (bool singleSwap, bool exactOutput, bool input6909, bool output6909, bool permit2, bool intentSwap);
```

**Parameters**

| Name    | Type    | Description                               |
| ------- | ------- | ----------------------------------------- |
| `flags` | `uint8` | The packed uint8 containing all flag bits |

**Returns**

| Name          | Type   | Description                     |
| ------------- | ------ | ------------------------------- |
| `singleSwap`  | `bool` | True if single pool swap        |
| `exactOutput` | `bool` | True if exact output swap       |
| `input6909`   | `bool` | True if input token is ERC6909  |
| `output6909`  | `bool` | True if output token is ERC6909 |
| `permit2`     | `bool` | True if using Permit2           |
