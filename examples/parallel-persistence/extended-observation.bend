import Base
import ./extended-observation-data.bend as Data
import ./observation.bend as Basic
import ./extended-declarations.bend as Schema
import ./extended-programs.bend as P
import ./extended-execution.bend as Execution
import ./extended-restore.bend as Restore
import ./extended-population.bend as Population
import ./extended-admission.bend as Admission
import ./extended-save.bend as Save
import ./extended-reader.bend as Read
import ./extended-target.bend as Target
import ./extended-flow.bend as Flow
import ./restore.bend as Ordinary
import ./declarations.bend as O
import ../parallel-machines/declarations.bend as Modes
import ../parallel-linked-despawn/generalized-observation-data.bend as GraphText
import ../parallel-relations/failure-message-text.bend as FailureText
import ../../src/ecs/execution-relation-store.bend as Store
import ../../src/ecs/execution-relation-failure-channel.bend as Failure
import ../../src/ecs/execution-relation-failure-message.bend as Message
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-parallel-scope.bend as Scope
import ../../src/ecs/execution-parallel-root-application.bend as Schedule
import ../../src/ecs/execution-declaration.bend as Declaration
import ../../src/ecs/dependency-application.bend as App
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/execution-restore-extended-data.bend as Extended
import ../../src/ecs/execution-restore-publication.bend as Publication
import ../../src/ecs/execution-machine-restore.bend as MachineRestore
import ../../src/ecs/execution-save-gate.bend as Gate
import ../../src/ecs/execution-save-recipe.bend as Recipe
import ../../src/ecs/restore-data.bend as R
import ../../src/ecs/execution-restore-receiver.bend as Receiver
import ../../src/ecs/world.bend as W
import ../../src/ecs/lifetime-scope.bend as ScopeData
import ../../src/ecs/change-tick.bend as Tick
import ../../src/ecs/dependency-plan.bend as DepPlan
import ../../src/ecs/execution-parallel-registration.bend as Part
import ../../src/ecs/relation-types.bend as T

def local_values(+runs:U32,result:Array<U32> & String) -> P.Local & String:
  match result:
    case (capture,text):(P.Local{capture,runs},"capture=" ++ text ++ ":runs=" ++ U32.show(runs))
def local_retained(value:P.Local) -> P.Local & String:
  match value:
    case P.Local{capture,runs}:local_values(runs,Data.u32_array(capture))
def left_values(~S:Data,+namespace:U32,+id:U32,+name:String,+access:List<&2,String>,+cursor:Maybe<&2,Tick.Tick>,result:P.Local & String) -> P.Left(~S) & String:
  match result:
    case (local,text):(Sys.Owner{namespace,id,name,access,cursor,local},Basic.system_header(namespace,id,name,access,cursor) ++ ":local=" ++ text)
def left(~S:Data,value:P.Left(~S)) -> P.Left(~S) & String:
  match value:
    case Sys.Owner{namespace,id,name,access,cursor,local}:left_values(~S,namespace,id,name,access,cursor,local_retained(local))
def right_values(~S:Data,+namespace:U32,+id:U32,+name:String,+access:List<&2,String>,+cursor:Maybe<&2,Tick.Tick>,result:P.Local & String) -> P.Right(~S) & String:
  match result:
    case (local,text):(Sys.Owner{namespace,id,name,access,cursor,local},Basic.system_header(namespace,id,name,access,cursor) ++ ":local=" ++ text)
def right(~S:Data,value:P.Right(~S)) -> P.Right(~S) & String:
  match value:
    case Sys.Owner{namespace,id,name,access,cursor,local}:right_values(~S,namespace,id,name,access,cursor,local_retained(local))
def guard_owner_values(~S:Data,+namespace:U32,+id:U32,+name:String,+access:List<&2,String>,+cursor:Maybe<&2,Tick.Tick>,result:P.Local & String) -> P.GuardOwner(~S) & String:
  match result:
    case (local,text):(Sys.Owner{namespace,id,name,access,cursor,local},Basic.system_header(namespace,id,name,access,cursor) ++ ":local=" ++ text)
