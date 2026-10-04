# Reader host adapter operation drafts (not approved proofs)

Subject: `reader-host.bend`, joining actual Storage.Handle/Change with the existing
R/S reader and stream operations. The dispatcher owns the clock and actual base
identity. Main's trusted schema-local component ordinal is 0.

- `append_ping(logs,t,vs)` publishes exactly one nominal Ping batch at supplied t;
  it changes neither lifecycle log nor clock. Empty values publish nothing.
- `append_changes(logs,t,changes)` appends actual MainRemoved handles to the Main
  removal log and actual Despawned handles to the despawn log, preserving FIFO
  order independently. Added/Changed remain live storage marks; they publish no
  sparse removal record. No handle is reconstructed from an integer.
- `frame(logs,readers,frame)` returns the supplied frame's actual clock, derives
  holders from each actual R.ReadKind and applies its message/lifecycle boundary.
  A None lifecycle boundary does not trim either lifecycle log.
- `read(logs,run)` returns the original affine ownership chain plus all three
  ordered observations and actual message/removal/despawn lag flags. Its boundary
  is R.project(run)'s boundary. It never completes a reader or advances a clock.
  Failure/retry equality is conditional on unchanged intervening publication/loss.

Controls must bind real factory-issued schema-specific handles, feed actual
commands.apply notifications, run both nominal schemas, complete/fail actual Runs,
trim at an actual frame, and compare returned handles including world namespace.
Planted defects: drop despawn routing; route Added as Removed; suppress lifecycle
lag; complete during read; ignore holder kind/frame lifecycle guard. Existing
module mutations supply primitive coverage; adapter mutants must execute fresh.
No general law is approved or proved by this draft. Public declared callbacks,
full dispatcher snapshots, old live marks, performance acceptance and global
identity authority remain their own integrated gates.
