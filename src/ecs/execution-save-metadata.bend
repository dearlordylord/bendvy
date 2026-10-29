import Base
import ./world.bend as W
import ./entity-allocator.bend as A
import ./entity-key.bend as Key
import ./clock-state.bend as Clock
import ./execution-lifecycle-notices.bend as Notice
import ./deferred-command.bend as Deferred

type Allocator is Data:
  Allocator{next:U32,high:U32,capacity:U32,depth:Nat,slots:List<&2,A.Slot>,free:List<&2,U32>,order:List<&2,Key.Key>}
type Lifecycle<-S:Data> is Data:
  Lifecycle{namespace:U32,channels:List<&2,Notice.Channel<S>>,nextReader:U32,active:List<&2,Notice.Active>}
type Metadata<-S:Data> is Data:
  Metadata{namespace:U32,allocator:Allocator,clock:Clock.State,lifecycle:Lifecycle<S>}

def right_slots(left:Array<A.Slot>,leftValues:List<&2,A.Slot>,result:Array<A.Slot> & List<&2,A.Slot>) -> Array<A.Slot> & List<&2,A.Slot>:
  match result:
    case (right,rightValues):(ANode{left,right},List.append(&2,A.Slot,leftValues,rightValues))
def joined_slots(leftResult:Array<A.Slot> & List<&2,A.Slot>,rightResult:Array<A.Slot> & List<&2,A.Slot>) -> Array<A.Slot> & List<&2,A.Slot>:
  match leftResult:
    case (left,leftValues):right_slots(left,leftValues,rightResult)
def slots(values:Array<A.Slot>) -> Array<A.Slot> & List<&2,A.Slot>:
  match values:
    case ALeaf{+value}:(ALeaf{value},[value])
    case ANode{left,right}:joined_slots(slots(left),slots(right))
def allocator_slots(+next:U32,+high:U32,+capacity:U32,+depth:Nat,+free:List<&2,U32>,+order:List<&2,Key.Key>,result:Array<A.Slot> & List<&2,A.Slot>) -> A.Allocator & Allocator:
  match result:
    case (actual,values):(A.Allocator{next,high,actual,capacity,depth,free,order},Allocator{next,high,capacity,depth,values,free,order})
def allocator(actual:A.Allocator) -> A.Allocator & Allocator:
  match actual:
    case A.Allocator{next,high,actual,capacity,depth,free,order}:allocator_slots(next,high,capacity,depth,free,order,slots(actual))
def lifecycle(~S:Data,actual:Notice.Journal<S>) -> Notice.Journal<S> & Lifecycle<S>:
  match actual:
    case Notice.Journal{+namespace,+channels,+nextReader,+active}:(Notice.Journal{namespace,channels,nextReader,active},Lifecycle{namespace,channels,nextReader,active})
def captured_lifecycle(~S:Data,~C:Type,~R:Type,~E:Data,+namespace:U32,actual:A.Allocator,metadata:Allocator,store:C,resource:R,events:List<&2,E>,pending:List<Deferred.Command<W.World<S,C,R,E>>>,registrations:List<&2,W.RegistrationMeta>,nextSystemId:U32,+clock:Clock.State,result:Notice.Journal<S> & Lifecycle<S>) -> W.World<S,C,R,E> & Metadata<S>:
  match result:
    case (journal,lifecycle):(W.World{namespace,actual,store,resource,events,pending,registrations,nextSystemId,clock,journal},Metadata{namespace,metadata,clock,lifecycle})
def captured_allocator(~S:Data,~C:Type,~R:Type,~E:Data,namespace:U32,store:C,resource:R,events:List<&2,E>,pending:List<Deferred.Command<W.World<S,C,R,E>>>,registrations:List<&2,W.RegistrationMeta>,nextSystemId:U32,clock:Clock.State,journal:Notice.Journal<S>,result:A.Allocator & Allocator) -> W.World<S,C,R,E> & Metadata<S>:
  match result:
    case (actual,metadata):captured_lifecycle(~S,~C,~R,~E,namespace,actual,metadata,store,resource,events,pending,registrations,nextSystemId,clock,lifecycle(~S,journal))
# Detached metadata accompanies field export. It is not a restored namespace or
# a checkpoint of live reader/system owners; restore must remap those identities.
def capture(~S:Data,~C:Type,~R:Type,~E:Data,world:W.World<S,C,R,E>) -> W.World<S,C,R,E> & Metadata<S>:
  match world:
    case W.World{namespace,actual,store,resource,events,pending,registrations,nextSystemId,clock,journal}:captured_allocator(~S,~C,~R,~E,namespace,store,resource,events,pending,registrations,nextSystemId,clock,journal,allocator(actual))
