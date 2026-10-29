import Base
import ./world.bend as W
import ./registration.bend as Reg
import ./execution-system.bend as Sys
import ./execution-system-lifecycle.bend as Life
import ./execution-builder.bend as Build
import ./execution-declaration.bend as D
import ./execution-resource-query-leaf.bend as Leaf
import ./execution-resource-query-execution.bend as Execution
import ./execution-parallel-scope.bend as Scope
import ./execution-compiled-binding.bend as Binding
import ./execution-prepared.bend as Prep
import ./entity-allocator.bend as Alloc
import ./deferred-command.bend as Deferred
import ./clock-state.bend as Clock
import ./execution-lifecycle-notices.bend as Notice

# Bevy ad678262 system_registry.rs returns an owned RemovedSystem on unregister;
# its contained system retains its state. Same-ID restoration and affine Local
# return here are Bendvy contracts, not claims about Bevy's re-registration IDs.
# https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_ecs/src/system/system_registry.rs
# Cache is a finite owner context, not an executable admission or a method table.
# Detach/refusal preserve it; successful re-registration consumes it through the
# same registered_binding boundary used before ordinary schedule reinspection.
type Cache<-Evidence:Data,-P:Data> is Data:
  Uninspected{}
  Inspected{evidence:Maybe<&2,Evidence>,id:U32,valid:Bool}
  CacheReady{namespace:U32,permits:List<&2,P>,provenance:Prep.Provenance<P>,evidence:Maybe<&2,Evidence>}
  Inventory{provenance:Prep.Provenance<P>,evidence:Maybe<&2,Evidence>}
type Released<-Compilation:Type,-World:Type,-Local:Type,-Evidence:Data,-P:Data> is Type:
  Released{compilation:Compilation,cache:Cache<Evidence,P>,identity:Life.Identity,local:Local}
type Reregistration<-World:Type,-Node:Type,-Returned:Type> is Type:
  Reregistered{world:World,node:Node}
  ReregistrationRefused{world:World,returned:Returned}

def local_returned(-S:Data,-WC:Type,-C:Type,-R:Type,-E:Data,-Ops:Data -> Type -> Type,-Local:Type,-Error:Data,-Out:Data,-program:Build.FrameworkProgram(~S,~WC,~C,~R,~Ops),-body:Sys.Body(~S,~Ops,~Local,~Error,~Out),-Compilation:Type,-World:Type,-Evidence:Data,-P:Data,compilation:Compilation,cache:Cache<Evidence,P>,owner:Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,program,body>) -> Released<Compilation,World,Local,Evidence,P>:
  match owner:
    case Sys.Owner{namespace,id,name,access,cursor,local}:Released{compilation,cache,Life.Identity{namespace,id,name,access,cursor},local}
def returned(-S:Data,-WC:Type,-C:Type,-R:Type,-E:Data,-Ops:Data -> Type -> Type,-Local:Type,-Error:Data,-Out:Data,-program:Build.FrameworkProgram(~S,~WC,~C,~R,~Ops),-body:Sys.Body(~S,~Ops,~Local,~Error,~Out),-Compilation:Type,-World:Type,-Evidence:Data,-P:Data,node:Leaf.Node<Compilation,World,Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,program,body>,Evidence,P>) -> Released<Compilation,World,Local,Evidence,P>:
  match node:
    case Leaf.Uninspected{Scope.CompiledBinding{compilation,owner}}:local_returned(S,WC,C,R,E,Ops,Local,Error,Out,program,body,Compilation,World,Evidence,P,compilation,Uninspected{},owner)
    case Leaf.Inspected{Scope.CompiledBinding{compilation,owner},evidence,id,valid}:local_returned(S,WC,C,R,E,Ops,Local,Error,Out,program,body,Compilation,World,Evidence,P,compilation,Inspected{evidence,id,valid},owner)
    case Leaf.Prepared{Execution.HeldReady{Binding.Binding{compilation,Prep.Prepared{namespace,owner,permits,provenance},evidence}}}:local_returned(S,WC,C,R,E,Ops,Local,Error,Out,program,body,Compilation,World,Evidence,P,compilation,CacheReady{namespace,permits,provenance,evidence},owner)
    case Leaf.Prepared{Execution.HeldInventory{compilation,Prep.Inventory{owner,provenance},evidence}}:local_returned(S,WC,C,R,E,Ops,Local,Error,Out,program,body,Compilation,World,Evidence,P,compilation,Inventory{provenance,evidence},owner)
