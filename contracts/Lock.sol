// // SPDX-License-Identifier: MIT
// pragma solidity 0.8.11;


// interface IERC20 {
//     function totalSupply() external view returns (uint256);

//     function balanceOf(address account) external view returns (uint256);

//     function transfer(address recipient, uint256 amount)
//         external
//         returns (bool);

//     function allowance(address owner, address spender)
//         external
//         view
//         returns (uint256);

//     function approve(address spender, uint256 amount) external returns (bool);

//     function transferFrom(
//         address sender,
//         address recipient,
//         uint256 amount
//     ) external returns (bool);

//     event Transfer(address indexed from, address indexed to, uint256 value);
//     event Approval(
//         address indexed owner,
//         address indexed spender,
//         uint256 value
//     );
// }

// interface IGmxRouter {
//     function swap(
//         address[] memory _path,
//         uint256 _amountIn,
//         uint256 _minOut,
//         address _receiver
//     ) external;
// }

// interface IGmxReader {
//     function getAmountOut(
//         address _vault,
//         address _tokenIn,
//         address _tokenOut,
//         uint256 _amountIn
//     ) external view returns (uint256, uint256);
// }

// interface IGmxVault {
//     function poolAmounts(address _token) external view returns (uint256);

//     function bufferAmounts(address _token) external view returns (uint256);

//     function reservedAmounts(address _token) external view returns (uint256);
// }

// interface IUniswapV2Router {
//     function getAmountsOut(uint256 amountIn, address[] memory path)
//         external
//         view
//         returns (uint256[] memory amounts);

//     function swapExactTokensForTokens(
//         uint256 amountIn,
//         uint256 amountOutMin,
//         address[] calldata path,
//         address to,
//         uint256 deadline
//     ) external returns (uint256[] memory amounts);
// }
// struct route {
//     address from;
//     address to;
//     bool stable;
// }

// interface IVeloRouter {
//     function getAmountsOut(uint256 amountIn, route[] memory path)
//         external
//         view
//         returns (uint256[] memory amounts);

//     function swapExactTokensForTokens(
//         uint256 amountIn,
//         uint256 amountOutMin,
//         route[] calldata path,
//         address to,
//         uint256 deadline
//     ) external returns (uint256[] memory amounts);
// }

// interface IUniswapV2Pair {
//     function token0() external view returns (address);

//     function token1() external view returns (address);

//     function swap(
//         uint256 amount0Out,
//         uint256 amount1Out,
//         address to,
//         bytes calldata data
//     ) external;
// }

// contract ArbiThere is Ownable {
//     struct GmxAddress {
//         address _GmxRouterAddress;
//         address _GmxReaderAddress;
//         address _GmxVaultAddress;
//     }

//     event ExpectInAndOut(uint256 AmountIn, uint256 AmountOut);

//     event ExpecTrialInAndOut(uint256 AmountIn);
//     event SushiTokenAndAmount(address Token, uint256 Amount);
//     event GmxTokenAndAmount(address Token, uint256 Amount);

//     GmxAddress GMX;

//     constructor(
//         address GmxRouterAddress,
//         address GmxReaderAddress,
//         address GmxVaultAddress
//     ) {
//         GMX._GmxRouterAddress = GmxRouterAddress;
//         GMX._GmxReaderAddress = GmxReaderAddress;
//         GMX._GmxVaultAddress = GmxVaultAddress;
//     }

//     function initialize(
//         address GmxRouterAddress,
//         address GmxReaderAddress,
//         address GmxVaultAddress
//     ) external onlyOwner {
//         GMX._GmxRouterAddress = GmxRouterAddress;
//         GMX._GmxReaderAddress = GmxReaderAddress;
//         GMX._GmxVaultAddress = GmxVaultAddress;
//     }

//     function approveToken(
//         address _token,
//         address router,
//         uint256 _amount
//     ) public {
//         IERC20(_token).approve(router, _amount);
//     }

//     function swapUniV2(
//         address router,
//         address[] memory path,
//         uint256 _amount
//     ) private {
//         emit SushiTokenAndAmount(path[0], _amount);
//         IERC20(path[0]).approve(router, _amount);

//         uint256 deadline = block.timestamp + 300;
//         IUniswapV2Router(router).swapExactTokensForTokens(
//             _amount,
//             1,
//             path,
//             address(this),
//             deadline
//         );
//     }

