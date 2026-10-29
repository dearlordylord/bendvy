import Base
import ../../src/ecs/world.bend as W
import ../../src/ecs/execution-command-buffer.bend as Buffer
import ../../src/ecs/execution-command-permission.bend as Permission
import ../../src/ecs/execution-reservation-bundle.bend as Bundle
import ../../src/ecs/change-tick.bend as Tick
import ../parallel-query/observation.bend as Text
import ./schema.bend as D
import ./gameplay.bend as G
import ./system.bend as Step
import ./spawn.bend as Spawn
import ./root.bend as Root
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-command-system.bend as Cmd
import ../../src/ecs/execution-command-local.bend as Local
import ../../src/ecs/execution-parallel-scope.bend as Scope
import ../../src/ecs/execution-resource-query-leaf.bend as Leaf
import ../../src/ecs/execution-resource-query-execution.bend as Execution
import ../../src/ecs/execution-resource-admission.bend as Admission
import ../../src/ecs/execution-compiled-binding.bend as Binding
import ../../src/ecs/execution-prepared.bend as Prep
import ../../src/ecs/execution-declaration.bend as Decl
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/execution-parallel-root-application.bend as Scheduled
import ../../src/ecs/dependency-application.bend as App

def rebuilt(~Owner:Type,~Node:Type,~Out:Data,rebuild:Owner -> Node,result:Owner & Out) -> Node & Out:
  match result:
    case (owner,out):(rebuild(owner),out)
def node(~Compilation:Type,~World:Type,~Owner:Type,~Evidence:Data,~Permit:Data,~Out:Data,update:Owner -> Owner & Out,held:Leaf.Node<Compilation,World,Owner,Evidence,Permit>) -> Leaf.Node<Compilation,World,Owner,Evidence,Permit> & Out:
  match held:
    case Leaf.Uninspected{Scope.CompiledBinding{compilation,owner}}:rebuilt(~Owner,~Leaf.Node<Compilation,World,Owner,Evidence,Permit>,~Out,owner=>Leaf.Uninspected{Scope.CompiledBinding{compilation,owner}},update(owner))
    case Leaf.Inspected{Scope.CompiledBinding{compilation,owner},evidence,id,valid}:rebuilt(~Owner,~Leaf.Node<Compilation,World,Owner,Evidence,Permit>,~Out,owner=>Leaf.Inspected{Scope.CompiledBinding{compilation,owner},evidence,id,valid},update(owner))
    case Leaf.Prepared{Execution.HeldReady{Binding.Binding{compilation,Prep.Prepared{namespace,owner,permits,provenance},evidence}}}:rebuilt(~Owner,~Leaf.Node<Compilation,World,Owner,Evidence,Permit>,~Out,owner=>Leaf.Prepared{Execution.HeldReady{Binding.Binding{compilation,Prep.Prepared{namespace,owner,permits,provenance},evidence}}},update(owner))
    case Leaf.Prepared{Execution.HeldInventory{compilation,Prep.Inventory{owner,provenance},evidence}}:rebuilt(~Owner,~Leaf.Node<Compilation,World,Owner,Evidence,Permit>,~Out,owner=>Leaf.Prepared{Execution.HeldInventory{compilation,Prep.Inventory{owner,provenance},evidence}},update(owner))
def SpawnOwner() -> Type:Cmd.System(~D.Schema,~Step.C(),~Step.R(),~Unit,~D.components(),~D.resources(),~Spawn.route(),~Spawn.Ops,~Spawn.User,~String,~Unit,~Spawn.declaration,~Spawn.body)
def StepOwner() -> Type:Cmd.System(~D.Schema,~Step.C(),~Step.R(),~Unit,~D.components(),~D.resources(),~Step.route(),~Step.Ops,~Step.User,~String,~Unit,~Step.declaration,~Step.body)
def seeded(seeds:List<&2,G.Body>,owner:SpawnOwner()) -> SpawnOwner() & Unit:
  match owner:
    case Sys.Owner{namespace,id,name,access,cursor,Local.Local{Spawn.User{prior,handles,returned,player},commands,permission}}:(Sys.Owner{namespace,id,name,access,cursor,Local.Local{Spawn.User{List.append(&2,G.Body,prior,seeds),handles,returned,player},commands,permission}},Unit{})
