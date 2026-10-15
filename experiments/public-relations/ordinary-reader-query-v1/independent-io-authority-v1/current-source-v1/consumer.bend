import Base
import ../../../../../src/ecs/world-io.bend as WI
import ./fixture.bend as F
import ./operations.bend as O
import ./reader-adapter.bend as C
import ../../../../../src/ecs/world.bend as W
import ../../../../../src/ecs/relation-types.bend as G
import ../../../../../src/ecs/relation-commands.bend as A
import ../../../../../src/ecs/system.bend as Sy
import ../../../../../src/ecs/relation-providers.bend as P
type Seed<S:Data> is Type: Seed{world:W.World<S,A.Store<S,F.Components>,Array<U32>,A.Notice<S,U32>>,handles:List<&2,W.Handle<S>>,statuses:List<&2,W.Status>}
type Ready<S:Data> is Type: Ready{receiver:Seed<S>,foreign:Seed<S>}
def empty(~S:Data,_:Unit) -> A.Store<S,F.Components>:
  A.Store{F.Components{ANode{ANode{ALeaf{None{}},ALeaf{Some{F.payload(1)}}},ANode{ALeaf{Some{F.payload(2)}},ALeaf{Some{F.payload(3)}}}},[]},G.Graph{[],[]}}
def activated2(~S:Data,+handle:W.Handle<S>,observed:W.World<S,A.Store<S,F.Components>,Array<U32>,A.Notice<S,U32>> & W.Status,handles:List<&2,W.Handle<S>>,statuses:List<&2,W.Status>) -> Maybe<Seed<S>>:
  match observed:
    case (world,+status):Some{Seed{world,List.reverse(&2,W.Handle<S>,handle <> handles),List.reverse(&2,W.Status,status <> statuses)}}
def reserved2(~S:Data,observed:W.World<S,A.Store<S,F.Components>,Array<U32>,A.Notice<S,U32>> & W.Reservation<S>,handles:List<&2,W.Handle<S>>,statuses:List<&2,W.Status>) -> Maybe<Seed<S>>:
  match observed:
    case (world,W.Reserved{+handle}):activated2(~S,handle,W.activate(~S,~A.Store<S,F.Components>,~Array<U32>,~A.Notice<S,U32>,world,handle),handles,statuses)
    case _:None{}
def activated1(~S:Data,+handle:W.Handle<S>,observed:W.World<S,A.Store<S,F.Components>,Array<U32>,A.Notice<S,U32>> & W.Status,handles:List<&2,W.Handle<S>>,statuses:List<&2,W.Status>) -> Maybe<Seed<S>>:
  match observed:
    case (world,+status):reserved2(~S,W.reserve_id(~S,~A.Store<S,F.Components>,~Array<U32>,~A.Notice<S,U32>,world),handle <> handles,status <> statuses)
def reserved1(~S:Data,observed:W.World<S,A.Store<S,F.Components>,Array<U32>,A.Notice<S,U32>> & W.Reservation<S>,handles:List<&2,W.Handle<S>>,statuses:List<&2,W.Status>) -> Maybe<Seed<S>>:
  match observed:
    case (world,W.Reserved{+handle}):activated1(~S,handle,W.activate(~S,~A.Store<S,F.Components>,~Array<U32>,~A.Notice<S,U32>,world,handle),handles,statuses)
    case _:None{}
def activated0(~S:Data,+handle:W.Handle<S>,observed:W.World<S,A.Store<S,F.Components>,Array<U32>,A.Notice<S,U32>> & W.Status,handles:List<&2,W.Handle<S>>,statuses:List<&2,W.Status>) -> Maybe<Seed<S>>:
  match observed:
    case (world,+status):reserved1(~S,W.reserve_id(~S,~A.Store<S,F.Components>,~Array<U32>,~A.Notice<S,U32>,world),handle <> handles,status <> statuses)
def reserved0(~S:Data,observed:W.World<S,A.Store<S,F.Components>,Array<U32>,A.Notice<S,U32>> & W.Reservation<S>,handles:List<&2,W.Handle<S>>,statuses:List<&2,W.Status>) -> Maybe<Seed<S>>:
  match observed:
    case (world,W.Reserved{+handle}):activated0(~S,handle,W.activate(~S,~A.Store<S,F.Components>,~Array<U32>,~A.Notice<S,U32>,world,handle),handles,statuses)
    case _:None{}
