import ../../src/ecs/execution-resource-admission.bend as ResourceAdmission
import ../../src/ecs/execution-resource-query-leaf.bend as Leaf
import ../../src/ecs/execution-resource-query-execution.bend as Execution
import ../../src/ecs/execution-generalized-root-application.bend as Application
import ../../src/ecs/dependency-application.bend as App
import ../../src/ecs/execution-parallel-scope.bend as Scope
import Base
import ../../src/ecs/execution-builder.bend as Build
import ./ordinary-sparse.bend as Run
import ./schema.bend as S
import ../common/column-observation.bend as Common
import ../../src/ecs/chunk-column.bend as Col
import ../../src/ecs/chunk-partition.bend as Part
import ../../src/ecs/execution-composer-layout.bend as L
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/world.bend as W
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-query.bend as Q
import ../../src/ecs/execution-query-preparation.bend as General
import ../../src/ecs/execution-query-admission.bend as Admission
import ../../src/ecs/execution-query-schema.bend as Schema
import ../../src/ecs/execution-query-recipe.bend as Recipe
import ../../src/ecs/execution-query-matches.bend as Match
import ../../src/ecs/execution-query-domain.bend as Domain
import ../../src/ecs/execution-prepared.bend as Prep
import ../../src/ecs/execution-parallel-schedule.bend as Ready
import ../../src/ecs/dependency-executor.bend as Exec
import ../../src/ecs/execution-command-buffer.bend as Commands
import ../../src/ecs/execution-lifecycle-notices.bend as Notice
import ../../src/ecs/change-tick.bend as Tick
import ../../src/ecs/lifecycle.bend as Life
import ../../src/ecs/deferred-command.bend as Deferred
import ../../src/ecs/execution-compiled-binding.bend as Binding

def array_pair(left:Array<U32> & String,right:Array<U32> & String) -> Array<U32> & String:
  match left right:
    case (l,lt), (r,rt):(ANode{l,r},"[" ++ lt ++ "," ++ rt ++ "]")
def array(value:Array<U32>) -> Array<U32> & String:
  match value:
    case ALeaf{+n}:(ALeaf{n},U32.show(n))
    case ANode{left,right}:array_pair(array(left),array(right))
def position_array(result:Array<U32> & String) -> S.Position & String:
  match result:
    case (values,text):(S.Position{values},text)
def position(owner:S.Position) -> S.Position & String:
  match owner:
    case S.Position{values}:position_array(array(values))
def shield_array(+label:String,result:Array<U32> & String) -> S.Shield & String:
  match result:
    case (values,text):(S.Shield{label,values},label ++ ":" ++ text)
def shield(owner:S.Shield) -> S.Shield & String:
  match owner:
    case S.Shield{+label,values}:shield_array(label,array(values))
def viewed_returned(~P:Type,+cache:U32,result:P & String) -> L.Viewed<P,U32> & String:
  match result:
    case (owner,text):(L.Viewed{owner,cache},text ++ "/cache=" ++ U32.show(cache))
def viewed(~P:Type,~project:P -> P & String,owner:L.Viewed<P,U32>) -> L.Viewed<P,U32> & String:
  match owner:
    case L.Viewed{owner,cache}:viewed_returned(~P,cache,project(owner))
def handle(value:W.Handle<S.SchemaA>) -> String:
  match value:
    case W.Handle{namespace,key}:U32.show(namespace) ++ ":" ++ Common.key(key)
def route(value:L.Route) -> String:
  match value:
    case L.AtLeaf{}:"."
    case L.InLeft{rest}:"L" ++ route(rest)
    case L.InRight{rest}:"R" ++ route(rest)
def bound(value:Recipe.Bound) -> String:
  match value:
    case Recipe.AllLive{}:"all"
    case Recipe.With{at}:"with(" ++ route(at) ++ ")"
    case Recipe.Without{at}:"without(" ++ route(at) ++ ")"
    case Recipe.And{left,right}:"and(" ++ bound(left) ++ "," ++ bound(right) ++ ")"
    case Recipe.Or{left,right}:"or(" ++ bound(left) ++ "," ++ bound(right) ++ ")"
    case Recipe.Changed{at}:"changed(" ++ route(at) ++ ")"
def kind(value:Recipe.QueryKind) -> String:
  match value:
    case Recipe.ReadRows{}:"read"
    case Recipe.WriteRows{}:"write"
def presence(value:Match.Presence) -> String:
  match value:
    case Match.Required{}:"required"
    case Match.Optional{}:"optional"
    case Match.With{}:"with"
    case Match.Without{}:"without"
