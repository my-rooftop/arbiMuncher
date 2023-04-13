// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import {IGmxRouter} from "./interfaces/IGmxRouter.sol";
import {IGmxReader} from "./interfaces/IGmxReader.sol";
import {IGmxVault} from "./interfaces/IGmxVault.sol";
import {IUniswapV2Router} from "./interfaces/IUniswapV2Router.sol";
import {IERC20} from "./interfaces/IERC20.sol";


struct InitialConfig {
    address gmxRouter;
    address gmxReader;
    address gmxVault;
    address wbtc;
    address weth;
    address uni;
    address link;
    address usdc;
    address usdt;
    address dai;
}

contract Arbitrage {
    mapping (address => uint256) public startBalance;
    mapping (address => uint256) public tokenDecimals;
    address[] public allWhitelistedTokens;

    address public weth;

    address public gov;

    address public gmxRouter;
    address public gmxReader;
    address public gmxVault;

    uint256 public ethBalance;
    uint256 public startTotalValue;


    constructor(InitialConfig memory _config){
        gov = msg.sender;

        gmxRouter = _config.gmxRouter;
        gmxReader = _config.gmxReader;
        gmxVault = _config.gmxVault;

        weth = _config.weth;

        allWhitelistedTokens.push(_config.wbtc);
        allWhitelistedTokens.push(_config.weth);
        allWhitelistedTokens.push(_config.uni);
        allWhitelistedTokens.push(_config.link);
        allWhitelistedTokens.push(_config.usdc);
        allWhitelistedTokens.push(_config.usdt);
        allWhitelistedTokens.push(_config.dai);

        tokenDecimals[_config.wbtc] = 10 ** IERC20(_config.wbtc).decimals();
        tokenDecimals[_config.weth] = 10 ** IERC20(_config.weth).decimals();
        tokenDecimals[_config.uni] = 10 ** IERC20(_config.uni).decimals();
        tokenDecimals[_config.link] = 10 ** IERC20(_config.link).decimals();
        tokenDecimals[_config.usdc] = 10 ** IERC20(_config.usdc).decimals();
        tokenDecimals[_config.usdt] = 10 ** IERC20(_config.usdt).decimals();
        tokenDecimals[_config.dai] = 10 ** IERC20(_config.dai).decimals();
    }

    modifier onlyGov() {
        _onlyGov();
        _;
    }

    function tradeGmxToSushi(        
        address _sushiRouter,
        address _tokenIn,
        address _tokenMiddle,
        uint256 _amountIn,
        uint256 _gas
    ) external onlyGov {
        (bool isProfit, uint256 out) = estimateGmxSushiTradeIsProfit(_sushiRouter, _tokenIn, _tokenMiddle, _amountIn, _gas);
        require(isProfit, "tradeGmxToSushi: trade is not profitable");
        require(isGmxTradablePre(_tokenIn, _tokenMiddle, _amountIn), "tradeGmxToSushi: GMX is not tradable");
        
    }

    function tradeSushiToGmx(
        address _sushiRouter,
        address _tokenIn,
        address _tokenMiddle,
        uint256 _amountIn,
        uint256 _gas
    ) external onlyGov {
        (bool isProfit, uint256 out) = estimateSushiGmxTradeIsProfit(_sushiRouter, _tokenIn, _tokenMiddle, _amountIn, _gas);
        require(isProfit, "tradeSushiToGmx: trade is not profitable");
        require(isGmxTradablePost(_tokenMiddle, _tokenIn, out), "tradeSushiToGmx: GMX is not tradable");
    }

    function isGmxTradablePre(
        address _tokenIn, 
        address _tokenOut, 
        uint256 _amountIn
    ) public view returns (bool) {
        uint256 poolAmount = IGmxVault(gmxVault).poolAmounts(_tokenOut);
        uint256 reservedAmount = IGmxVault(gmxVault).reservedAmounts(_tokenOut);
        uint256 bufferAmount = IGmxVault(gmxVault).bufferAmounts(_tokenOut);
        
        bool isAvailable = poolAmount > reservedAmount;

        if (!isAvailable) {
            return false;
        }

        uint256 availableAmount = poolAmount - reservedAmount;

        (uint256 amountOut, ) = IGmxReader(gmxReader).getAmountOut(gmxVault, _tokenIn, _tokenOut, _amountIn); 
        

        if (bufferAmount < poolAmount - amountOut) {
            return true;
        }

        if (amountOut < availableAmount) {
            return true;
        }

        return false;
    }

function isGmxTradablePost(
        address _tokenIn, 
        address _tokenOut, 
        uint256 _amountIn
    ) public view returns (bool) {
        uint256 poolAmount = IGmxVault(gmxVault).poolAmounts(_tokenOut);
        uint256 reservedAmount = IGmxVault(gmxVault).reservedAmounts(_tokenOut);
        uint256 bufferAmount = IGmxVault(gmxVault).bufferAmounts(_tokenOut);
        
        bool isAvailable = poolAmount > reservedAmount;

        if (!isAvailable) {
            return false;
        }

        uint256 availableAmount = poolAmount - reservedAmount;

        uint256 amountOut = _amountIn;

        if (bufferAmount < poolAmount - amountOut) {
            return true;
        }

        if (amountOut < availableAmount) {
            return true;
        }

        return false;
    }

    function estimateGmxSushiTradeIsProfit(
        address _sushiRouter,
        address _tokenIn,
        address _tokenMiddle,
        uint256 _amountIn,
        uint256 _gas
    ) public view returns (bool, uint256) {
        address[] memory gmxPath = new address[](2);
        gmxPath[0] = _tokenIn;
        gmxPath[1] = _tokenMiddle;

        (uint256 amountOut, ) = IGmxReader(gmxReader).getAmountOut(gmxVault, _tokenIn, _tokenMiddle, _amountIn);

        address[] memory sushiPath = new address[](2);
        sushiPath[0] = _tokenMiddle;
        sushiPath[1] = _tokenIn;

        uint256[] memory amountOutMins = IUniswapV2Router(_sushiRouter).getAmountsOut(amountOut, sushiPath);

        bool isIncreased = amountOutMins[1] > _amountIn;
        if (!isIncreased) {
            return (false, 0);
        }

        uint256 delta = amountOutMins[1] - _amountIn;
        uint256 deltaValue = delta * getPrice(_tokenIn) / tokenDecimals[_tokenIn];
        uint256 gas = _gas * getMinPrice(weth) / tokenDecimals[weth];

        return (deltaValue > gas, amountOutMins[1]);
    }

    function estimateSushiGmxTradeIsProfit(
        address _sushiRouter,
        address _tokenIn,
        address _tokenMiddle,
        uint256 _amountIn,
        uint256 _gas
    ) public view returns (bool, uint256) {
        address[] memory sushiPath = new address[](2);
        sushiPath[0] = _tokenIn;
        sushiPath[1] = _tokenMiddle;

        uint256[] memory amountOutMins = IUniswapV2Router(_sushiRouter).getAmountsOut(_amountIn, sushiPath);

        address[] memory gmxPath = new address[](2);
        gmxPath[0] = _tokenMiddle;
        gmxPath[1] = _tokenIn;

        (uint256 amountOut, ) = IGmxReader(gmxReader).getAmountOut(gmxVault, _tokenMiddle, _tokenIn, amountOutMins[1]);
        
        bool isIncreased = amountOut > _amountIn;
        if (!isIncreased) {
            return (false, 0);
        }

        uint256 delta = amountOut - _amountIn;
        uint256 deltaValue = delta * getPrice(_tokenIn) / tokenDecimals[_tokenIn];
        uint256 gas = _gas * getMinPrice(weth) / tokenDecimals[weth];

        return (deltaValue > gas, amountOut);
    }

    function depositWhitelistedTokens() external onlyGov {
        for (uint256 i = 0; i < allWhitelistedTokens.length; i++) {
            address token = allWhitelistedTokens[i];
            uint256 balance = IERC20(token).balanceOf(address(this));
            if (balance > 0) {
                IERC20(token).transferFrom(msg.sender, address(this), balance);
                startBalance[token] = balance;
            }
        }
        ethBalance = msg.sender.balance;
        startTotalValue = getTotalValue();
    }

    function withdrawWhitelistedTokens() external onlyGov {
        for (uint256 i = 0; i < allWhitelistedTokens.length; i++) {
            address token = allWhitelistedTokens[i];
            uint256 balance = IERC20(token).balanceOf(address(this));
            if (balance > 0) {
                IERC20(token).transfer(msg.sender, balance);
                startBalance[token] = 0;
            }
        }
    } 

    function withdrawWhitelistedToken(address _token) external onlyGov {
        IERC20(_token).transfer(msg.sender, IERC20(_token).balanceOf(address(this)));
    } 

    function isProfit() public view returns (bool, uint256) {
        uint256 totalValue = getTotalValue();
        bool hasProfit = totalValue > startTotalValue;
        uint256 profit = hasProfit ? totalValue - startTotalValue : startTotalValue - totalValue;
        return (hasProfit, profit);
    }

    function getTotalValue() public view returns (uint256) {
        uint256 totalValue = 0;

        uint256 currentEthBalance = msg.sender.balance;
        uint256 wethPrice = getPrice(weth);
        totalValue += currentEthBalance * wethPrice / tokenDecimals[weth];

        for (uint256 i = 0; i < allWhitelistedTokens.length; i++) {
            address token = allWhitelistedTokens[i];
            uint256 balance = IERC20(token).balanceOf(address(this));
            uint256 price = getPrice(token);
            totalValue += balance * price / tokenDecimals[token];
        }
        return totalValue;
    }

    function recoverEth() external onlyGov {
        payable(msg.sender).transfer(address(this).balance);
    }

    function getPrice(address _token) public view returns (uint256) {
        return IGmxVault(gmxVault).getMaxPrice(_token);
    }

    function getMinPrice(address _token) public view returns (uint256) {
        return IGmxVault(gmxVault).getMinPrice(_token);
    }

    function _approveToken(address _token, address _router) internal {
        IERC20 token = IERC20(_token);
        uint256 allowance = token.allowance(address(this), _router);
        if (allowance != type(uint256).max) {
            token.approve(_router, type(uint256).max);
        }
    }

    function _onlyGov() internal view {
        require(msg.sender == gov, "Arbitrage: not authorized");
    }


}