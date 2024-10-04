// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import {IAccount} from "../lib/account-abstraction/contracts/interfaces/IAccount.sol";
import {PackedUserOperation} from "../lib/account-abstraction/contracts/interfaces/PackedUserOperation.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract MinimalAccount is IAccount, Ownable {
    // entry point contract will call this one

    constructor() Ownable(msg.sender) {}

    function validateUserOp(PackedUserOperation calldata userOp, bytes32 userOpHash, uint256 missingAccountFunds)
        external
        returns (uint256 validationData)
    {}
}
