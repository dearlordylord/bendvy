# Independent Standards review

Subject: `git diff b2ef9608bc1b2640fd5418f922fc1b254a1160df b9c7f63a -- src/ecs` (33 added modules; 1,606 lines). Read-only source review for API adoption, applying AGENTS.md, CODING_STANDARDS.md, the applicable workflow, and Bend LDD constraints. No source edits or heavy execution.

## Hard violations

None established. Source adoption is not blocked by this Standards review. This conclusion does not certify runtime qualification, universal refinement, performance, or issue closure.

Payloads, stores, resources, recovery owners and Local state remain arbitrary `Type`; detached observations use `Data`. Generic gameplay invocation quantifies over opaque `H`. Read-only provisioning exposes `Cap.Read`, while owned mutation carries explicit request grants. Rejected validation returns its incoming owner; immediate restore failure retains `Pending<Q>` and Local recovery receives it. The retained declaration/project parameters travel through Family rest owners and snapshot leaves. Public save requires the complete product schema's `True` eligibility; plain leaves propagate `False`. Trusted author construction remains explicitly trusted, rather than claiming constructor secrecy.

Reference priority: pinned Rust Bevy's world-coupled ComponentId and access-bearing FilteredEntityRef support reviewing identity and access authority first; Bend affine threading then constrains the representation. Pinned TS Descriptor transient/constructed inventory is supplementary. All three reference HEADs match sources.json.

## Heuristic concerns (nonblocking)

- `decode-requests.bend:validated` and `decode-frame.bend:spawn_validated` project an accepted owner a second time after declaration validation already projected it. This duplicates potentially costly author work and makes the relationship between packet.original and the validated description depend on projection stability. Consider carrying the initial description with the validated owner, preserving arbitrary Type and the trusted-author boundary.
- `ordinary-query-declaration.bend` repeats the same Family/lens specialization across seven constructed clauses. A shared typed family helper could localize future wiring changes. Bend's one-match helpers and explicit type arguments justify much of the verbosity; this is a maintenance concern, not a blanket factoring requirement.

No laws, approval policies, or new restrictions are proposed.
