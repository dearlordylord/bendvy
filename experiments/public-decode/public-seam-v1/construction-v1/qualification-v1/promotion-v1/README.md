# Import-only construction promotion proposal

Draft for root integration; these files are not public core yet. The manifest maps six qualified source modules to intended `src/ecs` names and proves the inverse import mapping restores every original byte.

`decode-construction` exposes retained `Factory`/`FallibleFactory`, validation before the reversible builder, and an opaque-H owned grant. The two request compositions provide raw-input spawn/insert; the three resource modules provide typed validation, raw construction, and custom-error composition. Arbitrary `Type` inputs/payloads and `Custom:Data` errors remain supported.

Declaration, projector, builder/undo and recovery sink remain explicit application choices. Immediate refusal returns its owner; accepted commands use existing deferred barrier/Local recovery. Resource rollback retains the established `Resource.restore` behavior: it does not return a displaced replacement automatically. Pending recovery remains explicit/incomplete.

Full 44+20+16 JS and Native observations are archived in `9c62218b` and `8deb8104`. `check-imports.py` verifies only byte equivalence and dependency targets; root must check the staged canonical imports. No new backend plan or performance claim. The host Standard Schema adapter remains separate conversion support; generated ECS callback interoperability is still an explicit #46 audit boundary.
