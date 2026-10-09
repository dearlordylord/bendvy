# Retention backend admission — held on failure capture

Preparation: immutable author `4deedecbd452b93f332f296485079232ba25ed11`. Source/model review `9752741d` remains valid; both complete thirteen-Snapshot models unchanged. No compiler/runtime/profile child was launched by this reviewer.

| Exact original plan | SHA256 | Current input entries |
|---|---|---:|
| normal JS | 9f960dde54334d062c4a1280898f5bf0dc2e4a5a3a87217caca8b62b2224994b | 38 |
| normal Native | 0f3de892c4d3d1470fb12de277026fb62cd969aae253fd1638591a3fbfbecdc1 | 42 |
| retainer JS | 595e4a701a773842ca37107c5be7773337e84f457cdf7b89eb1ff70940da0755 | 39 |
| retainer Native | aa51fd74dc65bac917ec8516307fb3f29b366f1690eb1fc3edd5e2a432c077db | 43 |

All four actual plan hashes, every file pin and complete resource directory membership/bytes were independently verified. Raw/generated directories are regular and empty and no receipt exists. PREPARED commands equal actual plan commands; normal/retainer bindings select their exact sources and full raw/neutral oracles. Role `generic` is a transport dispatch, not owned-event scenario acceptance. Collector is reused unchanged from declaration-read-v1.

Reviewed stock stages: pinned Bend2.0.35 emit30, JS Node24.20 run5; Native Clang19 -O3 build120/run5 with threads1/GPUoff. CPU5 and sole internal heavy lock. No custom compiler, retries, threshold changes or Type-event policies. Source/import closure is exact. Helpers are compiled from rehashed admitted bytes after actual interpreter/current-input guard. Transport preserves full nominal constructor identity/typed scalar fields, rejects suffix, missing field and Bool/U32 misuse, and exact entire raw stdout is separately required. Generated regular artifacts are captured in finally and joined before later consumption. Commands are appended before invocation and completed Runner result is retained on publication errors.

## Concrete blocker

`experiments/public-owned-events/declaration-read-v1/development-run.py:170–175` defines guard with `logs.guard()` **before** `record['logs'] = dict(logs.hashes)`. If stdout publication succeeds and stderr publication fails, hashes contains the successful stream join but guard throws before copying it into the unconditional failure receipt. The actual returned command result is preserved, but that alone does not preserve the successfully published raw join. This repeats the existing partial-publication failure case already corrected in other collectors.

Required narrow repair: copy published joins before calling logs.guard; add a focused actual Runner partial-publication control proving returned result and successful stream hashes survive. Root owns this shared collector. Preserve these four unused frozen plans, then bind repaired helper bytes through fresh successor plans and recheck admission. **No launch admission** for the original four plans until this failure boundary is repaired; other exact-source/model/resource/wire checks passed.

Scope remains the declared retention DTO and reached artificial-retainer countermodel. Full #54 World/live/store/pending, arbitrary Type events, disposal policies and full delivery/performance are not qualified here.
