# Canonical queue/stream controls: source-only oracle

Producer a3f3e799aed4ff745c86c75a768d9f74b5273ba2 supplies the selected actual
`controls-v1/main.bend`, against unchanged queue candidate 0d2da72c5. The frozen
closure has ten Bend modules; all original import identities and copies are
pinned alongside Base and both IO.print effect bodies. No candidate output,
generated artifact or backend execution was consulted.

The model derives Queue behavior from the source's separate expired-prefix and
capacity-prefix passes, including normalize, exact cached event size and raw
batch count. Its independent Ev reference uses ordinary batch lists, prefix
expiry and a separate whole-batch size eviction loop, with no Queue/cache/fuel
machinery. The resulting complete observations are compared, not inferred from
an expected checksum.

## Three actual trim cases

- Nonmonotonic: input 10:[1],2:[2],9:[3], boundary 3/capacity 2/drop 0. Expiry stops
  at oldest tick 10. Capacity then removes only that batch, leaving ticks 2/9,
  size 2/batchCount 2/drop 10 and values [2,3]. Expiry is not restarted after capacity
  removed tick 10. Actual front is both remaining batches, back empty.
- Empty prefix: ticks 2/1/3 have empty payloads, followed by 7:[70], boundary 3/
  capacity 5. All three empty prefix batches are removed, drop becomes 3, and
  tick 7 remains with size 1/batchCount 1 and values [70]. Cached batchCount fuel
  permits removing raw empty batches even though event size stays 1.
- Whole multi-event: ticks 4:[1,2],9:[3,4,5],7:[], boundary 0/capacity 3/drop 1.
  Capacity drops whole tick 4, leaving tick 9 and raw empty tick 7. Size is3 but
  batchCount is2; drop 4 and values [3,4,5]. The empty retained batch is serialized.

Every case prints its full input/boundary/capacity/initial drop, complete Ev
reference batches/size/count/drop, and actual Queue front/back/counts/drop plus
full Q.read(cursor 0). Actual queue cached counts and payload lengths are checked.

## Reached stream lifecycle

`St.trimmed` lowers actual raw batches 20:[0→1],21:[Initial 2], drop 5, positions
[(7,3,2),(9,5,4)], frameStart 12. Its snapshot contains both complete batches;
cached event size/batchCount are 2/2. read7 sees both values with lagged=true
(max(cursor 3,registered 2)<drop 5), while read9 sees both with lagged=false.

`St.initial` at tick 30 replaces the queue with Initial 9, retaining those positions,
drop 5 and frameStart 12. Cached size/count become1/1. `St.skip(7,31)` and
`St.complete(7,32,false)` return the same state/readings. Successful completion
sets only reader 7's existing cursor to32, preserving registeredAt 2 and reader 9.
read7 is then empty/nonlagged while read9 still sees Initial 9/nonlagged.
Disposal removes only position 7. A subsequent pure observe of missing id7 uses
fallback cursor 0/registeredAt 35, so it sees Initial 9 with lagged=false; this
observation does not activate a position or resurrect an affine reader capability.

The lifecycle source prints every St snapshot batch/value/position/drop/frame
field, cached size/count/drop and both complete readings. Its stream_cache
projection does not expose internal front/back; the three direct Queue cases do.
The oracle follows this exact source projection and invents no additional fields.
These positions and ids are trusted Data setup for lower-level metadata controls,
not evidence of World-bound reader authority or foreign-world refusal. There is
no World, actual registration or ordinary scheduled callback in this small entry;
normal ordinary capacity and prior schedule evidence remain separate.

## Complete wire and checks

The run string has nine lines from the three trim cases followed by six lifecycle
lines (seed, initial, skip, complete-false, complete-true, disposed). No source
fragment ends with LF; the explicit joins supply 14 internal LFs. IO.print adds
one terminal LF. Output is raw text with all lists in Base List.show comma-space
format; no pure String quoting or extra terminal blank line is present.

Run `python3 model.py` for all source pins, source-callsite applicability, two
independent trim models, complete queue/cache/lag/skip/failure/completion/disposal
invariants and exact raw/gzip/hash reproduction. The counter/source models and
all previously sealed normal oracles are unchanged. These controls are finite
runtime expectations, not universal proofs; execution is established only when
root's unchanged collector compares complete actual JS/Native bytes.
