import ../../../src/ecs/deferred-command.bend as Deferred
import Base
import reader.bend as Reader
import ../../../src/ecs/ordinary-machine-transition-reader.bend as TransitionReader
import ../../../src/ecs/system-instance.bend as Instance
import ../../../src/ecs/system-cleanup.bend as Cleanup
import ../../../src/ecs/system.bend as Sys
import fixture.bend as F
import ../basic-world-statefree-v1/observe.bend as O
import ../basic-world-statefree-v1/inspect.bend as Inspect
import ../basic-world-statefree-v1/schema.bend as Original
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/relation-commands.bend as Relation
import ../../../src/ecs/relation-types.bend as G
import ../../../src/ecs/relation-failure-reader.bend as Decl
import ../../../src/ecs/ordinary-machine-initialization.bend as Init
import ../../../src/ecs/machine.bend as M
import ../../../src/ecs/machine-stream.bend as St
import ../../../src/ecs/machine-stream-queue.bend as Queue
import ../../../src/ecs/event-runtime.bend as Ev
import ../../../src/ecs/owner-product.bend as Product
import ../../../src/ecs/restore-graph-public.bend as Public
import ../../../src/ecs/restore-public.bend as Basic
import ../../../src/ecs/restore-graph-data.bend as Data
import ../../../src/ecs/restore-schema.bend as RestoreSchema
import ../../../src/ecs/ordinary-schema.bend as Ordinary
import ../../../src/ecs/schema-fragments.bend as Fragment
import ../../../src/ecs/restore-data.bend as R
import ../../../src/ecs/decode-data.bend as D
import ../../../src/ecs/entity-allocator.bend as Alloc
import ../../../src/ecs/entity-key.bend as Key

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
    case Relation.Original{event}:"Original{" ++ O.change(~S,event) ++ "}"
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
def user_resources(~S:Data,value:F.UserResources(~S)) -> F.UserResources(~S) & String:
  O.product(~Unit,~Original.ResourceGroupResources(~S),~O.unit,~O.product(~Original.ResourceResources(~S),~Original.TransientResources(~S),~O.resource(~S),~O.transient(~S)),value)
def resources(~S:Data,value:F.Resources(~S)) -> F.Resources(~S) & String:
  O.product(~F.UserResources(~S),~F.Machines(~S),~user_resources(~S),~O.product(~Init.State<S,F.Mode,U32>,~Init.State<S,F.Weather,U32>,~machine(~S,~F.Mode),~machine(~S,~F.Weather)),value)
def store_join(~S:Data,+value:G.Graph<S>,observed:F.Components(~S) & String) -> F.Store(~S) & String:
  (components,text)=observed
  (Relation.Store{components,value},"Store{components=" ++ text ++ ";graph=" ++ graph(~S,value) ++ "}")
def store(~S:Data,value:F.Store(~S)) -> F.Store(~S) & String:
  match value:
    case Relation.Store{components,graph}:store_join(~S,graph,O.store(~S,components))
def pending_count_join(~S:Data,head:Deferred.Command<F.World(~S)>,observed:List<Deferred.Command<F.World(~S)>> & Nat) -> List<Deferred.Command<F.World(~S)>> & Nat:
  (rest,count)=observed
  (head <> rest,1n+count)
def pending_count(~S:Data,values:List<Deferred.Command<F.World(~S)>>) -> List<Deferred.Command<F.World(~S)>> & Nat:
  match values:
    case []:([],0n)
    case head <> rest:pending_count_join(~S,head,pending_count(~S,rest))
def world_join(~S:Data,+ns:U32,+events:List<&2,F.Events(~S)>,+regs:List<&2,W.RegistrationMeta>,+sid:U32,+clock:U32,a:Alloc.Allocator & String,c:F.Store(~S) & String,r:F.Resources(~S) & String,p:List<Deferred.Command<F.World(~S)>> & Nat) -> F.World(~S) & String:
  (a,at)=a
  (c,ct)=c
  (r,rt)=r
  (p,count)=p
  (W.World{ns,a,c,r,events,p,regs,sid,clock},"World{namespace=" ++ U32.show(ns) ++ ";allocator={" ++ at ++ "};store=" ++ ct ++ ";resources=" ++ rt ++ ";events=" ++ List.show(&2,F.Events(~S),notice(~S),events) ++ ";pending=" ++ Nat.show(count) ++ ";registrations=" ++ List.show(&2,W.RegistrationMeta,O.registration,regs) ++ ";nextSystem=" ++ U32.show(sid) ++ ";clock=" ++ U32.show(clock) ++ "}")
def world(~S:Data,value:F.World(~S)) -> F.World(~S) & String:
  match value:
    case W.World{ns,a,c,r,e,p,regs,sid,clock}:world_join(~S,ns,e,regs,sid,clock,O.allocator(a),store(~S,c),resources(~S,r),pending_count(~S,p))
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
    case Public.GraphError{value}:"GraphError{" ++ graph_error(value) ++ "}"
