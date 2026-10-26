import Base
import ./change-tick.bend as Tick
import ./reader-parameter.bend as RP
import ./world.bend as W
import ./event-runtime.bend as Ev
import ./event-stream.bend as Stream
import ./event-family-routing.bend as Route
import ./event-family-runtime.bend as Family
import ./event-notice-runtime.bend as Mixed
import ./relation-commands.bend as Notice
import ./ordinary-event-declaration.bend as Event
import ./relation-failure-reader.bend as KDecl
import ./relation-failure-runtime.bend as K
import ./relation-failure-disposal.bend as KDispose
import ./internal/relation-failures/domains.bend as KD
import ./internal/relation-failures/readings.bend as KRead
import ./ordinary-removal-provision.bend as Provision
import ./ordinary-declaration.bend as Identity
import ./removals.bend as Rm

# These parameters read one shared route context. Per-system owners contain
# reader identity and cursor metadata; all retained histories stay centralized.
type EventView<S:Data,E:Data> is Data:
  EventView{reading:Ev.Reading<E>}
type RemovalView<S:Data,P:Type> is Data:
  RemovalView{records:List<&2,Rm.Record<S,Identity.Declaration<S,P>>>}
type RelationView<S:Data,P:Data> is Data:
  RelationView{readings:List<&2,KRead.KeyReading<S,Notice.Notice<S,P>>>}
type RelationDelta is Data:
  RelationDelta{id:Maybe<&2,U32>,readThrough:Nat}

type EventOwner<S:Data,C:Type,R:Type,P:Data,E:Data,F:Type,H:Type,
  -take:F -> F & Stream.Stream<S,E>,
  -put:F -> Stream.Stream<S,E> -> F> is Type:
  EventOwner{facts:RP.RegistrationFacts,reader:Route.Reader<S,E,F,take,put>}
type RemovalOwner<S:Data,P:Type,E:Data,
  -select:E -> Maybe<&2,Rm.Record<S,Identity.Declaration<S,P>>>> is Type:
  RemovalOwner{facts:RP.RegistrationFacts,reader:Rm.Reader<S,E,Identity.Declaration<S,P>,select>}
type RelationOwner<S:Data,P:Data> is Type:
  RelationOwner{facts:RP.RegistrationFacts,id:Maybe<&2,U32>,keys:List<&2,KD.DescriptorKey<S>>}

def access_member(+wanted:String,access:List<&2,String>) -> Bool:
  match access:
    case []:False{}
    case name <> rest:Bool.or(String.eq(wanted,name),access_member(wanted,rest))
def access_subset(wanted:List<&2,String>,+access:List<&2,String>) -> Bool:
  match wanted:
    case []:True{}
    case name <> rest:Bool.and(access_member(name,access),access_subset(rest,access))

# Keep the affine World returned by the normal registration check.
def registered_context_checked(~S:Data,~C:Type,~R:Type,~E:Data,
  namespace:U32,currentNamespace:U32,checked:W.World<S,C,R,E> & Bool) -> W.World<S,C,R,E> & Bool:
  match checked:
    case (world,matched):(world,Bool.and(U32.is_eq(namespace,currentNamespace),matched))
def registered_context_named(~S:Data,~C:Type,~R:Type,~E:Data,
  id:U32,name:String,access:List<&2,String>,factsNamespace:U32,
  named:W.World<S,C,R,E> & U32) -> W.World<S,C,R,E> & Bool:
  match named:
    case (world,currentNamespace):
      registered_context_checked(~S,~C,~R,~E,factsNamespace,currentNamespace,
        W.registration_matches(~S,~C,~R,~E,world,id,name,access))
def registered_context(~S:Data,~C:Type,~R:Type,~E:Data,
  world:W.World<S,C,R,E>,facts:RP.RegistrationFacts) -> W.World<S,C,R,E> & Bool:
  match facts:
    case RP.RegistrationFacts{namespace,id,name,access}:
      registered_context_named(~S,~C,~R,~E,id,name,access,namespace,
        W.namespace(~S,~C,~R,~E,world))

# Event stream readers use the existing central Leaf.Stream identity allocator.
def event_access(~S:Data,~E:Data,declaration:Event.Declaration<S,E>) -> List<&2,String>:
  [Event.access(~S,~E,declaration)]
def event_readable(~S:Data,~E:Data,declaration:Event.Declaration<S,E>) -> Bool:
  match declaration:
    case Event.Declaration{_,Event.Read{}}:True{}
    case Event.Declaration{_,Event.Write{}}:False{}
def event_domain_matches(~S:Data,~E:Data,
  declaration:Event.Declaration<S,E>,
  domain:Event.Domain<S,E>) -> Bool:
  match declaration domain:
    case Event.Declaration{Event.Domain{expected},Event.Read{}} Event.Domain{actual}:String.eq(expected,actual)
    case _ _:False{}

def event_selected_domain(~S:Data,~P:Data,~E:Data,~F:Type,~H:Type,
  ~take:F -> F & Stream.Stream<S,E>,
  ~put:F -> Stream.Stream<S,E> -> F,
  declaration:Event.Declaration<S,E>,
  selected:Mixed.State<S,P,F,H> & Stream.Stream<S,E>) -> Mixed.State<S,P,F,H> & Bool:
  match selected:
    case (state,+stream):
      (Mixed.put(~S,~E,~P,~F,~H,~put,state,stream),
       event_domain_matches(~S,~E,declaration,Stream.domain(~S,~E,stream)))

def event_validate_values(~S:Data,~C:Type,~R:Type,~P:Data,~E:Data,~F:Type,~H:Type,
  ~take:F -> F & Stream.Stream<S,E>,
  ~put:F -> Stream.Stream<S,E> -> F,
  ~declaration:Event.Declaration<S,E>,tick:Nat,facts:RP.RegistrationFacts,
  reader:Route.Reader<S,E,F,take,put>,
  world:W.World<S,C,R,Notice.Notice<S,P>>,registered:Bool,state:Mixed.State<S,P,F,H>,domainMatches:Bool) -> Route.Runtime<S,C,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>> & (EventOwner<S,C,R,P,E,F,H,take,put> & Bool):
  match facts:
    case RP.RegistrationFacts{+expectedNamespace,+registryIdExpected,_,+access}:
      match reader:
        case Route.Reader{+namespace,+readerId,+registryId}:
          +valid=Bool.and(event_readable(~S,~E,declaration),
            Bool.and(registered,Bool.and(access_subset(event_access(~S,~E,declaration),access),
              Bool.and(U32.is_eq(namespace,expectedNamespace),
                Bool.and(U32.is_gt(readerId,0),
                  Bool.and(U32.is_eq(registryId,registryIdExpected),domainMatches))))))
          (Route.Runtime{world,state,tick},(EventOwner{facts,reader},valid))

def event_validate_domain(~S:Data,~C:Type,~R:Type,~P:Data,~E:Data,~F:Type,~H:Type,
  ~take:F -> F & Stream.Stream<S,E>,
  ~put:F -> Stream.Stream<S,E> -> F,
  ~declaration:Event.Declaration<S,E>,tick:Nat,facts:RP.RegistrationFacts,
  reader:Route.Reader<S,E,F,take,put>,
  registered:W.World<S,C,R,Notice.Notice<S,P>> & Bool,
  selected:Mixed.State<S,P,F,H> & Bool) -> Route.Runtime<S,C,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>> & (EventOwner<S,C,R,P,E,F,H,take,put> & Bool):
  match registered:
    case (world,isRegistered):
      match selected:
        case (state,domainMatches):event_validate_values(~S,~C,~R,~P,~E,~F,~H,~take,~put,~declaration,tick,facts,reader,world,isRegistered,state,domainMatches)