def guard_owner(~S:Data,value:P.GuardOwner(~S)) -> P.GuardOwner(~S) & String:
  match value:
    case Sys.Owner{namespace,id,name,access,cursor,local}:guard_owner_values(~S,namespace,id,name,access,cursor,local_retained(local))
def compilation(~S:Data,value:P.GuardCompilation(~S)) -> P.GuardCompilation(~S) & String:
  match value:
    case Declaration.Supported{Declaration.Declaration{caps,+access},+recipes}:(Declaration.Supported{Declaration.Declaration{caps,access},recipes},"supported(access=" ++ List.show(&2,Declaration.Access,GraphText.access,access) ++ ",recipes=" ++ GraphText.recipes(~S,~P.Columns(~S),recipes) ++ ",caps=opaque)")
    case Declaration.Unsupported{caps,+access,+recipes}:(Declaration.Unsupported{caps,access,recipes},"unsupported(access=" ++ List.show(&2,Declaration.Access,GraphText.access,access) ++ ",recipes=" ++ GraphText.recipes(~S,~P.Columns(~S),recipes) ++ ",caps=opaque)")
def guard_finished(~S:Data,result:Product.Owner<P.GuardCompilation(~S),P.GuardOwner(~S)> & String) -> P.Guard(~S) & String:
  match result:
    case (Product.Owner{compilation,owner},text):(Scope.CompiledBinding{compilation,owner},text)
def guard(~S:Data,value:P.Guard(~S)) -> P.Guard(~S) & String:
  match value:
    case Scope.CompiledBinding{compiled,owner}:guard_finished(~S,Data.pair(P.GuardCompilation(~S),P.GuardOwner(~S),compilation(~S),guard_owner(~S),Product.Owner{compiled,owner}))
def reader_retained(~S:Data,value:Target.Reader(~S)) -> Target.Reader(~S) & String:
  match value:
    case Failure.Reader{+namespace,+id,+cursor}:(Failure.Reader{namespace,id,cursor},U32.show(namespace) ++ ":" ++ U32.show(id) ++ ":" ++ Nat.show(cursor))
def reader(~S:Data,value:Maybe<&1,Target.Reader(~S)>) -> String:Data.consumed(Maybe<&1,Target.Reader(~S)>,Data.maybe_retained(Target.Reader(~S),reader_retained(~S),value))
def handler_reader(~S:Data,capture:Array<U32>,text:String,+handled:U32,result:Maybe<&1,Target.Reader(~S)> & String) -> Execution.Handler<S> & String:
  match result:
    case (reader,other):(Execution.Handler{capture,handled,reader},"capture=" ++ text ++ ":handled=" ++ U32.show(handled) ++ ":reader=" ++ other)
def handler_capture(~S:Data,handled:U32,reader:Maybe<&1,Target.Reader(~S)>,result:Array<U32> & String) -> Execution.Handler<S> & String:
  match result:
    case (capture,text):handler_reader(~S,capture,text,handled,Data.maybe_retained(Target.Reader(~S),reader_retained(~S),reader))
def handler(~S:Data,value:Execution.Handler<S>) -> Execution.Handler<S> & String:
  match value:
    case Execution.Handler{capture,handled,reader}:handler_capture(~S,handled,reader,Data.u32_array(capture))
def app_owner_parts(~S:Data,value:Product.Owner<Product.Owner<P.Left(~S),P.Right(~S)>,Product.Owner<P.Guard(~S),Execution.Handler<S>>>) -> Product.Owner<Product.Owner<P.Left(~S),P.Right(~S)>,Product.Owner<P.Guard(~S),Execution.Handler<S>>> & String:
  Data.pair(Product.Owner<P.Left(~S),P.Right(~S)>,Product.Owner<P.Guard(~S),Execution.Handler<S>>,Data.pair(P.Left(~S),P.Right(~S),left(~S),right(~S)),Data.pair(P.Guard(~S),Execution.Handler<S>,guard(~S),handler(~S)),value)
