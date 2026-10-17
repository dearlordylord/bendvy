import ../../../src/ecs/deferred-command.bend as Deferred
import Base
import ../../../src/ecs/system.bend as Sys
import ../../../src/ecs/event-runtime.bend as Ev
import ../../../src/ecs/event-stream.bend as Stream
import ../../../src/ecs/ordinary-event-declaration.bend as Event
import ../../../src/ecs/event-family-runtime.bend as FR
import ../../../src/ecs/event-family-routing.bend as Route
import locals.bend as Locals
import ../../../src/ecs/ordinary-app-local-fields.bend as OrdinaryLocal
import ../../../src/ecs/local.bend as Local
import factory.bend as Factory
import schema.bend as Schema
import ../../../src/ecs/decode-data.bend as D
import ../../../src/ecs/entity-key.bend as Key
import ../../../src/ecs/entity-allocator.bend as Alloc
import ../../../src/ecs/column.bend as Col
import ../../../src/ecs/indexed-lifecycle.bend as M
import ../../../src/ecs/lifecycle.bend as L
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/owner-product.bend as Product
import ../../../src/ecs/owned-event-log.bend as Log
import ../../../src/ecs/restore-data.bend as R
import ../../../src/ecs/restore-leaf.bend as Stage
import ../../../src/ecs/restore-public.bend as Public
import ../../../src/ecs/restore-schema.bend as RestoreSchema
import ../../../src/ecs/ordinary-schema.bend as Ordinary
import ../../../src/ecs/schema-fragments.bend as Fragment
import ../../../src/ecs/snapshot-leaf.bend as Leaf
import ../../../src/ecs/persistence-declaration.bend as Persist
import ../../../src/ecs/snapshot-data.bend as SnapshotData
import ../../../src/ecs/event-publication.bend as Publication

def leaf(~T:Type,observed:T & String) -> Array<T> & String:
  (value,text)=observed
  (ALeaf{value},"leaf:" ++ text)
def node_join(~T:Type,leftObserved:Array<T> & String,rightObserved:Array<T> & String) -> Array<T> & String:
  (left,text)=leftObserved
  (right,other)=rightObserved
  (ANode{left,right},"node(" ++ text ++ "," ++ other ++ ")")
def array(~T:Type,~project:T -> T & String,value:Array<T>) -> Array<T> & String:
  match value:
    case ALeaf{value}:leaf(~T,project(value))
    case ANode{left,right}:node_join(~T,array(~T,~project,left),array(~T,~project,right))
def u32_data(+value:U32) -> U32 & String:
  (value,U32.show(value))
def u32_value(value:U32) -> U32 & String:
  u32_data(value)
def u32_array(value:Array<U32>) -> Array<U32> & String:
  array(~U32,~u32_value,value)
def bool_data(+value:Bool) -> Bool & String:
  (value,Bool.show(value))
def bool_value(value:Bool) -> Bool & String:
  bool_data(value)
def bool_array(value:Array<Bool>) -> Array<Bool> & String:
  array(~Bool,~bool_value,value)
def optional_done(~Payload:Type,observed:Payload & String) -> Maybe<&1,Payload> & String:
  (owner,text)=observed
  (Some{owner},"some(" ++ text ++ ")")
def optional(~Payload:Type,~project:Payload -> Payload & String,value:Maybe<&1,Payload>) -> Maybe<&1,Payload> & String:
  match value:
    case None{}:(None{},"none")
    case Some{owner}:optional_done(~Payload,project(owner))
def stamp(value:L.Stamp) -> String:
  match value:
    case L.Stamp{added,changed}:U32.show(added) ++ ":" ++ U32.show(changed)
def entry(value:L.Entry) -> String:
  match value:
    case L.Entry{id,value}:U32.show(id) ++ ":" ++ stamp(value)
def metadata_join(+capacity:U32,+depth:Nat,+exceptional:List<&2,L.Entry>,observedAdded:Array<U32> & String,observedChanged:Array<U32> & String) -> M.Metadata & String:
  (added,sa)=observedAdded
  (changed,sc)=observedChanged
  (M.Metadata{added,changed,capacity,depth,exceptional},"added=" ++ sa ++ ";changed=" ++ sc ++ ";capacity=" ++ U32.show(capacity) ++ ";depth=" ++ Nat.show(depth) ++ ";exceptional=" ++ List.show(&2,L.Entry,entry,exceptional))
def metadata(value:M.Metadata) -> M.Metadata & String:
  match value:
    case M.Metadata{added,changed,capacity,depth,exceptional}:metadata_join(capacity,depth,exceptional,u32_array(added),u32_array(changed))
