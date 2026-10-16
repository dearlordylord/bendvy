# Reached eager-RHS defect

The sole semantic change is in the copied canonical ordinary-checked-condition
`selected` helper: its False branch invokes `right_run` and retains the returned
right owner/result, instead of preserving the skipped right owner and returning
the left Bool. The True branch and all other condition/check/gameplay behavior
remain unchanged. Three nominally dependent modules are copied only to import
this isolated condition type; other dependencies use the unchanged canonical
root modules. The normal fixture, observer and scenario function bodies are
unchanged apart from variant imports; main is byte-identical.

The full normal consumer reaches the changed helper through actual registered
schedule AND conditions and retained direct OR probes. Missing-resource skipped
branches therefore expose the incorrect reached required preflight. No observer,
World setup, body, required declaration or canonical root module is mutated.
SOURCE-FREEZE.json pins the entire129-module/200-pin closure. Fixture/observer/
scenario source checks PASS; IO main has the same nine expected foreign IO
refusals. Independent source-derived countermodel and root-only stock pair are
pending. No cleanup/finalizer, performance or complete #61 acceptance claim.
