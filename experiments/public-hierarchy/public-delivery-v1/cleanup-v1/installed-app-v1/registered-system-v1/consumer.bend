import Base
import /workspace/formal-proofs/bendvy/src/ecs/relation-types.bend as G
import /workspace/formal-proofs/bendvy/src/ecs/relation-commands.bend as A
import /workspace/formal-proofs/bendvy/src/ecs/relation-providers.bend as P
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as X
import /workspace/formal-proofs/bendvy/src/ecs/hierarchy-provider.bend as H
import ../owners.bend as O
import ../observer.bend as Obs
import /workspace/formal-proofs/bendvy/src/ecs/relation-cleanup.bend as Cleanup
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-linked-cleanup.bend as LC
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-component-binding.bend as Binding
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-declaration.bend as Identity
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-component-despawn.bend as Clear
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-composer.bend as Build
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-recipe.bend as Tree
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-observation-data.bend as DTO
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-registration-fields.bend as Fields
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-relation.bend as Relation
import /workspace/formal-proofs/bendvy/src/ecs/relation-failure-reader.bend as Ord
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-component-clear-declaration.bend as CD
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-linked-cleanup-system.bend as System
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys


type Alpha is Data:
  Alpha{}
type Beta is Data:
  Beta{}
def parent(~S:Data) -> G.Descriptor<S>:
  G.Descriptor{1,"Parent","Children",G.Hierarchy{}}
def hierarchy(~S:Data) -> G.HierarchyDescriptor<S>:
  G.HierarchyDescriptor{1,"Parent","Children"}
def link(~S:Data) -> G.Descriptor<S>:
  G.Descriptor{2,"Link","Incoming",G.Ordinary{}}
def empty(~S:Data,_:Unit) -> A.Store<S,O.Components<S>>:
  A.empty(~S,~O.Components<S>,O.Components{Col.Column{Col.absent(~O.Payload,3n),[]}})
def populated(~S:Data,outcome:Col.SwapOutcome<S,O.Payload>,graph:G.Graph<S>) -> A.Store<S,O.Components<S>> & Unit:
  match outcome:
    case Col.Accepted{column,_}: (A.Store{O.Components{column},graph},Unit{})
    case Col.Rejected{column,_}: (A.Store{O.Components{column},graph},Unit{})
def populate(~S:Data,store:A.Store<S,O.Components<S>>,handle:W.Handle<S>) -> A.Store<S,O.Components<S>> & Unit:
  match store handle:
    case A.Store{O.Components{column},graph} W.Handle{_,+id}: populated(~S,Col.swap(~S,~O.Payload,column,id,Some{O.Payload{ANode{ALeaf{id},ALeaf{U32.mul(id,10)}},id}}),graph)
def activated(~S:Data,result:W.World<S,A.Store<S,O.Components<S>>,O.Resources,A.Notice<S,U32>> & W.Status,handle:W.Handle<S>,handles:List<&2,W.Handle<S>>) -> W.World<S,A.Store<S,O.Components<S>>,O.Resources,A.Notice<S,U32>> & List<&2,W.Handle<S>>:
  (world,_) = result
  (world,handle <> handles)
def prepared(~S:Data,result:W.World<S,A.Store<S,O.Components<S>>,O.Resources,A.Notice<S,U32>> & Unit,+handle:W.Handle<S>,handles:List<&2,W.Handle<S>>) -> W.World<S,A.Store<S,O.Components<S>>,O.Resources,A.Notice<S,U32>> & List<&2,W.Handle<S>>:
  (world,_) = result
  activated(~S,W.activate(~S,~A.Store<S,O.Components<S>>,~O.Resources,~A.Notice<S,U32>,world,handle),handle,handles)
def reserved(~S:Data,result:W.World<S,A.Store<S,O.Components<S>>,O.Resources,A.Notice<S,U32>> & W.Reservation<S>,handles:List<&2,W.Handle<S>>) -> W.World<S,A.Store<S,O.Components<S>>,O.Resources,A.Notice<S,U32>> & List<&2,W.Handle<S>>:
  match result:
    case (world,W.Reserved{+handle}): prepared(~S,W.with_store(~S,~A.Store<S,O.Components<S>>,~O.Resources,~A.Notice<S,U32>,~Unit,store => populate(~S,store,handle),world),handle,handles)
    case (world,_): (world,handles)
