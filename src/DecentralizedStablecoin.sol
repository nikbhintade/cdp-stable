// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {ERC20Burnable, ERC20} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title DecentralizedStablecoin
 * @author Me
 * @notice This contract is just the ERC20 implementation of the stablecoin. Stability mechanism will be in different contract.
 */
contract DecentralizedStablecoin is ERC20Burnable, Ownable {
    error DecentralizedStablecoin__MustBeMoreThanZero();
    error DecentralizedStablecoin__BurnAmountExceedsBalance();
    error DecentralizedStablecoin__MintToZeroAddressNotAllowed();

    constructor() ERC20("De Stable", "DSC") Ownable(msg.sender) {}

    function burn(uint256 _amount) public override onlyOwner {
        uint256 balance = balanceOf(msg.sender);

        if (_amount <= 0) {
            revert DecentralizedStablecoin__MustBeMoreThanZero();
        }

        if (balance < _amount) {
            revert DecentralizedStablecoin__BurnAmountExceedsBalance();
        }

        super.burn(_amount);
    }

    function mint(address _to, uint256 _amount) external onlyOwner returns (bool) {
        if (_to == address(0)) {
            revert DecentralizedStablecoin__MintToZeroAddressNotAllowed();
        }

        if (_amount <= 0) {
            revert DecentralizedStablecoin__MustBeMoreThanZero();
        }

        _mint(_to, _amount);
        return true;
    }
}
