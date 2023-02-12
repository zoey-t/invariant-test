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

contract Basic4626Deposit_handler is Test {
    MockToken public asset;
    Basic4626Deposit public vault; // erc4626 vault

    // actors (target sender in invariant tesing)
    address[] public actors;

    address internal currentActor;

    // ghost variables
    uint256 public sumBalanceOf;
    mapping(address user => uint256 assets) sumDeposits;

    

    function setUp() public {
        asset = new MockToken();
        vault = new Basic4626Deposit(address(asset), "basic 4626 deposit", "basic4626", 18);

        excludeContract(address(Basic4626Deposit));
        excludeContract(address(MockToken));


        address alice = vm.addr(0xA11ce);
        address bob = vm.addr(0xB0b);
        actors.push(alice);
        actors.push(bob);
        actors.push(address(this));

        
    }

    function invariant_A(address user_) public {
        assertTrue(vault.totalAssets() <= vault.balanceOf(user_));
        
    }


    function deposit(uint256 assets_, uint256 actorIndex_) public useActor(actorIndex_) {
        asset.mint(currentActor, assets_);
        asset.approve(address(vault), assets_);

        uint256 shares = vault.deposit(assets_, address(this));

        sumBalanceOf += shares;
        sumDeposits[currentActor] += assets_;
    }

    modifier useActor(uint256 actorIndexSeed) {
        currentActor = actors[bound(actorIndexSeed, 0, actors.length - 1)];
        vm.startPrank(currentActor);
        _;
        vm.stopPrank();
    }
}
