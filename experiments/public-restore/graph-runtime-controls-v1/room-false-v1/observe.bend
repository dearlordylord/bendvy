import ./held.bend as Held
import ./machine-reader.bend as Machine
import ../../../../src/ecs/ordinary-machine-transition-reader.bend as TransitionReader
import ../../../../src/ecs/system-instance.bend as Instance
import ../../../../src/ecs/system-cleanup.bend as Cleanup
import ./locals.bend as Locals
import ./readers.bend as Readers
import ../../../../src/ecs/local.bend as Local
import ../../../../src/ecs/ordinary-app-local-fields.bend as OrdinaryLocal
import ../../../../src/ecs/relation-failure-runtime.bend as K
import ../../../../src/ecs/internal/relation-failures/readings.bend as Readings
import ../../../../src/ecs/deferred-command.bend as Deferred
import ../../../../src/ecs/event-notice-runtime.bend as Mixed
import ../../../../src/ecs/event-family-runtime.bend as Family
import ../../../../src/ecs/event-family-routing.bend as Route
import ../../../../src/ecs/restore-graph-runtime.bend as Runtime
import ../../../../src/ecs/restore-graph-raw-owner.bend as RawOwner
import ../../../../src/ecs/restore-raw.bend as Raw
import ../../../../src/ecs/internal/relation-failures/domains.bend as Domains
import ../../../../src/ecs/internal/relation-failures/queue.bend as FailureQueue
import ../../../../src/ecs/owned-event-log.bend as Log
import ../../basic-world-statefree-v1/model.bend as Model
import ../../basic-world-statefree-v1/events.bend as BaseEvents
import Base
import ../../../../src/ecs/system.bend as Sys
import ./fixture.bend as F
import ../../basic-world-statefree-v1/observe.bend as O
import ../../basic-world-statefree-v1/inspect.bend as Inspect
import ../../basic-world-statefree-v1/schema.bend as Original
import ../../../../src/ecs/world.bend as W
import ../../../../src/ecs/relation-commands.bend as Relation
import ../../../../src/ecs/relation-types.bend as G
import ../../../../src/ecs/relation-failure-reader.bend as Decl
import ../../../../src/ecs/ordinary-machine-initialization.bend as Init
import ../../../../src/ecs/machine.bend as M
import ../../../../src/ecs/machine-stream.bend as St
import ../../../../src/ecs/machine-stream-queue.bend as Queue
import ../../../../src/ecs/event-runtime.bend as Ev
import ../../../../src/ecs/owner-product.bend as Product
import ../../../../src/ecs/restore-graph-public.bend as Public
import ../../../../src/ecs/restore-public.bend as Basic
import ../../../../src/ecs/restore-graph-data.bend as Data
import ../../../../src/ecs/restore-schema.bend as RestoreSchema
import ../../../../src/ecs/ordinary-schema.bend as Ordinary
import ../../../../src/ecs/schema-fragments.bend as Fragment
import ../../../../src/ecs/restore-data.bend as R
import ../../../../src/ecs/decode-data.bend as D
import ../../../../src/ecs/entity-allocator.bend as Alloc
import ../../../../src/ecs/entity-key.bend as Key

def kind(value:G.RelationKind) -> String:
  match value:
    case G.Ordinary{}:"Ordinary"
    case G.Hierarchy{}:"Hierarchy"
def descriptor(~S:Data,value:G.Descriptor<S>) -> String:
  match value:
    case G.Descriptor{key,name,inverse,k}:"Descriptor{" ++ U32.show(key) ++ ";" ++ name ++ ";inverse=" ++ inverse ++ ";kind=" ++ kind(k) ++ "}"
def edge(~S:Data,value:G.Edge<S>) -> String:
  match value:
    case G.Edge{relation,source,target}:"Edge{" ++ descriptor(~S,relation) ++ ";source=" ++ O.key(source) ++ ";target=" ++ O.key(target) ++ "}"
def inverse(~S:Data,value:G.Inverse<S>) -> String:
  match value:
    case G.Inverse{relation,target,sources}:"Inverse{" ++ descriptor(~S,relation) ++ ";target=" ++ O.key(target) ++ ";sources=" ++ List.show(&2,Key.Key,O.key,sources) ++ "}"
def graph(~S:Data,value:G.Graph<S>) -> String:
  match value:
    case G.Graph{edges,inverses}:"Graph{edges=" ++ List.show(&2,G.Edge<S>,edge(~S),edges) ++ ";inverses=" ++ List.show(&2,G.Inverse<S>,inverse(~S),inverses) ++ "}"
def relation_error(value:G.Error) -> String:
  match value:
    case G.MissingEntity{source}:"MissingEntity{" ++ O.key(source) ++ "}"
    case G.MissingTargetEntity{source,target,relation}:"MissingTargetEntity{" ++ O.key(source) ++ ";" ++ O.key(target) ++ ";" ++ relation ++ "}"
    case G.SelfRelationNotAllowed{source,relation}:"SelfRelationNotAllowed{" ++ O.key(source) ++ ";" ++ relation ++ "}"
    case G.HierarchyCycle{source,target,relation}:"HierarchyCycle{" ++ O.key(source) ++ ";" ++ O.key(target) ++ ";" ++ relation ++ "}"
    case G.MissingChildEntity{source,child,relation}:"MissingChildEntity{" ++ O.key(source) ++ ";" ++ O.key(child) ++ ";" ++ relation ++ "}"
    case G.DuplicateChild{source,child,relation}:"DuplicateChild{" ++ O.key(source) ++ ";" ++ O.key(child) ++ ";" ++ relation ++ "}"
    case G.ChildNotRelatedToParent{source,child,relation}:"ChildNotRelatedToParent{" ++ O.key(source) ++ ";" ++ O.key(child) ++ ";" ++ relation ++ "}"
    case G.ChildSetMismatch{source,relation}:"ChildSetMismatch{" ++ O.key(source) ++ ";" ++ relation ++ "}"
