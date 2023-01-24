// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//importing to gain access to the _min() function 
import "./ERC721.sol";
import "./interfaces/IERC721Enumerable.sol";

contract ERC721Enumerable is IERC721Enumerable, ERC721 {

    uint[] private _allTokens;

    //mapping of tokenId to position in _allTokens array 
    mapping(uint => uint) private _allTokensIndex; 
    //mapping of owner to list of all owner token Ids
    mapping(address => uint[]) private _ownedTokens; 
    //mapping of token ID index to the owner tokens list 
    mapping(uint => uint) private _ownedTokensIndex; 

    //so that the interface is registered at runtime  
    constructor () {
        _registerInterface(bytes4(
            keccak256("totalSupply(bytes4)")
            ^keccak256("tokenByIndex(bytes4)")
            ^keccak256("tokenOfOwnerByIndex(bytes4)")));
    }

    // @notice Count NFTs tracked by this contract
    // @return A count of valid NFTs tracked by this contract, where each one of
    // them has an assigned and queryable owner not equal to the zero address
    function totalSupply() public override view returns (uint256){ //flip back to external
        return _allTokens.length; 
    }

    //Adding tokens to the total supply count & keeping track of index & its position in all tokens
    //gets called in _mint()
    function _addTokensToAllTokenEnumeration(uint tokenId) private {

        //set index of then token to its position in the _allTokens array 
        //because tokens get pushed to array, so its always last position
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

    //Adding (assigning) tokens to the owner when they are minted
    //gets called in _mint()
    function _addTokensToOwnerEnumeration(address to, uint tokenId) private {
        _ownedTokensIndex[tokenId] = _ownedTokens[to].length;
        _ownedTokens[to].push(tokenId);

    }

    // @notice Enumerate valid NFTs
    // @dev Throws if `_index` >= `totalSupply()`.
    // @param _index A counter less than `totalSupply()`
    // @return The token identifier for the `_index`th NFT,
    ///  (sort order not specified)
    function tokenByIndex(uint index) public override view returns(uint){
        //ensure index is not out of bounds of total supply 
        require(index < totalSupply(), "Global index is out of bounds");
        return _allTokens[index];
    }

    // @notice Enumerate NFTs assigned to an owner
    // @dev Throws if `_index` >= `balanceOf(_owner)` or if
    ///  `_owner` is the zero address, representing invalid NFTs.
    // @param _owner An address where we are interested in NFTs owned by them
    // @param _index A counter less than `balanceOf(_owner)`
    // @return The token identifier for the `_index`th NFT assigned to `_owner`,
    ///   (sort order not specified)
    function tokenOfOwnerByIndex(address owner, uint index) public override view returns(uint){
        //ensure index is not out of bounds of owner's tokens
        require(index < balanceOf(owner), "Owner index is out of bounds");
        return _ownedTokens[owner][index];
    }


    //overriding the virtual function in ERC721 
    function _mint (address to, uint tokenId) internal override(ERC721) {
        super._mint(to, tokenId);

        //1. Add tokens to the owner 
        //2. Add tokens to total supply - _allTokens
        _addTokensToAllTokenEnumeration(tokenId); 
        _addTokensToOwnerEnumeration(to, tokenId);
    }


}
