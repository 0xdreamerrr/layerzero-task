// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.27;

// OApp imports
import { IOAppOptionsType3, EnforcedOptionParam } from "@layerzerolabs/oapp-evm/contracts/oapp/libs/OAppOptionsType3.sol";
import { OptionsBuilder } from "@layerzerolabs/oapp-evm/contracts/oapp/libs/OptionsBuilder.sol";
import { OFTMock } from "devtools/examples/oft-adapter/test/mocks/OFTMock.sol";

// OFT imports
import { IOFT, SendParam, OFTReceipt } from "@layerzerolabs/oft-evm/contracts/interfaces/IOFT.sol";
import { MessagingFee, MessagingReceipt } from "@layerzerolabs/oft-evm/contracts/OFTCore.sol";
import { OFTMsgCodec } from "@layerzerolabs/oft-evm/contracts/libs/OFTMsgCodec.sol";
import { OFTComposeMsgCodec } from "@layerzerolabs/oft-evm/contracts/libs/OFTComposeMsgCodec.sol";

// OZ imports
import { IERC20 } from "openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import { TestHelperOz5 } from "devtools/packages/test-devtools-evm-foundry/contracts/TestHelperOz5.sol";

// Forge imports
import "forge-std/console.sol";
import {Test} from "forge-std/Test.sol";

import {OptOFT} from "src/OptOFT.sol";
import {ArbOFT} from "src/ArbOFT.sol";


contract SendOFT is TestHelperOz5 {

    using OptionsBuilder for bytes;

    uint256 internal opt;
    uint256 internal arb;

    address private userA = address(0x1);
    address private userB = address(0x2);
    uint256 private initialBalance = 5000 ether;

    uint32 private aEid = 1;
    uint32 private oEid = 2;

    ArbOFT private aOFT;
    OptOFT private oOFT;

    function setUp() public override{      
        super.setUp();

        setUpEndpoints(2, LibraryType.UltraLightNode);

        vm.deal(userA, 1000 ether);
        vm.deal(userB, 1000 ether);
        
        vm.prank(userA);
        aOFT = ArbOFT(
            _deployOApp(type(ArbOFT).creationCode, abi.encode("GL ARB", "GL", address(endpoints[aEid]), address(userA)))
        );

        vm.prank(userB);
        oOFT = OptOFT(
            _deployOApp(type(OptOFT).creationCode, abi.encode("GL OPT", "GL", address(endpoints[oEid]), address(userB)))
        );

        // aOFT.mint(userA, initialBalance);
        // oOFT.mint(userB, initialBalance);
    }


    function test_constructor() public view{

        assertEq(aOFT.owner(), userA);
        assertEq(aOFT.token(), address(aOFT));
        assertEq(aOFT.balanceOf(userA), initialBalance);

        assertEq(oOFT.owner(), userB);
        assertEq(oOFT.token(), address(oOFT));
        assertEq(oOFT.balanceOf(userB), initialBalance);
    }


    function test_send_oft() public {
        uint256 tokensToSend = 100 ether;
        vm.deal(address(aOFT), 10 ether);

        vm.prank(userB);
        oOFT.setPeer(aEid, bytes32(uint256(uint160(address(aOFT)))));

        vm.prank(userA);
        aOFT.setPeer(oEid, bytes32(uint256(uint160(address(oOFT)))));


        assertEq(aOFT.balanceOf(userA), initialBalance);
        assertEq(oOFT.balanceOf(userB), initialBalance);

        aOFT.mint(address(aOFT), 5000 ether);
        vm.prank(userA);
        aOFT.sendOFTtoOpt(tokensToSend, oEid, userB);


        vm.prank(userA);
        verifyPackets(oEid, addressToBytes32(address(oOFT)));


        assertEq(aOFT.balanceOf(userA), initialBalance - tokensToSend);
        assertEq(oOFT.balanceOf(userB), initialBalance + tokensToSend);
    
    }
}