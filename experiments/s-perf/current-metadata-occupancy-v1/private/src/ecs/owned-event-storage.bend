import Base
import ./world.bend as W
import ./world-resource-owner.bend as Resource
import ./event-runtime.bend as Ev
import ./capabilities.bend as Cap
import ./owned-event-log.bend as Log

# Trusted schema storage: user resources and each affine payload log have one owner.
# Data IDs use the existing event runtime; its cursor/lag/retention policy is unchanged.
type Resources<R:Type,P:Type> is Type:
  Resources{resource:R,log:Log.Log<P>}
def World(~S:Data,~C:Type,~R:Type,~P:Type) -> Type:W.World<S,C,Resources<R,P>,Nat>
def Runtime(~S:Data,~C:Type,~R:Type,~P:Type) -> Type:Ev.Runtime<S,C,Resources<R,P>,Nat>

# Canonical World resource splitting preserves every non-resource field.
def resources_returned(~S:Data,~C:Type,~R:Type,~P:Type,~Out:Type,rest:Resource.Rest<S,C,Resources<R,P>,Nat>,returned:Resources<R,P> & Out) -> World(~S,~C,~R,~P) & Out:
  match returned:
    case (resources,output):(Resource.put(~S,~C,~Resources<R,P>,~Nat,rest,resources),output)
def resources_taken(~S:Data,~C:Type,~R:Type,~P:Type,~Out:Type,effect:Resources<R,P> -> Resources<R,P> & Out,taken:Resource.Rest<S,C,Resources<R,P>,Nat> & Resources<R,P>) -> World(~S,~C,~R,~P) & Out:
  match taken:
    case (rest,resources):resources_returned(~S,~C,~R,~P,~Out,rest,effect(resources))
def with_resources(~S:Data,~C:Type,~R:Type,~P:Type,~Out:Type,effect:Resources<R,P> -> Resources<R,P> & Out,world:World(~S,~C,~R,~P)) -> World(~S,~C,~R,~P) & Out:
  resources_taken(~S,~C,~R,~P,~Out,effect,Resource.take(~S,~C,~Resources<R,P>,~Nat,world))

def appended(~R:Type,~P:Type,resource:R,result:Log.Log<P> & List<&2,Nat>) -> Resources<R,P> & List<&2,Nat>:
  match result:
    case (log,ids):(Resources{resource,log},ids)
def append_resources(~R:Type,~P:Type,values:List<P>,resources:Resources<R,P>) -> Resources<R,P> & List<&2,Nat>:
  match resources:
    case Resources{resource,log}:appended(~R,~P,resource,Log.append_many(~P,log,values))
def publish_ids(~S:Data,~C:Type,~R:Type,~P:Type,result:World(~S,~C,~R,~P) & List<&2,Nat>) -> World(~S,~C,~R,~P):
  match result:
    case (world,ids):W.event_publish(~S,~C,~Resources<R,P>,~Nat,world,ids)
# Called only after successful canonical transaction finish: owners and IDs publish
# in the same FIFO order. Failure/abort transport remains the ordinary adapter's job.
def commit_owned(~S:Data,~C:Type,~R:Type,~P:Type,world:World(~S,~C,~R,~P),values:List<P>) -> World(~S,~C,~R,~P):
  publish_ids(~S,~C,~R,~P,with_resources(~S,~C,~R,~P,~List<&2,Nat>,resources => append_resources(~R,~P,values,resources),world))

def retained(~R:Type,~P:Type,resource:R,result:Log.Log<P> & List<Log.Row<P>>) -> Resources<R,P> & List<Log.Row<P>>:
  match result:
    case (log,retired):(Resources{resource,log},retired)
def retain_resources(~R:Type,~P:Type,ids:List<&2,Nat>,resources:Resources<R,P>) -> Resources<R,P> & List<Log.Row<P>>:
  match resources:
    case Resources{resource,log}:retained(~R,~P,resource,Log.retain(~P,log,ids))
def drain_resources(~R:Type,~P:Type,resources:Resources<R,P>) -> Resources<R,P> & List<Log.Row<P>>:
  match resources:
    case Resources{resource,log}:retained(~R,~P,resource,Log.drain(~P,log))
