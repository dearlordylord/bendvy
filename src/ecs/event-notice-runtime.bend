import Base
import ./event-stream.bend as Leaf
import ./world.bend as W
import ./relation-commands.bend as Notice
import ./relation-failure-runtime.bend as K
import ./internal/relation-failures/domains.bend as D
import ./internal/relation-failures/routing.bend as FailureRoute
import ./event-runtime.bend as Ev
import ./event-family-runtime.bend as Family
import ./event-family-routing.bend as Route

# Descriptor metadata owns no second World. Typed publication ticks remain separate.
type Failures<S:Data,P:Data> is Data:
  Failures{domains:List<&2,D.Domain<S,Notice.Notice<S,P>>>,positions:List<&2,Ev.Position>,tick:Nat,frameStart:Nat,boundary:Nat,capacity:Nat,nextReader:U32}
type State<S:Data,P:Data,F:Type,H:Type> is Type:
  State{typed:Family.State<P,F,H>,failures:Failures<S,P>}

def originals(~S:Data,~P:Data,records:List<&2,Notice.Notice<S,P>>) -> List<&2,P>:
  match records:
    case []:[]
    case Notice.Original{event} <> rest:event <> originals(~S,~P,rest)
    case Notice.RelationFailed{_} <> rest:originals(~S,~P,rest)
    case Notice.ComponentRemoved{_} <> rest:originals(~S,~P,rest)
    case Notice.CleanupPaused{_} <> rest:originals(~S,~P,rest)

def started(~S:Data,~C:Type,~R:Type,~P:Data,~F:Type,~H:Type,typed:Family.State<P,F,H>,runtime:K.Runtime<S,C,R,Notice.Notice<S,P>>) -> Route.Runtime<S,C,R,Notice.Notice<S,P>,State<S,P,F,H>>:
  match runtime:
    case K.Runtime{world,domains,positions,tick,frameStart,boundary,capacity,nextReader}:Route.Runtime{world,State{typed,Failures{domains,positions,tick,frameStart,boundary,capacity,nextReader}},0n}

def start(~S:Data,~C:Type,~R:Type,~P:Data,~F:Type,~H:Type,world:W.World<S,C,R,Notice.Notice<S,P>>,family:F,owners:H) -> Route.Runtime<S,C,R,Notice.Notice<S,P>,State<S,P,F,H>>:
  started(~S,~C,~R,~P,~F,~H,Family.State{family,owners,[],0n},K.start(~S,~C,~R,~Notice.Notice<S,P>,world))

def synchronized(~S:Data,~C:Type,~R:Type,~P:Data,~F:Type,~H:Type,~sync:F -> Nat -> List<&2,P> -> F,state:State<S,P,F,H>,+tick:Nat,observed:W.World<S,C,R,Notice.Notice<S,P>> & List<&2,Notice.Notice<S,P>>) -> W.World<S,C,R,Notice.Notice<S,P>> & State<S,P,F,H>:
  match state:
    case State{Family.State{family,owners,+journal,frameStart},failures}:
      (world,records)=observed
      +published=List.drop(&2,P,originals(~S,~P,records),Ev.size(~P,journal))
      (world,State{Family.State{sync(family,tick,published),owners,Ev.sync_checked(~P,Nat.is_lt(0n,Ev.count(~P,published)),journal,tick,published),frameStart},failures})

def synchronize(~S:Data,~C:Type,~R:Type,~P:Data,~F:Type,~H:Type,~sync:F -> Nat -> List<&2,P> -> F,world:W.World<S,C,R,Notice.Notice<S,P>>,state:State<S,P,F,H>,tick:Nat) -> W.World<S,C,R,Notice.Notice<S,P>> & State<S,P,F,H>:
  synchronized(~S,~C,~R,~P,~F,~H,~sync,state,tick,W.events_view(~S,~C,~R,~Notice.Notice<S,P>,world))

# The detached typed owner contains no World; K operations receive the sole World.
def failure_runtime(~S:Data,~C:Type,~R:Type,~P:Data,~F:Type,~H:Type,runtime:Route.Runtime<S,C,R,Notice.Notice<S,P>,State<S,P,F,H>>) -> K.Runtime<S,C,R,Notice.Notice<S,P>> & (Family.State<P,F,H> & Nat):
  match runtime:
    case Route.Runtime{world,State{typed,Failures{domains,positions,tick,frameStart,boundary,capacity,nextReader}},typedTick}:(K.Runtime{world,domains,positions,tick,frameStart,boundary,capacity,nextReader},(typed,typedTick))