def operation(value:G.Operation) -> String:
  match value:
    case G.Relate{}:"Relate"
    case G.ReorderChildren{}:"ReorderChildren"
def failure(~S:Data,value:G.Failure<S>) -> String:
  match value:
    case G.Failure{relation,op,source,target,error}:"Failure{" ++ descriptor(~S,relation) ++ ";operation=" ++ operation(op) ++ ";source=" ++ O.key(source) ++ ";target=" ++ O.key(target) ++ ";error=" ++ relation_error(error) ++ "}"
def frame(~S:Data,value:G.CleanupFrame<S>) -> String:
  match value:
    case G.CleanupEnter{id}:"Enter{" ++ O.key(id) ++ "}"
    case G.CleanupDescriptors{id,remaining}:"Descriptors{" ++ O.key(id) ++ ";" ++ List.show(&2,G.Descriptor<S>,descriptor(~S),remaining) ++ "}"
    case G.CleanupChildren{id,desc,remaining,children}:"Children{" ++ O.key(id) ++ ";" ++ descriptor(~S,desc) ++ ";" ++ List.show(&2,G.Descriptor<S>,descriptor(~S),remaining) ++ ";" ++ List.show(&2,Key.Key,O.key,children) ++ "}"
    case G.CleanupFinish{id}:"Finish{" ++ O.key(id) ++ "}"
def notice(~S:Data,value:F.Events(~S)) -> String:
  match value:
    case Relation.Original{event}:"Original{" ++ O.event(~S,event) ++ "}"
    case Relation.RelationFailed{value}:"RelationFailed{" ++ failure(~S,value) ++ "}"
    case Relation.ComponentRemoved{id}:"ComponentRemoved{" ++ O.key(id) ++ "}"
    case Relation.CleanupPaused{frames}:"CleanupPaused{" ++ List.show(&2,G.CleanupFrame<S>,frame(~S),frames) ++ "}"
def maybe_u32(value:Maybe<&2,U32>) -> String:
  match value:
    case None{}:"None"
    case Some{value}:"Some{" ++ U32.show(value) ++ "}"
def pending(value:M.Pending<U32>) -> String:
  match value:
    case M.NoPending{}:"NoPending"
    case M.Queued{value,same}:"Queued{" ++ U32.show(value) ++ ";skipSame=" ++ Bool.show(same) ++ "}"
def slot(~S:Data,~K:Data,value:M.Slot<S,K,U32>) -> String:
  match value:
    case M.Missing{}:"Missing"
    case M.Present{current,next,previous,changed}:"Present{current=" ++ U32.show(current) ++ ";pending=" ++ pending(next) ++ ";previous=" ++ maybe_u32(previous) ++ ";changed=" ++ Bool.show(changed) ++ "}"
def transition(value:M.Transition<U32>) -> String:
  match value:
    case M.Initial{to}:"Initial{" ++ U32.show(to) ++ "}"
    case M.Transition{from,to}:"Transition{" ++ U32.show(from) ++ ";" ++ U32.show(to) ++ "}"
def batch(value:Queue.Batch<M.Transition<U32>>) -> String:
  match value:
    case Queue.Batch{tick,count,values}:"Batch{tick=" ++ Nat.show(tick) ++ ";count=" ++ Nat.show(count) ++ ";values=" ++ List.show(&2,M.Transition<U32>,transition,values) ++ "}"
def queue(value:Queue.Queue<M.Transition<U32>>) -> String:
  match value:
    case Queue.Queue{front,back,size,dropped,count}:"Queue{front=" ++ List.show(&2,Queue.Batch<M.Transition<U32>>,batch,front) ++ ";back=" ++ List.show(&2,Queue.Batch<M.Transition<U32>>,batch,back) ++ ";size=" ++ Nat.show(size) ++ ";dropped=" ++ Nat.show(dropped) ++ ";batchCount=" ++ Nat.show(count) ++ "}"
def position(value:Ev.Position) -> String:
  match value:
    case Ev.Position{id,cursor,registered}:"Position{" ++ U32.show(id) ++ ";cursor=" ++ Nat.show(cursor) ++ ";registeredAt=" ++ Nat.show(registered) ++ "}"
def stream(value:St.Stream<U32>) -> String:
  match value:
    case St.Stream{q,positions,start}:"Stream{" ++ queue(q) ++ ";positions=" ++ List.show(&2,Ev.Position,position,positions) ++ ";frameStart=" ++ Nat.show(start) ++ "}"
def machine_text(~S:Data,~K:Data,value:Init.State<S,K,U32>) -> String:
  match value:
    case Init.State{value,events,revision}:"State{slot=" ++ slot(~S,~K,value) ++ ";stream=" ++ stream(events) ++ ";revision=" ++ Nat.show(revision) ++ "}"
