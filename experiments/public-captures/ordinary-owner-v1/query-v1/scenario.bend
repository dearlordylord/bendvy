import Base
import ./fixture.bend as F
import ./observe.bend as Obs
import ../payload.bend as P
import ../../../../src/ecs/ordinary-capture-query.bend as O
import ../../../../src/ecs/column.bend as Col
import ../../../../src/ecs/world.bend as W
import ../../../../src/ecs/compose.bend as Q

type State<S:Data> is Type:
  State{world:W.World<S,Col.Column<S,U32>,Unit,Unit>,foreign:W.World<S,Col.Column<S,U32>,Unit,Unit>,owner:F.Owned(S),twin:F.Owned(S),text:String}
def result(value:Result<Q.Error<F.Error>,List<&2,U32>>) -> String:
  match value:
    case Done{values}:"success:" ++ List.show(~&2,~U32,~U32.show,values)
    case Fail{Q.UserError{F.FailedAt{value}}}:"failure:" ++ U32.show(value)
    case Fail{Q.UserError{F.Missing{}}}:"failure:Missing"
    case Fail{Q.AccessError{W.MissingEntity{}}}:"failure:MissingEntity"
    case Fail{Q.AccessError{W.CapacityExceeded{}}}:"failure:CapacityExceeded"
    case Fail{Q.AccessError{W.NamespaceExhausted{}}}:"failure:NamespaceExhausted"
    case Fail{Q.AccessError{W.SystemIdExhausted{}}}:"failure:SystemIdExhausted"
def snapshot_done(~S:Data,label:String,old:String,a:W.World<S,Col.Column<S,U32>,Unit,Unit> & String,b:W.World<S,Col.Column<S,U32>,Unit,Unit> & String,c:F.Owned(S) & String,d:F.Owned(S) & String) -> State<S>:
  match a b c d:
    case (world,wt), (foreign,ft), (owner,ot), (twin,tt):State{world,foreign,owner,twin,old ++ label ++ "|" ++ wt ++ "|" ++ ft ++ "|" ++ ot ++ "|" ++ tt ++ "\n"}
def snapshot(~S:Data,label:String,state:State<S>) -> State<S>:
  match state:
    case State{world,foreign,owner,twin,text}:snapshot_done(~S,label,text,Obs.world(~S,world),Obs.world(~S,foreign),Obs.owner(~S,owner),Obs.owner(~S,twin))
def run_done(~S:Data,label:String,foreign:W.World<S,Col.Column<S,U32>,Unit,Unit>,twin:F.Owned(S),text:String,step:O.Run<W.World<S,Col.Column<S,U32>,Unit,Unit>,F.Owned(S),F.Args,Q.Error<F.Error>,U32>) -> State<S>:
  match step:
    case O.Completed{world,owner,value}:snapshot(~S,label ++ ":" ++ result(value),State{world,foreign,owner,twin,text})
    case O.Refused{world,owner,F.Args{d,f}}:snapshot(~S,label ++ ":refused:" ++ U32.show(d) ++ ":" ++ U32.show(f),State{world,foreign,owner,twin,text})
def run(~S:Data,label:String,args:F.Args,state:State<S>) -> State<S>:
  match state:
    case State{world,foreign,owner,twin,text}:run_done(~S,label,foreign,twin,text,F.run(~S,owner,world,args))
def populated(~S:Data,state:State<S>) -> State<S>:
  match state:
    case State{world,foreign,owner,twin,text}:snapshot(~S,"populated",State{F.populate(~S,F.populate(~S,F.spawn(~S,F.spawn(~S,F.spawn(~S,world))),1,10),2,20),foreign,owner,twin,text})
def changed(~S:Data,state:State<S>) -> State<S>:
  match state:
    case State{world,foreign,owner,twin,text}:snapshot(~S,"external",State{F.populate(~S,world,1,30),foreign,owner,twin,text})
def skipped_done(~S:Data,foreign:W.World<S,Col.Column<S,U32>,Unit,Unit>,twin:F.Owned(S),text:String,returned:F.Owned(S) & W.World<S,Col.Column<S,U32>,Unit,Unit>) -> State<S>:
  (owner,world) = returned
  snapshot(~S,"skip",State{world,foreign,owner,twin,text})
def skip(~S:Data,state:State<S>) -> State<S>:
  match state:
    case State{world,foreign,owner,twin,text}:skipped_done(~S,foreign,twin,text,O.skip(~S,~Col.Column<S,U32>,~Unit,~Unit,~P.Pack,~F.Ops,~F.Args,~F.Error,~U32,~F.query(~S),~F.body,owner,world))
