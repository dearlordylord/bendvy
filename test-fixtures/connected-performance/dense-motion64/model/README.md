# Independent Dense64 expectations

The primary candidate uses the existing Indexed column factory for all three columns. `state.IndexedMetadata` models `src/ecs/indexed-lifecycle.bend`: separate added/changed scalar trees, capacity/depth growth, zero slots, and ordered exceptional entries. Payload capacity grows independently. `IndexedColumn` keeps the original payload and lifecycle semantics while rendering the complete `Indexed{owned(values=…;metadata={…})}` wire observed by the existing owner observer. No runtime output is used as expected data.

Reproduce the complete two-world candidate stream with:

```sh
python3 test-fixtures/connected-performance/dense-motion64/model/pilot_oracle.py
```

This first reproduces the qualified Plain stream (226,988 bytes, SHA256 `0375eec332d8509226d2eafd8b5d48ac592f38caf6f89c30f449b9599d1a2ebf`), then seals the Indexed successor: 261,774 bytes, SHA256 `be10d12450be4bc77e44fd8f13641c95f7eac6cd4a2e047d3b435405f11d24df`. The original generic Plain model remains available; `model.py Motion 64 64 --indexed` emits one complete Indexed canonical report.

All five physical checkpoints are modeled for namespace1 warmup and namespace2 sample: seed pending, seed applied, registered, final, and after logical read. Pending columns contain one absent payload leaf and zero metadata leaves, capacity1/depth0. Applied and final metadata arrays have capacity64/depth6; every zero hole is retained. Main has64 populated stamp slots, Aux22, Flag21. Exceptional lists are actually empty in this workload, not omitted. Factory Indexed owners stay ordinary; a prepared-state fallback is not accepted as a physical observation.

Finite Python checks cover independent payload/metadata capacities, zero stamps, normal growth and clearing without shrink, normal bound131072, exceptional IDs0/131073, exceptional replacement/list order and clearing, and all five checkpoint shapes. They are controls for this source-derived model, not universal proofs or additional runtime workload operations.

`expected-common.json` remains byte-identical: 5,448 scalar cells and fold709905077 per world, complete tuples as the oracle. The TS full stream is unchanged (89,186 bytes, SHA256 `3f7d09aae4ac1d6e3a6b431ec3e4c54fcd06cf15a5c21f77e76ec4ca5dc3156e`). The sealer checks both existing files without rewriting them. Clock values remain separate files. This64/64 method fixture does not qualify wider cases or comparative performance by itself.