def seeded(~S:Data,world:W.World<S,A.Store<S,F.Components>,Array<U32>,A.Notice<S,U32>>) -> Maybe<Seed<S>>:reserved0(~S,W.reserve_id(~S,~A.Store<S,F.Components>,~Array<U32>,~A.Notice<S,U32>,world),[],[])
def second_seeded(~S:Data,receiver:Seed<S>,observed:Maybe<Seed<S>>) -> Maybe<Ready<S>>:
  match observed:
    case Some{foreign}:Some{Ready{receiver,foreign}}
    case _:None{}
def second_created(~S:Data,receiver:Seed<S>,observed:WI.Creation<S,A.Store<S,F.Components>,Array<U32>,A.Notice<S,U32>>) -> IO(Maybe<Ready<S>>):
  match observed:
    case WI.Created{world}:IO.pure(Maybe<Ready<S>>,second_seeded(~S,receiver,seeded(~S,world)))
    case WI.Refused{_}:IO.pure(Maybe<Ready<S>>,None{})
def first_seeded(~S:Data,observed:Maybe<Seed<S>>) -> IO(Maybe<Ready<S>>):
  match observed:
    case Some{receiver}:IO.bind(WI.Creation<S,A.Store<S,F.Components>,Array<U32>,A.Notice<S,U32>>,Maybe<Ready<S>>,WI.create(~S,~A.Store<S,F.Components>,~Array<U32>,~A.Notice<S,U32>,~empty(~S),ANode{ALeaf{177},ALeaf{188}}),value => second_created(~S,receiver,value))
    case _:IO.pure(Maybe<Ready<S>>,None{})
def first_created(~S:Data,observed:WI.Creation<S,A.Store<S,F.Components>,Array<U32>,A.Notice<S,U32>>) -> IO(Maybe<Ready<S>>):
  match observed:
    case WI.Created{world}:first_seeded(~S,seeded(~S,world))
    case WI.Refused{_}:IO.pure(Maybe<Ready<S>>,None{})
def created(~S:Data) -> IO(Maybe<Ready<S>>):
  IO.bind(WI.Creation<S,A.Store<S,F.Components>,Array<U32>,A.Notice<S,U32>>,Maybe<Ready<S>>,WI.create(~S,~A.Store<S,F.Components>,~Array<U32>,~A.Notice<S,U32>,~empty(~S),ANode{ALeaf{77},ALeaf{88}}),value => first_created(~S,value))
type Package<S:Data> is Type: Package{receiver:C.State<S>,foreign:W.World<S,A.Store<S,F.Components>,Array<U32>,A.Notice<S,U32>>,local:W.Handle<S>,target:W.Handle<S>,alien:W.Handle<S>,ownLookup:Maybe<&2,List<&2,U32>>,receiverStatus:List<&2,W.Status>,foreignStatus:List<&2,W.Status>,foreignSnapshots:List<&2,String>}
type Report<S:Data> is Data: Report{receiver:C.Report<S>,foreignSnapshots:List<&2,String>,local:W.Handle<S>,target:W.Handle<S>,alien:W.Handle<S>,ownLookup:Maybe<&2,List<&2,U32>>,receiverStatus:List<&2,W.Status>,foreignStatus:List<&2,W.Status>}
def checkpoint_done(~S:Data,receiver:C.State<S>,+local:W.Handle<S>,+target:W.Handle<S>,+alien:W.Handle<S>,ownLookup:Maybe<&2,List<&2,U32>>,receiverStatus:List<&2,W.Status>,foreignStatus:List<&2,W.Status>,foreignSnapshots:List<&2,String>,observed:W.World<S,A.Store<S,F.Components>,Array<U32>,A.Notice<S,U32>> & String) -> Package<S>:
  match observed:
    case (foreign,text):Package{C.snapshot(~S,receiver),foreign,local,target,alien,ownLookup,receiverStatus,foreignStatus,text <> foreignSnapshots}
def checkpoint(~S:Data,value:Package<S>) -> Package<S>:
  match value:
    case Package{receiver,foreign,local,target,alien,ownLookup,receiverStatus,foreignStatus,foreignSnapshots}:checkpoint_done(~S,receiver,local,target,alien,ownLookup,receiverStatus,foreignStatus,foreignSnapshots,F.observe(~S,foreign))
