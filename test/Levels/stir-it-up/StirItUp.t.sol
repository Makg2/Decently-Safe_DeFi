// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {Utilities} from "../../utils/Utilities.sol";
import "forge-std/Test.sol";

import {DamnValuableToken} from "../../../src/Contracts/DamnValuableToken.sol";
import {BentoBox} from "../../../src/Contracts/stir-it-up/BentoBox.sol";
import {IERC20} from "../../../src/Contracts/stir-it-up/BentoBox.sol";
import {CauldronV4Fixed} from "../../../src/Contracts/stir-it-up/CauldronV4Fixed.sol";
import {WETH9} from "../../../src/Contracts/WETH9.sol";
import {Oracle} from "../../../src/Contracts/stir-it-up/Oracle.sol";

interface IOracle {    
    function get(bytes calldata data) external returns (bool success, uint256 rate);
    function peek(bytes calldata data) external view returns (bool success, uint256 rate);    
    function peekSpot(bytes calldata data) external view returns (uint256 rate);    
    function symbol(bytes calldata data) external view returns (string memory);
    function name(bytes calldata data) external view returns (string memory);
}



contract StirItUp is Test {    

    Utilities internal utils;    
    BentoBox internal degenBox;
    CauldronV4Fixed internal cauldronMasterContract;
    DamnValuableToken internal dvt;
    DamnValuableToken internal mim;
    WETH9 internal weth;
    address payable internal attacker;    
    address payable internal owner;
    address internal someUser;
    Oracle internal oracle;
    address internal cauldronInstanceWETH;
    address internal cauldronInstanceDVT;
    

    function setUp() public {
        /**
         * SETUP SCENARIO - NO NEED TO CHANGE ANYTHING HERE
         * note: there were some trivial changes I had to make to the BentoBox contract to make it compile with solidity 8.
         * note: there may also be some ''non-trivial'' changes made to the BentoBox contract. 
         */

        utils = new Utilities();
        address payable[] memory users = utils.createUsers(3);
        attacker = users[0];
        owner = users[1];
        someUser = users[2];        
        vm.label(owner, "Owner");
        vm.label(attacker, "Attacker");
        vm.label(someUser, "some user");

        vm.startPrank(owner);      

        dvt = new DamnValuableToken();
        vm.label(address(dvt), "DVT");
        mim = new DamnValuableToken();
        vm.label(address(mim), "MIM");        
        weth = new WETH9();
        vm.label(address(weth), "WETH");

        //deploy a bentobox instance
        degenBox = new BentoBox(address(weth));
        vm.label(address(degenBox), "DegenBox");        

        //deploy a cauldron master contract and whitelist it
        cauldronMasterContract = new CauldronV4Fixed(address(degenBox), address(mim));
        degenBox.whitelistMasterContract(address(cauldronMasterContract), true);        
        
        //deploy 2 cauldron instances, one with WETH collateral and one with DVT collateral
        oracle = new Oracle();
        bytes memory data1 = abi.encode(weth, oracle, "", 0, 0, 0, 0);        
        cauldronInstanceWETH = degenBox.deploy(address(cauldronMasterContract), data1, true);
        bytes memory data2 = abi.encode(dvt, oracle, "", 0, 0, 0, 0);
        cauldronInstanceDVT = degenBox.deploy(address(cauldronMasterContract), data2, true);
        
        vm.stopPrank();
        console.log(unicode"\n are you sure that's gonna run? 👀");
    }

    function testExploit() public {        

        // !! PRE-EXPLOIT START - DO NOT EDIT  !!                                  
        vm.startPrank(someUser);
        vm.deal(someUser, 420.69 ether);        
        weth.deposit{value: 420.69 ether}();
        weth.approve(address(degenBox), 420.69 ether);        
        degenBox.setMasterContractApproval(someUser, address(cauldronMasterContract), true, 0, 0, 0);

        //add weth collateral to weth cauldron
        degenBox.deposit(IERC20(address(weth)), someUser, someUser, 420.69 ether, 0);
        CauldronV4Fixed(cauldronInstanceWETH).addCollateral(someUser, false, 420.69 ether);

        //add dvt collateral to dvt cauldron
        deal(address(dvt), someUser, 13.37 ether);
        dvt.approve(address(degenBox), 13.37 ether);        
        degenBox.deposit(IERC20(address(dvt)), someUser, someUser, 13.37 ether, 0);
        CauldronV4Fixed(cauldronInstanceDVT).addCollateral(someUser, false, 13.37 ether);
        vm.stopPrank();                
        // !! PRE-EXPLOIT END  !!
         

        //!! EXPLOIT START  !!

         //...your code here                                            

        // !! EXPLOIT END !!
         
        
        validation();
        console.log(unicode"\n you got it, nice work!🔥");
    }

    function validation() internal {        
        require(degenBox.balanceOf(IERC20(address(weth)), cauldronInstanceWETH) == 0);
        require(weth.balanceOf(attacker) == 420.69 ether);
        require(degenBox.balanceOf(IERC20(address(dvt)), cauldronInstanceDVT) == 0);
        require(dvt.balanceOf(attacker) == 13.37 ether);

    }
}
