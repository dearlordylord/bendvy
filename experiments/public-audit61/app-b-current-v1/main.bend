import Base
import bundle.bend as B
import resources.bend as R
import install.bend as Install
import observe.bend as Observe
import inspect.bend as Inspect
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/relation-commands.bend as A
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as T

type Snapshot is Data:
  Snapshot{stage:String,world:String}
type Report is Data:
  Report{snapshots:List<&2,Snapshot>,handles:List<&2,W.Handle<B.Scene>>,queueResults:List<&2,A.QueueStatus>,beforeReparent:Inspect.Selected,afterReparent:Inspect.Selected,repeated:Inspect.Selected}
def enqueue_list(commands:List<(B.World(R.Resources()) -> B.World(R.Resources()))>,world:B.World(R.Resources())) -> B.World(R.Resources()):
  match commands:
    case []:world
    case command <> rest:enqueue_list(rest,W.enqueue(~B.Scene,~B.Store(),~R.Resources(),~A.Notice<B.Scene,U32>,world,command))
def enqueue(world:B.World(R.Resources()),commands:List<(B.World(R.Resources()) -> B.World(R.Resources()))>) -> B.World(R.Resources()):
  enqueue_list(commands,world)
def publish(world:B.World(R.Resources()),events:List<&2,A.Notice<B.Scene,U32>>) -> B.World(R.Resources()):
  W.event_publish(~B.Scene,~B.Store(),~R.Resources(),~A.Notice<B.Scene,U32>,world,events)
def commit(tx:T.Tx<B.World(R.Resources()),A.Notice<B.Scene,U32>>) -> T.Returned<B.World(R.Resources()),Unit>:
  T.finish(~B.World(R.Resources()),~A.Notice<B.Scene,U32>,~Unit,~enqueue,~publish,tx,T.Success{})
def barrier(world:B.World(R.Resources())) -> B.World(R.Resources()):
  W.barrier(~B.Scene,~B.Store(),~R.Resources(),~A.Notice<B.Scene,U32>,world)
def repeated_done(snapshots:List<&2,Snapshot>,handles:List<&2,W.Handle<B.Scene>>,queueResults:List<&2,A.QueueStatus>,first:Inspect.Selected,second:Inspect.Selected,third:Inspect.Selected,result:B.World(R.Resources()) & String) -> Maybe<&2,Report>:
  match result:
    case (world,text):Some{Report{List.append(&2,Snapshot,snapshots,[Snapshot{"after-repeated-inspect",text}]),handles,queueResults,first,second,third}}
def repeated(snapshots:List<&2,Snapshot>,+handles:List<&2,W.Handle<B.Scene>>,queueResults:List<&2,A.QueueStatus>,first:Inspect.Selected,second:Inspect.Selected,result:B.World(R.Resources()) & Inspect.Selected) -> Maybe<&2,Report>:
  match result:
    case (world,third):repeated_done(snapshots,handles,queueResults,first,second,third,Observe.world(world))
def after_second(+child:W.Handle<B.Scene>,snapshots:List<&2,Snapshot>,handles:List<&2,W.Handle<B.Scene>>,queueResults:List<&2,A.QueueStatus>,first:Inspect.Selected,second:Inspect.Selected,result:B.World(R.Resources()) & String) -> Maybe<&2,Report>:
  match result:
    case (world,text):repeated(List.append(&2,Snapshot,snapshots,[Snapshot{"after-reparent-inspect",text}]),handles,queueResults,first,second,Inspect.snapshot(world,child))
def second(child:W.Handle<B.Scene>,snapshots:List<&2,Snapshot>,handles:List<&2,W.Handle<B.Scene>>,queueResults:List<&2,A.QueueStatus>,first:Inspect.Selected,result:B.World(R.Resources()) & Inspect.Selected) -> Maybe<&2,Report>:
  match result:
    case (world,selected):after_second(child,snapshots,handles,queueResults,first,selected,Observe.world(world))
