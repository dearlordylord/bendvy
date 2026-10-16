import Base
import ./host.bend as H
import ./fixture.bend as F
import ./schema.bend as Schema
import ./catalog.bend as Catalog
import ../ordinary-v1/payload.bend as P
import ../ordinary-v1/observe.bend as R
import ../families-v1/fixture.bend as Pub
import ../families-v1/observe.bend as V
import ../../../src/ecs/event-runtime.bend as Ev
import ../../../src/ecs/event-stream.bend as Stream
import ../../../src/ecs/event-family-runtime.bend as FR
import ../../../src/ecs/event-family-routing.bend as Route
import ../../../src/ecs/ordinary-event-declaration.bend as Event
import ../../../src/ecs/owner-product.bend as Product
import ../../../src/ecs/owned-event-log.bend as Log
import ../../../src/ecs/system.bend as Sys

def stream(~S:Data,value:Stream.Stream<S,Nat>) -> String:
  match value:
    case Stream.Stream{Event.Domain{key},+batches,+positions,next,start,boundary,capacity,+dropped}:"stream(domain=" ++ key ++ ",batches=" ++ List.show(~&2,~Ev.Batch<Nat>,~R.batch,batches) ++ ",positions=" ++ List.show(~&2,~Ev.Position,~R.position,positions) ++ ",statuses=" ++ List.show(~&2,~Ev.ReaderStatus,~R.reader_status,Ev.reader_statuses(~Nat,positions,batches,dropped)) ++ ",next=" ++ U32.show(next) ++ ",frameStart=" ++ Nat.show(start) ++ ",boundary=" ++ Nat.show(boundary) ++ ",capacity=" ++ Nat.show(capacity) ++ ",dropped=" ++ Nat.show(dropped) ++ ")"
def streams(~S:Data,value:Schema.Streams(~S)) -> Schema.Streams(~S) & String:
  match value:
    case Product.Owner{+a,Product.Owner{+b,+c}}:(Product.Owner{a,Product.Owner{b,c}},"Cargo=" ++ stream(~S,a) ++ ",Alerts=" ++ stream(~S,b) ++ ",Crates=" ++ stream(~S,c))
def journal_batch(value:Ev.Batch<Schema.E()>) -> String:
  match value:
    case Ev.Batch{tick,values}:"(" ++ Nat.show(tick) ++ "," ++ List.show(~&2,~Schema.E(),~V.publication,values) ++ ")"
def state_join(~S:Data,+journal:List<&2,Ev.Batch<Schema.E()>>,+start:Nat,value:Schema.Streams(~S) & String) -> F.State(~S) & String:
  (value,text) = value
  (FR.State{value,Unit{},journal,start},"state(" ++ text ++ ",owners=Unit,journal=" ++ List.show(~&2,~Ev.Batch<Schema.E()>,~journal_batch,journal) ++ ",journalSize=" ++ Nat.show(Ev.size(~Schema.E(),journal)) ++ ",frameStart=" ++ Nat.show(start) ++ ")")
def state(~S:Data,value:F.State(~S)) -> F.State(~S) & String:
  match value:
    case FR.State{family,Unit{},journal,start}:state_join(~S,journal,start,streams(~S,family))
def runtime_join(~S:Data,+tick:Nat,a:F.World(~S) & String,b:F.State(~S) & String) -> F.Runtime(~S) & String:
  match a b:
    case (world,w),(state,f):(Route.Runtime{world,state,tick},"runtime(tick=" ++ Nat.show(tick) ++ "," ++ w ++ "," ++ f ++ ")")
def runtime(~S:Data,value:F.Runtime(~S)) -> F.Runtime(~S) & String:
  match value:
    case Route.Runtime{world,family,tick}:runtime_join(~S,tick,V.world(~S,world),state(~S,family))
def reader_a(~S:Data,value:F.Reader_a(~S)) -> F.Reader_a(~S) & String:
  match value:
    case Route.Reader{+ns,+id,+reg}:(Route.Reader{ns,id,reg},"(" ++ U32.show(ns) ++ "," ++ U32.show(id) ++ "," ++ U32.show(reg) ++ ")")
def reader_b(~S:Data,value:F.Reader_b(~S)) -> F.Reader_b(~S) & String:
  match value:
    case Route.Reader{+ns,+id,+reg}:(Route.Reader{ns,id,reg},"(" ++ U32.show(ns) ++ "," ++ U32.show(id) ++ "," ++ U32.show(reg) ++ ")")