def machine(~S:Data,~K:Data,value:Init.State<S,K,U32>) -> Init.State<S,K,U32> & String:
  match value:
    case Init.State{+current,+events,+revision}:(Init.State{current,events,revision},machine_text(~S,~K,Init.State{current,events,revision}))
def user_resources(~S:Data,value:F.UserResources(~S)) -> F.UserResources(~S) & String:O.resources(~S,value)
def resources(~S:Data,value:F.Resources(~S)) -> F.Resources(~S) & String:
  O.product(~F.UserResources(~S),~F.Machines(~S),~user_resources(~S),~O.product(~Init.State<S,F.Mode,U32>,~Init.State<S,F.Weather,U32>,~machine(~S,~F.Mode),~machine(~S,~F.Weather)),value)
def store_join(~S:Data,+value:G.Graph<S>,observed:F.Components(~S) & String) -> F.Store(~S) & String:
  (components,text)=observed
  (Relation.Store{components,value},"Store{components=" ++ text ++ ";graph=" ++ graph(~S,value) ++ "}")
def store(~S:Data,value:F.Store(~S)) -> F.Store(~S) & String:
  match value:
    case Relation.Store{components,graph}:store_join(~S,graph,O.store(~S,components))
def command(~S:Data,value:Deferred.Command<F.World(~S)>) -> Deferred.Command<F.World(~S)> & String:
  match value:
    case Deferred.Raw{apply}:(Deferred.Raw{apply},"Raw{apply=opaque}")
    case Deferred.Observed{apply}:(Deferred.Observed{apply},"Observed{apply=opaque}")
def world_join(~S:Data,+ns:U32,+events:List<&2,F.Events(~S)>,+regs:List<&2,W.RegistrationMeta>,+sid:U32,+clock:U32,a:Alloc.Allocator & String,c:F.Store(~S) & String,r:F.Resources(~S) & String,p:List<Deferred.Command<F.World(~S)>> & String) -> F.World(~S) & String:
  (a,at)=a
  (c,ct)=c
  (r,rt)=r
  (p,pt)=p
  (W.World{ns,a,c,r,events,p,regs,sid,clock},"World{namespace=" ++ U32.show(ns) ++ ";allocator={" ++ at ++ "};store=" ++ ct ++ ";resources=" ++ rt ++ ";events=" ++ List.show(&2,F.Events(~S),notice(~S),events) ++ ";pending=" ++ pt ++ ";registrations=" ++ List.show(&2,W.RegistrationMeta,O.registration,regs) ++ ";nextSystem=" ++ U32.show(sid) ++ ";clock=" ++ U32.show(clock) ++ "}")
def world(~S:Data,value:F.World(~S)) -> F.World(~S) & String:
  match value:
    case W.World{ns,a,c,r,e,p,regs,sid,clock}:world_join(~S,ns,e,regs,sid,clock,O.allocator(a),store(~S,c),resources(~S,r),O.owners(~Deferred.Command<F.World(~S)>,~command(~S),p))
def state(~S:Data,value:F.State(~S)) -> F.State(~S) & String:O.state(~S,value)
def recovery(~S:Data,value:F.Recovery(~S)) -> F.Recovery(~S) & String:O.recovery(~S,value)
def declaration(~S:Data,value:Decl.Declaration<S>) -> String:
  match value:
    case Decl.Declaration{desc}:descriptor(~S,desc)
def owner_join(~S:Data,+schema:F.Schema(~S),+relations:List<&2,Decl.Declaration<S>>,+machines:F.MachineSchema(~S),observed:F.State(~S) & String) -> F.Owned(~S) & String:
  match schema observed:
    case RestoreSchema.Schema{Ordinary.Schema{+entries}}, (value,text):(Public.Owner{Basic.Owner{RestoreSchema.Schema{Ordinary.Schema{entries}},value},relations,machines},"Owner{schema=" ++ List.show(&2,Fragment.Entry<S>,O.schema_entry(~S),entries) ++ ";relations=" ++ List.show(&2,Decl.Declaration<S>,declaration(~S),relations) ++ ";machines=Schema{};state=" ++ text ++ "}")
def owner(~S:Data,value:F.Owned(~S)) -> F.Owned(~S) & String:
  match value:
    case Public.Owner{Basic.Owner{schema,value},relations,machines}:owner_join(~S,schema,relations,machines,state(~S,value))
def field(value:D.Field) -> String:
  match value:
    case D.Field{name,value}:name ++ ":" ++ O.raw(value)
def group(value:Data.Group) -> String:
  match value:
    case Data.Group{target,sources}:"Group{target=" ++ O.key(target) ++ ";sources=" ++ List.show(&2,Key.Key,O.key,sources) ++ "}"
def relation(value:Data.Relation) -> String:
  match value:
    case Data.Relation{name,groups}:"Relation{" ++ name ++ ";groups=" ++ List.show(&2,Data.Group,group,groups) ++ "}"
def snapshot(value:Data.Snapshot) -> String:
  match value:
    case Data.Snapshot{basic,relations,machines}:"Snapshot{basic=" ++ O.snapshot(basic) ++ ";relations=" ++ List.show(&2,Data.Relation,relation,relations) ++ ";machines=" ++ List.show(&2,D.Field,field,machines) ++ "}"
