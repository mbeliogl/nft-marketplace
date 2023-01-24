// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces/IERC165.sol";
import "./ERC165.sol";
import "./interfaces/IERC721.sol";
import "./Libraries/Counters.sol";


contract ERC721 is ERC165, IERC721 {
    using Counters for Counters.Counter;
    using SafeMath for uint;

    //setting event for _mint() and making indexed to access individual parts of the log 
    //event Transfer(address indexed from, address indexed to, uint indexed tokenId);

    //event for transfer approvals 
    //approved = receiver (who is being approved)
    //event Approval(address indexed owner, address indexed approved, uint indexed tokenId);

    //Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
    //event ApprovalForAll(address indexed owner, address indexed operator, bool approved);


    /* 
    Minting function: 
        1. NFT to point to an address
        2. Keep track of token IDs 
        3. Keep track of token owner addresses mapped to token IDs 
        4. Keep track of how many tokes an owner address has 
        5. Create event that emits the transfer log - contract address, where its being minted to, ID 
    */

    //mapping from token ID to owner 
    mapping (uint => address) private _tokenOwner; 

    //mapping from owner to number of owned tokens 
    mapping (address => Counters.Counter) private _ownedTokenCount; 

    //mapping from tokenId to approved addresses 
    mapping (uint => address) private _tokenApprovals; 

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    //so that the interface is registered at runtime  
    constructor () {
        _registerInterface(bytes4(
            keccak256("balanceOf(bytes4)")
            ^keccak256("ownerOf(bytes4)")
            ^keccak256("transferFrom(bytes4)")
            ^keccak256("approve(bytes4)")
            ^keccak256("setApprovalForAll(bytes4)")
            ^keccak256("isApprovedForAll(bytes4)")
            ^keccak256("getApproved(bytes4)")));
    }

    //balanceOf is standard function from EIP. Check documention for more info. 
    //counts all NFTs assigned to an owner
    function balanceOf(address _owner) public view override returns(uint){
        require(_owner != address(0), "Error: Owner query for non-existent token");
        return _ownedTokenCount[_owner].current();
    }

    //ownerOf is standard function from EIP. Check documention for more info. 
    //finds the owner of an NFT
    //_tokenId array starts at 0!
    function ownerOf(uint _tokenId) public view override returns(address){ //flip back to external
        address owner = _tokenOwner[_tokenId];
        require(owner != address(0), "Error: Owner query for non-existent token");
        return owner;
    }


    //checking if token already exists 
    function _exists(uint tokenId) internal view returns(bool){
        address owner = _tokenOwner[tokenId];

        //returning truthienss that address is not 0
        return owner != address(0);
    }

    //minting function 
    //virtual keyword means we override this function in ERC721Enumerable 
    function _mint (address to, uint tokenId) internal virtual {

        require(to != address(0), "ERC721: Minting to a zero address");
        require(!_exists(tokenId), "ERC721: Token already minted");

        _tokenOwner[tokenId] = to; 
        _ownedTokenCount[to].increment(); 

        emit Transfer(address(0), to, tokenId);
    }

    /// @notice Transfer ownership of an NFT -- THE CALLER IS RESPONSIBLE
    ///  TO CONFIRM THAT `_to` IS CAPABLE OF RECEIVING NFTS OR ELSE
    ///  THEY MAY BE PERMANENTLY LOST
    /// @dev Throws unless `msg.sender` is the current owner, an authorized
    ///  operator, or the approved address for this NFT. Throws if `_from` is
    ///  not the current owner. Throws if `_to` is the zero address. Throws if
    ///  `_tokenId` is not a valid NFT.
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    function _transferFrom(address _from, address _to, uint256 _tokenId) internal{

        require(_to != address(0), "ERC721 ERROR: Transfer to zero address");
        require(ownerOf(_tokenId) == _from, "ERC721 ERROR: This address is not the owner");

        //assigning token to _to address
        _tokenOwner[_tokenId] == _to;
        
        //reduce ownership of _from by 1
        _ownedTokenCount[_from].decrement();

        //increase ownership of _to by 1
        _ownedTokenCount[_to].increment(); 

        emit Transfer(_from, _to, _tokenId);
    }

    function transferFrom(address _from, address _to, uint256 _tokenId) public override {
        require(isApprovedOrOwner(msg.sender, _tokenId), "ERC721 ERROR: Not Approved");
        _transferFrom(_from, _to, _tokenId);
    }

    //1. require person approving is the owner 
    //2. approve an address to a token (tokenId)
    //3. require that we can't send tokens from owner to current caller (can't appvove sending to yourself)
    //4. update the mapping of approval addresses
    function approve(address _to, uint _tokenId) public payable {
        address owner = ownerOf(_tokenId);
        require(
            msg.sender == owner || isApprovedForAll(owner, msg.sender), 
            "ERC721 ERROR: Function caller is not the owner");
        require(_to != owner, "ERC721 ERROR: Approver and _to are the same");

        _tokenApprovals[_tokenId] = _to;

        emit Approval(owner, _to, _tokenId);
    }


    /// @notice Get the approved address for a single NFT
    /// @dev Throws if `_tokenId` is not a valid NFT.
    /// @param _tokenId The NFT to find the approved address for
    /// @return The approved address for this NFT, or the zero address if there is none
    function getApproved(uint256 _tokenId) public view returns (address){
        require(_exists(_tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[_tokenId];
    }

    /// @notice Enable or disable approval for a third party ("operator") to manage
    ///  all of `msg.sender`'s assets
    /// @dev Emits the ApprovalForAll event. The contract MUST allow
    ///  multiple operators per owner.
    /// @param _operator Address to add to the set of authorized operators
    /// @param _approved True if the operator is approved, false to revoke approval
    function setApprovalForAll(address _operator, bool _approved) public {
        require(_operator != msg.sender, "ERC721: approve to caller");

        _operatorApprovals[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    /// @notice Query if an address is an authorized operator for another address
    /// @param _owner The address that owns the NFTs
    /// @param _operator The address that acts on behalf of the owner
    /// @return True if `_operator` is an approved operator for `_owner`, false otherwise
    function isApprovedForAll(address _owner, address _operator) public view returns (bool){
        return _operatorApprovals[_owner][_operator];
    }

    function isApprovedOrOwner(address spender, uint tokenId) internal view returns(bool){
        require(_exists(tokenId), "ERC721 ERROR: Token does not exist");

        address owner = ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));


    }

}