type StateRest<-S:Data> is Type:StateRest{world:Schema.World(~S),bindings:List<&2,App.Binding>}
def state_parts(~S:Data,rest:StateRest<S>,result:Product.Owner<Product.Owner<P.Left(~S),P.Right(~S)>,Product.Owner<P.Guard(~S),Execution.Handler<S>>> & String) -> App.State<Schema.World(~S),Product.Owner<P.Left(~S),P.Right(~S)>,P.Guard(~S),Execution.Handler<S>> & String:
  match rest result:
    case StateRest{world,+bindings}, (Product.Owner{owners,Product.Owner{guard,handler}},text):(App.State{world,owners,guard,handler,bindings},"owners=" ++ text ++ ":stateBindings=" ++ List.show(&2,App.Binding,Basic.binding_app,bindings))
def state_owners(~S:Data,value:App.State<Schema.World(~S),Product.Owner<P.Left(~S),P.Right(~S)>,P.Guard(~S),Execution.Handler<S>>) -> App.State<Schema.World(~S),Product.Owner<P.Left(~S),P.Right(~S)>,P.Guard(~S),Execution.Handler<S>> & String:
  match value:
    case App.State{world,owners,guard,handler,bindings}:state_parts(~S,StateRest{world,bindings},app_owner_parts(~S,Product.Owner{owners,Product.Owner{guard,handler}}))
type StateOwners<-S:Data> is Type:StateOwners{owners:Product.Owner<P.Left(~S),P.Right(~S)>,guard:P.Guard(~S),handler:Execution.Handler<S>,bindings:List<&2,App.Binding>}
def state_world_values(~S:Data,held:StateOwners<S>,text:String,result:Schema.World(~S) & String) -> App.State<Schema.World(~S),Product.Owner<P.Left(~S),P.Right(~S)>,P.Guard(~S),Execution.Handler<S>> & String:
  match held result:
    case StateOwners{owners,guard,handler,bindings}, (world,other):(App.State{world,owners,guard,handler,bindings},text ++ "/world=" ++ other)
def state_world(~S:Data,result:App.State<Schema.World(~S),Product.Owner<P.Left(~S),P.Right(~S)>,P.Guard(~S),Execution.Handler<S>> & String) -> App.State<Schema.World(~S),Product.Owner<P.Left(~S),P.Right(~S)>,P.Guard(~S),Execution.Handler<S>> & String:
  match result:
    case (App.State{world,owners,guard,handler,bindings},text):state_world_values(~S,StateOwners{owners,guard,handler,bindings},text,Data.world_retained(~S,world))
type AppRest is Data:AppRest{plan:DepPlan.Build<String>,bindings:List<&2,App.Binding>,rules:Part.Rules,deferred:Schedule.Deferred}
def app_values(~S:Data,rest:AppRest,result:App.State<Schema.World(~S),Product.Owner<P.Left(~S),P.Right(~S)>,P.Guard(~S),Execution.Handler<S>> & String) -> Execution.Application(~S) & String:
  match rest result:
    case AppRest{+plan,+bindings,+rules,+deferred}, (state,text):(Schedule.Scheduled{state,plan,bindings,rules,deferred},text ++ "/plan=" ++ Basic.plan(plan) ++ "/appBindings=" ++ List.show(&2,App.Binding,Basic.binding_app,bindings) ++ "/rules=" ++ Basic.rules(rules) ++ "/deferred=" ++ Basic.scheduled_deferred(deferred))
def app_retained(~S:Data,value:Execution.Application(~S)) -> Execution.Application(~S) & String:
  match value:
    case Schedule.Scheduled{state,plan,bindings,rules,deferred}:app_values(~S,AppRest{plan,bindings,rules,deferred},state_world(~S,state_owners(~S,state)))