def reader_c(~S:Data,value:F.Reader_c(~S)) -> F.Reader_c(~S) & String:
  match value:
    case Route.Reader{+ns,+id,+reg}:(Route.Reader{ns,id,reg},"(" ++ U32.show(ns) ++ "," ++ U32.show(id) ++ "," ++ U32.show(reg) ++ ")")
def registry_a(~S:Data,value:F.Registry_a(~S)) -> F.Registry_a(~S) & String:
  match value:
    case Sys.Registry{+ns,+id,+name,+access,+cursor}:(Sys.Registry{ns,id,name,access,cursor},"(" ++ U32.show(ns) ++ "," ++ U32.show(id) ++ "," ++ name ++ "," ++ List.show(~&2,~String,~R.text,access) ++ ",cursor=" ++ U32.show(cursor) ++ ")")
def registry_b(~S:Data,value:F.Registry_b(~S)) -> F.Registry_b(~S) & String:
  match value:
    case Sys.Registry{+ns,+id,+name,+access,+cursor}:(Sys.Registry{ns,id,name,access,cursor},"(" ++ U32.show(ns) ++ "," ++ U32.show(id) ++ "," ++ name ++ "," ++ List.show(~&2,~String,~R.text,access) ++ ",cursor=" ++ U32.show(cursor) ++ ")")
def registry_c(~S:Data,value:F.Registry_c(~S)) -> F.Registry_c(~S) & String:
  match value:
    case Sys.Registry{+ns,+id,+name,+access,+cursor}:(Sys.Registry{ns,id,name,access,cursor},"(" ++ U32.show(ns) ++ "," ++ U32.show(id) ++ "," ++ name ++ "," ++ List.show(~&2,~String,~R.text,access) ++ ",cursor=" ++ U32.show(cursor) ++ ")")
def args(value:P.Args) -> P.Args & String:R.args(value)
def snapshot_join(~S:Data,label:String,a:F.Runtime(~S) & String,b:F.Runtime(~S) & String,c:Pub.PublisherRegistry(~S) & String,d:F.Reader_a(~S) & String,e:F.Registry_a(~S) & String,f:F.Reader_a(~S) & String,g:F.Registry_a(~S) & String,h:F.Reader_b(~S) & String,i:F.Registry_b(~S) & String,j:F.Reader_c(~S) & String,k:F.Registry_c(~S) & String,l:P.Args & String) -> H.Host<S> & String:
  match a b c d e f g h i j k l:
    case (a,at),(b,bt),(c,ct),(d,dt),(e,et),(f,ft),(g,gt),(h,ht),(i,it),(j,jt),(k,kt),(l,lt):(H.Host{a,b,c,d,e,f,g,h,i,j,k,l},label ++ "|" ++ at ++ "|foreign=" ++ bt ++ "|publisher=" ++ ct ++ "|fast=" ++ dt ++ ":" ++ et ++ "|slow=" ++ ft ++ ":" ++ gt ++ "|alerts=" ++ ht ++ ":" ++ it ++ "|crates=" ++ jt ++ ":" ++ kt ++ "|args=" ++ lt)
def snapshot(~S:Data,label:String,value:H.Host<S>) -> H.Host<S> & String:
  match value:
    case H.Host{a,b,c,d,e,f,g,h,i,j,k,l}:snapshot_join(~S,label,runtime(~S,a),runtime(~S,b),V.publisher_registry(~S,c),reader_a(~S,d),registry_a(~S,e),reader_a(~S,f),registry_a(~S,g),reader_b(~S,h),registry_b(~S,i),reader_c(~S,j),registry_c(~S,k),args(l))
def retired_seen(a:List<Log.Row<Array<U32>>> & String,b:List<Log.Row<Array<U32>>> & String,c:List<Log.Row<Array<Array<U32>>>> & String) -> String:
  match a b c:
    case (_,x),(_,y),(_,z):"retired(Cargo=" ++ x ++ ",Alerts=" ++ y ++ ",Crates=" ++ z ++ ")"
def retired(value:Catalog.Receipt()) -> String:
  match value:
    case Product.Owner{a,Product.Owner{b,c}}:retired_seen(V.items(~Log.Row<Array<U32>>,~V.row(~Array<U32>,~R.payload),a),V.items(~Log.Row<Array<U32>>,~V.row(~Array<U32>,~R.payload),b),V.items(~Log.Row<Array<Array<U32>>>,~V.row(~Array<Array<U32>>,~V.matrix),c))
