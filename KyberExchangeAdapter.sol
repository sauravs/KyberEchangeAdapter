/*
    Copyright 2020 Set Labs Inc.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

    SPDX-License-Identifier: Apache License, Version 2.0
*/

pragma solidity 0.6.10;
pragma experimental "ABIEncoderV2";

/**
 * @title KyberExchangeAdapter
 * @author Set Protocol
 *
 * Exchange adapter for Kyber that returns data for trades
 */

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { SafeMath } from "@openzeppelin/contracts/math/SafeMath.sol";
import { PreciseUnitMath } from "./PreciseUnitMath.sol";
import { IKyberNetworkProxy } from "./IKyberNetworkProxy.sol";

contract KyberExchangeAdapter {
    using SafeMath for uint256;
    using PreciseUnitMath for uint256;

    /* ============ Structs ============ */
    
    /**
     * Struct containing information for trade function
     */
    struct KyberTradeInfo {
        uint256 sourceTokenDecimals;        // Decimals of the token to send
        uint256 destinationTokenDecimals;   // Decimals of the token to receive
        uint256 conversionRate;             // Derived conversion rate from min receive quantity
    }

    /* ============ State Variables ============ */
    
    // Address of Kyber Network Proxy
    address public kyberNetworkProxyAddress;

    /* ============ Constructor ============ */

    /**
     * Set state variables
     *
     * @param _kyberNetworkProxyAddress    Address of Kyber Network Proxy contract
     */
    constructor(
        address _kyberNetworkProxyAddress
    )
        public
    {
        kyberNetworkProxyAddress = _kyberNetworkProxyAddress;
    }

    /* ============ External Getter Functions ============ */
    /**
     * Returns the address to approve source tokens to for trading. This is the Kyber Network
     * Proxy address
     *
     * @return address             Address of the contract to approve tokens to
     */
    function getSpender()
        external
        view
        returns (address)
    {
        return kyberNetworkProxyAddress;
    }

    /**
     * Returns the conversion rate between the source token and the destination token
     * in 18 decimals, regardless of component token's decimals
     *
     * @param  _sourceToken        Address of source token to be sold
     * @param  _destinationToken   Address of destination token to buy
     * @param  _sourceQuantity     Amount of source token to sell
     *
     * @return uint256             Conversion rate in wei
     * @return uint256             Slippage rate in wei
     */
    function getConversionRates(
        address _sourceToken,
        address _destinationToken,
        uint256 _sourceQuantity
    )
        external
        view
        returns (uint256, uint256)
    {
        // Get Kyber expectedRate to trade with
        return IKyberNetworkProxy(kyberNetworkProxyAddress).getExpectedRate(
            _sourceToken,
            _destinationToken,
            _sourceQuantity
        );
    }
}