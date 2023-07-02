# Decently Safe DeFi 🔑

Decently Safe DeFi is a wargame to learn offensive security of DeFi smart contracts. The challenges are modelled after the excellent [Damn Vulnerable DeFi](https://www.damnvulnerabledefi.xyz/), but instead of being based on theoretical vulnerabilities, the challenges are modelled after near-misses in the real world. By removing subtle security controls or reversing minor misconfigurations, we can learn about the critical vulnerabilities that was avoided in a protocol. 

Feel free to [submit PRs](https://github.com/AshiqAmien/decently-safe-defi) to include your challenges made from real-life near misses, or, [send me a DM](twitter.com/AshiqAmien) if you're part of a protocol and would like some challenges made! If you're just looking to get into the challenges, head to the [instructions](https://decentlysafedefi.xyz/tag/instructions/) to get started!

#### Acknowledgements

Big thanks to [Tincho](https://twitter.com/tinchoabbate) who created the [first version of this game](https://github.com/tinchoabbate/damn-vulnerable-defi/tree/v2.0.0) and to all the fellows behind the [Foundry Framework](https://github.com/gakonst/foundry/graphs/contributors). Further thanks to [Nicolás García](https://github.com/nicolasgarcia214), who ported Damn Vulnerable Defi to Foundry.


## Instructions 

Before you get started with the challenges, you'll need to do some setup:

- Install Foundry



    &nbsp; First run the command below to get foundryup, the Foundry toolchain installer:
    ```bash
    $ curl -L "https://foundry.paradigm.xyz" | bash
    ```     
    &nbsp; Then, in a new terminal session or after reloading your PATH, run it to get the latest forge and cast binaries:
    ```bash
    $ foundryup
    ```

- Clone the repo and install the dependencies
 
    ```bash 
    $ git clone "https://github.com/AshiqAmien/decently-safe-defi"
    $ cd decently-safe-defi
    $ forge install
    ```

- Code your solutions in the provided `[NAME_OF_THE_LEVEL].t.sol` files (inside each level's folder in the test folder)

- Run your exploit for a challenge

    ```bash
    forge test --match-contract [ChallengeName] -vvvv
    ```
    &nbsp;or
    ```bash
    ./run.sh [CHALLENGE_NUMBER]
    ```
If the challenge is executed successfully, you've passed! 

## Tips, rules and extras 
Before you begin, there's some things you should know: 

• In all challenges you must use the account called attacker. In Forge, you can use the [cheat code](https://github.com/gakonst/foundry/tree/master/forge#cheat-codes) _prank()_ or _startPrank()_. Avoid impersonating anyone else, or using any private keys that might be around on the contract! 

• In some cases, you may need to code and deploy custom smart contracts.

• Testing with the verbosity flags (i.e. using _-vvvv_) may help with debugging any issues you run into.

• Since the challenges are protocol based, it's recommended to diff the given contracts to the instances on mainnet for possible clues on solving the challenge.



