import Base
import fixture-state.bend as State
import fixture-consumer.bend as C
import fixture-registration.bend as Reg
import fixture-operations.bend as Op
import fixture-dump.bend as Dump
import machine-requirements.bend as Req
import root-source/transaction.bend as Tx
import root-source/world.bend as W
import root-source/inspector.bend as I
import root-source/system.bend as Sys
import root-source/schedule.bend as Sch
import root-source/machine.bend as M
import root-source/machine-stream.bend as St

type Record<S:Data> is Data:
  Record{label:String,values:C.Values<S>,inspections:U32,world:String,inspector:String,system:String}
type Session<S:Data> is Type:
  Session{world:W.World<S,State.Store<S>,State.Resources<S>,U32>,instance:I.Instance<S>,holder:C.Holder<S>,inspections:U32,records:List<&2,Record<S>>,errors:List<&2,String>}
type Step is Data:
  Point{label:String,ordinary:Bool}
  Queue{flow:U32,level:U32,failed:Bool}
  Barrier{}
  Marker{}
  Gate{condition:U32}
type Output<S:Data> is Type:
  Completed{factory:W.Factory,app:Session<S>}
  CreationRefused{factory:W.Factory,resources:State.Resources<S>}
  RegistrationRefused{factory:W.Factory,world:W.World<S,State.Store<S>,State.Resources<S>,U32>}
def registry_dump(~S:Data,holder:C.Holder<S>) -> C.Holder<S> & String:
  match holder:
    case C.Holder{Sys.Registry{+ns,+id,+name,+access,+cursor}}:(C.Holder{Sys.Registry{ns,id,name,access,cursor}},U32.show(ns) ++ ":" ++ U32.show(id) ++ ":" ++ name ++ ":" ++ List.show(&2,String,x => x,access) ++ ":" ++ U32.show(cursor))
def instance_dump(~S:Data,instance:I.Instance<S>) -> I.Instance<S> & String:
  match instance:
    case I.Fresh{}:(I.Fresh{},"fresh")
    case I.Active{+cursor,+registeredAt}:(I.Active{cursor,registeredAt},U32.show(cursor) ++ ":" ++ U32.show(registeredAt))
def point_registry(~S:Data,label:String,value:C.Values<S>,world:W.World<S,State.Store<S>,State.Resources<S>,U32>,worldText:String,instance:I.Instance<S>,instanceText:String,+inspections:U32,records:List<&2,Record<S>>,errors:List<&2,String>,result:C.Holder<S> & String) -> Session<S>:
  (holder,text)=result
  Session{world,instance,holder,inspections,List.append(&2,Record<S>,records,[Record{label,value,inspections,worldText,instanceText,text}]),errors}
def point_instance(~S:Data,label:String,value:C.Values<S>,world:W.World<S,State.Store<S>,State.Resources<S>,U32>,worldText:String,holder:C.Holder<S>,inspections:U32,records:List<&2,Record<S>>,errors:List<&2,String>,result:I.Instance<S> & String) -> Session<S>:
  (instance,text)=result
  point_registry(~S,label,value,world,worldText,instance,text,inspections,records,errors,registry_dump(~S,holder))
def point_dumped(~S:Data,label:String,value:C.Values<S>,instance:I.Instance<S>,holder:C.Holder<S>,inspections:U32,records:List<&2,Record<S>>,errors:List<&2,String>,result:W.World<S,State.Store<S>,State.Resources<S>,U32> & String) -> Session<S>:
  (world,text)=result
  point_instance(~S,label,value,world,text,holder,inspections,records,errors,instance_dump(~S,instance))
def inspected(~S:Data,label:String,holder:C.Holder<S>,inspections:U32,records:List<&2,Record<S>>,errors:List<&2,String>,observed:I.Observed<S,State.Store<S>,State.Resources<S>,U32,String,C.Values<S>>) -> Session<S>:
  match observed:
    case I.Observed{world,instance,Done{value}}:point_dumped(~S,label,value,instance,holder,(inspections+1:U32),records,errors,Dump.world(~S,world))
    case I.Observed{world,instance,Fail{error}}:Session{world,instance,holder,inspections,records,error <> errors}
def outside_read(~S:Data,label:String,instance:I.Instance<S>,holder:C.Holder<S>,inspections:U32,records:List<&2,Record<S>>,errors:List<&2,String>,result:I.Frame<S,State.Store<S>,State.Resources<S>,U32> & C.Values<S>) -> Session<S>:
  match result:
    case (I.Frame{world,_},value):point_dumped(~S,label,value,instance,holder,inspections,records,errors,Dump.world(~S,world))
def point(~S:Data,label:String,ordinary:Bool,app:Session<S>) -> Session<S>:
  match ordinary app:
    case True{} Session{world,instance,holder,inspections,records,errors}:inspected(~S,label,holder,inspections,records,errors,C.inspect(~S,instance,world))
    case False{} Session{world,instance,holder,inspections,records,errors}:outside_read(~S,label,instance,holder,inspections,records,errors,C.values(~I.Frame<S,State.Store<S>,State.Resources<S>,U32>,~S,~C.reads(~S),I.Frame{world,0}))
