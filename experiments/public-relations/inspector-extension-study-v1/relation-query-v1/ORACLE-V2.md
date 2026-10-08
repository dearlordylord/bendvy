# Relation fixture oracle correction (source review pending)

The original IO receipt remains INCOMPLETE. This sibling model corrects only fixture clock arithmetic; it changes no ECS source or contract and does not rerun the consumer.

`world.bend:39` creates the world at clock zero. `fixture-build.bend:35–43` selects Stock for IDs 1, 2, 4 and Title for IDs 2, 3, 4. Each successful `component.bend:121–139` replacement calls `World.advance_clock`; six replacements therefore leave the primary world at clock six. The separately owned foreign world does not advance the primary clock. Reserve, activate and deactivate preserve the clock.

The initial relation commands and barrier preserve that clock. `fixture-driver.bend:28–33` invokes the first observation with `Inspector.Fresh`. `inspector.bend:first` supplies cursor zero. `finished` advances the world once on Done and retains that new clock as the active instance cursor. The later queued and barrier observations reuse the returned instance. Their body clock/cursor pairs are thus `(6,0)`, `(7,7)`, `(8,8)`, followed by final clock/cursor `(9,9)`. No failed transaction, overflow, or failed Inspector branch is selected by this finite fixture.

`oracle-v2-source-delta.json` pins the original and sibling models, complete oracles, fixture and core sources. Exactly 24 clock/cursor leaves change across the two schemas; every one of the 192 complete query observations, owner snapshots, errors, relation orders, retained observations and foreign-handle expectations stays identical. The original TS oracle remains unchanged because it has no Bend clock/cursor fields.

Any later no-child reconciliation must separately bind the existing complete actual output, historical plan/receipt/guards, these source pins, the original oracle and this reviewed model delta. It must preserve the original failed acceptance rather than relabel its receipt PASS. This is finite development evidence, not standalone backend, Native, performance, adoption or full #55 qualification.
