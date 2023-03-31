Foundry First Steps
--------------------

This repo contains a very basic Foundry set up ready to be your first steps into the toolchain.
Follow the instructions below to run your first Foundry tests!
By the end, you also will be able to verify your foundry property tests using [KEVM!](https://github.com/runtimeverification/evm-semantics).

Note that the instructions are for linux systems.
However, they should be reproducible on Windows using the [Windows Subsystem for Linux](https://docs.microsoft.com/en-us/windows/wsl/).

Installing Foundry
------------------

As described in the [Foundry repository](https://github.com/foundry-rs/foundry/), you only need to execute the following command:

```sh
curl -L https://foundry.paradigm.xyz | bash
```

Then, run `foundryup` in a new terminal session or after reloading your `PATH`.

For other installation methods, go to the [Foundry repository](https://github.com/foundry-rs/foundry/).

Installing KEVM
---------------

The simplest way to install KEVM is via the [`kup` tool](https://github.com/runtimeverification/kup).
Install `kup`:

```sh
bash <(curl https://kframework.org/install)
```

Then install K, `kore-rpc`, and KEVM using `kup` (first time will take a while):

```sh
kup install k
kup install kore-rpc
kup install kevm --version anvacaru/set-symbolic
```

For more detailed instructions about building KEVM from source, see [the KEVM repository](https://github.com/runtimeverification/evm-semantics).

Repository contents
-------------------

This repository contains simple Solidity contracts and Foundry property tests associated with them.
See the [`src`](./src) directory for the Solidity source code.
See the [`test`](./test) directory for the Foundry property tests.

### Contracts

In the [`src`](./src) subdirectory, you will find two tokens:

- `ERC20.sol`: The file contains the base ERC20 token Solidity contract from [Open Zeppelin](https://github.com/OpenZeppelin/openzeppelin-contracts/tree/master/contracts/token/ERC20).
- `KEVMCheats.sol`: The [KEVMCheats.sol](./src/utils/KEVMCheats.sol) contract interface contains functions which are only available to KEVM.
                    Running a test that contains these function calls with `forge` will result in a failure with the `invalid data` error.

### Tests

In the [`test`](./test) subdirectory, you will find tests of varying difficulty:

- `ERC20.t.sol` - tests for the ERC20 functions.

Property Testing Using Foundry
------------------------------

We will use foundry for:

- Building the project (i.e. compiling the files), and
- Running the property tests on randomized inputs.

### Building the project

To build the project we only need to run this command in any folder of the repo:

```sh
forge build
```

As simple as that.

### Running tests with Foundry

Most of these tests are designed to work with symbolic execution and will most likely fail when used with foundry.
The main differences are that:

1. We use [KEVMCheats.sol](./src/utils/KEVMCheats.sol), which are not implemented in `forge`.
2. We use `vm.assume` to set a precondition, instead of filtering input values.
As example, the following would reject all inputs in forge:

```solidity
    function testExample(address alice, uint256 amount) public {
        ERC20 erc20 = new ERC20("Token Name", "TKN");
        vm.assume(erc20.balanceOf(alice) == amount);
        assertEq(erc20.balanceOf(alice), amount);
```


Since we have several different tests with different needs, we will tell Foundry which test to exercise.
This is done with the options `--match` or `--match-path`, which match a string against the name of the test (executing all matches) or against the path of a file.
If we only want to exercise the test "testNameAndSymbol" in `ERC20.t.sol`, we can do so by running the following command:

```sh
forge test -vvvv --match-test testNameAndSymbol
```

The `-vvvv` option just indicates the verbosity of the output.
It can go from being absent (verbosity 1) to five `v`'s (verbosity 5).
For more details see [here](https://book.getfoundry.sh/forge/tests#logs-and-traces).

If you wish to exercise all tests at once, you just have to omit the `--match-path` argument.

Property Verification using KEVM
--------------------------------

With KEVM installed, you'll also have the option to do property verification!
This is a big step up in assurance from property testing, but is more computationally expensive, and often requires manual intervention.
Be advised that these tests usually have a longer execution time (~30 mins to an hour), depending on the machine.

### Build KEVM Definition

First, we need to build the KEVM definition for this Foundry property test suite:

```sh
kevm foundry-kompile
```

When you are working, you may need to rebuild the definition in various ways.
For example:

- If you change the Solidity code, you need to re-run `forge build`, and then run the above `foundry-kompile` command again with the option `--regen` added.
- If you add/modify K lemmas in `lemmas.k`, you need to rerun the above `foundry-kompile` command with the `--rekompile` option added.

Once you have kompiled the definition, you can now run proofs!
For example, to run some simple proofs from [`test/ERC20.t.sol`](test/ERC20.t.sol), you could do:

```sh
kevm foundry-prove --test ERC20Test.testNameAndSymbol --test ERC20Test.testTotalSupply -j2
```

Notice you can use `--test ContractName.testName` to filter tests to run, and can use `-jN` to run listed proofs in parallel!

You can visualize the result of proofs using the following command:

```sh
kevm foundry-view-kcfg ERC20Test.testName
```

This launches an interactive visualizer where you can click on individual nodes and edges in the generated KCFG (K Control Flow Graph) to inspect them.
There is also static visualization you can use:

```sh
kevm foundry-show ERC20Test.testName
```

This command takes extra parameters if needed:

- `--no-minimize`: Do not omit details in node and edge output.
- `--node NODE_ID`: Output the given node fully as well as the KCFG (repeats allowed).
- `--node-delta NODE_ID_1,NODE_ID_2`: Output the differences between the two nodes as well as the full KCFG (repeats allowed).

If you have a node with a term that should be simplified, you need to add a lemma in [lemmas.k](./lemmas.k).
You recompile using the command above and the `--rekompile` flag.
Next call `simplify-node` on the node, and check that it simplifies.

For example, if there is a branch that should not happen:
You add a lemma, and call `rekompile`, then check that it simplifies the bad branch to `bottom` on using `simplify-node`.
After you're satisfied it won't branch again, you call `remove-node` on the node prior to the branch.
Then recall `prove` but without `--reinit` flag, to resume execution.

-------

And this is it! If you followed the instructions you just ran your first Foundry tests!

To go from here we recommend reading the [Foundry book](https://book.getfoundry.sh).
Have fun building!

---------------

**DISCLAIMER**: The files in this repository are toy examples only meant to illustrate how Foundry works.
They are not to be used in real-world cases.
Runtime Verification will not be held accountable should you do otherwise.
