# Shared runner migration

The runnable Python recipes now import `scripts/task_runner.py` directly and use
`execute_result` for raw stream dictionaries. Their prospective source pins bind
the shared runner. Existing receipts and capsule indexes remain historical evidence
of the original source bytes and executions; this migration does not renew their
acceptance. Migrated recipes require fresh execution and fresh receipts.

The historical `run-v3.py` at this directory was syntactically invalid (unterminated
string literal at line 39) and has been retired from the runnable source set.
Its exact original bytes are available from parent commit
`018005c636928e19b583b2de3757c264c814784b` at
`experiments/public-relations/promotion-stage/application/next-version/v1/run-v3.py`
using `git show`. Their SHA-256 is
`7203bb880bd3bd3c93cd8ef93087e333b0e4d01bbe35ef022904c51c8944c04a`.
Before retirement, the same bytes were preserved outside Git at
`/tmp/bendvy-pr66-retired-python/7203bb880bd3bd3c93cd8ef93087e333b0e4d01bbe35ef022904c51c8944c04a/run-v3.py`.
The temporary archive is local; the parent Git object is the durable source.
The separate valid `foreign/run-v3.py` remains a migrated recipe.
