import Base
import ./ordinary-combined-consumer.bend as Core
import ./ordinary-disposal-consumer.bend as Disposal
import ../../../../../../../../src/ecs/world-io.bend as WIO
import ../../../../../../../../src/ecs/event-stream.bend as Leaf
import ../../../../../../../../src/ecs/event-notice-runtime.bend as Mixed
import ../../../../../../../../src/ecs/ordinary-event-declaration.bend as Event
import ../../../../../../../../src/ecs/ordinary-reader-system.bend as Ordinary

# Both worlds are created through the host-backed WorldIO API in one IO chain.
def context_from_world(world:Core.world_type()) -> Core.context_type():
  Mixed.start(~Core.Schema,~Core.store_type(),~Unit,~Core.Publication,~Core.family_type(),~Unit,
    world,Leaf.provision(~Core.Schema,~Core.event_type(),Event.domain(~Core.Schema,~Core.event_type(),"values"),65536n),Unit{})

def disposal_type() -> Type:
  Disposal.disposal_result_type()

def own_disposed_snapshot_result(foreignResult:String,ownBefore:String,result:Core.context_type() & String) -> String:
  match result:
    case (_,ownAfter):"{\"foreign\":"++foreignResult++",\"own\":{\"status\":\"disposed\",\"contextBefore\":"++ownBefore++",\"contextAfter\":"++ownAfter++"}}"
def own_disposed_snapshot(foreignResult:String,ownBefore:String,context:Core.context_type()) -> String:
  own_disposed_snapshot_result(foreignResult,ownBefore,Disposal.context_keep(context))

def own_disposed_result(foreignResult:String,ownBefore:String,disposed:disposal_type()) -> String:
  match disposed:
    case Ordinary.ProviderDisposed{context,_}:
      own_disposed_snapshot(foreignResult,ownBefore,context)
    case Ordinary.ProviderDisposalRejected{_,_}:"{\"error\":\"own-context disposal was unexpectedly refused\",\"foreign\":"++foreignResult++"}"

def foreign_rejected_snapshots(own:Core.context_type(),ownBefore:String,+foreignBefore:String,+providerBefore:String,
    foreignResult:Core.context_type() & String,providerResult:Core.provider_type() & String) -> String:
  match foreignResult:
    case (foreign,+foreignAfter):
      match providerResult:
        case (provider,+providerAfter):
          own_disposed_result(
            "{\"status\":\"rejected\",\"contextBefore\":"++foreignBefore++",\"contextAfter\":"++foreignAfter
              ++",\"providerBefore\":"++providerBefore++",\"providerAfter\":"++providerAfter
              ++",\"contextPreserved\":"++Core.boolean(String.eq(foreignBefore,foreignAfter))
              ++",\"providerPreserved\":"++Core.boolean(String.eq(providerBefore,providerAfter))++"}",
            ownBefore,Disposal.dispose_all(provider,own))

def foreign_disposed(own:Core.context_type(),ownBefore:String,foreignBefore:String,providerBefore:String,
    result:disposal_type()) -> String:
  match result:
    case Ordinary.ProviderDisposalRejected{context,provider}:
      foreign_rejected_snapshots(own,ownBefore,foreignBefore,providerBefore,
        Disposal.context_keep(context),Disposal.provider_keep(provider))
    case Ordinary.ProviderDisposed{_,_}:"{\"error\":\"foreign-context disposal unexpectedly succeeded\"}"

def attempt_foreign(ownResult:Core.context_type() & String,foreignResult:Core.context_type() & String,
    providerResult:Core.provider_type() & String) -> String:
  match ownResult:
    case (own,ownBefore):
      match foreignResult:
        case (foreign,foreignBefore):
          match providerResult:
            case (provider,providerBefore):
              foreign_disposed(own,ownBefore,foreignBefore,providerBefore,Disposal.dispose_all(provider,foreign))

def defined(foreign:Core.context_type(),definition:Core.definition_type()) -> String:
  match definition:
    case Ordinary.DefinitionRegistered{context,provider}:
      attempt_foreign(Disposal.context_keep(context),Disposal.context_keep(foreign),Disposal.provider_keep(provider))
    case Ordinary.DefinitionRejected{_,_,_}:"{\"error\":\"ordinary provider definition rejected\"}"
    case Ordinary.DefinitionDisposalRejected{_,_,_}:"{\"error\":\"ordinary provider definition cleanup was refused\"}"

def run(own:Core.context_type(),foreign:Core.context_type()) -> String:
  defined(foreign,Core.define_all(own,"io-disposal"))

def second_world(own:Core.context_type(),created:WIO.Creation<Core.Schema,Core.store_type(),Unit,Core.event_type()>) -> IO(Unit):
  match created:
    case WIO.Refused{_}:IO.print("{\"error\":\"second WorldIO creation refused\"}")
    case WIO.Created{world}:IO.print(run(own,context_from_world(world)))

def first_world(created:WIO.Creation<Core.Schema,Core.store_type(),Unit,Core.event_type()>) -> IO(Unit):
  match created:
    case WIO.Refused{_}:IO.print("{\"error\":\"first WorldIO creation refused\"}")
    case WIO.Created{world}:
      IO.bind(WIO.Creation<Core.Schema,Core.store_type(),Unit,Core.event_type>(),Unit,
        WIO.create(~Core.Schema,~Core.store_type(),~Unit,~Core.event_type(),~Core.empty_store,Unit{}),
        result => second_world(context_from_world(world),result))

def main() -> IO(Unit):
  IO.bind(WIO.Creation<Core.Schema,Core.store_type(),Unit,Core.event_type()>,Unit,
    WIO.create(~Core.Schema,~Core.store_type(),~Unit,~Core.event_type(),~Core.empty_store,Unit{}),first_world)
