import Base
import trace-facts.bend as TraceFacts
import deferred-command.bend as Deferred
import string-equality.bend as SE
import entity-key.bend as K
import entity-allocator.bend as A

# Framework-owned metadata. Independent factory roots are not globally unique.
type Handle<Schema: Data> is Data:
  Handle{namespace: U32, key: K.Key}
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
  World{namespace: U32,allocator: A.Allocator,store: Store,resource: Resource,events: List<&2,Event>,pending:List<Deferred.Command<World<Schema,Store,Resource,Event>>>,registrations: List<&2,RegistrationMeta>,nextSystemId: U32,clock: U32}
type Creation<Schema: Data,Store: Type,Resource: Type,Event: Data> is Type:
  Created{factory: Factory,world: World<Schema,Store,Resource,Event>}
  CreateRejected{factory: Factory,resource: Resource}
type Reservation<Schema: Data> is Data:
  Reserved{handle: Handle<Schema>}
  ReservationRejected{error: WorldError}
type Status is Data:
  Accepted{}
  Rejected{error: WorldError}
type Registration is Data:
  Registered{id: U32}
  RegistrationRejected{error: WorldError}

def handle_index(~S:Data,handle:Handle<S>) -> U32:
  match handle:
    case Handle{_,key}:K.index(key)
def handle_key(~S:Data,handle:Handle<S>) -> K.Key:
  match handle:
    case Handle{_,key}:key

def factory() -> Factory:
  Factory{1}
def create_checked(~S:Data,~C:Type,~R:Type,~E:Data,~empty:Unit -> C,available:Bool,+namespace:U32,resource:R) -> Creation<S,C,R,E>:
  match available:
    case False{}:CreateRejected{Factory{namespace},resource}
    case True{}:Created{Factory{(namespace + 1 : U32)},World{namespace,A.empty(),empty(Unit{}),resource,[],[],[],1,0}}
def create(~S:Data,~C:Type,~R:Type,~E:Data,~empty:Unit -> C,factory:Factory,resource:R) -> Creation<S,C,R,E>:
  match factory:
    case Factory{+namespace}:create_checked(~S,~C,~R,~E,~empty,U32.is_lt(namespace,4294967295),namespace,resource)
def reserve_result(~S:Data,~C:Type,~R:Type,~E:Data,+namespace:U32,store:C,resource:R,+events:List<&2,E>,pending:List<Deferred.Command<World<S,C,R,E>>>,+registrations:List<&2,RegistrationMeta>,+nextSystemId:U32,+clock:U32,allocator:A.Allocator,reservation:A.Reservation) -> World<S,C,R,E> & Reservation<S>:
  match reservation:
    case A.Exhausted{}:(World{namespace,allocator,store,resource,events,pending,registrations,nextSystemId,clock},ReservationRejected{CapacityExceeded{}})
    case A.Reserved{key}:(World{namespace,allocator,store,resource,events,pending,registrations,nextSystemId,clock},Reserved{Handle{namespace,key}})
def reserve_join(~S:Data,~C:Type,~R:Type,~E:Data,+namespace:U32,store:C,resource:R,+events:List<&2,E>,pending:List<Deferred.Command<World<S,C,R,E>>>,+registrations:List<&2,RegistrationMeta>,+nextSystemId:U32,+clock:U32,reserved:A.Allocator & A.Reservation) -> World<S,C,R,E> & Reservation<S>:
  (allocator,reservation) = reserved
  reserve_result(~S,~C,~R,~E,namespace,store,resource,events,pending,registrations,nextSystemId,clock,allocator,reservation)
def reserve_id(~S:Data,~C:Type,~R:Type,~E:Data,world:World<S,C,R,E>) -> World<S,C,R,E> & Reservation<S>:
  match world:
    case World{namespace,allocator,store,resource,events,pending,registrations,nextSystemId,clock}:reserve_join(~S,~C,~R,~E,namespace,store,resource,events,pending,registrations,nextSystemId,clock,A.reserve(allocator))
