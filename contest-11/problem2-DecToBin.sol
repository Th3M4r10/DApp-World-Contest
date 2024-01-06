// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract ToBinary {
    function toBinary(int256 n) public pure returns (string memory) {
        require(n >= -128 && n <= 127, "Number must be between -128 and 127");

        // If the number is negative, calculate its two's complement representation
        if (n < 0) {
            n = (1 << 8) - (-n); // 2's complement: invert bits and add 1
        }

        bytes memory output = new bytes(8);
        for (uint8 i = 0; i < 8; i++) {
            output[7 - i] = (n & 1 == 1) ? bytes1("1") : bytes1("0");
            n >>= 1;
        }

        return string(output);
    }
}
