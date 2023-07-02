// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {Utilities} from "../../utils/Utilities.sol";
import "forge-std/Test.sol";

import {DamnValuableToken} from "../../../src/Contracts/DamnValuableToken.sol";
import {BentoBox} from "../../../src/Contracts/free2call/BentoBox.sol";
import {IERC20} from "../../../src/Contracts/free2call/BentoBox.sol";
import {CauldronV4} from "../../../src/Contracts/free2call/CauldronV4.sol";
import {WETH9} from "../../../src/Contracts/WETH9.sol";
import {Oracle} from "../../../src/Contracts/free2call/Oracle.sol";

interface IOracle {    
    function get(bytes calldata data) external returns (bool success, uint256 rate);
    function peek(bytes calldata data) external view returns (bool success, uint256 rate);    
    function peekSpot(bytes calldata data) external view returns (uint256 rate);    
    function symbol(bytes calldata data) external view returns (string memory);
    function name(bytes calldata data) external view returns (string memory);
}



contract Free2Call is Test {    

    Utilities internal utils;  
    BentoBox internal bentoBox;      
    CauldronV4 internal cauldronMasterContract;
    DamnValuableToken internal dvt;
    DamnValuableToken internal mim;
    WETH9 internal weth;
    address payable internal attacker;    
    address payable internal owner;
    address internal alice;
    Oracle internal oracle;
    address internal cauldronInstanceWETH;
    address internal cauldronInstanceDVT;
    

    function setUp() public {
        /**
         * SETUP SCENARIO - NO NEED TO CHANGE ANYTHING HERE
         * note: there were some trivial changes I had to make to the BentoBox contract to make it compile with solidity 8.
         * note: there may also be some ''non-trivial'' changes made to the Bentobox contract.
         */

        utils = new Utilities();
        address payable[] memory users = utils.createUsers(3);
        attacker = users[0];
        owner = users[1];
        alice = users[2];        
        vm.label(owner, "Owner");
        vm.label(attacker, "Attacker");
        vm.label(alice, "Alice");

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
        
        //deploy a weth cauldron instances
        oracle = new Oracle();
        bytes memory data = abi.encode(weth, oracle, "", 0, 0, 0, 0);        
        cauldronInstanceWETH = bentoBox.deploy(address(cauldronMasterContract), data, true);                
        vm.stopPrank();        

        console.log(unicode"\n are you sure that's gonna run? 👀");
    }

    function testExploit() public {        

        // !! PRE-EXPLOIT START - DO NOT EDIT  !!                                      

        //set approvals
        vm.startPrank(alice);
        bentoBox.setMasterContractApproval(alice, address(cauldronMasterContract), true, 0, 0, 0);                

        //add weth collateral to weth cauldron        
        vm.deal(alice, 420.69 ether);        
        weth.deposit{value: 420.69 ether}();
        weth.approve(address(bentoBox), 420.69 ether);
        bentoBox.deposit(IERC20(address(weth)), alice, alice, 420.69 ether, 0);                       
        vm.stopPrank();                
        // !! PRE-EXPLOIT END  !!
         

        //!! EXPLOIT START  !!                                
        
         //...your code here
        
        // !! EXPLOIT END !!
         
        
        validation();
        console.log(unicode"\n you got it, nice work!🔥");
    }

    function validation() internal {        
        require(bentoBox.balanceOf(IERC20(address(weth)), alice) == 0);
        require(weth.balanceOf(attacker) == 420.69 ether);        
    }
}
