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
        require(amountX > 0 && amountY > 0, "Invalid amount");

        _updateReserves();

        uint256 allowanceX = tokenX.allowance(msg.sender, address(this));
        uint256 allowanceY = tokenY.allowance(msg.sender, address(this));
        require(allowanceX >= amountX, "ERC20: insufficient allowance");
        require(allowanceY >= amountY, "ERC20: insufficient allowance");

        uint256 balanceX = tokenX.balanceOf(msg.sender);
        uint256 balanceY = tokenY.balanceOf(msg.sender);
        require(balanceX >= amountX, "ERC20: transfer amount exceeds balance");
        require(balanceY >= amountY, "ERC20: transfer amount exceeds balance");

        tokenX.transferFrom(msg.sender, address(this), amountX);
        tokenY.transferFrom(msg.sender, address(this), amountY);

        if (totalSupply == 0) {
            lpTokens = Math.sqrt(amountX * amountY);
        } else {
            uint256 mintX = (amountX * totalSupply) / reserveX;
            uint256 mintY = (amountY * totalSupply) / reserveY;
            lpTokens = Math.min(mintX, mintY);
        }

        require(lpTokens >= minLP, "Minimum LP tokens not met");

        reserveX += amountX;
        reserveY += amountY;
        totalSupply += lpTokens;
        balanceOf[msg.sender] += lpTokens;
    }


    function removeLiquidity(uint256 lpTokens, uint256 minAmountX, uint256 minAmountY) external returns (uint256 amountX, uint256 amountY) {
        require(lpTokens > 0 && lpTokens <= balanceOf[msg.sender], "Invalid LP token amount");

        amountX = (lpTokens * reserveX) / totalSupply;
        amountY = (lpTokens * reserveY) / totalSupply;

        require(amountX >= minAmountX && amountY >= minAmountY, "Minimum amounts not met");

        reserveX -= amountX;
        reserveY -= amountY;
        totalSupply -= lpTokens;
        balanceOf[msg.sender] -= lpTokens;

        tokenX.transfer(msg.sender, amountX);
        tokenY.transfer(msg.sender, amountY);
    }

    function swap(uint256 amountX, uint256 amountY, uint256 minOutput) external returns (uint256 output) {
        require(amountX == 0 || amountY == 0, "Invalid input");
        require(amountX > 0 || amountY > 0, "Invalid input");

        if (amountX > 0) {
            output = getOutputAmount(amountX, reserveX, reserveY);
            require(output >= minOutput, "Output less than minimum");
            tokenX.transferFrom(msg.sender, address(this), amountX);
            tokenY.transfer(msg.sender, output);
            reserveX += amountX;
            reserveY -= output;
        } else {
            output = getOutputAmount(amountY, reserveY, reserveX);
            require(output >= minOutput, "Output less than minimum");
            tokenY.transferFrom(msg.sender, address(this), amountY);
            tokenX.transfer(msg.sender, output);
            reserveY += amountY;
            reserveX -= output;
        }
    }

    function getOutputAmount(uint256 inputAmount, uint256 inputReserve, uint256 outputReserve) internal pure returns (uint256) {
        uint256 inputAmountWithFee = inputAmount * 999;
        uint256 numerator = inputAmountWithFee * outputReserve;
        uint256 denominator = inputReserve * 1000 + inputAmountWithFee;
        return numerator / denominator;
    }

    function _updateReserves() internal {
        reserveX = tokenX.balanceOf(address(this));
        reserveY = tokenY.balanceOf(address(this));
    }
}