def reparent_flushed(+child:W.Handle<B.Scene>,snapshots:List<&2,Snapshot>,handles:List<&2,W.Handle<B.Scene>>,queueResults:List<&2,A.QueueStatus>,first:Inspect.Selected,result:B.World(R.Resources()) & String) -> Maybe<&2,Report>:
  match result:
    case (world,text):second(child,List.append(&2,Snapshot,snapshots,[Snapshot{"reparent-flushed",text}]),handles,queueResults,first,Inspect.snapshot(world,child))
def reparent_pending(child:W.Handle<B.Scene>,snapshots:List<&2,Snapshot>,handles:List<&2,W.Handle<B.Scene>>,queueResults:List<&2,A.QueueStatus>,first:Inspect.Selected,result:B.World(R.Resources()) & String) -> Maybe<&2,Report>:
  match result:
    case (world,text):reparent_flushed(child,List.append(&2,Snapshot,snapshots,[Snapshot{"reparent-committed-pending",text}]),handles,queueResults,first,Observe.world(barrier(world)))
def reparent_committed(child:W.Handle<B.Scene>,snapshots:List<&2,Snapshot>,handles:List<&2,W.Handle<B.Scene>>,queueResults:List<&2,A.QueueStatus>,first:Inspect.Selected,result:T.Returned<B.World(R.Resources()),Unit>) -> Maybe<&2,Report>:
  match result:
    case T.Returned{world,outcome}:reparent_pending(child,snapshots,handles,queueResults,first,Observe.world(world))
def reparent_queued(child:W.Handle<B.Scene>,snapshots:List<&2,Snapshot>,handles:List<&2,W.Handle<B.Scene>>,queueResults:List<&2,A.QueueStatus>,first:Inspect.Selected,result:T.Tx<B.World(R.Resources()),A.Notice<B.Scene,U32>> & A.QueueStatus) -> Maybe<&2,Report>:
  match result:
    case (tx,status):reparent_committed(child,snapshots,handles,List.append(&2,A.QueueStatus,queueResults,[status]),first,commit(tx))
def first_observed(+root:W.Handle<B.Scene>,+other:W.Handle<B.Scene>,+child:W.Handle<B.Scene>,snapshots:List<&2,Snapshot>,queueResults:List<&2,A.QueueStatus>,first:Inspect.Selected,result:B.World(R.Resources()) & String) -> Maybe<&2,Report>:
  match result:
    case (world,text):reparent_queued(child,List.append(&2,Snapshot,snapshots,[Snapshot{"after-initial-inspect",text}]),[root,other,child],queueResults,first,A.queue_relate(~B.Scene,~B.Components,~R.Resources(),~U32,T.begin(~B.World(R.Resources()),~A.Notice<B.Scene,U32>,world),Inspect.parent(),child,other))
def first(root:W.Handle<B.Scene>,other:W.Handle<B.Scene>,child:W.Handle<B.Scene>,snapshots:List<&2,Snapshot>,queueResults:List<&2,A.QueueStatus>,result:B.World(R.Resources()) & Inspect.Selected) -> Maybe<&2,Report>:
  match result:
    case (world,selected):first_observed(root,other,child,snapshots,queueResults,selected,Observe.world(world))
def initial_flushed(root:W.Handle<B.Scene>,other:W.Handle<B.Scene>,+child:W.Handle<B.Scene>,snapshots:List<&2,Snapshot>,queueResults:List<&2,A.QueueStatus>,result:B.World(R.Resources()) & String) -> Maybe<&2,Report>:
  match result:
    case (world,text):first(root,other,child,List.append(&2,Snapshot,snapshots,[Snapshot{"relations-flushed",text}]),queueResults,Inspect.snapshot(world,child))
def initial_pending(root:W.Handle<B.Scene>,other:W.Handle<B.Scene>,child:W.Handle<B.Scene>,snapshots:List<&2,Snapshot>,queueResults:List<&2,A.QueueStatus>,result:B.World(R.Resources()) & String) -> Maybe<&2,Report>:
  match result:
    case (world,text):initial_flushed(root,other,child,List.append(&2,Snapshot,snapshots,[Snapshot{"relations-committed-pending",text}]),queueResults,Observe.world(barrier(world)))