def configured(args:G.Args,owner:StepOwner()) -> StepOwner() & Unit:
  match owner:
    case Sys.Owner{namespace,id,name,access,cursor,Local.Local{_,commands,permission}}:(Sys.Owner{namespace,id,name,access,cursor,Local.Local{Step.User{True{},args,[]},commands,permission}},Unit{})
def observed(owner:StepOwner()) -> StepOwner() & List<&2,G.Row>:
  match owner:
    case Sys.Owner{namespace,id,name,access,cursor,Local.Local{Step.User{active,args,+rows},commands,permission}}:(Sys.Owner{namespace,id,name,access,cursor,Local.Local{Step.User{active,args,rows},commands,permission}},rows)
def spawn_node(seeds:List<&2,G.Body>,held:Spawn.Node()) -> Spawn.Node() & Unit:
  node(~Root.Compilation(),~D.World(),~SpawnOwner(),~Admission.Evidence<D.Schema,D.components(),D.resources(),Step.C(),Step.R(),Cmd.ScopedOps(~D.Schema,~D.components(),~D.resources(),~Spawn.route(),~Spawn.Ops),Cmd.program_for_buffer(~D.Schema,~Step.C(),~Step.R(),~D.components(),~D.resources(),~Spawn.route(),~Spawn.Ops,~Spawn.declaration)>,~Prep.Permit<D.Schema,D.Columns()>,~Unit,seeded(seeds),held)
def step_node(args:G.Args,held:Step.Node()) -> Step.Node() & Unit:
  node(~Root.PeerCompilation(),~D.World(),~StepOwner(),~Admission.Evidence<D.Schema,D.components(),D.resources(),Step.C(),Step.R(),Cmd.ScopedOps(~D.Schema,~D.components(),~D.resources(),~Step.route(),~Step.Ops),Cmd.program_for_buffer(~D.Schema,~Step.C(),~Step.R(),~D.components(),~D.resources(),~Step.route(),~Step.Ops,~Step.declaration)>,~Prep.Permit<D.Schema,D.Columns()>,~Unit,configured(args),held)
def step_rows(held:Step.Node()) -> Step.Node() & List<&2,G.Row>:
  node(~Root.PeerCompilation(),~D.World(),~StepOwner(),~Admission.Evidence<D.Schema,D.components(),D.resources(),Step.C(),Step.R(),Cmd.ScopedOps(~D.Schema,~D.components(),~D.resources(),~Step.route(),~Step.Ops),Cmd.program_for_buffer(~D.Schema,~Step.C(),~Step.R(),~D.components(),~D.resources(),~Step.route(),~Step.Ops,~Step.declaration)>,~Prep.Permit<D.Schema,D.Columns()>,~List<&2,G.Row>,observed,held)
def nodes_updated(left:Spawn.Node() & Unit,right:Step.Node() & Unit) -> Root.Nodes():
  match left right:
    case (left,_),(right,_):Product.Owner{left,right}
def configure(seeds:List<&2,G.Body>,args:G.Args,app:Root.Application()) -> Root.Application():
  match app:
    case Scheduled.Scheduled{App.State{world,Product.Owner{left,right},guards,handler,stateBindings},plan,bindings,rules,deferred}:Scheduled.Scheduled{App.State{world,nodes_updated(spawn_node(seeds,left),step_node(args,right)),guards,handler,stateBindings},plan,bindings,rules,deferred}
def returned(rebuild:Step.Node() -> Root.Application(),result:Step.Node() & List<&2,G.Row>) -> Root.Application() & List<&2,G.Row>:
  match result:
    case (right,rows):(rebuild(right),rows)