def spawn(~S:Data,n:Nat,state:W.World<S,A.Store<S,O.Components<S>>,O.Resources,A.Notice<S,U32>> & List<&2,W.Handle<S>>) -> W.World<S,A.Store<S,O.Components<S>>,O.Resources,A.Notice<S,U32>> & List<&2,W.Handle<S>>:
  match n state:
    case 0n state: state
    case 1n+rest Tuple{world,handles}: spawn(~S,rest,reserved(~S,W.reserve_id(~S,~A.Store<S,O.Components<S>>,~O.Resources,~A.Notice<S,U32>,world),handles))
def write_body(~S:Data,-F:Type,caps:P.Writable<F,S>,targets:P.Targets<S>,owner:F) -> F & A.QueueStatus:
  P.relate_live(F,S,caps,owner,targets)
def queue(~S:Data,~descriptor:G.Descriptor<S>,tx:X.Tx<W.World<S,A.Store<S,O.Components<S>>,O.Resources,A.Notice<S,U32>>,A.Notice<S,U32>>,source:W.Handle<S>,target:W.Handle<S>) -> X.Tx<W.World<S,A.Store<S,O.Components<S>>,O.Resources,A.Notice<S,U32>>,A.Notice<S,U32>>:
  O.queue_done(~S,P.invoke_write(~S,~O.Components<S>,~O.Resources,~U32,~descriptor,~A.QueueStatus,~write_body(~S),P.Targets{source,target},tx))
def parent_declaration(~S:Data) -> Ord.Declaration<S>:Ord.relation(~S,parent(~S))
def link_declaration(~S:Data) -> Ord.Declaration<S>:Ord.relation(~S,link(~S))
def declarations(~S:Data) -> List<&2,Ord.Declaration<S>>:[parent_declaration(~S),link_declaration(~S)]
def take(~S:Data,components:O.Components<S>) -> Unit & Col.Column<S,O.Payload>:
  match components:
    case O.Components{column}:(Unit{},column)
def put(~S:Data,_:Unit,column:Col.Column<S,O.Payload>) -> O.Components<S>:O.Components{column}
def binding(~S:Data) -> Binding.Binding<S,O.Components<S>,Unit,O.Payload,List<&2,U32>,Unit,take(~S),put(~S),O.project_payload>:
  Binding.bind(~S,~O.Components<S>,~Unit,~O.Payload,~List<&2,U32>,~Unit,~take(~S),~put(~S),~O.project_payload,Identity.component(~S,~O.Payload,"Payload"))
def removed(~S:Data,_:Identity.Declaration<S,O.Payload>,handle:W.Handle<S>) -> A.Notice<S,U32>:
  match handle:
    case W.Handle{_,id}:A.ComponentRemoved{id}
def clear(~S:Data) -> O.Components<S> -> W.Handle<S> -> O.Components<S> & List<&2,A.Notice<S,U32>>:
  Clear.leaf(~S,~O.Components<S>,~Unit,~O.Payload,~List<&2,U32>,~Unit,~take(~S),~put(~S),~O.project_payload,~A.Notice<S,U32>,~removed(~S),~binding(~S))
def clear_declaration(~S:Data) -> CD.Declaration<S,O.Components<S>,A.Notice<S,U32>,clear(~S)>:
  CD.leaf(~S,~O.Components<S>,~Unit,~O.Payload,~List<&2,U32>,~Unit,~take(~S),~put(~S),~O.project_payload,~A.Notice<S,U32>,~removed(~S),~binding(~S))
def record(~S:Data,handle:W.Handle<S>) -> A.Notice<S,U32>:
  match handle:
    case W.Handle{_,id}:A.Original{U32.add(1000,id)}
def folded(~S:Data,owner:Array<U32>) -> Array<U32> & List<&2,Fields.Fields<S>>:(owner,[])
def physical_returned(~S:Data,seen:W.World<S,A.Store<S,O.Components<S>>,O.Resources,A.Notice<S,U32>> & String) -> W.World<S,A.Store<S,O.Components<S>>,O.Resources,A.Notice<S,U32>> & DTO.Observation<String>:
  match seen:
    case (world,+text):(world,DTO.Observation{text,[text]})
def physical(~S:Data,world:W.World<S,A.Store<S,O.Components<S>>,O.Resources,A.Notice<S,U32>>) -> W.World<S,A.Store<S,O.Components<S>>,O.Resources,A.Notice<S,U32>> & DTO.Observation<String>:physical_returned(~S,Obs.observe(~S,world))
def observe1(~S:Data) -> W.World<S,A.Store<S,O.Components<S>>,O.Resources,A.Notice<S,U32>> -> W.World<S,A.Store<S,O.Components<S>>,O.Resources,A.Notice<S,U32>> & DTO.Observation<Relation.ObservedRows(~S,~String)>:
  Relation.observation(~S,~O.Components<S>,~O.Resources,~U32,~parent_declaration(~S),~Relation.builtin_row(~S),~Array<U32>,~String,~physical(~S),~folded(~S))
