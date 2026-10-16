# Independent canonical family API successor

This independently authored source consumer adapts the CargoManifest application
to the final canonical owned-event family API. Its finite scope remains one
family and two independent readers; the separate source owner qualifies family
composition. The v1 consumer and its backend history remain preserved.

The real IO entry is `main.bend`; the pure application is `app.bend`. The world
resource is `Product.Owner<Array<U32>,Log.Log<Manifest>>`. `model.setup` calls
canonical `Setup.leaf` and `Setup.under_resource`; its selected owned binding
feeds the publisher declaration, and that same descriptor supplies the reader
runtime. A typed `Catalog.leaf` covers the complete log/stream tree for frame
maintenance and shutdown. No handwritten publication metadata or custom route is
used. Runtime ownership is `FamilyRuntime.State<Nat,Stream<Schema,Nat>,Unit>`.

The thirteen-operation observation sequence is reused from this author's own v1:
created; commit A; abort B with inspected/discarded recovery; fast failure; fast
retry; frame; commit C; fast C; slow A+C; frame; frame; commit D; shutdown.
Reader private Args retain their attempted projections after failure, while the
selected runtime determines cursor rollback. Reader scratch Arrays remain affine
and track the most recent observed manifest code. Full payload contents and
scratch sentinels remain visible. Capacity stays eight.

The preserving administrative observer records every World field and physical
Array tree, the product resource and full log rows/counter, every outer runtime
field, every family-state field (including the full publication journal and Unit
Owners), every stream field (including its nominal domain), all registry and
reader-handle fields, actual private Args, and returned ownership receipts.
Opaque pending command closures are threaded and counted; this consumer stages
no commands. Gameplay callbacks receive only opaque declared capabilities.

`check-app-01.txt` is a passing five-second pure source check, including concrete
canonical publisher and reader specialization. `check-main-01.txt` reports only
the expected foreign trust chain through namespace creation and IO main; it has
no syntax, type or affine diagnostic and is not reported as a proof pass. No
backend or oracle has been run or authored by this application author.

`source-manifest.json` contains all 45 transitive Bend files and both namespace
CNI sidecars. `freeze-sources.py` follows explicit-relative and bare module
imports recursively, plus quoted sidecar imports. Base uses the execution
runner's compiler/Base pin. All copied core dependency hashes were compared
against the source owner's final checked worktree and matched. The copies are
materialization only and are not committed by this application author.

Public API ergonomics: canonical Setup gives one consistent descriptor for the
log path, route, domain and stream, but the current ordinary wrapper signatures
require explicitly repeating its eighteen indexed parameters at call sites.
This source uses those public signatures directly. A future inferred descriptor
wrapper could shorten application declarations without changing their semantics;
no such core change is part of this consumer.
