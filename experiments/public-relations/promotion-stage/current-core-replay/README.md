# Affected current-core replay

This version replays the reviewed Query and lifetime subjects against the current live core, including staged `.c`/`.js` runtime assets. Original fixtures, literal/TypeScript oracles, precise negatives and intentional mutants are unchanged. Historical consumed runners and capsules remain immutable.

The new wrappers pin their own bytes, imported helper bytes, the current core and complete staged source inventories. Runtime products are guarded separately. CPU8 and the existing checker5/emission30/Clang120/runtime5 caps apply. Preflight review precedes execution; preflight is not semantic acceptance. No live relation modules are promoted by these runners.

Query development initially failed resolving the existing `validate` import; the new wrapper adds the original fixture directory to `sys.path`. No source/oracle change was required.
