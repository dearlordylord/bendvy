import Base
import ../payload.bend as P
import ../system.bend as Sys
import ../scenario.bend as Old
import ../format.bend as F
import ./schedule.bend as Run
import ../../../../src/ecs/world.bend as W
import ../../../../src/ecs/world-io.bend as WI
import ../../../../src/ecs/local.bend as L
import ../../../../src/ecs/captures.bend as Capture
import ../../../../src/ecs/ordinary-app-local-fields.bend as Ord

type Workshop is Data:
  Workshop{}
type Garden is Data:
  Garden{}
type Session<S:Data> is Type:
  Session{state:Old.State<S>,twin:L.Instance<S,Unit,U32,Unit,P.Pack,Sys.Args,Sys.Error,Unit,Ord.runner(~S,~Unit,~U32,~Unit,~P.Pack,~Sys.Args,~Sys.Error,~Unit,~Sys.Ops,~Sys.declaration(~S),~Sys.body)>,log:String}
def captured(~S:Data,twin:L.Instance<S,Unit,U32,Unit,P.Pack,Sys.Args,Sys.Error,Unit,Ord.runner(~S,~Unit,~U32,~Unit,~P.Pack,~Sys.Args,~Sys.Error,~Unit,~Sys.Ops,~Sys.declaration(~S),~Sys.body)>,log:String,label:String,result:Run.Scheduled<S>) -> Session<S>:
  match result:
    case Run.Scheduled{state,observations}:Session{state,twin,log ++ label ++ "=" ++ observations ++ "\n"}
def cycle(~S:Data,+label:String,code:U32,args:Sys.Args,session:Session<S>) -> Session<S>:
  match session:
    case Session{state,twin,log}:captured(~S,twin,log,label,Run.run(~S,label,code,args,state))
def foreign_run(~S:Data,session:Session<S>) -> Session<S>:
  match session:
    case Session{state,twin,log}:Session{Old.foreign_run(~S,state),twin,log}
def final_worlds(~S:Data,text:String,a:W.World<S,Unit,U32,Unit> & Old.WorldView,b:W.World<S,Unit,U32,Unit> & Old.WorldView) -> String:
  match a b:
    case (_,w), (_,f):text ++ "final-worlds|" ++ F.world(w) ++ "|" ++ F.world(f) ++ "\n"
def final_pack(~S:Data,world:W.World<S,Unit,U32,Unit>,foreign:W.World<S,Unit,U32,Unit>,text:String,result:P.Pack & P.Observation) -> String:
  (pack,view) = result
  final_worlds(~S,text ++ "twin-returned|" ++ F.pack(view) ++ "\n",Old.world_view(~S,world),Old.world_view(~S,foreign))
def final_twin(~S:Data,world:W.World<S,Unit,U32,Unit>,text:String,result:L.Disposal<S,Unit,U32,Unit,P.Pack,Sys.Args,Sys.Error,Unit,Ord.runner(~S,~Unit,~U32,~Unit,~P.Pack,~Sys.Args,~Sys.Error,~Unit,~Sys.Ops,~Sys.declaration(~S),~Sys.body),P.Pack>) -> String:
  match result:
    case L.Disposed{foreign,pack}:final_pack(~S,world,foreign,text,P.project(pack))
    case _:text ++ "TWIN_UNREGISTER_FAILED\n"
def second_pack(~S:Data,world:W.World<S,Unit,U32,Unit>,foreign:W.World<S,Unit,U32,Unit>,twin:L.Instance<S,Unit,U32,Unit,P.Pack,Sys.Args,Sys.Error,Unit,Ord.runner(~S,~Unit,~U32,~Unit,~P.Pack,~Sys.Args,~Sys.Error,~Unit,~Sys.Ops,~Sys.declaration(~S),~Sys.body)>,text:String,result:P.Pack & P.Observation) -> String:
  (pack,view) = result
  final_twin(~S,world,text ++ "second-returned|" ++ F.pack(view) ++ "\n",Capture.unregister(~S,~Unit,~U32,~Unit,~P.Pack,~Sys.Args,~Sys.Error,~Unit,~Ord.runner(~S,~Unit,~U32,~Unit,~P.Pack,~Sys.Args,~Sys.Error,~Unit,~Sys.Ops,~Sys.declaration(~S),~Sys.body),twin,foreign))
