// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.27;

import { Ownable } from "openzeppelin-contracts/contracts/access/Ownable.sol";
import { OFT } from "layerzero-v2/packages/layerzero-v2/evm/oapp/contracts/oft/OFT.sol";

/// @notice OFT is an ERC-20 token that extends the OFTCore contract.
contract OptOFT is OFT {
    
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

}