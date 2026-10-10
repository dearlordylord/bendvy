import Base
import ../mutation-composition-v1/fixture.bend as F
import ../mutation-composition-v1/operations.bend as O
import ../mutation-composition-v1/consumer.bend as C
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/relation-types.bend as G
import /workspace/formal-proofs/bendvy/src/ecs/relation-commands.bend as A
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sy
import /workspace/formal-proofs/bendvy/src/ecs/relation-providers.bend as P
type Seed<S:Data> is Type: Seed{world:W.World<S,A.Store<S,F.Components>,Array<U32>,A.Notice<S,U32>>,handles:List<&2,W.Handle<S>>,statuses:List<&2,W.Status>}
type Ready<S:Data> is Type: Ready{factory:W.Factory,receiver:Seed<S>,foreign:Seed<S>}
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
def second_seeded(~S:Data,receiver:Seed<S>,factory:W.Factory,observed:Maybe<Seed<S>>) -> Maybe<Ready<S>>:
  match observed:
    case Some{foreign}:Some{Ready{factory,receiver,foreign}}
    case _:None{}
def second_created(~S:Data,receiver:Seed<S>,observed:W.Creation<S,A.Store<S,F.Components>,Array<U32>,A.Notice<S,U32>>) -> Maybe<Ready<S>>:
  match observed:
    case W.Created{factory,world}:second_seeded(~S,receiver,factory,seeded(~S,world))
    case _:None{}
def first_seeded(~S:Data,factory:W.Factory,observed:Maybe<Seed<S>>) -> Maybe<Ready<S>>:
  match observed:
    case Some{receiver}:second_created(~S,receiver,W.create(~S,~A.Store<S,F.Components>,~Array<U32>,~A.Notice<S,U32>,~empty(~S),factory,ANode{ALeaf{177},ALeaf{188}}))
    case _:None{}
def first_created(~S:Data,observed:W.Creation<S,A.Store<S,F.Components>,Array<U32>,A.Notice<S,U32>>) -> Maybe<Ready<S>>:
  match observed:
    case W.Created{factory,world}:first_seeded(~S,factory,seeded(~S,world))
    case _:None{}
def created(~S:Data) -> Maybe<Ready<S>>:first_created(~S,W.create(~S,~A.Store<S,F.Components>,~Array<U32>,~A.Notice<S,U32>,~empty(~S),W.factory(),ANode{ALeaf{77},ALeaf{88}}))
type Package<S:Data> is Type: Package{receiver:C.State<S>,foreign:W.World<S,A.Store<S,F.Components>,Array<U32>,A.Notice<S,U32>>,factory:W.Factory,local:W.Handle<S>,alien:W.Handle<S>,ownLookup:Maybe<&2,List<&2,U32>>,receiverStatus:List<&2,W.Status>,foreignStatus:List<&2,W.Status>,foreignSnapshots:List<&2,String>}
type Report<S:Data> is Data: Report{receiver:C.Report<S>,foreignSnapshots:List<&2,String>,factoryNext:U32,local:W.Handle<S>,alien:W.Handle<S>,ownLookup:Maybe<&2,List<&2,U32>>,receiverStatus:List<&2,W.Status>,foreignStatus:List<&2,W.Status>}
def checkpoint_done(~S:Data,receiver:C.State<S>,factory:W.Factory,+local:W.Handle<S>,+alien:W.Handle<S>,ownLookup:Maybe<&2,List<&2,U32>>,receiverStatus:List<&2,W.Status>,foreignStatus:List<&2,W.Status>,foreignSnapshots:List<&2,String>,observed:W.World<S,A.Store<S,F.Components>,Array<U32>,A.Notice<S,U32>> & String) -> Package<S>:
  match observed:
    case (foreign,text):Package{C.snapshot(~S,receiver),foreign,factory,local,alien,ownLookup,receiverStatus,foreignStatus,text <> foreignSnapshots}
def checkpoint(~S:Data,value:Package<S>) -> Package<S>:
  match value:
    case Package{receiver,foreign,factory,local,alien,ownLookup,receiverStatus,foreignStatus,foreignSnapshots}:checkpoint_done(~S,receiver,factory,local,alien,ownLookup,receiverStatus,foreignStatus,foreignSnapshots,F.observe(~S,foreign))
def updated(~S:Data,observed:Maybe<C.State<S>>,foreign:W.World<S,A.Store<S,F.Components>,Array<U32>,A.Notice<S,U32>>,factory:W.Factory,local:W.Handle<S>,alien:W.Handle<S>,ownLookup:Maybe<&2,List<&2,U32>>,receiverStatus:List<&2,W.Status>,foreignStatus:List<&2,W.Status>,foreignSnapshots:List<&2,String>) -> Maybe<Package<S>>:
  match observed:
    case Some{receiver}:Some{Package{receiver,foreign,factory,local,alien,ownLookup,receiverStatus,foreignStatus,foreignSnapshots}}
    case _:None{}
