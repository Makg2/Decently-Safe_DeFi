# Challenge #4 - honeypot

Rumor has it that a thief is looking mix their stolen coins, and plans to deposit a large amount of WETH to one of Abracadabra's cauldrons. After looking at the Cauldron V4 contracts again, it seems there's a way we can setup a fresh cauldron to trap this thief. 

Objective: As the attacker starting with 100 WETH, set up a cauldron in such a way that it traps the incoming 400 WETH deposit. The attacker should be able to withdraw 500 WETH after the deposit is through, stealing back the thief's coins.

[See the contracts](https://github.com/AshiqAmien/decently-safe-defi/tree/master/src/Contracts/honeypot)
<br/>
[Complete the challenge](https://github.com/AshiqAmien/decently-safe-defi/blob/master/test/Levels/honeypot/Honeypot.t.sol)
