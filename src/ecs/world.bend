import Base
import string-equality.bend as SE

# Framework-owned metadata. Independent factory roots are not globally unique.
type Handle<Schema: Data> is Data:
  Handle{namespace: U32, id: U32}
type Factory is Type:
  Factory{nextNamespace: U32}
type RegistrationMeta is Data:
  RegistrationMeta{id: U32, name: String, access: List<&2,String>}
type WorldError is Data:
  MissingEntity{}
  CapacityExceeded{}
  NamespaceExhausted{}
  SystemIdExhausted{}
type World<Schema: Data,Store: Type,Resource: Type,Event: Data> is Type:
  World{namespace: U32,nextId: U32,highWater: U32,live: Array<Bool>,capacity: U32,depth: Nat,store: Store,resource: Resource,events: List<&2,Event>,pending: List<(World<Schema,Store,Resource,Event> -> World<Schema,Store,Resource,Event>)>,registrations: List<&2,RegistrationMeta>,nextSystemId: U32,clock: U32}
type Creation<Schema: Data,Store: Type,Resource: Type,Event: Data> is Type:
  Created{factory: Factory,world: World<Schema,Store,Resource,Event>}
  CreateRejected{factory: Factory,resource: Resource}
type Reservation<Schema: Data> is Data:
  Reserved{handle: Handle<Schema>}
  ReservationRejected{error: WorldError}
type Growth is Type:
  Growth{live: Array<Bool>,capacity: U32,depth: Nat}
type Status is Data:
  Accepted{}
  Rejected{error: WorldError}
type Registration is Data:
  Registered{id: U32}
  RegistrationRejected{error: WorldError}

def factory() -> Factory:
  Factory{1}

def create_checked(~S: Data,~C: Type,~R: Type,~E: Data,~empty: Unit -> C,available: Bool,+namespace: U32,resource: R) -> Creation<S,C,R,E>:
  match available:
    case False{}: CreateRejected{Factory{namespace},resource}
    case True{}: Created{Factory{(namespace + 1 : U32)},World{namespace,1,0,Array.new(Bool,0n,False{}),1,0n,empty(Unit{}),resource,[],[],[],1,0}}

def create(~S: Data,~C: Type,~R: Type,~E: Data,~empty: Unit -> C,factory: Factory,resource: R) -> Creation<S,C,R,E>:
  match factory:
    case Factory{+namespace}: create_checked(~S,~C,~R,~E,~empty,U32.is_lt(namespace,4294967295),namespace,resource)

# Logical capacity/depth describe plane0. A lazy second plane records only
# accepted deferred spawns; legacy raw Worlds retain the single live plane.
def grow_planes(+capacity:U32,+depth:Nat,live:Array<Bool>) -> Growth:
  match live:
    case ANode{visible,pending}:Growth{ANode{ANode{visible,Array.new(Bool,depth,False{})},ANode{pending,Array.new(Bool,depth,False{})}},(capacity * 2 : U32),1n+depth}
    case ALeaf{value}:Growth{ALeaf{value},capacity,depth}
def grow_selected(dual:Bool,+capacity:U32,+depth:Nat,live:Array<Bool>) -> Growth:
  match dual:
    case True{}:grow_planes(capacity,depth,live)
    case False{}:Growth{ANode{live,Array.new(Bool,depth,False{})},(capacity * 2 : U32),1n+depth}
def grow_measured(+capacity:U32,+depth:Nat,measured:Array<Bool> & U32) -> Growth:
  match measured:
    case (live,size):grow_selected(U32.is_eq(size,(capacity * 2 : U32)),capacity,depth,live)

def grow_continue(remaining:Nat,grown:Growth) -> Growth:
  match remaining grown:
    case 0n grown:grown
    case 1n+rest Growth{live,+capacity,+depth}:grow_continue(rest,grow_measured(capacity,depth,Array.size(Bool,live)))
def grow_live(remaining:Nat,capacity:U32,depth:Nat,live:Array<Bool>) -> Growth:
  grow_continue(remaining,Growth{live,capacity,depth})

