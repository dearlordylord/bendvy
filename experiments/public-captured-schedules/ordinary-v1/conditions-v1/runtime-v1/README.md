# Stateful-condition pair

Both stock JS and Native -O3 executions match the complete independent 13,895-byte
oracle (SHA256 `301432709cabf3215e21a4f4d81bfc906c90181a2c709bb7026a6f619e356478`).
Five commands exit zero; all 17 guards are unchanged. Sources remain 5d28b7887,
oracle 1e0ccfb32. The source README's pending status records the pre-run freeze.

`actual-attempt01/manifest.json` retains 508 path/hash bindings in 467 compressed
objects plus 22 explicitly external installed ELF identities. Full source, oracle,
plans, generated code, outputs and receipts are retained. Every object was checked
against its raw hash/length; the complete independent model reproduced its output
from an isolated directory. No extra backend or timing run was performed.

This qualifies the first actual ordinary stateful-condition composition. New-wrapper
preflight controls and final joined #51 review remain; the generic NoValue arm is
not claimed reached by ordinary built-in conditions.