def failure_returned(~S:Data,~C:Type,~R:Type,~P:Data,~F:Type,~H:Type,held:Family.State<P,F,H> & Nat,runtime:K.Runtime<S,C,R,Notice.Notice<S,P>>) -> Route.Runtime<S,C,R,Notice.Notice<S,P>,State<S,P,F,H>>:
  match held runtime:
    case (typed,typedTick) K.Runtime{world,domains,positions,tick,frameStart,boundary,capacity,nextReader}:
      Route.Runtime{world,State{typed,Failures{domains,positions,tick,frameStart,boundary,capacity,nextReader}},typedTick}

# Slots preserve the original mixed-log positions, including partially retained Publications.
type Retention<P:Data,F:Type> is Type:
  Retention{family:F,journal:List<&2,Ev.Batch<P>>,slots:List<&2,List<&2,P>>}
def retained_record(~P:Data,~F:Type,+head:List<&2,P>,returned:F & (List<&2,P> & List<&2,List<&2,P>>)) -> F & (List<&2,P> & List<&2,List<&2,P>>):
  match returned:
    case (family,(records,slots)):(family,(Ev.append(~P,head,records),head <> slots))
def retained_record_head(~P:Data,~F:Type,rest:F -> F & (List<&2,P> & List<&2,List<&2,P>>),returned:F & List<&2,P>) -> F & (List<&2,P> & List<&2,List<&2,P>>):
  match returned:
    case (family,+head):retained_record(~P,~F,head,rest(family))
def retained_records(~P:Data,~F:Type,~retain:F -> Nat -> List<&2,P> -> F & List<&2,P>,records:List<&2,P>,family:F,+tick:Nat) -> F & (List<&2,P> & List<&2,List<&2,P>>):
  match records:
    case []:(family,([],[]))
    case head <> rest:retained_record_head(~P,~F,(family => retained_records(~P,~F,~retain,rest,family,tick)),retain(family,tick,[head]))
def retained_batch_join(~P:Data,~F:Type,tick:Nat,+records:List<&2,P>,slots:List<&2,List<&2,P>>,returned:Retention<P,F>) -> Retention<P,F>:
  match returned:
    case Retention{family,journal,tail}:Retention{family,Family.kept_batch(~P,Nat.is_lt(0n,Ev.count(~P,records)),tick,records,journal),List.append(&2,List<&2,P>,slots,tail)}
def retained_batch_head(~P:Data,~F:Type,rest:F -> Retention<P,F>,tick:Nat,returned:F & (List<&2,P> & List<&2,List<&2,P>>)) -> Retention<P,F>:
  match returned:
    case (family,(+records,slots)):retained_batch_join(~P,~F,tick,records,slots,rest(family))
def retention(~P:Data,~F:Type,~retain:F -> Nat -> List<&2,P> -> F & List<&2,P>,journal:List<&2,Ev.Batch<P>>,family:F) -> Retention<P,F>:
  match journal:
    case []:Retention{family,[],[]}
    case Ev.Batch{+tick,records} <> rest:retained_batch_head(~P,~F,(family => retention(~P,~F,~retain,rest,family)),tick,retained_records(~P,~F,~retain,records,family,tick))
def original_notices(~S:Data,~P:Data,records:List<&2,P>) -> List<&2,Notice.Notice<S,P>>:
  match records:
    case []:[]
    case head <> rest:Notice.Original{head} <> original_notices(~S,~P,rest)
def rebuilt(~S:Data,~P:Data,notices:List<&2,Notice.Notice<S,P>>,slots:List<&2,List<&2,P>>) -> List<&2,Notice.Notice<S,P>>:
  match notices slots:
    case Nil{} _:[]
    case Con{Notice.Original{_},rest} Nil{}:rebuilt(~S,~P,rest,[])
    case Con{Notice.Original{_},rest} Con{head,tail}:List.append(&2,Notice.Notice<S,P>,original_notices(~S,~P,head),rebuilt(~S,~P,rest,tail))
    case Con{Notice.RelationFailed{failure},rest} slots:Notice.RelationFailed{failure} <> rebuilt(~S,~P,rest,slots)
    case Con{Notice.ComponentRemoved{id},rest} slots:Notice.ComponentRemoved{id} <> rebuilt(~S,~P,rest,slots)
    case Con{Notice.CleanupPaused{frames},rest} slots:Notice.CleanupPaused{frames} <> rebuilt(~S,~P,rest,slots)
