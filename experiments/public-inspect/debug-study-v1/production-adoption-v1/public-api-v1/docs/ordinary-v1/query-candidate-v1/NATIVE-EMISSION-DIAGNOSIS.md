# Native emission diagnosis — development only

The exact pinned installed ELF compiler timed out during C emission at30s on CPU5. No partial C artifact exists; no Clang/runtime child ran. Streams are empty and source/tool/42-import/47-constructor guards unchanged. The same full entry emitted1,188,208-byte JS successfully. Child elapsed/RSS were not recorded; post-run loadavg is not during-child evidence. Contention versus codegen expansion remains unresolved.

Reference-source mechanism (not established as the installed binary implementation): main.ts:358–364 evaluates the full JS/C compiler result before writeFileSync, explaining why absent C alone cannot locate a stalled pass. comp.ts:2750–2792 C compile_book repeatedly emits reachable definitions until ownership/hot/static facts stabilize. fun_of:1174–1195 computes live argument and return layouts from dependent types. js_lib:3193–3206 performs a different reachable-definition emission loop without that C fixed point. The fixture has three nominal storage/owner specializations, each retaining all fifteen phases and failure owners; higher-order retained-owner continuations can contribute additional layout/closure specialization. No measured attribution establishes which expression dominates.

The installed adjacent comp.ts is absent. Do not equate the reference TS with the pinned ELF based on directory naming. No justified source-sharing change has been identified: common DTO/renderers already share source, while distinct Plain/Transient/Constructed authority must remain. No category/phase/error observation can be removed as a compilation shortcut.

Next action: recover the exact binary-to-source build binding if already available, then instrument one separately admitted diagnostic C emit with elapsed/CPU/RSS capture and unchanged full entry/cap. This distinguishes CPU starvation from costly codegen more directly than an unchanged blind replay. No replay/cap increase performed here.

Reference read hashes:
- main.ts: d1a3e026f5014f8daec3614df8e39cf261e3fbc47769eb0916fd891bc18703c9
- comp.ts: 32fb66e09f608ce9e4b173384bcfeec453db8c5bc96650e26ad861bef815a8d9