def checked_join(~S:Data,~C:Type,~R:Type,~E:Data,namespace:U32,store:C,resource:R,events:List<&2,E>,pending:List<Deferred.Command<World<S,C,R,E>>>,registrations:List<&2,RegistrationMeta>,nextSystemId:U32,clock:U32,checked:A.Allocator & Bool) -> World<S,C,R,E> & Bool:
  match checked:
    case (allocator,valid):(World{namespace,allocator,store,resource,events,pending,registrations,nextSystemId,clock},valid)
def checked_namespace(~S:Data,~C:Type,~R:Type,~E:Data,allowed:Bool,mode:U32,world:World<S,C,R,E>,key:K.Key) -> World<S,C,R,E> & Bool:
  match allowed world:
    case False{} world:(world,False{})
    case True{} World{namespace,allocator,store,resource,events,pending,registrations,nextSystemId,clock}:checked_join(~S,~C,~R,~E,namespace,store,resource,events,pending,registrations,nextSystemId,clock,A.checked(allocator,key,mode))
def checked(~S:Data,~C:Type,~R:Type,~E:Data,mode:U32,world:World<S,C,R,E>,handle:Handle<S>) -> World<S,C,R,E> & Bool:
  match world handle:
    case World{+namespace,allocator,store,resource,events,pending,registrations,nextSystemId,clock} Handle{ns,key}:checked_namespace(~S,~C,~R,~E,U32.is_eq(namespace,ns),mode,World{namespace,allocator,store,resource,events,pending,registrations,nextSystemId,clock},key)
def metadata_valid(~S:Data,~C:Type,~R:Type,~E:Data,world:World<S,C,R,E>,handle:Handle<S>) -> World<S,C,R,E> & Bool:
  checked(~S,~C,~R,~E,0,world,handle)
def valid(~S:Data,~C:Type,~R:Type,~E:Data,world:World<S,C,R,E>,handle:Handle<S>) -> World<S,C,R,E> & Bool:
  checked(~S,~C,~R,~E,1,world,handle)
def pending_valid(~S:Data,~C:Type,~R:Type,~E:Data,world:World<S,C,R,E>,handle:Handle<S>) -> World<S,C,R,E> & Bool:
  checked(~S,~C,~R,~E,2,world,handle)
def phase_checked(~S:Data,~C:Type,~R:Type,~E:Data,phase:A.Phase,key:K.Key,checked:World<S,C,R,E> & Bool) -> World<S,C,R,E> & Status:
  match checked:
    case (world,False{}):(world,Rejected{MissingEntity{}})
    case (World{namespace,allocator,store,resource,events,pending,registrations,nextSystemId,clock},True{}):(World{namespace,A.write_phase(allocator,key,phase),store,resource,events,pending,registrations,nextSystemId,clock},Accepted{})
def activate(~S:Data,~C:Type,~R:Type,~E:Data,world:World<S,C,R,E>,+handle:Handle<S>) -> World<S,C,R,E> & Status:
  phase_checked(~S,~C,~R,~E,A.Live{},handle_key(~S,handle),metadata_valid(~S,~C,~R,~E,world,handle))
# Opaque storage is retained; this operation cannot make its slot reusable.
def deactivate(~S:Data,~C:Type,~R:Type,~E:Data,world:World<S,C,R,E>,+handle:Handle<S>) -> World<S,C,R,E> & Status:
  phase_checked(~S,~C,~R,~E,A.DeadRetained{},handle_key(~S,handle),metadata_valid(~S,~C,~R,~E,world,handle))
def discard_status(~S:Data,~C:Type,~R:Type,~E:Data,observed:World<S,C,R,E> & Status) -> World<S,C,R,E>:
  match observed:
    case (world,_):world
