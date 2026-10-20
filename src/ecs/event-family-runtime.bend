import Base
import ./world.bend as W
import ./event-runtime.bend as Ev
import ./ordinary-event-family.bend as Composition
import ./event-family-routing.bend as Route
import ./event-stream.bend as Leaf

# Advanced affine family state containing actual typed leaves F and owners H,
# with a shared Data publication journal and frame marker. It owns no second World.
# Canonical provisioning couples routes; raw callbacks remain trusted setup.
type State<P:Data,F:Type,H:Type> is Type:
  State{family:F,owners:H,journal:List<&2,Ev.Batch<P>>,frameStart:Nat}
# Create typed leaves from the canonical Provision domains/capacity, retaining
# actual World and supplied H owners with empty journal/tick zero. Does not register
# readers or automatically synchronize an existing World publication log.
def setup(~S:Data,~C:Type,~R:Type,~P:Data,~D:Data,~F:Type,~H:Type,~make:D -> Nat -> F,~sync:F -> Nat -> List<&2,P> -> F,~frame:F -> Nat -> F,~retain:F -> Nat -> List<&2,P> -> F & List<&2,P>,~inventory:F -> F & List<&2,String>,world:W.World<S,C,R,P>,provision:Composition.Provision<S,P,D,F,make,sync,frame,retain,inventory>,owners:H,capacity:Nat) -> Route.Runtime<S,C,R,P,State<P,F,H>>:
  match provision:
    case Composition.Provision{domains}:Route.Runtime{world,State{make(domains,capacity),owners,[],0n},0n}
def synchronize_world(~S:Data,~C:Type,~R:Type,~P:Data,~F:Type,~H:Type,~sync:F -> Nat -> List<&2,P> -> F,state:State<P,F,H>,+tick:Nat,observed:W.World<S,C,R,P> & List<&2,P>) -> W.World<S,C,R,P> & State<P,F,H>:
  match state:
    case State{family,owners,+journal,frameStart}:
      (world,records)=observed
      +published=List.drop(&2,P,records,Ev.size(~P,journal))
      (world,State{sync(family,tick,published),owners,Ev.sync_checked(~P,Nat.is_lt(0n,Ev.count(~P,published)),journal,tick,published),frameStart})
# Advanced publication synchronization: thread actual World/state and distribute
# World log suffix beyond journal length through the generated sync callback.
# Append nonempty suffix batches at the supplied tick. Caller must preserve the
# log/journal prefix invariant; this does not execute a barrier or advance readers.
def synchronize(~S:Data,~C:Type,~R:Type,~P:Data,~F:Type,~H:Type,~sync:F -> Nat -> List<&2,P> -> F,world:W.World<S,C,R,P>,state:State<P,F,H>,tick:Nat) -> W.World<S,C,R,P> & State<P,F,H>:
  synchronize_world(~S,~C,~R,~P,~F,~H,~sync,state,tick,W.events_view(~S,~C,~R,~P,world))
def kept_batch(~P:Data,keep:Bool,tick:Nat,records:List<&2,P>,journal:List<&2,Ev.Batch<P>>) -> List<&2,Ev.Batch<P>>:
  match keep:
    case False{}:journal
    case True{}:Ev.Batch{tick,records} <> journal
def kept_batch_returned(~P:Data,~F:Type,tick:Nat,+records:List<&2,P>,returned:F & List<&2,Ev.Batch<P>>) -> F & List<&2,Ev.Batch<P>>:
  match returned:
    case (family,journal):(family,kept_batch(~P,Nat.is_lt(0n,Ev.count(~P,records)),tick,records,journal))
def kept_batch_head(~P:Data,~F:Type,rest:F -> F & List<&2,Ev.Batch<P>>,tick:Nat,returned:F & List<&2,P>) -> F & List<&2,Ev.Batch<P>>:
  match returned:
    case (family,records):kept_batch_returned(~P,~F,tick,records,rest(family))
def retained_journal(~P:Data,~F:Type,~retain:F -> Nat -> List<&2,P> -> F & List<&2,P>,journal:List<&2,Ev.Batch<P>>,family:F) -> F & List<&2,Ev.Batch<P>>:
  match journal:
    case []:(family,[])
    case Ev.Batch{+tick,records} <> rest:kept_batch_head(~P,~F,(family => retained_journal(~P,~F,~retain,rest,family)),tick,retain(family,tick,records))
