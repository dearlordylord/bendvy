# Owned tool pins final review

Independent source review and seven-test execution, 2026-10-07. Reviewed helper
`bd8b8207`, tests `809e185f`, and note `8516d42e`; no core/backend execution.

Admitted as a caller-configured infrastructure helper. The executor is mandatory
and injected, with no process fallback. Every library probe receives the explicit
five-second cap and pinned taskset/CPU/environment. Actual supervision correctness
remains the caller's separately reviewed responsibility. Binary/resource/library
bytes and membership are pinned; in-flight prerequisite drift and subsequent
verification drift refuse.

The ASLR repair resolves the earlier verification blocker: only terminal
hexadecimal load-address annotations on recognized stdout library, loader or
vdso-shaped lines are removed in the comparison view. Library names, paths,
other text, stderr, exit/failure and configuration remain compared. Raw snapshot
captures are retained unchanged. No overbroad address substitution across
arbitrary log text was identified.

Complete environment values are omitted from returned metadata in favor of a
digest; this does not sanitize child-generated raw logs or provide a low-entropy
secret guarantee. Structured probe refusals retain raw byte captures, including
earlier successful probes, without embedding child/environment content in the
exception message. Caller receipts must deliberately encode these bytes and
retain source/config/output guards.

`python3 scripts/test-owned-tool-pins.py` passed all seven tests, including the
actual reviewed merged executor, mandatory injection, raw invalid-UTF8/NUL
refusal evidence, environment changes, resource/byte drift and address-only
acceptance with changed path/warning/symbol rejection. These tests establish the
helper contract, not a universal supervision theorem, ECS acceptance or approval
to migrate historical evidence.