def mark_pending(~S:Data,~C:Type,~R:Type,~E:Data,world:World<S,C,R,E>,+handle:Handle<S>) -> World<S,C,R,E>:
  discard_status(~S,~C,~R,~E,phase_checked(~S,~C,~R,~E,A.Pending{},handle_key(~S,handle),metadata_valid(~S,~C,~R,~E,world,handle)))
def owner_change(~S:Data,~C:Type,~R:Type,~E:Data,release:Bool,+key:K.Key,checked:World<S,C,R,E> & Bool) -> World<S,C,R,E>:
  match release checked:
    case _, (world,False{}):world
    case False{}, (World{namespace,allocator,store,resource,events,pending,registrations,nextSystemId,clock},True{}):World{namespace,A.abandon(allocator,key),store,resource,events,pending,registrations,nextSystemId,clock}
    case True{}, (World{namespace,allocator,store,resource,events,pending,registrations,nextSystemId,clock},True{}):World{namespace,A.release(allocator,key),store,resource,events,pending,registrations,nextSystemId,clock}
def clear_pending(~S:Data,~C:Type,~R:Type,~E:Data,world:World<S,C,R,E>,+handle:Handle<S>) -> World<S,C,R,E>:
  owner_change(~S,~C,~R,~E,False{},handle_key(~S,handle),pending_valid(~S,~C,~R,~E,world,handle))
# Only schema-owned cleanup calls this after all payloads and stamps are cleared.
def release_cleared(~S:Data,~C:Type,~R:Type,~E:Data,world:World<S,C,R,E>,+handle:Handle<S>) -> World<S,C,R,E>:
  owner_change(~S,~C,~R,~E,True{},handle_key(~S,handle),metadata_valid(~S,~C,~R,~E,world,handle))
def command_live(~S:Data,~C:Type,~R:Type,~E:Data,handle:Handle<S>,checked:World<S,C,R,E> & Bool) -> World<S,C,R,E> & Bool:
  match checked:
    case (world,True{}):(world,True{})
    case (world,False{}):pending_valid(~S,~C,~R,~E,world,handle)
def command_valid(~S:Data,~C:Type,~R:Type,~E:Data,world:World<S,C,R,E>,+handle:Handle<S>) -> World<S,C,R,E> & Bool:
  command_live(~S,~C,~R,~E,handle,valid(~S,~C,~R,~E,world,handle))

def enqueue_command(~S:Data,~C:Type,~R:Type,~E:Data,world:World<S,C,R,E>,command:Deferred.Command<World<S,C,R,E>>) -> World<S,C,R,E>:
  match world:
    case World{+namespace,allocator,store,resource,+events,pending,+registrations,+nextSystemId,+clock}:World{namespace,allocator,store,resource,events,command <> pending,registrations,nextSystemId,clock}
def enqueue(~S:Data,~C:Type,~R:Type,~E:Data,world:World<S,C,R,E>,command:World<S,C,R,E> -> World<S,C,R,E>) -> World<S,C,R,E>:
  enqueue_command(~S,~C,~R,~E,world,Deferred.Raw{command})
def drain_fifo(~S:Data,~C:Type,~R:Type,~E:Data,commands:List<Deferred.Command<World<S,C,R,E>>>,world:World<S,C,R,E>) -> World<S,C,R,E>:
  match commands:
    case []:world
    case command <> rest:Deferred.run_disabled(~World<S,C,R,E>,command,drain_fifo(~S,~C,~R,~E,rest,world))
def drain_apply(~S:Data,~C:Type,~R:Type,~E:Data,command:Deferred.Command<World<S,C,R,E>>,result:World<S,C,R,E> & TraceFacts.State) -> World<S,C,R,E> & TraceFacts.State:
  match result:
    case (world,trace):Deferred.run(~World<S,C,R,E>,command,world,trace)
