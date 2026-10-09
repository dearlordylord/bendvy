# Next #46 production seam — source-backed gap

The complete execution qualifies this application's registered assembly; it does not promote a general ECS API.

| Current seam | Actual source limitation | Smallest production change |
| --- | --- | --- |
| `public.Frame<S>` | Holds `App.World<S>` and fixed `Input.Owner`; declaration selects this application's component/resource/spawn providers | Parameterize frame by `C:Type,R:Type,E:Data,P:Type` and retained `Constructed<S,P,identity,project>`; keep World behind opaque H |
| `registered.State<S>` / `Args<S>` | Fixed application owner, operation, codec and Local recovery shape | Derive registered access from existing identity/clause declarations; retain descriptor and closed provider/body identity with arbitrary affine args/output, explicit existing Local recovery |
| `request.Owner<S,C,R,E,P,...>` | Already generic; real validation/Batch refusal preserves arbitrary P, but component delivery and resource adapter supplied by application | Reuse this provider; require closed schema delivery callbacks and existing resource journal/lens implementation at provisioning, not caller-authored access strings |
| `App.resource_grant` | Journals one fixed `Mail.value` projection | Join established generic resource/world ownership operations; preserve old-owner rollback and unrelated resource owners; do not select new cleanup/capture policy |
| query/read + owned write | Not composed in this candidate | Join existing query clause/capability declarations with owned operation grants into one declaration-derived opaque system body; shared core owned by integrator |

Important Bend boundary: arbitrary affine P cannot be reconstructed generically from detached Raw. Validation returns the original owner plus canonical Data; declaration-specific typed construction/delivery must preserve affine fields. A generic wrapper must not duplicate the owner, expose raw World, invent a P in a physical None refusal, or use runtime access strings as the authority itself.

Next implementation should generalize retained declarations/provisioning over the already-generic provider, then rerun the unchanged complete registered application as its consumer. Add a second genuinely different affine owner/resource family to prevent fixed-Input special casing. Immediate spawn remains a separate explicit feature gap; deferred spawn here is not its proof. Do not close #46 before production integration and general capability combinations qualify.
