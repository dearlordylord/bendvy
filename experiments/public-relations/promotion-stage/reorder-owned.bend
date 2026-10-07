import Base
import ../../../src/ecs/relation-types.bend as G
import ../../../src/ecs/relation-graph.bend as Graph
import ../../../src/ecs/relation-commands.bend as A
import owned-world.bend as O
import ../../../src/ecs/relation-reorder.bend as R
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/transaction.bend as X
import ../../../src/ecs/system.bend as Sys

type Command<S:Data> is Data:
  Reorder{args:R.Args<S>}
  Relate{source:W.Handle<S>,target:W.Handle<S>}
  Unrelate{source:W.Handle<S>}
type Subject<S:Data> is Data:
  Subject{name:String,commands:List<&2,Command<S>>}
def descriptor(~S:Data) -> G.HierarchyDescriptor<S>:
  G.HierarchyDescriptor{1,"Parent","Children"}
def queue_result(~S:Data,result:X.Tx<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>> & A.QueueStatus) -> X.Tx<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>>:
  (tx,_) = result
  tx
def step(~S:Data,command:Command<S>,tx:X.Tx<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>>) -> X.Tx<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>>:
  match command:
    case Reorder{args}: queue_result(~S,R.invoke(~S,~O.Components<S>,~U32,~U32,~descriptor(~S),~A.QueueStatus,~R.body(~S),args,tx))
    case Relate{source,target}: queue_result(~S,A.queue_relate(~S,~O.Components<S>,~U32,~U32,tx,R.descriptor(~S,descriptor(~S)),source,target))
    case Unrelate{source}: queue_result(~S,A.queue_unrelate(~S,~O.Components<S>,~U32,~U32,tx,R.descriptor(~S,descriptor(~S)),source))
def process_commands(~S:Data,commands:List<&2,Command<S>>,tx:X.Tx<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>>) -> X.Tx<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>>:
  match commands:
    case []: tx
    case command <> rest: process_commands(~S,rest,step(~S,command,tx))
def runner(~S:Data,world:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,args:List<&2,Command<S>>) -> Sys.Outcome<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,U32,Unit>:
  Sys.Succeeded{O.commit(~S,process_commands(~S,args,X.begin(~W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,~A.Notice<S,U32>,world)),X.Success{}),Unit{}}
def target(value:Maybe<&2,U32>) -> String:
  match value:
    case None{}: "none,"
    case Some{id}: U32.show(id) ++ ","
def projections(~S:Data,n:Nat,+graph:G.Graph<S>,+id:U32) -> String:
  match n:
    case 0n: ""
    case 1n+rest: target(Graph.target(~S,graph,R.descriptor(~S,descriptor(~S)),id)) ++ projections(~S,rest,graph,U32.add(id,1))
def inverses(~S:Data,n:Nat,+graph:G.Graph<S>,+id:U32) -> String:
  match n:
    case 0n: ""
    case 1n+rest: O.show_ids(Graph.inverse(~S,graph,R.descriptor(~S,descriptor(~S)),id)) ++ ";" ++ inverses(~S,rest,graph,U32.add(id,1))
def store_observed(~S:Data,result:A.Store<S,O.Components<S>> & String,projections:String) -> A.Store<S,O.Components<S>> & String:
  (store,value) = result
  (store,value ++ projections)
def observe_store(~S:Data,store:A.Store<S,O.Components<S>>) -> A.Store<S,O.Components<S>> & String:
  match store:
    case A.Store{components,+graph}: store_observed(~S,O.observe_store(~S,A.Store{components,graph}),"|targets=" ++ projections(~S,4n,graph,1) ++ "|inverses=" ++ inverses(~S,4n,graph,1))
def show_error(error:G.Error) -> String:
  match error:
    case G.MissingEntity{parent}: "MissingEntity:" ++ U32.show(parent)
    case G.MissingChildEntity{parent,child,name}: "MissingChildEntity:" ++ U32.show(parent) ++ ":" ++ U32.show(child) ++ ":" ++ name
    case G.DuplicateChild{parent,child,name}: "DuplicateChild:" ++ U32.show(parent) ++ ":" ++ U32.show(child) ++ ":" ++ name
    case G.ChildNotRelatedToParent{parent,child,name}: "ChildNotRelatedToParent:" ++ U32.show(parent) ++ ":" ++ U32.show(child) ++ ":" ++ name
    case G.ChildSetMismatch{parent,name}: "ChildSetMismatch:" ++ U32.show(parent) ++ ":" ++ name
    case _: "UNEXPECTED_ERROR"
def operation(op:G.Operation) -> String:
  match op:
    case G.Relate{}: "relate"
    case G.ReorderChildren{}: "reorderChildren"
def show_notice(~S:Data,notice:A.Notice<S,U32>) -> String:
  match notice:
    case A.RelationFailed{G.Failure{G.Descriptor{key,name,inverse,_},op,source,target,error}}: U32.show(key) ++ ":" ++ name ++ ":" ++ inverse ++ ":" ++ operation(op) ++ ":" ++ U32.show(source) ++ ":" ++ U32.show(target) ++ ":" ++ show_error(error)
    case _: "UNEXPECTED_NOTICE"
def notices(~S:Data,events:List<&2,A.Notice<S,U32>>) -> String:
  match events:
    case []: ""
    case event <> rest: show_notice(~S,event) ++ ";" ++ notices(~S,rest)