def entry(value:Recipe.Entry) -> String:
  match value:
    case Recipe.Entry{at,mode,selection,member}:route(at) ++ ":" ++ kind(mode) ++ ":" ++ bound(selection) ++ ":" ++ presence(member)
def recipe(value:Recipe.Recipe<S.SchemaA,Run.WC()>) -> String:
  match value:
    case Recipe.Recipe{value}:entry(value)
def inserted(value:U32,head:U32,rest:List<&2,U32>,tail:List<&2,U32>,first:Bool) -> List<&2,U32>:
  match first:
    case True{}:value <> head <> rest
    case False{}:head <> tail
def insert(+value:U32,items:List<&2,U32>) -> List<&2,U32>:
  match items:
    case []:[value]
    case +head <> +rest:inserted(value,head,rest,insert(value,rest),U32.is_lt(value,head))
def sorted(items:List<&2,U32>) -> List<&2,U32>:
  match items:
    case []:[]
    case head <> rest:insert(head,sorted(rest))
def domain(value:Domain.Domain) -> String:
  match value:
    case Domain.Domain{offsets}:List.show(&2,U32,U32.show,sorted(offsets))
def info(value:Schema.Info) -> String:
  match value:
    case Schema.Info{at,capacity,present}:route(at) ++ ":" ++ U32.show(capacity) ++ ":" ++ domain(present)
def physical_recipe(value:Match.Recipe) -> String:
  match value:
    case Match.Read{value}:"read" ++ domain(value)
    case Match.Write{value}:"write" ++ domain(value)
    case Match.Both{left,right}:"both(" ++ physical_recipe(left) ++ "," ++ physical_recipe(right) ++ ")"
def book_entry(value:Schema.Entry) -> String:
  match value:
    case Schema.Entry{at,recipe}:route(at) ++ ":" ++ physical_recipe(recipe)
def book(value:Schema.Book<S.SchemaA,S.layout_a()>) -> String:
  match value:
    case Schema.Book{entries}:List.show(&2,Schema.Entry,book_entry,entries)
def grant(value:Admission.Granted<S.SchemaA,Run.WC()>) -> String:
  match value:
    case Admission.Granted{decl,handles}:entry(decl) ++ ":" ++ List.show(&2,W.Handle<S.SchemaA>,handle,handles)
def evidence(~program:Build.FrameworkProgram(~S.SchemaA,~Run.WC(),~Run.HStore(),~Run.HResources(),~Run.Ops),value:Maybe<&2,ResourceAdmission.Evidence<S.SchemaA,S.layout_a(),L.EmptyLayout{},Run.HStore(),Run.HResources(),Run.Ops,program>>) -> String:
  match value:
    case Some{ResourceAdmission.Evidence{namespace,handles,recipes,resources,information,resourceInfo,grants,domains,resourceBook}}:"namespace=" ++ U32.show(namespace) ++ ";handles=" ++ List.show(&2,W.Handle<S.SchemaA>,handle,handles) ++ ";recipes=" ++ List.show(&2,Recipe.Recipe<S.SchemaA,Run.WC()>,recipe,recipes) ++ ";info=" ++ List.show(&2,Schema.Info,info,information) ++ ";grants=" ++ List.show(&2,Admission.Granted<S.SchemaA,Run.WC()>,grant,grants) ++ ";book=" ++ book(domains)
    case None{}:"unavailable"
def permit(value:Prep.Permit<S.SchemaA,Run.WC()>) -> String:
  match value:
    case Prep.Permit{namespace,id,allowed,tick}:U32.show(namespace) ++ ":" ++ U32.show(id) ++ ":" ++ Bool.pick(String,allowed,"true","false") ++ ":" ++ Tick.show(tick)
def provenance(value:Prep.Provenance<Prep.Permit<S.SchemaA,Run.WC()>>) -> String:
  match value:
    case Prep.Unprepared{}:"unprepared"
    case Prep.Leaf{namespace,permits}:"leaf(" ++ U32.show(namespace) ++ ":" ++ List.show(&2,Prep.Permit<S.SchemaA,Run.WC()>,permit,permits) ++ ")"
    case Prep.Pair{left,right}:"pair(" ++ provenance(left) ++ "," ++ provenance(right) ++ ")"
def position_text(owner:S.Position) -> String:Common.projected(~S.Position,position(owner))
def incoming(value:Maybe<&1,S.Position>) -> String:
  match value:
    case None{}:"none"
    case Some{owner}:position_text(owner)
