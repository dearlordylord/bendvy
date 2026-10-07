import Base
import relation-types.bend as G
import relation-commands.bend as A
import relation-cleanup.bend as K
import cleanup-owned.bend as C
import owned-world.bend as O
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/system.bend as Sys

def descriptor(~S:Data) -> G.Descriptor<S>:
  G.Descriptor{1,"R1","Sources1",G.Hierarchy{}}
def edge(~S:Data,+source:U32) -> G.Edge<S>:
  G.Edge{descriptor(~S),source,U32.add(source,1)}
def inverse(~S:Data,+source:U32) -> G.Inverse<S>:
  G.Inverse{descriptor(~S),U32.add(source,1),[source]}
def chain_edges_acc(~S:Data,remaining:Nat,+id:U32,acc:List<&2,G.Edge<S>>) -> List<&2,G.Edge<S>>:
  match remaining:
    case 0n: acc
    case 1n++rest: chain_edges_acc(~S,rest,U32.add(id,1),edge(~S,id) <> acc)
def chain_edges(~S:Data,remaining:Nat) -> List<&2,G.Edge<S>>:
  chain_edges_acc(~S,remaining,1,[])
def chain_inverses_acc(~S:Data,remaining:Nat,+id:U32,acc:List<&2,G.Inverse<S>>) -> List<&2,G.Inverse<S>>:
  match remaining:
    case 0n: acc
    case 1n++rest: chain_inverses_acc(~S,rest,U32.add(id,1),inverse(~S,id) <> acc)
def chain_inverses(~S:Data,remaining:Nat) -> List<&2,G.Inverse<S>>:
  chain_inverses_acc(~S,remaining,1,[])
def seed(~S:Data,store:A.Store<S,O.Components<S>>) -> A.Store<S,O.Components<S>> & Unit:
  match store:
    case A.Store{components,_}: (A.Store{components,G.Graph{chain_edges(~S,U32.to_nat(131071)),chain_inverses(~S,U32.to_nat(131071))}},Unit{})
def seeded(~S:Data,observed:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & Unit) -> W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>:
  (world,_) = observed
  world
def bool_equal(a:Bool,b:Bool) -> Bool:
  match a b:
    case True{} True{}: True{}
    case False{} False{}: True{}
    case _ _: False{}
def expected_live(+id:U32,after:Bool) -> Bool:
  Bool.and(Bool.and(U32.is_lt(0,id),U32.is_le(id,131072)),Bool.not(Bool.and(after,U32.is_eq(id,1))))
def live_resume(observed:Array<Bool> & Bool,next:Array<Bool> -> Bool -> Array<Bool> & Bool) -> Array<Bool> & Bool:
  (live,value) = observed
  next(live,value)
def verify_live(remaining:Nat,live:Array<Bool>,+id:U32,+after:Bool,good:Bool) -> Array<Bool> & Bool:
  match remaining:
    case 0n: (live,good)
    case 1n+rest: live_resume(Array.get(Bool,live,id),live => value => verify_live(rest,live,U32.add(id,1),after,Bool.and(good,bool_equal(value,expected_live(id,after)))))
def descriptor_valid(~S:Data,d:G.Descriptor<S>) -> Bool:
  match d:
    case G.Descriptor{key,name,inverse,G.Hierarchy{}}: Bool.and(U32.is_eq(key,1),Bool.and(String.eq(name,"R1"),String.eq(inverse,"Sources1")))
    case _: False{}
def edge_valid(~S:Data,e:G.Edge<S>,+expected:U32) -> Bool:
  match e:
    case G.Edge{d,source,target}: Bool.and(descriptor_valid(~S,d),Bool.and(U32.is_eq(source,expected),U32.is_eq(target,U32.add(expected,1))))
def edges_valid(~S:Data,edges:List<&2,G.Edge<S>>,+expected:U32,+lower:U32,good:Bool) -> Bool:
  match edges:
    case []: Bool.and(good,U32.is_eq(expected,U32.sub(lower,1)))
    case e <> rest: edges_valid(~S,rest,U32.sub(expected,1),lower,Bool.and(good,edge_valid(~S,e,expected)))
def sources_valid(sources:List<&2,U32>,expected:U32) -> Bool:
  match sources:
    case Con{source,Nil{}}: U32.is_eq(source,expected)
    case _: False{}
def inverse_valid(~S:Data,i:G.Inverse<S>,+expected:U32) -> Bool:
  match i:
    case G.Inverse{d,target,sources}: Bool.and(descriptor_valid(~S,d),Bool.and(U32.is_eq(target,U32.add(expected,1)),sources_valid(sources,expected)))
def inverses_valid(~S:Data,inverses:List<&2,G.Inverse<S>>,+expected:U32,+lower:U32,good:Bool) -> Bool:
  match inverses:
    case []: Bool.and(good,U32.is_eq(expected,U32.sub(lower,1)))
    case i <> rest: inverses_valid(~S,rest,U32.sub(expected,1),lower,Bool.and(good,inverse_valid(~S,i,expected)))
def graph_valid(~S:Data,graph:G.Graph<S>,+lower:U32) -> Bool:
  match graph:
    case G.Graph{edges,inverses}: Bool.and(edges_valid(~S,edges,131071,lower,True{}),inverses_valid(~S,inverses,131071,lower,True{}))
