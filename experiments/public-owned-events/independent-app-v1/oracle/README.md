# Independently derived complete oracle

Author: independent oracle agent, separate from application/core/observer authors.
Source freeze: application `5f1dbf025`, copied event modules from `bd57fde16`;
all manifest entries verified byte for byte before derivation. `bindings.json`
records contract, host allocator and primary Base effect bindings as well.
No previous application/oracle bodies, runtime outputs or generated backend source
were consulted; no Bend execution was performed. This is a finite source-derived
expectation, neither backend observation nor mathematical proof.

Run `python3 derive.py` to regenerate the complete 13-snapshot `expected.stdout`,
its deterministic gzip copy and human-readable state trace. The model has its own
World/runtime transition state and explicit owner conservation assertions.

A fresh host process/realm allocates namespace 1. Three registrations prepend
World metadata in reverse registration order, retain registry cursors zero, and
leave World clock zero. World contains one false live leaf; no entities, commands
or component mutations occur. Arrays are ordered binary trees, with four leaves
formatted as `[[a,b],[c,d]]`; list printers terminate in literal `[]` and prepend
no opening bracket. Every snapshot includes the full literal observer fields.

The failed publish increments runtime tick but preserves Log.next and returns
manifest 22. First fast read activates position `(1,0,2)` and retains the mutated
Args despite semantic failure. Retry sees manifest 11 again and commits cursor 4.
The first frame sets frameStart 4/boundary 0 and retires nothing. Publishing C is
tick 5; fast consumes C at tick 6; slow lazily activates at tick 6 and consumes
A then C at tick 7. Seen history prepends each projection, so C appears before A.
The second frame sets boundary 4 and retires A only; the third sets boundary 7
and retires C. Publishing D at tick 8 gets ID 3. Shutdown returns D exactly once,
clears IDs/batches, preserves Log.next=4 and all reader/runtime metadata.

The terminal String already ends in LF; the single IO.print adds another LF.
Expected raw output is 9,107 bytes, SHA-256
`505ae41497691176adaa44a7d460a0049aa5acf400c4d804b3a761ee1c711bc8`.
Deterministic gzip is 725 bytes, SHA-256
`1fc9cbc0101e058f8226fabacbacb7cafe936d1559162f3fd81c71c010115fef`.

## Source closure 02 addendum

The first prepared plan stopped before any child because the original source
manifest omitted six transitive imports. `source-closure02.json` adds exact pins
for component, lifecycle, column, owner-handoff, indexed-lifecycle and
string-equality. Each current body is byte-identical at `1bf6b8595`, `bd57fde16`
and `5f1dbf025`. This is a metadata repair with unchanged source semantics;
oracle `272ed4548` remains applicable without changing expected bytes. The
original bindings are preserved. No runtime outputs were consulted.
