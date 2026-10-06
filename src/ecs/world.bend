import Base

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
  World{namespace: U32,nextId: U32,highWater: U32,live: Array<Bool>,capacity: U32,depth: Nat,store: Store,resource: Resource,events: List<&2,Event>,pending: List<(World<Schema,Store,Resource,Event> -> World<Schema,Store,Resource,Event>)>,registrations: List<&2,RegistrationMeta>,nextSystemId: U32}
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
    case True{}: Created{Factory{(namespace + 1 : U32)},World{namespace,1,0,Array.new(Bool,0n,False{}),1,0n,empty(Unit{}),resource,[],[],[],1}}

def create(~S: Data,~C: Type,~R: Type,~E: Data,~empty: Unit -> C,factory: Factory,resource: R) -> Creation<S,C,R,E>:
  match factory:
    case Factory{+namespace}: create_checked(~S,~C,~R,~E,~empty,U32.is_lt(namespace,4294967295),namespace,resource)

def grow_live(remaining: Nat,+capacity: U32,+depth: Nat,live: Array<Bool>) -> Growth:
  match remaining:
    case 0n: Growth{live,capacity,depth}
    case 1n+rest: grow_live(rest,(capacity * 2 : U32),1n+depth,ANode{live,Array.new(Bool,depth,False{})})

def reserve_finish(~S: Data,~C: Type,~R: Type,~E: Data,grown: Growth,+namespace: U32,+nextId: U32,+highWater: U32,store: C,resource: R,+events: List<&2,E>,pending: List<(World<S,C,R,E> -> World<S,C,R,E>)>,+registrations: List<&2,RegistrationMeta>,+nextSystemId: U32) -> World<S,C,R,E> & Reservation<S>:
  match grown:
    case Growth{live,+capacity,+depth}: (World{namespace,(nextId + 1 : U32),nextId,live,capacity,depth,store,resource,events,pending,registrations,nextSystemId},Reserved{Handle{namespace,nextId}})

def reserve_available(~S: Data,~C: Type,~R: Type,~E: Data,available: Bool,grow: Bool,world: World<S,C,R,E>) -> World<S,C,R,E> & Reservation<S>:
  match available grow world:
    case False{} _ world: (world,ReservationRejected{CapacityExceeded{}})
    case True{} False{} World{+namespace,+nextId,+highWater,live,+capacity,+depth,store,resource,+events,pending,+registrations,+nextSystemId}: reserve_finish(~S,~C,~R,~E,Growth{live,capacity,depth},namespace,nextId,highWater,store,resource,events,pending,registrations,nextSystemId)
    case True{} True{} World{+namespace,+nextId,+highWater,live,+capacity,+depth,store,resource,+events,pending,+registrations,+nextSystemId}: reserve_finish(~S,~C,~R,~E,grow_live(1n+0n,capacity,depth,live),namespace,nextId,highWater,store,resource,events,pending,registrations,nextSystemId)

def reserve_id(~S: Data,~C: Type,~R: Type,~E: Data,world: World<S,C,R,E>) -> World<S,C,R,E> & Reservation<S>:
  match world:
    case World{+namespace,+nextId,+highWater,live,+capacity,+depth,store,resource,+events,pending,+registrations,+nextSystemId}: reserve_available(~S,~C,~R,~E,U32.is_lt(nextId,131073),Bool.not(U32.is_lt(nextId,capacity)),World{namespace,nextId,highWater,live,capacity,depth,store,resource,events,pending,registrations,nextSystemId})

def metadata_valid(~S: Data,~C: Type,~R: Type,~E: Data,world: World<S,C,R,E>,handle: Handle<S>) -> World<S,C,R,E> & Bool:
  match world handle:
    case World{+namespace,+nextId,+highWater,live,+capacity,+depth,store,resource,+events,pending,+registrations,+nextSystemId} Handle{+ns,+id}: (World{namespace,nextId,highWater,live,capacity,depth,store,resource,events,pending,registrations,nextSystemId},Bool.and(U32.is_eq(namespace,ns),Bool.and(U32.is_lt(0,id),U32.is_lt(id,nextId))))

