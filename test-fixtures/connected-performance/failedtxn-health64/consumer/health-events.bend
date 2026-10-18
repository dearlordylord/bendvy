import Base
import ../../sparse-motion64/consumer/s-perf/canonical-api-v1/sparse-runtime-v1/types.bend as T
import ../../../../src/ecs/relation-commands.bend as Notice
def Publication() -> Data:Nat
def event_type() -> Data:Notice.Notice<T.HealthSchema,Nat>
def ping(code:U32) -> event_type():Notice.Original{U32.to_nat(code)}
