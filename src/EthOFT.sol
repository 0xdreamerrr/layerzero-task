// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.27;

import { Ownable } from "openzeppelin-contracts/contracts/access/Ownable.sol";
import { OFT } from "layerzero-v2/packages/layerzero-v2/evm/oapp/contracts/oft/OFT.sol";

/// @notice OFT is an ERC-20 token that extends the OFTCore contract.
contract EthOFT is OFT {
    string oftName = "Gelasimoff ETH";
    string oftSymbol = "GLMF";
    address lzEndpoint = 0x6EDCE65403992e310A62460808c4b910D972f10f;

    constructor() OFT(oftName, oftSymbol, lzEndpoint, msg.sender) Ownable(msg.sender) {
        _mint(msg.sender, 100 ether);
    }
}