// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./SafeMath.sol";

library Counters {
    using SafeMath for uint; 

    //building our own variable type with keyword 'struct' 
    struct Counter {
        uint _value; 
    }

    //finding current value of a count 
    function current(Counter storage counter) internal view returns(uint) {
        return counter._value;
    }

    function decrement(Counter storage counter) internal {
        counter._value = counter._value.subtract(1);
    }

    function increment(Counter storage counter) internal {
        counter._value += 1;
    }
}