def indexed_join(~S:Data,~P:Type,observedValues:Array<Maybe<&1,P>> & String,observedMeta:M.Metadata & String) -> Col.IndexedOrdinaryCarrier<S,P> & String:
  (values,sv)=observedValues
  (metadata,sm)=observedMeta
  (Col.IndexedOrdinaryOwned{Col.IndexedOrdinaryState{values,metadata}},"owned(values=" ++ sv ++ ";metadata={" ++ sm ++ "})")
def indexed_wrap(~S:Data,~P:Type,observed:Col.IndexedOrdinaryCarrier<S,P> & String) -> Col.IndexedOrdinaryCarrier<S,P> & String:
  (inner,text)=observed
  (Col.IndexedOrdinaryWrapped{inner},"wrapped(" ++ text ++ ")")
def indexed_state(~S:Data,~P:Type,~project:P -> P & String,value:Col.IndexedOrdinaryState<S,P>) -> Col.IndexedOrdinaryCarrier<S,P> & String:
  match value:
    case Col.IndexedOrdinaryState{values,meta}:indexed_join(~S,~P,array(~Maybe<&1,P>,~optional(~P,~project),values),metadata(meta))
def indexed(~S:Data,~P:Type,~project:P -> P & String,value:Col.IndexedOrdinaryCarrier<S,P>) -> Col.IndexedOrdinaryCarrier<S,P> & String:
  match value:
    case Col.IndexedOrdinaryOwned{state}:indexed_state(~S,~P,~project,state)
    case Col.IndexedOrdinaryWrapped{inner}:indexed_wrap(~S,~P,indexed(~S,~P,~project,inner))
def indexed_column(~S:Data,~P:Type,observed:Col.IndexedOrdinaryCarrier<S,P> & String) -> Col.Column<S,P> & String:
  (state,text)=observed
  (Col.Indexed{state},"Indexed{" ++ text ++ "}")
def plain_column(~S:Data,~P:Type,+stamps:List<&2,L.Entry>,observed:Array<Maybe<&1,P>> & String) -> Col.Column<S,P> & String:
  (values,text)=observed
  (Col.Column{values,stamps},"Column{values=" ++ text ++ ";stamps=" ++ List.show(&2,L.Entry,entry,stamps) ++ "}")
def column(~S:Data,~P:Type,~project:P -> P & String,value:Col.Column<S,P>) -> Col.Column<S,P> & String:
  match value:
    case Col.Column{values,stamps}:plain_column(~S,~P,stamps,array(~Maybe<&1,P>,~optional(~P,~project),values))
    case Col.Indexed{state}:indexed_column(~S,~P,indexed(~S,~P,~project,state))
    case value:(value,"UNSUPPORTED_PREPARED_COLUMN")
# Opaque callbacks are returned unchanged; this observer never executes them.
def callbacks_join(~A:Type,~B:Type,head:A -> B,observed:List<(A -> B)> & Nat) -> List<(A -> B)> & Nat:
  (rest,count)=observed
  (head <> rest,1n+count)
def callbacks(~A:Type,~B:Type,values:List<(A -> B)>) -> List<(A -> B)> & Nat:
  match values:
    case []:([],0n)
    case head <> rest:callbacks_join(~A,~B,head,callbacks(~A,~B,rest))
def registration(value:W.RegistrationMeta) -> String:
  match value:
    case W.RegistrationMeta{id,name,access}:U32.show(id) ++ ":" ++ name ++ ":" ++ List.show(&2,String,x => x,access)

def key(value:Key.Key) -> String:
  match value:
    case Key.EntityKey{index,generation}:U32.show(index) ++ ":" ++ U32.show(generation)
type Render is Data:
  Text{value:String}
  Raw{value:D.Raw}
  Codec{value:D.Codec}
def raw_items(values:List<&2,D.Raw>,rest:List<&2,Render>) -> List<&2,Render>:
  match values:
    case []:rest
    case value <> tail:Raw{value} <> Text{","} <> raw_items(tail,rest)
def raw_fields(values:List<&2,D.Field>,rest:List<&2,Render>) -> List<&2,Render>:
  match values:
    case []:rest
    case D.Field{name,value} <> tail:Text{name ++ ":"} <> Raw{value} <> Text{","} <> raw_fields(tail,rest)
def codec_fields(values:List<&2,D.NamedCodec>,rest:List<&2,Render>) -> List<&2,Render>:
  match values:
    case []:rest
    case D.NamedCodec{name,value} <> tail:Text{name ++ ":"} <> Codec{value} <> Text{","} <> codec_fields(tail,rest)