def rows(app:Root.Application()) -> Root.Application() & List<&2,G.Row>:
  match app:
    case Scheduled.Scheduled{App.State{world,Product.Owner{left,right},guards,handler,stateBindings},plan,bindings,rules,deferred}:returned(right=>Scheduled.Scheduled{App.State{world,Product.Owner{left,right},guards,handler,stateBindings},plan,bindings,rules,deferred},step_rows(right))

# Read-only fixture snapshots return the same owners and queue entries.
def body_text(body:G.Body) -> String:
  match body:
    case G.Body{x,y,kind,seed,hp,speed,target,visited,age}:"(" ++ F32.show(x) ++ "," ++ F32.show(y) ++ "," ++ U32.show(kind) ++ "," ++ U32.show(seed) ++ "," ++ U32.show(hp) ++ "," ++ F32.show(speed) ++ "," ++ U32.show(target) ++ "," ++ List.show(&2,U32,U32.show,visited) ++ "," ++ U32.show(age) ++ ")"
def handle_text(handle:W.Handle<D.Schema>) -> String:
  match handle:
    case W.Handle{namespace,key}:U32.show(namespace) ++ ":" ++ Text.key(key)
def maybe_handle(value:Maybe<&2,W.Handle<D.Schema>>) -> String:
  match value:
    case None{}:"none"
    case Some{handle}:handle_text(handle)
def maybe_body(value:Maybe<&1,G.Body>) -> Maybe<&1,G.Body> & String:
  match value:
    case None{}:(None{},"none")
    case Some{+body}:(Some{body},body_text(body))
def named(~T:Type,~V:Type,rebuild:V -> T,prefix:String,result:V & String) -> T & String:
  match result:
    case (value,text):(rebuild(value),prefix ++ text)
def owned_cons(~T:Type,head:T,text:String,result:List<&1,T> & String) -> List<&1,T> & String:
  match result:
    case (rest,tail):(head <> rest,text ++ ";" ++ tail)
def owned_head(~T:Type,tail:Unit -> List<&1,T> & String,result:T & String) -> List<&1,T> & String:
  match result:
    case (head,text):owned_cons(~T,head,text,tail(Unit{}))
def owned_list(~T:Type,~project:T -> T & String,values:List<&1,T>) -> List<&1,T> & String:
  match values:
    case []:([],"")
    case head <> rest:owned_head(~T,_=>owned_list(~T,~project,rest),project(head))
def Queue() -> Type:Buffer.Buffer<D.Schema,G.Body,Maybe<&1,G.Body>>
def entry(value:Buffer.Entry<D.Schema,G.Body,Maybe<&1,G.Body>>) -> Buffer.Entry<D.Schema,G.Body,Maybe<&1,G.Body>> & String:
  match value:
    case Buffer.Entry{+handle,payload}:named(~Buffer.Entry<D.Schema,G.Body,Maybe<&1,G.Body>>,~Maybe<&1,G.Body>,payload=>Buffer.Entry{handle,payload},"component:" ++ handle_text(handle) ++ ":",maybe_body(payload))
    case Buffer.Spawn{+handle,payload}:named(~Buffer.Entry<D.Schema,G.Body,Maybe<&1,G.Body>>,~Maybe<&1,G.Body>,payload=>Buffer.Spawn{handle,payload},"spawn:" ++ handle_text(handle) ++ ":",maybe_body(payload))
    case Buffer.Despawn{+handle}:(Buffer.Despawn{handle},"despawn:" ++ handle_text(handle))
    case value:(value,"unexpected-non-arena-entry")
def refusal(value:Bundle.Refusal) -> String:
  match value:
    case Bundle.InvalidPending{_}:"invalid-pending"
    case Bundle.PermissionDenied{}:"permission-denied"
    case Bundle.DuplicateFamily{}:"duplicate-family"
    case Bundle.PhysicalIndex{}:"physical-index"
    case Bundle.MalformedColumn{key}:"malformed:" ++ key
    case Bundle.OccupiedFamily{key}:"occupied:" ++ key
