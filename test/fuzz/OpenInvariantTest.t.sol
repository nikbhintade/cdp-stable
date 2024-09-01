// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.19;

// // First you need to understand what are invariants:
// // here those invariants are as following:
// // 1. The value of total DSC supply in usd should be less than value of collateral in usd
// // 2. Getter or view functions should never revert

// import {Test} from "forge-std/Test.sol";
// import {StdInvariant} from "forge-std/StdInvariant.sol";

// import {DeployDsc} from "script/DeployDsc.s.sol";
// import {HelperConfig} from "script/HelperConfig.s.sol";
// import {DSCEngine} from "src/DSCEngine.sol";
// import {DecentralizedStablecoin} from "src/DecentralizedStablecoin.sol";
// import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// contract OpenInvariantTest is StdInvariant, Test {
//     DeployDsc deployer;
//     HelperConfig config;
//     DSCEngine dse;
//     DecentralizedStablecoin dsc;
//     address weth;
//     address wbtc;

//     function setUp() external {
//         deployer = new DeployDsc();
//         (dsc, dse, config) = deployer.run();
//         (,, weth, wbtc) = config.activeNetworkConfig();
//         targetContract(address(dse));
//     }

//     // function invariant_protocolMustHaveMoreValueThanTotalSupply() public view {
//     //     uint256 totalSupply = dsc.totalSupply();
//     //     uint256 totalWethDeposited = IERC20(weth).balanceOf(address(dse));
//     //     uint256 totalWbtcDeposited = IERC20(wbtc).balanceOf(address(dse));

//     //     uint256 wethValue = dse.getUsdValue(weth, totalWethDeposited);
//     //     uint256 wbtcValue = dse.getUsdValue(wbtc, totalWbtcDeposited);

//     //     assert(wethValue + wbtcValue >= totalSupply);
//     // }
// }