def app(~S:Data,value:Execution.Application(~S)) -> String:Data.consumed(Execution.Application(~S),app_retained(~S,value))
type Source<-S:Data> is Type:Source{world:Schema.World(~S),previous:Population.Previous(~S),receipt:Store.Receipt<S>}
type SourceRest<-S:Data> is Type:SourceRest{previous:Population.Previous(~S),receipt:Store.Receipt<S>}
def source_done(~S:Data,value:SourceRest<S>,text:String) -> String:
  match value:
    case SourceRest{previous,receipt}:"world={" ++ text ++ "}/previous=" ++ List.show(&1,Product.Owner<Maybe<&1,O.Actor<S>>,Maybe<&1,O.Scratch<S>>>,Basic.removed_bundle(~S),previous) ++ "/receiverRelation=" ++ GraphText.relation_receipt(~S,receipt)
def source(~S:Data,value:Source<S>) -> String:
  match value:
    case Source{world,previous,receipt}:source_done(~S,SourceRest{previous,receipt},Data.world(~S,world))
def machine_commit(value:MachineRestore.Commit<Modes.Mode>) -> String:
  match value:
    case MachineRestore.Commit{current,revision,stamp}:"current=" ++ Data.maybe_mode(current) ++ ":revision=" ++ Nat.show(revision) ++ ":stamp=" ++ Basic.maybe_tick(stamp)
type RestoreStateRest<-S:Data> is Data:RestoreStateRest{input:Extended.Snapshot<S>,graph:T.Graph<S>,machine:MachineRestore.Commit<Modes.Mode>}
def restore_state_done(~S:Data,rest:RestoreStateRest<S>,staged:String,result:Admission.Recipes(~S) & String) -> Admission.Recipes(~S) & String:
  match rest result:
    case RestoreStateRest{input,graph,machine}, (schema,text):(schema,"schema=" ++ text ++ "/input=" ++ Data.snapshot(~S,input) ++ "/preparedGraph=" ++ Data.graph(~S,graph) ++ "/machineCommit=" ++ machine_commit(machine) ++ "/actors=" ++ staged)
def restore_state_staged(~S:Data,schema:Admission.Recipes(~S),rest:RestoreStateRest<S>,text:String) -> Admission.Recipes(~S) & String:restore_state_done(~S,rest,text,Data.schema_retained(~S,schema))
def restore_state(~S:Data,value:Restore.State<S>) -> Admission.Recipes(~S) & String:
  match value:
    case Restore.State{schema,input,graph,machine,actors}:restore_state_staged(~S,schema,RestoreStateRest{input,graph,machine},Basic.actor_stage(~S,actors))
def previous(~S:Data,value:Restore.Previous<S>) -> String:
  match value:
    case Restore.Previous{graph,members}:Data.graph(~S,graph) ++ ":scopes=" ++ List.show(&2,ScopeData.Member,Data.member,members)
type Restoration<-S:Data> is Type:Restoration{state:Restore.State<S>,removed:List<Ordinary.Receipt(~S)>,mapping:List<&2,R.Binding<S>>,publications:List<Publication.Receipt<S,Schema.components(~S)>>,previous:Restore.Previous<S>}
type RestorationRest<-S:Data> is Type:RestorationRest{removed:List<Ordinary.Receipt(~S)>,mapping:List<&2,R.Binding<S>>,publications:List<Publication.Receipt<S,Schema.components(~S)>>,previous:Restore.Previous<S>}
def restoration_done(~S:Data,rest:RestorationRest<S>,result:Admission.Recipes(~S) & String) -> Admission.Recipes(~S) & String:
  match rest result:
    case RestorationRest{removed,mapping,publications,old}, (schema,text):(schema,text ++ "/removed=" ++ List.show(&1,Ordinary.Receipt(~S),Basic.buffer_receipt(~S),removed) ++ "/mapping=" ++ List.show(&2,R.Binding<S>,Basic.binding(~S),mapping) ++ "/publications=" ++ List.show(&1,Publication.Receipt<S,Schema.components(~S)>,Basic.publication_receipt(~S),publications) ++ "/previous=" ++ previous(~S,old))