def event_validate_registered(~S:Data,~C:Type,~R:Type,~P:Data,~E:Data,~F:Type,~H:Type,
  ~take:F -> F & Stream.Stream<S,E>,
  ~put:F -> Stream.Stream<S,E> -> F,
  ~declaration:Event.Declaration<S,E>,tick:Nat,facts:RP.RegistrationFacts,
  reader:Route.Reader<S,E,F,take,put>,
  registered:W.World<S,C,R,Notice.Notice<S,P>> & Bool,
  selected:Mixed.State<S,P,F,H> & Bool) -> Route.Runtime<S,C,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>> & (EventOwner<S,C,R,P,E,F,H,take,put> & Bool):
  event_validate_domain(~S,~C,~R,~P,~E,~F,~H,~take,~put,~declaration,tick,facts,reader,registered,selected)

def event_validate_join(~S:Data,~C:Type,~R:Type,~P:Data,~E:Data,~F:Type,~H:Type,
  ~take:F -> F & Stream.Stream<S,E>,
  ~put:F -> Stream.Stream<S,E> -> F,
  ~declaration:Event.Declaration<S,E>,
  tick:Nat,facts:RP.RegistrationFacts,
  reader:Route.Reader<S,E,F,take,put>,
  registeredContext:W.World<S,C,R,Notice.Notice<S,P>> & Bool,
  selectedDomain:Mixed.State<S,P,F,H> & Bool) -> Route.Runtime<S,C,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>> & (EventOwner<S,C,R,P,E,F,H,take,put> & Bool):
  event_validate_registered(~S,~C,~R,~P,~E,~F,~H,~take,~put,~declaration,tick,facts,reader,registeredContext,selectedDomain)

def validate_event(~S:Data,~C:Type,~R:Type,~P:Data,~E:Data,~F:Type,~H:Type,
  ~take:F -> F & Stream.Stream<S,E>,
  ~put:F -> Stream.Stream<S,E> -> F,
  ~declaration:Event.Declaration<S,E>,
  context:Route.Runtime<S,C,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>>,
  owner:EventOwner<S,C,R,P,E,F,H,take,put>) -> Route.Runtime<S,C,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>> & (EventOwner<S,C,R,P,E,F,H,take,put> & Bool):
  match context owner:
    case Route.Runtime{world,state,tick} EventOwner{+facts,reader}:
      event_validate_join(~S,~C,~R,~P,~E,~F,~H,~take,~put,~declaration,tick,facts,reader,
        registered_context(~S,~C,~R,~Notice.Notice<S,P>,world,facts),
        event_selected_domain(~S,~P,~E,~F,~H,~take,~put,declaration,
          Mixed.take(~S,~E,~P,~F,~H,~take,state)))

def event_reading_loaded(~S:Data,~P:Data,~E:Data,~F:Type,~H:Type,selected:Mixed.State<S,P,F,H>,
  viewed:Stream.Stream<S,E> & Ev.Reading<E>) -> Mixed.State<S,P,F,H> & (Stream.Stream<S,E> & Ev.Reading<E>):
  match viewed:
    case (stream,reading):(selected,(stream,reading))

def event_read_selected_from(~S:Data,~P:Data,~E:Data,~F:Type,~H:Type,
  ~take:F -> F & Stream.Stream<S,E>,
  id:U32,tick:Nat,
  selected:Mixed.State<S,P,F,H> & Stream.Stream<S,E>) -> Mixed.State<S,P,F,H> & (Stream.Stream<S,E> & Ev.Reading<E>):
  match selected:
    case (held,stream):event_reading_loaded(~S,~P,~E,~F,~H,held,Stream.reading(~S,~E,stream,id,tick))

def event_read_selected(~S:Data,~P:Data,~E:Data,~F:Type,~H:Type,
  ~take:F -> F & Stream.Stream<S,E>,
  state:Mixed.State<S,P,F,H>,id:U32,tick:Nat) -> Mixed.State<S,P,F,H> & (Stream.Stream<S,E> & Ev.Reading<E>):
  event_read_selected_from(~S,~P,~E,~F,~H,~take,id,tick,Mixed.take(~S,~E,~P,~F,~H,~take,state))

def event_prepared(~S:Data,~C:Type,~R:Type,~P:Data,~E:Data,~F:Type,~H:Type,
  ~take:F -> F & Stream.Stream<S,E>,
  ~put:F -> Stream.Stream<S,E> -> F,
  world:W.World<S,C,R,Notice.Notice<S,P>>,+tick:Nat,
  owner:EventOwner<S,C,R,P,E,F,H,take,put>,
  selected:Mixed.State<S,P,F,H> & (Stream.Stream<S,E> & Ev.Reading<E>)) -> Route.Runtime<S,C,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>> & (EventOwner<S,C,R,P,E,F,H,take,put> & (EventView<S,E> & Nat)):
  # A first attempted read owns retention even if its callback fails. Keep
  # cursor zero until commit; completed(False) only activates the position.
  match owner:
    case EventOwner{facts,Route.Reader{namespace,+id,registryId}}:
      match selected:
        case (state,(stream,reading)):
          (Route.Runtime{world,Mixed.put(~S,~E,~P,~F,~H,~put,state,
            Stream.completed(~S,~E,stream,id,Nat.sub(tick,1n),False{})),tick},
           (EventOwner{facts,Route.Reader{namespace,id,registryId}},(EventView{reading},Nat.sub(tick,1n))))

def prepare_event(~S:Data,~C:Type,~R:Type,~P:Data,~E:Data,~F:Type,~H:Type,
  ~take:F -> F & Stream.Stream<S,E>,
  ~put:F -> Stream.Stream<S,E> -> F,
  ~declaration:Event.Declaration<S,E>,
  context:Route.Runtime<S,C,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>>,+cursor:Maybe<&2,Tick.Tick>,
  owner:EventOwner<S,C,R,P,E,F,H,take,put>) -> Route.Runtime<S,C,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>> & (EventOwner<S,C,R,P,E,F,H,take,put> & (EventView<S,E> & Nat)):
  match context owner:
    case Route.Runtime{world,state,+tick} EventOwner{facts,reader}:
      match reader:
        case Route.Reader{namespace,+id,registryId}:
          event_prepared(~S,~C,~R,~P,~E,~F,~H,~take,~put,world,tick,EventOwner{facts,Route.Reader{namespace,id,registryId}},
            event_read_selected(~S,~P,~E,~F,~H,~take,state,id,tick))

def event_advanced_selected(~S:Data,~P:Data,~E:Data,~F:Type,~H:Type,
  ~put:F -> Stream.Stream<S,E> -> F,id:U32,readThrough:Nat,
  selected:Mixed.State<S,P,F,H> & Stream.Stream<S,E>) -> Mixed.State<S,P,F,H>:
  match selected:
    case (state,stream):Mixed.put(~S,~E,~P,~F,~H,~put,state,Stream.advance(~S,~E,stream,id,readThrough))

