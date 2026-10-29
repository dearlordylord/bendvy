import Base
import ./declarations.bend as Ordinary
import ./execution.bend as Execution
import ./restore-receipt.bend as Receipt
import ./staging.bend as Stage
import ../../src/ecs/execution-save-plan.bend as Plan
import ../../src/ecs/execution-save-world.bend as Save
import ../../src/ecs/execution-save-data.bend as Saved
import ../../src/ecs/execution-save-gate.bend as Gate
import ../../src/ecs/execution-composer-layout.bend as Layout
import ../../src/ecs/execution-parallel-root-application.bend as Schedule
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/dependency-application.bend as App
import ../../src/ecs/dependency-executor.bend as Exec
import ../../src/ecs/decode-data.bend as D
import ../../src/ecs/entity-key-render.bend as Key
import ../../src/ecs/restore-data.bend as R
import ../../src/ecs/world.bend as W
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/execution-lifecycle-notices.bend as Notice
import ../../src/ecs/execution-save-metadata.bend as Metadata
import ../../src/ecs/execution-save-recipe.bend as Recipe
import ../../src/ecs/entity-key.bend as EntityKey
import ../../src/ecs/entity-allocator.bend as Allocator
import ../../src/ecs/change-tick.bend as Tick
import ../../src/ecs/clock-state.bend as Clock
import ../../src/ecs/lifecycle.bend as Life
import ../../src/ecs/chunk-column.bend as Chunk
import ../../src/ecs/deferred-command.bend as Deferred
import ../../src/ecs/dependency-plan.bend as DepPlan
import ../../src/ecs/execution-deferred-settings.bend as Settings
import ./receiver.bend as Receiver
import ./setup.bend as Setup
import ../../src/ecs/execution-parallel-registration.bend as Part
import ../../src/ecs/execution-declaration.bend as Declaration
import ../../src/ecs/execution-query-recipe.bend as Query
import ../../src/ecs/persistence-declaration.bend as Decl
import ../../src/ecs/decode-construction.bend as Constructor
import ../../src/ecs/restore-leaf.bend as Leaf
import ./constructors.bend as Constructors
import ./publication.bend as Publication
import ../../src/ecs/execution-restore-publication.bend as Publish
import ../../src/ecs/execution-command-buffer.bend as Buffer
import ../../src/ecs/execution-command-removed.bend as Removed
import ../../src/ecs/execution-reservation-bundle.bend as Bundle
import ../../src/ecs/execution-restore-receiver.bend as Prepare
import ../../src/ecs/execution-restore-admission.bend as Admission
import ./pending-command.bend as Author
import ../../src/ecs/execution-command-system.bend as Cmd
import ../../src/ecs/execution-command-local.bend as CommandLocal
import ../../src/ecs/execution-command-permission.bend as Permission

def array_values(~T:Type,~show:T -> String,value:Array<T>) -> String:
  match value:
    case ALeaf{item}:"[" ++ show(item) ++ "]"
    case ANode{left,right}:"[" ++ array_values(~T,~show,left) ++ "," ++ array_values(~T,~show,right) ++ "]"
def array_u32(value:Array<U32>) -> String:array_values(~U32,~U32.show,value)
def maybe_owner(~T:Type,~show:T -> String,value:Maybe<&1,T>) -> String:
  match value:
    case None{}:"none"
    case Some{owner}:"some(" ++ show(owner) ++ ")"
def maybe_tick(value:Maybe<&2,Tick.Tick>) -> String:
  match value:
    case None{}:"none"
    case Some{tick}:"some(" ++ Tick.show(tick) ++ ")"
def stamp(value:Life.Stamp) -> String:
  match value:
    case Life.Stamp{added,changed}:"added=" ++ maybe_tick(added) ++ ":changed=" ++ maybe_tick(changed)
def maybe_stamp(value:Maybe<&2,Life.Stamp>) -> String:
  match value:
    case None{}:"none"
    case Some{value}:"some(" ++ stamp(value) ++ ")"
def phase(value:Allocator.Phase) -> String:
  match value:
    case Allocator.Consumed{}:"consumed"
    case Allocator.Pending{}:"pending"
    case Allocator.Live{}:"live"
    case Allocator.DeadRetained{}:"dead-retained"
    case Allocator.Free{}:"free"
def slot(value:Allocator.Slot) -> String:
  match value:
    case Allocator.Slot{generation,state}:U32.show(generation) ++ ":" ++ phase(state)
def clock(value:Clock.State) -> String:
  match value:
    case Clock.State{now,scopes}:"now=" ++ Tick.show(now) ++ ":scopes=" ++ List.show(&2,Tick.Tick,Tick.show,scopes)
def selector(value:Notice.Selector) -> String:
  match value:
    case Notice.Removed{key}:"removed(" ++ key ++ ")"
    case Notice.Despawned{}:"despawned"
def identity(~S:Data,value:Notice.Identity<S>) -> String:
  match value:
    case Notice.Identity{namespace,key}:U32.show(namespace) ++ ":" ++ Key.show(key)
def notice_row(~S:Data,value:Notice.Row<S>) -> String:
  match value:
    case Notice.Row{sequence,entity,tick}:Nat.show(sequence) ++ ":" ++ identity(~S,entity) ++ ":" ++ Tick.show(tick)
def channel(~S:Data,value:Notice.Channel<S>) -> String:
  match value:
    case Notice.Channel{chosen,next,previous,current,droppedThrough}:selector(chosen) ++ ":next=" ++ Nat.show(next) ++ ":previous=" ++ List.show(&2,Notice.Row<S>,notice_row(~S),previous) ++ ":current=" ++ List.show(&2,Notice.Row<S>,notice_row(~S),current) ++ ":dropped=" ++ Nat.show(droppedThrough)