def queued(~S:Data,instance:I.Instance<S>,holder:C.Holder<S>,inspections:U32,records:List<&2,Record<S>>,errors:List<&2,String>,result:Tx.Returned<W.World<S,State.Store<S>,State.Resources<S>,U32>,String>) -> Session<S>:
  match result:
    case Tx.Returned{world,_}:Session{world,instance,holder,inspections,records,errors}
def gate_finished(~S:Data,instance:I.Instance<S>,inspections:U32,records:List<&2,Record<S>>,errors:List<&2,String>,result:Sch.RunResult<S,State.Store<S>,State.Resources<S>,U32,C.Holder<S>,String>) -> Session<S>:
  match result:
    case Sch.Finished{Sch.Schedule{_,_,_,holder},world,_}:Session{world,instance,holder,inspections,records,errors}
    case Sch.Failed{Sch.Schedule{_,_,_,holder},world,error,_}:Session{world,instance,holder,inspections,records,error <> errors}
    case Sch.Rejected{Sch.Schedule{_,_,_,holder},world}:Session{world,instance,holder,inspections,records,"schedule-rejected" <> errors}
def gated(~S:Data,instance:I.Instance<S>,inspections:U32,records:List<&2,Record<S>>,errors:List<&2,String>,result:Reg.BuiltGate<S>) -> Session<S>:
  match result:
    case Reg.Ran{result}:gate_finished(~S,instance,inspections,records,errors,result)
    case Reg.Invalid{world,holder}:Session{world,instance,holder,inspections,records,"build-invalid" <> errors}
def step(~S:Data,step:Step,app:Session<S>) -> Session<S>:
  match step app:
    case Point{label,ordinary} app:point(~S,label,ordinary,app)
    case Queue{flow,level,failed} Session{world,instance,holder,inspections,records,errors}:queued(~S,instance,holder,inspections,records,errors,Op.finish(~S,Op.queue(~S,world,flow,level),failed))
    case Barrier{} Session{world,instance,holder,inspections,records,errors}:Session{W.barrier(~S,~State.Store<S>,~State.Resources<S>,~U32,world),instance,holder,inspections,records,errors}
    case Marker{} Session{world,instance,holder,inspections,records,errors}:Session{Op.marker(~S,world),instance,holder,inspections,records,errors}
    case Gate{condition} Session{world,instance,holder,inspections,records,errors}:gated(~S,instance,inspections,records,errors,Reg.gate(~S,world,holder,condition))
def steps(~S:Data,remaining:List<&2,Step>,app:Session<S>) -> Session<S>:
  match remaining:
    case []:app
    case head <> rest:steps(~S,rest,step(~S,head,app))
def timeline() -> List<&2,Step>:
  [Point{"initial",True{}},Point{"repeat",True{}},Queue{1,11,False{}},Point{"queued",True{}},Barrier{},Point{"structural-barrier",True{}},Marker{},Point{"marker",True{}},Gate{0},Point{"check-false",False{}},Gate{1},Point{"check-true",False{}},Queue{2,12,True{}},Marker{},Point{"failed-next-rollback",True{}}]
def registered(~S:Data,factory:W.Factory,result:Reg.GateResult<S>) -> Output<S>:
  match result:
    case Reg.Registered{Sys.Registered{world,registry}}:Completed{factory,steps(~S,timeline(),Session{world,I.Fresh{},C.Holder{registry},0,[],[]})}
    case Reg.Registered{Sys.RegistrationFailed{world}}:RegistrationRefused{factory,world}
def created(~S:Data,result:W.Creation<S,State.Store<S>,State.Resources<S>,U32>) -> Output<S>:
  match result:
    case W.Created{factory,world}:registered(~S,factory,Reg.register(~S,world))
    case W.CreateRejected{factory,resources}:CreationRefused{factory,resources}
def empty_store(~S:Data,args:Unit) -> State.Store<S>:
  State.Store{Array.set(U32,Array.set(U32,Array.new(U32,1n,0),0,7),1,17)}
def resources(~S:Data) -> State.Resources<S>:
  State.Resources{Array.set(U32,Array.set(U32,Array.new(U32,1n,0),0,3),1,13),M.Present{0,M.NoPending{},None{},False{}},M.Present{10,M.NoPending{},None{},False{}},0,St.empty(~U32),St.empty(~U32)}
def run(~S:Data) -> Output<S>:
  created(~S,W.create(~S,~State.Store<S>,~State.Resources<S>,~U32,~empty_store(~S),W.factory(),resources(~S)))
def workshop() -> Output<State.Workshop>:
  run(~State.Workshop)
def garden() -> Output<State.Garden>:
  run(~State.Garden)
