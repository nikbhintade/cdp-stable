// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.19;

// First you need to understand what are invariants:
// here those invariants are as following:
// 1. The value of total DSC supply in usd should be less than value of collateral in usd
// 2. Getter or view functions should never revert

import {Test, console2 as console} from "forge-std/Test.sol";
import {StdInvariant} from "forge-std/StdInvariant.sol";

import {DeployDsc} from "script/DeployDsc.s.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";
import {DSCEngine} from "src/DSCEngine.sol";
import {DecentralizedStablecoin} from "src/DecentralizedStablecoin.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Handler} from "./Handler.t.sol";

contract InvariantTest is StdInvariant, Test {
    DeployDsc deployer;
    HelperConfig config;
    DSCEngine dse;
    DecentralizedStablecoin dsc;
    Handler handler;
    address weth;
    address wbtc;

    function setUp() external {
        deployer = new DeployDsc();
        (dsc, dse, config) = deployer.run();
        (,, weth, wbtc) = config.activeNetworkConfig();
        handler = new Handler(dse, dsc);
        targetContract(address(handler));
    }

    // exmaple of how handler works, if we want to run invariant test on redeem collateral
    // we can write test but invariant test doesn't know anything so it will throw
    // random values at it.
    // with handler, we can setup things correctly and then pass it to invariant test
    // which then throw random input to function which is setup correctly and
    // then we can see if something breaks and we need to fix it.

    function invariant_protocolMustHaveMoreValueThanTotalSupply() public view {
        uint256 totalSupply = dsc.totalSupply();
        uint256 totalWethDeposited = IERC20(weth).balanceOf(address(dse));
        uint256 totalWbtcDeposited = IERC20(wbtc).balanceOf(address(dse));

        uint256 wethValue = dse.getUsdValue(weth, totalWethDeposited);
        uint256 wbtcValue = dse.getUsdValue(wbtc, totalWbtcDeposited);

        console.log("Total supply: ", totalSupply);
        console.log("weth value: ", wethValue);
        console.log("wbtc value: ", wbtcValue);

        assert(wethValue + wbtcValue >= totalSupply);
    }

    function invariant_getterShouldNotRevert() public view {
        dse.getCollateralTokens();
    }
}
