import Base
import ../../../src/ecs/execution-save-gate.bend as Gate

# Approved unchanged statement from ../LAWS.bend at
# fd6826220899f261994a4a77260d6c2049e1caed; see SUBJECTS.json.
# Guarantees: a supplied pending flag returns the same actual application and RefusedPending.
# Why it matters: pending save refusal must retain the caller's affine application.
# Bevy code: https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_ecs/src/schedule/executor/single_threaded.rs
# Bevy behavior: deferred-buffer application is a separate executor step.
# Bend adaptation: pending-save refusal and exact affine retention are Bend policy,
# not a Bevy serialization theorem or a proof of the caller's pending detector.
law pending_returns_actual_application:
  for -Actual:Type
  for -Value:Data
  for -Error:Data
  for -project:Actual -> Actual & Gate.Outcome<Value,Error>
  for -actual:Actual
  {Gate.checked(~Actual,~Value,~Error,~project,(actual,True{})) == (actual,Gate.RefusedPending{}) : (Actual & Gate.Outcome<Value,Error>)}
