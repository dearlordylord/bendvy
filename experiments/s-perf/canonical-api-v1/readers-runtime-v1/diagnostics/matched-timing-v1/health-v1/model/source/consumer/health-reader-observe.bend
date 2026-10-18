import Base
import health.bend as F
import types.bend as T
import health-events.bend as E
import health-family.bend as Family
import health-parameters.bend as P
import health-reader.bend as Reader
import health-logical.bend as Logical
import health-observe.bend as O
import ../../../../src/ecs/ordinary-reader-system.bend as Ordinary
import ../../../../src/ecs/ordinary-reader-stream-parameter.bend as SP
import ../../../../src/ecs/ordinary-reader-query-parameter.bend as QP
import ../../../../src/ecs/reader-parameter.bend as RP
import ../../../../src/ecs/event-runtime.bend as Ev
import ../../../../src/ecs/event-stream.bend as Leaf
import ../../../../src/ecs/event-family-routing.bend as Route
import ../../../../src/ecs/event-family-runtime.bend as FR
import ../../../../src/ecs/event-notice-runtime.bend as Mixed
import ../../../../src/ecs/ordinary-event-declaration.bend as Event
import ../../../../src/ecs/system.bend as Sys
import ../../../../src/ecs/internal/relation-failures/domains.bend as Domain
import ../../../../src/ecs/internal/relation-failures/queue.bend as Queue
import ../../../../src/ecs/inspector-query.bend as IQ
import ../../../../src/ecs/inspector-query-projection.bend as Projection

def position(value:Ev.Position) -> String:
  match value:
    case Ev.Position{id,cursor,registered}:"id=" ++ U32.show(id) ++ ";cursor=" ++ Nat.show(cursor) ++ ";registered=" ++ Nat.show(registered)
def batch(value:Ev.Batch<E.event_type()>) -> String:
  match value:
    case Ev.Batch{tick,values}:"tick=" ++ Nat.show(tick) ++ ";values=" ++ List.show(&2,E.event_type(),O.event,values)
def pub_batch(value:Ev.Batch<E.Publication>) -> String:
  match value:
    case Ev.Batch{tick,values}:"tick=" ++ Nat.show(tick) ++ ";values=" ++ List.show(&2,E.Publication,O.publication,values)
def stream(value:Leaf.Stream<T.HealthSchema,E.event_type()>) -> String:
  match value:
    case Leaf.Stream{Event.Domain{domain},batches,positions,nextReader,frameStart,boundary,capacity,dropped}:"domain=" ++ domain ++ ";batches=" ++ List.show(&2,Ev.Batch<E.event_type()>,batch,batches) ++ ";positions=" ++ List.show(&2,Ev.Position,position,positions) ++ ";nextReader=" ++ U32.show(nextReader) ++ ";frameStart=" ++ Nat.show(frameStart) ++ ";boundary=" ++ Nat.show(boundary) ++ ";capacity=" ++ Nat.show(capacity) ++ ";dropped=" ++ Nat.show(dropped)
def family(value:Family.Family) -> String:
  match value:
    case Family.Family{a,b,c}:"ping={" ++ stream(a) ++ "};removed={" ++ stream(b) ++ "};despawned={" ++ stream(c) ++ "}"
def queue_batch(value:Queue.Batch<E.event_type()>) -> String:
  match value:
    case Queue.Batch{tick,count,values}:"tick=" ++ Nat.show(tick) ++ ";cachedCount=" ++ Nat.show(count) ++ ";values=" ++ List.show(&2,E.event_type(),O.event,values)
def queue(value:Queue.Queue<E.event_type()>) -> String:
  match value:
    case Queue.Queue{front,back,size,dropped}:"front=" ++ List.show(&2,Queue.Batch<E.event_type()>,queue_batch,front) ++ ";back=" ++ List.show(&2,Queue.Batch<E.event_type()>,queue_batch,back) ++ ";size=" ++ Nat.show(size) ++ ";dropped=" ++ Nat.show(dropped)
