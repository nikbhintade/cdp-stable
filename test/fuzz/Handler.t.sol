// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
// import {StdInvariant} from "forge-std/StdInvariant.sol";

// import {DeployDsc} from "script/DeployDsc.s.sol";
// import {HelperConfig} from "script/HelperConfig.s.sol";
import {DSCEngine} from "src/DSCEngine.sol";
import {DecentralizedStablecoin} from "src/DecentralizedStablecoin.sol";
// import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";

// in handler based testing, we are just creating a another contract with has less
// function so only function that can be called has everything setup in correct way.
contract Handler is Test {
    DSCEngine dse;
    DecentralizedStablecoin dsc;

    ERC20Mock weth;
    ERC20Mock wbtc;

    uint256 MAX_DEPOSIT_SIZE = type(uint96).max;

    address USER = makeAddr("USER");

    constructor(DSCEngine _dse, DecentralizedStablecoin _dsc) {
        dse = _dse;
        dsc = _dsc;

        address[] memory collateralTokens = dse.getCollateralTokens();
        weth = ERC20Mock(collateralTokens[0]);
        wbtc = ERC20Mock(collateralTokens[1]);
    }

    // redeem collateral

    // similar to fuz test argument in the test functions are randomized
    function depositCollateral(uint256 collateralSeed, uint256 amountCollateral) public {
        vm.startPrank(USER);
        ERC20Mock collateral = _getCollateralFromSeed(collateralSeed);

        ERC20Mock(collateral).mint(address(USER), MAX_DEPOSIT_SIZE);
        ERC20Mock(collateral).approve(address(dse), MAX_DEPOSIT_SIZE);

        amountCollateral = bound(amountCollateral, 1, MAX_DEPOSIT_SIZE);
        dse.depositCollateral(address(collateral), amountCollateral);

        vm.stopPrank();
    }

    function redeemCollateral(uint256 collateralSeed, uint256 amountCollateral) public {
        vm.startPrank(USER);
        ERC20Mock collateral = _getCollateralFromSeed(collateralSeed);

        uint256 maxCollateralToRedeem = dse.getCollateralBalanceOfUser(address(collateral), USER);

        amountCollateral = bound(amountCollateral, 0, maxCollateralToRedeem);
        if (amountCollateral == 0) {
            return;
        }
        dse.redeemCollateral(address(collateral), amountCollateral);
        vm.stopPrank();
    }

    function mintDsc(uint256 amount) public {
        (uint256 totalDscMinted, uint256 collateralValueInUsd) = dse.getAccountInformation(USER);
        int256 maxDscToMint = int256(collateralValueInUsd / 2) - int256(totalDscMinted);
        if (maxDscToMint <= 0) {
            return;
        }
        amount = bound(amount, 1, uint256(maxDscToMint));

        vm.startPrank(USER);
        dse.mintDsc(amount);

        vm.stopPrank();
    }

    function _getCollateralFromSeed(uint256 collateralSeed) private view returns (ERC20Mock) {
        if (collateralSeed % 2 == 0) {
            return weth;
        } else {
            return wbtc;
        }
    }
}