def framed(~S:Data,~C:Type,~R:Type,~P:Data,~F:Type,~H:Type,owners:H,failures:Failures<S,P>,+tick:Nat,observed:W.World<S,C,R,Notice.Notice<S,P>> & List<&2,Notice.Notice<S,P>>,returned:Retention<P,F>) -> Route.Runtime<S,C,R,Notice.Notice<S,P>,State<S,P,F,H>>:
  match observed returned:
    case (world,notices) Retention{family,journal,slots}:
      Route.Runtime{W.events_replace(~S,~C,~R,~Notice.Notice<S,P>,world,rebuilt(~S,~P,notices,slots)),State{Family.State{family,owners,journal,tick},failures},tick}
def frame(~S:Data,~C:Type,~R:Type,~P:Data,~F:Type,~H:Type,~frame:F -> Nat -> F,~retain:F -> Nat -> List<&2,P> -> F & List<&2,P>,runtime:Route.Runtime<S,C,R,Notice.Notice<S,P>,State<S,P,F,H>>) -> Route.Runtime<S,C,R,Notice.Notice<S,P>,State<S,P,F,H>>:
  match runtime:
    case Route.Runtime{world,State{Family.State{family,owners,journal,_},failures},+tick}:framed(~S,~C,~R,~P,~F,~H,owners,failures,tick,W.events_view(~S,~C,~R,~Notice.Notice<S,P>,world),retention(~P,~F,~retain,journal,frame(family,tick)))

def failure_framed(~S:Data,~C:Type,~R:Type,~P:Data,~F:Type,~H:Type,detached:K.Runtime<S,C,R,Notice.Notice<S,P>> & (Family.State<P,F,H> & Nat)) -> Route.Runtime<S,C,R,Notice.Notice<S,P>,State<S,P,F,H>>:
  match detached:
    case (runtime,held):failure_returned(~S,~C,~R,~P,~F,~H,held,K.frame(~S,~C,~R,~Notice.Notice<S,P>,runtime))
def frame_failures(~S:Data,~C:Type,~R:Type,~P:Data,~F:Type,~H:Type,runtime:Route.Runtime<S,C,R,Notice.Notice<S,P>,State<S,P,F,H>>) -> Route.Runtime<S,C,R,Notice.Notice<S,P>,State<S,P,F,H>>:
  failure_framed(~S,~C,~R,~P,~F,~H,failure_runtime(~S,~C,~R,~P,~F,~H,runtime))
def inventoried(~S:Data,~C:Type,~R:Type,~P:Data,~F:Type,~H:Type,world:W.World<S,C,R,Notice.Notice<S,P>>,owners:H,journal:List<&2,Ev.Batch<P>>,frameStart:Nat,failures:Failures<S,P>,tick:Nat,returned:F & List<&2,String>) -> Route.Runtime<S,C,R,Notice.Notice<S,P>,State<S,P,F,H>> & Maybe<&2,List<&2,String>>:
  match returned:
    case (family,names):(Route.Runtime{world,State{Family.State{family,owners,journal,frameStart},failures},tick},Some{names})
def inventory_enabled(~S:Data,~C:Type,~R:Type,~P:Data,~F:Type,~H:Type,~inventory:F -> F & List<&2,String>,enabled:Bool,runtime:Route.Runtime<S,C,R,Notice.Notice<S,P>,State<S,P,F,H>>) -> Route.Runtime<S,C,R,Notice.Notice<S,P>,State<S,P,F,H>> & Maybe<&2,List<&2,String>>:
  match enabled runtime:
    case False{} runtime:(runtime,None{})
    case True{} Route.Runtime{world,State{Family.State{family,owners,journal,frameStart},failures},tick}:inventoried(~S,~C,~R,~P,~F,~H,world,owners,journal,frameStart,failures,tick,inventory(family))

def selected(~S:Data,~E:Data,~P:Data,~F:Type,~H:Type,failures:Failures<S,P>,returned:Family.State<P,F,H> & Leaf.Stream<S,E>) -> State<S,P,F,H> & Leaf.Stream<S,E>:
  match returned:
    case (typed,stream):(State{typed,failures},stream)
def take(~S:Data,~E:Data,~P:Data,~F:Type,~H:Type,~take:F -> F & Leaf.Stream<S,E>,state:State<S,P,F,H>) -> State<S,P,F,H> & Leaf.Stream<S,E>:
  match state:
    case State{typed,failures}:selected(~S,~E,~P,~F,~H,failures,Family.take(~S,~E,~P,~F,~H,~take,typed))
def put(~S:Data,~E:Data,~P:Data,~F:Type,~H:Type,~put:F -> Leaf.Stream<S,E> -> F,state:State<S,P,F,H>,stream:Leaf.Stream<S,E>) -> State<S,P,F,H>:
  match state:
    case State{typed,failures}:State{Family.put(~S,~E,~P,~F,~H,~put,typed,stream),failures}

