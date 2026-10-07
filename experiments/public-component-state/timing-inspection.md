# #47 timer semantic and generated-code inspection

Stage: `.artifacts/state-timing-stage-v1/stage.json`.
Semantic receipt: `.artifacts/state-timing-semantics-v1/receipt.json`,
`PASS_COMPLETE_APPLICATION_EQUIVALENCE`, 32 guarded commands, CPU5.
Receipt SHA256: `2f3a28f98a733ab470decfad2273d6a544d00e4eb6c032409fbf8aba278560bd`.
Portable receipt/stage and exact stdout/stderr logs:
`timing/evidence-semantics-v1/`. These qualify equivalence, not speed or quietness.

All three TS/JS/Native scales retain complete 62/124/248 rows, matching exact full
output bytes and FNV digest. Original actual TS62 and pure-driver checker pass.
The timer checker's foreign-effect refusal is reached at the intended seam;
JS/native emission, approved Clang19 build and execution pass at unchanged caps.
No source/tool/daily-cache/config drift was accepted.

The generated state-1.js main at line205 constructs IO.bind with timing.begin and
its continuation. Only that continuation invokes repeat(1). Repeat at line226
invokes driver.main afresh inside the effect continuation, captures every result,
and repeats only from the completed capture callback. Driver main at line268
calls World.factory/create for schemaA and then schemaB through the owned Factory.
There is no global precomputed application result or reused World/registration.

Native C main at line205930 constructs the Begin+continuation seam. Only the
post-Begin main continuation dispatches Repeat. Repeat at line205730 dispatches
DriverMain every positive step; its capture completion continuation at line205843
re-enters Repeat. End appears only in the final continuation. The C timer at
line207696 starts CLOCK_MONOTONIC in Begin; capture materializes/hashes all UTF8
bytes and LF while active; End records time before stdout flush/free. JS uses the
corresponding captured Buffer bytes/hrtime effect seam. This is inspection and
finite sequencing evidence, not universal IO refinement or an ECS proof.

Entire emitted JS programs across scales are identical after replacing only the
single main repetition constant with COUNT. Normalized SHA256:
`c679e3490716b76a521f21be051e73dbbde532323149082b3ad33950391a2cee`.
Entire C programs are identical after replacing only the two same-count literals
in the post-Begin main continuation. Normalized SHA256:
`3edbfc215e3c01f9a10102b58ae97802aa26084dfc7101c9a3cc0f6859171d84`.
Unnormalized generated artifacts/executable hashes remain bound in the receipt.
Thus the inspected sequencing/fresh driver dispatch applies to all three scales;
no other source differences were erased by normalization.

Comparative timing still requires independent review and integrator-established
quiet-window context. No ratios, new statistical threshold or performance verdict
are inferred from this semantic pipeline. Exact stage-v1 sources remain frozen.