def event_advanced(~S:Data,~P:Data,~E:Data,~F:Type,~H:Type,
  ~take:F -> F & Stream.Stream<S,E>,
  ~put:F -> Stream.Stream<S,E> -> F,
  state:Mixed.State<S,P,F,H>,id:U32,readThrough:Nat) -> Mixed.State<S,P,F,H>:
  event_advanced_selected(~S,~P,~E,~F,~H,~put,id,readThrough,Mixed.take(~S,~E,~P,~F,~H,~take,state))

def commit_event(~S:Data,~C:Type,~R:Type,~P:Data,~E:Data,~F:Type,~H:Type,
  ~take:F -> F & Stream.Stream<S,E>,
  ~put:F -> Stream.Stream<S,E> -> F,
  context:Route.Runtime<S,C,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>>,
  owner:EventOwner<S,C,R,P,E,F,H,take,put>,readThrough:Nat,+cursor:Tick.Tick) -> Route.Runtime<S,C,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>> & EventOwner<S,C,R,P,E,F,H,take,put>:
  match context owner:
    case Route.Runtime{world,state,tick} EventOwner{facts,reader}:
      match reader:
        case Route.Reader{namespace,+id,registryId}:
          (Route.Runtime{world,event_advanced(~S,~P,~E,~F,~H,~take,~put,state,id,readThrough),tick},
           EventOwner{facts,Route.Reader{namespace,id,registryId}})

def event_release_stream(~S:Data,~P:Data,~E:Data,~F:Type,~H:Type,
  ~put:F -> Stream.Stream<S,E> -> F,id:U32,tick:Nat,
  selected:Mixed.State<S,P,F,H> & Stream.Stream<S,E>) -> Mixed.State<S,P,F,H>:
  match selected:
    case (state,stream):
      match stream:
        case Stream.Stream{domain,batches,positions,nextReader,frameStart,boundary,capacity,dropped}:
          Mixed.put(~S,~E,~P,~F,~H,~put,state,
            Stream.Stream{domain,batches,Ev.update(positions,id,tick,True{}),nextReader,frameStart,boundary,capacity,dropped})

def event_release_ready(~S:Data,~C:Type,~R:Type,~P:Data,~E:Data,~F:Type,~H:Type,
  ~take:F -> F & Stream.Stream<S,E>,~put:F -> Stream.Stream<S,E> -> F,readerId:U32,
  context:Route.Runtime<S,C,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>>) -> Route.Runtime<S,C,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>>:
  match context:
    case Route.Runtime{world,state,+tick}:
      Route.Runtime{world,event_release_stream(~S,~P,~E,~F,~H,~put,readerId,tick,
        Mixed.take(~S,~E,~P,~F,~H,~take,state)),tick}

def event_release_decided(~S:Data,~C:Type,~R:Type,~P:Data,~E:Data,~F:Type,~H:Type,
  ~take:F -> F & Stream.Stream<S,E>,~put:F -> Stream.Stream<S,E> -> F,
  allowed:Bool,context:Route.Runtime<S,C,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>>,readerId:U32) -> Route.Runtime<S,C,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>>:
  match allowed:
    case False{}:context
    case True{}:event_release_ready(~S,~C,~R,~P,~E,~F,~H,~take,~put,readerId,context)

def event_release_validated(~S:Data,~C:Type,~R:Type,~P:Data,~E:Data,~F:Type,~H:Type,
  ~take:F -> F & Stream.Stream<S,E>,~put:F -> Stream.Stream<S,E> -> F,
  context:Route.Runtime<S,C,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>>,+readerId:U32) -> Route.Runtime<S,C,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>>:
  event_release_decided(~S,~C,~R,~P,~E,~F,~H,~take,~put,U32.is_gt(readerId,0),context,readerId)

def release_event(~S:Data,~C:Type,~R:Type,~P:Data,~E:Data,~F:Type,~H:Type,
  ~take:F -> F & Stream.Stream<S,E>,~put:F -> Stream.Stream<S,E> -> F,
  context:Route.Runtime<S,C,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>>,
  owner:EventOwner<S,C,R,P,E,F,H,take,put>) -> Route.Runtime<S,C,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>>:
  match context owner:
    case Route.Runtime{world,state,tick} EventOwner{_,reader}:
      match reader:
        case Route.Reader{namespace,+readerId,registryId}:
          event_release_validated(~S,~C,~R,~P,~E,~F,~H,~take,~put,
            Route.Runtime{world,state,tick},readerId)

def event_param(~S:Data,~C:Type,~R:Type,~P:Data,~E:Data,~F:Type,~H:Type,
  ~take:F -> F & Stream.Stream<S,E>,
  ~put:F -> Stream.Stream<S,E> -> F,
  ~declaration:Event.Declaration<S,E>) -> RP.Param<Route.Runtime<S,C,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>>,EventOwner<S,C,R,P,E,F,H,take,put>,EventView<S,E>,Nat,
  validate_event(~S,~C,~R,~P,~E,~F,~H,~take,~put,~declaration),prepare_event(~S,~C,~R,~P,~E,~F,~H,~take,~put,~declaration),commit_event(~S,~C,~R,~P,~E,~F,~H,~take,~put),release_event(~S,~C,~R,~P,~E,~F,~H,~take,~put)>:
  RP.make(~Route.Runtime<S,C,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>>,~EventOwner<S,C,R,P,E,F,H,take,put>,~EventView<S,E>,~Nat,
    ~validate_event(~S,~C,~R,~P,~E,~F,~H,~take,~put,~declaration),
    ~prepare_event(~S,~C,~R,~P,~E,~F,~H,~take,~put,~declaration),
    ~commit_event(~S,~C,~R,~P,~E,~F,~H,~take,~put),
    ~release_event(~S,~C,~R,~P,~E,~F,~H,~take,~put),
    event_access(~S,~E,declaration))

def event_registered_leaf(~S:Data,~P:Data,~E:Data,~F:Type,~H:Type,
  ~put:F -> Stream.Stream<S,E> -> F,
  selected:Mixed.State<S,P,F,H>,
  registered:Stream.Stream<S,E> & U32) -> Mixed.State<S,P,F,H> & U32:
  match registered:
    case (stream,id):(Mixed.put(~S,~E,~P,~F,~H,~put,selected,stream),id)

def event_registered_selected(~S:Data,~P:Data,~E:Data,~F:Type,~H:Type,
  ~put:F -> Stream.Stream<S,E> -> F,tick:Nat,
  selected:Mixed.State<S,P,F,H> & Stream.Stream<S,E>) -> Mixed.State<S,P,F,H> & U32:
  match selected:
    case (state,stream):event_registered_leaf(~S,~P,~E,~F,~H,~put,state,Stream.registered(~S,~E,stream,tick))

def event_registered(~S:Data,~P:Data,~E:Data,~F:Type,~H:Type,
  ~take:F -> F & Stream.Stream<S,E>,
  ~put:F -> Stream.Stream<S,E> -> F,
  state:Mixed.State<S,P,F,H>,tick:Nat) -> Mixed.State<S,P,F,H> & U32:
  event_registered_selected(~S,~P,~E,~F,~H,~put,tick,Mixed.take(~S,~E,~P,~F,~H,~take,state))