def command(value:Commands.Entry<S.SchemaA,S.Position,Unit>) -> String:
  match value:
    case Commands.Entry{entity,value}:handle(entity) ++ ":" ++ incoming(value)
    case Commands.Despawn{entity}:"despawn:" ++ handle(entity)
    case _:"other-command"
def receipt(value:Commands.Receipt<S.SchemaA,S.Position,Unit>) -> String:
  match value:
    case Commands.Applied{entity,previous}:"applied:" ++ handle(entity) ++ ":" ++ incoming(previous)
    case Commands.Refused{entity,value}:"refused:" ++ handle(entity) ++ ":" ++ incoming(value)
    case Commands.Despawned{entity,_}:"despawned:" ++ handle(entity)
    case Commands.DespawnRefused{entity}:"despawn-refused:" ++ handle(entity)
    case Commands.LinkedDespawn{entity,_,_,_}:"linked-despawn:" ++ handle(entity)
    case _:"other-receipt"
def queue(value:Commands.Buffer<S.SchemaA,S.Position,Unit>) -> String:
  match value:
    case Commands.Buffer{pending,receipts}:"pending=" ++ List.show(&1,Commands.Entry<S.SchemaA,S.Position,Unit>,command,pending) ++ ";receipts=" ++ List.show(&1,Commands.Receipt<S.SchemaA,S.Position,Unit>,receipt,receipts)
def probe(result:S.Position & Array<U32>) -> String:
  match result:
    case (owner,token):"unused(probe=" ++ position_text(owner) ++ ";token=" ++ Common.projected(~Array<U32>,array(token)) ++ ")"
def token(value:Run.Token) -> String:
  match value:
    case Run.Token{value}:Common.projected(~Array<U32>,array(value))
    case Run.DeferredToken{transform}:probe(transform(S.Position{[901 : U32^1n]}))
def local(value:Run.Local) -> String:
  match value:
    case Run.Local{target,value,commands}:"target=" ++ handle(target) ++ ";token=" ++ token(value) ++ ";" ++ queue(commands)
def left_owner(value:Run.LeftOwner()) -> String:
  match value:
    case Sys.Owner{namespace,id,name,access,cursor,state}:U32.show(namespace) ++ ":" ++ U32.show(id) ++ ":" ++ name ++ ":" ++ List.show(&2,String,value=>value,access) ++ ":" ++ Tick.cursor_show(cursor) ++ ":{" ++ local(state) ++ "}"
def right_owner(value:Run.RightOwner()) -> String:
  match value:
    case Sys.Owner{namespace,id,name,access,cursor,state}:U32.show(namespace) ++ ":" ++ U32.show(id) ++ ":" ++ name ++ ":" ++ List.show(&2,String,value=>value,access) ++ ":" ++ Tick.cursor_show(cursor) ++ ":{" ++ local(state) ++ "}"
def binding(~Owner:Type,~Evidence:Data,~owner:Owner -> String,~observed:Evidence -> String,value:Binding.Binding<Run.Compilation(),W.World<S.SchemaA,Run.WC(),Unit,Unit>,Owner,Evidence,Prep.Permit<S.SchemaA,Run.WC()>>) -> String:
  match value:
    case Binding.Binding{_,Prep.Prepared{namespace,state,permits,origin},evidence}:"namespace=" ++ U32.show(namespace) ++ ";owner={" ++ owner(state) ++ "};permits=" ++ List.show(&2,Prep.Permit<S.SchemaA,Run.WC()>,permit,permits) ++ ";provenance=" ++ provenance(origin) ++ ";evidence={" ++ observed(evidence) ++ "}"
def optional(value:Maybe<&2,U32>) -> String:
  match value:
    case None{}:"none"
    case Some{n}:U32.show(n)
def lookup(value:Q.GeneralLookup<U32>) -> String:
  match value:
    case Q.MissingEntity{}:"missing"
    case Q.NotMatched{}:"excluded"
    case Q.LookupRefused{}:"refused"
    case Q.Matched{value}:"matched:" ++ optional(value)
def invocation(value:Exec.Invocation<String,Q.GeneralLookup<U32>>) -> String:
  match value:
    case Exec.AdmissionRefused{}:"admission-refused"
    case Exec.Completed{value}:"success:" ++ lookup(value)
    case Exec.BodyError{error,value}:"error:" ++ error ++ ":" ++ lookup(value)
def status(value:Ready.Completed<String,Q.GeneralLookup<U32>>) -> String:
  match value:
    case Ready.Completed{id,value}:U32.show(id) ++ ":" ++ invocation(value)
