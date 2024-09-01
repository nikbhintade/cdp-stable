// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {DecentralizedStablecoin} from "src/DecentralizedStablecoin.sol";
import {DSCEngine} from "src/DSCEngine.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";

contract DeployDsc is Script {
    address[] public tokenAddresses;
    address[] public priceFeedAddresses;

    function run() external returns (DecentralizedStablecoin, DSCEngine, HelperConfig) {
        HelperConfig config = new HelperConfig();

        (address wethPriceFeed, address wbtcPriceFeed, address weth, address wbtc) = config.activeNetworkConfig();

        tokenAddresses = [weth, wbtc];
        priceFeedAddresses = [wethPriceFeed, wbtcPriceFeed];

        vm.startBroadcast();
        DecentralizedStablecoin dsc = new DecentralizedStablecoin();
        DSCEngine dse = new DSCEngine(tokenAddresses, priceFeedAddresses, address(dsc));

        dsc.transferOwnership(address(dse));
        vm.stopBroadcast();

        return (dsc, dse, config);
    }
}