def set_live_checked(~S: Data,~C: Type,~R: Type,~E: Data,allowed: Bool,value: Bool,world: World<S,C,R,E>,handle: Handle<S>) -> World<S,C,R,E> & Status:
  match allowed world handle:
    case False{} world _: (world,Rejected{MissingEntity{}})
    case True{} World{+namespace,+nextId,+highWater,live,+capacity,+depth,store,resource,+events,pending,+registrations,+nextSystemId} Handle{_,+id}: (World{namespace,nextId,highWater,Array.set(Bool,live,id,value),capacity,depth,store,resource,events,pending,registrations,nextSystemId},Accepted{})

def set_live_join(~S: Data,~C: Type,~R: Type,~E: Data,value: Bool,handle: Handle<S>,checked: World<S,C,R,E> & Bool) -> World<S,C,R,E> & Status:
  (world,allowed) = checked
  set_live_checked(~S,~C,~R,~E,allowed,value,world,handle)

def activate(~S: Data,~C: Type,~R: Type,~E: Data,world: World<S,C,R,E>,+handle: Handle<S>) -> World<S,C,R,E> & Status:
  set_live_join(~S,~C,~R,~E,True{},handle,metadata_valid(~S,~C,~R,~E,world,handle))

def deactivate(~S: Data,~C: Type,~R: Type,~E: Data,world: World<S,C,R,E>,+handle: Handle<S>) -> World<S,C,R,E> & Status:
  set_live_join(~S,~C,~R,~E,False{},handle,metadata_valid(~S,~C,~R,~E,world,handle))

def live_join(~S: Data,~C: Type,~R: Type,~E: Data,checked: Array<Bool> & Bool,+namespace: U32,+nextId: U32,+highWater: U32,+capacity: U32,+depth: Nat,store: C,resource: R,+events: List<&2,E>,pending: List<(World<S,C,R,E> -> World<S,C,R,E>)>,+registrations: List<&2,RegistrationMeta>,+nextSystemId: U32) -> World<S,C,R,E> & Bool:
  (live,+found) = checked
  (World{namespace,nextId,highWater,live,capacity,depth,store,resource,events,pending,registrations,nextSystemId},found)

def valid_checked(~S: Data,~C: Type,~R: Type,~E: Data,allowed: Bool,world: World<S,C,R,E>,handle: Handle<S>) -> World<S,C,R,E> & Bool:
  match allowed world handle:
    case False{} world _: (world,False{})
    case True{} World{+namespace,+nextId,+highWater,live,+capacity,+depth,store,resource,+events,pending,+registrations,+nextSystemId} Handle{_,id}: live_join(~S,~C,~R,~E,Array.get(Bool,live,id),namespace,nextId,highWater,capacity,depth,store,resource,events,pending,registrations,nextSystemId)

def valid_join(~S: Data,~C: Type,~R: Type,~E: Data,handle: Handle<S>,checked: World<S,C,R,E> & Bool) -> World<S,C,R,E> & Bool:
  (world,allowed) = checked
  valid_checked(~S,~C,~R,~E,allowed,world,handle)

def valid(~S: Data,~C: Type,~R: Type,~E: Data,world: World<S,C,R,E>,+handle: Handle<S>) -> World<S,C,R,E> & Bool:
  valid_join(~S,~C,~R,~E,handle,metadata_valid(~S,~C,~R,~E,world,handle))

def enqueue(~S: Data,~C: Type,~R: Type,~E: Data,world: World<S,C,R,E>,command: World<S,C,R,E> -> World<S,C,R,E>) -> World<S,C,R,E>:
  match world:
    case World{+namespace,+nextId,+highWater,live,+capacity,+depth,store,resource,+events,pending,+registrations,+nextSystemId}: World{namespace,nextId,highWater,live,capacity,depth,store,resource,events,command <> pending,registrations,nextSystemId}

def drain_fifo(~S: Data,~C: Type,~R: Type,~E: Data,commands: List<(World<S,C,R,E> -> World<S,C,R,E>)>,world: World<S,C,R,E>) -> World<S,C,R,E>:
  match commands:
    case []: world
    case command <> rest: command(drain_fifo(~S,~C,~R,~E,rest,world))