def raw_expand(value:D.Raw,rest:List<&2,Render>) -> List<&2,Render>:
  match value:
    case D.Missing{}:Text{"Missing"} <> rest
    case D.Null{}:Text{"Null"} <> rest
    case D.Number{value}:Text{"Number{" ++ U32.show(value) ++ "}"} <> rest
    case D.SignedInteger{negative,magnitude}:Text{"SignedInteger{" ++ Bool.show(negative) ++ "," ++ Nat.show(magnitude) ++ "}"} <> rest
    case D.Float{value}:Text{"Float{bits=" ++ U32.show(F32.bits(value)) ++ "}"} <> rest
    case D.Binary64{high,low}:Text{"Binary64{" ++ U32.show(high) ++ "," ++ U32.show(low) ++ "}"} <> rest
    case D.Text{value}:Text{"Text{" ++ value ++ "}"} <> rest
    case D.Utf16Text{units}:Text{"Utf16Text{" ++ List.show(&2,U32,U32.show,units) ++ "}"} <> rest
    case D.Boolean{value}:Text{"Boolean{" ++ Bool.show(value) ++ "}"} <> rest
    case D.Handle{ns,id}:Text{"Handle{" ++ U32.show(ns) ++ "," ++ key(id) ++ "}"} <> rest
    case D.Array{items}:Text{"Array{"} <> raw_items(items,Text{"}"} <> rest)
    case D.Object{fields}:Text{"Object{"} <> raw_fields(fields,Text{"}"} <> rest)
def codec_expand(value:D.Codec,rest:List<&2,Render>) -> List<&2,Render>:
  match value:
    case D.FiniteNumber{}:Text{"FiniteNumber"} <> rest
    case D.Integer{}:Text{"Integer"} <> rest
    case D.StringValue{}:Text{"StringValue"} <> rest
    case D.BoolValue{}:Text{"BoolValue"} <> rest
    case D.Literal{value}:Text{"Literal{"} <> Raw{value} <> Text{"}"} <> rest
    case D.LiteralValues{values}:Text{"LiteralValues{"} <> raw_items(values,Text{"}"} <> rest)
    case D.LiteralRendered{values,expected}:Text{"LiteralRendered{"} <> raw_items(values,Text{";expected=" ++ expected ++ "}"} <> rest)
    case D.Nullable{inner}:Text{"Nullable{"} <> Codec{inner} <> Text{"}"} <> rest
    case D.ArrayValue{inner}:Text{"ArrayValue{"} <> Codec{inner} <> Text{"}"} <> rest
    case D.Struct{fields}:Text{"Struct{"} <> codec_fields(fields,Text{"}"} <> rest)
    case D.HandleValue{ns}:Text{"HandleValue{" ++ U32.show(ns) ++ "}"} <> rest
type RenderQueue is Data:RenderQueue{items:List<&2,Render>}
def render(fuel:Nat,work:RenderQueue,text:String) -> String:
  match fuel work:
    case _ RenderQueue{[]}:text
    case 0n _:text ++ "RENDER-FUEL-EXHAUSTED"
    case 1n+more RenderQueue{Text{value} <> tail}:render(more,RenderQueue{tail},text ++ value)
    case 1n+more RenderQueue{Raw{value} <> tail}:render(more,RenderQueue{raw_expand(value,tail)},text)
    case 1n+more RenderQueue{Codec{value} <> tail}:render(more,RenderQueue{codec_expand(value,tail)},text)
def raw(value:D.Raw) -> String:render(100000n,RenderQueue{[Raw{value}]},"")
def codec(value:D.Codec) -> String:render(100000n,RenderQueue{[Codec{value}]},"")

def handle(~S:Data,value:W.Handle<S>) -> String:
  match value:
    case W.Handle{namespace,id}:U32.show(namespace) ++ "/" ++ key(id)
def snapshot_entity(value:SnapshotData.Entity) -> String:
  match value:
    case SnapshotData.Entity{id,components}:key(id) ++ ":" ++ render(100000n,RenderQueue{raw_fields(components,[])},"")
def snapshot(value:SnapshotData.Snapshot) -> String:
  match value:
    case SnapshotData.Snapshot{version,next,entities,resources}:"snapshot{version=" ++ U32.show(version) ++ ";next=" ++ U32.show(next) ++ ";entities=" ++ List.show(&2,SnapshotData.Entity,snapshot_entity,entities) ++ ";resources=" ++ render(100000n,RenderQueue{raw_fields(resources,[])},"") ++ "}"