def graph_error(value:Data.Error) -> String:
  match value:
    case Data.UnknownRelation{name}:"UnknownRelation{" ++ name ++ "}"
    case Data.InvalidRelation{name,source,target}:"InvalidRelation{" ++ name ++ ";" ++ O.key(source) ++ ";" ++ O.key(target) ++ "}"
    case Data.UnknownMachine{name}:"UnknownMachine{" ++ name ++ "}"
    case Data.InvalidMachineState{name,value}:"InvalidMachineState{" ++ name ++ ";" ++ O.raw(value) ++ "}"
def error(value:Public.Error<String>) -> String:
  match value:
    case Public.BasicError{value}:"BasicError{" ++ Inspect.error(value) ++ "}"
    case Public.GraphError{value}:"GraphError{" ++ graph_error(value) ++ "}"def failure_batch(~S:Data,value:FailureQueue.Batch<F.Events(~S)>) -> String:
  match value:
    case FailureQueue.Batch{tick,count,values}:"Batch{tick=" ++ Nat.show(tick) ++ ";count=" ++ Nat.show(count) ++ ";values=" ++ List.show(&2,F.Events(~S),notice(~S),values) ++ "}"
def failure_queue(~S:Data,value:FailureQueue.Queue<F.Events(~S)>) -> String:
  match value:
    case FailureQueue.Queue{front,back,size,dropped}:"Queue{front=" ++ List.show(&2,FailureQueue.Batch<F.Events(~S)>,failure_batch(~S),front) ++ ";back=" ++ List.show(&2,FailureQueue.Batch<F.Events(~S)>,failure_batch(~S),back) ++ ";size=" ++ Nat.show(size) ++ ";dropped=" ++ Nat.show(dropped) ++ "}"
def domain_key(~S:Data,value:Domains.DescriptorKey<S>) -> String:
  match value:
    case Domains.DeclaredKey{id}:U32.show(id)
def failure_domain(~S:Data,value:Domains.Domain<S,F.Events(~S)>) -> String:
  match value:
    case Domains.Domain{key,q,readers}:"Domain{key=" ++ domain_key(~S,key) ++ ";queue=" ++ failure_queue(~S,q) ++ ";readers=" ++ List.show(&2,U32,U32.show,readers) ++ "}"
def failures(~S:Data,value:Mixed.Failures<S,Model.Events(~S)>) -> String:
  match value:
    case Mixed.Failures{domains,positions,tick,start,boundary,capacity,next}:"Failures{domains=" ++ List.show(&2,Domains.Domain<S,F.Events(~S)>,failure_domain(~S),domains) ++ ";positions=" ++ List.show(&2,Ev.Position,position,positions) ++ ";tick=" ++ Nat.show(tick) ++ ";frameStart=" ++ Nat.show(start) ++ ";boundary=" ++ Nat.show(boundary) ++ ";capacity=" ++ Nat.show(capacity) ++ ";nextReader=" ++ U32.show(next) ++ "}"
def typed(~S:Data,value:Family.State<Model.Events(~S),BaseEvents.FamilyOwner(~S),Array<U32>>) -> Family.State<Model.Events(~S),BaseEvents.FamilyOwner(~S),Array<U32>> & String:
  O.family_state(~S,~BaseEvents.FamilyOwner(~S),~Array<U32>,~Inspect.family(~S),~O.u32_array,value)
def mixed_join(~S:Data,+failure:Mixed.Failures<S,Model.Events(~S)>,observed:Family.State<Model.Events(~S),BaseEvents.FamilyOwner(~S),Array<U32>> & String) -> Mixed.State<S,Model.Events(~S),BaseEvents.FamilyOwner(~S),Array<U32>> & String:
  (state,text)=observed
  (Mixed.State{state,failure},"Mixed{typed=" ++ text ++ ";failures=" ++ failures(~S,failure) ++ "}")
def mixed(~S:Data,value:Mixed.State<S,Model.Events(~S),BaseEvents.FamilyOwner(~S),Array<U32>>) -> Mixed.State<S,Model.Events(~S),BaseEvents.FamilyOwner(~S),Array<U32>> & String:
  match value:
    case Mixed.State{state,failure}:mixed_join(~S,failure,typed(~S,state))
def runtime_join(~S:Data,+tick:Nat,w:F.World(~S) & String,f:Mixed.State<S,Model.Events(~S),BaseEvents.FamilyOwner(~S),Array<U32>> & String) -> F.RuntimeType(~S) & String:
  (world,wt)=w
  (family,ft)=f
  (Route.Runtime{world,family,tick},"Runtime{world=" ++ wt ++ ";family=" ++ ft ++ ";tick=" ++ Nat.show(tick) ++ "}")
def runtime(~S:Data,value:F.RuntimeType(~S)) -> F.RuntimeType(~S) & String:
  match value:
    case Route.Runtime{current,family,tick}:runtime_join(~S,tick,world(~S,current),mixed(~S,family))
def receipt(value:F.Receipt()) -> F.Receipt() & String:
  O.product(~List<Log.Row<Array<U32>>>,~Unit,~O.owners(~Log.Row<Array<U32>>,~O.log_row),~O.unit,value)