def reserve_finish(~S: Data,~C: Type,~R: Type,~E: Data,grown: Growth,+namespace: U32,+nextId: U32,+highWater: U32,store: C,resource: R,+events: List<&2,E>,pending: List<(World<S,C,R,E> -> World<S,C,R,E>)>,+registrations: List<&2,RegistrationMeta>,+nextSystemId: U32,+clock: U32) -> World<S,C,R,E> & Reservation<S>:
  match grown:
    case Growth{live,+capacity,+depth}: (World{namespace,(nextId + 1 : U32),nextId,live,capacity,depth,store,resource,events,pending,registrations,nextSystemId,clock},Reserved{Handle{namespace,nextId}})

def reserve_available(~S: Data,~C: Type,~R: Type,~E: Data,available: Bool,grow: Bool,world: World<S,C,R,E>) -> World<S,C,R,E> & Reservation<S>:
  match available grow world:
    case False{} _ world: (world,ReservationRejected{CapacityExceeded{}})
    case True{} False{} World{+namespace,+nextId,+highWater,live,+capacity,+depth,store,resource,+events,pending,+registrations,+nextSystemId,+clock}: reserve_finish(~S,~C,~R,~E,Growth{live,capacity,depth},namespace,nextId,highWater,store,resource,events,pending,registrations,nextSystemId,clock)
    case True{} True{} World{+namespace,+nextId,+highWater,live,+capacity,+depth,store,resource,+events,pending,+registrations,+nextSystemId,+clock}: reserve_finish(~S,~C,~R,~E,grow_live(1n+0n,capacity,depth,live),namespace,nextId,highWater,store,resource,events,pending,registrations,nextSystemId,clock)

def reserve_id(~S: Data,~C: Type,~R: Type,~E: Data,world: World<S,C,R,E>) -> World<S,C,R,E> & Reservation<S>:
  match world:
    case World{+namespace,+nextId,+highWater,live,+capacity,+depth,store,resource,+events,pending,+registrations,+nextSystemId,+clock}: reserve_available(~S,~C,~R,~E,U32.is_lt(nextId,131073),Bool.not(U32.is_lt(nextId,capacity)),World{namespace,nextId,highWater,live,capacity,depth,store,resource,events,pending,registrations,nextSystemId,clock})

def metadata_valid(~S: Data,~C: Type,~R: Type,~E: Data,world: World<S,C,R,E>,handle: Handle<S>) -> World<S,C,R,E> & Bool:
  match world handle:
    case World{+namespace,+nextId,+highWater,live,+capacity,+depth,store,resource,+events,pending,+registrations,+nextSystemId,+clock} Handle{+ns,+id}: (World{namespace,nextId,highWater,live,capacity,depth,store,resource,events,pending,registrations,nextSystemId,clock},Bool.and(U32.is_eq(namespace,ns),Bool.and(U32.is_lt(0,id),U32.is_lt(id,nextId))))

def pending_write_dual(allowed:Bool,live:Array<Bool>,index:U32,value:Bool) -> Array<Bool>:
  match allowed:
    case False{}:live
    case True{}:Array.set(Bool,live,index,value)
def pending_write_shape(legacy:Bool,dual:Bool,+capacity:U32,depth:Nat,+id:U32,value:Bool,live:Array<Bool>) -> Array<Bool>:
  match legacy value:
    case True{} True{}:pending_write_dual(U32.is_lt(id,capacity),ANode{live,Array.new(Bool,depth,False{})},(capacity + id : U32),True{})
    case True{} False{}:live
    case False{} value:pending_write_dual(Bool.and(dual,U32.is_lt(id,capacity)),live,(capacity + id : U32),value)

def pending_write_measured(+capacity:U32,+depth:Nat,+id:U32,value:Bool,measured:Array<Bool> & U32) -> Array<Bool>:
  match measured:
    case (live,+size):pending_write_shape(U32.is_eq(size,capacity),U32.is_eq(size,(capacity * 2 : U32)),capacity,depth,id,value,live)
def pending_write_world(~S:Data,~C:Type,~R:Type,~E:Data,+ns:U32,+next:U32,+high:U32,+capacity:U32,+depth:Nat,store:C,resource:R,+events:List<&2,E>,commands:List<(World<S,C,R,E> -> World<S,C,R,E>)>,+regs:List<&2,RegistrationMeta>,+sid:U32,+clock:U32,live:Array<Bool>) -> World<S,C,R,E>:
  World{ns,next,high,live,capacity,depth,store,resource,events,commands,regs,sid,clock}