def payload_join(~S:Data,+canonical:D.Raw,+origin:D.Raw,observed:Array<U32> & String) -> Factory.Payload<S> & String:
  match observed:
    case (owned,text):(Factory.Payload{canonical,origin,owned},"payload{canonical=" ++ raw(canonical) ++ ";origin=" ++ raw(origin) ++ ";owned=" ++ text ++ "}")
def payload(~S:Data,value:Factory.Payload<S>) -> Factory.Payload<S> & String:
  match value:
    case Factory.Payload{canonical,origin,owned}:payload_join(~S,canonical,origin,u32_array(owned))
def input_join(~S:Data,+description:D.Raw,observed:Array<U32> & String) -> Factory.Input<S> & String:
  match observed:
    case (owned,text):(Factory.Input{description,owned},"input{raw=" ++ raw(description) ++ ";owned=" ++ text ++ "}")
def input(~S:Data,value:Factory.Input<S>) -> Factory.Input<S> & String:
  match value:
    case Factory.Input{description,owned}:input_join(~S,description,u32_array(owned))
def context_join(+serial:U32,observed:Array<U32> & String) -> Factory.Context & String:
  match observed:
    case (owned,text):(Factory.Context{serial,owned},"context{serial=" ++ U32.show(serial) ++ ";owned=" ++ text ++ "}")
def context(value:Factory.Context) -> Factory.Context & String:
  match value:
    case Factory.Context{serial,owned}:context_join(serial,u32_array(owned))
def list_join(~T:Type,head:T & String,tail:List<T> & String) -> List<T> & String:
  (head,ht)=head
  (tail,tt)=tail
  (head <> tail,"cons(" ++ ht ++ "," ++ tt ++ ")")
def owners(~T:Type,~view:T -> T & String,values:List<T>) -> List<T> & String:
  match values:
    case []:([],"[]")
    case head <> tail:list_join(~T,view(head),owners(~T,~view,tail))
def product_join(~A:Type,~B:Type,left:A & String,right:B & String) -> Product.Owner<A,B> & String:
  (left,lt)=left
  (right,rt)=right
  (Product.Owner{left,right},"product(" ++ lt ++ "," ++ rt ++ ")")
def product(~A:Type,~B:Type,~left:A -> A & String,~right:B -> B & String,value:Product.Owner<A,B>) -> Product.Owner<A,B> & String:
  match value:
    case Product.Owner{a,b}:product_join(~A,~B,left(a),right(b))
def unit(value:Unit) -> Unit & String:(value,"Unit")
def position(value:R.Position) -> String:
  match value:
    case R.Component{id}:"component(" ++ key(id) ++ ")"
    case R.Resource{}:"resource"
def record_join(~S:Data,+at:R.Position,undo:Factory.Payload<S> -> Factory.Input<S>,observed:Factory.Payload<S> & String) -> Stage.Record<Factory.Input<S>,Factory.Payload<S>> & String:
  match observed:
    case (owner,text):(Stage.Record{at,owner,undo},"record{position=" ++ position(at) ++ ";owner=" ++ text ++ ";undo=opaque}")
def record(~S:Data,value:Stage.Record<Factory.Input<S>,Factory.Payload<S>>) -> Stage.Record<Factory.Input<S>,Factory.Payload<S>> & String:
  match value:
    case Stage.Record{at,owner,undo}:record_join(~S,at,undo,payload(~S,owner))
def applied(~S:Data,value:Stage.Applied<Factory.Input<S>,Factory.Payload<S>>) -> Stage.Applied<Factory.Input<S>,Factory.Payload<S>> & String:
  match value:
    case Stage.Applied{+at,undo}:(Stage.Applied{at,undo},"applied{position=" ++ position(at) ++ ";undo=opaque}")
def stage_join(~S:Data,a:Factory.Context & String,b:List<Stage.Record<Factory.Input<S>,Factory.Payload<S>>> & String,c:List<Factory.Input<S>> & String,d:List<Factory.Payload<S>> & String,e:List<Stage.Applied<Factory.Input<S>,Factory.Payload<S>>> & String) -> Stage.State<Factory.Context,Factory.Input<S>,Factory.Payload<S>> & String:
  (a,sa)=a
  (b,sb)=b
  (c,sc)=c
  (d,sd)=d
  (e,se)=e
  (Stage.State{a,b,c,d,e},"stage{context=" ++ sa ++ ";records=" ++ sb ++ ";returned=" ++ sc ++ ";removed=" ++ sd ++ ";applied=" ++ se ++ "}")