def notice_observed(~S:Data,result:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & List<&2,A.Notice<S,U32>>,value:String) -> W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & String:
  (world,events) = result
  O.pending_join(~S,O.metadata(~S,(world,value ++ "|failures=" ++ notices(~S,events))))
def store_done(~S:Data,result:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & String) -> W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & String:
  (world,value) = result
  notice_observed(~S,W.events_view(~S,~A.Store<S,O.Components<S>>,~U32,~A.Notice<S,U32>,world),value)
def observe(~S:Data,world:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>) -> W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & String:
  store_done(~S,W.with_store(~S,~A.Store<S,O.Components<S>>,~U32,~A.Notice<S,U32>,~String,observe_store(~S),world))
def next_observed(~S:Data,result:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & String,prefix:String,next:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> -> String) -> String:
  (world,value) = result
  prefix ++ value ++ "\n" ++ next(world)
def queued(~S:Data,outcome:Sys.RunResult<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>,List<&2,Command<S>>,U32,Unit,runner(~S)>,+name:String,next:Sys.Registry<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>,List<&2,Command<S>>,U32,Unit,runner(~S)> -> W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> -> String) -> String:
  match outcome:
    case Sys.Completed{registry,Sys.Succeeded{world,_}}: next_observed(~S,observe(~S,world),name ++ "-queued|",world => next_observed(~S,observe(~S,W.barrier(~S,~A.Store<S,O.Components<S>>,~U32,~A.Notice<S,U32>,world)),name ++ "-after|",world => next(registry,world)))
    case _: "RUN_REJECTED"
def run_subjects(~S:Data,subjects:List<&2,Subject<S>>,registry:Sys.Registry<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>,List<&2,Command<S>>,U32,Unit,runner(~S)>,world:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>) -> String:
  match subjects:
    case []: "done"
    case Subject{name,commands} <> rest: queued(~S,Sys.run(~S,~A.Store<S,O.Components<S>>,~U32,~A.Notice<S,U32>,~List<&2,Command<S>>,~U32,~Unit,~runner(~S),registry,world,commands),name,registry => world => run_subjects(~S,rest,registry,world))
def handles(~S:Data,ids:List<&2,U32>) -> List<&2,W.Handle<S>>:
  match ids:
    case []: []
    case id <> rest: W.Handle{1,id} <> handles(~S,rest)
def subject(~S:Data,name:String,parent:U32,children:List<&2,U32>) -> Subject<S>:
  Subject{name,[Reorder{R.Args{W.Handle{1,parent},handles(~S,children)}}]}
def cases(~S:Data) -> List<&2,Subject<S>>:
  [subject(~S,"reverse",1,[2,3]),subject(~S,"repeat",1,[2,3]),subject(~S,"missing-parent",9,[99,99]),subject(~S,"early-duplicate",1,[2,2,99]),subject(~S,"early-missing-child",1,[99,2,2]),subject(~S,"not-related",1,[4,2,3]),subject(~S,"empty-mismatch",1,[]),subject(~S,"subset-mismatch",1,[2]),subject(~S,"duplicate",1,[2,2]),subject(~S,"other-parent",2,[4]),subject(~S,"empty-parent",3,[]),subject(~S,"restore-order",1,[3,2]),Subject{"fifo",[Reorder{R.Args{W.Handle{1,1},handles(~S,[2,3])}},Unrelate{W.Handle{1,3}},Reorder{R.Args{W.Handle{1,1},handles(~S,[2])}},Relate{W.Handle{1,3},W.Handle{1,1}},Reorder{R.Args{W.Handle{1,1},handles(~S,[3,2])}}]}]
def registered(~S:Data,result:Sys.RegistrationResult<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>,List<&2,Command<S>>,U32,Unit,runner(~S)>) -> String:
  match result:
    case Sys.Registered{world,registry}: run_subjects(~S,cases(~S),registry,world)
    case _: "REGISTER_REJECTED"
def setup(~S:Data,world:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>) -> W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>:
  A.apply_relate(~S,~O.Components<S>,~U32,~U32,A.apply_relate(~S,~O.Components<S>,~U32,~U32,A.apply_relate(~S,~O.Components<S>,~U32,~U32,world,R.descriptor(~S,descriptor(~S)),W.Handle{1,3},W.Handle{1,1}),R.descriptor(~S,descriptor(~S)),W.Handle{1,2},W.Handle{1,1}),R.descriptor(~S,descriptor(~S)),W.Handle{1,4},W.Handle{1,2})
def created(~S:Data,result:W.Creation<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>) -> String:
  match result:
    case W.Created{_,world}: registered(~S,Sys.register(~S,~A.Store<S,O.Components<S>>,~U32,~A.Notice<S,U32>,~List<&2,Command<S>>,~U32,~Unit,~runner(~S),setup(~S,O.spawn(~S,4n,world)),"hierarchy-reorder",["Parent.reorderChildren"]))
    case _: "CREATE_REJECTED"
def run(~S:Data) -> String:
  created(~S,W.create(~S,~A.Store<S,O.Components<S>>,~U32,~A.Notice<S,U32>,~O.empty(~S),W.factory(),77))
def main() -> IO(Unit):
  IO.print("Workshop\n" ++ run(~O.Workshop) ++ "\nOther\n" ++ run(~O.Other))