def updated(~S:Data,observed:Maybe<C.State<S>>,foreign:W.World<S,A.Store<S,F.Components>,Array<U32>,A.Notice<S,U32>>,local:W.Handle<S>,target:W.Handle<S>,alien:W.Handle<S>,ownLookup:Maybe<&2,List<&2,U32>>,receiverStatus:List<&2,W.Status>,foreignStatus:List<&2,W.Status>,foreignSnapshots:List<&2,String>) -> Maybe<Package<S>>:
  match observed:
    case Some{receiver}:Some{Package{receiver,foreign,local,target,alien,ownLookup,receiverStatus,foreignStatus,foreignSnapshots}}
    case _:None{}
type Operation is Data: ForeignSource{} ForeignTarget{} ForeignClear{} LocalRelate{} LocalClear{}
def request(~S:Data,mode:Operation,+local:W.Handle<S>,+target:W.Handle<S>,+alien:W.Handle<S>) -> O.Input<S>:
  match mode:
    case ForeignSource{}:O.Replace{P.Targets{alien,local}}
    case ForeignTarget{}:O.Replace{P.Targets{local,alien}}
    case ForeignClear{}:O.Clear{alien}
    case LocalRelate{}:O.Replace{P.Targets{local,target}}
    case LocalClear{}:O.Clear{local}
def write(~S:Data,value:Package<S>,mode:Operation) -> Maybe<Package<S>>:
  match value:
    case Package{receiver,foreign,+local,+target,+alien,ownLookup,receiverStatus,foreignStatus,foreignSnapshots}:updated(~S,C.write(~S,receiver,request(~S,mode,local,target,alien)),foreign,local,target,alien,ownLookup,receiverStatus,foreignStatus,foreignSnapshots)
def barrier(~S:Data,value:Package<S>) -> Package<S>:
  match value:
    case Package{receiver,foreign,local,target,alien,ownLookup,receiverStatus,foreignStatus,foreignSnapshots}:Package{C.barrier(~S,receiver),foreign,local,target,alien,ownLookup,receiverStatus,foreignStatus,foreignSnapshots}
def deliver(~S:Data,value:Package<S>) -> Maybe<Package<S>>:
  match value:
    case Package{receiver,foreign,local,target,alien,ownLookup,receiverStatus,foreignStatus,foreignSnapshots}:updated(~S,C.deliver(~S,receiver),foreign,local,target,alien,ownLookup,receiverStatus,foreignStatus,foreignSnapshots)
def query(~S:Data,value:Package<S>) -> Maybe<Package<S>>:
  match value:
    case Package{receiver,foreign,local,+target,alien,ownLookup,receiverStatus,foreignStatus,foreignSnapshots}:updated(~S,C.query(~S,receiver,target),foreign,local,target,alien,ownLookup,receiverStatus,foreignStatus,foreignSnapshots)
def finish(~S:Data,value:Package<S>) -> Report<S>:
  match value:
    case Package{receiver,_,local,target,alien,ownLookup,receiverStatus,foreignStatus,foreignSnapshots}:Report{C.finish(~S,receiver),List.reverse(&2,String,foreignSnapshots),local,target,alien,ownLookup,receiverStatus,foreignStatus}
def positive_finished(~S:Data,observed:Maybe<Package<S>>) -> Maybe<Report<S>>:
  match observed:
    case Some{value}:Some{finish(~S,checkpoint(~S,value))}
    case _:None{}
def positive_clear_barrier(~S:Data,observed:Maybe<Package<S>>) -> Maybe<Report<S>>:
  match observed:
    case Some{value}:positive_finished(~S,query(~S,barrier(~S,checkpoint(~S,value))))
    case _:None{}
def positive_clear(~S:Data,observed:Maybe<Package<S>>) -> Maybe<Report<S>>:
  match observed:
    case Some{value}:positive_clear_barrier(~S,write(~S,checkpoint(~S,value),LocalClear{}))
    case _:None{}
def positive_relate_barrier(~S:Data,observed:Maybe<Package<S>>) -> Maybe<Report<S>>:
  match observed:
    case Some{value}:positive_clear(~S,query(~S,barrier(~S,checkpoint(~S,value))))
    case _:None{}
def completed(~S:Data,observed:Maybe<Package<S>>) -> Maybe<Report<S>>:
  match observed:
    case Some{value}:positive_relate_barrier(~S,write(~S,checkpoint(~S,value),LocalRelate{}))
    case _:None{}
def stage5(~S:Data,observed:Maybe<Package<S>>) -> Maybe<Report<S>>:
  match observed:
    case Some{value}:completed(~S,deliver(~S,value))
    case _:None{}
def after4(~S:Data,observed:Maybe<Package<S>>) -> Maybe<Report<S>>:
  match observed:
    case Some{value}:stage5(~S,Some{checkpoint(~S,value)})
    case _:None{}