def stage(~S:Data,value:Stage.State<Factory.Context,Factory.Input<S>,Factory.Payload<S>>) -> Stage.State<Factory.Context,Factory.Input<S>,Factory.Payload<S>> & String:
  match value:
    case Stage.State{a,b,c,d,e}:stage_join(~S,context(a),owners(~Stage.Record<Factory.Input<S>,Factory.Payload<S>>,~record(~S),b),owners(~Factory.Input<S>,~input(~S),c),owners(~Factory.Payload<S>,~payload(~S),d),owners(~Stage.Applied<Factory.Input<S>,Factory.Payload<S>>,~applied(~S),e))
def state(~S:Data,value:Schema.FullState(~S)) -> Schema.FullState(~S) & String:
  product(~Schema.ComponentState(~S),~Schema.ResourceGroupState(~S),~stage(~S),~product(~Schema.ResourceState(~S),~Unit,~stage(~S),~unit),value)
def recovery(~S:Data,value:Schema.FullRecovery(~S)) -> Schema.FullRecovery(~S) & String:
  product(~List<Factory.Input<S>>,~Product.Owner<List<Factory.Input<S>>,Unit>,~owners(~Factory.Input<S>,~input(~S)),~product(~List<Factory.Input<S>>,~Unit,~owners(~Factory.Input<S>,~input(~S)),~unit),value)
def kind(value:Fragment.RegistryKind) -> String:
  match value:
    case Fragment.Component{}:"Component"
    case Fragment.Resource{}:"Resource"
    case Fragment.Event{}:"Event"
    case Fragment.Relation{}:"Relation"
    case Fragment.Service{}:"Service"
def persistence(value:Fragment.PersistenceKind) -> String:
  match value:
    case Fragment.Plain{}:"Plain"
    case Fragment.Transient{}:"Transient"
    case Fragment.Constructed{}:"Constructed"
def schema_entry(~S:Data,value:Fragment.Entry<S>) -> String:
  match value:
    case Fragment.Entry{k,key,name}:"entry(" ++ kind(k) ++ "," ++ key ++ "," ++ name ++ ")"
    case Fragment.Classified{k,key,name,p}:"classified(" ++ kind(k) ++ "," ++ key ++ "," ++ name ++ "," ++ persistence(p) ++ ")"
def schema_text(~S:Data,value:Schema.FullSchema(~S)) -> String:
  match value:
    case RestoreSchema.Schema{Ordinary.Schema{entries}}:List.show(&2,Fragment.Entry<S>,schema_entry(~S),entries)
def owner_join(~S:Data,+schema:Schema.FullSchema(~S),observed:Schema.FullState(~S) & String) -> Schema.Owned(~S) & String:
  match observed:
    case (state,text):(Public.Owner{schema,state},"owner{schema=" ++ schema_text(~S,schema) ++ ";state=" ++ text ++ "}")
def owner(~S:Data,value:Schema.Owned(~S)) -> Schema.Owned(~S) & String:
  match value:
    case Public.Owner{schema,value}:owner_join(~S,schema,state(~S,value))

def component_join(~S:Data,+declaration:Persist.Constructed<S,Factory.Payload<S>,Factory.component_identity(~S),Factory.project(~S)>,observed:Col.Column<S,Factory.Payload<S>> & String) -> Schema.ComponentStore(~S) & String:
  match observed:
    case (column,text):(Leaf.Component{column,declaration},"component{codec=" ++ codec(Persist.codec(~S,~Factory.Payload<S>,~Factory.component_identity(~S),~Factory.project(~S),declaration)) ++ ";column=" ++ text ++ "}")
def component(~S:Data,value:Schema.ComponentStore(~S)) -> Schema.ComponentStore(~S) & String:
  match value:
    case Leaf.Component{value,declaration}:component_join(~S,declaration,column(~S,~Factory.Payload<S>,~payload(~S),value))
def resource_join(~S:Data,+declaration:Persist.Constructed<S,Factory.Payload<S>,Factory.resource_identity(~S),Factory.project(~S)>,observed:Factory.Payload<S> & String) -> Schema.ResourceResources(~S) & String:
  match observed:
    case (owner,text):(Leaf.Resource{owner,declaration},"resource{codec=" ++ codec(Persist.codec(~S,~Factory.Payload<S>,~Factory.resource_identity(~S),~Factory.project(~S),declaration)) ++ ";owner=" ++ text ++ "}")
def resource(~S:Data,value:Schema.ResourceResources(~S)) -> Schema.ResourceResources(~S) & String:
  match value:
    case Leaf.Resource{owner,declaration}:resource_join(~S,declaration,payload(~S,owner))
