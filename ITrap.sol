// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ITrap {
    error InvalidSample();

    event TrapTriggered(address indexed responder, bytes payload);

    function collect() external view returns (bytes memory encodedData);

    function shouldRespond(bytes[] calldata history)
        external
        pure
        returns (bool shouldRespond, bytes memory payload);
}
