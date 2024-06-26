# Highlights

This repository contains a suite of property tests tailored for the OpenZeppelin ERC20 Solidity smart contract.
We want to demonstrate the usability and value of Kontrol for property testing and verification of smart contracts.

It also includes a very basic Foundry set up ready to be your first steps into the toolchain.

For kontrol documentation and more examples check [docs.runtimeverification.com/kontrol/](https://docs.runtimeverification.com/kontrol/).  

Follow the instructions below to run your first property tests using [KONTROL!](https://github.com/runtimeverification/kontrol).
However, they should be reproducible on Windows using the [Windows Subsystem for Linux](https://docs.microsoft.com/en-us/windows/wsl/).


<span style="color:red">Note that the instructions are for linux systems.</span>


# Table of Contents
- [Highlights](#highlights)
- [Machine Setup](#machine-setup)
  - [Installing Foundry](#installing-foundry)
  - [Installing KONTROL](#installing-kontrol)
  - [Repository contents](#repository-contents)
- [Test Breakdown](#test-breakdown)
  - [Contracts](#contracts)
  - [Tests](#tests)
- [Property Testing Using Foundry ( Forge )](#property-testing-using-foundry--forge-)
  - [Build with Forge](#build-with-forge)
  - [Run Tests with Foundry](#run-tests-with-foundry)
- [Property Verification using KEVM ( Kontrol )](#property-verification-using-kevm--kontrol-)
  - [Build with kontrol](#build-with-kontrol)
  - [Run the Proofs](#run-the-proofs)
- [Insights by Kontrol](#insights-by-kontrol)
  - [Kontrol List](#kontrol-list)
  - [Kontrol View](#kontrol-view)
  
# Machine Setup

Installing Foundry
------------------

As described in the [Foundry repository](https://github.com/foundry-rs/foundry/), you only need to execute the following command:

```sh
curl -L https://foundry.paradigm.xyz | bash
```

Then, run `foundryup` in a new terminal session or after reloading your `PATH`.

For other installation methods, go to the [Foundry repository](https://github.com/foundry-rs/foundry/).

Installing KONTROL
------------------

The simplest way to install kontrol is via the [`kup` tool](https://github.com/runtimeverification/kup).
Install `kup`:

```sh
bash <(curl https://kframework.org/install)
```

Then install `kontrol` using `kup` (first time will take a while):

```sh
kup install kontrol
```

For more detailed instructions about building Kontrol from source, see [the Kontrol repository](https://github.com/runtimeverification/kontrol).

Repository contents
-------------------

This repository contains the OpenZeppelin ERC20 (took from the latest commit at that time, `1a60b061d5bb809c3d7e4ee915c77a00b1eca95d`) and the associated property tests.
- The [`src`](./src) directory contains the Solidity source code.
- The [`test`](./test) directory contains the Foundry property tests.
- The [`exclude`](./exclude) file contains proofs that are expected to fail.
- The [`run-kontrol.sh`](./run-kontrol.sh) file contains examples of Kontrol commands that you can use.
- The [`erc20.sh`](./erc20.sh) file contains a script that runs all the ERC20 proofs and times them.

# Test Breakdown

Contracts
---------

In the [`src`](./src) subdirectory, you will find multiple files:

- `ERC20.sol`: The file contains the base ERC20 token Solidity contract from [Open Zeppelin](https://github.com/OpenZeppelin/openzeppelin-contracts/tree/master/contracts/token/ERC20).
- `IERC20Metadata.sol`, `IERC20.sol` and `Context.sol` are helper files of the ERC20 contract, imported from the same repository.
- `token.sol`: The file contains a simple token with two functionalities: mint and transfer tokens.
  Thus, it makes sense to test that the transfer function works correctly.
  I.e., that if a user `A` transfers `x` amount of tokens to a user `B`, `A`'s balance is decreased by `x` and `B`'s balance is increased by `x`.
  This is the property that `token.t.sol` tests.
- `exclusiveToken.sol`: The file `exclusiveToken.sol` contains a modified version of `token.sol`.
  This contract can only mint tokens to addresses that hold some [alUSD](https://etherscan.io/token/0xbc6da0fe9ad5f3b0d58160288917aa56653660e9).
  Hence, what the test `exclusiveToken.t.sol` checks is precisely this, that accounts with zero balance in the alUSD contract cannot be minted to, and the opposite for addresses that hold alUSD.
  However, note that we don't have the source code of the alUSD token, and much less a file or something similar with the current state of alUSD on the blockchain.
  Thus, we must use Foundry's extra capabilities to excercise the test correctly.

Tests
-----

In the [`test`](./test) subdirectory, you will find tests of varying difficulty:

- `ERC20.t.sol` - tests for the ERC20 functions.
- `simple.t.sol`: Standalone tests of arithmetic functions, no dependencies on the `src` directory.
- `token.t.sol`: Tests of `token.sol`.
- `exclusiveToken.t.sol`: Tests of `exclusiveToken.t.sol`.

# Property Testing Using Foundry ( Forge )

We will use foundry for:

- Building the project (i.e. compiling the files), and
- Running the property tests on randomized inputs.

Build with Forge
----------------

To build the project we only need to run this command in any folder of the repo:

```sh
forge build
```

As simple as that.

Run Tests with Foundry
----------------------

Since we have several different tests with different needs, we will tell Foundry which test to exercise.
This is done with the options `--match` or `--match-path`, which match a string against the name of the test (executing all matches) or against the path of a file.
If we only want to exercise the test contained in `token.t.sol`, we can do so by running the following command:

The `-vvvv` option just indicates the verbosity of the output.
It can go from being absent (verbosity 1) to five `v`'s (verbosity 5).
For more details see [here](https://book.getfoundry.sh/forge/tests#logs-and-traces).

We can also run the `exclusiveToken.t.sol` test.
Running this test is the same as in the previous case, but the test requires an extra
argument, `--fork-url`, to provide the URL of an RPC client such as Alchemy or Infura.

```sh
forge test -vvvv --fork-url <your_url> --match-path test/exclusiveToken.t.sol
```

If you wish to exercise all tests at once, you just have to omit the `--match-path` argument.
But don't forget to add the `--fork-url`! Otherwise the test in `exclusiveToken.t.sol` won't be exercised.

For ERC20, most of these tests are designed to work with symbolic execution and will most likely fail when used with Foundry.
The main differences are that:

1. We use [KontrolCheats.sol](https://github.com/runtimeverification/kontrol-cheatcodes/tree/master), which are not implemented in `forge`.
2. We use `vm.assume` to set a precondition or an assumption, instead of filtering input values.
As example, the following would reject all inputs in forge:

```solidity
    function testExample(address alice, uint256 amount) public {
        ERC20 erc20 = new ERC20("Token Name", "TKN");
        vm.assume(amount > 0 );
        vm.assume(erc20.balanceOf(alice) == amount);
        assertEq(erc20.balanceOf(alice), amount);
    }
```

# Property Verification using KEVM ( Kontrol )

<span style="color:red">Marking here for rewrite - This could be more detailed on highlighting benefits of Kontrol over Forge -- please advise</span>  
With kontrol installed, you'll also have the option to do property verification!
This is a big step up in assurance from property testing, but is more computationally expensive, and often requires manual intervention. 
Be advised that these tests usually have a longer execution time (from a few mins up to an hour and a half), depending on the machine and the complexity of the test.

Build with kontrol
------------------

First, we need to build a K definition for this Foundry property test suite:

```sh
kontrol build --require lemmas.k --module-import ERC20:DEMO-LEMMAS
```

When you are working, you may need to rebuild the definition in various ways.
For example:

- If you change the Solidity code, you need to re-run the above `build` command with the option `--regen` added.
- If you add/modify K lemmas in `lemmas.k`, you need to rerun the above `build` command with the `--rekompile` option added.


Run the Proofs
--------------
Once you have kompiled the definition, you can now run proofs!  
For example, to run some simple proofs from [`test/simple.t.sol`](test/simple.t.sol), you could do:

```sh
kontrol prove --match-test Examples.test_assert_bool_failing --match-test Examples.test_assert_bool_passing -j2
```

Notice you can use `--match-test ContractName.testName` to filter tests to run, and can use `-jN` where `N` is number of threads to run listed proofs in parallel!   
We suggest to not exceed 2x the number of cores in your machine. If you're machine is limited on RAM resources it's suggested to reduce parallel threads equal to Number of Cores.  
CPU information is avaulable is viewable on Linux by running the command `lscpu` in the terminal.  

For example:
  ```sh
  HOST:~/../kontrol-demo$ lscpu
  Architecture:            x86_64
    CPU op-mode(s):        32-bit, 64-bit
    Address sizes:         39 bits physical, 48 bits virtual
    Byte Order:            Little Endian
  CPU(s):                  8
    On-line CPU(s) list:   0-7
  Vendor ID:               GenuineIntel
    Model name:            11th Gen Intel(R) Core(TM) i7-1165G7 @ 2.80GHz
      CPU family:          6
      Model:               140
      Thread(s) per core:  2
      Core(s) per socket:  4
      Socket(s):           1
  ```   
# Insights by Kontrol

Kontrol List
------------
You can list the status of the proofs with `kontrol list`:

```sh
HOST:~/../kontrol-demo$ kontrol list
APRProof: test%Examples.test_assert_bool_failing(bool):0
    status: ProofStatus.FAILED
    admitted: False
    nodes: 7
    pending: 1
    failing: 1
    vacuous: 0
    stuck: 0
    terminal: 2
    refuted: 0
    bounded: 0
    execution time: 45s
Subproofs: 0

APRProof: test%Examples.test_assert_bool_passing(bool):0
    status: ProofStatus.PASSED
    admitted: False
    nodes: 7
    pending: 0
    failing: 0
    vacuous: 0
    stuck: 0
    terminal: 3
    refuted: 0
    bounded: 0
    execution time: 41s
Subproofs: 0
```

Kontrol View
------------

You can visualize the result of proofs with `kontrol view-kcfg`  
Lets view `Examples.test_assert_bool_failing`
```sh
kontrol view-kcfg Examples.test_assert_bool_failing
```

This launches an interactive visualizer where you can click on individual nodes and edges in the generated KCFG (K Control Flow Graph) to inspect them.

![Kontrol View KCFG Demo](media/KontrolViewKCFGDemo.png)

There is also static visualization you can use:
```sh
kontrol show Examples.test_assert_bool_failing
```

![Kontrol View KCFG Static Demo](media/KontrolViewKCFGStaticDemo.png)

`Kontrol view` command takes extra parameters if needed:

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

And that is it! If you followed the instructions you just ran your first Foundry tests!

To go from here we recommend checking out [Kontrol Homepage](https://kontrol.runtimeverification.com)  
And reading the [Foundry book](https://book.getfoundry.sh).  

🎉 Have fun building! 🎉

---------------

<span style="color:red">**DISCLAIMER**: The files in this repository are toy examples only meant to illustrate how Foundry works.
They are not to be used in real-world cases.
Runtime Verification will not be held accountable should you do otherwise.</span>