def observe2(~S:Data) -> W.World<S,A.Store<S,O.Components<S>>,O.Resources,A.Notice<S,U32>> -> W.World<S,A.Store<S,O.Components<S>>,O.Resources,A.Notice<S,U32>> & DTO.Observation<Relation.ObservedRows(~S,~Relation.ObservedRows(~S,~String))>:
  Relation.observation(~S,~O.Components<S>,~O.Resources,~U32,~link_declaration(~S),~Relation.builtin_row(~S),~Array<U32>,~Relation.ObservedRows(~S,~String),~observe1(~S),~folded(~S))
def CleanupApp(~S:Data) -> Type:
  LC.Installed<S,O.Components<S>,O.Resources,U32,Array<U32>,Relation.ObservedRows(~S,~Relation.ObservedRows(~S,~String)),observe2(~S),folded(~S),declarations(~S),clear(~S),record(~S)>
def text_lines(lines:List<&2,String>) -> String:
  match lines:
    case []:""
    case line <> rest:line ++ "\n" ++ text_lines(rest)
def view_text(~S:Data,view:Maybe<&2,DTO.Product<List<&2,DTO.Binding<S>>,DTO.Observation<Relation.ObservedRows(~S,~Relation.ObservedRows(~S,~String))>>>) -> String:
  match view:
    case None{}:"INSPECT_DISABLED"
    case Some{DTO.Product{_,DTO.Observation{_,text}}}:text_lines(text)
def snapshot_returned(~S:Data,seen:CleanupApp(~S) & Maybe<&2,DTO.Product<List<&2,DTO.Binding<S>>,DTO.Observation<Relation.ObservedRows(~S,~Relation.ObservedRows(~S,~String))>>>) -> CleanupApp(~S) & String:
  match seen:
    case (LC.Installed{Build.Registered{world,owners,recipe,+debug}},view):(LC.Installed{Build.Registered{world,owners,recipe,debug}},"debug=" ++ Bool.show(debug) ++ "\n" ++ view_text(~S,view))
def owner_prefixed(~S:Data,seen:CleanupApp(~S) & String,owners:String) -> CleanupApp(~S) & String:
  match seen:
    case (app,text):(app,"owners=" ++ owners ++ "|recipe=Recipe{}\n" ++ text)
def owner_observed(~S:Data,world:W.World<S,A.Store<S,O.Components<S>>,O.Resources,A.Notice<S,U32>>,debug:Bool,seen:Array<U32> & List<&2,U32>) -> CleanupApp(~S) & String:
  match seen:
    case (owners,values):owner_prefixed(~S,snapshot_returned(~S,LC.snapshot_app(~S,~O.Components<S>,~O.Resources,~U32,~Array<U32>,~Relation.ObservedRows(~S,~Relation.ObservedRows(~S,~String)),~observe2(~S),~folded(~S),~declarations(~S),~clear(~S),~record(~S),LC.Installed{Build.Registered{world,owners,Tree.Recipe{},debug}},True{})),O.show_ids(values))
def snapshot(~S:Data,app:CleanupApp(~S)) -> CleanupApp(~S) & String:
  match app:
    case LC.Installed{Build.Registered{world,owners,Tree.Recipe{},debug}}:owner_observed(~S,world,debug,O.project_cells(1n,owners,0))
def status(status:A.QueueStatus) -> String:
  match status:
    case A.Queued{}:"Queued"
    case A.MissingEntity{}:"MissingEntity"
def outcome(outcome:X.Outcome<U32>) -> String:
  match outcome:
    case X.Success{}:"Success"
    case X.Failure{error}:"Failure:" ++ U32.show(error)
type Args<S:Data> is Data:
  Args{target:W.Handle<S>,outcome:X.Outcome<U32>}
def body_returned(-F:Type,result:X.Outcome<U32>,seen:F & A.QueueStatus) -> F & (X.Outcome<U32> & A.QueueStatus):
  match seen:
    case (owner,status):(owner,(result,status))