def event_initialized_registered(~S:Data,~C:Type,~R:Type,~P:Data,~E:Data,~F:Type,~H:Type,
  ~take:F -> F & Stream.Stream<S,E>,
  ~put:F -> Stream.Stream<S,E> -> F,
  ~declaration:Event.Declaration<S,E>,
  world:W.World<S,C,R,Notice.Notice<S,P>>,+tick:Nat,
  facts:RP.RegistrationFacts,
  registered:Mixed.State<S,P,F,H> & U32) -> Route.Runtime<S,C,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>> & (EventOwner<S,C,R,P,E,F,H,take,put> & RP.Param<Route.Runtime<S,C,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>>,EventOwner<S,C,R,P,E,F,H,take,put>,EventView<S,E>,Nat,
  validate_event(~S,~C,~R,~P,~E,~F,~H,~take,~put,~declaration),prepare_event(~S,~C,~R,~P,~E,~F,~H,~take,~put,~declaration),commit_event(~S,~C,~R,~P,~E,~F,~H,~take,~put),release_event(~S,~C,~R,~P,~E,~F,~H,~take,~put)>):
  match facts:
    case RP.RegistrationFacts{+namespace,+registryId,_,_}:
      match registered:
        case (state,id):
          (Route.Runtime{world,state,tick},
           (EventOwner{facts,Route.Reader{namespace,id,registryId}},event_param(~S,~C,~R,~P,~E,~F,~H,~take,~put,~declaration)))

def initialize_event_selected(~S:Data,~C:Type,~R:Type,~P:Data,~E:Data,~F:Type,~H:Type,
  ~take:F -> F & Stream.Stream<S,E>,
  ~put:F -> Stream.Stream<S,E> -> F,
  ~declaration:Event.Declaration<S,E>,
  readable:Bool,
  context:Route.Runtime<S,C,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>>,
  facts:RP.RegistrationFacts) -> Route.Runtime<S,C,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>> & (EventOwner<S,C,R,P,E,F,H,take,put> & RP.Param<Route.Runtime<S,C,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>>,EventOwner<S,C,R,P,E,F,H,take,put>,EventView<S,E>,Nat,
  validate_event(~S,~C,~R,~P,~E,~F,~H,~take,~put,~declaration),prepare_event(~S,~C,~R,~P,~E,~F,~H,~take,~put,~declaration),commit_event(~S,~C,~R,~P,~E,~F,~H,~take,~put),release_event(~S,~C,~R,~P,~E,~F,~H,~take,~put)>):
  match readable context facts:
    case False{} Route.Runtime{world,state,tick} RP.RegistrationFacts{+namespace,+registryId,_,_}:
      (Route.Runtime{world,state,tick},
       (EventOwner{facts,Route.Reader{namespace,0,registryId}},event_param(~S,~C,~R,~P,~E,~F,~H,~take,~put,~declaration)))
    case True{} Route.Runtime{world,state,+tick} RP.RegistrationFacts{+namespace,+registryId,_,_}:
      event_initialized_registered(~S,~C,~R,~P,~E,~F,~H,~take,~put,~declaration,
        world,tick,facts,
        event_registered(~S,~P,~E,~F,~H,~take,~put,state,tick))

def initialize_event(~S:Data,~C:Type,~R:Type,~P:Data,~E:Data,~F:Type,~H:Type,
  ~take:F -> F & Stream.Stream<S,E>,
  ~put:F -> Stream.Stream<S,E> -> F,
  ~declaration:Event.Declaration<S,E>,
  context:Route.Runtime<S,C,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>>,
  facts:RP.RegistrationFacts) -> Route.Runtime<S,C,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>> & (EventOwner<S,C,R,P,E,F,H,take,put> & RP.Param<Route.Runtime<S,C,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>>,EventOwner<S,C,R,P,E,F,H,take,put>,EventView<S,E>,Nat,
  validate_event(~S,~C,~R,~P,~E,~F,~H,~take,~put,~declaration),prepare_event(~S,~C,~R,~P,~E,~F,~H,~take,~put,~declaration),commit_event(~S,~C,~R,~P,~E,~F,~H,~take,~put),release_event(~S,~C,~R,~P,~E,~F,~H,~take,~put)>):
  initialize_event_selected(~S,~C,~R,~P,~E,~F,~H,~take,~put,~declaration,
    event_readable(~S,~E,declaration),context,facts)

# Removal declarations retain their nominal component identity and selector.
def removal_name(~S:Data,~Payload:Type,~E:Data,
  ~inject:Identity.Declaration<S,Payload> -> W.Handle<S> -> E,
  ~select:E -> Maybe<&2,Rm.Record<S,Identity.Declaration<S,Payload>>>,
  selection:Provision.Selection<S,Payload,E,inject,select>) -> String:
  match selection:
    case Provision.Selection{identity}:Identity.key(~S,~Payload,identity)

def removal_identity(~S:Data,~Payload:Type,~E:Data,
  ~inject:Identity.Declaration<S,Payload> -> W.Handle<S> -> E,
  ~select:E -> Maybe<&2,Rm.Record<S,Identity.Declaration<S,Payload>>>,
  selection:Provision.Selection<S,Payload,E,inject,select>) -> Identity.Declaration<S,Payload>:
  match selection:
    case Provision.Selection{identity}:identity
def removal_access(~S:Data,~Payload:Type,~E:Data,
  ~inject:Identity.Declaration<S,Payload> -> W.Handle<S> -> E,
  ~select:E -> Maybe<&2,Rm.Record<S,Identity.Declaration<S,Payload>>>,
  selection:Provision.Selection<S,Payload,E,inject,select>) -> List<&2,String>:
  ["removal",removal_name(~S,~Payload,~E,~inject,~select,selection)]

def removal_validate_checked(~S:Data,~C:Type,~R:Type,~P:Data,~Payload:Type,~F:Type,~H:Type,
  ~inject:Identity.Declaration<S,Payload> -> W.Handle<S> -> Notice.Notice<S,P>,
  ~select:Notice.Notice<S,P> -> Maybe<&2,Rm.Record<S,Identity.Declaration<S,Payload>>>,
  ~selection:Provision.Selection<S,Payload,Notice.Notice<S,P>,inject,select>,
  state:Mixed.State<S,P,F,H>,tick:Nat,facts:RP.RegistrationFacts,
  reader:Rm.Reader<S,Notice.Notice<S,P>,Identity.Declaration<S,Payload>,select>,
  registered:W.World<S,C,R,Notice.Notice<S,P>> & Bool) -> Route.Runtime<S,C,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>> & (RemovalOwner<S,Payload,Notice.Notice<S,P>,select> & Bool):
  match facts:
    case RP.RegistrationFacts{+expectedNamespace,+expectedId,_,+access}:
      match reader:
        case Rm.Reader{+namespace,+id,+name,cursor}:
          match registered:
            case (world,isRegistered):
              +expected=removal_access(~S,~Payload,~Notice.Notice<S,P>,~inject,~select,selection)
              +valid=Bool.and(isRegistered,Bool.and(access_subset(expected,access),
                Bool.and(U32.is_eq(namespace,expectedNamespace),
                  Bool.and(U32.is_eq(id,expectedId),String.eq(name,removal_name(~S,~Payload,~Notice.Notice<S,P>,~inject,~select,selection))))))
              (Route.Runtime{world,state,tick},(RemovalOwner{facts,Rm.Reader{namespace,id,name,cursor}},valid))