def domain(value:Domain.Domain<T.HealthSchema,E.event_type()>) -> String:
  match value:
    case Domain.Domain{Domain.DeclaredKey{id},stored,readers}:"id=" ++ U32.show(id) ++ ";queue={" ++ queue(stored) ++ "};readers=" ++ List.show(&2,U32,U32.show,readers)
def failures(value:Mixed.Failures<T.HealthSchema,E.Publication>) -> String:
  match value:
    case Mixed.Failures{domains,positions,tick,frameStart,boundary,capacity,nextReader}:"domains=" ++ List.show(&2,Domain.Domain<T.HealthSchema,E.event_type()>,domain,domains) ++ ";positions=" ++ List.show(&2,Ev.Position,position,positions) ++ ";tick=" ++ Nat.show(tick) ++ ";frameStart=" ++ Nat.show(frameStart) ++ ";boundary=" ++ Nat.show(boundary) ++ ";capacity=" ++ Nat.show(capacity) ++ ";nextReader=" ++ U32.show(nextReader)
def meta(value:Mixed.State<T.HealthSchema,E.Publication,Family.Family,Unit>) -> Mixed.State<T.HealthSchema,E.Publication,Family.Family,Unit> & String:
  match value:
    case Mixed.State{FR.State{+f,unit,+journal,+frameStart},+failed}:(Mixed.State{FR.State{f,unit,journal,frameStart},failed},"typed={family={" ++ family(f) ++ "};owner=Unit;journal=" ++ List.show(&2,Ev.Batch<E.Publication>,pub_batch,journal) ++ ";frameStart=" ++ Nat.show(frameStart) ++ "};failures={" ++ failures(failed) ++ "}")
def context_join(+tick:Nat,observedWorld:F.World() & String,observedMeta:Mixed.State<T.HealthSchema,E.Publication,Family.Family,Unit> & String) -> Family.Context() & String:
  (world,sw)=observedWorld
  (meta,sm)=observedMeta
  (Route.Runtime{world,meta,tick},"tick=" ++ Nat.show(tick) ++ ";world={" ++ sw ++ "};meta={" ++ sm ++ "}")
def context(value:Family.Context()) -> Family.Context() & String:
  match value:
    case Route.Runtime{world,stored,tick}:context_join(tick,O.world(world),meta(stored))
def facts(value:RP.RegistrationFacts) -> String:
  match value:
    case RP.RegistrationFacts{ns,id,name,access}:"ns=" ++ U32.show(ns) ++ ";id=" ++ U32.show(id) ++ ";name=" ++ name ++ ";access=" ++ List.show(&2,String,x=>x,access)
def ping_owner(value:P.ping_owner()) -> P.ping_owner() & String:
  match value:
    case SP.EventOwner{+registration,Route.Reader{+namespace,+id,+registryId}}:(SP.EventOwner{registration,Route.Reader{namespace,id,registryId}},"facts={" ++ facts(registration) ++ "};reader={namespace=" ++ U32.show(namespace) ++ ";id=" ++ U32.show(id) ++ ";registryId=" ++ U32.show(registryId) ++ "}")
def removed_owner(value:P.removed_owner()) -> P.removed_owner() & String:
  match value:
    case SP.EventOwner{+registration,Route.Reader{+namespace,+id,+registryId}}:(SP.EventOwner{registration,Route.Reader{namespace,id,registryId}},"facts={" ++ facts(registration) ++ "};reader={namespace=" ++ U32.show(namespace) ++ ";id=" ++ U32.show(id) ++ ";registryId=" ++ U32.show(registryId) ++ "}")
def despawned_owner(value:P.despawned_owner()) -> P.despawned_owner() & String:
  match value:
    case SP.EventOwner{+registration,Route.Reader{+namespace,+id,+registryId}}:(SP.EventOwner{registration,Route.Reader{namespace,id,registryId}},"facts={" ++ facts(registration) ++ "};reader={namespace=" ++ U32.show(namespace) ++ ";id=" ++ U32.show(id) ++ ";registryId=" ++ U32.show(registryId) ++ "}")
