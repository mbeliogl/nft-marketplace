// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC721Connector.sol";

contract KryptoBird is ERC721Connector {

    //array to store our NFTs
    string[] public kryptoBirdz;

    //to ensure that the nft doesn't already exist 
    //sets as true every time the mint function is ran 
    mapping(string => bool) _kryptoBirdzExists;


    function mint(string memory _kryptoBird) public {

        require(!_kryptoBirdzExists[_kryptoBird], "Error - kryptoBird already exists");

        // this is deprecated -> uint _id = KryptoBirdz.push(_kryptoBird);
        kryptoBirdz.push(_kryptoBird);
        uint _id = kryptoBirdz.length - 1;

        _mint(msg.sender, _id);
        _kryptoBirdzExists[_kryptoBird] = true; 
    }


    constructor () ERC721Connector("KryptoBird", "KBIRDZ") {}
}