def active(value:Notice.Active) -> String:
  match value:
    case Notice.Active{id,chosen}:U32.show(id) ++ ":" ++ selector(chosen)
def journal(~S:Data,value:Notice.Journal<S>) -> String:
  match value:
    case Notice.Journal{namespace,channels,nextReader,entries}:"ns=" ++ U32.show(namespace) ++ ":channels=" ++ List.show(&2,Notice.Channel<S>,channel(~S),channels) ++ ":nextReader=" ++ U32.show(nextReader) ++ ":active=" ++ List.show(&2,Notice.Active,active,entries)
def saved_lifecycle(~S:Data,value:Metadata.Lifecycle<S>) -> String:
  match value:
    case Metadata.Lifecycle{namespace,channels,nextReader,entries}:"ns=" ++ U32.show(namespace) ++ ":channels=" ++ List.show(&2,Notice.Channel<S>,channel(~S),channels) ++ ":nextReader=" ++ U32.show(nextReader) ++ ":active=" ++ List.show(&2,Notice.Active,active,entries)
def prepare_reason(value:Prepare.Reason) -> String:
  match value:
    case Prepare.PendingWork{}:"pending-work"
    case Prepare.ActiveExecution{}:"active-execution"
    case Prepare.MalformedColumns{}:"malformed-columns"
    case Prepare.Capacity{}:"capacity"

def raw(value:D.Raw) -> String:
  match value:
    case D.Missing{}:"missing"
    case D.Null{}:"null"
    case D.Number{value}:U32.show(value)
    case D.SignedInteger{negative,value}:Bool.show(negative) ++ ":" ++ Nat.show(value)
    case D.Float{value}:F32.show(value)
    case D.Binary64{hi,lo}:U32.show(hi) ++ ":" ++ U32.show(lo)
    case D.BendvyText{value}:value
    case D.Utf16Text{values}:List.show(&2,U32,U32.show,values)
    case D.Boolean{value}:Bool.show(value)
    case D.Handle{namespace,key}:U32.show(namespace) ++ ":" ++ Key.show(key)
    case D.Array{[]}:"[]"
    case D.Array{head <> rest}:"[" ++ raw(head) ++ ";" ++ raw(D.Array{rest}) ++ "]"
    case D.Object{[]}:"{}"
    case D.Object{D.Field{name,value} <> rest}:"{" ++ name ++ "=" ++ raw(value) ++ ";" ++ raw(D.Object{rest}) ++ "}"
def codec_atom(value:D.Codec) -> String:
  match value:
    case D.FiniteNumber{}:"finite-number"
    case D.Integer{}:"integer"
    case D.StringValue{}:"string"
    case D.BoolValue{}:"bool"
    case D.Literal{value}:"literal(" ++ raw(value) ++ ")"
    case D.LiteralValues{values}:"literals" ++ List.show(&2,D.Raw,raw,values)
    case D.LiteralRendered{values,expected}:"rendered(" ++ expected ++ "," ++ List.show(&2,D.Raw,raw,values) ++ ")"
    case D.Nullable{_}:"nullable(nested-codec)"
    case D.ArrayValue{_}:"array(nested-codec)"
    case D.Struct{fields}:"struct(fields=" ++ Nat.show(List.length(&2,D.NamedCodec,fields)) ++ ")"
    case D.HandleValue{namespace}:"handle(" ++ U32.show(namespace) ++ ")"
def named_codec(value:D.NamedCodec) -> String:
  match value:
    case D.NamedCodec{name,part}:name ++ "=" ++ codec_atom(part)
def codec(value:D.Codec) -> String:
  match value:
    case D.FiniteNumber{}:"finite-number"
    case D.Integer{}:"integer"
    case D.StringValue{}:"string"
    case D.BoolValue{}:"bool"
    case D.Literal{value}:"literal(" ++ raw(value) ++ ")"
    case D.LiteralValues{values}:"literals" ++ List.show(&2,D.Raw,raw,values)
    case D.LiteralRendered{values,expected}:"rendered(" ++ expected ++ "," ++ List.show(&2,D.Raw,raw,values) ++ ")"
    case D.Nullable{inner}:"nullable(" ++ codec(inner) ++ ")"
    case D.ArrayValue{inner}:"array(" ++ codec(inner) ++ ")"
    case D.Struct{fields}:"struct" ++ List.show(&2,D.NamedCodec,named_codec,fields)
    case D.HandleValue{namespace}:"handle(" ++ U32.show(namespace) ++ ")"
def schema(~S:Data,value:Plan.Schema<S,Ordinary.components(~S),Ordinary.resources(~S)>) -> String:
  match value:
    case Plan.Schema{Product.Owner{Decl.Constructed{actorCodec},Decl.Transient{}},Product.Owner{Decl.Constructed{configCodec},Decl.Transient{}}}:"actor=" ++ codec(actorCodec) ++ ":scratch=transient/config=" ++ codec(configCodec) ++ ":temporary=transient"
def position(value:R.Position) -> String:
  match value:
    case R.Component{saved}:"component(" ++ Key.show(saved) ++ ")"
    case R.Resource{}:"resource"
def actor_factory(~S:Data,value:Constructors.ActorFactory(~S)) -> String:
  match value:
    case Constructor.FallibleFactory{Decl.Constructed{declared},input}:"declaration=" ++ codec(declared) ++ ":input=" ++ codec(input) ++ ":callbacks=opaque"
def config_factory(~S:Data,value:Constructors.ConfigFactory(~S)) -> String:
  match value:
    case Constructor.FallibleFactory{Decl.Constructed{declared},input}:"declaration=" ++ codec(declared) ++ ":input=" ++ codec(input) ++ ":callbacks=opaque"