def transient_join(~S:Data,+declaration:Persist.Transient<S,Array<U32>,Factory.transient_identity(~S)>,observed:Array<U32> & String) -> Schema.TransientResources(~S) & String:
  match observed:
    case (owner,text):(Leaf.TransientResource{owner,declaration},"transient{owner=" ++ text ++ "}")
def transient(~S:Data,value:Schema.TransientResources(~S)) -> Schema.TransientResources(~S) & String:
  match value:
    case Leaf.TransientResource{owner,declaration}:transient_join(~S,declaration,u32_array(owner))
def store(~S:Data,value:Schema.FullStore(~S)) -> Schema.FullStore(~S) & String:
  product(~Schema.ComponentStore(~S),~Schema.ResourceGroupStore(~S),~component(~S),~product(~Unit,~Unit,~unit,~unit),value)
def row_join(+id:Nat,observed:Array<U32> & String) -> Log.Row<Array<U32>> & String:
  match observed:
    case (payload,text):(Log.Row{id,payload},Nat.show(id) ++ ":" ++ text)
def log_row(value:Log.Row<Array<U32>>) -> Log.Row<Array<U32>> & String:
  match value:
    case Log.Row{id,payload}:row_join(id,u32_array(payload))
def log_join(+next:Nat,observed:List<Log.Row<Array<U32>>> & String) -> Log.Log<Array<U32>> & String:
  match observed:
    case (rows,text):(Log.Log{next,rows},"log{next=" ++ Nat.show(next) ++ ";rows=" ++ text ++ "}")
def log(value:Log.Log<Array<U32>>) -> Log.Log<Array<U32>> & String:
  match value:
    case Log.Log{next,rows}:log_join(next,owners(~Log.Row<Array<U32>>,~log_row,rows))
def resources(~S:Data,value:Schema.FullResources(~S)) -> Schema.FullResources(~S) & String:
  product(~Schema.UserResources(~S),~Schema.Logs(),~product(~Unit,~Schema.ResourceGroupResources(~S),~unit,~product(~Schema.ResourceResources(~S),~Schema.TransientResources(~S),~resource(~S),~transient(~S))),~product(~Log.Log<Array<U32>>,~Unit,~log,~unit),value)
def change(~S:Data,value:R.Change<S>) -> String:
  match value:
    case R.Removed{target,name}:"Removed(" ++ handle(~S,target) ++ "," ++ name ++ ")"
    case R.Despawned{target}:"Despawned(" ++ handle(~S,target) ++ ")"
    case R.Spawned{target}:"Spawned(" ++ handle(~S,target) ++ ")"
def event(~S:Data,value:Schema.Events(~S)) -> String:
  match value:
    case Publication.Publication{first,second}:"publication{owned=" ++ List.show(&2,Nat,Nat.show,first) ++ ";restore=" ++ List.show(&2,R.Change<S>,change(~S),second) ++ "}"
def phase(value:Alloc.Phase) -> String:
  match value:
    case Alloc.Consumed{}:"Consumed"
    case Alloc.Pending{}:"Pending"
    case Alloc.Live{}:"Live"
    case Alloc.DeadRetained{}:"DeadRetained"
    case Alloc.Free{}:"Free"
def slot(value:Alloc.Slot) -> Alloc.Slot & String:
  match value:
    case Alloc.Slot{+generation,+p}:(Alloc.Slot{generation,p},U32.show(generation) ++ ":" ++ phase(p))
def allocator_join(+next:U32,+high:U32,+capacity:U32,+depth:Nat,+free:List<&2,U32>,+order:List<&2,Key.Key>,observed:Array<Alloc.Slot> & String) -> Alloc.Allocator & String:
  match observed:
    case (slots,text):(Alloc.Allocator{next,high,slots,capacity,depth,free,order},"next=" ++ U32.show(next) ++ ";high=" ++ U32.show(high) ++ ";capacity=" ++ U32.show(capacity) ++ ";depth=" ++ Nat.show(depth) ++ ";slots=" ++ text ++ ";free=" ++ List.show(&2,U32,U32.show,free) ++ ";order=" ++ List.show(&2,Key.Key,key,order))
def allocator(value:Alloc.Allocator) -> Alloc.Allocator & String:
  match value:
    case Alloc.Allocator{next,high,slots,capacity,depth,free,order}:allocator_join(next,high,capacity,depth,free,order,array(~Alloc.Slot,~slot,slots))
def pending_count_join(~S:Data,head:Deferred.Command<Schema.World(~S)>,observed:List<Deferred.Command<Schema.World(~S)>> & Nat) -> List<Deferred.Command<Schema.World(~S)>> & Nat:
  (rest,count)=observed
  (head <> rest,1n+count)
