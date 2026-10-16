# Independent family-publisher oracle, formatting successor

This successor preserves the original source-derived model and corrects one
nested-Array rendering omission. The source fixture constructs each Crates
payload as an outer `Array<Array<U32>>` node whose two leaves contain the inner
`Array<U32>` values. The observer recursively renders the outer array and its
`array_leaf` adds `L(...)` around each nested array. Accordingly the rendered
shape is `N(L(inner_left),L(inner_right))`; the inner arrays themselves render
as `N(L(x),L(y))`.

The predecessor was compared with a retained failed JS run. That output exposed
the first difference at the Crates nested-array shape; the expected successor
was then derived from the pinned fixture, observer, and Base Array constructors.
The full failed output is retained as diagnostic provenance in
`SOURCE-BASIS.json`; it supplied no expected model values. The successor's
selftest asserts the source-derived nested constructor and compares every byte
against the saved expected output.

The oracle covers Workshop and Garden, seven snapshots per schema, complete
world/resource/component/event/registry observations, recovery receipts, and
`IO.print`'s final newline. It does not qualify the full feature or any runtime.
Run `python3 derive.py` to regenerate, or `python3 derive.py --selftest` to
validate source pins and retained bytes. The source root defaults to the frozen
producer worktree and can be overridden with `--source-root`.