//     function swapGmx(
//         address router,
//         address[] memory path,
//         uint256 _amount
//     ) private {
//         emit GmxTokenAndAmount(path[0], _amount);
//         IERC20(path[0]).approve(router, _amount);
//         IGmxRouter(router).swap(path, _amount, 1, address(this));
//     }

//     function swapVelo(
//         address router,
//         route[] memory path,
//         uint256 _amount
//     ) private {
//         emit SushiTokenAndAmount(path[0].from, _amount);
//         IERC20(path[0].from).approve(router, _amount);

//         uint256 deadline = block.timestamp + 300;
//         IVeloRouter(router).swapExactTokensForTokens(
//             _amount,
//             1,
//             path,
//             address(this),
//             deadline
//         );
//     }

//     function getAmountOutMinUniV2(
//         address router,
//         address[] memory path,
//         uint256 _amount
//     ) public view returns (uint256) {
//         uint256[] memory amountOutMins = IUniswapV2Router(router).getAmountsOut(
//             _amount,
//             path
//         );
//         return amountOutMins[path.length - 1];
//     }

//     function getAmountOutMinVelo(
//         address router,
//         route[] memory path,
//         uint256 _amount
//     ) public view returns (uint256) {
//         uint256[] memory amountOutMins = IVeloRouter(router).getAmountsOut(
//             _amount,
//             path
//         );
//         return amountOutMins[amountOutMins.length - 1];
//     }

//     function getAmountOutMinGmx(address[] memory path, uint256 _amount)
//         public
//         view
//         returns (uint256)
//     {
//         uint256 outAmount = _amount;
//         for (uint256 i = 0; i < path.length - 1; i++) {
//             (uint256 out, ) = IGmxReader(GMX._GmxReaderAddress).getAmountOut(
//                 GMX._GmxVaultAddress,
//                 path[i],
//                 path[i + 1],
//                 outAmount
//             );
//             outAmount = out;
//         }

//         return outAmount;
//     }

//     // estimate

//     function estimateTradeSushiToSushi(
//         address _sushiRouter,
//         address _sushi2Router,
//         address[] memory sushiPath,
//         address[] memory sushi2Path,
//         uint256 _inputAmount,
//         uint256 gas
//     ) public view returns (uint256) {
//         uint256 amtBack1 = getAmountOutMinUniV2(
//             _sushiRouter,
//             sushiPath,
//             _inputAmount
//         );
//         uint256 amtBack2 = getAmountOutMinUniV2(
//             _sushi2Router,
//             sushi2Path,
//             amtBack1
//         );

//         amtBack2 -= gas;
//         return amtBack2;
//     }

//     function estimateTradeSushiToGmx(
//         address _uniV2Router,
//         address[] memory sushiPath,
//         address[] memory gmxPath,
//         uint256 _inputAmount,
//         uint256 gas
//     ) public view returns (uint256) {
//         uint256 amtBack1 = getAmountOutMinUniV2(
//             _uniV2Router,
//             sushiPath,
//             _inputAmount
//         );
//         uint256 amtBack2 = getAmountOutMinGmx(gmxPath, amtBack1);

//         amtBack2 -= gas;
//         return amtBack2;
//     }

//     function estimateTradeGmxToSushi(
//         address _uniV2Router,
//         address[] memory gmxPath,
//         address[] memory sushiPath,
//         uint256 _inputAmount,
//         uint256 gas
//     ) public view returns (uint256) {
//         uint256 amtBack1 = getAmountOutMinGmx(gmxPath, _inputAmount);
//         uint256 amtBack2 = getAmountOutMinUniV2(
//             _uniV2Router,
//             sushiPath,
//             amtBack1
//         );

//         amtBack2 -= gas;
//         return amtBack2;
//     }

//     function estimateTradeVeloToGmx(
//         address _veloV2Router,
//         route[] memory sushiPath,
//         address[] memory gmxPath,
//         uint256 _inputAmount,
//         uint256 gas
//     ) public view returns (uint256) {
//         uint256 amtBack1 = getAmountOutMinVelo(
//             _veloV2Router,
//             sushiPath,
//             _inputAmount
//         );
//         uint256 amtBack2 = getAmountOutMinGmx(gmxPath, amtBack1);

//         amtBack2 -= gas;
//         return amtBack2;
//     }

