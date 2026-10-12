import Base
import ../alpha/application.bend as Common
import ../alpha/state.bend as F
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-dump.bend as Dump
def duplicate(value:Common.Application()) -> (Common.Application() & Maybe<&2,Dump.Dump<F.S>>) & (Common.Application() & Maybe<&2,Dump.Dump<F.S>>):(Common.dump(value),Common.dump(value))
def main() -> Unit:Unit{}
