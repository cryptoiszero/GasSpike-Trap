# GasSpike-Trap
GasSpikeTrap is triggered if block.basefee suddenly increases by more than a set threshold (e.g., 50%). This reflects “abnormal” network conditions (e.g., flash attacks, mempool congestion, or coordinated spam transactions).

GasSpikeTrap
```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "./ITrap.sol";

contract GasSpikeTrap is ITrap {
    uint256 public constant GAS_SPIKE_THRESHOLD_BPS = 5000; // 50%
    uint8   public constant MIN_SAMPLES = 2;

    address public constant TARGET = YOUR_WALLET;

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
```


ITrap
```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

interface ITrap {
    error InvalidSample();

    event TrapTriggered(address indexed responder, bytes payload);

    function collect() external view returns (bytes memory encodedData);

    function shouldRespond(bytes[] calldata history)
        external
        pure
        returns (bool shouldRespond, bytes memory payload);
}
```

GasResponse
```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract GasResponse {
    event AnomalyDetected(address indexed target, uint256 feePrev, uint256 feeNow, uint256 spikeBps, uint256 blkNow);

    function handleAnomaly(bytes calldata payload) external {
        (address target, uint256 feePrev, uint256 feeNow, uint256 spikeBps, uint256 blkNow) =
            abi.decode(payload, (address, uint256, uint256, uint256, uint256));

        emit AnomalyDetected(target, feePrev, feeNow, spikeBps, blkNow);
    }
}
```
