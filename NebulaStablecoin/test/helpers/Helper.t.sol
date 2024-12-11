// SPDX-License-Identifier: MIT

pragma solidity 0.8.26;

//Foundry Tools
import {Test, console2} from "forge-std/Test.sol";

//Protocol Contracts
import {NebulaQuestCoin} from "../../src/NebulaQuestCoin.sol";

abstract contract Helper is Test {

    //Contracts Instances
    NebulaQuestCoin stablecoin;

    //Stablecoin variables
    bytes32 ADMIN_ROLE;
    bytes32 MINTER_ROLE;

    //State Variables ~ Utils
    address s_admin = makeAddr("s_admin");
    address s_minter = makeAddr("s_minter");
    address s_user01 = address(1);
    address s_user02 = address(2);
    address s_user03 = address(3);
    address s_user04 = address(4);
    
    //Token Amounts
    uint256 constant AMOUNT_TO_MINT = 10*10**18;

    //Events
    event NebulaQuestCoin_TokenMinted(address _to, uint256 _amount);
    event NebulaQuestCoin_TokenBurned(uint256 _amount);

    // Errors
    error AccessControlUnauthorizedAccount(address account, bytes32 role);

    function setUp() external {
        stablecoin = new NebulaQuestCoin("NebulaQuestCoin","NQC", s_admin, s_minter);

        ADMIN_ROLE = stablecoin.DEFAULT_ADMIN_ROLE();
        MINTER_ROLE = stablecoin.MINTER_ROLE();
    }

    modifier mintTokens(){
        //Mint tokens
        vm.prank(s_minter);
        vm.expectEmit();
        emit NebulaQuestCoin_TokenMinted(s_user01, AMOUNT_TO_MINT);
        stablecoin.mint(s_user01, AMOUNT_TO_MINT);
        _;
    }
}