def restored_node(-S:Data,-WC:Type,-C:Type,-R:Type,-E:Data,-Ops:Data -> Type -> Type,-Local:Type,-Error:Data,-Out:Data,-program:Build.FrameworkProgram(~S,~WC,~C,~R,~Ops),-body:Sys.Body(~S,~Ops,~Local,~Error,~Out),-Compilation:Type,-World:Type,-Evidence:Data,-P:Data,compilation:Compilation,cache:Cache<Evidence,P>,owner:Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,program,body>) -> Leaf.Node<Compilation,World,Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,program,body>,Evidence,P>:
  match cache:
    case Uninspected{}:Leaf.Uninspected{Scope.CompiledBinding{compilation,owner}}
    case Inspected{evidence,id,valid}:Leaf.Inspected{Scope.CompiledBinding{compilation,owner},evidence,id,valid}
    case CacheReady{namespace,permits,provenance,evidence}:Leaf.Prepared{Execution.HeldReady{Binding.Binding{compilation,Prep.Prepared{namespace,owner,permits,provenance},evidence}}}
    case Inventory{provenance,evidence}:Leaf.Prepared{Execution.HeldInventory{compilation,Prep.Inventory{owner,provenance},evidence}}
def rebuild(-S:Data,-WC:Type,-C:Type,-R:Type,-E:Data,-Ops:Data -> Type -> Type,-Local:Type,-Error:Data,-Out:Data,-program:Build.FrameworkProgram(~S,~WC,~C,~R,~Ops),-body:Sys.Body(~S,~Ops,~Local,~Error,~Out),-Compilation:Type,-World:Type,-Evidence:Data,-P:Data,returned:Released<Compilation,World,Local,Evidence,P>) -> Leaf.Node<Compilation,World,Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,program,body>,Evidence,P>:
  match returned:
    case Released{compilation,cache,Life.Identity{namespace,id,name,access,cursor},local}:restored_node(S,WC,C,R,E,Ops,Local,Error,Out,program,body,Compilation,World,Evidence,P,compilation,cache,Sys.Owner{namespace,id,name,access,cursor,local})
def release(-S:Data,-WC:Type,-C:Type,-R:Type,-E:Data,-Ops:Data -> Type -> Type,-Local:Type,-Error:Data,-Out:Data,-program:Build.FrameworkProgram(~S,~WC,~C,~R,~Ops),-body:Sys.Body(~S,~Ops,~Local,~Error,~Out),-Compilation:Type,-World:Type,-Evidence:Data,-P:Data,detached:Life.Detached<Leaf.Node<Compilation,World,Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,program,body>,Evidence,P>>) -> Released<Compilation,World,Local,Evidence,P>:
  match detached:
    case Life.Detached{node}:returned(S,WC,C,R,E,Ops,Local,Error,Out,program,body,Compilation,World,Evidence,P,node)

def retirement_returned(-S:Data,-WC:Type,-C:Type,-R:Type,-E:Data,-Ops:Data -> Type -> Type,-Local:Type,-Error:Data,-Out:Data,-program:Build.FrameworkProgram(~S,~WC,~C,~R,~Ops),-body:Sys.Body(~S,~Ops,~Local,~Error,~Out),-Compilation:Type,-WR:Type,-WE:Data,-Evidence:Data,-P:Data,returned:Released<Compilation,W.World<S,WC,WR,WE>,Local,Evidence,P>,result:W.World<S,WC,WR,WE> & Bool) -> Life.Retirement<W.World<S,WC,WR,WE>,Leaf.Node<Compilation,W.World<S,WC,WR,WE>,Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,program,body>,Evidence,P>>:
  match result:
    case (world,False{}):Life.RetirementRefused{world,rebuild(S,WC,C,R,E,Ops,Local,Error,Out,program,body,Compilation,W.World<S,WC,WR,WE>,Evidence,P,returned)}
    case (world,True{}):Life.Retired{world,Life.Detached{rebuild(S,WC,C,R,E,Ops,Local,Error,Out,program,body,Compilation,W.World<S,WC,WR,WE>,Evidence,P,returned)}}
def retire_returned(~S:Data,~WC:Type,~WR:Type,~WE:Data,-C:Type,-R:Type,-E:Data,-Ops:Data -> Type -> Type,-Local:Type,-Error:Data,-Out:Data,-program:Build.FrameworkProgram(~S,~WC,~C,~R,~Ops),-body:Sys.Body(~S,~Ops,~Local,~Error,~Out),-Compilation:Type,-Evidence:Data,-P:Data,world:W.World<S,WC,WR,WE>,returned:Released<Compilation,W.World<S,WC,WR,WE>,Local,Evidence,P>) -> Life.Retirement<W.World<S,WC,WR,WE>,Leaf.Node<Compilation,W.World<S,WC,WR,WE>,Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,program,body>,Evidence,P>>:
  match returned:
    case Released{compilation,cache,Life.Identity{+namespace,+id,+name,+access,cursor},local}:retirement_returned(S,WC,C,R,E,Ops,Local,Error,Out,program,body,Compilation,WR,WE,Evidence,P,Released{compilation,cache,Life.Identity{namespace,id,name,access,cursor},local},Reg.remove(~S,~WC,~WR,~WE,world,namespace,id,name,access))
