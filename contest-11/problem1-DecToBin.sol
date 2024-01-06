// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract ToBinary {
    function toBinary(uint256 n) public pure returns (string memory) {
        require(n <= 255, "Number must be between 0 and 255");
        bytes memory output = new bytes(8);
        for (uint8 i = 0; i < 8; i++) {
            output[7 - i] = (n % 2 == 1) ? bytes1("1") : bytes1("0");
            n /= 2;
        }
        return string(output);
    }
}
