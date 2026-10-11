import Base
import /workspace/formal-proofs/bendvy-worktrees/native54-matching-tree-v1/experiments/public-inspect/ordinary-declaration-v1/native54-matching-tree-v1/native-blocker-source-research-v1/current-repeat-schedule-v1/removal-inspection-v1/affected-v1/removal-provision-mutant.bend as Provision
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-declaration.bend as Identity
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-component-binding.bend as Binding
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/removals.bend as Rm
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap

type Mode is Data:
  Read{}
  Write{}
type Declaration<S:Data,P:Type> is Data:
  Declaration{identity:Identity.Declaration<S,P>,mode:Mode}
def read(~S:Data,~Store:Type,~Rest:Type,~P:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,P>,~put:Rest -> Col.Column<S,P> -> Store,~view:P -> P & V,binding:Binding.Binding<S,Store,Rest,P,V,Token,take,put,view>) -> Declaration<S,P>:
  Declaration{Binding.identity(~S,~Store,~Rest,~P,~V,~Token,~take,~put,~view,binding),Read{}}
def write(~S:Data,~Store:Type,~Rest:Type,~P:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,P>,~put:Rest -> Col.Column<S,P> -> Store,~view:P -> P & V,binding:Binding.Binding<S,Store,Rest,P,V,Token,take,put,view>) -> Declaration<S,P>:
  Declaration{Binding.identity(~S,~Store,~Rest,~P,~V,~Token,~take,~put,~view,binding),Write{}}
def record_checked(~S:Data,~P:Type,allowed:Bool,+key:String,+handle:W.Handle<S>,+identity:Identity.Declaration<S,P>,rest:List<&2,Rm.Record<S,Identity.Declaration<S,P>>>) -> List<&2,Rm.Record<S,Identity.Declaration<S,P>>>:
  match allowed:
    case True{}:Rm.Removed{handle,identity} <> rest
    case False{}:rest
def records(~S:Data,~P:Type,+key:String,values:List<&2,Rm.Record<S,Identity.Declaration<S,P>>>) -> List<&2,Rm.Record<S,Identity.Declaration<S,P>>>:
  match values:
    case []:[]
    case Rm.Removed{+handle,+identity} <> rest:record_checked(~S,~P,String.eq(key,Identity.key(~S,~P,identity)),key,handle,identity,records(~S,~P,key,rest))
    case Rm.Despawned{handle} <> rest:Rm.Despawned{handle} <> records(~S,~P,key,rest)
def viewed(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~select:E -> Maybe<&2,Rm.Record<S,Identity.Declaration<S,P>>>,key:String,view:W.World<S,C,R,E> & List<&2,E>) -> W.World<S,C,R,E> & Maybe<&2,List<&2,Rm.Record<S,Identity.Declaration<S,P>>>>:
  (world,values)=view
  (world,Some{records(~S,~P,key,Rm.since(~S,~E,~Identity.Declaration<S,P>,~select,values,0n))})
def checked(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~select:E -> Maybe<&2,Rm.Record<S,Identity.Declaration<S,P>>>,allowed:Bool,key:String,world:W.World<S,C,R,E>) -> W.World<S,C,R,E> & Maybe<&2,List<&2,Rm.Record<S,Identity.Declaration<S,P>>>>:
  match allowed:
    case False{}:(world,None{})
    case True{}:viewed(~S,~C,~R,~E,~P,~select,key,W.events_view(~S,~C,~R,~E,world))
def get(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~inject:Identity.Declaration<S,P> -> W.Handle<S> -> E,~select:E -> Maybe<&2,Rm.Record<S,Identity.Declaration<S,P>>>,declaration:Declaration<S,P>,selection:Provision.Selection<S,P,E,inject,select>,world:W.World<S,C,R,E>) -> W.World<S,C,R,E> & Maybe<&2,List<&2,Rm.Record<S,Identity.Declaration<S,P>>>>:
  match declaration selection:
    case Declaration{_,Write{}} _:(world,None{})
    case Declaration{identity,Read{}} Provision.Selection{selected}:
      +key=Identity.key(~S,~P,identity)
      checked(~S,~C,~R,~E,~P,~select,String.eq(key,Identity.key(~S,~P,selected)),key,world)
def bind(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~inject:Identity.Declaration<S,P> -> W.Handle<S> -> E,~select:E -> Maybe<&2,Rm.Record<S,Identity.Declaration<S,P>>>,declaration:Declaration<S,P>,selection:Provision.Selection<S,P,E,inject,select>) -> Cap.ValueRead<W.World<S,C,R,E>,Maybe<&2,List<&2,Rm.Record<S,Identity.Declaration<S,P>>>>>:
  Cap.ValueRead{world => get(~S,~C,~R,~E,~P,~inject,~select,declaration,selection,world)}