//     function estimateTradeGmxToVelo(
//         address _veloV2Router,
//         address[] memory gmxPath,
//         route[] memory sushiPath,
//         uint256 _inputAmount,
//         uint256 gas
//     ) public view returns (uint256) {
//         uint256 amtBack1 = getAmountOutMinGmx(gmxPath, _inputAmount);
//         uint256 amtBack2 = getAmountOutMinVelo(
//             _veloV2Router,
//             sushiPath,
//             amtBack1
//         );

//         amtBack2 -= gas;
//         return amtBack2;
//     }

//     function verificationGmx(
//         bool calc,
//         uint256 amount,
//         address[] memory gmxPath
//     ) public view {
//         uint256 poolAmount = IGmxVault(GMX._GmxVaultAddress).poolAmounts(
//             gmxPath[gmxPath.length - 1]
//         );
//         uint256 reservedAmount = IGmxVault(GMX._GmxVaultAddress)
//             .reservedAmounts(gmxPath[gmxPath.length - 1]);
//         uint256 bufferAmount = IGmxVault(GMX._GmxVaultAddress).bufferAmounts(
//             gmxPath[gmxPath.length - 1]
//         );
//         uint256 availableAmount = poolAmount - reservedAmount;
//         uint256 Out = calc ? getAmountOutMinGmx(gmxPath, amount) : amount;
//         require(
//             bufferAmount < poolAmount - Out,
//             "Insufficient liquidity in NIT Pool"
//         );
//         require(Out < availableAmount, "Insufficient liquidity in NIT Pool");
//     }

//     // trade

//     function dualDexTradeSushiToSushi(
//         address _router1,
//         address _router2,
//         address[] memory sushiPath,
//         address[] memory sushi2Path,
//         uint256 _amount,
//         uint256 gas
//     ) external onlyOwner {
//         uint256 Out = estimateTradeSushiToSushi(
//             _router1,
//             _router2,
//             sushiPath,
//             sushi2Path,
//             _amount,
//             gas
//         );
//         require(Out > _amount, "No Profit Made");

//         address startToken = sushiPath[0];
//         address endToken = sushiPath[sushiPath.length - 1];
//         uint256 startBalance = IERC20(startToken).balanceOf(address(this));
//         uint256 endTokenInitialBalance = IERC20(endToken).balanceOf(
//             address(this)
//         );
//         swapUniV2(_router1, sushiPath, _amount);
//         uint256 endTokenBalance = IERC20(endToken).balanceOf(address(this));
//         uint256 tradeableAmount = endTokenBalance - endTokenInitialBalance;
//         swapUniV2(_router2, sushi2Path, tradeableAmount);
//         uint256 endBalance = IERC20(startToken).balanceOf(address(this));
//         endBalance -= gas;
//         require(endBalance > startBalance, "Trade Reverted, No Profit Made");
//         emit ExpectInAndOut(startBalance, endBalance);
//     }

//     function dualDexTradeSushiToGmx(
//         address _router1,
//         address _router2,
//         address[] memory sushiPath,
//         address[] memory gmxPath,
//         uint256 _amount,
//         uint256 gas
//     ) external onlyOwner {
//         uint256 Out = estimateTradeSushiToGmx(
//             _router1,
//             sushiPath,
//             gmxPath,
//             _amount,
//             gas
//         );
//         require(Out > _amount, "No Profit Made");
//         verificationGmx(false, Out, gmxPath);

//         address startToken = sushiPath[0];
//         address endToken = sushiPath[sushiPath.length - 1];
//         uint256 startBalance = IERC20(startToken).balanceOf(address(this));
//         uint256 endTokenInitialBalance = IERC20(endToken).balanceOf(
//             address(this)
//         );
//         swapUniV2(_router1, sushiPath, _amount);
//         uint256 endTokenBalance = IERC20(endToken).balanceOf(address(this));
//         uint256 tradeableAmount = endTokenBalance - endTokenInitialBalance;
//         swapGmx(_router2, gmxPath, tradeableAmount);
//         uint256 endBalance = IERC20(startToken).balanceOf(address(this));
//         endBalance -= gas;
//         // require(endBalance > startBalance, "Trade Reverted, No Profit Made");
//         emit ExpectInAndOut(startBalance, endBalance);
//     }

//     function dualDexTradeGmxToSushi(
//         address _router1,
//         address _router2,
//         address[] memory gmxPath,
//         address[] memory sushiPath,
//         uint256 _amount,
//         uint256 gas
//     ) external onlyOwner {
//         verificationGmx(true, _amount, gmxPath);
//         uint256 Out = estimateTradeGmxToSushi(
//             _router2,
//             gmxPath,
//             sushiPath,
//             _amount,
//             gas
//         );
//         require(Out > _amount, "No Profit Made");

