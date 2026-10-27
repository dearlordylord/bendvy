# Run a scheduled health simulation

This ordinary consumer uses the replacement generalized Root executor. A retained command author queues three entities; a retained query writes `Health` and reads required `HealthDecay`. The registered enabled condition runs through the condition kernel. The first run leaves commands pending and observes no rows. Turning on automatic barriers publishes the entities before the decay query on each of the following six updates.

From the repository root:

```sh
bash examples/scheduled-health/run.sh js
bash examples/scheduled-health/run.sh native
```

`BEND`, `NODE` and `CLANG` select the compiler and runtimes. The source was compiled and its ordinary JS entry executed with Bend 2.0.35 during this migration. Generated files stay in ignored `build/`. These entry runs produce finite observations; they are not formal proofs or a native qualification claim.

```text
before-barrier=
tick=1 health=5,5
tick=2 health=2.5,1.25
tick=3 health=1.25,0.3125
tick=4 health=0.625,0.078125
tick=5 health=0.3125,0.01953125
tick=6 health=0.15625,0.0048828125
untouched=30
```

- [schema.bend](schema.bend) declares the nominal schema and the `health` / `decay` component layout.
- [spawn.bend](spawn.bend) owns the three initial bundles and retains actual reserved handles and refused bundles. Change the initial health and factors here.
- [system.bend](system.bend) declares the health query bounded by decay presence and applies the factor to the real component owner.
- [enabled.bend](enabled.bend) defines the always-enabled condition.
- [registration.bend](registration.bend) registers the command author, decay system and condition with their actual compilation witnesses.
- [root.bend](root.bend) retains those owners, derives dependency and condition bindings from their real registration identities, dispatches through the common group driver, and publishes the command queue through one barrier clock.
- [observe.bend](observe.bend) reads cached component views through passive Inspector grants with full-handle validation. Health rows with decay form the tick output; the row without decay supplies `untouched`.
- [application.bend](application.bend) retains each returned Root and Inspector instance across the first pending run, barrier configuration change and six updates.

The third entity has Health 30 and no HealthDecay. It remains outside the decay query. The first empty result demonstrates pending command visibility; the final observation demonstrates the excluded component remains 30.

The replacement amendment in [SPEC](../../docs/SPEC.md) supersedes the old rollback and fail-fast execution contract. A body error is a returned completion; this consumer's handler continues, and earlier owner changes or queued commands are not rolled back. Admission and publication refusals retain their actual inventories in the new carriers. This example exercises the successful path and does not claim to demonstrate failure recovery.

The former transaction implementation remains available in Git history under its old contract. The pre-existing `verify.py` is retained as existing infrastructure; `run.sh` does not invoke it, and it was not run as migration evidence. This migrated entry adds no host-language behavioral verifier.