def restoration(~S:Data,value:Restoration<S>) -> Admission.Recipes(~S) & String:
  match value:
    case Restoration{state,removed,mapping,publications,previous}:restoration_done(~S,RestorationRest{removed,mapping,publications,previous},restore_state(~S,state))
def reading(~S:Data,value:Read.Reading(~S)) -> String:
  match value:
    case Failure.Read{retained,messages,missed,tick}:"read(reader=" ++ Data.consumed(Target.Reader(~S),reader_retained(~S,retained)) ++ ",messages=" ++ List.show(&2,Message.Message<S,Schema.hierarchy(~S)>,value => FailureText.message(S,Schema.hierarchy(~S),value),messages) ++ ",missed=" ++ Nat.show(missed) ++ ",tick=" ++ Tick.show(tick) ++ ")"
    case Failure.Refused{retained}:"refused(reader=" ++ Data.consumed(Target.Reader(~S),reader_retained(~S,retained)) ++ ")"
def read_finished(~S:Data,result:Schema.World(~S) & Read.Reading(~S)) -> String:
  match result:
    case (world,result):"reading=" ++ reading(~S,result) ++ "/postReadWorld=" ++ Data.world(~S,world)
def read_world(~S:Data,value:Schema.World(~S),reader:Maybe<&1,Target.Reader(~S)>) -> String:
  match reader:
    case None{}:"reader=none/world=" ++ Data.world(~S,value)
    case Some{reader}:read_finished(~S,Read.read(~S,value,reader))
def save_reason(value:Recipe.Refusal) -> String:
  match value:
    case Recipe.PlainUnserializable{key}:"plain(" ++ key ++ ")"
    case Recipe.InvalidProjection{key,error}:"projection(" ++ key ++ "," ++ Basic.decode_error(error) ++ ")"
    case Recipe.MalformedColumn{key}:"column(" ++ key ++ ")"
    case Recipe.DescriptorMismatch{expected,actual}:"descriptor(" ++ expected ++ "," ++ actual ++ ")"
def save_outcome(~S:Data,value:Gate.Outcome<Extended.Snapshot<S>,Recipe.Refusal>) -> String:
  match value:
    case Gate.Saved{snapshot}:"saved(" ++ Data.snapshot(~S,snapshot) ++ ")"
    case Gate.RefusedPending{}:"pending"
    case Gate.Refused{error}:"refused(" ++ save_reason(error) ++ ")"
def saved(~S:Data,retained:Maybe<&1,Target.Reader(~S)>,result:Admission.Recipes(~S) & (Schema.World(~S) & Gate.Outcome<Extended.Snapshot<S>,Recipe.Refusal>)) -> String:
  match result:
    case (schema,(world,Gate.Saved{snapshot})):"schema=" ++ Data.schema(~S,schema) ++ "/after=" ++ Data.snapshot(~S,snapshot) ++ "/" ++ read_world(~S,world,retained)
    case (schema,(world,Gate.RefusedPending{})):"save-pending/schema=" ++ Data.schema(~S,schema) ++ "/reader=" ++ reader(~S,retained) ++ "/world=" ++ Data.world(~S,world)
    case (schema,(world,Gate.Refused{error})):"save-refused(" ++ save_reason(error) ++ ")/schema=" ++ Data.schema(~S,schema) ++ "/reader=" ++ reader(~S,retained) ++ "/world=" ++ Data.world(~S,world)
def state_text(~S:Data,result:Admission.Recipes(~S) & String) -> String:
  match result:
    case (_,text):text
