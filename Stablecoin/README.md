## Cyfrin Course Inspired Stablecoin

1. Relative Stability: Anchored or Pegged -> $1.00
   1. Chainlink Price Feed
   2. Set function to exchange ETH and BTC -> $$$
2. Stability Mechanism (Minting): Algorithmic (Decentralised) 
   1. People can only mint the stablecoin with enough collateral
3. Collateral: Exogenous (Crypto) 
   1. wETH 
   2. wBTC


### Fuzzing Notes

Foundry Invariants are stateful fuzzing
Foundry Fuzzing is stateless fuzzing


What are the invariants?

1. The total supply of DSC should be less than the total value of collateral
2. Getter view functions should never revert <- evergreen invariant