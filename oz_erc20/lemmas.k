requires "foundry.md"

module KONTROL-LEMMAS
    imports FOUNDRY
    imports INT-SYMBOLIC
    imports MAP-SYMBOLIC
    imports SET-SYMBOLIC

    //
    // Equality of +Bytes
    //

   rule { B:Bytes #Equals B1:Bytes +Bytes B2:Bytes } =>
           { #range ( B, 0, lengthBytes(B1) ) #Equals B1 } #And
           { #range ( B, lengthBytes(B1), lengthBytes(B) -Int lengthBytes(B1) ) #Equals B2 }
      requires lengthBytes(B1) <=Int lengthBytes(B)
      [simplification(60), concrete(B, B1)]

    rule { B1:Bytes +Bytes B2:Bytes #Equals B } =>
           { #range ( B, 0, lengthBytes(B1) ) #Equals B1 } #And
           { #range ( B, lengthBytes(B1), lengthBytes(B) -Int lengthBytes(B1) ) #Equals B2 }
      requires lengthBytes(B1) <=Int lengthBytes(B)
      [simplification(60), concrete(B, B1)]

    rule { B:Bytes #Equals #buf( N, X:Int ) +Bytes B2:Bytes } =>
           { X #Equals #asWord ( #range ( B, 0, N ) ) } #And
           { #range ( B, N, lengthBytes(B) -Int N ) #Equals B2 }
      requires N <=Int lengthBytes(B)
      [simplification(60), concrete(B, N)]

    rule { #buf( N, X:Int ) +Bytes B2:Bytes #Equals B } =>
           { X #Equals #asWord ( #range ( B, 0, N ) ) } #And
           { #range ( B, N, lengthBytes(B) -Int N ) #Equals B2 }
      requires N <=Int lengthBytes(B)
      [simplification(60), concrete(B, N)]


    //
    // keccak assumptions: these assumptions are not sound in principle, but are
    // required for verification - they should ideally be collected at the end of execution
    //

    rule 0 <=Int keccak( _ )             => true [simplification, smt-lemma]
    rule         keccak( _ ) <Int pow256 => true [simplification, smt-lemma]

    // keccak does not equal a concrete value
    rule [keccak-eq-conc-false]: keccak(_A)  ==Int _B => false [symbolic(_A), concrete(_B), simplification(30), comm]
    rule [keccak-neq-conc-true]: keccak(_A) =/=Int _B => true  [symbolic(_A), concrete(_B), simplification(30), comm]
    rule [keccak-eq-conc-false-ml-lr]: { keccak(A) #Equals B } => { true #Equals keccak(A) ==Int B } [symbolic(A), concrete(B), simplification]
    rule [keccak-eq-conc-false-ml-rl]: { B #Equals keccak(A) } => { true #Equals keccak(A) ==Int B } [symbolic(A), concrete(B), simplification]

    // keccak is injective
    rule [keccak-inj]: keccak(A) ==Int keccak(B) => A ==K B [simplification]
    rule [keccak-inj-ml]: { keccak(A) #Equals keccak(B) } => { true #Equals A ==K B } [simplification]

    // chop of negative keccak
    rule chop (0 -Int keccak(BA)) => pow256 -Int keccak(BA)
       [simplification]

    // keccak cannot equal a number outside of its range
    rule { X #Equals keccak (_) } => #Bottom
      requires X <Int 0 orBool X >=Int pow256
      [concrete(X), simplification]


    // Lookup simplifications
    rule #lookup (M:Map [ K1 <- #lookup(M, K1)], K2) => #lookup (M, K2) [simplification]

    rule #lookup (M:Map [ K1 <- #lookup (M, K1)] [ K2 <- #lookup (M, K2)], K3) => #lookup (M, K3) [simplification]

    // Map simplifications
    rule M:Map [K1 <- _V1] [K2 <- V2] [K1 <-V3] => M:Map [K2 <- V2] [K1 <- V3] [simplification]


    rule X |Int #asWord ( Y ) => 
        #asWord ( #buf ( 32 -Int lengthBytes(Y), X >>Int ( 8 *Int lengthBytes(Y) ) ) +Bytes #buf ( lengthBytes(Y), #asWord (Y) ) )
    requires #rangeUInt(256, X) andBool lengthBytes(Y) <=Int 32 
    andBool X modInt ( 2 ^Int ( 8 *Int ( 32 -Int lengthBytes(Y) ) ) ) ==Int 0
    [simplification(60), concrete(X), preserves-definedness]

    // List simplifications
    rule E1 in ListItem(E2) L => E1 ==K E2 orBool E1 in L [simplification]
    rule X in .List => false [simplification]

endmodule