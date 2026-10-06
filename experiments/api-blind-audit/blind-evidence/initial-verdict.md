# First impressions (frozen before experiments)

The snapshot exposes generic storage/query functions, but the schedule registers a closed BodyKind enum rather than a caller-authored system function. Its supplied hosts split Motion and Health into different worlds. World has two affine payload slots plus one Data flag, a ledger and a mode; it does not directly express Position, Velocity, Health and optional Armor as independent components in one world. Packing gameplay into a main component might permit arithmetic but would lose independent ECS membership and access declarations.

Returning an affine owner beside observations is normal Bend ownership, not an API defect. Repeated template type/getter/client arguments, concrete trusted storage constructors and a closed demonstration dispatcher are API costs beyond that ownership requirement. I will attempt the generic query/command seams independently before assigning final capability verdicts. No gameplay success is inferred from existing demo callbacks.

## Frozen after first independently authored query attempts

Installed bend 2.0.35 accepts the import but cannot accept a useful query callback: ordinary live get binder does not match the expected erased binder; changing it to -get makes its live call illegal. This is a blocker, not a type-safety rejection or passed read capability. Independently registered gameplay systems remain unsupported by the closed schedule. No coordinator design hints have been requested or accepted.
