# Independent host launch review

BLOCKED: author d2d39ecd, exact plan 15882b3432194d759cb980c6bbdfb24d8b2d21b2593e3457822d571ca1237749. All 44 current pins and 33 reference source membership entries match; prepared output contains only plan. Existing two actual bootstrap controls pass without helper execution or children. Scope correctly states host conversion, not generated ECS interoperability.

Three collector gaps require repair before launch. First, json.loads(stdout)==json.loads(expected) uses loose Python equality: True equals 1 and False equals 0. Actual expected sameFunctions/ok Boolean fields therefore accept integer corruption. Require existing type-sensitive whole JSON comparison and a reached Bool/int refusal control.

Second, raw publication uses Path.write_bytes without exclusive creation or regular nonsymlink checks; only existing receipt is refused. Existing stdout/stderr files or symlinks can be overwritten. Require exclusive regular raw boundaries and actual output collision/symlink controls.

Third, result metadata is retained before publication, but raw bytes/capture failure details are lost if publication raises. Reuse reviewed raw result/capture-error preservation so original child result and failed capture are both retained; test failed publication with actual collector path. No backend launched. Keep original plan immutable and prepare fresh exact plan after repair.
