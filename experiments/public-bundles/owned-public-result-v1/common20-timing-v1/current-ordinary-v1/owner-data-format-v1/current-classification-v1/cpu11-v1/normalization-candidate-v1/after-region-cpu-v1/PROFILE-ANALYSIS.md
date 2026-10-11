# Region CPU attribution

Both independent captures validate the complete 72,442-byte scale-4 output. Before has 484 samples (461 generated-artifact leaves); after has 431 (414). Schema-fragments has 48/129 before and 41/107 after leaf/inclusive samples. bind_declared has 128/106 inclusive, bind_requirements 110/90, and check_one_bare 17/7. These are unweighted sample counts from separate captures; inclusive counts overlap. They do not establish a causal speedup, allocation reduction, or instrumented timer comparison. No single leaf dominates.

The after analyzer reuses the accepted traversal/counting implementation, changing only actual02 paths and mapping relocated core/source definitions to the qualified private closure. Every generated frame mapping retains its exact artifact line; identified definitions retain source hash and line. The four-call candidate remains private. The original selector failure launched no child and is retained separately.