def drain_fifo_traced(~S:Data,~C:Type,~R:Type,~E:Data,commands:List<Deferred.Command<World<S,C,R,E>>>,world:World<S,C,R,E>,trace:TraceFacts.State) -> World<S,C,R,E> & TraceFacts.State:
  match commands:
    case []:(world,trace)
    case command <> rest:
      drain_apply(~S,~C,~R,~E,command,drain_fifo_traced(~S,~C,~R,~E,rest,world,trace))
def barrier_traced(~S:Data,~C:Type,~R:Type,~E:Data,world:World<S,C,R,E>,trace:TraceFacts.State) -> World<S,C,R,E> & TraceFacts.State:
  match world:
    case World{+namespace,allocator,store,resource,+events,pending,+registrations,+nextSystemId,+clock}:drain_fifo_traced(~S,~C,~R,~E,pending,World{namespace,allocator,store,resource,events,[],registrations,nextSystemId,clock},trace)
def barrier(~S:Data,~C:Type,~R:Type,~E:Data,world:World<S,C,R,E>) -> World<S,C,R,E>:
  Deferred.world_only(~World<S,C,R,E>,barrier_traced(~S,~C,~R,~E,world,TraceFacts.Off{}))

def replace_resource(~S: Data,~C: Type,~R: Type,~E: Data,world: World<S,C,R,E>,replacement: R) -> World<S,C,R,E> & R:
  match world:
    case World{+namespace,allocator,store,resource,+events,pending,+registrations,+nextSystemId,+clock}: (World{namespace,allocator,store,replacement,events,pending,registrations,nextSystemId,clock},resource)

def event_append_loop(~E: Data,reversed: List<&2,E>,+output: List<&2,E>) -> List<&2,E>:
  match reversed:
    case []: output
    case head <> rest: event_append_loop(~E,rest,head <> output)

def event_append(~E: Data,+left: List<&2,E>,+right: List<&2,E>) -> List<&2,E>:
  event_append_loop(~E,List.reverse(&2,E,left),right)

def event_publish_nonempty(~S: Data,~C: Type,~R: Type,~E: Data,world: World<S,C,R,E>,+published: List<&2,E>) -> World<S,C,R,E>:
  match world:
    case World{+namespace,allocator,store,resource,+events,pending,+registrations,+nextSystemId,+clock}: World{namespace,allocator,store,resource,event_append(~E,events,published),pending,registrations,nextSystemId,clock}

# An empty publication changes no field and needs no traversal of retained events.
def event_publish(~S: Data,~C: Type,~R: Type,~E: Data,world: World<S,C,R,E>,+published: List<&2,E>) -> World<S,C,R,E>:
  match published:
    case []: world
    case head <> rest: event_publish_nonempty(~S,~C,~R,~E,world,head <> rest)

def events_view(~S: Data,~C: Type,~R: Type,~E: Data,world: World<S,C,R,E>) -> World<S,C,R,E> & List<&2,E>:
  match world:
    case World{+namespace,allocator,store,resource,+events,pending,+registrations,+nextSystemId,+clock}: (World{namespace,allocator,store,resource,events,pending,registrations,nextSystemId,clock},events)

def observe_resource_finish(~S: Data,~C: Type,~R: Type,~E: Data,~V: Type,observed: R & V,+namespace: U32,allocator: A.Allocator,store: C,+events: List<&2,E>,pending:List<Deferred.Command<World<S,C,R,E>>>,+registrations: List<&2,RegistrationMeta>,+nextSystemId: U32,+clock: U32) -> World<S,C,R,E> & V:
  (resource,value) = observed
  (World{namespace,allocator,store,resource,events,pending,registrations,nextSystemId,clock},value)

def observe_resource(~S: Data,~C: Type,~R: Type,~E: Data,~V: Type,~project: R -> R & V,world: World<S,C,R,E>) -> World<S,C,R,E> & V:
  match world:
    case World{+namespace,allocator,store,resource,+events,pending,+registrations,+nextSystemId,+clock}: observe_resource_finish(~S,~C,~R,~E,~V,project(resource),namespace,allocator,store,events,pending,registrations,nextSystemId,clock)

