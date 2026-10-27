import Base
import ./execution-composer-layout.bend as Layout
import ./owner-product.bend as Product
import ./world.bend as W
import ./execution-reservation-task.bend as Task

# Closed component-layout traversal: each family appears once, with its own
# actual affine payload type. None omits that family. Resources are separate.
def Payload(layout:Layout.Layout) -> Type:
  match layout:
    case Layout.EmptyLayout{}:Unit
    case Layout.LayoutLeaf{P,_,_,_}:Maybe<&1,P>
    case Layout.ClassifiedLayoutLeaf{P,_,_,_,_}:Maybe<&1,P>
    case Layout.LayoutPair{left,right}:Product.Owner<Payload(left),Payload(right)>
type Refusal is Data:
  InvalidPending{}
  InvalidBundle{}
type Spawned<-S:Data,-layout:Layout.Layout> is Type:
  Queued{handle:W.Handle<S>}
  Refused{bundle:Payload(layout),reason:W.WorldError}
type Entry<-S:Data,-layout:Layout.Layout> is Type:
  Spawn{handle:W.Handle<S>,bundle:Payload(layout)}
type Publication<-S:Data,-C:Type,-R:Type,-E:Data,-layout:Layout.Layout> is Type:
  Materialized{world:W.World<S,C,R,E>,handle:W.Handle<S>}
  RefusedPublication{world:W.World<S,C,R,E>,handle:W.Handle<S>,bundle:Payload(layout),reason:Refusal}

type Queue<-S:Data,-layout:Layout.Layout> is Type:
  Queue{entries:List<&1,Entry<S,layout>>}

# The reservation answer is produced by framework service. Successful staging
# retains the actual bundle before exposing its handle in the returned result.
def stage(~S:Data,~layout:Layout.Layout,queue:Queue<S,layout>,bundle:Payload(layout),answer:W.Reservation<S>) -> Task.Task<S,Queue<S,layout> & Spawned<S,layout>>:
  match queue answer:
    case Queue{entries} W.ReservationRejected{error}:Task.TDone{(Queue{entries},Refused{bundle,error})}
    case Queue{entries} W.Reserved{+handle}:Task.TDone{(Queue{Spawn{handle,bundle} <> entries},Queued{handle})}
def spawn(~S:Data,~layout:Layout.Layout,queue:Queue<S,layout>,bundle:Payload(layout)) -> Task.Task<S,Queue<S,layout> & Spawned<S,layout>>:
  Task.TNeed{answer => stage(~S,~layout,queue,bundle,answer)}
