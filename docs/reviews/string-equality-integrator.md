# String equality candidate — integrator evidence review

Reviewed the staged finite candidate; no shared World adoption or proof approval.
Receipt `2aa8ec5b0f37a68599bdb654214362d622d91446159186978ab5524429388d6a` reports 27 commands and
`PASS_FINITE_EQUALITY_AND_REACHED_MUTANTS_BOTH_BACKENDS`.
Both complete normal JS and Native outputs independently match the authored
333-line oracle, SHA256
`f2ed66b23729baf478f560326994601abd93065ce6ba900aa8d22231aaeaf87d`.
The emitted `equal_walk` function uses `for (;;)` and direct `continue`; it
avoids the original candidate's eager recursive call underneath `Bool.and`.

Receipt metadata caveat: `sourceScope` incorrectly inherited a full 62-row
application description. The actual `scope`, sources and outputs concern only
324 old/new Unicode pairs plus nine registration/access controls. No full
application acceptance follows. Preserve that receipt and correct future
metadata rather than rewriting historical evidence or repeating an unchanged
subject solely for a reporting field.

Long-control v2 failed at a backend-specific surrogate-printing oracle:
JS rejects the value; Native prints raw surrogate UTF8 bytes. This is an IO
boundary observation, not an equality mismatch or a common scalar-domain proof.
Retain the failure and separate valid-Unicode long controls from that canary.
No compiler/Base/runtime modification, new policy, threshold or law is approved.
After candidate validation, staged World adoption must replay affected public
semantics, paired regression and the equivalent full application/profile protocol.

## Staged full application checkpoint

The admitted staged World patch now passes the unchanged complete 87-command
state cohort, including five reached mutants on JS/Native. Child receipt SHA256
`2fe828d607287a7758953060570007e1bca7a5e948f16978a9250edc131e6591`;
outer orchestration receipt
`ed881853beddbaaf652b5f1c5c9595c4bee62f850c4ec16a44731a0ee6b936e1`.
Root independently inspected both terminal statuses/counts. Three-scale complete
semantic/build controls are in progress. Live World remains unchanged; profile,
equivalent timing, regression, final review and delivery remain required.
