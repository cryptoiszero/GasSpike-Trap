// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./ITrap.sol";

contract GasSpikeTrap is ITrap {
    uint256 public constant GAS_SPIKE_THRESHOLD_BPS = 5000; // 50%
    uint8   public constant MIN_SAMPLES = 2;

    address public constant TARGET = 0x7b1e678B98718eA599763b3247C3273F0Ff06B36;

    constructor() {}

    function collect() external view override returns (bytes memory) {
        return abi.encode(block.basefee, block.number);
    }

    function shouldRespond(bytes[] calldata data)
        external
        pure
        override
        returns (bool, bytes memory)
    {
        if (data.length < MIN_SAMPLES) return (false, "");

        (uint256 feeNow, uint256 blkNow) = abi.decode(data[0], (uint256, uint256));
        (uint256 feePrev, /* blkPrev */) = abi.decode(data[1], (uint256, uint256));

        if (feePrev == 0 || feeNow <= feePrev) return (false, "");

        uint256 spikeBps = ((feeNow - feePrev) * 10_000) / feePrev;
        if (spikeBps < GAS_SPIKE_THRESHOLD_BPS) return (false, "");

        bytes memory payload = abi.encode(TARGET, feePrev, feeNow, spikeBps, blkNow);
        return (true, payload);
    }
}