def pending_write_checked(~S:Data,~C:Type,~R:Type,~E:Data,value:Bool,allowed:Bool,world:World<S,C,R,E>,handle:Handle<S>) -> World<S,C,R,E>:
  match allowed world handle:
    case False{} world _:world
    case True{} World{ns,next,high,live,+capacity,+depth,store,resource,events,commands,regs,sid,clock} Handle{_,id}:pending_write_world(~S,~C,~R,~E,ns,next,high,capacity,depth,store,resource,events,commands,regs,sid,clock,pending_write_measured(capacity,depth,id,value,Array.size(Bool,live)))
def pending_write_returned(~S:Data,~C:Type,~R:Type,~E:Data,value:Bool,handle:Handle<S>,checked:World<S,C,R,E> & Bool) -> World<S,C,R,E>:
  match checked:
    case (world,allowed):pending_write_checked(~S,~C,~R,~E,value,allowed,world,handle)
def mark_pending(~S:Data,~C:Type,~R:Type,~E:Data,world:World<S,C,R,E>,+handle:Handle<S>) -> World<S,C,R,E>:
  pending_write_returned(~S,~C,~R,~E,True{},handle,metadata_valid(~S,~C,~R,~E,world,handle))
def clear_pending(~S:Data,~C:Type,~R:Type,~E:Data,world:World<S,C,R,E>,+handle:Handle<S>) -> World<S,C,R,E>:
  pending_write_returned(~S,~C,~R,~E,False{},handle,metadata_valid(~S,~C,~R,~E,world,handle))

def set_live_checked(~S: Data,~C: Type,~R: Type,~E: Data,allowed: Bool,value: Bool,world: World<S,C,R,E>,handle: Handle<S>) -> World<S,C,R,E> & Status:
  match allowed world handle:
    case False{} world _: (world,Rejected{MissingEntity{}})
    case True{} World{+namespace,+nextId,+highWater,live,+capacity,+depth,store,resource,+events,pending,+registrations,+nextSystemId,+clock} Handle{_,+id}: (World{namespace,nextId,highWater,Array.set(Bool,live,id,value),capacity,depth,store,resource,events,pending,registrations,nextSystemId,clock},Accepted{})

def set_live_join(~S: Data,~C: Type,~R: Type,~E: Data,value: Bool,handle: Handle<S>,checked: World<S,C,R,E> & Bool) -> World<S,C,R,E> & Status:
  (world,allowed) = checked
  set_live_checked(~S,~C,~R,~E,allowed,value,world,handle)

def activate(~S: Data,~C: Type,~R: Type,~E: Data,world: World<S,C,R,E>,+handle: Handle<S>) -> World<S,C,R,E> & Status:
  set_live_join(~S,~C,~R,~E,True{},handle,metadata_valid(~S,~C,~R,~E,clear_pending(~S,~C,~R,~E,world,handle),handle))

def deactivate(~S: Data,~C: Type,~R: Type,~E: Data,world: World<S,C,R,E>,+handle: Handle<S>) -> World<S,C,R,E> & Status:
  set_live_join(~S,~C,~R,~E,False{},handle,metadata_valid(~S,~C,~R,~E,world,handle))

def live_join(~S: Data,~C: Type,~R: Type,~E: Data,checked: Array<Bool> & Bool,+namespace: U32,+nextId: U32,+highWater: U32,+capacity: U32,+depth: Nat,store: C,resource: R,+events: List<&2,E>,pending: List<(World<S,C,R,E> -> World<S,C,R,E>)>,+registrations: List<&2,RegistrationMeta>,+nextSystemId: U32,+clock: U32) -> World<S,C,R,E> & Bool:
  (live,+found) = checked
  (World{namespace,nextId,highWater,live,capacity,depth,store,resource,events,pending,registrations,nextSystemId,clock},found)

def pending_read_shape(allowed:Bool,live:Array<Bool>,index:U32) -> Array<Bool> & Bool:
  match allowed:
    case False{}:(live,False{})
    case True{}:Array.get(Bool,live,index)
def pending_read(+capacity:U32,+id:U32,measured:Array<Bool> & U32) -> Array<Bool> & Bool:
  match measured:
    case (live,size):pending_read_shape(Bool.and(U32.is_eq(size,(capacity * 2 : U32)),U32.is_lt(id,capacity)),live,(capacity + id : U32))