def barrier(~S: Data,~C: Type,~R: Type,~E: Data,world: World<S,C,R,E>) -> World<S,C,R,E>:
  match world:
    case World{+namespace,+nextId,+highWater,live,+capacity,+depth,store,resource,+events,pending,+registrations,+nextSystemId}: drain_fifo(~S,~C,~R,~E,pending,World{namespace,nextId,highWater,live,capacity,depth,store,resource,events,[],registrations,nextSystemId})

def replace_resource(~S: Data,~C: Type,~R: Type,~E: Data,world: World<S,C,R,E>,replacement: R) -> World<S,C,R,E> & R:
  match world:
    case World{+namespace,+nextId,+highWater,live,+capacity,+depth,store,resource,+events,pending,+registrations,+nextSystemId}: (World{namespace,nextId,highWater,live,capacity,depth,store,replacement,events,pending,registrations,nextSystemId},resource)

def event_publish(~S: Data,~C: Type,~R: Type,~E: Data,world: World<S,C,R,E>,+published: List<&2,E>) -> World<S,C,R,E>:
  match world:
    case World{+namespace,+nextId,+highWater,live,+capacity,+depth,store,resource,+events,pending,+registrations,+nextSystemId}: World{namespace,nextId,highWater,live,capacity,depth,store,resource,List.append(&2,E,events,published),pending,registrations,nextSystemId}

def events_view(~S: Data,~C: Type,~R: Type,~E: Data,world: World<S,C,R,E>) -> World<S,C,R,E> & List<&2,E>:
  match world:
    case World{+namespace,+nextId,+highWater,live,+capacity,+depth,store,resource,+events,pending,+registrations,+nextSystemId}: (World{namespace,nextId,highWater,live,capacity,depth,store,resource,events,pending,registrations,nextSystemId},events)

def observe_resource_finish(~S: Data,~C: Type,~R: Type,~E: Data,~V: Type,observed: R & V,+namespace: U32,+nextId: U32,+highWater: U32,live: Array<Bool>,+capacity: U32,+depth: Nat,store: C,+events: List<&2,E>,pending: List<(World<S,C,R,E> -> World<S,C,R,E>)>,+registrations: List<&2,RegistrationMeta>,+nextSystemId: U32) -> World<S,C,R,E> & V:
  (resource,value) = observed
  (World{namespace,nextId,highWater,live,capacity,depth,store,resource,events,pending,registrations,nextSystemId},value)

def observe_resource(~S: Data,~C: Type,~R: Type,~E: Data,~V: Type,~project: R -> R & V,world: World<S,C,R,E>) -> World<S,C,R,E> & V:
  match world:
    case World{+namespace,+nextId,+highWater,live,+capacity,+depth,store,resource,+events,pending,+registrations,+nextSystemId}: observe_resource_finish(~S,~C,~R,~E,~V,project(resource),namespace,nextId,highWater,live,capacity,depth,store,events,pending,registrations,nextSystemId)

def register_checked(~S: Data,~C: Type,~R: Type,~E: Data,available: Bool,world: World<S,C,R,E>,+name: String,+access: List<&2,String>) -> World<S,C,R,E> & Registration:
  match available world:
    case False{} world: (world,RegistrationRejected{SystemIdExhausted{}})
    case True{} World{+namespace,+nextId,+highWater,live,+capacity,+depth,store,resource,+events,pending,+registrations,+nextSystemId}: (World{namespace,nextId,highWater,live,capacity,depth,store,resource,events,pending,RegistrationMeta{nextSystemId,name,access} <> registrations,(nextSystemId + 1 : U32)},Registered{nextSystemId})

def register(~S: Data,~C: Type,~R: Type,~E: Data,world: World<S,C,R,E>,+name: String,+access: List<&2,String>) -> World<S,C,R,E> & Registration:
  match world:
    case World{+namespace,+nextId,+highWater,live,+capacity,+depth,store,resource,+events,pending,+registrations,+nextSystemId}: register_checked(~S,~C,~R,~E,U32.is_lt(nextSystemId,4294967295),World{namespace,nextId,highWater,live,capacity,depth,store,resource,events,pending,registrations,nextSystemId},name,access)

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

