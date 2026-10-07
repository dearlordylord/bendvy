import Base
import provider.bend as Provider
import gameplay.bend as Gameplay
import runtime-context-other.bend as X
import core-feature.bend as Core
import feature.bend as F
import ../../src/ecs/world.bend as W
import ../../src/ecs/system.bend as Sys
import ../../src/ecs/schedule.bend as Sch
import ../../src/ecs/schedule-provision.bend as P
def tick(world:W.World<X.Schema,X.Declarations,X.Trace,U32>) -> W.World<X.Schema,X.Declarations,X.Trace,U32>:
  X.tick(0,"Core",world)
def runner(world:W.World<X.Schema,X.Declarations,X.Trace,U32>,args:Unit) -> Sys.Outcome<W.World<X.Schema,X.Declarations,X.Trace,U32>,String,Unit>:
  Sys.Succeeded{Provider.provide_action(~W.World<X.Schema,X.Declarations,X.Trace,U32>,~tick,~Gameplay.action,world),Unit{}}
type Built is Type:
  Built{owner:Core.Owner,registry:Maybe<&1,Sys.Registry<X.Schema,X.Declarations,X.Trace,U32,Unit,String,Unit,runner>>}
def registered(owner:Core.Owner,observed:Sys.RegistrationResult<X.Schema,X.Declarations,X.Trace,U32,Unit,String,Unit,runner>) -> W.World<X.Schema,X.Declarations,X.Trace,U32> & F.Output<X.Schema,Built>:
  match observed:
    case Sys.Registered{world,Sys.Registry{ns,+id,name,access,cursor}}: (world,F.Output{Built{owner,Some{Sys.Registry{ns,id,name,access,cursor}}},P.Entry{Sch.System{id,0},[P.Component{1}]},P.Entry{Sch.System{id,0},[P.Component{1}]}})
    case Sys.RegistrationFailed{world}: (world,F.Output{Built{owner,None{}},P.Empty{},P.Empty{}})
def owned(world:W.World<X.Schema,X.Declarations,X.Trace,U32>,observed:List<&2,String> & F.Output<X.Schema,Core.Owner>) -> W.World<X.Schema,X.Declarations,X.Trace,U32> & F.Output<X.Schema,Built>:
  match observed:
    case (trace,F.Output{owner,bootstrap,update}): registered(owner,Sys.register(~X.Schema,~X.Declarations,~X.Trace,~U32,~Unit,~String,~Unit,~runner,X.traced(world,"build:Core"),"Core",["trace.write"]))
def build(world:W.World<X.Schema,X.Declarations,X.Trace,U32>,owner:Core.Owner) -> W.World<X.Schema,X.Declarations,X.Trace,U32> & F.Output<X.Schema,Built>:
  owned(world,Core.build(~X.Schema,[],owner))
def provided(definition:F.Definition<X.Schema>,owner:Core.Owner) -> F.Feature<X.Schema,W.World<X.Schema,X.Declarations,X.Trace,U32>,Core.Owner,Built>:
  F.FeatureOwner{definition,owner,build}