def show_actor(~S:Data,value:Ordinary.Actor<S>) -> String:
  match value:
    case Ordinary.Actor{name,energy}:"name=" ++ name ++ ":energy=" ++ array_u32(energy)
def show_config(~S:Data,value:Ordinary.Config<S>) -> String:
  match value:
    case Ordinary.Config{enabled,limit}:"enabled=" ++ Bool.show(enabled) ++ ":limit=" ++ array_u32(limit)
def show_scratch(~S:Data,value:Ordinary.Scratch<S>) -> String:
  match value:
    case Ordinary.Scratch{values}:array_u32(values)
def actor_record(~S:Data,value:Leaf.Record<D.Raw,Ordinary.Actor<S>>) -> String:
  match value:
    case Leaf.Record{place,owner,_}:position(place) ++ ":" ++ show_actor(~S,owner) ++ ":undo=opaque"
def config_record(~S:Data,value:Leaf.Record<D.Raw,Ordinary.Config<S>>) -> String:
  match value:
    case Leaf.Record{place,owner,_}:position(place) ++ ":" ++ show_config(~S,owner) ++ ":undo=opaque"
def actor_applied(~S:Data,value:Leaf.Applied<D.Raw,Ordinary.Actor<S>>) -> String:
  match value:
    case Leaf.Applied{place,_}:position(place) ++ ":undo=opaque"
def config_applied(~S:Data,value:Leaf.Applied<D.Raw,Ordinary.Config<S>>) -> String:
  match value:
    case Leaf.Applied{place,_}:position(place) ++ ":undo=opaque"
def actor_stage(~S:Data,value:Stage.Actors(~S)) -> String:
  match value:
    case Leaf.State{factory,records,returned,removed,applied}:"factory=" ++ actor_factory(~S,factory) ++ ":records=" ++ List.show(&1,Leaf.Record<D.Raw,Ordinary.Actor<S>>,actor_record(~S),records) ++ ":returned=" ++ List.show(&1,D.Raw,raw,returned) ++ ":removed=" ++ List.show(&1,Ordinary.Actor<S>,show_actor(~S),removed) ++ ":applied=" ++ List.show(&1,Leaf.Applied<D.Raw,Ordinary.Actor<S>>,actor_applied(~S),applied)
def config_stage(~S:Data,value:Stage.Configs(~S)) -> String:
  match value:
    case Leaf.State{factory,records,returned,removed,applied}:"factory=" ++ config_factory(~S,factory) ++ ":records=" ++ List.show(&1,Leaf.Record<D.Raw,Ordinary.Config<S>>,config_record(~S),records) ++ ":returned=" ++ List.show(&1,D.Raw,raw,returned) ++ ":removed=" ++ List.show(&1,Ordinary.Config<S>,show_config(~S),removed) ++ ":applied=" ++ List.show(&1,Leaf.Applied<D.Raw,Ordinary.Config<S>>,config_applied(~S),applied)
def stage(~S:Data,value:Stage.State<S>) -> Plan.Schema<S,Ordinary.components(~S),Ordinary.resources(~S)> & String:
  match value:
    case Stage.State{schema,actors,configs}:(schema,"actors=" ++ actor_stage(~S,actors) ++ "/configs=" ++ config_stage(~S,configs))
def field(value:Saved.Field) -> String:
  match value:
    case Saved.Field{key,present,Saved.Absent{},written}:key ++ "=" ++ Bool.show(present) ++ ":absent:stamp=" ++ maybe_stamp(written)
    case Saved.Field{key,present,Saved.Omitted{},written}:key ++ "=" ++ Bool.show(present) ++ ":transient:stamp=" ++ maybe_stamp(written)
    case Saved.Field{key,present,Saved.Persisted{value},written}:key ++ "=" ++ Bool.show(present) ++ ":" ++ raw(value) ++ ":stamp=" ++ maybe_stamp(written)
def entity(value:Saved.Entity) -> String:
  match value:
    case Saved.Entity{key,values}:Key.show(key) ++ List.show(&2,Saved.Field,field,values)
def snapshot(~S:Data,value:Saved.Snapshot<S>) -> String:
  match value:
    case Saved.Snapshot{version,Metadata.Metadata{namespace,Metadata.Allocator{next,high,capacity,depth,slots,free,order},time,lifecycle},entities,resources}:"v=" ++ U32.show(version) ++ "/ns=" ++ U32.show(namespace) ++ "/allocator=" ++ U32.show(next) ++ ":" ++ U32.show(high) ++ ":" ++ U32.show(capacity) ++ ":" ++ Nat.show(depth) ++ ":slots=" ++ List.show(&2,Allocator.Slot,slot,slots) ++ ":free=" ++ List.show(&2,U32,U32.show,free) ++ ":order=" ++ List.show(&2,EntityKey.Key,Key.show,order) ++ "/clock=" ++ clock(time) ++ "/lifecycle=" ++ saved_lifecycle(~S,lifecycle) ++ "/entities=" ++ List.show(&2,Saved.Entity,entity,entities) ++ "/resources=" ++ List.show(&2,Saved.Field,field,resources)
def binding(~S:Data,value:R.Binding<S>) -> String:
  match value:
    case R.Binding{saved,W.Handle{namespace,target}}:Key.show(saved) ++ "->" ++ U32.show(namespace) ++ ":" ++ Key.show(target)
def handle(~S:Data,value:W.Handle<S>) -> String:
  match value:
    case W.Handle{namespace,key}:U32.show(namespace) ++ ":" ++ Key.show(key)
