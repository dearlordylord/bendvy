# Independent oracle for query/resource and owned-event composition

`derive.py` models the complete `composition-v1/main.bend` stdout from the
frozen source closure named in `SOURCE-BASIS.json`. The basis binds producer
commit `3c9533f0b4fa1796568bba1c5fe4dc6aac99647d`, its 60 source pins and the
installed Base/print implementations. The model has not consulted a backend
output or runtime receipt.

The trace has five snapshots for each nominal schema. It seeds component
values 10 and 20, registers the paired Value/Counter query with a Cargo writer,
commits `delta=1`, fails on the second row's old value 21 with `delta=10`,
retries with `delta=2`, then attempts the registered system against a separate
WorldIO-created foreign namespace. The failed attempt restores the component
values, lifecycle stamps and Counter, keeps the monotonic World clock at 6,
returns both staged payloads in row order, and leaves the successful query
cursor at 4. The retry commits payload IDs 3 and 4 and advances the cursor to
8; the foreign attempt is refused before the runner changes either world.

The serializer follows the source observer literally. Component rows end in a
semicolon, nonempty payload and log-row views end in `;[]`, and `List.show`
uses comma-space separators. `main.bend` appends the Garden section directly
after the last Workshop snapshot; `IO.print` contributes one final LF.

Regenerate or check the retained bytes and all pinned sources with:

```sh
python3 experiments/public-owned-events/composition-v1/oracle/derive.py
python3 experiments/public-owned-events/composition-v1/oracle/derive.py --selftest
```

This is the one-family composition bridge only. It does not establish
cross-family routing or complete issue #53 integration.
