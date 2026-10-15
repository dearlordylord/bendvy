# Source-current opaque-classified oracle

This oracle models the frozen `source-current-v1` input at producer commit
`14b4fbb7debbdc4e511d26548749d737666afaae`. `SOURCE-BASIS.json` pins the
producer freeze and all 106 files in its declared source inventory. The
generator checks those bytes before it regenerates the result.

The model reuses the prior independent 14-checkpoint model as its starting
point. Its only semantic changes follow the current relation-failure reader
source:

- `relation-failure-runtime.bend` starts its own `nextReader` counter at 1.
  Successful registration returns a `K.Reader` carrying that value and
  advances the counter. The fixture registers one such reader per schema, so
  the exposed reader identity is 1 and `nextReader` becomes 2.
- The System registry identity remains 4. The ordinary adapter keeps that
  registry/system identity in its registration fields, while the current
  `FailureView` separately exposes the `K.Reader` identity.
- Running the reader passes `K.Reader.id` to both relation-domain activation
  and event-position activation. Those two physical references therefore use
  reader ID 1, rather than the unrelated System registry ID 4.

The two schemas, full 14-checkpoint timelines, component arrays and tag,
transient component provision, plain resource provision, relation graph,
reader/event observations, and complete physical owner fields are retained
from the prior source-derived model. Current relative imports also change the
serialized external module prefix: constructor names are resolved relative to
the current entry root. The entry returns the pair of reports as a Data result;
it does not call `IO.print`. The expected stream therefore keeps the existing
single final LF for CLI Data rendering. Base and the print effect files are
hash-pinned as formatting provenance, but this oracle does not execute them.

`derive.py.source --check` validates the source and prior-model pins, checks the
reader-ID relationships, regenerates the complete 201,468-byte output, and
compares its deterministic gzip bytes with `expected.stdout.gz`. It consumes
no candidate output, runtime receipt, compiler log, or generated artifact.

This is a finite source-derived oracle for this two-schema consumer. It does
not establish runtime acceptance, universal observer purity, full #56
coverage, or performance.