def removed_bundle(~S:Data,value:Removed.Removed(Receiver.Components(~S))) -> String:
  match value:
    case Product.Owner{actorOwner,scratchOwner}:"actor=" ++ maybe_owner(~Ordinary.Actor<S>,~show_actor(~S),actorOwner) ++ ":scratch=" ++ maybe_owner(~Ordinary.Scratch<S>,~show_scratch(~S),scratchOwner)
def buffer_receipt(~S:Data,value:Buffer.Receipt<S,Ordinary.Actor<S>,Removed.Removed(Receiver.Components(~S))>) -> String:
  match value:
    case Buffer.Applied{target,previous}:"applied(" ++ handle(~S,target) ++ "," ++ maybe_owner(~Ordinary.Actor<S>,~show_actor(~S),previous) ++ ")"
    case Buffer.Refused{target,incoming}:"refused(" ++ handle(~S,target) ++ "," ++ maybe_owner(~Ordinary.Actor<S>,~show_actor(~S),incoming) ++ ")"
    case Buffer.Despawned{target,removed}:"despawned(" ++ handle(~S,target) ++ "," ++ removed_bundle(~S,removed) ++ ")"
    case Buffer.DespawnRefused{target}:"despawn-refused(" ++ handle(~S,target) ++ ")"
    case Buffer.Spawned{target,previous}:"spawned(" ++ handle(~S,target) ++ "," ++ removed_bundle(~S,previous) ++ ")"
    case Buffer.SpawnRefused{target,bundle,_}:"spawn-refused(" ++ handle(~S,target) ++ "," ++ removed_bundle(~S,bundle) ++ ")"
    case _:"other-command-receipt"
def publication_row(~S:Data,value:Publish.Row<Receiver.Components(~S)>) -> String:
  match value:
    case Publish.Row{saved,bundle}:Key.show(saved) ++ ":" ++ removed_bundle(~S,bundle)
def publication_receipt(~S:Data,value:Publish.Receipt<S,Receiver.Components(~S)>) -> String:
  match value:
    case Publish.Materialized{saved,target,previous}:"materialized(" ++ Key.show(saved) ++ "->" ++ handle(~S,target) ++ "," ++ removed_bundle(~S,previous) ++ ")"
    case Publish.AllocationRefused{saved,bundle}:"allocation-refused(" ++ Key.show(saved) ++ "," ++ removed_bundle(~S,bundle) ++ ")"
    case Publish.PublicationRefused{saved,target,bundle,_}:"publication-refused(" ++ Key.show(saved) ++ "->" ++ handle(~S,target) ++ "," ++ removed_bundle(~S,bundle) ++ ")"
def previous_config(~S:Data,value:Maybe<&1,Publication.ConfigSlot(~S)>) -> String:
  match value:
    case None{}:"none"
    case Some{Layout.ResourceSlot{Layout.Viewed{owner,Ordinary.ConfigView{enabled,limit}},written}}:"some(" ++ show_config(~S,owner) ++ ":cache=" ++ Bool.show(enabled) ++ ":" ++ U32.show(limit) ++ ":stamp=" ++ stamp(written) ++ ")"
def decode_error(value:D.Error) -> String:
  match value:
    case D.Invalid{path,expected,actual}:"invalid(" ++ path ++ "," ++ expected ++ "," ++ raw(actual) ++ ")"
    case D.FuelExhausted{path}:"fuel(" ++ path ++ ")"
def admission_error(value:Admission.Error) -> String:
  match value:
    case Admission.UnsupportedVersion{version}:"unsupported-version(" ++ U32.show(version) ++ ")"
    case Admission.DuplicateEntity{key}:"duplicate(" ++ Key.show(key) ++ ")"
    case Admission.FieldShape{}:"field-shape"
    case Admission.FieldKey{expected,actual}:"field-key(" ++ expected ++ "," ++ actual ++ ")"
    case Admission.PlainUnserializable{key}:"plain(" ++ key ++ ")"
    case Admission.InvalidValue{key}:"value(" ++ key ++ ")"
    case Admission.InvalidCodec{key,error}:"codec(" ++ key ++ "," ++ decode_error(error) ++ ")"
    case Admission.InvalidMetadata{}:"metadata"
def constructor_error(value:Constructor.Error<Unit>) -> String:
  match value:
    case Constructor.Validation{error}:"validation(" ++ decode_error(error) ++ ")"
    case Constructor.Constructor{_}:"constructor(unit)"
def restore_error(value:R.Error<Unit>) -> String:
  match value:
    case R.InvalidSnapshot{path}:"snapshot(" ++ path ++ ")"
    case R.UnsupportedVersion{version}:"version(" ++ raw(version) ++ ")"
    case R.DuplicateEntity{saved}:"duplicate(" ++ Key.show(saved) ++ ")"
    case R.UnknownComponent{saved,name}:"component(" ++ Key.show(saved) ++ "," ++ name ++ ")"
    case R.UnknownResource{name}:"resource(" ++ name ++ ")"
    case R.InvalidComponent{saved,name,error}:"component-value(" ++ Key.show(saved) ++ "," ++ name ++ "," ++ constructor_error(error) ++ ")"
    case R.InvalidResource{name,error}:"resource-value(" ++ name ++ "," ++ constructor_error(error) ++ ")"
    case R.UnvalidatedDescriptor{name}:"descriptor(" ++ name ++ ")"
    case R.Capacity{nextEntity}:"capacity(" ++ U32.show(nextEntity) ++ ")"
def stage_error(value:Stage.Error) -> String:
  match value:
    case Stage.AdmissionRefused{error}:"admission(" ++ admission_error(error) ++ ")"
    case Stage.ConstructorRefused{error}:"constructor(" ++ restore_error(error) ++ ")"