def outcome(~S:Data,value:Runtime.Outcome<S,String>) -> String:
  match value:
    case Runtime.Restored{bindings}:"Restored{bindings=" ++ List.show(&2,R.Binding<S>,Inspect.binding(~S),bindings) ++ "}"
    case Runtime.Rejected{input,reason}:"Rejected{input=" ++ snapshot(input) ++ ";error=" ++ error(reason) ++ "}"
    case Runtime.MissingBinding{saved}:"MissingBinding{saved=" ++ O.key(saved) ++ "}"
def returned_join(~S:Data,+result:Runtime.Outcome<S,String>,r:F.RuntimeType(~S) & String,o:F.Owned(~S) & String,v:F.Recovery(~S) & String,d:Maybe<&1,F.Receipt()> & String) -> F.RuntimeReturned(~S) & String:
  (runtime,rt)=r
  (owner,ot)=o
  (recovery,vt)=v
  (receipt,dt)=d
  (Runtime.Returned{runtime,owner,recovery,receipt,result},"Returned{runtime=" ++ rt ++ ";owner=" ++ ot ++ ";recovery=" ++ vt ++ ";receipt=" ++ dt ++ ";outcome=" ++ outcome(~S,result) ++ "}")
def returned(~S:Data,value:F.RuntimeReturned(~S)) -> F.RuntimeReturned(~S) & String:
  match value:
    case Runtime.Returned{r,o,v,d,result}:returned_join(~S,result,runtime(~S,r),owner(~S,o),recovery(~S,v),O.optional(~F.Receipt(),~receipt,d))
def raw_error(value:Raw.Error) -> String:
  match value:
    case Raw.Invalid{error}:"Invalid{" ++ Inspect.decode_error(error) ++ "}"
    case Raw.UnsupportedVersion{version}:"UnsupportedVersion{" ++ O.raw(version) ++ "}"
def parse_rejected_join(~S:Data,+original:D.Raw,+reason:Raw.Error,o:F.Owned(~S) & String,r:F.RuntimeType(~S) & String) -> F.RawReturned(~S) & String:
  (owner,ot)=o
  (runtime,rt)=r
  (RawOwner.ParseRejected{owner,runtime,original,reason},"ParseRejected{owner=" ++ ot ++ ";runtime=" ++ rt ++ ";original=" ++ O.raw(original) ++ ";error=" ++ raw_error(reason) ++ "}")
def delivered_join(~S:Data,+original:D.Raw,observed:F.RuntimeReturned(~S) & String) -> F.RawReturned(~S) & String:
  (output,text)=observed
  (RawOwner.Delivered{original,output},"Delivered{original=" ++ O.raw(original) ++ ";output=" ++ text ++ "}")
def raw_returned(~S:Data,value:F.RawReturned(~S)) -> F.RawReturned(~S) & String:
  match value:
    case RawOwner.ParseRejected{o,r,original,reason}:parse_rejected_join(~S,original,reason,owner(~S,o),runtime(~S,r))
    case RawOwner.Delivered{original,output}:delivered_join(~S,original,returned(~S,output))
def local_join(~S:Data,+ns:U32,+id:U32,+name:String,+access:List<&2,String>,observed:Locals.Capture() & String) -> Locals.Owned(~S) & String:
  (capture,text)=observed
  (OrdinaryLocal.Owner{Local.Instance{ns,id,name,access,capture}},"Local{namespace=" ++ U32.show(ns) ++ ";id=" ++ U32.show(id) ++ ";name=" ++ name ++ ";access=" ++ List.show(&2,String,x=>x,access) ++ ";capture=" ++ text ++ "}")
def local(~S:Data,value:Locals.Owned(~S)) -> Locals.Owned(~S) & String:
  match value:
    case OrdinaryLocal.Owner{Local.Instance{ns,id,name,access,capture}}:local_join(~S,ns,id,name,access,O.product(~Array<U32>,~Array<U32>,~O.u32_array,~O.u32_array,capture))
def registry(~S:Data,~Args:Type,~Error:Data,~Out:Type,~runner:F.World(~S) -> Args -> Sys.Outcome<F.World(~S),Error,Out>,value:Sys.Registry<S,F.Store(~S),F.Resources(~S),F.Events(~S),Args,Error,Out,runner>) -> Sys.Registry<S,F.Store(~S),F.Resources(~S),F.Events(~S),Args,Error,Out,runner> & String:
  match value:
    case Sys.Registry{+ns,+id,+name,+access,+cursor}:(Sys.Registry{ns,id,name,access,cursor},"Registry{namespace=" ++ U32.show(ns) ++ ";id=" ++ U32.show(id) ++ ";name=" ++ name ++ ";access=" ++ List.show(&2,String,x=>x,access) ++ ";cursor=" ++ U32.show(cursor) ++ "}")
def lifecycle_registry(~S:Data,value:Readers.Registry(~S)) -> Readers.Registry(~S) & String:
  registry(~S,~Ev.Input<R.Change<S>,Array<U32>>,~Unit,~Ev.Input<R.Change<S>,Array<U32>>,~Readers.callback(~S),value)
def lifecycle_reader(~S:Data,value:Readers.Reader(~S)) -> Readers.Reader(~S) & String:
  O.reader(~S,~R.Change<S>,~Readers.FamilyState(~S),~Readers.take(~S),~Readers.put(~S),value)
