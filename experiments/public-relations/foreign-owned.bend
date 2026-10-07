import Base
import types.bend as G
import world-adapter.bend as A
import owned-world.bend as O
import reorder-adapter.bend as R
import cleanup-owned.bend as C
import ../../src/ecs/world.bend as W
import ../../src/ecs/transaction.bend as X

type Worlds<S:Data> is Type:
  Worlds{first:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,second:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>}
def seeded_join(~S:Data,result:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & W.Status,+handle:W.Handle<S>) -> W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & W.Handle<S>:
  (world,_) = result
  (O.spawn(~S,3n,world),handle)
def seeded(~S:Data,result:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & W.Reservation<S>) -> W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & W.Handle<S>:
  match result:
    case (world,W.Reserved{+handle}): seeded_join(~S,W.activate(~S,~A.Store<S,O.Components<S>>,~U32,~A.Notice<S,U32>,world,handle),handle)
    case (world,_): (world,W.Handle{0,0})
def create_seed(~S:Data,world:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>) -> W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & W.Handle<S>:
  seeded(~S,W.reserve_id(~S,~A.Store<S,O.Components<S>>,~U32,~A.Notice<S,U32>,world))
def status(value:A.QueueStatus) -> String:
  match value:
    case A.Queued{}: "Queued"
    case A.MissingEntity{}: "MissingEntity"
def second_observed(~S:Data,result:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & String,first:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,firstValue:String) -> Worlds<S> & String:
  (second,secondValue) = result
  (Worlds{first,second},firstValue ++ "\nsecond|" ++ secondValue)
def first_observed(~S:Data,result:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & String,second:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>) -> Worlds<S> & String:
  (first,firstValue) = result
  second_observed(~S,O.observe_complete(~S,second),first,firstValue)
def observe(~S:Data,worlds:Worlds<S>) -> Worlds<S> & String:
  match worlds:
    case Worlds{first,second}: first_observed(~S,O.observe_complete(~S,first),second)
def recorded(~S:Data,result:Worlds<S> & String,prefix:String,next:Worlds<S> -> String) -> String:
  (worlds,value) = result
  prefix ++ value ++ "\n" ++ next(worlds)
def final(~S:Data,result:Worlds<S> & String,prefix:String) -> String:
  (_,value) = result
  prefix ++ value
# Every queued-result projection preserves the exact existing Tx owner/queue.
def accepted_status(~S:Data,result:X.Tx<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>> & A.QueueStatus,next:X.Tx<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>> -> String) -> String:
  (tx,queueStatus) = result
  status(queueStatus) ++ "\n" ++ next(tx)
def after(~S:Data,worlds:Worlds<S>) -> String:
  match worlds:
    case Worlds{first,second}: final(~S,observe(~S,Worlds{W.barrier(~S,~A.Store<S,O.Components<S>>,~U32,~A.Notice<S,U32>,first),second}),"after|")
def committed(~S:Data,tx:X.Tx<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>>,second:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>) -> String:
  recorded(~S,observe(~S,Worlds{O.commit(~S,tx,X.Success{}),second}),"queued|",after(~S))
def foreign_ops(~S:Data,tx:X.Tx<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>>,second:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,+local:W.Handle<S>,+foreign:W.Handle<S>) -> String:
  "relate-source=" ++ accepted_status(~S,A.queue_relate(~S,~O.Components<S>,~U32,~U32,tx,G.Descriptor{1,"Link","LinkedBy",G.Ordinary{}},foreign,local),tx => "relate-target=" ++ accepted_status(~S,A.queue_relate(~S,~O.Components<S>,~U32,~U32,tx,G.Descriptor{1,"Link","LinkedBy",G.Ordinary{}},local,foreign),tx => "unrelate=" ++ accepted_status(~S,A.queue_unrelate(~S,~O.Components<S>,~U32,~U32,tx,G.Descriptor{1,"Link","LinkedBy",G.Ordinary{}},foreign),tx => "reorder-parent=" ++ accepted_status(~S,R.queue(~S,~O.Components<S>,~U32,~U32,~G.HierarchyDescriptor{2,"Parent","Children"},tx,R.Args{foreign,[]}),tx => "reorder-child=" ++ accepted_status(~S,R.queue(~S,~O.Components<S>,~U32,~U32,~G.HierarchyDescriptor{2,"Parent","Children"},tx,R.Args{local,[foreign]}),tx => "cleanup=" ++ accepted_status(~S,C.queue(~S,~[G.Descriptor{1,"Link","LinkedBy",G.Ordinary{}},G.Descriptor{2,"Parent","Children",G.Hierarchy{}}],tx,foreign),tx => committed(~S,tx,second)))))))
def start(~S:Data,worlds:Worlds<S>,local:W.Handle<S>,foreign:W.Handle<S>) -> String:
  match worlds:
    case Worlds{first,second}: foreign_ops(~S,O.queue_done(~S,A.queue_relate(~S,~O.Components<S>,~U32,~U32,X.begin(~W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,~A.Notice<S,U32>,first),G.Descriptor{1,"Link","LinkedBy",G.Ordinary{}},W.Handle{1,3},W.Handle{1,1})),second,local,foreign)
def before(~S:Data,result:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & W.Handle<S>,first:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,+local:W.Handle<S>) -> String:
  (second,+foreign) = result
  recorded(~S,observe(~S,Worlds{first,second}),"before|",worlds => start(~S,worlds,local,foreign))
def second_created(~S:Data,result:W.Creation<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,first:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,local:W.Handle<S>) -> String:
  match result:
    case W.Created{_,second}: before(~S,create_seed(~S,second),first,local)
    case _: "SECOND_REJECTED"
def first_seeded(~S:Data,result:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & W.Handle<S>,factory:W.Factory) -> String:
  (first,local) = result
  second_created(~S,W.create(~S,~A.Store<S,O.Components<S>>,~U32,~A.Notice<S,U32>,~O.empty(~S),factory,88),first,local)
def first_created(~S:Data,result:W.Creation<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>) -> String:
  match result:
    case W.Created{factory,first}: first_seeded(~S,create_seed(~S,first),factory)
    case _: "FIRST_REJECTED"
def run(~S:Data) -> String:
  first_created(~S,W.create(~S,~A.Store<S,O.Components<S>>,~U32,~A.Notice<S,U32>,~O.empty(~S),W.factory(),77))
def main() -> IO(Unit):
  IO.print("Workshop\n" ++ run(~O.Workshop) ++ "\nOther\n" ++ run(~O.Other))
