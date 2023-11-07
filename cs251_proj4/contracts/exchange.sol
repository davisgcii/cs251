// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;


import './token.sol';
import "hardhat/console.sol";


contract TokenExchange is Ownable {
    string public exchange_name = '';

    address tokenAddr = 0x5FbDB2315678afecb367f032d93F642f64180aa3;
    Token public token = Token(tokenAddr);                                

    // Liquidity pool for the exchange
    uint private token_reserves = 0;
    uint private eth_reserves = 0;

    mapping(address => uint) private lps;
    uint constant private lp_denominator = 10**9;
     
    // Needed for looping through the keys of the lps mapping
    address[] private lp_providers;                     

    // liquidity rewards
    uint private swap_fee_numerator = 2;                // TODO Part 5: Set liquidity providers' returns.
    uint private swap_fee_denominator = 100;

    // Constant: x * y = k
    uint private k;

    constructor() {}
    

    // Function createPool: Initializes a liquidity pool between your Token and ETH.
    // ETH will be sent to pool in this transaction as msg.value
    // amountTokens specifies the amount of tokens to transfer from the liquidity provider.
    // Sets up the initial exchange rate for the pool by setting amount of token and amount of ETH.
    function createPool(uint amountTokens) external payable onlyOwner {
        // This function is already implemented for you; no changes needed.

        // require pool does not yet exist:
        require (token_reserves == 0, "Token reserves was not 0");
        require (eth_reserves == 0, "ETH reserves was not 0.");

        // require nonzero values were sent
        require (msg.value > 0, "Need eth to create pool.");
        uint tokenSupply = token.balanceOf(msg.sender);
        require(amountTokens <= tokenSupply, "Not have enough tokens to create the pool");
        require (amountTokens > 0, "Need tokens to create pool.");

        token.transferFrom(msg.sender, address(this), amountTokens);
        token_reserves = token.balanceOf(address(this));
        eth_reserves = msg.value;
        k = token_reserves * eth_reserves;
    }

    // Function removeLP: removes a liquidity provider from the list.
    // This function also removes the gap left over from simply running "delete".
    function removeLP(uint index) private {
        require(index < lp_providers.length, "specified index is larger than the number of lps");
        lp_providers[index] = lp_providers[lp_providers.length - 1];
        lp_providers.pop();
    }

    // Function getSwapFee: Returns the current swap fee ratio to the client.
    function getSwapFee() public view returns (uint, uint) {
        return (swap_fee_numerator, swap_fee_denominator);
    }



    // ============================================================
    //                    FUNCTIONS TO IMPLEMENT
    // ============================================================
    
    /* ========================= Liquidity Provider Functions =========================  */ 

    // Function addLiquidity: Adds liquidity given a supply of ETH (sent to the contract as msg.value).
    // You can change the inputs, or the scope of your function, as needed.
    function addLiquidity(uint max_exchange_rate, uint min_exchange_rate) external payable {
        // get the current exchange rate
        uint requiredTokens = token_reserves * msg.value / eth_reserves;

        // TODO: ensure it is within the bounds
        uint eth_token_rate = eth_reserves * lp_denominator / token_reserves;
        require (eth_token_rate <= max_exchange_rate && eth_token_rate >= min_exchange_rate, 'Slippage parameters exceeded.');

        // see if the provider has enough ABS; fail if insufficient funds
        require(token.balanceOf(msg.sender) >= requiredTokens, 'Insufficient tokens');

        // add provider to lp_providers if not there already; find where they are in lp_providers otherwise
        uint index;
        bool found = false;

        
        for (uint i = 0; i < lp_providers.length; i++) {
            if (lp_providers[i] == msg.sender) {
                index = i;
                found = true;
                break;
            }
        }

        if (!found) {
            lp_providers.push(msg.sender);
            index = lp_providers.length - 1;
        }


        // transfer tokens from the user
        token.transferFrom(msg.sender, address(this), requiredTokens);

        // update reserves, k, and everyone's liquidity
        liquidityUpdate();
    }


    // Function removeLiquidity: Removes liquidity given the desired amount of ETH to remove.
    // You can change the inputs, or the scope of your function, as needed.
    function removeLiquidity(uint amountETH, uint max_exchange_rate, uint min_exchange_rate) public payable {
        // ensure provider is an lp and has enough liquidity
        uint index;
        bool found = false;

        for (uint i = 0; i < lp_providers.length; i++) {
            if (lp_providers[i] == msg.sender) {
                index = i;
                found = true;
                break;
            }
        }
        require(found, 'You are not an LP');
        require(lps[msg.sender] * eth_reserves >= amountETH * lp_denominator, 'You are trying to withdraw more liquidity than you have provided');

        uint eth_token_rate = eth_reserves * lp_denominator / token_reserves;
        require (eth_token_rate <= max_exchange_rate && eth_token_rate >= min_exchange_rate, 'Slippage parameters exceeded.');

        // ensure suficient liquidity remains
        uint amountTokens = amountETH * token_reserves / eth_reserves;
        require(sufficientLiquidity(amountETH, amountTokens), 'You would empty the pool');

        // send them tokens and eth
        token.transfer(msg.sender, amountTokens);
        payable(msg.sender).transfer(amountETH);

        // update liquidity portions, reserves, and k
        liquidityUpdate();
    }

    // Function removeAllLiquidity: Removes all liquidity that msg.sender is entitled to withdraw
    // You can change the inputs, or the scope of your function, as needed.
    function removeAllLiquidity(uint max_exchange_rate, uint min_exchange_rate) external payable {
        // ensure they are an LP
        uint index;
        bool found = false;

        for (uint i = 0; i < lp_providers.length; i++) {
            if (lp_providers[i] == msg.sender) {
                index = i;
                found = true;
                break;
            }
        }
        require(found, 'You are not an LP');

        uint eth_token_rate = eth_reserves * lp_denominator / token_reserves;
        require (eth_token_rate <= max_exchange_rate && eth_token_rate >= min_exchange_rate, 'Slippage parameters exceeded.');

        // figure out how much they can remove
        uint amountETH = lps[msg.sender] * eth_reserves / lp_denominator;
        uint amountTokens = lps[msg.sender] * token_reserves / lp_denominator;

        // ensure suficient liquidity remains
        require(sufficientLiquidity(amountETH, amountTokens), 'You would empty the pool');

        // transfer these amounts
        token.transfer(msg.sender, amountTokens);
        payable(msg.sender).transfer(amountETH);

        // update all other liquidity portions and remove the sender
        liquidityUpdate();
    }
    /***  Define additional functions for liquidity fees here as needed ***/

    // updates liquidity proportions after liquidity is added or removed
    function liquidityUpdate() private {
        uint old_eth_reserves = eth_reserves;
        uint index;

        eth_reserves = address(this).balance;
        token_reserves = token.balanceOf(address(this));
        k = eth_reserves * token_reserves;

        // check to see if liquidity was added or removed
        bool add = eth_reserves > old_eth_reserves ? true : false;
        uint change = add ? eth_reserves - old_eth_reserves : old_eth_reserves - eth_reserves;

        // ensure there was no underflow
        require (change <= old_eth_reserves || change <= eth_reserves, 'Underflow occurred');

        for (uint i = 0; i < lp_providers.length; i++) {
            address lp = lp_providers[i];
            if (lp == msg.sender) { // find where the sender is but don't do anything with them yet
                index = i;
            } else { // update everyone else's proportion of liquidity
                lps[lp] = lps[lp] * old_eth_reserves / eth_reserves;
            }
        }

        // otherwise, update the sender's liquidity portion based on whether liquidity was added or removed
        if (add) {
            lps[msg.sender] = (lps[msg.sender] * old_eth_reserves / lp_denominator + change) * lp_denominator / eth_reserves;
        } else {
            lps[msg.sender] = (lps[msg.sender] * old_eth_reserves / lp_denominator - change) * lp_denominator / eth_reserves;
        }

        if (lps[msg.sender] == 0) {
            removeLP(index);
        }
    }

    // check to see if the amount of ETH and tokens you're removing leave sufficient liquidity in the pool
    function sufficientLiquidity(uint amountETH, uint amountTokens) private view returns (bool) {
        return (amountETH + 1 <= eth_reserves && amountTokens + 1 <= token_reserves);
    }

    /* ========================= Swap Functions =========================  */ 

    // Function swapTokensForETH: Swaps your token with ETH
    // You can change the inputs, or the scope of your function, as needed.
    function swapTokensForETH(uint amountTokens, uint max_exchange_rate) external payable {
        require(token.balanceOf(msg.sender) >= amountTokens, 'Your token balance is insufficient');

        uint amountETH = amountTokens * eth_reserves / token_reserves;
        require(sufficientLiquidity(amountETH, 0), 'You would empty the liquidity pool of ETH');

        uint token_eth_rate = token_reserves * lp_denominator / eth_reserves;
        require (token_eth_rate <= max_exchange_rate, 'Out of slippage bounds.');

        // transfer tokens to us and ETH to them
        token.transferFrom(msg.sender, address(this), amountTokens);

        payable(msg.sender).transfer(amountETH* (swap_fee_denominator - swap_fee_numerator) / swap_fee_denominator);

        // update reserve balances
        swapUpdate();
    }



    // Function swapETHForTokens: Swaps ETH for your tokens
    // ETH is sent to contract as msg.value
    // You can change the inputs, or the scope of your function, as needed.
    function swapETHForTokens(uint max_exchange_rate) external payable {
        require(msg.sender.balance >= msg.value, 'Your ETH balance is insufficient');

        uint amountTokens = msg.value * token_reserves / eth_reserves;
        require(sufficientLiquidity(0, amountTokens), 'You would empty the liquidity pool of tokens');

        uint eth_token_rate = eth_reserves * lp_denominator / token_reserves;
        require (eth_token_rate <= max_exchange_rate, 'Out of slippage bounds.');

        // transfer tokens to them
        token.transfer(msg.sender, amountTokens * (swap_fee_denominator - swap_fee_numerator) / swap_fee_denominator);

        // update reserve balances
        swapUpdate();
    }

    function swapUpdate() private {
        eth_reserves = address(this).balance;
        token_reserves = token.balanceOf(address(this));
    }   
}