def pending_checked(~S:Data,~C:Type,~R:Type,~E:Data,allowed:Bool,world:World<S,C,R,E>,handle:Handle<S>) -> World<S,C,R,E> & Bool:
  match allowed world handle:
    case False{} world _:(world,False{})
    case True{} World{ns,next,high,live,+capacity,depth,store,resource,events,commands,regs,sid,clock} Handle{_,id}:live_join(~S,~C,~R,~E,pending_read(capacity,id,Array.size(Bool,live)),ns,next,high,capacity,depth,store,resource,events,commands,regs,sid,clock)
def pending_join(~S:Data,~C:Type,~R:Type,~E:Data,handle:Handle<S>,checked:World<S,C,R,E> & Bool) -> World<S,C,R,E> & Bool:
  match checked:
    case (world,allowed):pending_checked(~S,~C,~R,~E,allowed,world,handle)
def pending_valid(~S:Data,~C:Type,~R:Type,~E:Data,world:World<S,C,R,E>,+handle:Handle<S>) -> World<S,C,R,E> & Bool:
  pending_join(~S,~C,~R,~E,handle,metadata_valid(~S,~C,~R,~E,world,handle))

def valid_checked(~S: Data,~C: Type,~R: Type,~E: Data,allowed: Bool,world: World<S,C,R,E>,handle: Handle<S>) -> World<S,C,R,E> & Bool:
  match allowed world handle:
    case False{} world _: (world,False{})
    case True{} World{+namespace,+nextId,+highWater,live,+capacity,+depth,store,resource,+events,pending,+registrations,+nextSystemId,+clock} Handle{_,id}: live_join(~S,~C,~R,~E,Array.get(Bool,live,id),namespace,nextId,highWater,capacity,depth,store,resource,events,pending,registrations,nextSystemId,clock)

def valid_join(~S: Data,~C: Type,~R: Type,~E: Data,handle: Handle<S>,checked: World<S,C,R,E> & Bool) -> World<S,C,R,E> & Bool:
  (world,allowed) = checked
  valid_checked(~S,~C,~R,~E,allowed,world,handle)

def valid(~S: Data,~C: Type,~R: Type,~E: Data,world: World<S,C,R,E>,+handle: Handle<S>) -> World<S,C,R,E> & Bool:
  valid_join(~S,~C,~R,~E,handle,metadata_valid(~S,~C,~R,~E,world,handle))

def command_live(~S:Data,~C:Type,~R:Type,~E:Data,handle:Handle<S>,checked:World<S,C,R,E> & Bool) -> World<S,C,R,E> & Bool:
  match checked:
    case (world,True{}):(world,True{})
    case (world,False{}):pending_valid(~S,~C,~R,~E,world,handle)
def command_valid(~S:Data,~C:Type,~R:Type,~E:Data,world:World<S,C,R,E>,+handle:Handle<S>) -> World<S,C,R,E> & Bool:
  command_live(~S,~C,~R,~E,handle,valid(~S,~C,~R,~E,world,handle))

def enqueue(~S: Data,~C: Type,~R: Type,~E: Data,world: World<S,C,R,E>,command: World<S,C,R,E> -> World<S,C,R,E>) -> World<S,C,R,E>:
  match world:
    case World{+namespace,+nextId,+highWater,live,+capacity,+depth,store,resource,+events,pending,+registrations,+nextSystemId,+clock}: World{namespace,nextId,highWater,live,capacity,depth,store,resource,events,command <> pending,registrations,nextSystemId,clock}

def drain_fifo(~S: Data,~C: Type,~R: Type,~E: Data,commands: List<(World<S,C,R,E> -> World<S,C,R,E>)>,world: World<S,C,R,E>) -> World<S,C,R,E>:
  match commands:
    case []: world
    case command <> rest: command(drain_fifo(~S,~C,~R,~E,rest,world))

def barrier(~S: Data,~C: Type,~R: Type,~E: Data,world: World<S,C,R,E>) -> World<S,C,R,E>:
  match world:
    case World{+namespace,+nextId,+highWater,live,+capacity,+depth,store,resource,+events,pending,+registrations,+nextSystemId,+clock}: drain_fifo(~S,~C,~R,~E,pending,World{namespace,nextId,highWater,live,capacity,depth,store,resource,events,[],registrations,nextSystemId,clock})