def second_removed(~S:Data,foreign:W.World<S,Unit,U32,Unit>,twin:L.Instance<S,Unit,U32,Unit,P.Pack,Sys.Args,Sys.Error,Unit,Ord.runner(~S,~Unit,~U32,~Unit,~P.Pack,~Sys.Args,~Sys.Error,~Unit,~Sys.Ops,~Sys.declaration(~S),~Sys.body)>,text:String,result:L.Disposal<S,Unit,U32,Unit,P.Pack,Sys.Args,Sys.Error,Unit,Ord.runner(~S,~Unit,~U32,~Unit,~P.Pack,~Sys.Args,~Sys.Error,~Unit,~Sys.Ops,~Sys.declaration(~S),~Sys.body),P.Pack>) -> String:
  match result:
    case L.Disposed{world,pack}:second_pack(~S,world,foreign,twin,text,P.project(pack))
    case _:text ++ "SECOND_UNREGISTER_FAILED\n"
def first_pack(~S:Data,world:W.World<S,Unit,U32,Unit>,foreign:W.World<S,Unit,U32,Unit>,second:L.Instance<S,Unit,U32,Unit,P.Pack,Sys.Args,Sys.Error,Unit,Ord.runner(~S,~Unit,~U32,~Unit,~P.Pack,~Sys.Args,~Sys.Error,~Unit,~Sys.Ops,~Sys.declaration(~S),~Sys.body)>,twin:L.Instance<S,Unit,U32,Unit,P.Pack,Sys.Args,Sys.Error,Unit,Ord.runner(~S,~Unit,~U32,~Unit,~P.Pack,~Sys.Args,~Sys.Error,~Unit,~Sys.Ops,~Sys.declaration(~S),~Sys.body)>,text:String,result:P.Pack & P.Observation) -> String:
  (pack,view) = result
  second_removed(~S,foreign,twin,text ++ "first-returned|" ++ F.pack(view) ++ "\n",Capture.unregister(~S,~Unit,~U32,~Unit,~P.Pack,~Sys.Args,~Sys.Error,~Unit,~Ord.runner(~S,~Unit,~U32,~Unit,~P.Pack,~Sys.Args,~Sys.Error,~Unit,~Sys.Ops,~Sys.declaration(~S),~Sys.body),second,world))
def first_removed(~S:Data,foreign:W.World<S,Unit,U32,Unit>,second:L.Instance<S,Unit,U32,Unit,P.Pack,Sys.Args,Sys.Error,Unit,Ord.runner(~S,~Unit,~U32,~Unit,~P.Pack,~Sys.Args,~Sys.Error,~Unit,~Sys.Ops,~Sys.declaration(~S),~Sys.body)>,twin:L.Instance<S,Unit,U32,Unit,P.Pack,Sys.Args,Sys.Error,Unit,Ord.runner(~S,~Unit,~U32,~Unit,~P.Pack,~Sys.Args,~Sys.Error,~Unit,~Sys.Ops,~Sys.declaration(~S),~Sys.body)>,text:String,result:L.Disposal<S,Unit,U32,Unit,P.Pack,Sys.Args,Sys.Error,Unit,Ord.runner(~S,~Unit,~U32,~Unit,~P.Pack,~Sys.Args,~Sys.Error,~Unit,~Sys.Ops,~Sys.declaration(~S),~Sys.body),P.Pack>) -> String:
  match result:
    case L.Disposed{world,pack}:first_pack(~S,world,foreign,second,twin,text,P.project(pack))
    case _:text ++ "FIRST_UNREGISTER_FAILED\n"