def pending_count(~S:Data,values:List<Deferred.Command<Schema.World(~S)>>) -> List<Deferred.Command<Schema.World(~S)>> & Nat:
  match values:
    case []:([],0n)
    case head <> rest:pending_count_join(~S,head,pending_count(~S,rest))


def world_join(~S:Data,+ns:U32,+events:List<&2,Schema.Events(~S)>,+regs:List<&2,W.RegistrationMeta>,+sid:U32,+clock:U32,a:Alloc.Allocator & String,c:Schema.FullStore(~S) & String,r:Schema.FullResources(~S) & String,p:List<Deferred.Command<Schema.World(~S)>> & Nat) -> Schema.World(~S) & String:
  (a,sa)=a
  (c,sc)=c
  (r,sr)=r
  (p,count)=p
  (W.World{ns,a,c,r,events,p,regs,sid,clock},"world{namespace=" ++ U32.show(ns) ++ ";allocator={" ++ sa ++ "};store=" ++ sc ++ ";resources=" ++ sr ++ ";events=" ++ List.show(&2,Schema.Events(~S),event(~S),events) ++ ";pending=" ++ Nat.show(count) ++ ";registrations=" ++ List.show(&2,W.RegistrationMeta,registration,regs) ++ ";nextSystem=" ++ U32.show(sid) ++ ";clock=" ++ U32.show(clock) ++ "}")
def world_raw(~S:Data,value:Schema.World(~S)) -> Schema.World(~S) & String:
  match value:
    case W.World{ns,a,c,r,e,p,regs,sid,clock}:world_join(~S,ns,e,regs,sid,clock,allocator(a),store(~S,c),resources(~S,r),pending_count(~S,p))
def world_visible(~S:Data,text:String,observed:Schema.World(~S) & List<&2,W.Handle<S>>) -> Schema.World(~S) & String:
  match observed:
    case (world,handles):(world,text ++ ";visible=" ++ List.show(&2,W.Handle<S>,handle(~S),handles))
def world_observed(~S:Data,observed:Schema.World(~S) & String) -> Schema.World(~S) & String:
  match observed:
    case (world,text):world_visible(~S,text,W.handles(~S,~Schema.FullStore(~S),~Schema.FullResources(~S),~Schema.Events(~S),world))
def world(~S:Data,value:Schema.World(~S)) -> Schema.World(~S) & String:
  world_observed(~S,world_raw(~S,value))

def local_join(~S:Data,+ns:U32,+id:U32,+name:String,+access:List<&2,String>,observed:Locals.Capture() & String) -> Locals.Owned(~S) & String:
  match observed:
    case (capture,text):(OrdinaryLocal.Owner{Local.Instance{ns,id,name,access,capture}},"local{namespace=" ++ U32.show(ns) ++ ";id=" ++ U32.show(id) ++ ";name=" ++ name ++ ";access=" ++ List.show(&2,String,x=>x,access) ++ ";capture=" ++ text ++ "}")
def local(~S:Data,value:Locals.Owned(~S)) -> Locals.Owned(~S) & String:
  match value:
    case OrdinaryLocal.Owner{Local.Instance{ns,id,name,access,capture}}:local_join(~S,ns,id,name,access,product(~Array<U32>,~Array<U32>,~u32_array,~u32_array,capture))

def batch(~E:Data,~show:E -> String,value:Ev.Batch<E>) -> String:
  match value:
    case Ev.Batch{tick,values}:"batch(" ++ Nat.show(tick) ++ "," ++ List.show(&2,E,show,values) ++ ")"
def reader_position(value:Ev.Position) -> String:
  match value:
    case Ev.Position{id,cursor,at}:U32.show(id) ++ ":" ++ Nat.show(cursor) ++ ":" ++ Nat.show(at)
def reader_status(value:Ev.ReaderStatus) -> String:
  match value:
    case Ev.ReaderStatus{id,cursor,at,unread,lagged}:U32.show(id) ++ ":" ++ Nat.show(cursor) ++ ":" ++ Nat.show(at) ++ ":" ++ Nat.show(unread) ++ ":" ++ Bool.show(lagged)
def stream_text(~S:Data,~E:Data,~show:E -> String,value:Stream.Stream<S,E>) -> String:
  match value:
    case Stream.Stream{Event.Domain{domain},+batches,+positions,next,start,boundary,capacity,+dropped}:"stream{domain=" ++ domain ++ ";batches=" ++ List.show(&2,Ev.Batch<E>,batch(~E,~show),batches) ++ ";positions=" ++ List.show(&2,Ev.Position,reader_position,positions) ++ ";statuses=" ++ List.show(&2,Ev.ReaderStatus,reader_status,Ev.reader_statuses(~E,positions,batches,dropped)) ++ ";nextReader=" ++ U32.show(next) ++ ";frameStart=" ++ Nat.show(start) ++ ";boundary=" ++ Nat.show(boundary) ++ ";capacity=" ++ Nat.show(capacity) ++ ";dropped=" ++ Nat.show(dropped) ++ "}"
