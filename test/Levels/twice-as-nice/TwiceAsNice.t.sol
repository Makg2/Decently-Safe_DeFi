// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {Utilities} from "../../utils/Utilities.sol";
import "forge-std/Test.sol";

import {DamnValuableToken} from "../../../src/Contracts/DamnValuableToken.sol";
import {BentoBox} from "../../../src/Contracts/twice-as-nice/BentoBox.sol";
import {IERC20} from "../../../src/Contracts/twice-as-nice/BentoBox.sol";
import {CauldronV4} from "../../../src/Contracts/twice-as-nice/CauldronV4.sol";
import {WETH9} from "../../../src/Contracts/WETH9.sol";
import {Oracle} from "../../../src/Contracts/twice-as-nice/Oracle.sol";

interface IOracle {    
    function get(bytes calldata data) external returns (bool success, uint256 rate);
    function peek(bytes calldata data) external view returns (bool success, uint256 rate);    
    function peekSpot(bytes calldata data) external view returns (uint256 rate);    
    function symbol(bytes calldata data) external view returns (string memory);
    function name(bytes calldata data) external view returns (string memory);
}



contract TwiceAsNice is Test {    

    Utilities internal utils;
    BentoBox internal bentoBox;
    BentoBox internal degenBox;
    CauldronV4 internal cauldronMasterContract;
    DamnValuableToken internal mim;
    WETH9 internal weth;
    address payable internal attacker;    
    address payable internal owner;
    address internal alice;
    Oracle internal oracle;
    address internal cauldronInstance;
    uint256 internal userPrivateKey; // don't use this!

    function setUp() public {
        /**
         * SETUP SCENARIO - NO NEED TO CHANGE ANYTHING HERE
         * note: there were some trivial changes I had to make to the BentoBox contract to make it compile with solidity 8.
         * note: there may also be some ''non-trivial'' changes made to the BentoBox contract. 
         */

        utils = new Utilities();
        address payable[] memory users = utils.createUsers(2);
        attacker = users[0];
        owner = users[1];        
        vm.label(owner, "Owner");
        vm.label(attacker, "Attacker");

        userPrivateKey = 0xa11ce;
        alice = vm.addr(userPrivateKey);
        vm.label(alice, "Alice");

        vm.startPrank(owner);
        mim = new DamnValuableToken();
        vm.label(address(mim), "MIM");
        
        weth = new WETH9();
        vm.label(address(weth), "WETH");

        //deploy 2 bentobox instances
        bentoBox = new BentoBox(address(weth));
        vm.label(address(bentoBox), "BentoBox");

        degenBox = new BentoBox(address(weth));
        vm.label(address(degenBox), "DegenBox");        

        //deploy a cauldron master contract and whitelist it
        cauldronMasterContract = new CauldronV4(address(bentoBox), address(mim));
        bentoBox.whitelistMasterContract(address(cauldronMasterContract), true);        
        
        //deploy a cauldron instance contract        
        oracle = new Oracle();
        bytes memory data = abi.encode(weth, oracle, "", 0, 0, 0, 0);        
        cauldronInstance = bentoBox.deploy(address(cauldronMasterContract), data, true);        
        vm.stopPrank();
        
        console.log(unicode"\n are you sure that's gonna run? 👀");
    }

    function testExploit() public {

        // !! PRE-EXPLOIT START - DO NOT EDIT  !!     
        vm.startPrank(alice);
        vm.deal(alice, 420.69 ether);
        weth.deposit{value: 420.69 ether}();
        weth.approve(address(bentoBox), 420.69 ether);
        bentoBox.deposit(IERC20(address(weth)), alice, alice, 420.69 ether, 0);
        bytes32 digest =
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    bentoBox.DOMAIN_SEPARATOR(),
                    keccak256(
                        abi.encode(
                            keccak256("SetMasterContractApproval(string warning,address user,address masterContract,bool approved,uint256 nonce)"),
                            keccak256("Give FULL access to funds in (and approved to) BentoBox?")                                ,
                            alice,
                            address(cauldronMasterContract),
                            true,
                            bentoBox.nonces(alice)
                        )
                    )
                )
            );
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(userPrivateKey, digest);
        bentoBox.setMasterContractApproval(alice, address(cauldronMasterContract), true, v, r, s);
        CauldronV4(cauldronInstance).addCollateral(alice, false, 420.69 ether);
        //wait ... V4 is vulnerable! Let me remove it!
        CauldronV4(cauldronInstance).removeCollateral(alice, 420.69 ether);
        //while it's vulnerable, I'll also revoke my access.        
        bytes32 digest1 =
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    bentoBox.DOMAIN_SEPARATOR(),
                    keccak256(
                        abi.encode(
                            keccak256("SetMasterContractApproval(string warning,address user,address masterContract,bool approved,uint256 nonce)"),
                            keccak256("Revoke access to BentoBox?")                                ,
                            alice,
                            address(cauldronMasterContract),
                            false,
                            bentoBox.nonces(alice)
                        )
                    )
                )
            );
        (uint8 v1, bytes32 r1, bytes32 s1) = vm.sign(userPrivateKey, digest1);
        bentoBox.setMasterContractApproval(alice, address(cauldronMasterContract), false, v1, r1, s1);        
        //Just in case bentobox is compromised too, I'm going to move over to degenbox rather.
        bentoBox.withdraw(IERC20(address(weth)), alice, alice, 420.69 ether, 0);
        //I'll wait for a new version of the cauldron to come out rather...
        weth.approve(address(degenBox), 420.69 ether);
        degenBox.deposit(IERC20(address(weth)), alice, alice, 420.69 ether, 0);
        vm.stopPrank();                

        // !! PRE-EXPLOIT END  !!

         
        /**
         * !! EXPLOIT START !! 
         * note: Besides state variables, you have access to variables in this function's scope, as if you scraped the contract's history         
         * i.e. access to v, r, s, digest and v1, r1, s1, digest1 - should you need any of it.
         */        

          //...your code here

         // !! EXPLOIT END !!
        
        validation();
        console.log(unicode"\n you got it, nice work!🔥");
    }

    function validation() internal {
        require(degenBox.balanceOf(IERC20(address(weth)),alice) == 0);
        require(weth.balanceOf(attacker) == 420.69 ether);
    }
}