def body(~S:Data,-F:Type,caps:System.Ops<F,S>,args:Args<S>,owner:F) -> F & (X.Outcome<U32> & A.QueueStatus):
  match args:
    case Args{target,result}:body_returned(F,result,System.cleanup(F,S,caps,owner,target))
type Session<S:Data> is Type:
  Session{app:CleanupApp(~S),owner:System.Owner(~S,~O.Components<S>,~O.Resources,~U32,~declarations(~S),~clear(~S),~record(~S),~Args<S>,~U32,~A.QueueStatus,~body(~S))}
def access_text(access:List<&2,String>) -> String:
  match access:
    case []:""
    case name <> rest:name ++ "," ++ access_text(rest)
def metadata(~S:Data,owner:System.Owner(~S,~O.Components<S>,~O.Resources,~U32,~declarations(~S),~clear(~S),~record(~S),~Args<S>,~U32,~A.QueueStatus,~body(~S))) -> System.Owner(~S,~O.Components<S>,~O.Resources,~U32,~declarations(~S),~clear(~S),~record(~S),~Args<S>,~U32,~A.QueueStatus,~body(~S)) & String:
  match owner:
    case Sys.Registry{+ns,+id,+name,+access,+cursor}:(Sys.Registry{ns,id,name,access,cursor},"system=" ++ U32.show(ns) ++ ":" ++ U32.show(id) ++ ":" ++ name ++ "|access=" ++ access_text(access) ++ "|cursor=" ++ U32.show(cursor))
def snapshot_joined(~S:Data,seen:CleanupApp(~S) & String,owner:System.Owner(~S,~O.Components<S>,~O.Resources,~U32,~declarations(~S),~clear(~S),~record(~S),~Args<S>,~U32,~A.QueueStatus,~body(~S)),meta:String) -> Session<S> & String:
  match seen:
    case (app,text):(Session{app,owner},meta ++ "\n" ++ text)
def snapshot_metadata(~S:Data,app:CleanupApp(~S),seen:System.Owner(~S,~O.Components<S>,~O.Resources,~U32,~declarations(~S),~clear(~S),~record(~S),~Args<S>,~U32,~A.QueueStatus,~body(~S)) & String) -> Session<S> & String:
  match seen:
    case (owner,meta):snapshot_joined(~S,snapshot(~S,app),owner,meta)
def session_snapshot(~S:Data,session:Session<S>) -> Session<S> & String:
  match session:
    case Session{app,owner}:snapshot_metadata(~S,app,metadata(~S,owner))
def executed(~S:Data,seen:System.Executed<CleanupApp(~S),System.Owner(~S,~O.Components<S>,~O.Resources,~U32,~declarations(~S),~clear(~S),~record(~S),~Args<S>,~U32,~A.QueueStatus,~body(~S)),Args<S>,U32,A.QueueStatus>) -> Session<S> & String:
  match seen:
    case System.Executed{app,owner,result,Some{queued}}:(Session{app,owner},status(queued) ++ ":" ++ outcome(result))
    case System.Executed{app,owner,result,None{}}:(Session{app,owner},"NoOutput:" ++ outcome(result))
    case System.RegistrationRejected{app,owner,_}:(Session{app,owner},"RegistrationRejected")
def session_invoke(~S:Data,session:Session<S>,target:W.Handle<S>,result:X.Outcome<U32>) -> Session<S> & String:
  match session:
    case Session{app,owner}:executed(~S,System.run_app(~S,~O.Components<S>,~O.Resources,~U32,~declarations(~S),~clear(~S),~record(~S),~Args<S>,~U32,~A.QueueStatus,~body(~S),~Array<U32>,~Relation.ObservedRows(~S,~Relation.ObservedRows(~S,~String)),~observe2(~S),~folded(~S),owner,app,Args{target,result}))
def session_barrier(~S:Data,session:Session<S>) -> Session<S>:
  match session:
    case Session{app,owner}:Session{LC.barrier_app(~S,~O.Components<S>,~O.Resources,~U32,~Array<U32>,~Relation.ObservedRows(~S,~Relation.ObservedRows(~S,~String)),~observe2(~S),~folded(~S),~declarations(~S),~clear(~S),~record(~S),app),owner}
def finish(~S:Data,seen:Session<S> & String,head:String) -> String:
  match seen:
    case (_,text):head ++ "\nAPPLIED\n" ++ text
def pending_snapshot(~S:Data,seen:Session<S> & String,head:String) -> String:
  match seen:
    case (session,text):finish(~S,session_snapshot(~S,session_barrier(~S,session)),head ++ "\nPENDING\n" ++ text)
