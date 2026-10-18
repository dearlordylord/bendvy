import Base
import ../dense-runtime-v1/types.bend as T
import ../../../../../../../../../../../../workspace/formal-proofs/bendvy/experiments/s-perf/current-tx-boundaries-v1/workload-boundaries-v1/private/src/ecs/relation-commands.bend as Notice
def Publication() -> Data:Nat
def event_type() -> Data:Notice.Notice<T.HealthSchema,Nat>
def ping(code:U32) -> event_type():Notice.Original{U32.to_nat(code)}