type Operation is Data: ForeignSource{} ForeignTarget{} ForeignClear{}
def request(~S:Data,mode:Operation,+local:W.Handle<S>,+alien:W.Handle<S>) -> O.Input<S>:
  match mode:
    case ForeignSource{}:O.Replace{P.Targets{alien,local}}
    case ForeignTarget{}:O.Replace{P.Targets{local,alien}}
    case ForeignClear{}:O.Clear{alien}
def write(~S:Data,value:Package<S>,mode:Operation) -> Maybe<Package<S>>:
  match value:
    case Package{receiver,foreign,factory,+local,+alien,ownLookup,receiverStatus,foreignStatus,foreignSnapshots}:updated(~S,C.write(~S,receiver,request(~S,mode,local,alien)),foreign,factory,local,alien,ownLookup,receiverStatus,foreignStatus,foreignSnapshots)
def barrier(~S:Data,value:Package<S>) -> Package<S>:
  match value:
    case Package{receiver,foreign,factory,local,alien,ownLookup,receiverStatus,foreignStatus,foreignSnapshots}:Package{C.barrier(~S,receiver),foreign,factory,local,alien,ownLookup,receiverStatus,foreignStatus,foreignSnapshots}
def deliver(~S:Data,value:Package<S>) -> Maybe<Package<S>>:
  match value:
    case Package{receiver,foreign,factory,local,alien,ownLookup,receiverStatus,foreignStatus,foreignSnapshots}:updated(~S,C.deliver(~S,receiver),foreign,factory,local,alien,ownLookup,receiverStatus,foreignStatus,foreignSnapshots)
def finish(~S:Data,value:Package<S>) -> Report<S>:
  match value:
    case Package{receiver,_,W.Factory{next},local,alien,ownLookup,receiverStatus,foreignStatus,foreignSnapshots}:Report{C.finish(~S,receiver),List.reverse(&2,String,foreignSnapshots),next,local,alien,ownLookup,receiverStatus,foreignStatus}
def completed(~S:Data,observed:Maybe<Package<S>>) -> Maybe<Report<S>>:
  match observed:
    case Some{value}:Some{finish(~S,checkpoint(~S,value))}
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
def registered(~S:Data,observed:Maybe<C.State<S>>,foreign:W.World<S,A.Store<S,F.Components>,Array<U32>,A.Notice<S,U32>>,factory:W.Factory,local:W.Handle<S>,alien:W.Handle<S>,ownLookup:Maybe<&2,List<&2,U32>>,receiverStatus:List<&2,W.Status>,foreignStatus:List<&2,W.Status>) -> Maybe<Report<S>>:
  match observed:
    case Some{receiver}:stage0(~S,Some{checkpoint(~S,Package{receiver,foreign,factory,local,alien,ownLookup,receiverStatus,foreignStatus,[]})})
    case _:None{}
def own_lookup(~S:Data,observed:W.World<S,A.Store<S,F.Components>,Array<U32>,A.Notice<S,U32>> & Maybe<&2,List<&2,U32>>,receiver:W.World<S,A.Store<S,F.Components>,Array<U32>,A.Notice<S,U32>>,factory:W.Factory,local:W.Handle<S>,alien:W.Handle<S>,receiverStatus:List<&2,W.Status>,foreignStatus:List<&2,W.Status>) -> Maybe<Report<S>>:
  match observed:
    case (foreign,result):registered(~S,C.writer_registered(~S,Sy.register(~S,~A.Store<S,F.Components>,~Array<U32>,~A.Notice<S,U32>,~O.Input<S>,~Unit,~A.QueueStatus,~O.writer(~S,~F.Components,~Array<U32>,~U32,~F.parent(~S)),W.enqueue(~S,~A.Store<S,F.Components>,~Array<U32>,~A.Notice<S,U32>,receiver,F.tick(~S)),"ForeignParentWriter",["Parent:write"])),foreign,factory,local,alien,result,receiverStatus,foreignStatus)
def ready(~S:Data,observed:Maybe<Ready<S>>) -> Maybe<Report<S>>:
  match observed:
    case Some{Ready{factory,Seed{receiver,+local <> _,receiverStatus},Seed{foreign,+alien <> _,foreignStatus}}}:own_lookup(~S,A.inverse(~S,~F.Components,~Array<U32>,~U32,foreign,F.parent(~S),alien),receiver,factory,local,alien,receiverStatus,foreignStatus)
    case _:None{}
def run(~S:Data) -> Maybe<Report<S>>:ready(~S,created(~S))