def retire(~S:Data,~WC:Type,~WR:Type,~WE:Data,-C:Type,-R:Type,-E:Data,-Ops:Data -> Type -> Type,-Local:Type,-Error:Data,-Out:Data,-program:Build.FrameworkProgram(~S,~WC,~C,~R,~Ops),-body:Sys.Body(~S,~Ops,~Local,~Error,~Out),-Compilation:Type,-Evidence:Data,-P:Data,node:Leaf.Node<Compilation,W.World<S,WC,WR,WE>,Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,program,body>,Evidence,P>,world:W.World<S,WC,WR,WE>) -> Life.Retirement<W.World<S,WC,WR,WE>,Leaf.Node<Compilation,W.World<S,WC,WR,WE>,Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,program,body>,Evidence,P>>:
  retire_returned(~S,~WC,~WR,~WE,C,R,E,Ops,Local,Error,Out,program,body,Compilation,Evidence,P,world,returned(S,WC,C,R,E,Ops,Local,Error,Out,program,body,Compilation,W.World<S,WC,WR,WE>,Evidence,P,node))

# Inspect the actual retained compilation once, then return its affine caps.
def compilation_checked(-S:Data,-WC:Type,-C:Type,-R:Type,-Ops:Data -> Type -> Type,compilation:D.Compilation<S,WC,C,R,Ops>) -> D.Compilation<S,WC,C,R,Ops> & (Bool & List<&2,String>):
  match compilation:
    case D.Supported{D.Declaration{caps,+access},recipes}:(D.Supported{D.Declaration{caps,access},recipes},(True{},D.keys(access)))
    case D.Unsupported{caps,+access,recipes}:(D.Unsupported{caps,access,recipes},(False{},D.keys(access)))

def reregister_world(-S:Data,-WC:Type,-C:Type,-R:Type,-E:Data,-Ops:Data -> Type -> Type,-Local:Type,-Error:Data,-Out:Data,-program:Build.FrameworkProgram(~S,~WC,~C,~R,~Ops),-body:Sys.Body(~S,~Ops,~Local,~Error,~Out),-WR:Type,-WE:Data,-Evidence:Data,-P:Data,actual:U32,allocator:Alloc.Allocator,columns:WC,resources:WR,events:List<&2,WE>,pending:List<Deferred.Command<W.World<S,WC,WR,WE>>>,registrations:List<&2,W.RegistrationMeta>,nextSystemId:U32,clock:Clock.State,journal:Notice.Journal<S>,returned:Released<D.Compilation<S,WC,C,R,Ops>,W.World<S,WC,WR,WE>,Local,Evidence,P>) -> Reregistration<W.World<S,WC,WR,WE>,Leaf.Node<D.Compilation<S,WC,C,R,Ops>,W.World<S,WC,WR,WE>,Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,program,body>,Evidence,P>,Released<D.Compilation<S,WC,C,R,Ops>,W.World<S,WC,WR,WE>,Local,Evidence,P>>:
  match returned:
    case Released{compilation,cache,Life.Identity{namespace,+id,+name,+access,cursor},local}:Reregistered{W.World{actual,allocator,columns,resources,events,pending,W.RegistrationMeta{id,name,access} <> registrations,nextSystemId,clock,journal},Leaf.Uninspected{Leaf.registered_binding(D.Compilation<S,WC,C,R,Ops>,W.World<S,WC,WR,WE>,Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,program,body>,Evidence,P,rebuild(S,WC,C,R,E,Ops,Local,Error,Out,program,body,D.Compilation<S,WC,C,R,Ops>,W.World<S,WC,WR,WE>,Evidence,P,Released{compilation,cache,Life.Identity{namespace,id,name,access,cursor},local}))}}
def reregistration_checked(-S:Data,-WC:Type,-C:Type,-R:Type,-E:Data,-Ops:Data -> Type -> Type,-Local:Type,-Error:Data,-Out:Data,-program:Build.FrameworkProgram(~S,~WC,~C,~R,~Ops),-body:Sys.Body(~S,~Ops,~Local,~Error,~Out),-WR:Type,-WE:Data,-Evidence:Data,-P:Data,allowed:Bool,returned:Released<D.Compilation<S,WC,C,R,Ops>,W.World<S,WC,WR,WE>,Local,Evidence,P>,world:W.World<S,WC,WR,WE>) -> Reregistration<W.World<S,WC,WR,WE>,Leaf.Node<D.Compilation<S,WC,C,R,Ops>,W.World<S,WC,WR,WE>,Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,program,body>,Evidence,P>,Released<D.Compilation<S,WC,C,R,Ops>,W.World<S,WC,WR,WE>,Local,Evidence,P>>:
  match allowed returned world:
    case False{} returned world:ReregistrationRefused{world,returned}
    case True{} returned W.World{actual,allocator,columns,resources,events,pending,registrations,nextSystemId,clock,journal}:reregister_world(S,WC,C,R,E,Ops,Local,Error,Out,program,body,WR,WE,Evidence,P,actual,allocator,columns,resources,events,pending,registrations,nextSystemId,clock,journal,returned)
