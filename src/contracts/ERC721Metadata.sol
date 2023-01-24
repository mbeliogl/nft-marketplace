// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// contains the metadata of the primary contract (KryptoBirdz)

import "./interfaces/IERC721Metadata.sol";
import "./ERC165.sol";


contract ERC721Metadata is IERC721Metadata, ERC165 {
    string private _name;
    string private _symbol; 

    //when bringing strings into functions, we HAVE to use memory key word 
    constructor(string memory named, string memory symbolified){
        _name = named; 
        _symbol = symbolified;

        //so that the interface is registered at runtime  
        _registerInterface(bytes4(
            keccak256("name(bytes4)")
            ^keccak256("symbol(bytes4)")));
    }   

    //creating functions because vars are set to private 
    function name() external view override returns(string memory){
        return _name;
    }    

    function symbol() external view override returns(string memory){
        return _symbol; 
    }

}