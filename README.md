From Zero to Foundry
--------------------

This repo contains a very basic Foundry set up ready to be your first steps into the toolchain. Follow the instructions below to run your first Foundry tests!

Note that the instructions are for linux systems. However, they should be reproducible on Windows using the [Windows Subsystem for Linux](https://docs.microsoft.com/en-us/windows/wsl/).

Installing Foundry
------------------

As described in the [Foundry repository](https://github.com/foundry-rs/foundry/), you only need to execute the following command:

```
curl -L https://foundry.paradigm.xyz | bash
```

Then, run `foundryup` in a new terminal session or after reloading your `PATH`.

For other installation methods, go to the [Foundry repository](https://github.com/foundry-rs/foundry/).

Repository contents
-------------------

This repository contains two main files, `token.sol` and `exclusiveToken.sol`, both in the [`src`](./src/) folder.
It also contains the corresponding tests `token.t.sol` and `exclusiveToken.t.sol` in the [`test`](./test/) folder.

### token.sol

The file contains a simple token with two functionalities: mint and transfer tokens. Thus, it makes sense to test that the transfer function works correctly. I.e., that if a user `A` transfers `x` amount of tokens to a user `B`, `A`'s balance is decreased by `x` and `B`'s balance is increased by `x`. This is the property that `token.t.sol` tests.


### exclusiveToken.sol

The file `exclusiveToken.sol` contains a modified version of `token.sol`. This contract can only mint tokens to addresses that hold some [alUSD](https://etherscan.io/token/0xbc6da0fe9ad5f3b0d58160288917aa56653660e9). Hence, what the test `exclusiveToken.t.sol` checks is precisely this, that accounts with zero balance in the alUSD contract cannot be minted to, and the opposite for addresses that hold alUSD.

However, note that we don't have the source code of the alUSD token, and much less a file or something similar with the current state of alUSD on the blockchain. Thus, we must use Foundry's extra capabilities to excercise the test correctly.

Using Foundry
-------------

We will use foundry for three different stages:

- Building the project (i.e. compiling the files),
- Running `token` tests (i.e. with no external context),
- Running `exclusiveTonen` tests (i.e. taking into account data from mainnet).

### Building the project

To build the project we only need to run this command in any folder of the repo:

```
forge build
```

As simple as that.

### Running `token`  tests

Since we have two tests with different needs, `token.t.sol` and `exclusiveToken.t.sol`, we will tell Foundry which test to exercise. This is done with the optios `--match` or `--match-path`, which match a sting against the name of the test (executing all matches) or against the path of a file.

Since we only want to exercise the test contained in `token.t.sol`, we can do so by running the following command:

```
forge test -vvvv --match-path test/token.t.sol
```

The `-vvvv` option just indicates the verbosity of the output. It can go from being absent (verbosity 1) to five `v`'s (verbosity 5). For more details see [here](https://book.getfoundry.sh/forge/tests#logs-and-traces).

### Running `exclusiveToken` tests

Running this test is the same as in the previous case, but with an extra argument, `--fork-url`. We need to provide to `--fork-url` the URL of a RPC client such as Alchemy or Infura.

```
forge test -vvvv --fork-url <your_url> --match-path test/exclusiveToken.t.sol
```

If you wish to exercise all tests at once, you just have to omit the `--match` argument. But don't forget to add the `--fork-url`! Otherwise the test in `exclusiveToken.t.sol` won't be exercised.

-------


And this is it! If you followed the instructions you just ran your first Foundry tests!

To go from here we recommend reading the [Foundry book](https://book.getfoundry.sh). Have fun building!





---------------
**DISCLAIMER**: The files in this repository are toy examples only meant to illustrate how Foundry works. They are not to be used in real-world cases. Runtime Verification will not be held accountable should you do otherwise.