def stream(~S:Data,~E:Data,~show:E -> String,+value:Stream.Stream<S,E>) -> Stream.Stream<S,E> & String:
  (value,stream_text(~S,~E,~show,value))
def family_state_join(~S:Data,~F:Type,~Owners:Type,+journal:List<&2,Ev.Batch<Schema.Events(~S)>>,+start:Nat,observedFamily:F & String,observedOwners:Owners & String) -> FR.State<Schema.Events(~S),F,Owners> & String:
  (family,ft)=observedFamily
  (owned,ot)=observedOwners
  (FR.State{family,owned,journal,start},"family{streams=" ++ ft ++ ";owners=" ++ ot ++ ";journal=" ++ List.show(&2,Ev.Batch<Schema.Events(~S)>,batch(~Schema.Events(~S),~event(~S)),journal) ++ ";journalSize=" ++ Nat.show(Ev.size(~Schema.Events(~S),journal)) ++ ";frameStart=" ++ Nat.show(start) ++ "}")
def family_state(~S:Data,~F:Type,~Owners:Type,~family:F -> F & String,~retained:Owners -> Owners & String,value:FR.State<Schema.Events(~S),F,Owners>) -> FR.State<Schema.Events(~S),F,Owners> & String:
  match value:
    case FR.State{streams,owners,journal,start}:family_state_join(~S,~F,~Owners,journal,start,family(streams),retained(owners))
def runtime_join(~S:Data,~F:Type,~Owners:Type,+tick:Nat,observedWorld:Schema.World(~S) & String,observedFamily:FR.State<Schema.Events(~S),F,Owners> & String) -> Route.Runtime<S,Schema.FullStore(~S),Schema.FullResources(~S),Schema.Events(~S),FR.State<Schema.Events(~S),F,Owners>> & String:
  (world,wt)=observedWorld
  (family,ft)=observedFamily
  (Route.Runtime{world,family,tick},"runtime{tick=" ++ Nat.show(tick) ++ ";" ++ wt ++ ";" ++ ft ++ "}")
def runtime(~S:Data,~F:Type,~Owners:Type,~family:F -> F & String,~retained:Owners -> Owners & String,value:Route.Runtime<S,Schema.FullStore(~S),Schema.FullResources(~S),Schema.Events(~S),FR.State<Schema.Events(~S),F,Owners>>) -> Route.Runtime<S,Schema.FullStore(~S),Schema.FullResources(~S),Schema.Events(~S),FR.State<Schema.Events(~S),F,Owners>> & String:
  match value:
    case Route.Runtime{current,state,tick}:runtime_join(~S,~F,~Owners,tick,world(~S,current),family_state(~S,~F,~Owners,~family,~retained,state))

def registry(~S:Data,~Args:Type,~Error:Data,~Out:Type,~runner:Schema.World(~S) -> Args -> Sys.Outcome<Schema.World(~S),Error,Out>,value:Sys.Registry<S,Schema.FullStore(~S),Schema.FullResources(~S),Schema.Events(~S),Args,Error,Out,runner>) -> Sys.Registry<S,Schema.FullStore(~S),Schema.FullResources(~S),Schema.Events(~S),Args,Error,Out,runner> & String:
  match value:
    case Sys.Registry{+ns,+id,+name,+access,+cursor}:(Sys.Registry{ns,id,name,access,cursor},"registry{namespace=" ++ U32.show(ns) ++ ";id=" ++ U32.show(id) ++ ";name=" ++ name ++ ";access=" ++ List.show(&2,String,x=>x,access) ++ ";cursor=" ++ U32.show(cursor) ++ "}")
def reader(~S:Data,~E:Data,~F:Type,~take:F -> F & Stream.Stream<S,E>,~put:F -> Stream.Stream<S,E> -> F,value:Route.Reader<S,E,F,take,put>) -> Route.Reader<S,E,F,take,put> & String:
  match value:
    case Route.Reader{+ns,+id,+registryId}:(Route.Reader{ns,id,registryId},"reader{namespace=" ++ U32.show(ns) ++ ";id=" ++ U32.show(id) ++ ";registryId=" ++ U32.show(registryId) ++ "}")
