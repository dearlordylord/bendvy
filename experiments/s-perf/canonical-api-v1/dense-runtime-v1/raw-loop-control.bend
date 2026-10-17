import Base
import motion.bend as F
import motion-observe.bend as O
import types.bend as Types
import ../../../../src/ecs/compose.bend as Q
import ../../../../src/ecs/ordinary-system.bend as Ordinary
import ../../../../src/ecs/transaction.bend as T
import ../../../../src/ecs/world.bend as W
import ../../../../src/ecs/entity-key.bend as Key
import ../../../../src/ecs/trace-facts.bend as Trace
import ../../../../src/ecs/deferred-command.bend as Deferred

def outcome(value:T.Outcome<Q.Error<Unit>>) -> String:
  match value:
    case T.Success{}:"Success"
    case T.Failure{Q.UserError{Unit{}}}:"UserFailure"
    case T.Failure{Q.AccessError{error}}:"AccessFailure{" ++ O.error(error) ++ "}"
def body_result(~H:Type,failed:Bool,owner:H,result:T.Outcome<Unit>,value:U32) -> H & (T.Outcome<Unit> & U32):
  match failed:
    case False{}:(owner,(result,value))
    case True{}:(owner,(T.Failure{Unit{}},value))
def body_value(~H:Type,fail:Bool,owner:H,observed:T.Outcome<Unit> & U32) -> H & (T.Outcome<Unit> & U32):
  match observed:
    case (result,+value):body_result(~H,Bool.and(fail,U32.is_eq(value,10)),owner,result,value)
def body_done(~H:Type,fail:Bool,observed:H & (T.Outcome<Unit> & U32)) -> H & (T.Outcome<Unit> & U32):
  match observed:
    case (owner,result):body_value(~H,fail,owner,result)
def body(~H:Type,~caps:F.Ops(H),fail:Bool,owner:H) -> H & (T.Outcome<Unit> & U32):body_done(~H,fail,F.body(~H,~caps,Unit{},owner))
def selected(skip:Bool,frame:Q.Frame<Types.MotionSchema,F.Store(),F.Resources(),Nat>) -> Q.Frame<Types.MotionSchema,F.Store(),F.Resources(),Nat> & Bool:
  match frame:
    case Q.Frame{tx,+handle,error,cursor}:
      match handle:
        case W.Handle{_,Key.EntityKey{index,_}}:(Q.Frame{tx,handle,error,cursor},Bool.not(Bool.and(skip,U32.is_eq(index,2))))
def plan(~skip:Bool) -> Q.Plan<Types.MotionSchema,F.Store(),F.Resources(),Nat,F.Ops>:
  Q.Plan{Q.plan_caps(~Types.MotionSchema,~F.Store(),~F.Resources(),~Nat,~F.Ops,Ordinary.plan(~Types.MotionSchema,~F.Store(),~F.Resources(),~Nat,~F.Ops,~Unit,~Unit,~U32,~F.declaration(),~F.body)),frame=>selected(skip,frame)}
def opaque_count_done(~A:Type,value:A,observed:List<&1,A> & U32) -> List<&1,A> & U32:
  match observed:
    case (rest,count):(value <> rest,U32.add(count,1))
def opaque_count(~A:Type,values:List<&1,A>) -> List<&1,A> & U32:
  match values:
    case []:([],0)
    case value <> rest:opaque_count_done(~A,value,opaque_count(~A,rest))
def raw_world(prefix:String,undo:List<&1,F.World()->F.World()>,commands:List<&1,Deferred.Command<F.World()>>,events:List<&2,Nat>,trace:Trace.State,observed:F.World() & String) -> T.Tx<F.World(),Nat> & String:
  match observed:
    case (world,text):(T.Tx{world,undo,commands,events,trace},prefix ++ text)
def raw_counted(world:F.World(),+events:List<&2,Nat>,+trace:Trace.State,undos:List<&1,F.World()->F.World()> & U32,cmds:List<&1,Deferred.Command<F.World()>> & U32) -> T.Tx<F.World(),Nat> & String:
  match undos cmds:
    case (undo,uc), (commands,cc):raw_world("undo=" ++ U32.show(uc) ++ ";commands=" ++ U32.show(cc) ++ ";events=" ++ List.show(&2,Nat,Nat.show,events) ++ ";traceEnabled=" ++ Bool.show(Trace.enabled(trace)) ++ ";world=",undo,commands,events,trace,O.world(world))
def raw_tx(tx:T.Tx<F.World(),Nat>) -> T.Tx<F.World(),Nat> & String:
  match tx:
    case T.Tx{world,undo,commands,+events,+trace}:raw_counted(world,events,trace,opaque_count(~(F.World()->F.World()),undo),opaque_count(~Deferred.Command<F.World()>,commands))
def finished_world(prefix:String,observed:F.World() & String) -> String:
  match observed:
    case (world,text):prefix ++ text ++ "\n"
def finished(prefix:String,observed:Q.Executed<F.World(),Q.Error<Unit>,U32>) -> String:
  match observed:
    case Q.Executed{world,result,values}:finished_world(prefix ++ "finishedOutcome=" ++ outcome(result) ++ ";values=" ++ List.show(&2,U32,U32.show,values) ++ ";world=",O.world(world))
def raw_observed(prefix:String,+result:T.Outcome<Q.Error<Unit>>,+values:List<&2,U32>,observed:T.Tx<F.World(),Nat> & String) -> String:
  match observed:
    case (tx,text):finished(prefix ++ "rawOutcome=" ++ outcome(result) ++ ";values=" ++ List.show(&2,U32,U32.show,values) ++ ";" ++ text ++ "\n",Q.finished(~Types.MotionSchema,~F.Store(),~F.Resources(),~Nat,~Unit,~U32,(tx,(result,values))))
def raw(prefix:String,observed:T.Tx<F.World(),Nat> & (T.Outcome<Q.Error<Unit>> & List<&2,U32>)) -> String:
  match observed:
    case (tx,(result,values)):raw_observed(prefix,result,values,raw_tx(tx))
def choose(empty:Bool,found:List<&2,W.Handle<Types.MotionSchema>>) -> List<&2,W.Handle<Types.MotionSchema>>:
  match empty:
    case True{}:[]
    case False{}:found

def handles(~skip:Bool,name:String,empty:Bool,fail:Bool,observed:F.World() & List<&2,W.Handle<Types.MotionSchema>>) -> String:
  match observed:
    case (world,found):raw(name ++ "\n",Q.run_handles(~Types.MotionSchema,~F.Store(),~F.Resources(),~Nat,~F.Ops,~Bool,~Unit,~U32,~plan(~skip),~body,choose(empty,found),fail,0,T.begin(~F.World(),~Nat,world)))
def seeded(~skip:Bool,name:String,empty:Bool,fail:Bool,result:F.Seeded) -> String:
  match result:
    case F.Seeded{world,reservations,outcome}:handles(~skip,name,empty,fail,W.handles(~Types.MotionSchema,~F.Store(),~F.Resources(),~Nat,W.barrier(~Types.MotionSchema,~F.Store(),~F.Resources(),~Nat,world)))
def run(~skip:Bool,name:String,empty:Bool,fail:Bool,world:F.World()) -> String:seeded(~skip,name,empty,fail,F.seed(3,world))
