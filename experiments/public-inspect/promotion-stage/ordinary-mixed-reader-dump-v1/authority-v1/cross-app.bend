import Base
import ../alpha/application.bend as Common
import ../alpha/state.bend as F
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-dump.bend as Dump
import ../beta/application.bend as Other
import ../beta/state.bend as OtherState
def wrong(value:Common.Application()) -> Other.Application() & Maybe<&2,Dump.Dump<OtherState.S>>:Other.dump(value)
def main() -> Unit:Unit{}
