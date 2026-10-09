import Base
import schema-families.bend as D
import runtime-owners.bend as Owners
import check-execution.bend as QueryCheck
import world-observer.bend as Dump
import ../../../../../src/ecs/world.bend as W
import ../../../../../src/ecs/check.bend as Check
import ../../../../../src/ecs/string-equality.bend as SE

# All preload and record writes are diagnostic driver operations OUTSIDE Check.run.
def preload_resource(~S:Data,targets:List<&2,W.Handle<S>>,record:String,resource:Owners.Resource<S>) -> Owners.Resource<S> & Unit:
  match resource:
    case Owners.Resource{cells,extra,_}:(Owners.Resource{cells,extra,Owners.Diagnostic{targets,record,"","",False{},False{},0,0}},Unit{})
def preload(~S:Data,targets:List<&2,W.Handle<S>>,record:String,world:W.World<S,D.Store<S>,Owners.Resource<S>,U32>) -> W.World<S,D.Store<S>,Owners.Resource<S>,U32> & Unit:
  match world:
    case W.World{namespace,nextId,highWater,live,capacity,depth,store,resource,events,pending,registrations,nextSystemId,clock}:W.observe_resource_finish(~S,~D.Store<S>,~Owners.Resource<S>,~U32,~Unit,preload_resource(~S,targets,record,resource),namespace,nextId,highWater,live,capacity,depth,store,events,pending,registrations,nextSystemId,clock)
def diagnostic(~S:Data,resource:Owners.Resource<S>) -> Owners.Resource<S> & Owners.Diagnostic<S>:
  match resource:
    case Owners.Resource{cells,extra,+state}:(Owners.Resource{cells,extra,state},state)
def record_resource(~S:Data,+before:String,+after:String,+allowed:Bool,resource:Owners.Resource<S>) -> Owners.Resource<S> & Bool:
  match resource:
    case Owners.Resource{cells,extra,Owners.Diagnostic{targets,record,_,_,_,_,+checks,ran}}:(Owners.Resource{cells,extra,Owners.Diagnostic{targets,record,before,after,SE.equal(before,after),allowed,(checks + 1 : U32),ran}},Bool.and(SE.equal(before,after),allowed))
def record(~S:Data,before:String,after:String,allowed:Bool,world:W.World<S,D.Store<S>,Owners.Resource<S>,U32>) -> W.World<S,D.Store<S>,Owners.Resource<S>,U32> & Bool:
  match world:
    case W.World{namespace,nextId,highWater,live,capacity,depth,store,resource,events,pending,registrations,nextSystemId,clock}:W.observe_resource_finish(~S,~D.Store<S>,~Owners.Resource<S>,~U32,~Bool,record_resource(~S,before,after,allowed,resource),namespace,nextId,highWater,live,capacity,depth,store,events,pending,registrations,nextSystemId,clock)
def after(~S:Data,before:String,allowed:Bool,observed:W.World<S,D.Store<S>,Owners.Resource<S>,U32> & String) -> W.World<S,D.Store<S>,Owners.Resource<S>,U32> & Bool:
  (world,current)=observed
  record(~S,before,current,allowed,world)
def checked(~S:Data,before:String,value:Check.Checked<S,D.Store<S>,Owners.Resource<S>,U32>) -> W.World<S,D.Store<S>,Owners.Resource<S>,U32> & Bool:
  match value:
    case Check.Checked{world,Done{allowed}}:after(~S,before,allowed,Dump.world(~S,world))
    case Check.Checked{world,Fail{_}}:after(~S,before,False{},Dump.world(~S,world))
def prepared(~S:Data,kind:QueryCheck.CheckKind,args:QueryCheck.Args<S>,observed:W.World<S,D.Store<S>,Owners.Resource<S>,U32> & String) -> W.World<S,D.Store<S>,Owners.Resource<S>,U32> & Bool:
  (world,before)=observed
  checked(~S,before,QueryCheck.run(~S,kind,args,world))
def read(~S:Data,kind:QueryCheck.CheckKind,observed:W.World<S,D.Store<S>,Owners.Resource<S>,U32> & Owners.Diagnostic<S>) -> W.World<S,D.Store<S>,Owners.Resource<S>,U32> & Bool:
  match observed:
    case (world,Owners.Diagnostic{targets,record,_,_,_,_,_,_}):prepared(~S,kind,QueryCheck.Args{targets,record},Dump.world(~S,world))
def condition_kind(~S:Data,kind:QueryCheck.CheckKind,world:W.World<S,D.Store<S>,Owners.Resource<S>,U32>) -> W.World<S,D.Store<S>,Owners.Resource<S>,U32> & Bool:
  read(~S,kind,W.observe_resource(~S,~D.Store<S>,~Owners.Resource<S>,~U32,~Owners.Diagnostic<S>,~diagnostic(~S),world))
def condition(~S:Data,world:W.World<S,D.Store<S>,Owners.Resource<S>,U32>,key:U32) -> W.World<S,D.Store<S>,Owners.Resource<S>,U32> & Bool:
  match key:
    case 0:condition_kind(~S,QueryCheck.CheckEmpty{},world)
    case 1:condition_kind(~S,QueryCheck.CheckOptionalFour{},world)
    case 2:condition_kind(~S,QueryCheck.CheckRequiredPair{},world)
    case 3:condition_kind(~S,QueryCheck.CheckFiveAlias{},world)
    case 4:condition_kind(~S,QueryCheck.CheckWithWithout{},world)
    case 5:condition_kind(~S,QueryCheck.CheckMultipleWith{},world)
    case 6:condition_kind(~S,QueryCheck.CheckMultipleWithout{},world)
    case 7:condition_kind(~S,QueryCheck.CheckRepeated{},world)
    case 8:condition_kind(~S,QueryCheck.CheckContradictory{},world)
    case _:(world,False{})
# Invalid diagnostic schedule keys preserve World and DO NOT call Check.run.
def workshop(world:W.World<D.Workshop,D.Store<D.Workshop>,Owners.Resource<D.Workshop>,U32>,key:U32) -> W.World<D.Workshop,D.Store<D.Workshop>,Owners.Resource<D.Workshop>,U32> & Bool:
  condition(~D.Workshop,world,key)
def garden(world:W.World<D.Garden,D.Store<D.Garden>,Owners.Resource<D.Garden>,U32>,key:U32) -> W.World<D.Garden,D.Store<D.Garden>,Owners.Resource<D.Garden>,U32> & Bool:
  condition(~D.Garden,world,key)
def main() -> Unit:
  Unit{}
