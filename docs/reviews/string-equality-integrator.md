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