def notice_identity(value:Notice.Identity<S.SchemaA>) -> String:
  match value:
    case Notice.Identity{namespace,key}:U32.show(namespace) ++ ":" ++ Common.key(key)
def notice_row(value:Notice.Row<S.SchemaA>) -> String:
  match value:
    case Notice.Row{sequence,entity,tick}:Nat.show(sequence) ++ ":" ++ notice_identity(entity) ++ ":" ++ Tick.show(tick)
def notice_selector(value:Notice.Selector) -> String:
  match value:
    case Notice.Removed{key}:"removed:" ++ key
    case Notice.Despawned{}:"despawned"
def notice_channel(value:Notice.Channel<S.SchemaA>) -> String:
  match value:
    case Notice.Channel{selector,next,previous,current,dropped}:notice_selector(selector) ++ ":" ++ Nat.show(next) ++ ":" ++ List.show(&2,Notice.Row<S.SchemaA>,notice_row,previous) ++ ":" ++ List.show(&2,Notice.Row<S.SchemaA>,notice_row,current) ++ ":" ++ Nat.show(dropped)
def notice_active(value:Notice.Active) -> String:
  match value:
    case Notice.Active{id,selector}:U32.show(id) ++ ":" ++ notice_selector(selector)
def journal(value:Notice.Journal<S.SchemaA>) -> String:
  match value:
    case Notice.Journal{namespace,channels,next,active}:U32.show(namespace) ++ ":" ++ List.show(&2,Notice.Channel<S.SchemaA>,notice_channel,channels) ++ ":" ++ U32.show(next) ++ ":" ++ List.show(&2,Notice.Active,notice_active,active)
def world(value:W.World<S.SchemaA,Run.WC(),Unit,Unit>) -> String:
  match value:
    case W.World{namespace,allocator,Product.Owner{L.ColumnSlot{positions},L.ColumnSlot{shields}},Unit{},events,pending,registrations,next,clock,lifecycle}:"namespace=" ++ U32.show(namespace) ++ ";allocator={" ++ Common.allocator(allocator) ++ "};position=" ++ Common.capacity_done(~S.SchemaA,~L.Viewed<S.Position,U32>,~viewed(~S.Position,~position),Col.capacity(~S.SchemaA,~L.Viewed<S.Position,U32>,positions)) ++ ";shield=" ++ Common.capacity_done(~S.SchemaA,~L.Viewed<S.Shield,U32>,~viewed(~S.Shield,~shield),Col.capacity(~S.SchemaA,~L.Viewed<S.Shield,U32>,shields)) ++ ";events=" ++ Nat.show(List.length(&2,Unit,events)) ++ ";pending=" ++ Nat.show(List.length(&1,Deferred.Command<W.World<S.SchemaA,Run.WC(),Unit,Unit>>,pending)) ++ ";registrations=" ++ List.show(&2,W.RegistrationMeta,Common.registration,registrations) ++ ";next=" ++ U32.show(next) ++ ";clock=" ++ Common.clock(clock) ++ ";journal=" ++ journal(lifecycle)
def position_cell(value:Part.Cell<L.Viewed<S.Position,U32>>) -> String:
  match value:
    case Part.Cell{offset,None{},stamp}:U32.show(offset) ++ ":none:" ++ Common.stamp_text(Some{stamp})
    case Part.Cell{offset,Some{owner},stamp}:U32.show(offset) ++ ":" ++ Common.projected(~L.Viewed<S.Position,U32>,viewed(~S.Position,~position,owner)) ++ ":" ++ Common.stamp_text(Some{stamp})
def shield_cell(value:Part.Cell<L.Viewed<S.Shield,U32>>) -> String:
  match value:
    case Part.Cell{offset,None{},stamp}:U32.show(offset) ++ ":none:" ++ Common.stamp_text(Some{stamp})
    case Part.Cell{offset,Some{owner},stamp}:U32.show(offset) ++ ":" ++ Common.projected(~L.Viewed<S.Shield,U32>,viewed(~S.Shield,~shield,owner)) ++ ":" ++ Common.stamp_text(Some{stamp})
def displaced(value:Schema.displacements(~S.SchemaA,S.layout_a())) -> String:
  match value:
    case Product.Owner{left,right}:List.show(&1,Part.Cell<L.Viewed<S.Position,U32>>,position_cell,left) ++ "/" ++ List.show(&1,Part.Cell<L.Viewed<S.Shield,U32>>,shield_cell,right)
