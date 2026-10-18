import Base
import /tmp/bendvy-failedtxn-health-matched-method/experiments/s-perf/canonical-api-v1/dense-runtime-v1/types.bend as T
import /tmp/bendvy-failedtxn-health-matched-method/src/ecs/relation-commands.bend as Notice
def Publication() -> Data:Nat
def event_type() -> Data:Notice.Notice<T.HealthSchema,Nat>
def ping(code:U32) -> event_type():Notice.Original{U32.to_nat(code)}