def store_valid(~S:Data,store:A.Store<S,O.Components<S>>,lower:U32) -> A.Store<S,O.Components<S>> & Bool:
  match store:
    case A.Store{components,+graph}: (A.Store{components,graph},graph_valid(~S,graph,lower))
def verified_world(~S:Data,observed:Array<Bool> & Bool,+namespace:U32,+nextId:U32,+highWater:U32,+capacity:U32,+depth:Nat,store:A.Store<S,O.Components<S>>,resource:U32,+events:List<&2,A.Notice<S,U32>>,pending:List<(W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> -> W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>)>,+registrations:List<&2,W.RegistrationMeta>,+nextSystemId:U32,+clock:U32) -> W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & Bool:
  (live,good) = observed
  (W.World{namespace,nextId,highWater,live,capacity,depth,store,resource,events,pending,registrations,nextSystemId,clock},good)
def verify_world(~S:Data,world:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,after:Bool) -> W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & Bool:
  match world:
    case W.World{namespace,nextId,highWater,live,+capacity,depth,store,resource,events,pending,registrations,nextSystemId,clock}: verified_world(~S,verify_live(U32.to_nat(capacity),live,0,after,True{}),namespace,nextId,highWater,capacity,depth,store,resource,events,pending,registrations,nextSystemId,clock)
def show_bool(value:Bool) -> String:
  match value:
    case True{}: "true"
    case False{}: "false"
def projected(~S:Data,observed:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & String,good:Bool) -> W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & String:
  (world,text) = observed
  (world,text ++ "|all-live-shape=" ++ show_bool(good))
def observed_graph(~S:Data,observed:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & String,good:Bool) -> W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & String:
  (world,text) = observed
  (world,text ++ "|all-graph-fields=" ++ show_bool(good))
def graph_join(~S:Data,observed:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & Bool,text:String) -> W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & String:
  (world,good) = observed
  (world,text ++ "|all-graph-fields=" ++ show_bool(good))
def graph_observe(~S:Data,observed:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & String,lower:U32) -> W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & String:
  (world,text) = observed
  graph_join(~S,W.with_store(~S,~A.Store<S,O.Components<S>>,~U32,~A.Notice<S,U32>,~Bool,store => store_valid(~S,store,lower),world),text)
def live_join(~S:Data,observed:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & Bool,lower:U32) -> W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & String:
  (world,good) = observed
  graph_observe(~S,projected(~S,O.observe_complete(~S,world),good),lower)
def observe(~S:Data,world:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,after:Bool,lower:U32) -> W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & String:
  live_join(~S,verify_world(~S,world,after),lower)
def after(~S:Data,observed:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & String) -> String:
  (_,text) = observed
  "after|" ++ text
def queued(~S:Data,observed:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & String) -> String:
  (world,text) = observed
  "queued|" ++ text ++ "\n" ++ after(~S,observe(~S,W.barrier(~S,~A.Store<S,O.Components<S>>,~U32,~A.Notice<S,U32>,world),True{},2))
def ran(~S:Data,result:Sys.RunResult<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>,W.Handle<S>,U32,Unit,C.runner(~S,~[descriptor(~S)])>) -> String:
  match result:
    case Sys.Completed{_,Sys.Succeeded{world,_}}: queued(~S,observe(~S,world,False{},1))
    case _: "RUN_REJECTED"
def before(~S:Data,observed:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & String,registry:Sys.Registry<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>,W.Handle<S>,U32,Unit,C.runner(~S,~[descriptor(~S)])>) -> String:
  (world,text) = observed
  "before|" ++ text ++ "\n" ++ ran(~S,Sys.run(~S,~A.Store<S,O.Components<S>>,~U32,~A.Notice<S,U32>,~W.Handle<S>,~U32,~Unit,~C.runner(~S,~[descriptor(~S)]),registry,world,W.Handle{1,1}))
def registered(~S:Data,result:Sys.RegistrationResult<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>,W.Handle<S>,U32,Unit,C.runner(~S,~[descriptor(~S)])>) -> String:
  match result:
    case Sys.Registered{world,registry}: before(~S,observe(~S,world,False{},1),registry)
    case _: "REGISTER_REJECTED"
def created(~S:Data,result:W.Creation<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>) -> String:
  match result:
    case W.Created{_,world}: registered(~S,Sys.register(~S,~A.Store<S,O.Components<S>>,~U32,~A.Notice<S,U32>,~W.Handle<S>,~U32,~Unit,~C.runner(~S,~[descriptor(~S)]),seeded(~S,W.with_store(~S,~A.Store<S,O.Components<S>>,~U32,~A.Notice<S,U32>,~Unit,seed(~S),O.spawn(~S,U32.to_nat(131072),world))),"large-relation-cleanup",["Relation.despawn"]))
    case _: "CREATE_REJECTED"
def run(~S:Data) -> String:
  created(~S,W.create(~S,~A.Store<S,O.Components<S>>,~U32,~A.Notice<S,U32>,~O.empty(~S),W.factory(),77))
def main() -> IO(Unit):
  IO.print("Workshop\n" ++ run(~O.Workshop) ++ "\nOther\n" ++ run(~O.Other))
