import Base
import world.bend as W
import world-resource-owner.bend as Resource
import owner-product.bend as Product
import capabilities.bend as Cap
import owned-event-log.bend as Log

# Trusted engine helpers. Ordinary product declarations bind the canonical log
# path and matching key route; gameplay receives only its abstract capability.
# R is the entire heterogeneous resource tree, E the existing Data publication
# tree. No Type payload or unrelated resource owner is copied or reconstructed.
def log_returned(~S:Data,~C:Type,~R:Type,~P:Type,~Rest:Type,~E:Data,~path:Product.Lens<R,Log.Log<P>,Rest>,~Out:Type,worldRest:Resource.Rest<S,C,R,E>,resourceRest:Rest,result:Log.Log<P> & Out) -> W.World<S,C,R,E> & Out:
  match result:
    case (log,output):(Resource.put(~S,~C,~R,~E,worldRest,Product.put_field(~R,~Log.Log<P>,~Rest,path)(resourceRest,log)),output)
def log_taken(~S:Data,~C:Type,~R:Type,~P:Type,~Rest:Type,~E:Data,~path:Product.Lens<R,Log.Log<P>,Rest>,~Out:Type,effect:Log.Log<P> -> Log.Log<P> & Out,worldRest:Resource.Rest<S,C,R,E>,result:Rest & Log.Log<P>) -> W.World<S,C,R,E> & Out:
  match result:
    case (resourceRest,log):log_returned(~S,~C,~R,~P,~Rest,~E,~path,~Out,worldRest,resourceRest,effect(log))
def resource_taken(~S:Data,~C:Type,~R:Type,~P:Type,~Rest:Type,~E:Data,~path:Product.Lens<R,Log.Log<P>,Rest>,~Out:Type,effect:Log.Log<P> -> Log.Log<P> & Out,result:Resource.Rest<S,C,R,E> & R) -> W.World<S,C,R,E> & Out:
  match result:
    case (worldRest,resource):log_taken(~S,~C,~R,~P,~Rest,~E,~path,~Out,effect,worldRest,Product.get_field(~R,~Log.Log<P>,~Rest,path)(resource))
def with_log(~S:Data,~C:Type,~R:Type,~P:Type,~Rest:Type,~E:Data,~path:Product.Lens<R,Log.Log<P>,Rest>,~Out:Type,effect:Log.Log<P> -> Log.Log<P> & Out,world:W.World<S,C,R,E>) -> W.World<S,C,R,E> & Out:
  resource_taken(~S,~C,~R,~P,~Rest,~E,~path,~Out,effect,Resource.take(~S,~C,~R,~E,world))

def injected(~E:Data,~inject:Nat -> E,ids:List<&2,Nat>) -> List<&2,E>:
  match ids:
    case []:[]
    case id <> rest:inject(id) <> injected(~E,~inject,rest)
def published(~S:Data,~C:Type,~R:Type,~E:Data,~inject:Nat -> E,result:W.World<S,C,R,E> & List<&2,Nat>) -> W.World<S,C,R,E>:
  match result:
    case (world,ids):W.event_publish(~S,~C,~R,~E,world,injected(~E,~inject,ids))
# The transaction adapter calls this after successful canonical ECS finish. One
# caller batch retains its FIFO; cross-family action order belongs to that adapter,
# using the existing publication journal, not a regrouping by payload type/family.
def commit_owned(~S:Data,~C:Type,~R:Type,~P:Type,~Rest:Type,~E:Data,~path:Product.Lens<R,Log.Log<P>,Rest>,~inject:Nat -> E,world:W.World<S,C,R,E>,values:List<P>) -> W.World<S,C,R,E>:
  published(~S,~C,~R,~E,~inject,with_log(~S,~C,~R,~P,~Rest,~E,~path,~List<&2,Nat>,log => Log.append_many(~P,log,values),world))
# The runtime chooses surviving records using its unchanged per-family retention
# policy, then calls each family's selected path with those records.
def retain(~S:Data,~C:Type,~R:Type,~P:Type,~Rest:Type,~E:Data,~path:Product.Lens<R,Log.Log<P>,Rest>,~select:List<&2,E> -> List<&2,Nat>,world:W.World<S,C,R,E>,records:List<&2,E>) -> W.World<S,C,R,E> & List<Log.Row<P>>:
  with_log(~S,~C,~R,~P,~Rest,~E,~path,~List<Log.Row<P>>,log => Log.retain(~P,log,select(records)),world)
# Drain only this log, preserving its next ID and every publication. The outer
# shutdown drains ALL family logs and clears their publication tree atomically
# before any reader runs. Clearing shared records here would lose sibling events.
def drain(~S:Data,~C:Type,~R:Type,~P:Type,~Rest:Type,~E:Data,~path:Product.Lens<R,Log.Log<P>,Rest>,world:W.World<S,C,R,E>) -> W.World<S,C,R,E> & List<Log.Row<P>>:
  with_log(~S,~C,~R,~P,~Rest,~E,~path,~List<Log.Row<P>>,Log.drain(~P),world)
# Read only the log at the declaration's path. IDs are local to that family; the
# ordinary adapter first projects the reader's IDs through the matching key route.
# Trusted at preserves its owner; the abstract body cannot extract that owner.
def read(~S:Data,~C:Type,~R:Type,~P:Type,~Rest:Type,~E:Data,~path:Product.Lens<R,Log.Log<P>,Rest>,~Request:Type,~Projection:Data,~Args:Type,~Observation:Type,~at:P -> Request -> P & Projection,~body:@-H:Type -> @-read:Cap.Request<H,Request,Projection> -> H -> Args -> H & Observation,world:W.World<S,C,R,E>,id:Nat,args:Args) -> W.World<S,C,R,E> & Log.ReadResult<Args,Observation>:
  with_log(~S,~C,~R,~P,~Rest,~E,~path,~Log.ReadResult<Args,Observation>,log => Log.read(~P,~Request,~Projection,~Args,~Observation,~at,~body,log,id,args),world)