def foreign_done(~S:Data,world:W.World<S,Col.Column<S,U32>,Unit,Unit>,twin:F.Owned(S),text:String,returned:O.Run<W.World<S,Col.Column<S,U32>,Unit,Unit>,F.Owned(S),F.Args,Q.Error<F.Error>,U32>) -> State<S>:
  match returned:
    case O.Refused{foreign,owner,F.Args{d,f}}:snapshot(~S,"foreign-refused:" ++ U32.show(d) ++ ":" ++ U32.show(f),State{world,foreign,owner,twin,text})
    case O.Completed{foreign,owner,value}:snapshot(~S,"BUG:foreign-entered:" ++ result(value),State{world,foreign,owner,twin,text})
def foreign_run(~S:Data,state:State<S>) -> State<S>:
  match state:
    case State{world,foreign,owner,twin,text}:foreign_done(~S,world,twin,text,F.run(~S,owner,foreign,F.Args{99,0}))
def finished(~S:Data,old:String,a:W.World<S,Col.Column<S,U32>,Unit,Unit> & String,b:W.World<S,Col.Column<S,U32>,Unit,Unit> & String,c:P.Pack & P.Observation,d:P.Pack & P.Observation) -> String:
  match a b c d:
    case (_,wt), (_,ft), (_,x), (_,y):old ++ "removed|" ++ wt ++ "|" ++ ft ++ "|" ++ Obs.pack(x) ++ "|" ++ Obs.pack(y) ++ "\n"
def removed_twin(~S:Data,world:W.World<S,Col.Column<S,U32>,Unit,Unit>,pack:P.Pack,text:String,returned:O.Removal<W.World<S,Col.Column<S,U32>,Unit,Unit>,F.Owned(S),P.Pack>) -> String:
  match returned:
    case O.Removed{foreign,other}:finished(~S,text,Obs.world(~S,world),Obs.world(~S,foreign),P.project(pack),P.project(other))
    case _:text ++ "BUG:twin-removal\n"
def removed(~S:Data,foreign:W.World<S,Col.Column<S,U32>,Unit,Unit>,twin:F.Owned(S),text:String,returned:O.Removal<W.World<S,Col.Column<S,U32>,Unit,Unit>,F.Owned(S),P.Pack>) -> String:
  match returned:
    case O.Removed{world,pack}:removed_twin(~S,world,pack,text,O.unregister(~S,~Col.Column<S,U32>,~Unit,~Unit,~P.Pack,~F.Ops,~F.Args,~F.Error,~U32,~F.query(~S),~F.body,twin,foreign))
    case _:text ++ "BUG:removal\n"
def finish(~S:Data,state:State<S>) -> String:
  match state:
    case State{world,foreign,owner,twin,text}:removed(~S,foreign,twin,text,O.unregister(~S,~Col.Column<S,U32>,~Unit,~Unit,~P.Pack,~F.Ops,~F.Args,~F.Error,~U32,~F.query(~S),~F.body,owner,world))
def sequence(~S:Data,state:State<S>) -> String:
  finish(~S,foreign_run(~S,skip(~S,run(~S,"changed-one",F.Args{3,0},changed(~S,run(~S,"no-changes",F.Args{9,0},run(~S,"retry",F.Args{2,0},run(~S,"late-failure",F.Args{1,20},populated(~S,run(~S,"empty",F.Args{1,0},snapshot(~S,"registered",state)))))))))))
def twin_defined(~S:Data,world:W.World<S,Col.Column<S,U32>,Unit,Unit>,owner:F.Owned(S),registration:O.Registration<W.World<S,Col.Column<S,U32>,Unit,Unit>,F.Owned(S),P.Pack>) -> String:
  match registration:
    case O.Registered{foreign,twin}:sequence(~S,State{world,foreign,owner,twin,""})
    case _:"BUG:twin-registration"
def defined(~S:Data,foreign:W.World<S,Col.Column<S,U32>,Unit,Unit>,registration:O.Registration<W.World<S,Col.Column<S,U32>,Unit,Unit>,F.Owned(S),P.Pack>) -> String:
  match registration:
    case O.Registered{world,owner}:twin_defined(~S,world,owner,F.define(~S,foreign))
    case _:"BUG:registration"
def start(~S:Data,world:W.World<S,Col.Column<S,U32>,Unit,Unit>,foreign:W.World<S,Col.Column<S,U32>,Unit,Unit>) -> String:
  defined(~S,foreign,F.define(~S,world))
