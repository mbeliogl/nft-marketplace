// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces/IERC165.sol";

contract ERC165 is IERC165 {

    //hash table to keep track of contract fingerprint of byte function conversions 
    mapping(bytes4 => bool) private _supportedInterfaces; 

    //so that the interface is registered at runtime  
    constructor () {
        _registerInterface(bytes4(keccak256("supportsInterface(bytes4)")));
    }

    function supportsInterface(bytes4 interfaceId) external view override returns(bool){
        return _supportedInterfaces[interfaceId];
    }

    //registering the interface 
    function _registerInterface(bytes4 interfaceId) internal {
        require(interfaceId != 0xffffffff, "ERC165: Invalid Interface");
        _supportedInterfaces[interfaceId] = true; 
    }
}