def receipt_status(value:Receipt.Status) -> String:
  match value:
    case Receipt.Pending{}:"pending"
    case Receipt.ReceiverRefused{reason}:"receiver-refused(" ++ prepare_reason(reason) ++ ")"
    case Receipt.InputRefused{error}:"input-refused(" ++ stage_error(error) ++ ")"
    case Receipt.RowsRefused{}:"rows-refused"
    case Receipt.ClearInterrupted{}:"clear-interrupted"
    case Receipt.PublicationPartial{}:"publication-partial"
    case Receipt.ResourcePartial{}:"resource-partial"
    case Receipt.Restored{}:"restored"
def receipt_rendered(~S:Data,input:Saved.Snapshot<S>,removed:List<Buffer.Receipt<S,Ordinary.Actor<S>,Removed.Removed(Receiver.Components(~S))>>,rows:List<Publish.Row<Receiver.Components(~S)>>,mapping:List<&2,R.Binding<S>>,publications:List<Publish.Receipt<S,Receiver.Components(~S)>>,previous:Maybe<&1,Publication.ConfigSlot(~S)>,remaining:List<&2,W.Handle<S>>,status:Receipt.Status,result:Plan.Schema<S,Ordinary.components(~S),Ordinary.resources(~S)> & String) -> Plan.Schema<S,Ordinary.components(~S),Ordinary.resources(~S)> & String:
  match result:
    case (schema,staged):(schema,"status=" ++ receipt_status(status) ++ "/input=" ++ snapshot(~S,input) ++ "/staged=" ++ staged ++ "/removed=" ++ List.show(&1,Buffer.Receipt<S,Ordinary.Actor<S>,Removed.Removed(Receiver.Components(~S))>,buffer_receipt(~S),removed) ++ "/rows=" ++ List.show(&1,Publish.Row<Receiver.Components(~S)>,publication_row(~S),rows) ++ "/mapping=" ++ List.show(&2,R.Binding<S>,binding(~S),mapping) ++ "/publications=" ++ List.show(&1,Publish.Receipt<S,Receiver.Components(~S)>,publication_receipt(~S),publications) ++ "/previous=" ++ previous_config(~S,previous) ++ "/remaining=" ++ List.show(&2,W.Handle<S>,handle(~S),remaining))
def receipt_for_save(~S:Data,value:Receipt.Receipt<S>) -> Plan.Schema<S,Ordinary.components(~S),Ordinary.resources(~S)> & String:
  match value:
    case Receipt.Receipt{state,input,removed,rows,mapping,publications,previous,remaining,status}:receipt_rendered(~S,input,removed,rows,mapping,publications,previous,remaining,status,stage(~S,state))
def viewed_actor(~S:Data,value:Layout.Viewed<Ordinary.Actor<S>,Ordinary.ActorView>) -> String:
  match value:
    case Layout.Viewed{owner,Ordinary.ActorView{name,energy}}:show_actor(~S,owner) ++ ":cache=" ++ name ++ ":" ++ U32.show(energy)
def viewed_scratch(~S:Data,value:Layout.Viewed<Ordinary.Scratch<S>,Unit>) -> String:
  match value:
    case Layout.Viewed{owner,_}:show_scratch(~S,owner) ++ ":cache=unit"
def column(~S:Data,~P:Type,~show:P -> String,value:Chunk.Column<S,P>) -> String:
  match value:
    case Chunk.Leaf{values,stamps}:"leaf(values=" ++ array_values(~Maybe<&1,P>,~maybe_owner(~P,~show),values) ++ ",stamps=" ++ array_values(~Life.Stamp,~stamp,stamps) ++ ")"
    case Chunk.Branch{half,left,right}:"branch(" ++ U32.show(half) ++ "," ++ column(~S,~P,~show,left) ++ "," ++ column(~S,~P,~show,right) ++ ")"
def columns(~S:Data,value:Layout.columns(~S,Receiver.Components(~S))) -> String:
  match value:
    case Product.Owner{Layout.ColumnSlot{actors},Layout.ColumnSlot{scratchValues}}:"actor=" ++ column(~S,~Layout.Viewed<Ordinary.Actor<S>,Ordinary.ActorView>,~viewed_actor(~S),actors) ++ ":scratch=" ++ column(~S,~Layout.Viewed<Ordinary.Scratch<S>,Unit>,~viewed_scratch(~S),scratchValues)
def resources(~S:Data,value:Receiver.Resources(~S)) -> String:
  match value:
    case Product.Owner{Layout.ResourceSlot{Layout.Viewed{configOwner,Ordinary.ConfigView{cachedEnabled,cachedLimit}},configStamp},Layout.ResourceSlot{Layout.Viewed{scratchOwner,_},scratchStamp}}:"config=" ++ show_config(~S,configOwner) ++ ":cache=" ++ Bool.show(cachedEnabled) ++ ":" ++ U32.show(cachedLimit) ++ ":stamp=" ++ stamp(configStamp) ++ ":temporary=" ++ show_scratch(~S,scratchOwner) ++ ":stamp=" ++ stamp(scratchStamp)
def allocator_state(value:Allocator.Allocator) -> String:
  match value:
    case Allocator.Allocator{next,high,slots,capacity,depth,free,order}:"next=" ++ U32.show(next) ++ ":high=" ++ U32.show(high) ++ ":capacity=" ++ U32.show(capacity) ++ ":depth=" ++ Nat.show(depth) ++ ":slots=" ++ array_values(~Allocator.Slot,~slot,slots) ++ ":free=" ++ List.show(&2,U32,U32.show,free) ++ ":order=" ++ List.show(&2,EntityKey.Key,Key.show,order)
def registration(value:W.RegistrationMeta) -> String:
  match value:
    case W.RegistrationMeta{id,name,access}:U32.show(id) ++ ":" ++ name ++ ":" ++ List.show(&2,String,(value => value),access)
