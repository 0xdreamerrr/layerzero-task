// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.27;

import {Script, console} from "forge-std/Script.sol";
import { OptOFT } from "../src/OptOFT.sol";
import { ArbOFT } from "../src/ArbOFT.sol";
import { SendParam, OFTReceipt, IOFT } from "@layerzerolabs/oft-evm/contracts/interfaces/IOFT.sol";
import { OptionsBuilder } from "@layerzerolabs/oapp-evm/contracts/oapp/libs/OptionsBuilder.sol";
import { MessagingFee } from "@layerzerolabs/oapp-evm/contracts/oapp/OApp.sol";


contract DeployOFTScript is Script {

    address public layerZeroEndpoint = 0x6EDCE65403992e310A62460808c4b910D972f10f;
    uint32 public optId = 40232;
    uint32 public arbId = 40231;

    string optUrl = vm.envString("OPT_URL");
    string arbUrl = vm.envString("ARB_URL");
    uint256 internal opt;
    uint256 internal arb;
    
    using OptionsBuilder for bytes;


    function setUp() public {
        opt = vm.createFork(optUrl);
        arb = vm.createFork(arbUrl);
    }


    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");

        vm.selectFork(arb);
        vm.startBroadcast(privateKey);
        
        ArbOFT aOFT = new ArbOFT("SuperFinal ArbOFT", "AOFT", layerZeroEndpoint, msg.sender);
        console.log("ARB contract deployed at: ", address(aOFT));

        vm.stopBroadcast();

        vm.selectFork(opt);
        vm.startBroadcast(privateKey);

        OptOFT oOFT = new OptOFT("SuperFinal OptOFT", "OOFT", layerZeroEndpoint, msg.sender);
        console.log("OPT contract deployed at: ", address(oOFT));

        oOFT.setPeer(arbId, bytes32(uint256(uint160(address(aOFT)))));

        vm.stopBroadcast();

        vm.selectFork(arb);
        vm.startBroadcast(privateKey);

        aOFT.setPeer(optId, bytes32(uint256(uint160(address(oOFT)))));
        vm.stopBroadcast();

    }
}