def lifecycle_input_join(~S:Data,+values:List<&2,R.Change<S>>,+lagged:Bool,observed:Array<U32> & String) -> Ev.Input<R.Change<S>,Array<U32>> & String:
  (args,text)=observed
  (Ev.Input{values,lagged,args},"Input{values=" ++ List.show(&2,R.Change<S>,O.change(~S),values) ++ ";lagged=" ++ Bool.show(lagged) ++ ";args=" ++ text ++ "}")
def lifecycle_input(~S:Data,value:Ev.Input<R.Change<S>,Array<U32>>) -> Ev.Input<R.Change<S>,Array<U32>> & String:
  match value:
    case Ev.Input{values,lagged,args}:lifecycle_input_join(~S,values,lagged,O.u32_array(args))
def lifecycle_success_join(~S:Data,observed:Ev.Input<R.Change<S>,Array<U32>> & String) -> Ev.Completion<Unit,Ev.Input<R.Change<S>,Array<U32>>,Array<U32>> & String:
  (output,text)=observed
  (Ev.Succeeded{output},"Succeeded{" ++ text ++ "}")
def lifecycle_rejected_join(~S:Data,observed:Array<U32> & String) -> Ev.Completion<Unit,Ev.Input<R.Change<S>,Array<U32>>,Array<U32>> & String:
  (args,text)=observed
  (Ev.Rejected{args},"Rejected{args=" ++ text ++ "}")
def lifecycle_completion(~S:Data,value:Ev.Completion<Unit,Ev.Input<R.Change<S>,Array<U32>>,Array<U32>>) -> Ev.Completion<Unit,Ev.Input<R.Change<S>,Array<U32>>,Array<U32>> & String:
  match value:
    case Ev.Succeeded{output}:lifecycle_success_join(~S,lifecycle_input(~S,output))
    case Ev.Failed{error}:(Ev.Failed{error},"Failed{error=Unit}")
    case Ev.Rejected{args}:lifecycle_rejected_join(~S,O.u32_array(args))
def lifecycle_returned_join(~S:Data,rt:F.RuntimeType(~S) & String,rd:Readers.Reader(~S) & String,rg:Readers.Registry(~S) & String,cp:Ev.Completion<Unit,Ev.Input<R.Change<S>,Array<U32>>,Array<U32>> & String) -> Readers.Returned(~S) & String:
  (runtime,rtt)=rt
  (reader,rdt)=rd
  (registry,rgt)=rg
  (completion,cpt)=cp
  (Route.Ran{runtime,reader,registry,completion},"LifecycleRan{runtime=" ++ rtt ++ ";reader=" ++ rdt ++ ";registry=" ++ rgt ++ ";completion=" ++ cpt ++ "}")
def lifecycle_returned(~S:Data,value:Readers.Returned(~S)) -> Readers.Returned(~S) & String:
  match value:
    case Route.Ran{rt,rd,rg,cp}:lifecycle_returned_join(~S,runtime(~S,rt),lifecycle_reader(~S,rd),lifecycle_registry(~S,rg),lifecycle_completion(~S,cp))
def failure_registry(~S:Data,value:Sys.Registry<S,F.Store(~S),F.Resources(~S),F.Events(~S),K.Input<S,F.Events(~S),Array<U32>>,Unit,K.Input<S,F.Events(~S),Array<U32>>,Readers.failure_callback(~S)>) -> Sys.Registry<S,F.Store(~S),F.Resources(~S),F.Events(~S),K.Input<S,F.Events(~S),Array<U32>>,Unit,K.Input<S,F.Events(~S),Array<U32>>,Readers.failure_callback(~S)> & String:
  registry(~S,~K.Input<S,F.Events(~S),Array<U32>>,~Unit,~K.Input<S,F.Events(~S),Array<U32>>,~Readers.failure_callback(~S),value)
def failure_reader_join(~S:Data,+keys:List<&2,Domains.DescriptorKey<S>>,+id:U32,observed:Sys.Registry<S,F.Store(~S),F.Resources(~S),F.Events(~S),K.Input<S,F.Events(~S),Array<U32>>,Unit,K.Input<S,F.Events(~S),Array<U32>>,Readers.failure_callback(~S)> & String) -> Readers.FailureReader(~S) & String:
  (registry,text)=observed
  (K.Reader{registry,keys,id},"FailureReader{registry=" ++ text ++ ";keys=" ++ List.show(&2,Domains.DescriptorKey<S>,domain_key(~S),keys) ++ ";id=" ++ U32.show(id) ++ "}")
def failure_reader(~S:Data,value:Readers.FailureReader(~S)) -> Readers.FailureReader(~S) & String:
  match value:
    case K.Reader{registry,keys,id}:failure_reader_join(~S,keys,id,failure_registry(~S,registry))
def key_reading(~S:Data,value:Readings.KeyReading<S,F.Events(~S)>) -> String:
  match value:
    case Readings.KeyReading{key,values,lagged}:"KeyReading{key=" ++ domain_key(~S,key) ++ ";values=" ++ List.show(&2,F.Events(~S),notice(~S),values) ++ ";lagged=" ++ Bool.show(lagged) ++ "}"