def receiver_reason(value:Receiver.Reason) -> String:
  match value:
    case Receiver.PendingWork{}:"pending-work"
    case Receiver.ActiveExecution{}:"active-execution"
    case Receiver.MalformedColumns{}:"malformed-columns"
    case Receiver.Capacity{}:"capacity"
type SavedApp<-S:Data> is Type:SavedApp{schema:Admission.Recipes(~S),app:Execution.Application(~S)}
def saved_app(~S:Data,value:SavedApp<S>,text:String) -> String:
  match value:
    case SavedApp{schema,Schedule.Scheduled{App.State{world,_,_,Execution.Handler{_,_,retained},_},_,_,_,_}}:text ++ "/" ++ saved(~S,retained,Save.save(~S,schema,world))
def resumed_app(~S:Data,schema:Admission.Recipes(~S),text:String,result:Execution.Application(~S) & String) -> String:
  match result:
    case (app,other):saved_app(~S,SavedApp{schema,app},text ++ "/application={" ++ other ++ "}")
def resumed_restoration(~S:Data,app:Execution.Application(~S),text:String,result:Admission.Recipes(~S) & String) -> String:
  match result:
    case (schema,other):resumed_app(~S,schema,text ++ "/restoration={" ++ other ++ "}",app_retained(~S,app))
type ResumedRest<-S:Data> is Type:ResumedRest{restoration:Restoration<S>,app:Execution.Application(~S),report:App.Report<String,String>}
def resumed_source(~S:Data,rest:ResumedRest<S>,text:String) -> String:
  match rest:
    case ResumedRest{receipt,app,report}:resumed_restoration(~S,app,"report=" ++ Basic.report(report) ++ "/source={" ++ text ++ "}",restoration(~S,receipt))
def resumed(~S:Data,original:Source<S>,receipt:Restoration<S>,app:Execution.Application(~S),report:App.Report<String,String>) -> String:
  resumed_source(~S,ResumedRest{receipt,app,report},source(~S,original))
def execution_restoration(~S:Data,value:Execution.Restoration<S>) -> String:
  match value:
    case Execution.Pending{schema,input,actual}:"pending/schema=" ++ Data.schema(~S,schema) ++ "/input=" ++ Data.snapshot(~S,input) ++ "/application={" ++ app(~S,actual) ++ "}"
    case Execution.InputRefused{actual,schema,input,reason}:"input-refused(" ++ Data.reason(reason) ++ ")/schema=" ++ Data.schema(~S,schema) ++ "/input=" ++ Data.snapshot(~S,input) ++ "/application={" ++ app(~S,actual) ++ "}"
    case Execution.NamespaceRefused{actual,state}:"namespace-refused/state={" ++ state_text(~S,restore_state(~S,state)) ++ "}/application={" ++ app(~S,actual) ++ "}"
    case Execution.ReceiverRefused{actual,state,reason}:"receiver-refused(" ++ receiver_reason(reason) ++ ")/state={" ++ state_text(~S,restore_state(~S,state)) ++ "}/application={" ++ app(~S,actual) ++ "}"
    case Execution.StagingRefused{actual,state,error}:"staging-refused(" ++ Basic.restore_error(error) ++ ")/state={" ++ state_text(~S,restore_state(~S,state)) ++ "}/application={" ++ app(~S,actual) ++ "}"
    case Execution.RowsRefused{actual,state,rows}:"rows-refused/state={" ++ state_text(~S,restore_state(~S,state)) ++ "}/rows=" ++ List.show(&1,Publication.Row<Schema.components(~S)>,Basic.publication_row(~S),rows) ++ "/application={" ++ app(~S,actual) ++ "}"
    case Execution.Restored{actual,state,removed,mapping,publications,previous}:"restored/state={" ++ state_text(~S,restoration(~S,Restoration{state,removed,mapping,publications,previous})) ++ "}/application={" ++ app(~S,actual) ++ "}"
    case Execution.Refused{_,_}:"unobserved-partial-restoration"