# Reserve from the same failure-reader pool used by standalone K.register.
def reserved_failure_reader(~S:Data,~C:Type,~R:Type,~P:Data,~F:Type,~H:Type,held:Family.State<P,F,H> & Nat,result:K.Runtime<S,C,R,Notice.Notice<S,P>> & Maybe<&2,U32>) -> Route.Runtime<S,C,R,Notice.Notice<S,P>,State<S,P,F,H>> & Maybe<&2,U32>:
  match result:
    case (runtime,id):(failure_returned(~S,~C,~R,~P,~F,~H,held,runtime),id)
def reserve_failure_reader_detached(~S:Data,~C:Type,~R:Type,~P:Data,~F:Type,~H:Type,detached:K.Runtime<S,C,R,Notice.Notice<S,P>> & (Family.State<P,F,H> & Nat)) -> Route.Runtime<S,C,R,Notice.Notice<S,P>,State<S,P,F,H>> & Maybe<&2,U32>:
  match detached:
    case (runtime,held):reserved_failure_reader(~S,~C,~R,~P,~F,~H,held,K.reserve_reader(~S,~C,~R,~Notice.Notice<S,P>,runtime))
def reserve_failure_reader(~S:Data,~C:Type,~R:Type,~P:Data,~F:Type,~H:Type,runtime:Route.Runtime<S,C,R,Notice.Notice<S,P>,State<S,P,F,H>>) -> Route.Runtime<S,C,R,Notice.Notice<S,P>,State<S,P,F,H>> & Maybe<&2,U32>:
  reserve_failure_reader_detached(~S,~C,~R,~P,~F,~H,failure_runtime(~S,~C,~R,~P,~F,~H,runtime))


# One outer ingestion boundary, shared by every parameter in an invocation.
def ingested_failures(~S:Data,~C:Type,~R:Type,~P:Data,~F:Type,~H:Type,typed:Family.State<P,F,H>,positions:List<&2,Ev.Position>,+tick:Nat,start:Nat,boundary:Nat,capacity:Nat,nextReader:U32,returned:W.World<S,C,R,Notice.Notice<S,P>> & List<&2,D.Domain<S,Notice.Notice<S,P>>>) -> Route.Runtime<S,C,R,Notice.Notice<S,P>,State<S,P,F,H>>:
  match returned:
    case (world,domains):Route.Runtime{world,State{typed,Failures{domains,positions,tick,start,boundary,capacity,nextReader}},tick}
def ingested_typed(~S:Data,~C:Type,~R:Type,~P:Data,~F:Type,~H:Type,~classify:Notice.Notice<S,P> -> Maybe<D.DescriptorKey<S>>,+tick:Nat,returned:W.World<S,C,R,Notice.Notice<S,P>> & State<S,P,F,H>) -> Route.Runtime<S,C,R,Notice.Notice<S,P>,State<S,P,F,H>>:
  match returned:
    case (world,State{typed,Failures{domains,positions,_,start,boundary,capacity,nextReader}}):
      ingested_failures(~S,~C,~R,~P,~F,~H,typed,positions,tick,start,boundary,capacity,nextReader,FailureRoute.collect(~S,~C,~R,~Notice.Notice<S,P>,~classify,world,tick,domains))
def ingest(~S:Data,~C:Type,~R:Type,~P:Data,~F:Type,~H:Type,~sync:F -> Nat -> List<&2,P> -> F,~classify:Notice.Notice<S,P> -> Maybe<D.DescriptorKey<S>>,+tick:Nat,runtime:Route.Runtime<S,C,R,Notice.Notice<S,P>,State<S,P,F,H>>) -> Route.Runtime<S,C,R,Notice.Notice<S,P>,State<S,P,F,H>>:
  match runtime:
    case Route.Runtime{world,state,_}:ingested_typed(~S,~C,~R,~P,~F,~H,~classify,tick,synchronize(~S,~C,~R,~P,~F,~H,~sync,world,state,tick))
def attempt_clocked(~S:Data,~C:Type,~R:Type,~P:Data,~F:Type,~H:Type,state:State<S,P,F,H>,tick:Nat,clocked:W.World<S,C,R,Notice.Notice<S,P>> & U32) -> Route.Runtime<S,C,R,Notice.Notice<S,P>,State<S,P,F,H>>:
  match clocked:
    case (world,_):Route.Runtime{world,state,1n+tick}
