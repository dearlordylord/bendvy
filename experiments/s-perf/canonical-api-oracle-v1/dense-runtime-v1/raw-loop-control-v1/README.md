# Independent raw-loop control oracle

Source metadata `1b8b34145` pins the current two candidate core bodies by exact
hash, not committed-core identity. Its four sequential actual IO worlds run the
same canonical three-entity seed and gameplay Main/Ledger body through public
`Q.run_handles`, then `Q.finished`. Source-only expected output is complete;
no subject output or backend execution was consulted.

Success returns[6,10,14], middle skip returns[6,14], empty returns[], and failure
returns raw successful prefix[6] after the second row has already written both
Main and Ledger. The third row is untouched on that failure. Raw Tx observations
preserve every opaque inverse/command owner, count them, print events, and render
the complete World before finish. Actual `T.begin` and untraced caps guarantee
trace Off; its enabled=False observation does not discard reached trace facts.

The failure's four inverse closures restore payloads, Ledger and old stamp values
in LIFO order. World clock remains7. Restoring stamps with actual `L.set` changes
main stamp-list order to[1,2,3]; this observable order is not normalized. Finished
failure returns output[], while success/skip/empty preserve their full outputs.
Four IO.print calls each add a newline to a source string already ending in one.

The local `state.py` is an exact copy of the generic independent Dense state
model. `model.py` adds actual namespace/Tx/undo behavior for these finite cases.
Run `python3 model.py`, `python3 model.py --self-test`, or the offline complete
source-pin/raw/gzip/isolated-model verifier `python3 verify.py.source`.

This is one focused current traversal control, not a new authority matrix,
arbitrary access-priority test, enabled-trace qualification, formal law or proof.
The older 13-field World mechanism fixtures are not relabeled as current controls.
Current reader/query rollback/trace and protected regression gates remain separate.
