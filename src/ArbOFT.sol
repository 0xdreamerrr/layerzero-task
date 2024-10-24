// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.27;

import { Ownable } from "openzeppelin-contracts/contracts/access/Ownable.sol";
import { OFT } from "layerzero-v2/packages/layerzero-v2/evm/oapp/contracts/oft/OFT.sol";
import { SendParam, OFTReceipt, IOFT } from "@layerzerolabs/oft-evm/contracts/interfaces/IOFT.sol";
import { OptionsBuilder } from "devtools/packages/oapp-evm/contracts/oapp/libs/OptionsBuilder.sol";
import { MessagingFee } from "@layerzerolabs/oapp-evm/contracts/oapp/OApp.sol";


/// @notice OFT is an ERC-20 token that extends the OFTCore contract.
contract ArbOFT is OFT {

    constructor(
        string memory _name,
        string memory _symbol,
        address _lzEndpoint,
        address _delegate
    ) OFT(_name, _symbol, _lzEndpoint, _delegate) Ownable(msg.sender) {
        mint(msg.sender, 5000);
    }

    function mint(address _to, uint amount) public {
        _mint(_to, amount * 10** decimals());
    }

    function sendOFTtoOpt(uint amount, uint32 eId, address receiver) public {
        bytes memory _options = OptionsBuilder.newOptions();
        bytes memory _extraOptions = OptionsBuilder.addExecutorLzReceiveOption(_options, 200000, 0);

        SendParam memory sendParam = SendParam({
            dstEid: eId,
            to: bytes32(uint256(uint160(receiver))),
            amountLD: amount * 10 ** decimals(),
            minAmountLD: amount * 10 ** decimals(),
            extraOptions: _extraOptions,
            composeMsg: "",
            oftCmd: ""
        });

        MessagingFee memory fee = IOFT(address(this)).quoteSend(sendParam, false);

        IOFT(address(this)).send{value: fee.nativeFee}(sendParam, fee, address(msg.sender));
        
        _debit(amount, amount, eId);
    }
}