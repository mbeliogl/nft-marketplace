// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Connects the other ERC contracts to our primary (KryptoBirdz)

import "./ERC721Metadata.sol";
import "./ERC721Enumerable.sol";



contract ERC721Connector is ERC721Metadata, ERC721Enumerable {
    //we want to carry the metadata over 

    constructor (string memory name, string memory symbol) ERC721Metadata(name, symbol){

    }
}