def reregistration_allowed(-S:Data,-WC:Type,-C:Type,-R:Type,-E:Data,-Ops:Data -> Type -> Type,-Local:Type,-Error:Data,-Out:Data,-program:Build.FrameworkProgram(~S,~WC,~C,~R,~Ops),-body:Sys.Body(~S,~Ops,~Local,~Error,~Out),-WR:Type,-WE:Data,-Evidence:Data,-P:Data,supported:Bool,expectedAccess:List<&2,String>,returned:Released<D.Compilation<S,WC,C,R,Ops>,W.World<S,WC,WR,WE>,Local,Evidence,P>,world:W.World<S,WC,WR,WE>) -> Reregistration<W.World<S,WC,WR,WE>,Leaf.Node<D.Compilation<S,WC,C,R,Ops>,W.World<S,WC,WR,WE>,Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,program,body>,Evidence,P>,Released<D.Compilation<S,WC,C,R,Ops>,W.World<S,WC,WR,WE>,Local,Evidence,P>>:
  match returned world:
    case Released{compilation,cache,Life.Identity{+namespace,+id,name,+access,cursor},local} W.World{+actual,allocator,columns,resources,events,pending,+registrations,+nextSystemId,clock,journal}:reregistration_checked(S,WC,C,R,E,Ops,Local,Error,Out,program,body,WR,WE,Evidence,P,Bool.and(supported,Bool.and(U32.is_eq(namespace,actual),Bool.and(U32.is_lt(id,nextSystemId),Bool.and(Bool.not(Life.contains_id(registrations,id)),W.access_equal(access,expectedAccess))))),Released{compilation,cache,Life.Identity{namespace,id,name,access,cursor},local},W.World{actual,allocator,columns,resources,events,pending,registrations,nextSystemId,clock,journal})
def reregistration_compiled(-S:Data,-WC:Type,-C:Type,-R:Type,-E:Data,-Ops:Data -> Type -> Type,-Local:Type,-Error:Data,-Out:Data,-program:Build.FrameworkProgram(~S,~WC,~C,~R,~Ops),-body:Sys.Body(~S,~Ops,~Local,~Error,~Out),-WR:Type,-WE:Data,-Evidence:Data,-P:Data,cache:Cache<Evidence,P>,identity:Life.Identity,local:Local,world:W.World<S,WC,WR,WE>,result:D.Compilation<S,WC,C,R,Ops> & (Bool & List<&2,String>)) -> Reregistration<W.World<S,WC,WR,WE>,Leaf.Node<D.Compilation<S,WC,C,R,Ops>,W.World<S,WC,WR,WE>,Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,program,body>,Evidence,P>,Released<D.Compilation<S,WC,C,R,Ops>,W.World<S,WC,WR,WE>,Local,Evidence,P>>:
  match result:
    case (compilation,(supported,access)):reregistration_allowed(S,WC,C,R,E,Ops,Local,Error,Out,program,body,WR,WE,Evidence,P,supported,access,Released{compilation,cache,identity,local},world)
# Re-registration restores the same identity/cursor and returned Local. Cached
# admission is consumed; the next ordinary inspection validates the actual World.
def reregister(-S:Data,-WC:Type,-C:Type,-R:Type,-E:Data,-Ops:Data -> Type -> Type,-Local:Type,-Error:Data,-Out:Data,-program:Build.FrameworkProgram(~S,~WC,~C,~R,~Ops),-body:Sys.Body(~S,~Ops,~Local,~Error,~Out),-WR:Type,-WE:Data,-Evidence:Data,-P:Data,returned:Released<D.Compilation<S,WC,C,R,Ops>,W.World<S,WC,WR,WE>,Local,Evidence,P>,world:W.World<S,WC,WR,WE>) -> Reregistration<W.World<S,WC,WR,WE>,Leaf.Node<D.Compilation<S,WC,C,R,Ops>,W.World<S,WC,WR,WE>,Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,program,body>,Evidence,P>,Released<D.Compilation<S,WC,C,R,Ops>,W.World<S,WC,WR,WE>,Local,Evidence,P>>:
  match returned:
    case Released{compilation,cache,identity,local}:reregistration_compiled(S,WC,C,R,E,Ops,Local,Error,Out,program,body,WR,WE,Evidence,P,cache,identity,local,world,compilation_checked(S,WC,C,R,Ops,compilation))