def deferred(~S:Data,value:Deferred.Command<Receiver.World(~S)>) -> String:
  match value:
    case Deferred.Raw{_}:"raw(callback-opaque)"
    case Deferred.Observed{_}:"observed(callback-opaque)"
def world(~S:Data,value:Receiver.World(~S)) -> String:
  match value:
    case W.World{namespace,allocator,store,resource,events,pending,registrations,nextSystemId,time,lifecycle}:"ns=" ++ U32.show(namespace) ++ "/allocator=" ++ allocator_state(allocator) ++ "/columns=" ++ columns(~S,store) ++ "/resources=" ++ resources(~S,resource) ++ "/events=" ++ List.show(&2,Unit,(_ => "unit"),events) ++ "/pending=" ++ List.show(&1,Deferred.Command<Receiver.World(~S)>,deferred(~S),pending) ++ "/registrations=" ++ List.show(&2,W.RegistrationMeta,registration,registrations) ++ "/nextSystem=" ++ U32.show(nextSystemId) ++ "/clock=" ++ clock(time) ++ "/lifecycle=" ++ journal(~S,lifecycle)
def system_header(namespace:U32,id:U32,name:String,access:List<&2,String>,cursor:Maybe<&2,Tick.Tick>) -> String:
  "ns=" ++ U32.show(namespace) ++ ":id=" ++ U32.show(id) ++ ":name=" ++ name ++ ":access=" ++ List.show(&2,String,(x => x),access) ++ ":cursor=" ++ maybe_tick(cursor)
def report_event(value:Exec.Observation<String,String>) -> String:
  match value:
    case Exec.Ran{id,output}:"ran(" ++ U32.show(id) ++ "," ++ output ++ ")"
    case Exec.BodyFailed{id,error,output}:"body-failed(" ++ U32.show(id) ++ "," ++ error ++ "," ++ output ++ ")"
    case Exec.Skipped{id}:"skipped(" ++ U32.show(id) ++ ")"
    case Exec.ConditionFailed{id,error}:"condition-failed(" ++ U32.show(id) ++ "," ++ error ++ ")"
    case Exec.ConditionRejected{id}:"condition-rejected(" ++ U32.show(id) ++ ")"
    case Exec.AdmissionRejected{id}:"admission-rejected(" ++ U32.show(id) ++ ")"
def invalid(value:DepPlan.Invalid<String>) -> String:
  match value:
    case DepPlan.Duplicate{id}:"duplicate(" ++ U32.show(id) ++ ")"
    case DepPlan.UnknownDependency{id}:"unknown(" ++ U32.show(id) ++ ")"
    case DepPlan.Missing{id,requirement}:"missing(" ++ U32.show(id) ++ "," ++ requirement ++ ")"
    case DepPlan.Cycle{}:"cycle"
    case DepPlan.InvalidCondition{id}:"condition(" ++ U32.show(id) ++ ")"
def report(value:App.Report<String,String>) -> String:
  match value:
    case App.Finished{events}:"finished" ++ List.show(&2,Exec.Observation<String,String>,report_event,events)
    case App.Stopped{error,events}:"stopped(" ++ error ++ ")" ++ List.show(&2,Exec.Observation<String,String>,report_event,events)
    case App.Invalid{reason}:"invalid(" ++ invalid(reason) ++ ")"
def plan_node(value:DepPlan.Node<String>) -> String:
  match value:
    case DepPlan.Node{id,requirements}:U32.show(id) ++ List.show(&2,String,(x => x),requirements)
def plan_edge(value:DepPlan.Edge) -> String:
  match value:
    case DepPlan.Edge{before,after}:U32.show(before) ++ ">" ++ U32.show(after)
def plan(value:DepPlan.Build<String>) -> String:
  match value:
    case DepPlan.Planned{order,edges}:"order=" ++ List.show(&2,DepPlan.Node<String>,plan_node,order) ++ ":edges=" ++ List.show(&2,DepPlan.Edge,plan_edge,edges)
    case DepPlan.Rejected{reason}:"rejected(" ++ invalid(reason) ++ ")"
def route(value:Layout.Route) -> String:
  match value:
    case Layout.AtLeaf{}:"leaf"
    case Layout.InLeft{rest}:"left/" ++ route(rest)
    case Layout.InRight{rest}:"right/" ++ route(rest)
def mode(value:Declaration.Mode) -> String:
  match value:
    case Declaration.Exclusive{}:"exclusive"
    case Declaration.SharedView{}:"shared"
def bound(value:Query.Bound) -> String:
  match value:
    case Query.AllLive{}:"all-live"
    case Query.With{chosen}:"with(" ++ route(chosen) ++ ")"
    case Query.Without{chosen}:"without(" ++ route(chosen) ++ ")"
    case Query.Changed{chosen}:"changed(" ++ route(chosen) ++ ")"
    case Query.And{left,right}:"and(" ++ bound(left) ++ "," ++ bound(right) ++ ")"
    case Query.Or{left,right}:"or(" ++ bound(left) ++ "," ++ bound(right) ++ ")"
def coordinates(value:Part.Coordinates) -> String:
  match value:
    case Part.EmptyCoordinates{}:"empty"
    case Part.LeafCoordinates{key}:key
    case Part.PairCoordinates{left,right}:"(" ++ coordinates(left) ++ "," ++ coordinates(right) ++ ")"
def use(value:Part.Use) -> String:
  match value:
    case Part.Use{key,access}:key ++ ":" ++ mode(access)
    case Part.SelectedQuery{key,access,chosen,filter,shape}:key ++ ":" ++ mode(access) ++ ":" ++ route(chosen) ++ ":" ++ bound(filter) ++ ":" ++ coordinates(shape)