def finish(~S:Data,session:Session<S>) -> String:
  match session:
    case Session{Old.State{world,foreign,first,second,trace},twin,log}:first_removed(~S,foreign,second,twin,log ++ F.trace(trace),Capture.unregister(~S,~Unit,~U32,~Unit,~P.Pack,~Sys.Args,~Sys.Error,~Unit,~Ord.runner(~S,~Unit,~U32,~Unit,~P.Pack,~Sys.Args,~Sys.Error,~Unit,~Sys.Ops,~Sys.declaration(~S),~Sys.body),first,world))
def foreign_removed(~S:Data,world:W.World<S,Unit,U32,Unit>,second:L.Instance<S,Unit,U32,Unit,P.Pack,Sys.Args,Sys.Error,Unit,Ord.runner(~S,~Unit,~U32,~Unit,~P.Pack,~Sys.Args,~Sys.Error,~Unit,~Sys.Ops,~Sys.declaration(~S),~Sys.body)>,twin:L.Instance<S,Unit,U32,Unit,P.Pack,Sys.Args,Sys.Error,Unit,Ord.runner(~S,~Unit,~U32,~Unit,~P.Pack,~Sys.Args,~Sys.Error,~Unit,~Sys.Ops,~Sys.declaration(~S),~Sys.body)>,trace:List<&2,Old.Snapshot>,log:String,result:L.Disposal<S,Unit,U32,Unit,P.Pack,Sys.Args,Sys.Error,Unit,Ord.runner(~S,~Unit,~U32,~Unit,~P.Pack,~Sys.Args,~Sys.Error,~Unit,~Sys.Ops,~Sys.declaration(~S),~Sys.body),P.Pack>) -> String:
  match result:
    case L.DisposalRejected{foreign,first}:finish(~S,Session{Old.snapshot(~S,"foreign-unregister-refused",Old.Skipped{},Old.State{world,foreign,first,second,trace}),twin,log ++ "unregister=Refused\n"})
    case L.Disposed{foreign,pack}:log ++ "UNREGISTER_ACCEPTED_BUG"
def foreign_unregister(~S:Data,session:Session<S>) -> String:
  match session:
    case Session{Old.State{world,foreign,first,second,trace},twin,log}:foreign_removed(~S,world,second,twin,trace,log,Capture.unregister(~S,~Unit,~U32,~Unit,~P.Pack,~Sys.Args,~Sys.Error,~Unit,~Ord.runner(~S,~Unit,~U32,~Unit,~P.Pack,~Sys.Args,~Sys.Error,~Unit,~Sys.Ops,~Sys.declaration(~S),~Sys.body),first,foreign))
def swapped(~S:Data,session:Session<S>) -> Session<S>:
  match session:
    case Session{state,twin,log}:Session{Old.swap(~S,state),twin,log}
def scenario(~S:Data,session:Session<S>) -> String:
  session = cycle(~S,"scheduled-success",0,Sys.Args{1,False{}},session)
  session = swapped(~S,cycle(~S,"second-success",0,Sys.Args{10,False{}},swapped(~S,session)))
  session = cycle(~S,"scheduled-skip",1,Sys.Args{999,False{}},session)
  session = cycle(~S,"scheduled-failure",0,Sys.Args{2,True{}},session)
  session = cycle(~S,"scheduled-retry",0,Sys.Args{3,False{}},session)
  session = swapped(~S,cycle(~S,"second-repeat",0,Sys.Args{20,False{}},swapped(~S,session)))
  session = foreign_run(~S,session)
  foreign_unregister(~S,session)
def twin_observed(~S:Data,state:Old.State<S>,result:L.Instance<S,Unit,U32,Unit,P.Pack,Sys.Args,Sys.Error,Unit,Ord.runner(~S,~Unit,~U32,~Unit,~P.Pack,~Sys.Args,~Sys.Error,~Unit,~Sys.Ops,~Sys.declaration(~S),~Sys.body)> & Old.OwnerView) -> String:
  (twin,view) = result
  scenario(~S,Session{Old.snapshot(~S,"registered",Old.Registered{},state),twin,"twin-initial|" ++ F.owner(view) ++ "\n"})
