// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

interface IGmxReader {
    function getAmountOut(address _vault, address _tokenIn, address _tokenOut, uint256 _amountIn) external view returns (uint256, uint256);
}
