// SPDX-License-Identifier: MIT
pragma solidity >=0.8.9;

import "./IUniswapV2Router02.sol";
import "./IERC20.sol";

contract SimpleRouterTest {
    address[] public routers;
    address[] public connectors;

    /**
        Gets router* and path* that give max output amount with input amount and tokens
        @param amountIn input amount
        @param tokenIn source token
        @param tokenOut destination token
        @return max output amount and router and path, that give this output amount
        router* - Uniswap-like Router
        path* - token list to swap
     */
    function quote(
        uint amountIn,
        address tokenIn,
        address tokenOut
    ) external view returns (uint amountOut, address router, address[] memory path) {
        for (uint i = 0; i < routers.length; i++) {                         // делаем цикл по роутерам, что бы проверить все
            address[] memory path = [](connectors.length + 2);              // создаем массив для хранения коннекторов и токенов
            path[0] = tokenIn;                                              // первый элемент массива - токен входа               
            path[connectors.length + 1] = tokenOut;                         // последний элемент массива - токен выхода
            for (uint j = 0; j < connectors.length; j++) {                  // делаем цикл по коннекторам, что бы добавить их в массив
                path[j + 1] = connectors[j];
            }
            uint checkAmountOut = IUniswapV2Router02(routers[i])
                .getAmountsOut(amountIn, path)[connectors.length + 1];      // получаем количество выходного токена, для этого роутера и пути
            if (checkAmountOut > amountOut) {                               // если полученное количество больше, чем текущее максимальное
                amountOut = checkAmountOut;                                 // то обновляем переменную которую возвращаем
                router = routers[i];                                        // обновляем роутер который возвращаем
                path = path;                                                // обновляем путь который возвращаем
            }
        }
    }
    
    /**
        Swaps tokens on router with path, should check slippage
        @param amountIn input amount
        @param amountOutMin minumum output amount
        @param router Uniswap-like router to swap tokens on
        @param path tokens list to swap
        @return actual output amount
     */
    function swap(
        uint amountIn,
        uint amountOutMin,
        address router,
        address[] memory path
    ) external returns (uint amountOut) {
        IERC20(path[0]).transferFrom(msg.sender, address(this), amountIn);  // переводим токен входа на контракт
        IERC20(path[0]).approve(router, amountIn);                          // разрешаем роутеру использовать токен входа
        uint[] memory amounts = IUniswapV2Router02(router)
            .swapExactTokensForTokens(amountIn, amountOutMin, path, msg.sender, block.number + 200); // меняем токены
        amountOut = amounts[amounts.length - 1];                            // получаем количество выходного токена
    }
}