def pending(~S:Data,seen:Session<S> & String,head:String) -> String:
  match seen:
    case (session,text):pending_snapshot(~S,session_snapshot(~S,session),head ++ "\nQUEUE=" ++ text)
def after_abort(~S:Data,seen:Session<S> & String,+target:W.Handle<S>,head:String) -> String:
  match seen:
    case (session,text):pending(~S,session_invoke(~S,session,target,X.Success{}),head ++ "\nABORTED\n" ++ text)
def aborted(~S:Data,seen:Session<S> & String,target:W.Handle<S>,head:String) -> String:
  match seen:
    case (session,text):after_abort(~S,session_snapshot(~S,session_barrier(~S,session)),target,head ++ "\nABORT=" ++ text)
def initial(~S:Data,seen:Session<S> & String,+target:W.Handle<S>) -> String:
  match seen:
    case (session,text):aborted(~S,session_invoke(~S,session,target,X.Failure{77}),target,"INITIAL\n" ++ text)
def defined(~S:Data,target:W.Handle<S>,seen:System.Defined<CleanupApp(~S),System.Owner(~S,~O.Components<S>,~O.Resources,~U32,~declarations(~S),~clear(~S),~record(~S),~Args<S>,~U32,~A.QueueStatus,~body(~S))>) -> String:
  match seen:
    case System.Defined{app,owner}:initial(~S,session_snapshot(~S,Session{app,owner}),target)
    case System.DefinitionRejected{_}:"REGISTRATION_FAILURE"
def installed(~S:Data,world:W.World<S,A.Store<S,O.Components<S>>,O.Resources,A.Notice<S,U32>>,target:W.Handle<S>) -> String:
  defined(~S,target,System.register_app(~S,~O.Components<S>,~O.Resources,~U32,~declarations(~S),~clear(~S),~record(~S),~Args<S>,~U32,~A.QueueStatus,~body(~S),~Array<U32>,~Relation.ObservedRows(~S,~Relation.ObservedRows(~S,~String)),~observe2(~S),~folded(~S),~clear_declaration(~S),LC.install_relation(~S,~O.Components<S>,~O.Resources,~U32,~Array<U32>,~Relation.ObservedRows(~S,~String),~observe1(~S),~folded(~S),~[parent_declaration(~S)],~clear(~S),~record(~S),~link_declaration(~S),LC.install_relation(~S,~O.Components<S>,~O.Resources,~U32,~Array<U32>,~String,~physical(~S),~folded(~S),~[],~clear(~S),~record(~S),~parent_declaration(~S),LC.empty(~S,~O.Components<S>,~O.Resources,~U32,~Array<U32>,~String,~physical(~S),~folded(~S),~clear(~S),~record(~S),Build.Registered{world,Array.new(U32,0n,19),Tree.Recipe{},False{}}))),"LinkedCleanup"))
def seeded(~S:Data,state:W.World<S,A.Store<S,O.Components<S>>,O.Resources,A.Notice<S,U32>> & List<&2,W.Handle<S>>) -> String:
  match state:
    case (world,Con{h4,Con{+h3,Con{+h2,Con{+h1,Nil{}}}}}):installed(~S,W.barrier(~S,~A.Store<S,O.Components<S>>,~O.Resources,~A.Notice<S,U32>,O.commit(~S,queue(~S,~link(~S),queue(~S,~parent(~S),queue(~S,~parent(~S),queue(~S,~parent(~S),X.begin(~W.World<S,A.Store<S,O.Components<S>>,O.Resources,A.Notice<S,U32>>,~A.Notice<S,U32>,world),h2,h1),h3,h1),h4,h2),h3,h2),X.Success{})),h2)
    case _:"RESERVATION_FAILURE"
def created(~S:Data,result:W.Creation<S,A.Store<S,O.Components<S>>,O.Resources,A.Notice<S,U32>>) -> String:
  match result:
    case W.Created{_,world}:seeded(~S,spawn(~S,4n,(world,[])))
    case _:"CREATE_FAILURE"
def run(~S:Data) -> String:
  created(~S,W.create(~S,~A.Store<S,O.Components<S>>,~O.Resources,~A.Notice<S,U32>,~empty(~S),W.factory(),O.Resources{Array.new(U32,0n,17),Array.new(U32,0n,18)}))
def main() -> IO(Unit):IO.print("HierarchyAlpha\n" ++ run(~Alpha) ++ "\nHierarchyBeta\n" ++ run(~Beta))
