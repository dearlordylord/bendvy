# #41 transaction runner — early guard inspection

Backend admission is not granted. This inspection precedes diagnostic-only
freezing and concerns the current unverified transaction runner, not earlier
bundle receipts or correctness of the new transaction implementation.

Inspected `experiments/public-bundles/production-candidate/transactions/run.py`
and its inherited `experiments/public-bundles/tool-pins.py` on master after
`a1c586b5`. Prospective variant anchors/counts/intended byte hashes, complete
stage membership and unique planned CommandLogs labels are already present.

Before execution admission:

- Use owned-descendant supervision for tool-library discovery. The inherited
  `subprocess.run(ldd, timeout=5)` does not establish the required descendant
  boundary. Preserve that historical helper; qualify a task-local replacement.
- Pin configuration presence/absence prospectively at stage, root and effective
  working directory. Hashing the known installed check.json alone is insufficient.
- Include the runtime assets actually consumed by the selected emission path;
  do not infer C/JS provenance from Bend source hashes alone.
- Diagnostic freezing must assert the exact intended expression/type/line/caret
  span, rather than merely several diagnostic substrings. Recorded diagnostics
  are a development control, not application or Native acceptance.

The worker has these findings before launch. It must submit a fresh frozen
preflight after repair; no new dependency, policy or law approval is implied.