def handles_finish(~S: Data,~C: Type,~R: Type,~E: Data,scanned: HandleScan<S>,+namespace: U32,+nextId: U32,+highWater: U32,+capacity: U32,+depth: Nat,store: C,resource: R,+events: List<&2,E>,pending: List<(World<S,C,R,E> -> World<S,C,R,E>)>,+registrations: List<&2,RegistrationMeta>,+nextSystemId: U32) -> World<S,C,R,E> & List<&2,Handle<S>>:
  match scanned:
    case HandleScan{live,handles}: (World{namespace,nextId,highWater,live,capacity,depth,store,resource,events,pending,registrations,nextSystemId},List.reverse(&2,Handle<S>,handles))

def handles(~S: Data,~C: Type,~R: Type,~E: Data,world: World<S,C,R,E>) -> World<S,C,R,E> & List<&2,Handle<S>>:
  match world:
    case World{+namespace,+nextId,+highWater,live,+capacity,+depth,store,resource,+events,pending,+registrations,+nextSystemId}: handles_finish(~S,~C,~R,~E,collect_live(~S,U32.to_nat(highWater),namespace,live),namespace,nextId,highWater,capacity,depth,store,resource,events,pending,registrations,nextSystemId)

# Exact ordered declaration comparison; no normalization grants capabilities.
def access_equal(xs: List<&2,String>,ys: List<&2,String>) -> Bool:
  match xs ys:
    case Nil{} Nil{}: True{}
    case Nil{} Con{_,_}: False{}
    case Con{_,_} Nil{}: False{}
    case Con{x,xs} Con{y,ys}: Bool.and(String.eq(x,y),access_equal(xs,ys))

def registration_meta_matches(meta: RegistrationMeta,+id: U32,+name: String,+access: List<&2,String>) -> Bool:
  match meta:
    case RegistrationMeta{mid,mname,maccess}: Bool.and(U32.is_eq(mid,id),Bool.and(String.eq(mname,name),access_equal(maccess,access)))

def registration_list_matches(registrations: List<&2,RegistrationMeta>,+id: U32,+name: String,+access: List<&2,String>) -> Bool:
  match registrations:
    case []: False{}
    case meta <> rest: Bool.or(registration_meta_matches(meta,id,name,access),registration_list_matches(rest,id,name,access))

def namespace(~S: Data,~C: Type,~R: Type,~E: Data,world: World<S,C,R,E>) -> World<S,C,R,E> & U32:
  match world:
    case World{+namespace,+nextId,+highWater,live,+capacity,+depth,store,resource,+events,pending,+registrations,+nextSystemId}: (World{namespace,nextId,highWater,live,capacity,depth,store,resource,events,pending,registrations,nextSystemId},namespace)

def registration_matches(~S: Data,~C: Type,~R: Type,~E: Data,world: World<S,C,R,E>,+id: U32,+name: String,+access: List<&2,String>) -> World<S,C,R,E> & Bool:
  match world:
    case World{+namespace,+nextId,+highWater,live,+capacity,+depth,store,resource,+events,pending,+registrations,+nextSystemId}: (World{namespace,nextId,highWater,live,capacity,depth,store,resource,events,pending,registrations,nextSystemId},registration_list_matches(registrations,id,name,access))

def with_store_finish(~S: Data,~C: Type,~R: Type,~E: Data,~Out: Type,observed: C & Out,+namespace: U32,+nextId: U32,+highWater: U32,live: Array<Bool>,+capacity: U32,+depth: Nat,resource: R,+events: List<&2,E>,pending: List<(World<S,C,R,E> -> World<S,C,R,E>)>,+registrations: List<&2,RegistrationMeta>,+nextSystemId: U32) -> World<S,C,R,E> & Out:
  (store,value) = observed
  (World{namespace,nextId,highWater,live,capacity,depth,store,resource,events,pending,registrations,nextSystemId},value)

def with_store(~S: Data,~C: Type,~R: Type,~E: Data,~Out: Type,effect: C -> C & Out,world: World<S,C,R,E>) -> World<S,C,R,E> & Out:
  match world:
    case World{+namespace,+nextId,+highWater,live,+capacity,+depth,store,resource,+events,pending,+registrations,+nextSystemId}: with_store_finish(~S,~C,~R,~E,~Out,effect(store),namespace,nextId,highWater,live,capacity,depth,resource,events,pending,registrations,nextSystemId)
