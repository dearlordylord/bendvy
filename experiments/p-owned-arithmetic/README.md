# Contextual owned-runtime arithmetic checkpoint

The structural toolkit checks with Bend 2.0.34 and its kernel. **No ECS endpoint is completed here.** The full owned schedule proof, including the proposed binder revision, remains outside this work. The pre-development [inventory](PLAN.md) fixes the intended dependency scope.

## Checked result

| Dependency | Actual guarantee / purpose |
| --- | --- |
| `adc_zero` | For every width and word, adding the zero word without carry preserves the word. |
| `adc_carry` | Adding the zero word with carry equals the actual `Word.inc`, including overflow. |
| `add_one`, `runtime_add_one` | Actual `U32.add(value,1)` used by Reserve/Bump equals `U32.inc(value)` for every U32. This is an operational linkage, not a Nat no-wrap theorem. |
| `zero_conversion` | Structural zero words convert to Nat zero. |
| `clear_conversion` | Increment converts to successor when the actual low bit is False. |
| `carry_conversion` | A True low bit converts correctly **given** the tail's actual successor equation. That premise is not silently assumed globally. |
| `cmp_self` | Structural self-comparison returns EQ. This is only reflexivity, not conversion agreement for distinct keys. |

All proofs recurse on word width or use explicit constructor cases. None expands unary MAX, asserts global non-overflow, assumes carry propagation as an axiom, or fills an unapproved catalogue law. The actual library's low-bit-first representation and `Word.adc` determine the derivations. Base's existing `Word.add_comm` / `U32.add_comm` are available but insufficient for the needed conversion/order links. No available mathlib installation was found; no dependency was added.

## Evidence

Run from repository root:

```sh
python3 experiments/p-owned-arithmetic/run.py
```

Fresh result: exit 0. [evidence.json](evidence.json) records exact original subject hashes, installed Base hash, source hashes and command outputs. Both toolkit and controls pass `--check-only` and `--verdict` via the existing five-second wrapper; subprocess watchdog is six seconds and does not extend the checker limit. A copied positive passes the kernel. Literal controls exercise a clear low bit, multi-bit carry, full U32 wrap and comparison reflexivity. They were added after structural proof development; they are finite controls, not a pre-proof falsification claim.

The false two-bit carry equation is rejected. A focused *statement* mutation replacing True input carry by False in the general `adc_carry` equality is rejected by its unchanged proof at `adc_carry`. This checks contextual proof sensitivity only: it is not an implementation mutant, not an own-ECS-endpoint mutation and not independent kernel rejection (negative stops in initial checking). No unsafe/foreign code or unresolved hole occurs in the accepted toolkit.

## Remaining boundaries

General U32 comparison conversion and general below-MAX successor conversion would reproduce the unapproved `u32_comparison_agrees_nat` and `u32_increment_no_wrap` catalogue claims if presented as standalone bridges. This collision was reported to the coordinator before proof development; neither is proved or renamed here. The conditional-Type infrastructure laws are untouched. These local dependencies are not separately promoted arithmetic contracts.

The future endpoint still needs contextual comparison agreement for distinct projected keys, a carry/no-wrap argument derived from actual Reserve bounds and prefix-safe Bump values, then actual owner/array read-write projection, command-prefix preservation and schedule composition. `carry_conversion` leaves the essential tail premise visible; it does not solve that no-wrap argument. Whether a broader contextual bridge is acceptable under the endpoint approval must be resolved explicitly before introducing a statement equivalent to an unapproved catalogue claim. The pending binder decision is independent of these mathematical gaps.

Sources are restricted to this directory; original core/laws and all other work are unchanged. No performance or backend correctness result is claimed.
