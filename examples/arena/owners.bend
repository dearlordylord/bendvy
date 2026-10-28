import Base
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
