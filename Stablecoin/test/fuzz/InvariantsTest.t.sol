// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {StdInvariant} from "forge-std/StdInvariant.sol";
import {DSCEngine} from "../../src/DSCEngine.sol";
import {DecentralisedStableCoin} from "../../src/DecentralisedStableCoin.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {DeployDSC} from "../../script/DeployDSC.s.sol";
// import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC20Mock} from "../mocks/ERC20Mock.sol";
// import { StopOnRevertHandler } from "./StopOnRevertHandler.t.sol";
// import { console } from "forge-std/console.sol";

contract InvariantsTest is StdInvariant, Test {
    DeployDSC public deployer;
    DSCEngine public dsce;
    DecentralisedStableCoin public dsc;
    HelperConfig public helperConfig;

    address public weth;
    address public wbtc;

    function setUp() external {
        deployer = new DeployDSC();
        (dsc, dsce, helperConfig) = deployer.run();
        (,, weth, wbtc,) = helperConfig.activeNetworkConfig();
        targetContract(address(dsce));
    }

    function invariant_protocolMustHaveMoreValueThatTotalSupplyDollars() public view {
        // get value of all collateral and compare it to debt (dsc)
        uint256 totalSupply = dsc.totalSupply();
        uint256 wethDeposted = ERC20Mock(weth).balanceOf(address(dsce));
        uint256 wbtcDeposited = ERC20Mock(wbtc).balanceOf(address(dsce));

        uint256 wethValue = dsce.getUsdValue(weth, wethDeposted);
        uint256 wbtcValue = dsce.getUsdValue(wbtc, wbtcDeposited);

        console.log("wethValue: %s", wethValue);
        console.log("wbtcValue: %s", wbtcValue);

        assert(wethValue + wbtcValue >= totalSupply);
    }
}