def stage4(~S:Data,observed:Maybe<Package<S>>) -> Maybe<Report<S>>:
  match observed:
    case Some{value}:after4(~S,Some{barrier(~S,value)})
    case _:None{}
def after3(~S:Data,observed:Maybe<Package<S>>) -> Maybe<Report<S>>:
  match observed:
    case Some{value}:stage4(~S,Some{checkpoint(~S,value)})
    case _:None{}
def stage3(~S:Data,observed:Maybe<Package<S>>) -> Maybe<Report<S>>:
  match observed:
    case Some{value}:after3(~S,write(~S,value,ForeignClear{}))
    case _:None{}
def after2(~S:Data,observed:Maybe<Package<S>>) -> Maybe<Report<S>>:
  match observed:
    case Some{value}:stage3(~S,Some{checkpoint(~S,value)})
    case _:None{}
def stage2(~S:Data,observed:Maybe<Package<S>>) -> Maybe<Report<S>>:
  match observed:
    case Some{value}:after2(~S,write(~S,value,ForeignClear{}))
    case _:None{}
def after1(~S:Data,observed:Maybe<Package<S>>) -> Maybe<Report<S>>:
  match observed:
    case Some{value}:stage2(~S,Some{checkpoint(~S,value)})
    case _:None{}
def stage1(~S:Data,observed:Maybe<Package<S>>) -> Maybe<Report<S>>:
  match observed:
    case Some{value}:after1(~S,write(~S,value,ForeignTarget{}))
    case _:None{}
def after0(~S:Data,observed:Maybe<Package<S>>) -> Maybe<Report<S>>:
  match observed:
    case Some{value}:stage1(~S,Some{checkpoint(~S,value)})
    case _:None{}
def stage0(~S:Data,observed:Maybe<Package<S>>) -> Maybe<Report<S>>:
  match observed:
    case Some{value}:after0(~S,write(~S,value,ForeignSource{}))
    case _:None{}
def registered(~S:Data,observed:Maybe<C.State<S>>,foreign:W.World<S,A.Store<S,F.Components>,Array<U32>,A.Notice<S,U32>>,local:W.Handle<S>,target:W.Handle<S>,alien:W.Handle<S>,ownLookup:Maybe<&2,List<&2,U32>>,receiverStatus:List<&2,W.Status>,foreignStatus:List<&2,W.Status>) -> Maybe<Report<S>>:
  match observed:
    case Some{receiver}:stage0(~S,Some{checkpoint(~S,Package{receiver,foreign,local,target,alien,ownLookup,receiverStatus,foreignStatus,[]})})
    case _:None{}
def own_lookup(~S:Data,observed:W.World<S,A.Store<S,F.Components>,Array<U32>,A.Notice<S,U32>> & Maybe<&2,List<&2,U32>>,receiver:W.World<S,A.Store<S,F.Components>,Array<U32>,A.Notice<S,U32>>,local:W.Handle<S>,target:W.Handle<S>,alien:W.Handle<S>,receiverStatus:List<&2,W.Status>,foreignStatus:List<&2,W.Status>) -> Maybe<Report<S>>:
  match observed:
    case (foreign,result):registered(~S,C.writer_registered(~S,Sy.register(~S,~A.Store<S,F.Components>,~Array<U32>,~A.Notice<S,U32>,~O.Input<S>,~Unit,~A.QueueStatus,~O.writer(~S,~F.Components,~Array<U32>,~U32,~F.parent(~S)),W.enqueue(~S,~A.Store<S,F.Components>,~Array<U32>,~A.Notice<S,U32>,receiver,F.tick(~S)),"ForeignParentWriter",["Parent:write"])),foreign,local,target,alien,result,receiverStatus,foreignStatus)
def ready(~S:Data,observed:Maybe<Ready<S>>) -> Maybe<Report<S>>:
  match observed:
    case Some{Ready{Seed{receiver,+local <> +target <> _,receiverStatus},Seed{foreign,+alien <> _,foreignStatus}}}:own_lookup(~S,A.inverse(~S,~F.Components,~Array<U32>,~U32,foreign,F.parent(~S),alien),receiver,local,target,alien,receiverStatus,foreignStatus)
    case _:None{}
def run(~S:Data) -> IO(Maybe<Report<S>>):IO.bind(Maybe<Ready<S>>,Maybe<Report<S>>,created(~S),value => IO.pure(Maybe<Report<S>>,ready(~S,value)))
