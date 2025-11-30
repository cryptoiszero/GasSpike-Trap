// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract GasResponse {
    event AnomalyDetected(address indexed target, uint256 feePrev, uint256 feeNow, uint256 spikeBps, uint256 blkNow);

    function handleAnomaly(bytes calldata payload) external {
        (address target, uint256 feePrev, uint256 feeNow, uint256 spikeBps, uint256 blkNow) =
            abi.decode(payload, (address, uint256, uint256, uint256, uint256));

        emit AnomalyDetected(target, feePrev, feeNow, spikeBps, blkNow);
    }
}