def owners_join(a:P.ping_owner() & String,b:P.removed_owner() & String,c:P.despawned_owner() & String) -> P.all_owner() & String:
  (a,sa)=a
  (b,sb)=b
  (c,sc)=c
  ((Unit{},(Unit{},(Unit{},(a,(b,c))))),"queryOwners=(Unit,Unit,Unit);ping={" ++ sa ++ "};removed={" ++ sb ++ "};despawned={" ++ sc ++ "}")
def owners(value:P.all_owner()) -> P.all_owner() & String:
  match value:
    case (Unit{},(Unit{},(Unit{},(a,(b,c))))):owners_join(ping_owner(a),removed_owner(b),despawned_owner(c))
def provider_registry(owner:P.all_owner(),text:String,+access:List<&2,String>,unit:Unit,registry:Reader.Registry()) -> Reader.Provider() & String:
  match registry:
    case Sys.Registry{+ns,+id,+name,+uses,+cursor}:(Ordinary.Provider{Sys.Registry{ns,id,name,uses,cursor},owner,RP.Param{access},unit},"registry={ns=" ++ U32.show(ns) ++ ";id=" ++ U32.show(id) ++ ";name=" ++ name ++ ";access=" ++ List.show(&2,String,x=>x,uses) ++ ";cursor=" ++ U32.show(cursor) ++ "};parameter=" ++ List.show(&2,String,x=>x,access) ++ ";declaration=Unit;owners={" ++ text ++ "}")
def provider_join(registry:Reader.Registry(),+access:List<&2,String>,unit:Unit,observed:P.all_owner() & String) -> Reader.Provider() & String:
  (owner,text)=observed
  provider_registry(owner,text,access,unit,registry)
def provider(value:Reader.Provider()) -> Reader.Provider() & String:
  match value:
    case Ordinary.Provider{registry,owner,RP.Param{access},unit}:provider_join(registry,access,unit,owners(owner))
def added_row(value:IQ.ProjectedRow<T.HealthSchema,Projection.Product<Unit,Logical.Value()>>) -> String:
  match value:
    case IQ.ProjectedRow{handle,Projection.Product{Unit{},view}}:O.row(IQ.ProjectedRow{handle,view})
def event_view(value:SP.EventView<T.HealthSchema,E.event_type()>) -> String:
  match value:
    case SP.EventView{Ev.Reading{values,lagged}}:"values=" ++ List.show(&2,E.event_type(),O.event,values) ++ ";lagged=" ++ Bool.show(lagged)
def raw_view(value:P.all_raw_view()) -> String:
  match value:
    case RP.ViewPair{QP.Rows{rows},RP.ViewPair{QP.Rows{added},RP.ViewPair{QP.Rows{changed},RP.ViewPair{ping,RP.ViewPair{removed,despawned}}}}}:"rows=" ++ List.show(&2,IQ.ProjectedRow<T.HealthSchema,Logical.Value()>,O.row,rows) ++ ";added=" ++ List.show(&2,IQ.ProjectedRow<T.HealthSchema,Projection.Product<Unit,Logical.Value()>>,added_row,added) ++ ";changed=" ++ List.show(&2,IQ.ProjectedRow<T.HealthSchema,Projection.Product<Unit,Logical.Value()>>,added_row,changed) ++ ";ping={" ++ event_view(ping) ++ "};removed={" ++ event_view(removed) ++ "};despawned={" ++ event_view(despawned) ++ "}"
def view(value:P.all_view()) -> String:
  match value:
    case P.PreparedView{raw,cursor,ping,removed,despawned,running}:"queryCursor=" ++ U32.show(cursor) ++ ";readThroughPing=" ++ Nat.show(ping) ++ ";readThroughRemoved=" ++ Nat.show(removed) ++ ";readThroughDespawned=" ++ Nat.show(despawned) ++ ";runningContext={" ++ running ++ "};" ++ raw_view(raw)
def read(value:Reader.Read) -> String:
  match value:
    case Reader.Read{Reader.Args{who,phase,iteration},values}:"who=" ++ U32.show(who) ++ ";phase=" ++ U32.show(phase) ++ ";iteration=" ++ U32.show(iteration) ++ ";" ++ view(values)
