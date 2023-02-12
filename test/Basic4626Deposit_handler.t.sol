// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import "../src/Basic4626Deposit.sol";
import "solmate/tokens/ERC20.sol";
import "forge-std/Test.sol";

contract MockToken is ERC20("Mock Token", "MToken", 18) {
    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}

contract Basic4626Deposit_test is Test {
    Basic4626Deposit_handler handler;

    function setUp() public {
        handler = new Basic4626Deposit_handler();
    }

    function invariant_totalSupply_should_eq_sumBalances() public {
        assertEq(handler.totalSupply(), handler.sumBalances());
    }

    function invariant_totalAssets_should_eq_sumDeposits() public {
        assertEq(handler.totalAssets(), handler.sumDeposits());
    }

    function invariant_totalSupply_should_ge_userShares() public {
        assertGe(handler.totalSupply(), handler.balanceOf(msg.sender));
    }

    // cannot have input parameters
    // function invariant_totalSupply_should_ge_userShares(address user) public {
    //     user;
    //     assertGe(handler.totalSupply(), 0);
    // }
}

contract Basic4626Deposit_handler is Test {
    MockToken public asset;
    Basic4626Deposit public vault; // erc4626 vault

    // actors (target sender in invariant tesing)
    address[] public actors;

    address internal currentActor;

    // ghost variables
    uint256 public sumBalances;
    uint256 public sumDeposits;
    mapping(address user => uint256 assets) public sumDepositsOf;

    constructor() {
        asset = new MockToken();
        vault = new Basic4626Deposit(address(asset), "basic 4626 deposit", "basic4626", 18);
        address alice = vm.addr(0xA11ce);
        address bob = vm.addr(0xB0b);
        actors.push(alice);
        actors.push(bob);
        actors.push(address(this));
    }

    function deposit(uint256 assets_, uint256 actorIndex_) public useActor(actorIndex_) {
        asset.mint(currentActor, assets_);
        asset.approve(address(vault), assets_);

        uint256 shares = vault.deposit(assets_, address(this));

        sumBalances += shares;
        sumDeposits += assets_;
        sumDepositsOf[currentActor] += assets_;
    }

    function totalAssets() public view returns (uint256) {
        return vault.totalAssets();
    }

    function totalSupply() public view returns (uint256) {
        return vault.totalSupply();
    }

    function balanceOf(address user_) public view returns (uint256) {
        return vault.balanceOf(user_);
    }

    modifier useActor(uint256 actorIndexSeed) {
        currentActor = actors[bound(actorIndexSeed, 0, actors.length - 1)];
        vm.startPrank(currentActor);
        _;
        vm.stopPrank();
    }
}
