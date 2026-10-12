# Boxed World-clock omission v2 final review

## Verdict

**Bounded PASS for the Native-only, both-schema physical `World.clock` omission control.** The V2 candidate's complete runtime output equals the independent source-derived countermodel and rejects the complete qualified normal oracle. This supports retaining the finite counterfactual evidence for the two mapped payload stores. It does not qualify JavaScript, a general Native/compiler property, universal clock or owner behavior, affine ownership, adoption, performance, or issue #54 closure.

## Packet and source joins

- Reviewed commit `291eaa355191875a96e60dd8f8596e885b379200` (`Retain both-schema boxed clock full counter control`), whose 28 direct packet paths are joined by `DELIVERY.json`. The 55,419,314-byte `EVIDENCE.zip` has SHA-256 `5a7e38c862f22579b02de33a54ec36086475540bcd464db7ad6766d90b940ecd`, 38 unique members, and every declared member matched its recorded bytes and SHA-256.
- The 53-file source inventory matched the live files byte-for-byte. All seven build/consumer/final guards report `unchanged: true`; the frozen plan is `afc61db5d3c66ccd68e3a6ba18a6bae5ab3a03019e798ab51367d3525371a1fd`, with 155 current pins and six resource-root inventories.
- The candidate C is exactly the qualified normal C after replacing the old clock store in both mapped functions: `FID_WORLD_OBSERVER_JOINED_0_K12793` (Workshop) and `FID_WORLD_OBSERVER_JOINED_1_K12643` (Garden), each at `WorldCID32` physical slot 12. The archived qualified normal C is 21,470,090 bytes/SHA `da2ccfc70e99519923f407eabc8b1fc6a30caccf92747f3c32af7c3b4792b1f0`; the V2 candidate is 21,470,084 bytes/SHA `a26935fb4b8ce58553aa8e5dfbd9b8270464c6ce793ab88388269cd9f4ef776e`, and static replacement of the two old lines reproduces it exactly.
- `NOMINAL-MAPPING.json` and the source call graph bind Workshop to `WORLD_0_K12902 → JOINED_0_K12793` and Garden to `WORLD_1_K12865 → JOINED_1_K12643`, with 11 physical checkpoints per schema. `world-observer.bend` renders the clock into the physical text while constructing the returned `World`; `consumer.bend` passes `Dump.world` through `snapshot_join` and carries the returned World onward. Thus the two C substitutions preserve the pre-reset text while changing the carried boxed clock payload.

## Failure correction and runtime evidence

- The nested V1 archive is preserved byte-for-byte (SHA `d29094bb47f4d7b9c4d0af6ad9c26875d6f208a1a68aea4ba64622960177d11a`). Its one Garden-only mutation remains an honest failure: build and consumer exited 0, but the 212,569-byte output (SHA `993390ee1977e47748ed03d206a69a6da7d1552708903337f426b7d0b910cdaa`) did not equal the 217,304-byte countermodel (SHA `94c84156df10cd969db592bc36b200ad14893986bfa2407aa2b58a46f1cdd21a`), first differing at byte 5,335. V1 is not used as V2 success evidence.
- V2 build and consumer both exited 0 under the pinned standard `-O3`, CPU 3, 120-second build and 5-second consumer limits; build and consumer stderr are empty. The complete 217,304-byte `consumer.stdout` has SHA `94c84156df10cd969db592bc36b200ad14893986bfa2407aa2b58a46f1cdd21a` and independently equals the decompressed archived counter gzip (4,673 bytes, SHA `82998ff62c31dfdac1f6971a45fd63da8c69675d997b88d718097db95a0cca6d`). The decoded output contains 22 physical snapshots, four schedule observations, and 20 check tuples.
- The complete normal output was independently read from the nested qualified archive: 207,834 bytes/SHA `14565a3635124edb3ba8ef53b76e2030c3b3698e5d7c4a31989bc3ca9fb54a2d`. Direct comparison rejects it at byte 5,335; the candidate context carries `clock=14` where normal carries `clock=47`. The explicit `ORACLE-COMPARISON.json`/`COMPARISON.json` join records this rejection rather than relying on the generic `subject=normal` collector.
- The independent model source is pinned separately (`1b01b4325d7f722021dc73178511543c5cebc9f78acf13b8389a8bcf859ec099`), declares no runtime stdout inputs, and applies the same two source-mapped substitutions to the two-schema consumer. Its source checks retain 14 query kinds, nine checks, 11 checkpoints per schema, and the complete counter digest without fitting to the Native output.

## Limits

This is a finite Native control for two generated `World` payload stores and the preserved consumer fixture. It carries no JavaScript-mutant result, universal observer/compiler claim, performance result, ownership qualification, or adoption credit. The pre-execution `RUNTIME-FREEZE` metadata remains a freeze record; the post-run receipt and raw output provide the terminal result.