def register_checked(~S: Data,~C: Type,~R: Type,~E: Data,available: Bool,world: World<S,C,R,E>,+name: String,+access: List<&2,String>) -> World<S,C,R,E> & Registration:
  match available world:
    case False{} world: (world,RegistrationRejected{SystemIdExhausted{}})
    case True{} World{+namespace,allocator,store,resource,+events,pending,+registrations,+nextSystemId,+clock}: (World{namespace,allocator,store,resource,events,pending,RegistrationMeta{nextSystemId,name,access} <> registrations,(nextSystemId + 1 : U32),clock},Registered{nextSystemId})

def register(~S: Data,~C: Type,~R: Type,~E: Data,world: World<S,C,R,E>,+name: String,+access: List<&2,String>) -> World<S,C,R,E> & Registration:
  match world:
    case World{+namespace,allocator,store,resource,+events,pending,+registrations,+nextSystemId,+clock}: register_checked(~S,~C,~R,~E,U32.is_lt(nextSystemId,4294967295),World{namespace,allocator,store,resource,events,pending,registrations,nextSystemId,clock},name,access)

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
    case World{+namespace,allocator,store,resource,+events,pending,+registrations,+nextSystemId,+clock}: (World{namespace,allocator,store,resource,events,pending,registrations,nextSystemId,clock},namespace)

def registration_matches(~S: Data,~C: Type,~R: Type,~E: Data,world: World<S,C,R,E>,+id: U32,+name: String,+access: List<&2,String>) -> World<S,C,R,E> & Bool:
  match world:
    case World{+namespace,allocator,store,resource,+events,pending,+registrations,+nextSystemId,+clock}: (World{namespace,allocator,store,resource,events,pending,registrations,nextSystemId,clock},registration_list_matches(registrations,id,name,access))

def with_store_finish(~S: Data,~C: Type,~R: Type,~E: Data,~Out: Type,observed: C & Out,+namespace: U32,allocator: A.Allocator,resource: R,+events: List<&2,E>,pending:List<Deferred.Command<World<S,C,R,E>>>,+registrations: List<&2,RegistrationMeta>,+nextSystemId: U32,+clock: U32) -> World<S,C,R,E> & Out:
  (store,value) = observed
  (World{namespace,allocator,store,resource,events,pending,registrations,nextSystemId,clock},value)

def with_store(~S: Data,~C: Type,~R: Type,~E: Data,~Out: Type,effect: C -> C & Out,world: World<S,C,R,E>) -> World<S,C,R,E> & Out:
  match world:
    case World{+namespace,allocator,store,resource,+events,pending,+registrations,+nextSystemId,+clock}: with_store_finish(~S,~C,~R,~E,~Out,effect(store),namespace,allocator,resource,events,pending,registrations,nextSystemId,clock)

def pending_prepend(~S: Data,~C: Type,~R: Type,~E: Data,command: World<S,C,R,E> -> World<S,C,R,E>,counted: List<(World<S,C,R,E> -> World<S,C,R,E>)> & U32) -> List<(World<S,C,R,E> -> World<S,C,R,E>)> & U32:
  (commands,count) = counted
  (command <> commands,(count + 1 : U32))

def pending_length_acc(~S: Data,~C: Type,~R: Type,~E: Data,commands:List<Deferred.Command<World<S,C,R,E>>>,reversed: List<Deferred.Command<World<S,C,R,E>>>,count: U32) -> List<Deferred.Command<World<S,C,R,E>>> & U32:
  match commands:
    case []: (List.reverse(&1,Deferred.Command<World<S,C,R,E>>,reversed),count)
    case command <> rest: pending_length_acc(~S,~C,~R,~E,rest,command <> reversed,(count + 1 : U32))

