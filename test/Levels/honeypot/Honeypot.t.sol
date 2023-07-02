// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {Utilities} from "../../utils/Utilities.sol";
import "forge-std/Test.sol";

import {DamnValuableToken} from "../../../src/Contracts/DamnValuableToken.sol";
import {BentoBox} from "../../../src/Contracts/honeypot/BentoBox.sol";
import {IERC20} from "../../../src/Contracts/honeypot/BentoBox.sol";
import {CauldronV4} from "../../../src/Contracts/honeypot/CauldronV4.sol";
import {WETH9} from "../../../src/Contracts/WETH9.sol";
import {Oracle} from "../../../src/Contracts/honeypot/Oracle.sol";

interface IOracle {    
    function get(bytes calldata data) external returns (bool success, uint256 rate);
    function peek(bytes calldata data) external view returns (bool success, uint256 rate);    
    function peekSpot(bytes calldata data) external view returns (uint256 rate);    
    function symbol(bytes calldata data) external view returns (string memory);
    function name(bytes calldata data) external view returns (string memory);
}



contract Honeypot is Test {    

    Utilities internal utils;  
    BentoBox internal bentoBox;      
    CauldronV4 internal cauldronMasterContract;
    DamnValuableToken internal dvt;
    DamnValuableToken internal mim;
    WETH9 internal weth;
    address payable internal attacker;    
    address payable internal owner;
    address internal thief;
    Oracle internal oracle;
    address internal cauldronInstanceWETH;    
    

    function setUp() public {
        /**
         * SETUP SCENARIO - NO NEED TO CHANGE ANYTHING HERE
         * note: there were some trivial changes I had to make to the BentoBox contract to make it compile with solidity 8.         
         */

        //set up the users
        utils = new Utilities();
        address payable[] memory users = utils.createUsers(3);
        attacker = users[0];
        owner = users[1];
        thief = users[2];        
        vm.label(owner, "Owner");
        vm.label(attacker, "Attacker");
        vm.label(thief, "thief");

        vm.startPrank(owner);      
        dvt = new DamnValuableToken();
        vm.label(address(dvt), "DVT");
        mim = new DamnValuableToken();
        vm.label(address(mim), "MIM");        
        weth = new WETH9();
        vm.label(address(weth), "WETH");

        //deploy bentobox instance
        bentoBox = new BentoBox(address(weth));
        vm.label(address(bentoBox), "BentoBox");        
        
        //deploy a cauldron master contract and whitelist it
        cauldronMasterContract = new CauldronV4(address(bentoBox), address(mim));
        bentoBox.whitelistMasterContract(address(cauldronMasterContract), true);                       
        vm.stopPrank();

        //deal 100 weth to the attacker        
        vm.deal(attacker, 100 ether);        
        vm.startPrank(attacker);
        weth.deposit{value: 100 ether}();
        vm.stopPrank();
        
        console.log(unicode"\n are you sure that's gonna run? 👀");
    }

    function testExploit() public {        
         
        /**
        * !! EXPLOIT START  !! 
        * note: ensure that the honeypot cauldron name is cauldronInstanceWETH, and is instantiated with WETH collateral                                            
        */        

         //...your code here

        // !! EXPLOIT END !!



        // !! POST-EXPLOIT START - DO NOT EDIT  !!                                  
          
         //set approvals
         vm.startPrank(thief);
         bentoBox.setMasterContractApproval(thief, address(cauldronMasterContract), true, 0, 0, 0);                
 
         //add weth collateral to weth cauldron    
         vm.deal(thief, 400 ether);        
         weth.deposit{value: 400 ether}();
         weth.approve(address(bentoBox), 400 ether);
         bentoBox.deposit(IERC20(address(weth)), thief, thief, 400 ether, 0);                        
         CauldronV4(cauldronInstanceWETH).addCollateral(thief, false, 400 ether);
         vm.stopPrank();                
        // !! POST-EXPLOIT END  !!
                 
        validation();
        console.log(unicode"\n you got it, nice work!🔥");
    }

    function validation() internal {
        //perform the withdrawal from the attackers perspective     
        vm.startPrank(attacker);        
        CauldronV4(cauldronInstanceWETH).removeCollateral(attacker, 500 ether);
        bentoBox.withdraw(IERC20(address(weth)), attacker, attacker, 500 ether, 0);
        require(bentoBox.balanceOf(IERC20(address(weth)), cauldronInstanceWETH) == 0);
        require(weth.balanceOf(attacker) == 500 ether);
        

    }
}
