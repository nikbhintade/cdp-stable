// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
// import {DeployDsc} from "script/DeployDsc.s.sol";
import {DecentralizedStablecoin} from "src/DecentralizedStablecoin.sol";
// import {DSCEngine} from "src/DSCEngine.sol";
// import {HelperConfig} from "script/HelperConfig.s.sol";
// import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract DecentralizedStablecoinTest is Test {
    DecentralizedStablecoin dsc;

    address TESTER = makeAddr("TESTER");
    address constant ZERO_ADDRESS = address(0);
    uint256 public constant TOKEN_AMOUNT = 10e18;
    uint256 public constant ZERO_AMOUNT = 0 ether;

    function setUp() external {
        dsc = new DecentralizedStablecoin();
    }

    /*//////////////////////////////////////////////////////////////
                              CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    function testConstructorValueAreCorrect() public view {
        // erc20 values
        vm.assertEq(dsc.name(), "De Stable");
        vm.assertEq(dsc.symbol(), "DSC");

        // owner address
        vm.assertEq(dsc.owner(), address(this));
        // here owner is not the msg.sender but the contract deploying dsc
        // which is our test contract and that's why I have put address(this)
        // while using script to deploy the contract for test this issue
        // won't come up.
    }

    /*//////////////////////////////////////////////////////////////
                             BURN FUNCTION
    //////////////////////////////////////////////////////////////*/

    function testBurnRevertOnBalanceZero() public {
        vm.expectRevert(DecentralizedStablecoin.DecentralizedStablecoin__BurnAmountExceedsBalance.selector);
        dsc.burn(TOKEN_AMOUNT);
    }

    function testBurnRevertsOnValueZeroOrLess() public {
        vm.expectRevert(DecentralizedStablecoin.DecentralizedStablecoin__MustBeMoreThanZero.selector);
        dsc.burn(ZERO_AMOUNT);
    }

    function testBurnFailsOnCalledByAddressOtherThanOwner() public {
        dsc.mint(TESTER, TOKEN_AMOUNT);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, TESTER));
        vm.prank(TESTER);
        dsc.burn(TOKEN_AMOUNT);
    }

    function testBurnReducesTheTotalSupply() public {
        // Arranage
        dsc.mint(address(this), TOKEN_AMOUNT);
        uint256 dscTotalSupply = dsc.totalSupply();

        // Act
        dsc.burn(TOKEN_AMOUNT / 2);

        // Assert
        uint256 dscTotalSupplyAfterBurn = dsc.totalSupply();
        vm.assertEq(dscTotalSupplyAfterBurn, dscTotalSupply / 2);
    }

    /*//////////////////////////////////////////////////////////////
                             MINT FUNCTION
    //////////////////////////////////////////////////////////////*/

    function testMintRevertOnAmountLessThanOrEqualToZero() public {
        vm.expectRevert(DecentralizedStablecoin.DecentralizedStablecoin__MustBeMoreThanZero.selector);
        dsc.mint(TESTER, ZERO_AMOUNT);
    }

    function testMintRevertsOnMintedToZeroAddress() public {
        vm.expectRevert(DecentralizedStablecoin.DecentralizedStablecoin__MintToZeroAddressNotAllowed.selector);
        dsc.mint(ZERO_ADDRESS, TOKEN_AMOUNT);
    }

    function testMintFailsOnCalledByAddressOtherThanOwner() public {
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, TESTER));
        vm.prank(TESTER);
        dsc.mint(TESTER, TOKEN_AMOUNT);
    }
}