def validate_removal(~S:Data,~C:Type,~R:Type,~P:Data,~Payload:Type,~F:Type,~H:Type,
  ~inject:Identity.Declaration<S,Payload> -> W.Handle<S> -> Notice.Notice<S,P>,
  ~select:Notice.Notice<S,P> -> Maybe<&2,Rm.Record<S,Identity.Declaration<S,Payload>>>,
  ~selection:Provision.Selection<S,Payload,Notice.Notice<S,P>,inject,select>,
  context:Route.Runtime<S,C,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>>,
  owner:RemovalOwner<S,Payload,Notice.Notice<S,P>,select>) -> Route.Runtime<S,C,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>> & (RemovalOwner<S,Payload,Notice.Notice<S,P>,select> & Bool):
  match context owner:
    case Route.Runtime{world,state,tick} RemovalOwner{+facts,reader}:
      removal_validate_checked(~S,~C,~R,~P,~Payload,~F,~H,~inject,~select,~selection,
        state,tick,facts,reader,registered_context(~S,~C,~R,~Notice.Notice<S,P>,world,facts))

def removal_prepared(~S:Data,~C:Type,~R:Type,~P:Data,~Payload:Type,~F:Type,~H:Type,
  ~select:Notice.Notice<S,P> -> Maybe<&2,Rm.Record<S,Identity.Declaration<S,Payload>>>,
  state:Mixed.State<S,P,F,H>,tick:Nat,owner:RemovalOwner<S,Payload,Notice.Notice<S,P>,select>,
  observed:W.World<S,C,R,Notice.Notice<S,P>> & List<&2,Notice.Notice<S,P>>) -> Route.Runtime<S,C,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>> & (RemovalOwner<S,Payload,Notice.Notice<S,P>,select> & (RemovalView<S,Payload> & Nat)):
  match owner:
    case RemovalOwner{facts,reader}:
      match reader:
        case Rm.Reader{namespace,id,name,+cursor}:
          match observed:
            case (world,+values):
              +records=Rm.since(~S,~Notice.Notice<S,P>,~Identity.Declaration<S,Payload>,~select,values,cursor)
              (Route.Runtime{world,state,tick},
                (RemovalOwner{facts,Rm.Reader{namespace,id,name,cursor}},
                 (RemovalView{records},Rm.count(~Notice.Notice<S,P>,values))))

def prepare_removal(~S:Data,~C:Type,~R:Type,~P:Data,~Payload:Type,~F:Type,~H:Type,
  ~select:Notice.Notice<S,P> -> Maybe<&2,Rm.Record<S,Identity.Declaration<S,Payload>>>,
  context:Route.Runtime<S,C,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>>,+cursor:Maybe<&2,Tick.Tick>,
  owner:RemovalOwner<S,Payload,Notice.Notice<S,P>,select>) -> Route.Runtime<S,C,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>> & (RemovalOwner<S,Payload,Notice.Notice<S,P>,select> & (RemovalView<S,Payload> & Nat)):
  match context:
    case Route.Runtime{world,state,tick}:
      removal_prepared(~S,~C,~R,~P,~Payload,~F,~H,~select,state,tick,owner,
        W.events_view(~S,~C,~R,~Notice.Notice<S,P>,world))

def commit_removal(~S:Data,~C:Type,~R:Type,~P:Data,~Payload:Type,~F:Type,~H:Type,
  ~select:Notice.Notice<S,P> -> Maybe<&2,Rm.Record<S,Identity.Declaration<S,Payload>>>,
  context:Route.Runtime<S,C,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>>,
  owner:RemovalOwner<S,Payload,Notice.Notice<S,P>,select>,observedCount:Nat,+cursor:Tick.Tick) -> Route.Runtime<S,C,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>> & RemovalOwner<S,Payload,Notice.Notice<S,P>,select>:
  match context owner:
    case context RemovalOwner{facts,reader}:
      match reader:
        case Rm.Reader{namespace,id,name,_}:
          (context,RemovalOwner{facts,Rm.Reader{namespace,id,name,observedCount}})

def removal_access_member(access:List<&2,String>) -> Bool:
  match access:
    case []:False{}
    case first <> rest:Bool.or(String.eq("removal",first),removal_access_member(rest))
def removal_registration_remains(entries:List<&2,W.RegistrationMeta>) -> Bool:
  match entries:
    case []:False{}
    case W.RegistrationMeta{_,_,access} <> rest:
      Bool.or(removal_access_member(access),removal_registration_remains(rest))
def removal_event_selected(~S:Data,~P:Data,~Payload:Type,
  selected:Maybe<&2,Rm.Record<S,Identity.Declaration<S,Payload>>>,
  +event:Notice.Notice<S,P>,rest:List<&2,Notice.Notice<S,P>>) -> List<&2,Notice.Notice<S,P>>:
  match selected:
    case None{}:event <> rest
    case Some{_}:rest
def removal_event_kept(~S:Data,~P:Data,~Payload:Type,
  ~select:Notice.Notice<S,P> -> Maybe<&2,Rm.Record<S,Identity.Declaration<S,Payload>>>,
  +event:Notice.Notice<S,P>,rest:List<&2,Notice.Notice<S,P>>) -> List<&2,Notice.Notice<S,P>>:
  removal_event_selected(~S,~P,~Payload,select(event),event,rest)
def removal_events_kept(~S:Data,~P:Data,~Payload:Type,
  ~select:Notice.Notice<S,P> -> Maybe<&2,Rm.Record<S,Identity.Declaration<S,Payload>>>,
  events:List<&2,Notice.Notice<S,P>>) -> List<&2,Notice.Notice<S,P>>:
  match events:
    case []:[]
    case event <> rest:removal_event_kept(~S,~P,~Payload,~select,event,removal_events_kept(~S,~P,~Payload,~select,rest))
def removal_release_world_checked(~S:Data,~C:Type,~R:Type,~P:Data,~Payload:Type,
  ~select:Notice.Notice<S,P> -> Maybe<&2,Rm.Record<S,Identity.Declaration<S,Payload>>>,
  retained:Bool,world:W.World<S,C,R,Notice.Notice<S,P>>) -> W.World<S,C,R,Notice.Notice<S,P>>:
  match retained world:
    case True{} world:world
    case False{} W.World{namespace,allocator,store,resource,events,pending,registrations,nextSystemId,clock,lifecycle}:
      W.World{namespace,allocator,store,resource,
        removal_events_kept(~S,~P,~Payload,~select,events),pending,registrations,nextSystemId,clock,lifecycle}
def removal_world_retained(~S:Data,~C:Type,~R:Type,~P:Data,
  world:W.World<S,C,R,Notice.Notice<S,P>>) -> W.World<S,C,R,Notice.Notice<S,P>> & Bool:
  match world:
    case W.World{+namespace,allocator,store,resource,+events,pending,+registrations,+nextSystemId,+clock,lifecycle}:
      (W.World{namespace,allocator,store,resource,events,pending,registrations,nextSystemId,clock,lifecycle},
        removal_registration_remains(registrations))