def replace_resource(~S: Data,~C: Type,~R: Type,~E: Data,world: World<S,C,R,E>,replacement: R) -> World<S,C,R,E> & R:
  match world:
    case World{+namespace,+nextId,+highWater,live,+capacity,+depth,store,resource,+events,pending,+registrations,+nextSystemId,+clock}: (World{namespace,nextId,highWater,live,capacity,depth,store,replacement,events,pending,registrations,nextSystemId,clock},resource)

def event_append_loop(~E: Data,reversed: List<&2,E>,+output: List<&2,E>) -> List<&2,E>:
  match reversed:
    case []: output
    case head <> rest: event_append_loop(~E,rest,head <> output)

def event_append(~E: Data,+left: List<&2,E>,+right: List<&2,E>) -> List<&2,E>:
  event_append_loop(~E,List.reverse(&2,E,left),right)

def event_publish_nonempty(~S: Data,~C: Type,~R: Type,~E: Data,world: World<S,C,R,E>,+published: List<&2,E>) -> World<S,C,R,E>:
  match world:
    case World{+namespace,+nextId,+highWater,live,+capacity,+depth,store,resource,+events,pending,+registrations,+nextSystemId,+clock}: World{namespace,nextId,highWater,live,capacity,depth,store,resource,event_append(~E,events,published),pending,registrations,nextSystemId,clock}

# An empty publication changes no field and needs no traversal of retained events.
def event_publish(~S: Data,~C: Type,~R: Type,~E: Data,world: World<S,C,R,E>,+published: List<&2,E>) -> World<S,C,R,E>:
  match published:
    case []: world
    case head <> rest: event_publish_nonempty(~S,~C,~R,~E,world,head <> rest)

def events_view(~S: Data,~C: Type,~R: Type,~E: Data,world: World<S,C,R,E>) -> World<S,C,R,E> & List<&2,E>:
  match world:
    case World{+namespace,+nextId,+highWater,live,+capacity,+depth,store,resource,+events,pending,+registrations,+nextSystemId,+clock}: (World{namespace,nextId,highWater,live,capacity,depth,store,resource,events,pending,registrations,nextSystemId,clock},events)

def observe_resource_finish(~S: Data,~C: Type,~R: Type,~E: Data,~V: Type,observed: R & V,+namespace: U32,+nextId: U32,+highWater: U32,live: Array<Bool>,+capacity: U32,+depth: Nat,store: C,+events: List<&2,E>,pending: List<(World<S,C,R,E> -> World<S,C,R,E>)>,+registrations: List<&2,RegistrationMeta>,+nextSystemId: U32,+clock: U32) -> World<S,C,R,E> & V:
  (resource,value) = observed
  (World{namespace,nextId,highWater,live,capacity,depth,store,resource,events,pending,registrations,nextSystemId,clock},value)

def observe_resource(~S: Data,~C: Type,~R: Type,~E: Data,~V: Type,~project: R -> R & V,world: World<S,C,R,E>) -> World<S,C,R,E> & V:
  match world:
    case World{+namespace,+nextId,+highWater,live,+capacity,+depth,store,resource,+events,pending,+registrations,+nextSystemId,+clock}: observe_resource_finish(~S,~C,~R,~E,~V,project(resource),namespace,nextId,highWater,live,capacity,depth,store,events,pending,registrations,nextSystemId,clock)

def register_checked(~S: Data,~C: Type,~R: Type,~E: Data,available: Bool,world: World<S,C,R,E>,+name: String,+access: List<&2,String>) -> World<S,C,R,E> & Registration:
  match available world:
    case False{} world: (world,RegistrationRejected{SystemIdExhausted{}})
    case True{} World{+namespace,+nextId,+highWater,live,+capacity,+depth,store,resource,+events,pending,+registrations,+nextSystemId,+clock}: (World{namespace,nextId,highWater,live,capacity,depth,store,resource,events,pending,RegistrationMeta{nextSystemId,name,access} <> registrations,(nextSystemId + 1 : U32),clock},Registered{nextSystemId})

def register(~S: Data,~C: Type,~R: Type,~E: Data,world: World<S,C,R,E>,+name: String,+access: List<&2,String>) -> World<S,C,R,E> & Registration:
  match world:
    case World{+namespace,+nextId,+highWater,live,+capacity,+depth,store,resource,+events,pending,+registrations,+nextSystemId,+clock}: register_checked(~S,~C,~R,~E,U32.is_lt(nextSystemId,4294967295),World{namespace,nextId,highWater,live,capacity,depth,store,resource,events,pending,registrations,nextSystemId,clock},name,access)