def receipt(value:Buffer.Receipt<D.Schema,G.Body,Maybe<&1,G.Body>>) -> Buffer.Receipt<D.Schema,G.Body,Maybe<&1,G.Body>> & String:
  match value:
    case Buffer.Applied{+handle,payload}:named(~Buffer.Receipt<D.Schema,G.Body,Maybe<&1,G.Body>>,~Maybe<&1,G.Body>,payload=>Buffer.Applied{handle,payload},"applied:" ++ handle_text(handle) ++ ":",maybe_body(payload))
    case Buffer.Refused{+handle,payload}:named(~Buffer.Receipt<D.Schema,G.Body,Maybe<&1,G.Body>>,~Maybe<&1,G.Body>,payload=>Buffer.Refused{handle,payload},"refused:" ++ handle_text(handle) ++ ":",maybe_body(payload))
    case Buffer.Despawned{+handle,payload}:named(~Buffer.Receipt<D.Schema,G.Body,Maybe<&1,G.Body>>,~Maybe<&1,G.Body>,payload=>Buffer.Despawned{handle,payload},"despawned:" ++ handle_text(handle) ++ ":",maybe_body(payload))
    case Buffer.DespawnRefused{+handle}:(Buffer.DespawnRefused{handle},"despawn-refused:" ++ handle_text(handle))
    case Buffer.Spawned{+handle,payload}:named(~Buffer.Receipt<D.Schema,G.Body,Maybe<&1,G.Body>>,~Maybe<&1,G.Body>,payload=>Buffer.Spawned{handle,payload},"spawned:" ++ handle_text(handle) ++ ":",maybe_body(payload))
    case Buffer.SpawnRefused{+handle,payload,+reason}:named(~Buffer.Receipt<D.Schema,G.Body,Maybe<&1,G.Body>>,~Maybe<&1,G.Body>,payload=>Buffer.SpawnRefused{handle,payload,reason},"spawn-refused:" ++ handle_text(handle) ++ ":" ++ refusal(reason) ++ ":",maybe_body(payload))
    case value:(value,"unexpected-non-arena-receipt")
def queue_values(pending:List<Buffer.Entry<D.Schema,G.Body,Maybe<&1,G.Body>>> & String,receipts:List<Buffer.Receipt<D.Schema,G.Body,Maybe<&1,G.Body>>> & String) -> Queue() & String:
  match pending receipts:
    case (pending,pt), (receipts,rt):(Buffer.Buffer{pending,receipts},"pending=[" ++ pt ++ "];receipts=[" ++ rt ++ "]")
def queue(value:Queue()) -> Queue() & String:
  match value:
    case Buffer.Buffer{pending,receipts}:queue_values(owned_list(~Buffer.Entry<D.Schema,G.Body,Maybe<&1,G.Body>>,~entry,pending),owned_list(~Buffer.Receipt<D.Schema,G.Body,Maybe<&1,G.Body>>,~receipt,receipts))
def header(namespace:U32,id:U32,name:String,access:List<&2,String>,cursor:Maybe<&2,Tick.Tick>,permission:Permission.Permission) -> String:
  U32.show(namespace) ++ ":" ++ U32.show(id) ++ ":" ++ name ++ ":" ++ List.show(&2,String,text=>text,access) ++ ":cursor=" ++ Tick.cursor_show(cursor) ++ ":structural=" ++ Bool.show(Permission.agrees(permission,Permission.EntityStructural{}))