def removal_release_world(~S:Data,~C:Type,~R:Type,~P:Data,~Payload:Type,
  ~select:Notice.Notice<S,P> -> Maybe<&2,Rm.Record<S,Identity.Declaration<S,Payload>>>,
  world:W.World<S,C,R,Notice.Notice<S,P>>) -> W.World<S,C,R,Notice.Notice<S,P>>:
  match world:
    case W.World{namespace,allocator,store,resource,events,pending,+registrations,nextSystemId,clock,lifecycle}:
      removal_release_world_checked(~S,~C,~R,~P,~Payload,~select,
        removal_registration_remains(registrations),
        W.World{namespace,allocator,store,resource,events,pending,registrations,nextSystemId,clock,lifecycle})

def removal_publication_selected_value(~S:Data,~P:Data,~Payload:Type,
  selected:Maybe<&2,Rm.Record<S,Identity.Declaration<S,Payload>>>) -> Bool:
  match selected:
    case None{}:True{}
    case Some{_}:False{}
def removal_publication_kept(~S:Data,~P:Data,~Payload:Type,
  ~select:Notice.Notice<S,P> -> Maybe<&2,Rm.Record<S,Identity.Declaration<S,Payload>>>,
  +publication:P) -> Bool:
  removal_publication_selected_value(~S,~P,~Payload,select(Notice.Original{publication}))
def removal_publication_retain(~P:Data,keep:Bool,publication:P,rest:List<&2,P>) -> List<&2,P>:
  match keep:
    case True{}:publication <> rest
    case False{}:rest
def removal_publications_kept(~S:Data,~P:Data,~Payload:Type,
  ~select:Notice.Notice<S,P> -> Maybe<&2,Rm.Record<S,Identity.Declaration<S,Payload>>>,
  publications:List<&2,P>) -> List<&2,P>:
  match publications:
    case []:[]
    case +publication <> rest:
      removal_publication_retain(~P,
        removal_publication_kept(~S,~P,~Payload,~select,publication),publication,
        removal_publications_kept(~S,~P,~Payload,~select,rest))
def removal_batch_kept(~S:Data,~P:Data,~Payload:Type,
  ~select:Notice.Notice<S,P> -> Maybe<&2,Rm.Record<S,Identity.Declaration<S,Payload>>>,
  batch:Ev.Batch<P>) -> Ev.Batch<P>:
  match batch:
    case Ev.Batch{tick,values}:Ev.Batch{tick,removal_publications_kept(~S,~P,~Payload,~select,values)}
def removal_batches_kept(~S:Data,~P:Data,~Payload:Type,
  ~select:Notice.Notice<S,P> -> Maybe<&2,Rm.Record<S,Identity.Declaration<S,Payload>>>,
  batches:List<&2,Ev.Batch<P>>) -> List<&2,Ev.Batch<P>>:
  match batches:
    case []:[]
    case batch <> rest:removal_batch_kept(~S,~P,~Payload,~select,batch) <> removal_batches_kept(~S,~P,~Payload,~select,rest)
def removal_release_state_checked(~S:Data,~P:Data,~Payload:Type,~F:Type,~H:Type,
  ~select:Notice.Notice<S,P> -> Maybe<&2,Rm.Record<S,Identity.Declaration<S,Payload>>>,
  retained:Bool,state:Mixed.State<S,P,F,H>) -> Mixed.State<S,P,F,H>:
  match retained state:
    case True{} state:state
    case False{} Mixed.State{Family.State{family,owners,journal,frameStart},failures}:
      Mixed.State{Family.State{family,owners,removal_batches_kept(~S,~P,~Payload,~select,journal),frameStart},failures}
def removal_release_context_checked(~S:Data,~C:Type,~R:Type,~P:Data,~Payload:Type,~F:Type,~H:Type,
  ~select:Notice.Notice<S,P> -> Maybe<&2,Rm.Record<S,Identity.Declaration<S,Payload>>>,
  state:Mixed.State<S,P,F,H>,tick:Nat,checked:W.World<S,C,R,Notice.Notice<S,P>> & Bool) -> Route.Runtime<S,C,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>>:
  match checked:
    case (world,+retained):
      Route.Runtime{removal_release_world_checked(~S,~C,~R,~P,~Payload,~select,retained,world),
        removal_release_state_checked(~S,~P,~Payload,~F,~H,~select,retained,state),tick}

def release_removal(~S:Data,~C:Type,~R:Type,~P:Data,~Payload:Type,~F:Type,~H:Type,
  ~select:Notice.Notice<S,P> -> Maybe<&2,Rm.Record<S,Identity.Declaration<S,Payload>>>,
  context:Route.Runtime<S,C,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>>,
  owner:RemovalOwner<S,Payload,Notice.Notice<S,P>,select>) -> Route.Runtime<S,C,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>>:
  match context owner:
    case Route.Runtime{world,state,tick} RemovalOwner{_,_}:
      removal_release_context_checked(~S,~C,~R,~P,~Payload,~F,~H,~select,state,tick,
        removal_world_retained(~S,~C,~R,~P,world))

def removal_param(~S:Data,~C:Type,~R:Type,~P:Data,~Payload:Type,~F:Type,~H:Type,
  ~inject:Identity.Declaration<S,Payload> -> W.Handle<S> -> Notice.Notice<S,P>,
  ~select:Notice.Notice<S,P> -> Maybe<&2,Rm.Record<S,Identity.Declaration<S,Payload>>>,
  ~selection:Provision.Selection<S,Payload,Notice.Notice<S,P>,inject,select>) -> RP.Param<Route.Runtime<S,C,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>>,RemovalOwner<S,Payload,Notice.Notice<S,P>,select>,RemovalView<S,Payload>,Nat,
  validate_removal(~S,~C,~R,~P,~Payload,~F,~H,~inject,~select,~selection),prepare_removal(~S,~C,~R,~P,~Payload,~F,~H,~select),commit_removal(~S,~C,~R,~P,~Payload,~F,~H,~select),release_removal(~S,~C,~R,~P,~Payload,~F,~H,~select)>:
  RP.make(~Route.Runtime<S,C,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>>,~RemovalOwner<S,Payload,Notice.Notice<S,P>,select>,~RemovalView<S,Payload>,~Nat,
    ~validate_removal(~S,~C,~R,~P,~Payload,~F,~H,~inject,~select,~selection),
    ~prepare_removal(~S,~C,~R,~P,~Payload,~F,~H,~select),
    ~commit_removal(~S,~C,~R,~P,~Payload,~F,~H,~select),
    ~release_removal(~S,~C,~R,~P,~Payload,~F,~H,~select),
    removal_access(~S,~Payload,~Notice.Notice<S,P>,~inject,~select,selection))

