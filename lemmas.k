requires "foundry.md"

module KONTROL-LEMMAS

// Your lemmas go here
// Not sure what to do next? Try checking the documentation for writing lemmas: https://docs.runtimeverification.com/kontrol/guides/advancing-proofs/kevm-lemmas


/* These are needed for the `mulWad` example but got upstreamed:

rule bool2Word ( X ) => 1 requires X         [simplification]
rule bool2Word ( X ) => 0 requires notBool X [simplification]
*/


/* This one is needed for the XOR example:
rule A xorInt A => 0 [simplification]
*/

endmodule