def runtime_returned(~S:Data,~C:Type,~R:Type,~P:Type,~Out:Type,namespace:U32,batches:List<&2,Ev.Batch<Nat>>,positions:List<&2,Ev.Position>,nextReader:U32,tick:Nat,frameStart:Nat,boundary:Nat,capacity:Nat,dropped:Nat,result:World(~S,~C,~R,~P) & Out) -> Runtime(~S,~C,~R,~P) & Out:
  match result:
    case (world,output):(Ev.Runtime{world,namespace,batches,positions,nextReader,tick,frameStart,boundary,capacity,dropped},output)
def framed(~S:Data,~C:Type,~R:Type,~P:Type,runtime:Runtime(~S,~C,~R,~P)) -> Runtime(~S,~C,~R,~P) & List<Log.Row<P>>:
  match runtime:
    case Ev.Runtime{world,namespace,+batches,positions,nextReader,tick,frameStart,boundary,capacity,dropped}:
      runtime_returned(~S,~C,~R,~P,~List<Log.Row<P>>,namespace,batches,positions,nextReader,tick,frameStart,boundary,capacity,dropped,with_resources(~S,~C,~R,~P,~List<Log.Row<P>>,resources => retain_resources(~R,~P,Ev.values(~Nat,batches),resources),world))
# Existing Ev.frame chooses surviving complete batches. Return every other payload
# owner once; the caller chooses reuse or release, with no automatic IO finalizer.
def frame(~S:Data,~C:Type,~R:Type,~P:Type,runtime:Runtime(~S,~C,~R,~P)) -> Runtime(~S,~C,~R,~P) & List<Log.Row<P>>:
  framed(~S,~C,~R,~P,Ev.frame(~S,~C,~Resources<R,P>,~Nat,runtime))
def cleared_events(~S:Data,~C:Type,~R:Type,~P:Type,result:World(~S,~C,~R,~P) & List<Log.Row<P>>) -> World(~S,~C,~R,~P) & List<Log.Row<P>>:
  match result:
    case (world,rows):(W.events_replace(~S,~C,~Resources<R,P>,~Nat,world,[]),rows)
# Shutdown clears only queued IDs/batches and log rows. Preserve reader/runtime
# metadata and Log.next so old IDs cannot alias a later appended payload.
def drain(~S:Data,~C:Type,~R:Type,~P:Type,runtime:Runtime(~S,~C,~R,~P)) -> Runtime(~S,~C,~R,~P) & List<Log.Row<P>>:
  match runtime:
    case Ev.Runtime{world,namespace,_,positions,nextReader,tick,frameStart,boundary,capacity,dropped}:
      runtime_returned(~S,~C,~R,~P,~List<Log.Row<P>>,namespace,[],positions,nextReader,tick,frameStart,boundary,capacity,dropped,cleared_events(~S,~C,~R,~P,with_resources(~S,~C,~R,~P,~List<Log.Row<P>>,drain_resources(~R,~P),world)))

def read_returned(~R:Type,~P:Type,~Args:Type,~Observation:Type,resource:R,result:Log.Log<P> & Log.ReadResult<Args,Observation>) -> Resources<R,P> & Log.ReadResult<Args,Observation>:
  match result:
    case (log,reading):(Resources{resource,log},reading)
def read_resources(~R:Type,~P:Type,~Request:Type,~Projection:Data,~Args:Type,~Observation:Type,~at:P -> Request -> P & Projection,~body:@-H:Type -> @-read:Cap.Request<H,Request,Projection> -> H -> Args -> H & Observation,resources:Resources<R,P>,id:Nat,args:Args) -> Resources<R,P> & Log.ReadResult<Args,Observation>:
  match resources:
    case Resources{resource,log}:read_returned(~R,~P,~Args,~Observation,resource,Log.read(~P,~Request,~Projection,~Args,~Observation,~at,~body,log,id,args))
# The projection is trusted schema provisioning. The closed body receives only an
# abstract payload handle and declared scoped read request; it never gets World.
def read(~S:Data,~C:Type,~R:Type,~P:Type,~Request:Type,~Projection:Data,~Args:Type,~Observation:Type,~at:P -> Request -> P & Projection,~body:@-H:Type -> @-read:Cap.Request<H,Request,Projection> -> H -> Args -> H & Observation,world:World(~S,~C,~R,~P),id:Nat,args:Args) -> World(~S,~C,~R,~P) & Log.ReadResult<Args,Observation>:
  with_resources(~S,~C,~R,~P,~Log.ReadResult<Args,Observation>,resources => read_resources(~R,~P,~Request,~Projection,~Args,~Observation,~at,~body,resources,id,args),world)