def failure_input_join(~S:Data,+readings:List<&2,Readings.KeyReading<S,F.Events(~S)>>,observed:Array<U32> & String) -> K.Input<S,F.Events(~S),Array<U32>> & String:
  (args,text)=observed
  (K.Input{readings,args},"Input{readings=" ++ List.show(&2,Readings.KeyReading<S,F.Events(~S)>,key_reading(~S),readings) ++ ";args=" ++ text ++ "}")
def failure_input(~S:Data,value:K.Input<S,F.Events(~S),Array<U32>>) -> K.Input<S,F.Events(~S),Array<U32>> & String:
  match value:
    case K.Input{readings,args}:failure_input_join(~S,readings,O.u32_array(args))
def failure_success_join(~S:Data,observed:K.Input<S,F.Events(~S),Array<U32>> & String) -> K.Completion<Unit,K.Input<S,F.Events(~S),Array<U32>>,Array<U32>> & String:
  (output,text)=observed
  (K.Succeeded{output},"Succeeded{" ++ text ++ "}")
def failure_rejected_join(~S:Data,observed:Array<U32> & String) -> K.Completion<Unit,K.Input<S,F.Events(~S),Array<U32>>,Array<U32>> & String:
  (args,text)=observed
  (K.Rejected{args},"Rejected{args=" ++ text ++ "}")
def failure_completion(~S:Data,value:K.Completion<Unit,K.Input<S,F.Events(~S),Array<U32>>,Array<U32>>) -> K.Completion<Unit,K.Input<S,F.Events(~S),Array<U32>>,Array<U32>> & String:
  match value:
    case K.Succeeded{output}:failure_success_join(~S,failure_input(~S,output))
    case K.Failed{error}:(K.Failed{error},"Failed{error=Unit}")
    case K.Rejected{args}:failure_rejected_join(~S,O.u32_array(args))
def failure_runtime_join(~S:Data,+domains:List<&2,Domains.Domain<S,F.Events(~S)>>,+positions:List<&2,Ev.Position>,+tick:Nat,+start:Nat,+boundary:Nat,+capacity:Nat,+next:U32,observed:F.World(~S) & String) -> K.Runtime<S,F.Store(~S),F.Resources(~S),F.Events(~S)> & String:
  (world,text)=observed
  (K.Runtime{world,domains,positions,tick,start,boundary,capacity,next},"FailureRuntime{world=" ++ text ++ ";state=" ++ failures(~S,Mixed.Failures{domains,positions,tick,start,boundary,capacity,next}) ++ "}")
def failure_runtime(~S:Data,value:K.Runtime<S,F.Store(~S),F.Resources(~S),F.Events(~S)>) -> K.Runtime<S,F.Store(~S),F.Resources(~S),F.Events(~S)> & String:
  match value:
    case K.Runtime{current,domains,positions,tick,start,boundary,capacity,next}:failure_runtime_join(~S,domains,positions,tick,start,boundary,capacity,next,world(~S,current))
def failure_returned_join(~S:Data,rt:K.Runtime<S,F.Store(~S),F.Resources(~S),F.Events(~S)> & String,rd:Readers.FailureReader(~S) & String,cp:K.Completion<Unit,K.Input<S,F.Events(~S),Array<U32>>,Array<U32>> & String) -> Readers.FailureReturned(~S) & String:
  (runtime,rtt)=rt
  (reader,rdt)=rd
  (completion,cpt)=cp
  (K.Ran{runtime,reader,completion},"FailureRan{runtime=" ++ rtt ++ ";reader=" ++ rdt ++ ";completion=" ++ cpt ++ "}")
def failure_returned(~S:Data,value:Readers.FailureReturned(~S)) -> Readers.FailureReturned(~S) & String:
  match value:
    case K.Ran{rt,rd,cp}:failure_returned_join(~S,failure_runtime(~S,rt),failure_reader(~S,rd),failure_completion(~S,cp))

def machine_reader(~S:Data,value:Machine.Owned(~S)) -> Machine.Owned(~S) & String:
  match value:
    case Instance.Instance{Cleanup.Instance{Sys.Registry{+ns,+id,+name,+access,+cursor},St.Reader{+rns,+rid}}}:(Instance.Instance{Cleanup.Instance{Sys.Registry{ns,id,name,access,cursor},St.Reader{rns,rid}}},"Reader{namespace=" ++ U32.show(ns) ++ ";id=" ++ U32.show(id) ++ ";name=" ++ name ++ ";access=" ++ List.show(&2,String,x=>x,access) ++ ";cursor=" ++ U32.show(cursor) ++ ";portNamespace=" ++ U32.show(rns) ++ ";portId=" ++ U32.show(rid) ++ "}")
def machine_reading(value:Ev.Reading<M.Transition<U32>>) -> String:
  match value:
    case Ev.Reading{values,lagged}:"Reading{values=" ++ List.show(&2,M.Transition<U32>,transition,values) ++ ";lagged=" ++ Bool.show(lagged) ++ "}"
def machine_read_succeeded(~S:Data,+observed:Ev.Reading<M.Transition<U32>>,w:F.World(~S) & String,r:Machine.Owned(~S) & String,a:Array<U32> & String) -> Machine.Returned(~S) & String:
  (world,wt)=w
  (reader,rt)=r
  (output,at)=a
  (TransitionReader.ReadSucceeded{world,reader,output,observed},"ReadSucceeded{world=" ++ wt ++ ";reader=" ++ rt ++ ";output=" ++ at ++ ";reading=" ++ machine_reading(observed) ++ "}")
