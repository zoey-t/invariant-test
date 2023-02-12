// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import "../src/Basic4626Deposit.sol";

contract Basic4626Deposit_handler {
    Basic4626Deposit public immutable vault; // erc4626 vault

    constructor(address _asset) {
        vault = new Basic4626Deposit(_asset, "basic 4626 deposit", "basic4626", 18);
    }

    function deposit() external {

    }
}