def definition(~S:Data,value:Execution.Defined<S>) -> String:
  match value:
    case Execution.Defined{actual}:"defined/application={" ++ app(~S,actual) ++ "}"
    case Execution.LeftRefused{world,local,retained}:"left-refused/local=" ++ Data.consumed(P.Local,local_retained(local)) ++ "/reader=" ++ reader(~S,retained) ++ "/world={" ++ Data.world(~S,world) ++ "}"
    case Execution.RightRefused{world,owner,local,retained}:"right-refused/left=" ++ Data.consumed(P.Left(~S),left(~S,owner)) ++ "/local=" ++ Data.consumed(P.Local,local_retained(local)) ++ "/reader=" ++ reader(~S,retained) ++ "/world={" ++ Data.world(~S,world) ++ "}"
    case Execution.GuardRefused{world,l,r,compiled,local,retained}:"guard-refused/left=" ++ Data.consumed(P.Left(~S),left(~S,l)) ++ "/right=" ++ Data.consumed(P.Right(~S),right(~S,r)) ++ "/compilation=" ++ Data.consumed(P.GuardCompilation(~S),compilation(~S,compiled)) ++ "/local=" ++ Data.consumed(P.Local,local_retained(local)) ++ "/reader=" ++ reader(~S,retained) ++ "/world={" ++ Data.world(~S,world) ++ "}"
type RestoreSavedRest<-S:Data> is Type:RestoreSavedRest{world:Schema.World(~S),reader:Maybe<&1,Target.Reader(~S)>}
def restore_saved(~S:Data,held:RestoreSavedRest<S>,result:Admission.Recipes(~S) & String) -> String:
  match held result:
    case RestoreSavedRest{world,reader}, (schema,text):"restored={" ++ text ++ "}/" ++ saved(~S,reader,Save.save(~S,schema,world))
def low_restoration(~S:Data,retained:Maybe<&1,Target.Reader(~S)>,value:Restore.Outcome<S>) -> String:
  match value:
    case Restore.Restored{state,world,removed,mapping,publications,previous}:restore_saved(~S,RestoreSavedRest{world,retained},restoration(~S,Restoration{state,removed,mapping,publications,previous}))
    case Restore.InputRefused{world,schema,input,reason}:"input-refused(" ++ Data.reason(reason) ++ ")/schema=" ++ Data.schema(~S,schema) ++ "/input=" ++ Data.snapshot(~S,input) ++ "/reader=" ++ reader(~S,retained) ++ "/world={" ++ Data.world(~S,world) ++ "}"
    case Restore.NamespaceRefused{state,world}:"namespace-refused/state={" ++ state_text(~S,restore_state(~S,state)) ++ "}/reader=" ++ reader(~S,retained) ++ "/world={" ++ Data.world(~S,world) ++ "}"
    case Restore.ReceiverRefused{state,Receiver.Refused{world,reason}}:"receiver-refused(" ++ receiver_reason(reason) ++ ")/state={" ++ state_text(~S,restore_state(~S,state)) ++ "}/reader=" ++ reader(~S,retained) ++ "/world={" ++ Data.world(~S,world) ++ "}"
    case _:"unobserved-partial-world-restoration"
type FlowRest<-S:Data> is Type:FlowRest{reader:Maybe<&1,Target.Reader(~S)>,result:Restore.Outcome<S>}
def flow_restored(~S:Data,rest:FlowRest<S>,text:String) -> String:
  match rest:
    case FlowRest{reader,result}:"source={" ++ text ++ "}/" ++ low_restoration(~S,reader,result)
def flow(~S:Data,value:Flow.Outcome<S>) -> String:
  match value:
    case Flow.Restored{world,previous,reader,receipt,result}:flow_restored(~S,FlowRest{reader,result},source(~S,Source{world,previous,receipt}))
    case _:"unobserved-source-preparation"