def rule(value:Part.Entry) -> String:
  match value:
    case Part.Entry{id,uses}:U32.show(id) ++ List.show(&2,Part.Use,use,uses)
def rules(value:Part.Rules) -> String:
  match value:
    case Part.Rules{entries}:List.show(&2,Part.Entry,rule,entries)
def binding_app(value:App.Binding) -> String:
  match value:
    case App.Binding{system,condition}:U32.show(system) ++ "?" ++ U32.show(condition)
def maybe_u32(value:Maybe<&2,U32>) -> String:
  match value:
    case None{}:"none"
    case Some{value}:U32.show(value)
def explicit(value:Settings.Explicit) -> String:
  match value:
    case Settings.Explicit{before,condition}:U32.show(before) ++ "?" ++ maybe_u32(condition)
def settings(value:Settings.Settings) -> String:
  match value:
    case Settings.Settings{automatic,finalApply,ignored,entries}:"automatic=" ++ Bool.show(automatic) ++ ":finalApply=" ++ Bool.show(finalApply) ++ ":ignored=" ++ List.show(&2,DepPlan.Edge,plan_edge,ignored) ++ ":explicit=" ++ List.show(&2,Settings.Explicit,explicit,entries)
def scheduled_deferred(value:Schedule.Deferred) -> String:
  match value:
    case Schedule.Deferred{systems,options,unapplied}:"systems=" ++ List.show(&2,U32,U32.show,systems) ++ ":settings=" ++ settings(options) ++ ":unapplied=" ++ List.show(&2,U32,U32.show,unapplied)
def left_local(value:Execution.Local) -> String:
  match value:
    case Execution.Local{capture,runs}:"capture=" ++ array_u32(capture) ++ ":runs=" ++ U32.show(runs)
def right_local(~S:Data,value:Execution.ReaderLocal<S>) -> String:
  match value:
    case Execution.ReaderLocal{capture,runs,Notice.Reader{namespace,id,cursor},notices}:"capture=" ++ array_u32(capture) ++ ":runs=" ++ U32.show(runs) ++ ":reader=" ++ U32.show(namespace) ++ ":" ++ U32.show(id) ++ ":" ++ Nat.show(cursor) ++ ":notices=" ++ U32.show(notices)
def left_owner(~S:Data,value:Execution.Left(~S)) -> String:
  match value:
    case Sys.Owner{namespace,id,name,access,cursor,local}:system_header(namespace,id,name,access,cursor) ++ ":" ++ left_local(local)
def right_owner(~S:Data,value:Execution.Right(~S)) -> String:
  match value:
    case Sys.Owner{namespace,id,name,access,cursor,local}:system_header(namespace,id,name,access,cursor) ++ ":" ++ right_local(~S,local)
def basic_owners(~S:Data,value:Product.Owner<Execution.Left(~S),Execution.Right(~S)>) -> String:
  match value:
    case Product.Owner{left,right}:"left=" ++ left_owner(~S,left) ++ "/right=" ++ right_owner(~S,right)
def command_permission(value:Permission.Permission) -> String:
  match value:
    case Permission.FamilyOnly{}:"family-only"
    case Permission.EntityStructural{}:"entity-structural"
def command_entry(~S:Data,value:Buffer.Entry<S,Ordinary.Actor<S>,Removed.Removed(Receiver.Components(~S))>) -> String:
  match value:
    case Buffer.Entry{target,incoming}:"entry(" ++ handle(~S,target) ++ "," ++ maybe_owner(~Ordinary.Actor<S>,~show_actor(~S),incoming) ++ ")"
    case Buffer.Despawn{target}:"despawn(" ++ handle(~S,target) ++ ")"
    case Buffer.Spawn{target,bundle}:"spawn(" ++ handle(~S,target) ++ "," ++ removed_bundle(~S,bundle) ++ ")"
    case Buffer.Relation{chosen,_}:"relation(" ++ route(chosen) ++ ",operation-unreached)"
    case Buffer.LifetimeScope{chosen,_}:"lifetime-scope(" ++ route(chosen) ++ ",operation-unreached)"
def command_buffer(~S:Data,value:Buffer.Buffer<S,Ordinary.Actor<S>,Removed.Removed(Receiver.Components(~S))>) -> String:
  match value:
    case Buffer.Buffer{pending,receipts}:"pending=" ++ List.show(&1,Buffer.Entry<S,Ordinary.Actor<S>,Removed.Removed(Receiver.Components(~S))>,command_entry(~S),pending) ++ ":receipts=" ++ List.show(&1,Buffer.Receipt<S,Ordinary.Actor<S>,Removed.Removed(Receiver.Components(~S))>,buffer_receipt(~S),receipts)
def command_capture(~S:Data,value:Author.Capture<S>) -> String:
  match value:
    case Author.Capture{target,retained,capture,runs}:"target=" ++ handle(~S,target) ++ ":retained=" ++ left_owner(~S,retained) ++ ":capture=" ++ array_u32(capture) ++ ":runs=" ++ U32.show(runs)
def command_local(~S:Data,value:Cmd.Captures(~S,~Receiver.Components(~S),~Plan.layout(Ordinary.resources(~S)),~Author.route(),~Author.Capture<S>)) -> String:
  match value:
    case CommandLocal.Local{user,commands,permission}:"user=" ++ command_capture(~S,user) ++ ":commands=" ++ command_buffer(~S,commands) ++ ":permission=" ++ command_permission(permission)
def command_owner(~S:Data,value:Author.Owner(~S)) -> String:
  match value:
    case Cmd.Owner{Sys.Owner{namespace,id,name,access,cursor,local}}:system_header(namespace,id,name,access,cursor) ++ ":" ++ command_local(~S,local)
