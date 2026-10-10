# Expanded #70 actual reference comparison

One admitted TS run, original 18214, passed the complete independent 7421-byte oracle (SHA256 `635b5737…`), empty stderr, unchanged prepared/source pins. Raw output and receipt are preserved in `actual-01`. No retry or manual rollback occurred. The earlier selected writer/read comparison remains valid.

Bend core batch original 31428 separately passed seeded A (3018 bytes), seeded B (3493 bytes), and provisioning (2771 bytes), each on JS and Native; exact source/model/archive hashes are in COMPARISON-BASIS.json. This comparison joins common observations, not serialized representation equality.

| Observation | Actual common result / limit |
| --- | --- |
| A selected resources | 10..13 / 100..103 → 12..15 / 110..113 → failure restores those arrays → retry 14..17 / 120..123. |
| Other selected resources | 30..33 / 300..303 → 32..35 / 310..313 → rollback → 34..37 / 320..323. |
| Untouched sibling | Values [700,701] and flags [true,false] preserved. TS separate descriptor object does not establish Bend physically nested affine confinement. |
| Seeded membership | Two live entities with Cell values survive all resource operations. TS object records do not establish Bend capacity/depth, two affine column cells or namespace identity. |
| Pre-existing events | Actual [91,92] remain available through resource operations. TS uses a retained reader; Bend owns its event list. |
| Pre-existing deferred work | Remains pending/invisible through resource operations; explicit barrier applies it. TS inserts Marker99 into entity1; Bend callback publishes event99. These are labelled queue-visibility analogues, not equivalent command APIs. |
| Registration/access | TS retains declared system order/access observations. Bend additionally qualifies actual typed Registry ID/cursor/owner observations; TS does not expose equivalent ownership. |
| Duplicate provisioning | Both reject duplicate First, through different boundaries: TS Schema.bind throws; Bend canonical validation and ordinary engine return typed refusal. |
| Missing provisioning | TS absent resource preflight preserves full dump and skips body. Bend missing descriptor-list requirement preserves returned affine World. Physical absence and metadata absence are distinct. |
| Valid provisioning | TS runs selected resource system; Bend trusted Fragment initializer is identity. Their success markers do not establish identical initializer semantics. |

TS complete frame/tick observations are 1/7, 2/9, 3/11, 4/13, 5/15. Bend clock remains3 and selected actual cursor becomes3. Neither is normalized into the other. TS failure host-call log persists independently of World rollback; Bend typed error/affine Output transport differs. The actual Runtime journal performs TS rollback, while the accepted Bend transactional contract remains independent of generic Rust system behavior.

Remaining #70 audit limits: no TS proof of affine destruction, nested field ownership, authority refusal boundaries, physical missing-field policy, general inverse law, process identity or cursor equivalence. Expanded reference now covers the supported finite public TS scenarios; event99 callback and Fragment ownership/initializer behavior remain Bend-specific. No full issue closure or performance claim follows.
