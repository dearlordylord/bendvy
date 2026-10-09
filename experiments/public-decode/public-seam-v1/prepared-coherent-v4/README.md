# Complete consumer packet v4

PREPARED_NO_CHILD. Frozen72 generic15 and frozen6c deferred8 subjects, independent
full models, raw expected bytes and 30-second emission / 5-second JS limits remain
unchanged. V1–v3 files remain untouched and BLOCKED_UNLAUNCHED.

Fresh plans pin shared Runner fix d729ffe2 / SHA-256
ee166e354afca23d1b2ac87424b97925172d79a7cb693285a36ac188c7ef0714.
A completed child result now survives logs.record or postguard failure. Both owned
collectors retain its exact exit/failure in the pre-appended command row and copy
published raw-log joins before guards. Partial stderr is reported as incomplete;
a successfully published stdout join remains in the failure receipt.

check-partial-publication.py uses actual Runner with mocked execute_result (zero
children), actual collector row capture/guard and ReceiptBoundary. It writes stdout,
partially creates stderr then raises the publication sentinel. Both collectors
retain returned exit17/failure, stdout hash and INCOMPLETE receipt with failed guard.
controls.json also records strict whole DTO, historical raw preservation, stale-pyc/
cached-module and stdlib-before-helper admission controls.

manifest.json lists exact four plan digests and argv. JS: one emission30 then run5;
C: one emission30. CPU5 shared lock, no retries/cap raises. C emits authorize no
Native runtime. Independent review/admission precedes execution. Private environment
stays local. No public promotion, performance or #46 closure claim.