def initialize_removal(~S:Data,~C:Type,~R:Type,~P:Data,~Payload:Type,~F:Type,~H:Type,
  ~inject:Identity.Declaration<S,Payload> -> W.Handle<S> -> Notice.Notice<S,P>,
  ~select:Notice.Notice<S,P> -> Maybe<&2,Rm.Record<S,Identity.Declaration<S,Payload>>>,
  ~selection:Provision.Selection<S,Payload,Notice.Notice<S,P>,inject,select>,
  context:Route.Runtime<S,C,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>>,
  facts:RP.RegistrationFacts) -> Route.Runtime<S,C,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>> & (RemovalOwner<S,Payload,Notice.Notice<S,P>,select> & RP.Param<Route.Runtime<S,C,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>>,RemovalOwner<S,Payload,Notice.Notice<S,P>,select>,RemovalView<S,Payload>,Nat,
  validate_removal(~S,~C,~R,~P,~Payload,~F,~H,~inject,~select,~selection),prepare_removal(~S,~C,~R,~P,~Payload,~F,~H,~select),commit_removal(~S,~C,~R,~P,~Payload,~F,~H,~select),release_removal(~S,~C,~R,~P,~Payload,~F,~H,~select)>):
  match facts:
    case RP.RegistrationFacts{+namespace,+id,_,_}:
      (context,
       (RemovalOwner{facts,Rm.Reader{namespace,id,Identity.key(~S,~Payload,removal_identity(~S,~Payload,~Notice.Notice<S,P>,~inject,~select,selection)),0n}},
        removal_param(~S,~C,~R,~P,~Payload,~F,~H,~inject,~select,~selection)))

# Relation-failure cursors use the shared K allocator; queues and positions stay
# in Mixed.Failures and are only projected during prepare.
def relation_access(~S:Data,declarations:List<&2,KDecl.Declaration<S>>) -> List<&2,String>:
  KDecl.accesses(~S,declarations)
def relation_keys_equal(~S:Data,left:List<&2,KD.DescriptorKey<S>>,right:List<&2,KD.DescriptorKey<S>>) -> Bool:
  match left:
    case []:
      match right:
        case []:True{}
        case _ <> _:False{}
    case a <> restA:
      match right:
        case []:False{}
        case b <> restB:Bool.and(KD.key_equal(~S,a,b),relation_keys_equal(~S,restA,restB))
def has_reader(id:Maybe<&2,U32>) -> Bool:
  match id:
    case None{}:False{}
    case Some{_}:True{}

def relation_validated(~S:Data,~C:Type,~R:Type,~P:Data,~F:Type,~H:Type,
  ~declarations:List<&2,KDecl.Declaration<S>>,
  state:Mixed.State<S,P,F,H>,tick:Nat,facts:RP.RegistrationFacts,
  +id:Maybe<&2,U32>,+keys:List<&2,KD.DescriptorKey<S>>,
  registered:W.World<S,C,R,Notice.Notice<S,P>> & Bool) -> Route.Runtime<S,C,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>> & (RelationOwner<S,P> & Bool):
  match facts:
    case RP.RegistrationFacts{_,_,_,+access}:
      match registered:
        case (world,isRegistered):
          +expected=relation_access(~S,declarations)
          +valid=Bool.and(isRegistered,Bool.and(access_subset(expected,access),
            Bool.and(relation_keys_equal(~S,keys,KDecl.keys(~S,declarations)),has_reader(id))))
          (Route.Runtime{world,state,tick},(RelationOwner{facts,id,keys},valid))

def validate_relation(~S:Data,~C:Type,~R:Type,~P:Data,~F:Type,~H:Type,
  ~declarations:List<&2,KDecl.Declaration<S>>,
  context:Route.Runtime<S,C,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>>,
  owner:RelationOwner<S,P>) -> Route.Runtime<S,C,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>> & (RelationOwner<S,P> & Bool):
  match context owner:
    case Route.Runtime{world,state,tick} RelationOwner{+facts,id,keys}:
      relation_validated(~S,~C,~R,~P,~F,~H,~declarations,state,tick,facts,id,keys,
        registered_context(~S,~C,~R,~Notice.Notice<S,P>,world,facts))

def relation_prepared(~S:Data,~C:Type,~R:Type,~P:Data,~F:Type,~H:Type,
  context:Route.Runtime<S,C,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>>,
  owner:RelationOwner<S,P>) -> Route.Runtime<S,C,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>> & (RelationOwner<S,P> & (RelationView<S,P> & RelationDelta)):
  match context owner:
    case Route.Runtime{world,Mixed.State{typed,Mixed.Failures{+domains,+positions,+tick,frameStart,boundary,capacity,nextReader}},routeTick} RelationOwner{facts,+id,+keys}:
      match id:
        case None{}:
          +readThrough=tick
          (Route.Runtime{world,Mixed.State{typed,Mixed.Failures{domains,positions,tick,frameStart,boundary,capacity,nextReader}},routeTick},
            (RelationOwner{facts,id,keys},(RelationView{[]},RelationDelta{id,readThrough})))
        case Some{+readerId}:
          +position=K.position_or(Ev.lookup(positions,readerId),readerId,tick)
          +readings=KRead.all(~S,~Notice.Notice<S,P>,keys,domains,position)
          +readThrough=tick
          # Match standalone failed reads: activation retains unread input,
          # while only the successful commit advances its cursor.
          (Route.Runtime{world,Mixed.State{typed,Mixed.Failures{
            KRead.activate(~S,~Notice.Notice<S,P>,keys,domains,readerId),
            Ev.activate(positions,readerId,tick),tick,frameStart,boundary,capacity,nextReader}},routeTick},
            (RelationOwner{facts,id,keys},(RelationView{readings},RelationDelta{id,readThrough})))

def prepare_relation(~S:Data,~C:Type,~R:Type,~P:Data,~F:Type,~H:Type,
  ~declarations:List<&2,KDecl.Declaration<S>>,
  context:Route.Runtime<S,C,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>>,+cursor:Maybe<&2,Tick.Tick>,
  owner:RelationOwner<S,P>) -> Route.Runtime<S,C,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>> & (RelationOwner<S,P> & (RelationView<S,P> & RelationDelta)):
  relation_prepared(~S,~C,~R,~P,~F,~H,context,owner)

def relation_commit_match(~S:Data,~P:Data,
  domains:List<&2,KD.Domain<S,Notice.Notice<S,P>>>,positions:List<&2,Ev.Position>,
  keys:List<&2,KD.DescriptorKey<S>>, +readerId:U32,+readThrough:Nat,matched:Bool) -> List<&2,KD.Domain<S,Notice.Notice<S,P>>> & List<&2,Ev.Position>:
  match matched:
    case True{}:
      (KRead.activate(~S,~Notice.Notice<S,P>,keys,domains,readerId),
       Ev.update(Ev.activate(positions,readerId,readThrough),readerId,readThrough,False{}))
    case False{}:(domains,positions)

def relation_commit_selected(~S:Data,~P:Data,domains:List<&2,KD.Domain<S,Notice.Notice<S,P>>>,
  positions:List<&2,Ev.Position>,keys:List<&2,KD.DescriptorKey<S>>,id:Maybe<&2,U32>,
  delta:RelationDelta) -> List<&2,KD.Domain<S,Notice.Notice<S,P>>> & List<&2,Ev.Position>:
  match id delta:
    case Some{+readerId} RelationDelta{Some{deltaId},readThrough}:
      relation_commit_match(~S,~P,domains,positions,keys,readerId,readThrough,U32.is_eq(readerId,deltaId))
    case _ _:(domains,positions)

