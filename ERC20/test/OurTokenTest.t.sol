// // SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {DeployOurToken} from "../script/DeployOurToken.s.sol";
import {OurToken} from "../src/OurToken.sol";

contract OurTokenTest is Test {
    OurToken public ourToken;
    DeployOurToken public deployer;

    function setUp() public {
        deployer = new DeployOurToken();
        ourToken = deployer.run();
    }
}
