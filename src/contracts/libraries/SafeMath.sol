// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library SafeMath {
    //building functions to perform safemath operations 

    // r = x + y 
    function add(uint x, uint y) internal pure returns(uint){
        uint r = x + y;

        require(r >= x, "SafeMath: Addition Overflow");
        return r; 
    }

    // r = x - y 
    function subtract(uint x, uint y) internal pure returns(uint){
        require(y <= x, "SafeMath: Subtraction Overflow");
        uint r = x - y; 
        return r; 
    }

    // r = x * y
    function multiply(uint x, uint y) internal pure returns(uint){
        uint r = x * y; 
        require(r / x == y, "SafeMath: Multiplication Overflow");
        return r; 
    }

    // r = x / y
    function divide(uint x, uint y) internal pure returns(uint){
        require(y > 0, "SafeMath: Division By Zero");
        uint r = x / y; 
        return r; 
    }

    // r = x % y 
    function modulo(uint x, uint y) internal pure returns(uint){
        require(y != 0, "SafeMath: Modulo By Zero");
        uint r = x % y; 
        return r; 
    }

}