def pending_owners(~S:Data,value:Product.Owner<Author.Owner(~S),Execution.Right(~S)>) -> String:
  match value:
    case Product.Owner{left,right}:"author=" ++ command_owner(~S,left) ++ "/right=" ++ right_owner(~S,right)
def reader(~S:Data,value:Notice.Reader<S,Layout.EmptyLayout{},Notice.Despawned{}>) -> String:
  match value:
    case Notice.Reader{namespace,id,cursor}:U32.show(namespace) ++ ":" ++ U32.show(id) ++ ":" ++ Nat.show(cursor)
def reader_refusal(value:Notice.Refusal) -> String:
  match value:
    case Notice.ForeignWorld{}:"foreign-world"
    case Notice.Inactive{}:"inactive"
    case Notice.ReaderLimit{}:"reader-limit"
def handler(value:Execution.Handler) -> String:
  match value:
    case Execution.Handler{capture,handled}:"capture=" ++ array_u32(capture) ++ ":handled=" ++ U32.show(handled)
def scheduled(~S:Data,~Owners:Type,~show:Owners -> String,value:Schedule.Scheduled<App.State<Receiver.World(~S),Owners,Unit,Execution.Handler>>) -> String:
  match value:
    case Schedule.Scheduled{App.State{actualWorld,owners,_,handlerOwner,stateBindings},schedulePlan,appBindings,scheduleRules,deferred}:"world=" ++ world(~S,actualWorld) ++ "/owners=" ++ show(owners) ++ "/guards=unit/handler=" ++ handler(handlerOwner) ++ "/stateBindings=" ++ List.show(&2,App.Binding,binding_app,stateBindings) ++ "/plan=" ++ plan(schedulePlan) ++ "/appBindings=" ++ List.show(&2,App.Binding,binding_app,appBindings) ++ "/rules=" ++ rules(scheduleRules) ++ "/deferred=" ++ scheduled_deferred(deferred)
def setup(~S:Data,value:Setup.Defined<S>) -> String:
  match value:
    case Setup.Defined{app}:"defined(" ++ scheduled(~S,~Product.Owner<Execution.Left(~S),Execution.Right(~S)>,~basic_owners(~S),app) ++ ")"
    case Setup.ReaderRefused{actualWorld,reason}:"reader-refused(" ++ reader_refusal(reason) ++ "," ++ world(~S,actualWorld) ++ ")"
    case Setup.LeftRefused{actualWorld,local,actualReader}:"left-refused(" ++ world(~S,actualWorld) ++ "," ++ left_local(local) ++ "," ++ reader(~S,actualReader) ++ ")"
    case Setup.RightRefused{actualWorld,left,local}:"right-refused(" ++ world(~S,actualWorld) ++ "," ++ left_owner(~S,left) ++ "," ++ right_local(~S,local) ++ ")"
def save_refusal(value:Recipe.Refusal) -> String:
  match value:
    case Recipe.PlainUnserializable{key}:"plain(" ++ key ++ ")"
    case Recipe.InvalidProjection{key,error}:"projection(" ++ key ++ "," ++ decode_error(error) ++ ")"
    case Recipe.MalformedColumn{key}:"column(" ++ key ++ ")"
    case Recipe.DescriptorMismatch{expected,actual}:"descriptor(" ++ expected ++ "," ++ actual ++ ")"
def save_result(~S:Data,value:Gate.Outcome<Saved.Snapshot<S>,Recipe.Refusal>) -> String:
  match value:
    case Gate.Saved{after}:"saved(" ++ snapshot(~S,after) ++ ")"
    case Gate.RefusedPending{}:"refused-pending"
    case Gate.Refused{reason}:"refused(" ++ save_refusal(reason) ++ ")"
def captured(result:Array<U32> & U32) -> String:
  match result:
    case (_,value):U32.show(value)
def after_save(~S:Data,receiptText:String,reportText:String,result:Plan.Schema<S,Ordinary.components(~S),Ordinary.resources(~S)> & (Execution.Application(~S) & Gate.Outcome<Saved.Snapshot<S>,Recipe.Refusal>)) -> String:
  match result:
    case (actualSchema,(current,saved)):"receipt=" ++ receiptText ++ "/report=" ++ reportText ++ "/postSaveSchema=" ++ schema(~S,actualSchema) ++ "/finalSave=" ++ save_result(~S,saved) ++ "/postSaveApplication=" ++ scheduled(~S,~Product.Owner<Execution.Left(~S),Execution.Right(~S)>,~basic_owners(~S),current)
def resumed_receipt(~S:Data,app:Execution.Application(~S),executionReport:App.Report<String,String>,result:Plan.Schema<S,Ordinary.components(~S),Ordinary.resources(~S)> & String) -> String:
  match result:
    case (schema,receiptText):after_save(~S,receiptText,report(executionReport),Execution.save(~S,schema,app))
def retained_receipt(~S:Data,app:Execution.Application(~S),result:Plan.Schema<S,Ordinary.components(~S),Ordinary.resources(~S)> & String) -> String:
  match result:
    case (actualSchema,receiptText):"receipt=" ++ receiptText ++ "/schema=" ++ schema(~S,actualSchema) ++ "/application=" ++ scheduled(~S,~Product.Owner<Execution.Left(~S),Execution.Right(~S)>,~basic_owners(~S),app)
def resumed(~S:Data,result:Execution.Resumed<S>) -> String:
  match result:
    case Execution.Retained{app,receipt}:retained_receipt(~S,app,receipt_for_save(~S,receipt))
    case Execution.Resumed{app,receipt,executionReport}:resumed_receipt(~S,app,executionReport,receipt_for_save(~S,receipt))
