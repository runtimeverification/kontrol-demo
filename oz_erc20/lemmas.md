Kontrol Lemmas
==============

Lemmas are K rewrite rules that enhance the reasoning power of Kontrol. For more information on lemmas, please consult [this section](https://docs.runtimeverification.com/kontrol/guides/advancing-proofs) of the Kontrol documentation.

This file contains the lemmas required to run the proofs included in the [GLDToken.t.sol](./test/kontrol/proofs/GLDToken.t.sol) file. Some of these lemmas are general enough to likely be incorporated into future versions of Kontrol, while others are specific to the challenges presented by the proofs.

Similarly to other files such as [`cheatcodes.md`](https://github.com/runtimeverification/kontrol/blob/master/src/kontrol/kdist/cheatcodes.md), we use the idiomatic way of programming in Kontrol, which is [literate programming](https://en.wikipedia.org/wiki/Literate_programming), allowing for better documentation of the code.

## Imports

For writing the lemmas, we use the [`foundry.md`](https://github.com/runtimeverification/kontrol/blob/master/src/kontrol/kdist/foundry.md) file. This file contains and imports all of the definitions from KEVM and Kontrol on top of which we write the lemmas.

```k
requires "foundry.md"

module KONTROL-LEMMAS
    imports FOUNDRY
    imports INT-SYMBOLIC
    imports MAP-SYMBOLIC
    imports SET-SYMBOLIC
```

## Bytes Equality

These lemmas ensure that concatenations and buffer operations within the [Bytes](https://github.com/runtimeverification/k/blob/master/k-distribution/include/kframework/builtin/domains.md#byte-arrays) sort follow consistent equality principles.

```k
    //
    // Equality of +Bytes
    //

   // Equality of Concatenated Bytes (Direct)
   rule { B:Bytes #Equals B1:Bytes +Bytes B2:Bytes } =>
           { #range ( B, 0, lengthBytes(B1) ) #Equals B1 } #And
           { #range ( B, lengthBytes(B1), lengthBytes(B) -Int lengthBytes(B1) ) #Equals B2 }
      requires lengthBytes(B1) <=Int lengthBytes(B)
      [simplification(60), concrete(B, B1)]

    // Equality of Concatenated Bytes (Reverse)
    rule { B1:Bytes +Bytes B2:Bytes #Equals B } =>
           { #range ( B, 0, lengthBytes(B1) ) #Equals B1 } #And
           { #range ( B, lengthBytes(B1), lengthBytes(B) -Int lengthBytes(B1) ) #Equals B2 }
      requires lengthBytes(B1) <=Int lengthBytes(B)
      [simplification(60), concrete(B, B1)]

    // Equality with a Padded Integer (Direct)
    rule { B:Bytes #Equals #buf( N, X:Int ) +Bytes B2:Bytes } =>
           { X #Equals #asWord ( #range ( B, 0, N ) ) } #And
           { #range ( B, N, lengthBytes(B) -Int N ) #Equals B2 }
      requires N <=Int lengthBytes(B)
      [simplification(60), concrete(B, N)]

    // Equality with a Padded Integer (Reverse)
    rule { #buf( N, X:Int ) +Bytes B2:Bytes #Equals B } =>
           { X #Equals #asWord ( #range ( B, 0, N ) ) } #And
           { #range ( B, N, lengthBytes(B) -Int N ) #Equals B2 }
      requires N <=Int lengthBytes(B)
      [simplification(60), concrete(B, N)]
```

## Keccak assumptions

The provided K Lemmas define assumptions and properties related to the keccak hash function used in the verification of smart contracts within the symbolic execution context.

1. The result of the `keccak` function is always a non-negative integer, and it is always less than 2^256.

```k
    rule 0 <=Int keccak( _ )             => true [simplification, smt-lemma]
    rule         keccak( _ ) <Int pow256 => true [simplification, smt-lemma]
```

2. The result of the `keccak` function applied on a symbolic input does not equal any concrete value.

```k
    // keccak does not equal a concrete value
    rule [keccak-eq-conc-false]: keccak(_A)  ==Int _B => false [symbolic(_A), concrete(_B), simplification(30), comm]
    rule [keccak-neq-conc-true]: keccak(_A) =/=Int _B => true  [symbolic(_A), concrete(_B), simplification(30), comm]
```

In addition, equality involving keccak of a symbolic variable is reduced to a comparison that always results in `false` for concrete values.

```k
    rule [keccak-eq-conc-false-ml-lr]: { keccak(A) #Equals B } => { true #Equals keccak(A) ==Int B } [symbolic(A), concrete(B), simplification]
    rule [keccak-eq-conc-false-ml-rl]: { B #Equals keccak(A) } => { true #Equals keccak(A) ==Int B } [symbolic(A), concrete(B), simplification]
```

3. Injectivity of Keccak. If `keccak(A)` equals `keccak(B)`, then `A` must equal `B`.

In reality, cryptographic hash functions like `keccak` are not injective. They are designed to be collision-resistant, meaning it is computationally infeasible to find two different inputs that produce the same hash output, but not impossible.
The assumption of injectivity simplifies reasoning about the keccak function in formal verification, but it is not fundamentally true. It is used to aid in the verification process.

```k
    // keccak is injective
    rule [keccak-inj]: keccak(A) ==Int keccak(B) => A ==K B [simplification]
    rule [keccak-inj-ml]: { keccak(A) #Equals keccak(B) } => { true #Equals A ==K B } [simplification]
```

4. Negating keccak. Instead of allowing a negative value, the rule adjusts it within the valid range, ensuring the value remains non-negative.

```k
    // chop of negative keccak
    rule chop (0 -Int keccak(BA)) => pow256 -Int keccak(BA)
       [simplification]
```

5. Ensure that any value resulting from a `keccak` is within the valid range of 0 and 2^256 - 1.

```k
    // keccak cannot equal a number outside of its range
    rule { X #Equals keccak (_) } => #Bottom
      requires X <Int 0 orBool X >=Int pow256
      [concrete(X), simplification]
```


## Lookup simplifications

These lemmas are used to simplify [#lookups](https://github.com/runtimeverification/evm-semantics/blob/85b99bea64fa3d77a826ca51ca07a605d92d3dc4/kevm-pyk/src/kevm_pyk/kproj/evm-semantics/evm-types.md?plain=1#L404-L422) and [map updates](https://github.com/runtimeverification/k/blob/master/k-distribution/include/kframework/builtin/domains.md#map-update).

When you `lookup` a value for a key `K1` in a map `M` and then update the map `M` with the result, looking up another key `K2` can directly use the original map `M`. The intermediate update with the same key does not affect the lookup for other keys.

```k
    // Single Key Lookup Simplification
    rule #lookup (M:Map [ K1 <- #lookup (M, K1)], K2) => #lookup (M, K2) [simplification]
    // Multiple Key Lookup Simplification
    rule #lookup (M:Map [ K1 <- #lookup (M, K1)] [ K2 <- #lookup (M, K2)], K3) => #lookup (M, K3) [simplification]
```

## Map update simplifications.

When a map `M` is updated multiple times with values for the same key `K1`, we can directly apply the final update for key `K1`.

```k
    // Map simplifications
    rule M:Map [K1 <- _V1] [K2 <- V2] [K1 <-V3] => M:Map [K2 <- V2] [K1 <- V3] [simplification]

```

## Bitwise Or simplification.

This one is used to simplify operations that involve the function selector of a solidity Error type and the arguments provided for a `vm.expectRevert` cheatcode. Because some arguments are symbolic, the bitwise operations cannot be applied directly, requiring a simplification lemma like the one below.

```k
    rule X |Int #asWord ( Y ) => 
        #asWord ( #buf ( 32 -Int lengthBytes(Y), X >>Int ( 8 *Int lengthBytes(Y) ) ) +Bytes #buf ( lengthBytes(Y), #asWord (Y) ) )
    requires #rangeUInt(256, X) andBool lengthBytes(Y) <=Int 32 
    andBool X modInt ( 2 ^Int ( 8 *Int ( 32 -Int lengthBytes(Y) ) ) ) ==Int 0
    [simplification(60), concrete(X), preserves-definedness]
```

## List containment simplifications.

```k
    // List simplifications
    rule E1 in ListItem(E2) L => E1 ==K E2 orBool E1 in L [simplification]
    rule X in .List => false [simplification]

endmodule
```
