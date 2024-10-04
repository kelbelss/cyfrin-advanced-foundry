// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import {IAccount} from "../lib/account-abstraction/contracts/interfaces/IAccount.sol";
import {PackedUserOperation} from "../lib/account-abstraction/contracts/interfaces/PackedUserOperation.sol";

contract MinimalAccount is IAccount {
    // entry point contract will call this one

    function validateUserOp(PackedUserOperation calldata userOp, bytes32 userOpHash, uint256 missingAccountFunds)
        external
        returns (uint256 validationData)
    {}
}