def restored_join(~S:Data,+bindings:List<&2,R.Binding<S>>,w:F.World(~S) & String,o:F.Owned(~S) & String,r:F.Recovery(~S) & String) -> F.Returned(~S) & String:
  (world,wt)=w
  (owner,ot)=o
  (recovery,rt)=r
  (Public.Restored{world,owner,recovery,bindings},"Restored{world=" ++ wt ++ ";owner=" ++ ot ++ ";recovery=" ++ rt ++ ";bindings=" ++ List.show(&2,R.Binding<S>,Inspect.binding(~S),bindings) ++ "}")
def rejected_join(~S:Data,+input:Data.Snapshot,+reason:Public.Error<String>,w:F.World(~S) & String,o:F.Owned(~S) & String,r:F.Recovery(~S) & String) -> F.Returned(~S) & String:
  (world,wt)=w
  (owner,ot)=o
  (recovery,rt)=r
  (Public.Rejected{world,owner,recovery,input,reason},"Rejected{world=" ++ wt ++ ";owner=" ++ ot ++ ";recovery=" ++ rt ++ ";input=" ++ snapshot(input) ++ ";error=" ++ error(reason) ++ "}")
def missing_join(~S:Data,+saved:Key.Key,w:F.World(~S) & String,o:F.Owned(~S) & String,r:F.Recovery(~S) & String) -> F.Returned(~S) & String:
  (world,wt)=w
  (owner,ot)=o
  (recovery,rt)=r
  (Public.MissingBinding{world,owner,recovery,saved},"MissingBinding{world=" ++ wt ++ ";owner=" ++ ot ++ ";recovery=" ++ rt ++ ";saved=" ++ O.key(saved) ++ "}")
def returned(~S:Data,value:F.Returned(~S)) -> F.Returned(~S) & String:
  match value:
    case Public.Restored{w,o,r,bindings}:restored_join(~S,bindings,world(~S,w),owner(~S,o),recovery(~S,r))
    case Public.Rejected{w,o,r,input,reason}:rejected_join(~S,input,reason,world(~S,w),owner(~S,o),recovery(~S,r))
    case Public.MissingBinding{w,o,r,saved}:missing_join(~S,saved,world(~S,w),owner(~S,o),recovery(~S,r))

def reader(~S:Data,value:Reader.Owned(~S)) -> Reader.Owned(~S) & String:
  match value:
    case Instance.Instance{Cleanup.Instance{Sys.Registry{+ns,+id,+name,+access,+cursor},St.Reader{+rns,+rid}}}:(Instance.Instance{Cleanup.Instance{Sys.Registry{ns,id,name,access,cursor},St.Reader{rns,rid}}},"Reader{namespace=" ++ U32.show(ns) ++ ";id=" ++ U32.show(id) ++ ";name=" ++ name ++ ";access=" ++ List.show(&2,String,x=>x,access) ++ ";cursor=" ++ U32.show(cursor) ++ ";portNamespace=" ++ U32.show(rns) ++ ";portId=" ++ U32.show(rid) ++ "}")
def reading(value:Ev.Reading<M.Transition<U32>>) -> String:
  match value:
    case Ev.Reading{values,lagged}:"Reading{values=" ++ List.show(&2,M.Transition<U32>,transition,values) ++ ";lagged=" ++ Bool.show(lagged) ++ "}"
def read_succeeded(~S:Data,+observed:Ev.Reading<M.Transition<U32>>,w:F.World(~S) & String,r:Reader.Owned(~S) & String,a:Array<U32> & String) -> Reader.Returned(~S) & String:
  (world,wt)=w
  (reader,rt)=r
  (output,at)=a
  (TransitionReader.ReadSucceeded{world,reader,output,observed},"ReadSucceeded{world=" ++ wt ++ ";reader=" ++ rt ++ ";output=" ++ at ++ ";reading=" ++ reading(observed) ++ "}")
def read_failed(~S:Data,+reason:Unit,+observed:Ev.Reading<M.Transition<U32>>,w:F.World(~S) & String,r:Reader.Owned(~S) & String) -> Reader.Returned(~S) & String:
  (world,wt)=w
  (reader,rt)=r
  (TransitionReader.ReadFailed{world,reader,reason,observed},"ReadFailed{world=" ++ wt ++ ";reader=" ++ rt ++ ";error=Unit;reading=" ++ reading(observed) ++ "}")
def read_rejected(~S:Data,w:F.World(~S) & String,r:Reader.Owned(~S) & String,a:Array<U32> & String) -> Reader.Returned(~S) & String:
  (world,wt)=w
  (reader,rt)=r
  (args,at)=a
  (TransitionReader.ReadRejected{world,reader,args},"ReadRejected{world=" ++ wt ++ ";reader=" ++ rt ++ ";args=" ++ at ++ "}")
def read_returned(~S:Data,value:Reader.Returned(~S)) -> Reader.Returned(~S) & String:
  match value:
    case TransitionReader.ReadSucceeded{w,r,output,observed}:read_succeeded(~S,observed,world(~S,w),reader(~S,r),O.u32_array(output))
    case TransitionReader.ReadFailed{w,r,reason,observed}:read_failed(~S,reason,observed,world(~S,w),reader(~S,r))
    case TransitionReader.ReadRejected{w,r,args}:read_rejected(~S,world(~S,w),reader(~S,r),O.u32_array(args))
