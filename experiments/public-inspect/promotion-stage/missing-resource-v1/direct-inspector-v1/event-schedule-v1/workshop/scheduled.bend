import Base
import ./fixture-1.bend as F
import ./fixture-2.bend as Events
import ./fixture-3.bend as B
import ./fixture-6.bend as Common
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-event-family-runtime.bend as App
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-schema.bend as SchemaApp
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-schema.bend as Schema
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-recipe.bend as Recipe
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-registration-fields.bend as Records
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/schedule.bend as Sch
import /workspace/formal-proofs/bendvy/src/ecs/event-family-routing.bend as Route
type Carry<-Out:Type> is Type:
  Carry{schema:Schema.Schema<F.S,F.Store(),F.Resources()>,family:Events.State(),tick:Nat,owners:B.Owners4(),recipe:Recipe.Recipe<F.World(),B.Rows4(),B.observe4()>,debug:Bool,args:Maybe<&1,Array<U32>>,output:Maybe<&1,Out>}
type Outcome<-Out:Type> is Type:
  Ran{app:Common.Application(),completion:Out,observations:List<&2,Sch.Observation>}
  Refused{app:Common.Application(),args:Maybe<&1,Array<U32>>,observations:List<&2,Sch.Observation>}
def selected(index:Nat,fields:List<&2,Records.Fields<F.S>>) -> U32:
  match index fields:
    case _ Nil{}:0
    case 0n Con{Records.Fields{_,id,_,_,_,_,_,_},_}:id
    case 1n+rest Con{_,tail}:selected(rest,tail)
def returned(~Out:Type,result:Common.Application() & Out) -> Carry<Out> & Sys.Outcome<F.World(),Unit,Unit>:
  match result:
    case (App.Application{schema,Route.Runtime{world,family,tick},owners,recipe,debug},output):(Carry{schema,family,tick,owners,recipe,debug,None{},Some{output}},Sys.Succeeded{world,Unit{}})
def dispatch(~Out:Type,~read:Common.Application() -> Array<U32> -> Common.Application() & Out,carry:Carry<Out>,world:F.World(),id:U32) -> Carry<Out> & Sys.Outcome<F.World(),Unit,Unit>:
  match carry:
    case Carry{schema,family,tick,owners,recipe,debug,Some{args},_}:returned(~Out,read(App.Application{schema,Route.Runtime{world,family,tick},owners,recipe,debug},args))
    case Carry{schema,family,tick,owners,recipe,debug,None{},output}:(Carry{schema,family,tick,owners,recipe,debug,None{},output},Sys.Failed{world,Unit{}})
def condition(world:F.World(),id:U32) -> F.World() & Bool:(world,True{})
def finished(~Out:Type,world:F.World(),observations:List<&2,Sch.Observation>,carry:Carry<Out>) -> Outcome<Out>:
  match carry:
    case Carry{schema,family,tick,owners,recipe,debug,args,Some{output}}:Ran{App.Application{schema,Route.Runtime{world,family,tick},owners,recipe,debug},output,observations}
    case Carry{schema,family,tick,owners,recipe,debug,args,None{}}:Refused{App.Application{schema,Route.Runtime{world,family,tick},owners,recipe,debug},args,observations}
def executed(~Out:Type,result:Sch.RunResult<F.S,F.Store(),F.Resources(),F.Events(),Carry<Out>,Unit>) -> Outcome<Out>:
  match result:
    case Sch.Finished{Sch.Schedule{_,_,_,carry},world,observations}:finished(~Out,world,observations,carry)
    case Sch.Failed{Sch.Schedule{_,_,_,carry},world,_,observations}:finished(~Out,world,observations,carry)
    case Sch.Rejected{Sch.Schedule{_,_,_,carry},world}:finished(~Out,world,[],carry)
def built(~Out:Type,~read:Common.Application() -> Array<U32> -> Common.Application() & Out,world:F.World(),result:Sch.Build<F.S,F.Store(),F.Resources(),F.Events(),Carry<Out>>) -> Outcome<Out>:
  match result:
    case Sch.Built{schedule}:executed(~Out,Sch.run(~F.S,~F.Store(),~F.Resources(),~F.Events(),~Carry<Out>,~Unit,~dispatch(~Out,~read),~condition,schedule,world))
    case Sch.Invalid{carry}:finished(~Out,world,[],carry)
def ids(registrations:List<&2,W.RegistrationMeta>) -> List<&2,U32>:
  match registrations:
    case []:[]
    case W.RegistrationMeta{id,_,_} <> rest:id <> ids(rest)
def cataloged(~Out:Type,~read:Common.Application() -> Array<U32> -> Common.Application() & Out,id:U32,carry:Carry<Out>,world:F.World()) -> Outcome<Out>:
  match world:
    case W.World{+namespace,next,high,live,capacity,depth,store,resource,events,pending,+registrations,nextSystem,clock}:built(~Out,~read,W.World{namespace,next,high,live,capacity,depth,store,resource,events,pending,registrations,nextSystem,clock},Sch.build(~F.S,~F.Store(),~F.Resources(),~F.Events(),~Carry<Out>,namespace,"RegisteredEventReader",[Sch.System{id,0}],ids(registrations),carry))
def folded(~Out:Type,~read:Common.Application() -> Array<U32> -> Common.Application() & Out,index:Nat,schema:Schema.Schema<F.S,F.Store(),F.Resources()>,family:Events.State(),tick:Nat,recipe:Recipe.Recipe<F.World(),B.Rows4(),B.observe4()>,debug:Bool,args:Array<U32>,world:F.World(),result:B.Owners4() & List<&2,Records.Fields<F.S>>) -> Outcome<Out>:
  match result:
    case (owners,fields):cataloged(~Out,~read,selected(index,fields),Carry{schema,family,tick,owners,recipe,debug,Some{args},None{}},world)
def run(~Out:Type,~read:Common.Application() -> Array<U32> -> Common.Application() & Out,index:Nat,app:Common.Application(),args:Array<U32>) -> Outcome<Out>:
  match app:
    case App.Application{schema,Route.Runtime{world,family,tick},owners,recipe,debug}:folded(~Out,~read,index,schema,family,tick,recipe,debug,args,world,B.fold4()(owners))
