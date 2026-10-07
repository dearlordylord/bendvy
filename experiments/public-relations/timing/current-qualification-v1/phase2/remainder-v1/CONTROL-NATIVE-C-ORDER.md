# Current control Native generated order

Read-only inspection of the actual qualified emitted C. No backend replay or timing claim. Generated C is excluded from the portable archive; hashes below bind the local review.

## nonpower

C SHA256 `827bb7bfdacc71b86e7bb97c5bca5ecd47f38e2227fd35eaaee18bf98c0e339e`.

Actual switch/call sites:

- Line 166518: `WL_JMP(FID____FORCE_WALK);`.
- Line 170667: `WL_JMP(FID____FORCE_WALK);`.
- Line 171932: `WL_JMP(FID____APPLICATION_RUN_0);`.
- Line 172048: `WL_JMP(FID____APPLICATION_RUN_1);`.
- Line 174141: `WL_CASE(FID_MAIN_C3327)`.
- Line 174160: `WL_CASE(FID_MAIN_C3328)`.
- Line 174184: `WL_CASE(FID_MAIN_K3329)`.
- Line 174222: `WL_JMP(FID____SETUP_RUN_0);`.
- Line 174233: `WL_CASE(FID_MAIN_K3330)`.
- Line 174333: `WL_JMP(FID____SETUP_RUN_1);`.
- Line 174338: `WL_CASE(FID_MAIN_K3331)`.
- Line 174485: `WL_CASE(FID_MAIN_C3332)`.
- Line 174593: `WL_CASE(FID_MAIN_C3333)`.
- Line 174749: `WL_CASE(FID_MAIN_K3334)`.
- Line 174782: `WL_CASE(FID_MAIN_K3335)`.
- Line 174812: `WL_CASE(FID_MAIN_C3336)`.
- Line 174843: `WL_CASE(FID_MAIN_C3337)`.
- Line 174866: `WL_JMP(FID____SERIALIZE_ENCODE);`.
- Line 174871: `WL_CASE(FID_MAIN_K3338)`.
- Line 174914: `WL_CASE(FID_______TRACE_BOUNDARY_BEGIN)`.
- Line 174926: `WL_CASE(FID_______TRACE_BOUNDARY_COMPLETE)`.

Main continuations bind Begin before materializing the complete trace; the force-result continuation receives the completion discriminator and three U32 summary registers before constructing the completion foreign-effect closure. Only its following IO continuation calls serialize.encode. The refusal branch prints the incomplete marker rather than constructing normal completion.

## sparse

C SHA256 `b7ac3b953d96b1ae616ac577d1d1cd8baf9d45e97f5deb3c064a0a4cad023d87`.

Actual switch/call sites:

- Line 166478: `WL_JMP(FID____FORCE_WALK);`.
- Line 170627: `WL_JMP(FID____FORCE_WALK);`.
- Line 171892: `WL_JMP(FID____APPLICATION_RUN_0);`.
- Line 172008: `WL_JMP(FID____APPLICATION_RUN_1);`.
- Line 174101: `WL_CASE(FID_MAIN_C3327)`.
- Line 174120: `WL_CASE(FID_MAIN_C3328)`.
- Line 174144: `WL_CASE(FID_MAIN_K3329)`.
- Line 174182: `WL_JMP(FID_SPARSE_SETUP_RUN_0);`.
- Line 174193: `WL_CASE(FID_MAIN_K3330)`.
- Line 174293: `WL_JMP(FID_SPARSE_SETUP_RUN_1);`.
- Line 174298: `WL_CASE(FID_MAIN_K3331)`.
- Line 174445: `WL_CASE(FID_MAIN_C3332)`.
- Line 174553: `WL_CASE(FID_MAIN_C3333)`.
- Line 174709: `WL_CASE(FID_MAIN_K3334)`.
- Line 174742: `WL_CASE(FID_MAIN_K3335)`.
- Line 174772: `WL_CASE(FID_MAIN_C3336)`.
- Line 174803: `WL_CASE(FID_MAIN_C3337)`.
- Line 174826: `WL_JMP(FID____SERIALIZE_ENCODE);`.
- Line 174831: `WL_CASE(FID_MAIN_K3338)`.
- Line 174874: `WL_CASE(FID_______TRACE_BOUNDARY_BEGIN)`.
- Line 174886: `WL_CASE(FID_______TRACE_BOUNDARY_COMPLETE)`.

Main continuations bind Begin before materializing the complete trace; the force-result continuation receives the completion discriminator and three U32 summary registers before constructing the completion foreign-effect closure. Only its following IO continuation calls serialize.encode. The refusal branch prints the incomplete marker rather than constructing normal completion.

## empty

C SHA256 `f0f4360638ba219cf49547e1746787c58cc4210a145ac69d27ef74550f618cc7`.

Actual switch/call sites:

- Line 72680: `WL_JMP(FID____FORCE_WALK);`.
- Line 73963: `WL_JMP(FID____FORCE_WALK);`.
- Line 74118: `WL_JMP(FID_EMPTY_APPLICATION_RUN_0);`.
- Line 74226: `WL_JMP(FID_EMPTY_APPLICATION_RUN_1);`.
- Line 74671: `WL_CASE(FID_MAIN_C1527)`.
- Line 74690: `WL_CASE(FID_MAIN_C1528)`.
- Line 74714: `WL_CASE(FID_MAIN_K1529)`.
- Line 75002: `WL_CASE(FID_MAIN_C1530)`.
- Line 75110: `WL_CASE(FID_MAIN_C1531)`.
- Line 75266: `WL_CASE(FID_MAIN_K1532)`.
- Line 75299: `WL_CASE(FID_MAIN_K1533)`.
- Line 75329: `WL_CASE(FID_MAIN_C1534)`.
- Line 75360: `WL_CASE(FID_MAIN_C1535)`.
- Line 75383: `WL_JMP(FID____SERIALIZE_ENCODE);`.
- Line 75388: `WL_CASE(FID_MAIN_K1536)`.
- Line 75431: `WL_CASE(FID_______TRACE_BOUNDARY_BEGIN)`.
- Line 75443: `WL_CASE(FID_______TRACE_BOUNDARY_COMPLETE)`.

Main continuations bind Begin before materializing the complete trace; the force-result continuation receives the completion discriminator and three U32 summary registers before constructing the completion foreign-effect closure. Only its following IO continuation calls serialize.encode. The refusal branch prints the incomplete marker rather than constructing normal completion.

The common runtime IO loop executes io_exec before installing its returned item. Setup is performed before the Begin bind. Full actual output and Begin/complete summaries provide independent consumer checks of each finite control; universal timing/forcing proofs are not claimed.

Actual full-force entry and traversal sites (not serialization substitutes):

- nonpower line 166191: `WL_CASE(FID____FORCE_WALK)`.
- nonpower line 171774: `WL_CASE(FID_TRACE)`.
- nonpower line 174777: `WL_JMP(FID____FORCE_FORCE);`.
- sparse line 166151: `WL_CASE(FID____FORCE_WALK)`.
- sparse line 171734: `WL_CASE(FID_TRACE)`.
- sparse line 174737: `WL_JMP(FID____FORCE_FORCE);`.
- empty line 72353: `WL_CASE(FID____FORCE_WALK)`.
- empty line 73968: `WL_CASE(FID_TRACE)`.
- empty line 75294: `WL_JMP(FID____FORCE_FORCE);`.