def spawn_values(rebuild:Spawn.User -> Queue() -> SpawnOwner(),prefix:String,+seeds:List<&2,G.Body>,+handles:List<&2,W.Handle<D.Schema>>,+player:Maybe<&2,W.Handle<D.Schema>>,returned:List<Maybe<&1,G.Body>> & String,queued:Queue() & String) -> SpawnOwner() & String:
  match returned queued:
    case (returned,rt),(queue,qt):(rebuild(Spawn.User{seeds,handles,returned,player},queue),prefix ++ ";seeds=" ++ List.show(&2,G.Body,body_text,seeds) ++ ";handles=" ++ List.show(&2,W.Handle<D.Schema>,handle_text,handles) ++ ";player=" ++ maybe_handle(player) ++ ";returned=[" ++ rt ++ "];" ++ qt)
def spawn_snapshot(owner:SpawnOwner()) -> SpawnOwner() & String:
  match owner:
    case Sys.Owner{+namespace,+id,+name,+access,+cursor,Local.Local{Spawn.User{seeds,handles,returned,player},commands,+permission}}:spawn_values(user=>commands=>Sys.Owner{namespace,id,name,access,cursor,Local.Local{user,commands,permission}},header(namespace,id,name,access,cursor,permission),seeds,handles,player,owned_list(~Maybe<&1,G.Body>,~maybe_body,returned),queue(commands))
def impact_text(value:G.Impact) -> String:
  match value:
    case G.Impact{hit,body,target,amount,dead}:body_text(body) ++ ":" ++ U32.show(hit) ++ ":" ++ U32.show(target) ++ ":" ++ U32.show(amount) ++ ":" ++ U32.show(dead)
def row_text(value:G.Row) -> String:
  match value:
    case G.Row{body,hit,points,killed,dead}:body_text(body) ++ ":" ++ U32.show(hit) ++ ":" ++ U32.show(points) ++ ":" ++ U32.show(killed) ++ ":" ++ U32.show(dead)
def step_text(value:Step.User) -> String:
  match value:
    case Step.User{active,G.Args{px,py,hp,tick,pulse,impacts},rows}:"active=" ++ Bool.show(active) ++ ";args=" ++ F32.show(px) ++ "," ++ F32.show(py) ++ "," ++ U32.show(hp) ++ "," ++ U32.show(tick) ++ "," ++ Bool.show(pulse) ++ "," ++ List.show(&2,G.Impact,impact_text,impacts) ++ ";rows=" ++ List.show(&2,G.Row,row_text,rows)
def step_snapshot(owner:StepOwner()) -> StepOwner() & String:
  match owner:
    case Sys.Owner{+namespace,+id,+name,+access,+cursor,Local.Local{+user,commands,+permission}}:named(~StepOwner(),~Queue(),commands=>Sys.Owner{namespace,id,name,access,cursor,Local.Local{user,commands,permission}},header(namespace,id,name,access,cursor,permission) ++ ";" ++ step_text(user) ++ ";",queue(commands))

def spawn_snapshot_node(held:Spawn.Node()) -> Spawn.Node() & String:
  node(~Root.Compilation(),~D.World(),~SpawnOwner(),~Admission.Evidence<D.Schema,D.components(),D.resources(),Step.C(),Step.R(),Cmd.ScopedOps(~D.Schema,~D.components(),~D.resources(),~Spawn.route(),~Spawn.Ops),Cmd.program_for_buffer(~D.Schema,~Step.C(),~Step.R(),~D.components(),~D.resources(),~Spawn.route(),~Spawn.Ops,~Spawn.declaration)>,~Prep.Permit<D.Schema,D.Columns()>,~String,spawn_snapshot,held)

def step_snapshot_node(held:Step.Node()) -> Step.Node() & String:
  node(~Root.PeerCompilation(),~D.World(),~StepOwner(),~Admission.Evidence<D.Schema,D.components(),D.resources(),Step.C(),Step.R(),Cmd.ScopedOps(~D.Schema,~D.components(),~D.resources(),~Step.route(),~Step.Ops),Cmd.program_for_buffer(~D.Schema,~Step.C(),~Step.R(),~D.components(),~D.resources(),~Step.route(),~Step.Ops,~Step.declaration)>,~Prep.Permit<D.Schema,D.Columns()>,~String,step_snapshot,held)