def attempt_ingested(~S:Data,~C:Type,~R:Type,~P:Data,~F:Type,~H:Type,runtime:Route.Runtime<S,C,R,Notice.Notice<S,P>,State<S,P,F,H>>) -> Route.Runtime<S,C,R,Notice.Notice<S,P>,State<S,P,F,H>>:
  match runtime:
    case Route.Runtime{world,state,tick}:attempt_clocked(~S,~C,~R,~P,~F,~H,state,tick,W.advance_clock(~S,~C,~R,~Notice.Notice<S,P>,world))
# Standalone and composed operations share histories but may advance different
# administrative clocks. Never publish below any already observed boundary.
def before_state(~S:Data,~C:Type,~R:Type,~P:Data,~F:Type,~H:Type,~sync:F -> Nat -> List<&2,P> -> F,~classify:Notice.Notice<S,P> -> Maybe<D.DescriptorKey<S>>,state:State<S,P,F,H>,+tick:Nat,world:W.World<S,C,R,Notice.Notice<S,P>>,clock:U32) -> Route.Runtime<S,C,R,Notice.Notice<S,P>,State<S,P,F,H>>:
  match state:
    case State{typed,Failures{domains,positions,+failureTick,start,boundary,capacity,nextReader}}:
      attempt_ingested(~S,~C,~R,~P,~F,~H,ingest(~S,~C,~R,~P,~F,~H,~sync,~classify,Nat.max(1n,Nat.max(tick,Nat.max(failureTick,U32.to_nat(clock)))),Route.Runtime{world,State{typed,Failures{domains,positions,failureTick,start,boundary,capacity,nextReader}},tick}))
def before_clocked(~S:Data,~C:Type,~R:Type,~P:Data,~F:Type,~H:Type,~sync:F -> Nat -> List<&2,P> -> F,~classify:Notice.Notice<S,P> -> Maybe<D.DescriptorKey<S>>,state:State<S,P,F,H>,tick:Nat,clocked:W.World<S,C,R,Notice.Notice<S,P>> & U32) -> Route.Runtime<S,C,R,Notice.Notice<S,P>,State<S,P,F,H>>:
  match clocked:
    case (world,clock):before_state(~S,~C,~R,~P,~F,~H,~sync,~classify,state,tick,world,clock)
# Zero is the initial unread cursor, so startup publications need a positive epoch.
# Called only after registration/parameter validation; preparation follows it.
def before_attempt(~S:Data,~C:Type,~R:Type,~P:Data,~F:Type,~H:Type,~sync:F -> Nat -> List<&2,P> -> F,~classify:Notice.Notice<S,P> -> Maybe<D.DescriptorKey<S>>,runtime:Route.Runtime<S,C,R,Notice.Notice<S,P>,State<S,P,F,H>>) -> Route.Runtime<S,C,R,Notice.Notice<S,P>,State<S,P,F,H>>:
  match runtime:
    case Route.Runtime{world,state,tick}:before_clocked(~S,~C,~R,~P,~F,~H,~sync,~classify,state,tick,W.clock(~S,~C,~R,~Notice.Notice<S,P>,world))
# Called once after successful cursor commits, without another clock advance.
def after_success(~S:Data,~C:Type,~R:Type,~P:Data,~F:Type,~H:Type,~sync:F -> Nat -> List<&2,P> -> F,~classify:Notice.Notice<S,P> -> Maybe<D.DescriptorKey<S>>,runtime:Route.Runtime<S,C,R,Notice.Notice<S,P>,State<S,P,F,H>>) -> Route.Runtime<S,C,R,Notice.Notice<S,P>,State<S,P,F,H>>:
  match runtime:
    case Route.Runtime{world,state,+tick}:ingest(~S,~C,~R,~P,~F,~H,~sync,~classify,tick,Route.Runtime{world,state,tick})


# Internal invocation transport: detached metadata retains all shared owners.
def split(~S:Data,~C:Type,~R:Type,~P:Data,~F:Type,~H:Type,runtime:Route.Runtime<S,C,R,Notice.Notice<S,P>,State<S,P,F,H>>) -> W.World<S,C,R,Notice.Notice<S,P>> & (State<S,P,F,H> & Nat):
  match runtime:
    case Route.Runtime{world,state,tick}:(world,(state,tick))
def join(~S:Data,~C:Type,~R:Type,~P:Data,~F:Type,~H:Type,world:W.World<S,C,R,Notice.Notice<S,P>>,metadata:State<S,P,F,H> & Nat) -> Route.Runtime<S,C,R,Notice.Notice<S,P>,State<S,P,F,H>>:
  match metadata:
    case (state,tick):Route.Runtime{world,state,tick}