type HandleScan<Schema: Data> is Type:
  HandleScan{live: Array<Bool>,handles: List<&2,Handle<Schema>>}

def collect_checked(~S: Data,present: Bool,+namespace: U32,+id: U32,handles: List<&2,Handle<S>>) -> List<&2,Handle<S>>:
  match present:
    case False{}: handles
    case True{}: Handle{namespace,id} <> handles

def collect_step(~S: Data,checked: Array<Bool> & Bool,+namespace: U32,+id: U32,handles: List<&2,Handle<S>>) -> HandleScan<S>:
  (live,present) = checked
  HandleScan{live,collect_checked(~S,present,namespace,id,handles)}

def collect_join(~S: Data,scanned: HandleScan<S>,+namespace: U32,+id: U32) -> HandleScan<S>:
  match scanned:
    case HandleScan{live,handles}: collect_step(~S,Array.get(Bool,live,id),namespace,id,handles)

def collect_live(~S: Data,remaining: Nat,+namespace: U32,live: Array<Bool>) -> HandleScan<S>:
  match remaining:
    case 0n: HandleScan{live,[]}
    case 1n++rest: collect_join(~S,collect_live(~S,rest,namespace,live),namespace,U32.from_nat(1n+rest))

def handles_finish(~S: Data,~C: Type,~R: Type,~E: Data,scanned: HandleScan<S>,+namespace: U32,+nextId: U32,+highWater: U32,+capacity: U32,+depth: Nat,store: C,resource: R,+events: List<&2,E>,pending: List<(World<S,C,R,E> -> World<S,C,R,E>)>,+registrations: List<&2,RegistrationMeta>,+nextSystemId: U32,+clock: U32) -> World<S,C,R,E> & List<&2,Handle<S>>:
  match scanned:
    case HandleScan{live,handles}: (World{namespace,nextId,highWater,live,capacity,depth,store,resource,events,pending,registrations,nextSystemId,clock},List.reverse(&2,Handle<S>,handles))

type TailScanPhase<S:Data> is Type:
  WorldTailScanReady{live:Array<Bool>,handles:List<&2,Handle<S>>}
  WorldTailScanRead{checked:Array<Bool> & Bool,handles:List<&2,Handle<S>>}
def collect_tail_loop(~S:Data,fuel:Nat,remaining:Nat,+namespace:U32,phase:TailScanPhase<S>) -> HandleScan<S>:
  match fuel remaining phase:
    case 0n _ WorldTailScanReady{live,handles}: HandleScan{live,handles}
    case 0n _ WorldTailScanRead{(live,_),handles}: HandleScan{live,handles}
    case 1n+more 0n WorldTailScanReady{live,handles}: HandleScan{live,handles}
    case 1n+more 1n++rest WorldTailScanReady{live,handles}: collect_tail_loop(~S,more,1n+rest,namespace,WorldTailScanRead{Array.get(Bool,live,U32.from_nat(1n+rest)),handles})
    case 1n+more 0n WorldTailScanRead{(live,_),handles}: HandleScan{live,handles}
    case 1n+more 1n++rest WorldTailScanRead{(live,present),handles}: collect_tail_loop(~S,more,rest,namespace,WorldTailScanReady{live,collect_checked(~S,present,namespace,U32.from_nat(1n+rest),handles)})

def collect_tail(~S: Data,+remaining: Nat,+namespace: U32,live: Array<Bool>) -> HandleScan<S>:
  collect_tail_loop(~S,Nat.mul(2n,remaining),remaining,namespace,WorldTailScanReady{live,[]})

def handles_tail_finish(~S: Data,~C: Type,~R: Type,~E: Data,scanned: HandleScan<S>,+namespace: U32,+nextId: U32,+highWater: U32,+capacity: U32,+depth: Nat,store: C,resource: R,+events: List<&2,E>,pending: List<(World<S,C,R,E> -> World<S,C,R,E>)>,+registrations: List<&2,RegistrationMeta>,+nextSystemId: U32,+clock: U32) -> World<S,C,R,E> & List<&2,Handle<S>>:
  match scanned:
    case HandleScan{live,handles}: (World{namespace,nextId,highWater,live,capacity,depth,store,resource,events,pending,registrations,nextSystemId,clock},handles)