def machine_read_failed(~S:Data,+reason:Unit,+observed:Ev.Reading<M.Transition<U32>>,w:F.World(~S) & String,r:Machine.Owned(~S) & String) -> Machine.Returned(~S) & String:
  (world,wt)=w
  (reader,rt)=r
  (TransitionReader.ReadFailed{world,reader,reason,observed},"ReadFailed{world=" ++ wt ++ ";reader=" ++ rt ++ ";error=Unit;reading=" ++ machine_reading(observed) ++ "}")
def machine_read_rejected(~S:Data,w:F.World(~S) & String,r:Machine.Owned(~S) & String,a:Array<U32> & String) -> Machine.Returned(~S) & String:
  (world,wt)=w
  (reader,rt)=r
  (args,at)=a
  (TransitionReader.ReadRejected{world,reader,args},"ReadRejected{world=" ++ wt ++ ";reader=" ++ rt ++ ";args=" ++ at ++ "}")
def machine_returned(~S:Data,value:Machine.Returned(~S)) -> Machine.Returned(~S) & String:
  match value:
    case TransitionReader.ReadSucceeded{w,r,output,observed}:machine_read_succeeded(~S,observed,world(~S,w),machine_reader(~S,r),O.u32_array(output))
    case TransitionReader.ReadFailed{w,r,reason,observed}:machine_read_failed(~S,reason,observed,world(~S,w),machine_reader(~S,r))
    case TransitionReader.ReadRejected{w,r,args}:machine_read_rejected(~S,world(~S,w),machine_reader(~S,r),O.u32_array(args))
def held_join(~S:Data,+foreignHandle:W.Handle<S>,+handles:List<&2,W.Handle<S>>,lo:Locals.Owned(~S) & String,rd:Readers.Reader(~S) & String,rg:Readers.Registry(~S) & String,fr:Readers.FailureReader(~S) & String,mr:Machine.Owned(~S) & String,a:Array<U32> & String,fa:Array<U32> & String,ma:Array<U32> & String,se:Array<U32> & String,fo:F.World(~S) & String) -> Held.Owners<S> & String:
  (local,lot)=lo
  (reader,rdt)=rd
  (registry,rgt)=rg
  (failures,frt)=fr
  (machine,mrt)=mr
  (args,at)=a
  (failureArgs,fat)=fa
  (machineArgs,mat)=ma
  (service,set)=se
  (foreign,fot)=fo
  (Held.Owners{local,reader,registry,failures,machine,args,failureArgs,machineArgs,service,foreign,foreignHandle,handles},"Held{local=" ++ lot ++ ";reader=" ++ rdt ++ ";registry=" ++ rgt ++ ";failures=" ++ frt ++ ";machine=" ++ mrt ++ ";args=" ++ at ++ ";failureArgs=" ++ fat ++ ";machineArgs=" ++ mat ++ ";service=" ++ set ++ ";foreign=" ++ fot ++ ";foreignHandle=" ++ O.handle(~S,foreignHandle) ++ ";handles=" ++ List.show(&2,W.Handle<S>,O.handle(~S),handles) ++ "}")
def held(~S:Data,value:Held.Owners<S>) -> Held.Owners<S> & String:
  match value:
    case Held.Owners{lo,rd,rg,fr,mr,a,fa,ma,se,fo,fh,hs}:held_join(~S,fh,hs,local(~S,lo),lifecycle_reader(~S,rd),lifecycle_registry(~S,rg),failure_reader(~S,fr),machine_reader(~S,mr),O.u32_array(a),O.u32_array(fa),O.u32_array(ma),O.u32_array(se),world(~S,fo))
def local_result(value:Result<&2,&1,Unit,U32>) -> Result<&2,&1,Unit,U32> & String:
  match value:
    case Done{+value}:(Done{value},"Done{" ++ U32.show(value) ++ "}")
    case Fail{+error}:(Fail{error},"Fail{Unit}")
def local_completed_join(~S:Data,r:Result<&2,&1,Unit,U32> & String,w:F.World(~S) & String,o:Locals.Owned(~S) & String) -> Locals.Returned(~S) & String:
  match r w o:
    case (result,rt), (world,wt), (OrdinaryLocal.Owner{instance},ot):(Local.Completed{world,instance,result},"LocalCompleted{world=" ++ wt ++ ";owner=" ++ ot ++ ";result=" ++ rt ++ "}")
def local_refused_join(~S:Data,+args:Unit,w:F.World(~S) & String,o:Locals.Owned(~S) & String) -> Locals.Returned(~S) & String:
  match w o:
    case (world,wt), (OrdinaryLocal.Owner{instance},ot):(Local.Refused{world,instance,args},"LocalRefused{world=" ++ wt ++ ";owner=" ++ ot ++ ";args=Unit}")
def local_returned(~S:Data,value:Locals.Returned(~S)) -> Locals.Returned(~S) & String:
  match value:
    case Local.Completed{w,o,result}:local_completed_join(~S,local_result(result),world(~S,w),local(~S,OrdinaryLocal.Owner{o}))
    case Local.Refused{w,o,args}:local_refused_join(~S,args,world(~S,w),local(~S,OrdinaryLocal.Owner{o}))
