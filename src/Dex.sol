// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "openzeppelin-contracts/token/ERC20/IERC20.sol";
import "openzeppelin-contracts/utils/math/Math.sol";

contract Dex {
    IERC20 public tokenX;
    IERC20 public tokenY;
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;

    uint256 public reserveX;
    uint256 public reserveY;

    constructor(address _tokenX, address _tokenY) {
        tokenX = IERC20(_tokenX);
        tokenY = IERC20(_tokenY);
    }

    function addLiquidity(uint256 amountX, uint256 amountY, uint256 minLP) external returns (uint256 lpTokens) {
    }


    function removeLiquidity(uint256 lpTokens, uint256 minAmountX, uint256 minAmountY) external returns (uint256 amountX, uint256 amountY) {
    }

    function swap(uint256 amountX, uint256 amountY, uint256 minOutput) external returns (uint256 output) {
    }

    function getOutputAmount(uint256 inputAmount, uint256 inputReserve, uint256 outputReserve) internal pure returns (uint256) {
    }

    function _updateReserves() internal {
    }
}