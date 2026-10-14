# Final review: native TU mechanism probe

**Verdict: PASS for the bounded ABI/link-feasibility probe.** This is not a full generated-program backend split, performance result, or runtime acceptance claim.

Reviewed commit `21855b5af28fd9c40046d4eae8fb93ee43713cf1` (35 owned paths) in `native-tu-mechanism`. The committed bindings are:

- `FREEZE.json`: `5ca63bb85a113e013ac3d9e9c3cf7656214ce2f24d12d09027b9d81cb3dc7148`
- `plan.json`: `eca6afcbcce8c9f18c37af196ba9d819309d0fdf900a7f61d04e9c1c8560f5ed`
- `evidence/run01/receipt.json`: `3989f077143d532f86e167035d08f8ee52b788f3aac19d89ee2a986c7fc47239`
- `ORACLE.json`: `724d948b5176bbdd08f6d2968985ed8072ec4c188e5d51a7990737d69bb4e41c`
- `expected.stdout`: `73d8ec19058d56d758109047137bb791ba4cd585404e1479cbcd83fd1bd6885f`

The source-only verifier passed. I independently joined the frozen plan and receipt, all eight argv/exit/status rows, raw streams, expected output, and six object/executable hashes. Every compile/link/execute step reports exit 0; stderr and compile/link stdout are empty. Both executables produced the same 27-byte stdout, matching the pinned oracle. The split objects each have a single runtime owner for `runtime_state` and `wl_tab`; direct and indirect cross-TU calls preserve the ordered 46-argument `preserve_none` signature and `musttail` form. The monolithic counterpart includes the same three bodies once. The split and monolithic builds both use `-fno-lto`.

The guarded launch holds one nonblocking exclusive lock over freshness checks, all eight commands, artifact guards, raw logs, and terminal receipt. Pins were exact at review, outputs were present and matched the receipt, and no guard failures were recorded.

Residual scope: this demonstrates the small AArch64 ABI/link shape only. It does not partition the actual generated program or establish safety for its full global state, GPU embedding, or helper closure. Separate sparse-fixture failures remain outside this probe’s claims.