def framed_journal(~S:Data,~C:Type,~R:Type,~P:Data,~F:Type,~H:Type,world:W.World<S,C,R,P>,owners:H,+tick:Nat,returned:F & List<&2,Ev.Batch<P>>) -> Route.Runtime<S,C,R,P,State<P,F,H>>:
  match returned:
    case (family,+journal):Route.Runtime{W.events_replace(~S,~C,~R,~P,world,Ev.values(~P,journal)),State{family,owners,journal,tick},tick}
# Apply each generated family frame/retention operation at current routing tick,
# retain only still-represented journal records, and replace World event log with
# those retained values. Return actual family/owners/World; no gameplay dispatch
# or implicit affine payload-log retirement is added to this Data layer.
def frame(~S:Data,~C:Type,~R:Type,~P:Data,~F:Type,~H:Type,~frame:F -> Nat -> F,~retain:F -> Nat -> List<&2,P> -> F & List<&2,P>,runtime:Route.Runtime<S,C,R,P,State<P,F,H>>) -> Route.Runtime<S,C,R,P,State<P,F,H>>:
  match runtime:
    case Route.Runtime{world,State{family,owners,journal,_},+tick}:framed_journal(~S,~C,~R,~P,~F,~H,world,owners,tick,retained_journal(~P,~F,~retain,journal,frame(family,tick)))
def inventory_returned(~S:Data,~C:Type,~R:Type,~P:Data,~F:Type,~H:Type,world:W.World<S,C,R,P>,owners:H,journal:List<&2,Ev.Batch<P>>,frameStart:Nat,tick:Nat,returned:F & List<&2,String>) -> Route.Runtime<S,C,R,P,State<P,F,H>> & List<&2,String>:
  match returned:
    case (family,names):(Route.Runtime{world,State{family,owners,journal,frameStart},tick},names)
def inventory_optional(~S:Data,~C:Type,~R:Type,~P:Data,~F:Type,~H:Type,returned:Route.Runtime<S,C,R,P,State<P,F,H>> & List<&2,String>) -> Route.Runtime<S,C,R,P,State<P,F,H>> & Maybe<&2,List<&2,String>>:
  match returned:
    case (runtime,names):(runtime,Some{names})
# Return actual Runtime and optional detached family inventory. Disabled bypasses
# the inventory callback; enabled threads actual F through it. No synchronization,
# trim, frame or reader acknowledgement is performed by this observation.
def inventory_enabled(~S:Data,~C:Type,~R:Type,~P:Data,~F:Type,~H:Type,~inventory:F -> F & List<&2,String>,enabled:Bool,runtime:Route.Runtime<S,C,R,P,State<P,F,H>>) -> Route.Runtime<S,C,R,P,State<P,F,H>> & Maybe<&2,List<&2,String>>:
  match enabled runtime:
    case False{} runtime:(runtime,None{})
    case True{} Route.Runtime{world,State{family,owners,journal,frameStart},tick}:inventory_optional(~S,~C,~R,~P,~F,~H,inventory_returned(~S,~C,~R,~P,~F,~H,world,owners,journal,frameStart,tick,inventory(family)))

def selected_state(~S:Data,~E:Data,~P:Data,~F:Type,~H:Type,owners:H,journal:List<&2,Ev.Batch<P>>,frameStart:Nat,returned:F & Leaf.Stream<S,E>) -> State<P,F,H> & Leaf.Stream<S,E>:
  match returned:
    case (family,stream):(State{family,owners,journal,frameStart},stream)
# Trusted selector adapter extracting a copied Data stream while retaining actual
# family/owners/journal. Selector coherence comes from canonical provision, not
# a universal ownership or route-validity check in this wrapper.
def take(~S:Data,~E:Data,~P:Data,~F:Type,~H:Type,~take:F -> F & Leaf.Stream<S,E>,state:State<P,F,H>) -> State<P,F,H> & Leaf.Stream<S,E>:
  match state:
    case State{family,owners,journal,frameStart}:selected_state(~S,~E,~P,~F,~H,owners,journal,frameStart,take(family))
# Trusted selector adapter reinserting a Data stream into actual family state,
# preserving owners/journal/frame marker. Does not validate arbitrary stream origin
# or manufacture a reader capability.
def put(~S:Data,~E:Data,~P:Data,~F:Type,~H:Type,~put:F -> Leaf.Stream<S,E> -> F,state:State<P,F,H>,stream:Leaf.Stream<S,E>) -> State<P,F,H>:
  match state:
    case State{family,owners,journal,frameStart}:State{put(family,stream),owners,journal,frameStart}