def relation_commit_updated(~S:Data,~C:Type,~R:Type,~P:Data,~F:Type,~H:Type,
  world:W.World<S,C,R,Notice.Notice<S,P>>,typed:Family.State<P,F,H>,
  tick:Nat,frameStart:Nat,boundary:Nat,capacity:Nat,nextReader:U32,routeTick:Nat,
  facts:RP.RegistrationFacts,id:Maybe<&2,U32>,keys:List<&2,KD.DescriptorKey<S>>,
  updated:List<&2,KD.Domain<S,Notice.Notice<S,P>>> & List<&2,Ev.Position>) -> Route.Runtime<S,C,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>> & RelationOwner<S,P>:
  match updated:
    case (updatedDomains,updatedPositions):
      (Route.Runtime{world,Mixed.State{typed,Mixed.Failures{updatedDomains,updatedPositions,tick,frameStart,boundary,capacity,nextReader}},routeTick},
       RelationOwner{facts,id,keys})

def relation_commit_state(~S:Data,~C:Type,~R:Type,~P:Data,~F:Type,~H:Type,
  world:W.World<S,C,R,Notice.Notice<S,P>>,typed:Family.State<P,F,H>,
  failures:Mixed.Failures<S,P>,routeTick:Nat,facts:RP.RegistrationFacts,
  +id:Maybe<&2,U32>,+keys:List<&2,KD.DescriptorKey<S>>,delta:RelationDelta) -> Route.Runtime<S,C,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>> & RelationOwner<S,P>:
  match failures:
    case Mixed.Failures{domains,positions,tick,frameStart,boundary,capacity,nextReader}:
      relation_commit_updated(~S,~C,~R,~P,~F,~H,world,typed,tick,frameStart,boundary,capacity,nextReader,routeTick,facts,id,keys,
        relation_commit_selected(~S,~P,domains,positions,keys,id,delta))

def relation_release_selected(~S:Data,~C:Type,~R:Type,~P:Data,~F:Type,~H:Type,
  context:Route.Runtime<S,C,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>>,
  id:Maybe<&2,U32>) -> Route.Runtime<S,C,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>>:
  match context id:
    case Route.Runtime{world,Mixed.State{typed,Mixed.Failures{domains,positions,+tick,frameStart,boundary,capacity,nextReader}},routeTick} None{}:
      Route.Runtime{world,Mixed.State{typed,Mixed.Failures{domains,positions,tick,frameStart,boundary,capacity,nextReader}},routeTick}
    case Route.Runtime{world,Mixed.State{typed,Mixed.Failures{domains,positions,+tick,frameStart,boundary,capacity,nextReader}},routeTick} Some{+readerId}:
      Route.Runtime{world,
        Mixed.State{typed,Mixed.Failures{
          KDispose.release(~S,~Notice.Notice<S,P>,domains,readerId),
          Ev.update(positions,readerId,tick,True{}),tick,frameStart,boundary,capacity,nextReader}},routeTick}

def release_relation(~S:Data,~C:Type,~R:Type,~P:Data,~F:Type,~H:Type,
  context:Route.Runtime<S,C,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>>,
  owner:RelationOwner<S,P>) -> Route.Runtime<S,C,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>>:
  match context owner:
    case context RelationOwner{_,id,_}:relation_release_selected(~S,~C,~R,~P,~F,~H,context,id)

def commit_relation(~S:Data,~C:Type,~R:Type,~P:Data,~F:Type,~H:Type,
  context:Route.Runtime<S,C,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>>,
  owner:RelationOwner<S,P>,delta:RelationDelta,+cursor:Tick.Tick) -> Route.Runtime<S,C,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>> & RelationOwner<S,P>:
  match context owner:
    case Route.Runtime{world,Mixed.State{typed,failures},routeTick} RelationOwner{facts,id,keys}:
      relation_commit_state(~S,~C,~R,~P,~F,~H,world,typed,failures,routeTick,facts,id,keys,delta)

def relation_param(~S:Data,~C:Type,~R:Type,~P:Data,~F:Type,~H:Type,
  ~declarations:List<&2,KDecl.Declaration<S>>) -> RP.Param<Route.Runtime<S,C,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>>,RelationOwner<S,P>,RelationView<S,P>,RelationDelta,
  validate_relation(~S,~C,~R,~P,~F,~H,~declarations),prepare_relation(~S,~C,~R,~P,~F,~H,~declarations),commit_relation(~S,~C,~R,~P,~F,~H),release_relation(~S,~C,~R,~P,~F,~H)>:
  RP.make(~Route.Runtime<S,C,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>>,~RelationOwner<S,P>,~RelationView<S,P>,~RelationDelta,
    ~validate_relation(~S,~C,~R,~P,~F,~H,~declarations),
    ~prepare_relation(~S,~C,~R,~P,~F,~H,~declarations),
    ~commit_relation(~S,~C,~R,~P,~F,~H),
    ~release_relation(~S,~C,~R,~P,~F,~H),
    relation_access(~S,declarations))

def relation_initialized_id(~S:Data,~C:Type,~R:Type,~P:Data,~F:Type,~H:Type,
  ~declarations:List<&2,KDecl.Declaration<S>>,
  context:Route.Runtime<S,C,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>>,
  facts:RP.RegistrationFacts,id:Maybe<&2,U32>) -> Route.Runtime<S,C,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>> & (RelationOwner<S,P> & RP.Param<Route.Runtime<S,C,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>>,RelationOwner<S,P>,RelationView<S,P>,RelationDelta,
  validate_relation(~S,~C,~R,~P,~F,~H,~declarations),prepare_relation(~S,~C,~R,~P,~F,~H,~declarations),commit_relation(~S,~C,~R,~P,~F,~H),release_relation(~S,~C,~R,~P,~F,~H)>):
  (context,(RelationOwner{facts,id,KDecl.keys(~S,declarations)},relation_param(~S,~C,~R,~P,~F,~H,declarations)))

def relation_initialized(~S:Data,~C:Type,~R:Type,~P:Data,~F:Type,~H:Type,
  ~declarations:List<&2,KDecl.Declaration<S>>,
  facts:RP.RegistrationFacts,
  reserved:Route.Runtime<S,C,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>> & Maybe<&2,U32>) -> Route.Runtime<S,C,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>> & (RelationOwner<S,P> & RP.Param<Route.Runtime<S,C,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>>,RelationOwner<S,P>,RelationView<S,P>,RelationDelta,
  validate_relation(~S,~C,~R,~P,~F,~H,~declarations),prepare_relation(~S,~C,~R,~P,~F,~H,~declarations),commit_relation(~S,~C,~R,~P,~F,~H),release_relation(~S,~C,~R,~P,~F,~H)>):
  match reserved:
    case (context,id):relation_initialized_id(~S,~C,~R,~P,~F,~H,~declarations,context,facts,id)

def initialize_relation(~S:Data,~C:Type,~R:Type,~P:Data,~F:Type,~H:Type,
  ~declarations:List<&2,KDecl.Declaration<S>>,
  context:Route.Runtime<S,C,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>>,
  facts:RP.RegistrationFacts) -> Route.Runtime<S,C,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>> & (RelationOwner<S,P> & RP.Param<Route.Runtime<S,C,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>>,RelationOwner<S,P>,RelationView<S,P>,RelationDelta,
  validate_relation(~S,~C,~R,~P,~F,~H,~declarations),prepare_relation(~S,~C,~R,~P,~F,~H,~declarations),commit_relation(~S,~C,~R,~P,~F,~H),release_relation(~S,~C,~R,~P,~F,~H)>):
  relation_initialized(~S,~C,~R,~P,~F,~H,~declarations,facts,
    Mixed.reserve_failure_reader(~S,~C,~R,~P,~F,~H,context))