def handles(~S: Data,~C: Type,~R: Type,~E: Data,world: World<S,C,R,E>) -> World<S,C,R,E> & List<&2,Handle<S>>:
  match world:
    case World{+namespace,+nextId,+highWater,live,+capacity,+depth,store,resource,+events,pending,+registrations,+nextSystemId,+clock}: handles_tail_finish(~S,~C,~R,~E,collect_tail(~S,U32.to_nat(highWater),namespace,live),namespace,nextId,highWater,capacity,depth,store,resource,events,pending,registrations,nextSystemId,clock)

# Exact ordered declaration comparison; no normalization grants capabilities.
def access_equal(xs: List<&2,String>,ys: List<&2,String>) -> Bool:
  match xs ys:
    case Nil{} Nil{}: True{}
    case Nil{} Con{_,_}: False{}
    case Con{_,_} Nil{}: False{}
    case Con{x,xs} Con{y,ys}: Bool.and(SE.equal(x,y),access_equal(xs,ys))

def matching_access(sameName: Bool,metaAccess: List<&2,String>,wantedAccess: List<&2,String>) -> Bool:
  match sameName:
    case False{}: False{}
    case True{}: access_equal(metaAccess,wantedAccess)

def matching_id(sameId: Bool,metaName: String,wantedName: String,metaAccess: List<&2,String>,wantedAccess: List<&2,String>) -> Bool:
  match sameId:
    case False{}: False{}
    case True{}: matching_access(SE.equal(metaName,wantedName),metaAccess,wantedAccess)

def registration_meta_matches(meta: RegistrationMeta,+id: U32,+name: String,+access: List<&2,String>) -> Bool:
  match meta:
    case RegistrationMeta{mid,mname,maccess}: matching_id(U32.is_eq(mid,id),mname,name,maccess,access)

def registration_list_walk(registrations: List<&2,RegistrationMeta>,+id: U32,+name: String,+access: List<&2,String>,found: Bool) -> Bool:
  match registrations found:
    case _ True{}: True{}
    case [] False{}: False{}
    case meta <> rest False{}: registration_list_walk(rest,id,name,access,registration_meta_matches(meta,id,name,access))

def registration_list_matches(registrations: List<&2,RegistrationMeta>,+id: U32,+name: String,+access: List<&2,String>) -> Bool:
  registration_list_walk(registrations,id,name,access,False{})


def namespace(~S: Data,~C: Type,~R: Type,~E: Data,world: World<S,C,R,E>) -> World<S,C,R,E> & U32:
  match world:
    case World{+namespace,+nextId,+highWater,live,+capacity,+depth,store,resource,+events,pending,+registrations,+nextSystemId,+clock}: (World{namespace,nextId,highWater,live,capacity,depth,store,resource,events,pending,registrations,nextSystemId,clock},namespace)

def registration_matches(~S: Data,~C: Type,~R: Type,~E: Data,world: World<S,C,R,E>,+id: U32,+name: String,+access: List<&2,String>) -> World<S,C,R,E> & Bool:
  match world:
    case World{+namespace,+nextId,+highWater,live,+capacity,+depth,store,resource,+events,pending,+registrations,+nextSystemId,+clock}: (World{namespace,nextId,highWater,live,capacity,depth,store,resource,events,pending,registrations,nextSystemId,clock},registration_list_matches(registrations,id,name,access))

def with_store_finish(~S: Data,~C: Type,~R: Type,~E: Data,~Out: Type,observed: C & Out,+namespace: U32,+nextId: U32,+highWater: U32,live: Array<Bool>,+capacity: U32,+depth: Nat,resource: R,+events: List<&2,E>,pending: List<(World<S,C,R,E> -> World<S,C,R,E>)>,+registrations: List<&2,RegistrationMeta>,+nextSystemId: U32,+clock: U32) -> World<S,C,R,E> & Out:
  (store,value) = observed
  (World{namespace,nextId,highWater,live,capacity,depth,store,resource,events,pending,registrations,nextSystemId,clock},value)

def with_store(~S: Data,~C: Type,~R: Type,~E: Data,~Out: Type,effect: C -> C & Out,world: World<S,C,R,E>) -> World<S,C,R,E> & Out:
  match world:
    case World{+namespace,+nextId,+highWater,live,+capacity,+depth,store,resource,+events,pending,+registrations,+nextSystemId,+clock}: with_store_finish(~S,~C,~R,~E,~Out,effect(store),namespace,nextId,highWater,live,capacity,depth,resource,events,pending,registrations,nextSystemId,clock)