//         address startToken = gmxPath[0];
//         address endToken = gmxPath[gmxPath.length - 1];

//         uint256 startBalance = IERC20(startToken).balanceOf(address(this));
//         uint256 endTokenInitialBalance = IERC20(endToken).balanceOf(
//             address(this)
//         );
//         swapGmx(_router1, gmxPath, _amount);
//         uint256 endTokenBalance = IERC20(endToken).balanceOf(address(this));
//         uint256 tradeableAmount = endTokenBalance - endTokenInitialBalance;
//         swapUniV2(_router2, sushiPath, tradeableAmount);
//         uint256 endBalance = IERC20(startToken).balanceOf(address(this));
//         endBalance -= gas;
//         require(endBalance > startBalance, "Trade Reverted, No Profit Made");
//         emit ExpectInAndOut(startBalance, endBalance);
//     }

//     function dualDexTradeVeloToGmx(
//         address _router1,
//         address _router2,
//         route[] memory sushiPath,
//         address[] memory gmxPath,
//         uint256 _amount,
//         uint256 gas
//     ) external onlyOwner {
//         uint256 Out = estimateTradeVeloToGmx(
//             _router1,
//             sushiPath,
//             gmxPath,
//             _amount,
//             gas
//         );
//         require(Out > _amount, "No Profit Made");
//         verificationGmx(false, Out, gmxPath);

//         address startToken = sushiPath[0].from;
//         address endToken = sushiPath[sushiPath.length - 1].to;
//         uint256 startBalance = IERC20(startToken).balanceOf(address(this));
//         uint256 endTokenInitialBalance = IERC20(endToken).balanceOf(
//             address(this)
//         );
//         swapVelo(_router1, sushiPath, _amount);
//         uint256 endTokenBalance = IERC20(endToken).balanceOf(address(this));
//         uint256 tradeableAmount = endTokenBalance - endTokenInitialBalance;
//         swapGmx(_router2, gmxPath, tradeableAmount);
//         uint256 endBalance = IERC20(startToken).balanceOf(address(this));
//         endBalance -= gas;
//         // require(endBalance > startBalance, "Trade Reverted, No Profit Made");
//         emit ExpectInAndOut(startBalance, endBalance);
//     }

//     function dualDexTradeGmxToVelo(
//         address _router1,
//         address _router2,
//         address[] memory gmxPath,
//         route[] memory sushiPath,
//         uint256 _amount,
//         uint256 gas
//     ) external onlyOwner {
//         verificationGmx(true, _amount, gmxPath);
//         uint256 Out = estimateTradeGmxToVelo(
//             _router2,
//             gmxPath,
//             sushiPath,
//             _amount,
//             gas
//         );
//         require(Out > _amount, "No Profit Made");

//         address startToken = gmxPath[0];
//         address endToken = gmxPath[gmxPath.length - 1];

//         uint256 startBalance = IERC20(startToken).balanceOf(address(this));
//         uint256 endTokenInitialBalance = IERC20(endToken).balanceOf(
//             address(this)
//         );
//         swapGmx(_router1, gmxPath, _amount);
//         uint256 endTokenBalance = IERC20(endToken).balanceOf(address(this));
//         uint256 tradeableAmount = endTokenBalance - endTokenInitialBalance;
//         swapVelo(_router2, sushiPath, tradeableAmount);
//         uint256 endBalance = IERC20(startToken).balanceOf(address(this));
//         endBalance -= gas;
//         require(endBalance > startBalance, "Trade Reverted, No Profit Made");
//         emit ExpectInAndOut(startBalance, endBalance);
//     }

//     function getBalance(address _tokenContractAddress)
//         external
//         view
//         returns (uint256)
//     {
//         uint256 balance = IERC20(_tokenContractAddress).balanceOf(
//             address(this)
//         );
//         return balance;
//     }

//     function recoverEth() external onlyOwner {
//         payable(msg.sender).transfer(address(this).balance);
//     }

//     function recoverTokens(address tokenAddress) external onlyOwner {
//         IERC20 token = IERC20(tokenAddress);
//         token.transfer(msg.sender, token.balanceOf(address(this)));
//     }
// }