def second_registered(~S:Data,foreign:W.World<S,Unit,U32,Unit>,twin:L.Instance<S,Unit,U32,Unit,P.Pack,Sys.Args,Sys.Error,Unit,Ord.runner(~S,~Unit,~U32,~Unit,~P.Pack,~Sys.Args,~Sys.Error,~Unit,~Sys.Ops,~Sys.declaration(~S),~Sys.body)>,first:L.Instance<S,Unit,U32,Unit,P.Pack,Sys.Args,Sys.Error,Unit,Ord.runner(~S,~Unit,~U32,~Unit,~P.Pack,~Sys.Args,~Sys.Error,~Unit,~Sys.Ops,~Sys.declaration(~S),~Sys.body)>,result:L.Registered<S,Unit,U32,Unit,P.Pack,Sys.Args,Sys.Error,Unit,Ord.runner(~S,~Unit,~U32,~Unit,~P.Pack,~Sys.Args,~Sys.Error,~Unit,~Sys.Ops,~Sys.declaration(~S),~Sys.body)>) -> String:
  match result:
    case L.Registered{world,second}:twin_observed(~S,Old.State{world,foreign,first,second,[]},Old.owner_view(~S,twin))
    case _:"SECOND_REGISTER_FAILED"
def first_registered(~S:Data,foreign:W.World<S,Unit,U32,Unit>,twin:L.Instance<S,Unit,U32,Unit,P.Pack,Sys.Args,Sys.Error,Unit,Ord.runner(~S,~Unit,~U32,~Unit,~P.Pack,~Sys.Args,~Sys.Error,~Unit,~Sys.Ops,~Sys.declaration(~S),~Sys.body)>,result:L.Registered<S,Unit,U32,Unit,P.Pack,Sys.Args,Sys.Error,Unit,Ord.runner(~S,~Unit,~U32,~Unit,~P.Pack,~Sys.Args,~Sys.Error,~Unit,~Sys.Ops,~Sys.declaration(~S),~Sys.body)>) -> String:
  match result:
    case L.Registered{world,first}:second_registered(~S,foreign,twin,first,Old.define(~S,world,"second",P.initial(100)))
    case _:"FIRST_REGISTER_FAILED"
def twin_registered(~S:Data,world:W.World<S,Unit,U32,Unit>,result:L.Registered<S,Unit,U32,Unit,P.Pack,Sys.Args,Sys.Error,Unit,Ord.runner(~S,~Unit,~U32,~Unit,~P.Pack,~Sys.Args,~Sys.Error,~Unit,~Sys.Ops,~Sys.declaration(~S),~Sys.body)>) -> String:
  match result:
    case L.Registered{foreign,twin}:first_registered(~S,foreign,twin,Old.define(~S,world,"first",P.initial(1)))
    case _:"TWIN_REGISTER_FAILED"
def empty(unit:Unit) -> Unit:
  Unit{}
def second_world(~S:Data,world:W.World<S,Unit,U32,Unit>,result:WI.Creation<S,Unit,U32,Unit>) -> IO(String):
  match result:
    case WI.Created{foreign}:IO.pure(String,twin_registered(~S,world,Old.define(~S,foreign,"first",P.initial(500))))
    case _:IO.die(String,1,"foreign create failed")
def first_world(~S:Data,result:WI.Creation<S,Unit,U32,Unit>) -> IO(String):
  match result:
    case WI.Created{world}:IO.bind(WI.Creation<S,Unit,U32,Unit>,String,WI.create(~S,~Unit,~U32,~Unit,~empty,900),other => second_world(~S,world,other))
    case _:IO.die(String,1,"create failed")
def schema(~S:Data) -> IO(String):
  IO.bind(WI.Creation<S,Unit,U32,Unit>,String,WI.create(~S,~Unit,~U32,~Unit,~empty,10),first_world(~S))
def printed(a:String,b:String) -> IO(Unit):
  IO.print("Workshop\n" ++ a ++ "Garden\n" ++ b)
def workshop(a:String) -> IO(Unit):
  IO.bind(String,Unit,schema(~Garden),b => printed(a,b))
def main() -> IO(Unit):
  IO.bind(String,Unit,schema(~Workshop),workshop)