def pending_length(~S: Data,~C: Type,~R: Type,~E: Data,commands:List<Deferred.Command<World<S,C,R,E>>>) -> List<Deferred.Command<World<S,C,R,E>>> & U32:
  pending_length_acc(~S,~C,~R,~E,commands,[],0)

def pending_count_join(~S: Data,~C: Type,~R: Type,~E: Data,+namespace: U32,allocator: A.Allocator,store: C,resource: R,+events: List<&2,E>,+registrations: List<&2,RegistrationMeta>,+nextSystemId: U32,+clock: U32,counted: List<Deferred.Command<World<S,C,R,E>>> & U32) -> World<S,C,R,E> & U32:
  (pending,count) = counted
  (World{namespace,allocator,store,resource,events,pending,registrations,nextSystemId,clock},count)

def pending_count(~S: Data,~C: Type,~R: Type,~E: Data,world: World<S,C,R,E>) -> World<S,C,R,E> & U32:
  match world:
    case World{+namespace,allocator,store,resource,+events,pending,+registrations,+nextSystemId,+clock}: pending_count_join(~S,~C,~R,~E,namespace,allocator,store,resource,events,registrations,nextSystemId,clock,pending_length(~S,~C,~R,~E,pending))

# Monotonic write clock. Failed transactions may leave unused clock positions;
# their component stamps are restored by the owned inverse journal.
def clock(~S: Data,~C: Type,~R: Type,~E: Data,world: World<S,C,R,E>) -> World<S,C,R,E> & U32:
  match world:
    case World{+namespace,allocator,store,resource,+events,pending,+registrations,+nextSystemId,+clock}: (World{namespace,allocator,store,resource,events,pending,registrations,nextSystemId,clock},clock)

def next_clock(available: Bool,+clock: U32) -> U32:
  match available:
    case False{}: clock
    case True{}: (clock + 1 : U32)

def advance_clock(~S: Data,~C: Type,~R: Type,~E: Data,world: World<S,C,R,E>) -> World<S,C,R,E> & U32:
  match world:
    case World{+namespace,allocator,store,resource,+events,pending,+registrations,+nextSystemId,+clock}: (World{namespace,allocator,store,resource,events,pending,registrations,nextSystemId,next_clock(U32.is_lt(clock,4294967295),clock)},next_clock(U32.is_lt(clock,4294967295),clock))

# Event runtime retention replaces only its owned event domain.
def events_replace(~S: Data,~C: Type,~R: Type,~E: Data,world: World<S,C,R,E>,+retained: List<&2,E>) -> World<S,C,R,E>:
  match world:
    case World{+namespace,allocator,store,resource,_,pending,+registrations,+nextSystemId,+clock}: World{namespace,allocator,store,resource,retained,pending,registrations,nextSystemId,clock}

def key_handles(~S:Data,+namespace:U32,keys:List<&2,K.Key>) -> List<&2,Handle<S>>:
  match keys:
    case []:[]
    case key <> rest:Handle{namespace,key} <> key_handles(~S,namespace,rest)
def handles_join(~S:Data,~C:Type,~R:Type,~E:Data,+namespace:U32,store:C,resource:R,events:List<&2,E>,pending:List<Deferred.Command<World<S,C,R,E>>>,registrations:List<&2,RegistrationMeta>,nextSystemId:U32,clock:U32,observed:A.Allocator & List<&2,K.Key>) -> World<S,C,R,E> & List<&2,Handle<S>>:
  match observed:
    case (allocator,keys):(World{namespace,allocator,store,resource,events,pending,registrations,nextSystemId,clock},key_handles(~S,namespace,keys))
def handles(~S:Data,~C:Type,~R:Type,~E:Data,world:World<S,C,R,E>) -> World<S,C,R,E> & List<&2,Handle<S>>:
  match world:
    case World{namespace,allocator,store,resource,events,pending,registrations,nextSystemId,clock}:handles_join(~S,~C,~R,~E,namespace,store,resource,events,pending,registrations,nextSystemId,clock,A.visible(allocator))