def pending_prepend(~S: Data,~C: Type,~R: Type,~E: Data,command: World<S,C,R,E> -> World<S,C,R,E>,counted: List<(World<S,C,R,E> -> World<S,C,R,E>)> & U32) -> List<(World<S,C,R,E> -> World<S,C,R,E>)> & U32:
  (commands,count) = counted
  (command <> commands,(count + 1 : U32))

def pending_length_acc(~S: Data,~C: Type,~R: Type,~E: Data,commands: List<(World<S,C,R,E> -> World<S,C,R,E>)>,reversed: List<(World<S,C,R,E> -> World<S,C,R,E>)>,count: U32) -> List<(World<S,C,R,E> -> World<S,C,R,E>)> & U32:
  match commands:
    case []: (List.reverse(&1,(World<S,C,R,E> -> World<S,C,R,E>),reversed),count)
    case command <> rest: pending_length_acc(~S,~C,~R,~E,rest,command <> reversed,(count + 1 : U32))

def pending_length(~S: Data,~C: Type,~R: Type,~E: Data,commands: List<(World<S,C,R,E> -> World<S,C,R,E>)>) -> List<(World<S,C,R,E> -> World<S,C,R,E>)> & U32:
  pending_length_acc(~S,~C,~R,~E,commands,[],0)

def pending_count_join(~S: Data,~C: Type,~R: Type,~E: Data,+namespace: U32,+nextId: U32,+highWater: U32,live: Array<Bool>,+capacity: U32,+depth: Nat,store: C,resource: R,+events: List<&2,E>,+registrations: List<&2,RegistrationMeta>,+nextSystemId: U32,+clock: U32,counted: List<(World<S,C,R,E> -> World<S,C,R,E>)> & U32) -> World<S,C,R,E> & U32:
  (pending,count) = counted
  (World{namespace,nextId,highWater,live,capacity,depth,store,resource,events,pending,registrations,nextSystemId,clock},count)

def pending_count(~S: Data,~C: Type,~R: Type,~E: Data,world: World<S,C,R,E>) -> World<S,C,R,E> & U32:
  match world:
    case World{+namespace,+nextId,+highWater,live,+capacity,+depth,store,resource,+events,pending,+registrations,+nextSystemId,+clock}: pending_count_join(~S,~C,~R,~E,namespace,nextId,highWater,live,capacity,depth,store,resource,events,registrations,nextSystemId,clock,pending_length(~S,~C,~R,~E,pending))

# Monotonic write clock. Failed transactions may leave unused clock positions;
# their component stamps are restored by the owned inverse journal.
def clock(~S: Data,~C: Type,~R: Type,~E: Data,world: World<S,C,R,E>) -> World<S,C,R,E> & U32:
  match world:
    case World{+namespace,+nextId,+highWater,live,+capacity,+depth,store,resource,+events,pending,+registrations,+nextSystemId,+clock}: (World{namespace,nextId,highWater,live,capacity,depth,store,resource,events,pending,registrations,nextSystemId,clock},clock)

def next_clock(available: Bool,+clock: U32) -> U32:
  match available:
    case False{}: clock
    case True{}: (clock + 1 : U32)

def advance_clock(~S: Data,~C: Type,~R: Type,~E: Data,world: World<S,C,R,E>) -> World<S,C,R,E> & U32:
  match world:
    case World{+namespace,+nextId,+highWater,live,+capacity,+depth,store,resource,+events,pending,+registrations,+nextSystemId,+clock}: (World{namespace,nextId,highWater,live,capacity,depth,store,resource,events,pending,registrations,nextSystemId,next_clock(U32.is_lt(clock,4294967295),clock)},next_clock(U32.is_lt(clock,4294967295),clock))

# Event runtime retention replaces only its owned event domain.
def events_replace(~S: Data,~C: Type,~R: Type,~E: Data,world: World<S,C,R,E>,+retained: List<&2,E>) -> World<S,C,R,E>:
  match world:
    case World{+namespace,+nextId,+highWater,live,+capacity,+depth,store,resource,_,pending,+registrations,+nextSystemId,+clock}: World{namespace,nextId,highWater,live,capacity,depth,store,resource,retained,pending,registrations,nextSystemId,clock}
