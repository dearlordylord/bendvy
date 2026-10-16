import Base
import ../../../../../src/ecs/world.bend as W
import ../../../../../src/ecs/column.bend as Col
import ../../../../../src/ecs/lifecycle.bend as L
import ./storage.bend as Storage
import ./step.bend as Step
import ./events.bend as Events

type LiveTree is Data:
  LiveLeaf{value:Bool}
  LiveNode{left:LiveTree,right:LiveTree}
type StampRow is Data:
  StampRow{id:U32,position:L.Stamp,velocity:L.Stamp,health:L.Stamp}
type WorldMetadata is Data:
  WorldMetadata{namespace:U32,capacity:U32,depth:Nat,live:LiveTree,registrations:List<&2,W.RegistrationMeta>,nextSystemId:U32,lifecycles:List<&2,StampRow>}
def live_join(left:Array<Bool>,leftView:LiveTree,observed:Array<Bool> & LiveTree) -> Array<Bool> & LiveTree:
  (right,rightView)=observed
  (ANode{left,right},LiveNode{leftView,rightView})
def live_left(next:Unit -> Array<Bool> & LiveTree,observed:Array<Bool> & LiveTree) -> Array<Bool> & LiveTree:
  (left,leftView)=observed
  live_join(left,leftView,next(Unit{}))
def live(value:Array<Bool>) -> Array<Bool> & LiveTree:
  match value:
    case ALeaf{+value}:(ALeaf{value},LiveLeaf{value})
    case ANode{left,right}:live_left(_ => live(right),live(left))
def health(~S:Data,id:U32,position:Col.Column<S,Array<U32>>,velocity:Col.Column<S,Array<U32>>,ps:L.Stamp,vs:L.Stamp,observed:Col.Column<S,Array<U32>> & L.Stamp) -> Storage.Store<S> & StampRow:
  (health,hs)=observed
  (Storage.Store{position,velocity,health},StampRow{id,ps,vs,hs})
def velocity(~S:Data,+id:U32,position:Col.Column<S,Array<U32>>,healthColumn:Col.Column<S,Array<U32>>,ps:L.Stamp,observed:Col.Column<S,Array<U32>> & L.Stamp) -> Storage.Store<S> & StampRow:
  (velocity,vs)=observed
  health(~S,id,position,velocity,ps,vs,Col.lifecycle(~S,~Array<U32>,healthColumn,id))
def position(~S:Data,+id:U32,velocityColumn:Col.Column<S,Array<U32>>,healthColumn:Col.Column<S,Array<U32>>,observed:Col.Column<S,Array<U32>> & L.Stamp) -> Storage.Store<S> & StampRow:
  (position,ps)=observed
  velocity(~S,id,position,healthColumn,ps,Col.lifecycle(~S,~Array<U32>,velocityColumn,id))
def row(~S:Data,+id:U32,store:Storage.Store<S>) -> Storage.Store<S> & StampRow:
  match store:
    case Storage.Store{positionColumn,velocityColumn,healthColumn}:position(~S,id,velocityColumn,healthColumn,Col.lifecycle(~S,~Array<U32>,positionColumn,id))
def prepend(~S:Data,value:StampRow,observed:Storage.Store<S> & List<&2,StampRow>) -> Storage.Store<S> & List<&2,StampRow>:
  (store,rest)=observed
  (store,value <> rest)
def stepped(~S:Data,next:Storage.Store<S> -> Storage.Store<S> & List<&2,StampRow>,observed:Storage.Store<S> & StampRow) -> Storage.Store<S> & List<&2,StampRow>:
  (store,value)=observed
  prepend(~S,value,next(store))
def rows(~S:Data,count:Nat,+id:U32,store:Storage.Store<S>) -> Storage.Store<S> & List<&2,StampRow>:
  match count:
    case 0n:(store,[])
    case 1n+rest:stepped(~S,store => rows(~S,rest,(id + 1 : U32),store),row(~S,id,store))
def stamps_done(~S:Data,namespace:U32,capacity:U32,depth:Nat,tree:LiveTree,registrations:List<&2,W.RegistrationMeta>,nextSystemId:U32,observed:Step.World(~S) & List<&2,StampRow>) -> Step.World(~S) & WorldMetadata:
  (world,stamps)=observed
  (world,WorldMetadata{namespace,capacity,depth,tree,registrations,nextSystemId,stamps})
def live_done(~S:Data,+namespace:U32,+nextId:U32,+highWater:U32,+capacity:U32,+depth:Nat,store:Storage.Store<S>,resource:Array<U32>,+events:List<&2,Events.SimulationEvent>,pending:List<(Step.World(~S) -> Step.World(~S))>,+registrations:List<&2,W.RegistrationMeta>,+nextSystemId:U32,+clock:U32,observed:Array<Bool> & LiveTree) -> Step.World(~S) & WorldMetadata:
  (live,tree)=observed
  stamps_done(~S,namespace,capacity,depth,tree,registrations,nextSystemId,W.with_store(~S,~Storage.Store<S>,~Array<U32>,~Events.SimulationEvent,~List<&2,StampRow>,store => rows(~S,U32.to_nat(highWater),1,store),W.World{namespace,nextId,highWater,live,capacity,depth,store,resource,events,pending,registrations,nextSystemId,clock}))
def world(~S:Data,world:Step.World(~S)) -> Step.World(~S) & WorldMetadata:
  match world:
    case W.World{+namespace,+nextId,+highWater,liveArray,+capacity,+depth,store,resource,+events,pending,+registrations,+nextSystemId,+clock}:live_done(~S,namespace,nextId,highWater,capacity,depth,store,resource,events,pending,registrations,nextSystemId,clock,live(liveArray))