def initial_committed(root:W.Handle<B.Scene>,other:W.Handle<B.Scene>,child:W.Handle<B.Scene>,snapshots:List<&2,Snapshot>,queueResults:List<&2,A.QueueStatus>,result:T.Returned<B.World(R.Resources()),Unit>) -> Maybe<&2,Report>:
  match result:
    case T.Returned{world,outcome}:initial_pending(root,other,child,snapshots,queueResults,Observe.world(world))
def link_queued(root:W.Handle<B.Scene>,other:W.Handle<B.Scene>,child:W.Handle<B.Scene>,snapshots:List<&2,Snapshot>,parentStatus:A.QueueStatus,result:T.Tx<B.World(R.Resources()),A.Notice<B.Scene,U32>> & A.QueueStatus) -> Maybe<&2,Report>:
  match result:
    case (tx,linkStatus):initial_committed(root,other,child,snapshots,[parentStatus,linkStatus],commit(tx))
def parent_queued(root:W.Handle<B.Scene>,+other:W.Handle<B.Scene>,+child:W.Handle<B.Scene>,snapshots:List<&2,Snapshot>,result:T.Tx<B.World(R.Resources()),A.Notice<B.Scene,U32>> & A.QueueStatus) -> Maybe<&2,Report>:
  match result:
    case (tx,parentStatus):link_queued(root,other,child,snapshots,parentStatus,A.queue_relate(~B.Scene,~B.Components,~R.Resources(),~U32,tx,Inspect.related(),child,other))
def bundles_flushed(+root:W.Handle<B.Scene>,other:W.Handle<B.Scene>,+child:W.Handle<B.Scene>,snapshots:List<&2,Snapshot>,result:B.World(R.Resources()) & String) -> Maybe<&2,Report>:
  match result:
    case (world,text):parent_queued(root,other,child,List.append(&2,Snapshot,snapshots,[Snapshot{"bundles-explicit-flush",text}]),A.queue_relate(~B.Scene,~B.Components,~R.Resources(),~U32,T.begin(~B.World(R.Resources()),~A.Notice<B.Scene,U32>,world),Inspect.parent(),child,root))
def bundles_pending(root:W.Handle<B.Scene>,other:W.Handle<B.Scene>,child:W.Handle<B.Scene>,snapshots:List<&2,Snapshot>,result:B.World(R.Resources()) & String) -> Maybe<&2,Report>:
  match result:
    case (world,text):bundles_flushed(root,other,child,List.append(&2,Snapshot,snapshots,[Snapshot{"three-bundles-committed-pending",text}]),Observe.world(barrier(world)))
def third_seed(root:W.Handle<B.Scene>,other:W.Handle<B.Scene>,snapshots:List<&2,Snapshot>,result:Install.Seeded) -> Maybe<&2,Report>:
  match result:
    case Install.Seeded{world,child}:bundles_pending(root,other,child,snapshots,Observe.world(world))
    case Install.SeedRejected{world,payloads,raw}:None{}
def second_seed(root:W.Handle<B.Scene>,snapshots:List<&2,Snapshot>,result:Install.Seeded) -> Maybe<&2,Report>:
  match result:
    case Install.Seeded{world,other}:third_seed(root,other,snapshots,Install.seed(world))
    case Install.SeedRejected{world,payloads,raw}:None{}
def first_seed(snapshots:List<&2,Snapshot>,result:Install.Seeded) -> Maybe<&2,Report>:
  match result:
    case Install.Seeded{world,root}:second_seed(root,snapshots,Install.seed(world))
    case Install.SeedRejected{world,payloads,raw}:None{}
def created_observed(result:B.World(R.Resources()) & String) -> Maybe<&2,Report>:
  match result:
    case (world,text):first_seed([Snapshot{"created",text}],Install.seed(world))
def created(result:W.Creation<B.Scene,B.Store(),R.Resources(),A.Notice<B.Scene,U32>>) -> Maybe<&2,Report>:
  match result:
    case W.Created{factory,world}:created_observed(Observe.world(world))
    case W.CreateRejected{factory,resources}:None{}
def main() -> Maybe<&2,Report>:
  created(W.create(~B.Scene,~B.Store(),~R.Resources(),~A.Notice<B.Scene,U32>,~B.empty,W.factory(),R.initial()))
