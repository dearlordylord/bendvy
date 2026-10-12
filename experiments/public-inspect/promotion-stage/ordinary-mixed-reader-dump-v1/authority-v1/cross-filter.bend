import Base
import ../alpha/application.bend as Common
import ../alpha/state.bend as F
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-dump.bend as Dump
import ../beta/state.bend as OtherState
import ../alpha/event-setup.bend as Events
import ../alpha/bindings.bend as B
import ../alpha/provision.bend as Provision
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-event-family-dump.bend as DumpApp
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-dump-filter.bend as Filter
def wrong(value:Common.Application(),criteria:Filter.Filter<OtherState.S>) -> Common.Application() & Maybe<&2,Dump.Dump<F.S>>:DumpApp.snapshot(~F.S,~F.Store(),~F.Resources(),~F.Events(),~Events.State(),~B.Owners4(),~B.Rows4(),~B.observe4(),~B.fold4(),~Provision.count(),~Provision.values(),~Provision.resources(),criteria,value)
def main() -> Unit:Unit{}