def node(~Owner:Type,~Evidence:Data,~owner:Owner -> String,~observed:Maybe<&2,Evidence> -> String,value:Leaf.Node<Run.Compilation(),Run.World(),Owner,Evidence,Prep.Permit<S.SchemaA,Run.WC()>>) -> String:
  match value:
    case Leaf.Uninspected{Scope.CompiledBinding{_,state}}:"uninspected;owner={" ++ owner(state) ++ "}"
    case Leaf.Inspected{Scope.CompiledBinding{_,state},value,id,valid}:"inspected=" ++ U32.show(id) ++ ":" ++ Bool.pick(String,valid,"true","false") ++ ";owner={" ++ owner(state) ++ "};evidence={" ++ observed(value) ++ "}"
    case Leaf.Prepared{Execution.HeldReady{value}}:binding(~Owner,~Maybe<&2,Evidence>,~owner,~observed,value)
    case Leaf.Prepared{Execution.HeldInventory{_,_,value}}:"preparation-inventory;evidence={" ++ observed(value) ++ "}"
def event(value:Exec.Observation<String,Q.GeneralLookup<U32>>) -> String:
  match value:
    case Exec.Ran{id,value}:U32.show(id) ++ ":success:" ++ lookup(value)
    case Exec.BodyFailed{id,error,value}:U32.show(id) ++ ":error:" ++ error ++ ":" ++ lookup(value)
    case Exec.Skipped{id}:U32.show(id) ++ ":disabled"
    case Exec.ConditionFailed{id,error}:U32.show(id) ++ ":condition-error:" ++ error
    case Exec.ConditionRejected{id}:U32.show(id) ++ ":condition-refused"
    case Exec.AdmissionRejected{id}:U32.show(id) ++ ":admission-refused"
def report(value:App.Report<String,Q.GeneralLookup<U32>>) -> String:
  match value:
    case App.Finished{events}:"finished:" ++ List.show(&2,Exec.Observation<String,Q.GeneralLookup<U32>>,event,events)
    case App.Stopped{error,events}:"stopped:" ++ error ++ ":" ++ List.show(&2,Exec.Observation<String,Q.GeneralLookup<U32>>,event,events)
    case App.Invalid{_}:"invalid"
def result(value:Run.WorldResult) -> String:
  match value:
    case Run.WorldReturned{Application.Present{actual,moved},Product.Owner{left,right},handler,outcome}:"world={" ++ world(actual) ++ "};displaced=" ++ List.show(&1,Schema.displacements(~S.SchemaA,S.layout_a()),displaced,moved) ++ ";left={" ++ node(~Run.LeftOwner(),~ResourceAdmission.Evidence<S.SchemaA,S.layout_a(),L.EmptyLayout{},Run.HStore(),Run.HResources(),Run.Ops,Run.left_program>,~left_owner,~evidence(~Run.left_program),left) ++ "};right={" ++ node(~Run.RightOwner(),~ResourceAdmission.Evidence<S.SchemaA,S.layout_a(),L.EmptyLayout{},Run.HStore(),Run.HResources(),Run.Ops,Run.right_program>,~right_owner,~evidence(~Run.right_program),right) ++ "};handler=" ++ U32.show(handler) ++ ";report=" ++ report(outcome)
    case _:"unexpected-unreassembled"
def seeded(value:Run.SeedRun) -> String:
  match value:
    case Run.SeedRun{W.Factory{next},value}:"factory=" ++ U32.show(next) ++ ";" ++ result(value)
    case Run.SeedRunRefused{W.Factory{next},Unit{}}:"seed-refused:" ++ U32.show(next)
def printed(+label:String,result:Run.SeedRun) -> IO(Unit):IO.print(label ++ seeded(result))
def mode(+label:String,target:Run.TargetMode) -> IO(Unit):IO.bind(Run.SeedRun,Unit,Run.run_mode(W.factory(),target),result => printed(label,result))
def main() -> IO(Unit):
  IO.bind(Unit,Unit,IO.bind(Run.SeedRun,Unit,Run.run(W.factory()),result => printed("baseline=",result)),_ => IO.bind(Unit,Unit,mode("absent=",Run.Target{6}),_ => IO.bind(Unit,Unit,mode("excluded=",Run.Target{1}),_ => IO.bind(Unit,Unit,mode("foreign=",Run.ForeignTarget{}),_ => IO.bind(Unit,Unit,mode("stale=",Run.StaleTarget{}),_ => IO.bind(Unit,Unit,mode("zero=",Run.ZeroTarget{}),_ => mode("outside=",Run.OutsideTarget{})))))))
