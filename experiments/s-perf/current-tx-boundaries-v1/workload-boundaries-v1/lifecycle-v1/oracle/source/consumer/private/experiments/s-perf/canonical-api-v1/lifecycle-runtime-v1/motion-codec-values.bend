import Base
import ../dense-runtime-v1/motion.bend as F
import ../dense-runtime-v1/motion-observe.bend as Old
import ../dense-runtime-v1/types.bend as T
import ../../../public-audit61/app-a-current-carrier-v1/owner-observer.bend as Dump
import ../../../../../../../../../../../../workspace/formal-proofs/bendvy/experiments/s-perf/current-tx-boundaries-v1/workload-boundaries-v1/private/src/ecs/world.bend as W
import ../../../../../../../../../../../../workspace/formal-proofs/bendvy/experiments/s-perf/current-tx-boundaries-v1/workload-boundaries-v1/private/src/ecs/entity-allocator.bend as Alloc
import ../../../../../../../../../../../../workspace/formal-proofs/bendvy/experiments/s-perf/current-tx-boundaries-v1/workload-boundaries-v1/private/src/ecs/entity-key.bend as Key
import ../../../../../../../../../../../../workspace/formal-proofs/bendvy/experiments/s-perf/current-tx-boundaries-v1/workload-boundaries-v1/private/src/ecs/column.bend as Col
import ../../../../../../../../../../../../workspace/formal-proofs/bendvy/experiments/s-perf/current-tx-boundaries-v1/workload-boundaries-v1/private/src/ecs/lifecycle.bend as L
import ../../../../../../../../../../../../workspace/formal-proofs/bendvy/experiments/s-perf/current-tx-boundaries-v1/workload-boundaries-v1/private/src/ecs/deferred-command.bend as Deferred
import ../../../../../../../../../../../../workspace/formal-proofs/bendvy/experiments/s-perf/current-tx-boundaries-v1/workload-boundaries-v1/private/src/ecs/owner-product.bend as Product

type Tree<V:Data> is Data:
  Leaf{value:V}
  Branch{left:Tree<V>,right:Tree<V>}
type Position is Data:
  Position{values:Tree<U32>,frame:U32}
type Velocity is Data:
  Velocity{values:Tree<U32>,moving:Bool}
type Ledger is Data:
  Ledger{values:Tree<U32>,epoch:U32}
type Column<V:Data> is Data:
  Plain{values:Tree<Maybe<&2,V>>,stamps:List<&2,L.Entry>}
  Legacy{variant:U32,text:String}
type Store is Data:
  Store{main:Column<Position>,aux:Column<Velocity>,flag:Column<T.Selected>}
type Allocator is Data:
  Allocator{next:U32,high:U32,capacity:U32,depth:Nat,slots:Tree<Alloc.Slot>,free:List<&2,U32>,order:List<&2,Key.Key>}
type World is Data:
  World{namespace:U32,allocator:Allocator,store:Store,resource:Ledger,sibling:Unit,events:List<&2,Nat>,pendingCount:Nat,pendingKinds:List<&2,U32>,registrations:List<&2,W.RegistrationMeta>,nextSystem:U32,clock:U32}
type Local is Data:
  Local{namespace:U32,id:U32,name:String,access:List<&2,String>,owner:Tree<U32>}
def tree_leaf(~P:Type,~V:Data,observed:P & V) -> Array<P> & Tree<V>:
  (owner,value)=observed
  (ALeaf{owner},Leaf{value})
def tree_node(~P:Type,~V:Data,left:Array<P> & Tree<V>,right:Array<P> & Tree<V>) -> Array<P> & Tree<V>:
  (left,vl)=left
  (right,vr)=right
  (ANode{left,right},Branch{vl,vr})
def tree(~P:Type,~V:Data,~project:P -> P & V,value:Array<P>) -> Array<P> & Tree<V>:
  match value:
    case ALeaf{owner}:tree_leaf(~P,~V,project(owner))
    case ANode{left,right}:tree_node(~P,~V,tree(~P,~V,~project,left),tree(~P,~V,~project,right))
def u32_copy(+value:U32) -> U32 & U32:(value,value)
def u32_value(value:U32) -> U32 & U32:u32_copy(value)
def slot_copy(+value:Alloc.Slot) -> Alloc.Slot & Alloc.Slot:(value,value)
def slot_value(value:Alloc.Slot) -> Alloc.Slot & Alloc.Slot:slot_copy(value)
def flag_copy(+value:T.Selected) -> T.Selected & T.Selected:(value,value)
def flag_value(value:T.Selected) -> T.Selected & T.Selected:flag_copy(value)
def position_done(+frame:U32,observed:Array<U32> & Tree<U32>) -> T.Position & Position:
  (values,view)=observed
  (T.Position{values,frame},Position{view,frame})
def position(value:T.Position) -> T.Position & Position:
  match value:
    case T.Position{values,frame}:position_done(frame,tree(~U32,~U32,~u32_value,values))
def velocity_done(+moving:Bool,observed:Array<U32> & Tree<U32>) -> T.Velocity & Velocity:
  (values,view)=observed
  (T.Velocity{values,moving},Velocity{view,moving})
def velocity(value:T.Velocity) -> T.Velocity & Velocity:
  match value:
    case T.Velocity{values,moving}:velocity_done(moving,tree(~U32,~U32,~u32_value,values))
def ledger_done(+epoch:U32,observed:Array<U32> & Tree<U32>) -> T.MotionLedger & Ledger:
  (values,view)=observed
  (T.MotionLedger{values,epoch},Ledger{view,epoch})
def ledger(value:T.MotionLedger) -> T.MotionLedger & Ledger:
  match value:
    case T.MotionLedger{values,epoch}:ledger_done(epoch,tree(~U32,~U32,~u32_value,values))
def optional_done(~P:Type,~V:Data,observed:P & V) -> Maybe<&1,P> & Maybe<&2,V>:
  (owner,value)=observed
  (Some{owner},Some{value})
def optional(~P:Type,~V:Data,~project:P -> P & V,value:Maybe<&1,P>) -> Maybe<&1,P> & Maybe<&2,V>:
  match value:
    case None{}:(None{},None{})
    case Some{owner}:optional_done(~P,~V,project(owner))
def column_done(~S:Data,~P:Type,~V:Data,+stamps:List<&2,L.Entry>,observed:Array<Maybe<&1,P>> & Tree<Maybe<&2,V>>) -> Col.Column<S,P> & Column<V>:
  (values,view)=observed
  (Col.Column{values,stamps},Plain{view,stamps})
def column_legacy(~S:Data,~P:Type,~V:Data,variant:U32,observed:Col.Column<S,P> & String) -> Col.Column<S,P> & Column<V>:
  (owner,text)=observed
  (owner,Legacy{variant,text})
def column(~S:Data,~P:Type,~V:Data,~project:P -> P & V,~old:P -> P & String,value:Col.Column<S,P>) -> Col.Column<S,P> & Column<V>:
  match value:
    case Col.Column{values,stamps}:column_done(~S,~P,~V,stamps,tree(~Maybe<&1,P>,~Maybe<&2,V>,~optional(~P,~V,~project),values))
    case Col.Indexed{state}:column_legacy(~S,~P,~V,1,Dump.column(~S,~P,~old,Col.Indexed{state}))
    case Col.Prepared{state}:column_legacy(~S,~P,~V,2,Dump.column(~S,~P,~old,Col.Prepared{state}))
    case Col.PreparedIndexed{state}:column_legacy(~S,~P,~V,3,Dump.column(~S,~P,~old,Col.PreparedIndexed{state}))
def store_done(main:Col.Column<T.MotionSchema,T.Position> & Column<Position>,aux:Col.Column<T.MotionSchema,T.Velocity> & Column<Velocity>,flag:Col.Column<T.MotionSchema,T.Selected> & Column<T.Selected>) -> F.Store() & Store:
  (main,vm)=main
  (aux,va)=aux
  (flag,vf)=flag
  (Product.Owner{main,Product.Owner{aux,flag}},Store{vm,va,vf})
def store(value:F.Store()) -> F.Store() & Store:
  match value:
    case Product.Owner{main,Product.Owner{aux,flag}}:store_done(column(~T.MotionSchema,~T.Position,~Position,~position,~Old.main,main),column(~T.MotionSchema,~T.Velocity,~Velocity,~velocity,~Old.aux,aux),column(~T.MotionSchema,~T.Selected,~T.Selected,~flag_value,~Old.flag,flag))
def allocator_done(+next:U32,+high:U32,+capacity:U32,+depth:Nat,+free:List<&2,U32>,+order:List<&2,Key.Key>,observed:Array<Alloc.Slot> & Tree<Alloc.Slot>) -> Alloc.Allocator & Allocator:
  (slots,view)=observed
  (Alloc.Allocator{next,high,slots,capacity,depth,free,order},Allocator{next,high,capacity,depth,view,free,order})
def allocator(value:Alloc.Allocator) -> Alloc.Allocator & Allocator:
  match value:
    case Alloc.Allocator{next,high,slots,capacity,depth,free,order}:allocator_done(next,high,capacity,depth,free,order,tree(~Alloc.Slot,~Alloc.Slot,~slot_value,slots))
def resource_done(+sibling:Unit,observed:T.MotionLedger & Ledger) -> F.Resources() & (Ledger & Unit):
  (owner,view)=observed
  (Product.Owner{owner,sibling},(view,sibling))
def resource(value:F.Resources()) -> F.Resources() & (Ledger & Unit):
  match value:
    case Product.Owner{owner,sibling}:resource_done(sibling,ledger(owner))
def pending_done(~P:Type,head:Deferred.Command<P>,kind:U32,observed:List<Deferred.Command<P>> & (Nat & List<&2,U32>)) -> List<Deferred.Command<P>> & (Nat & List<&2,U32>):
  (rest,(count,kinds))=observed
  (head <> rest,(1n+count,kind <> kinds))
def pending_head(~P:Type,head:Deferred.Command<P>,observed:List<Deferred.Command<P>> & (Nat & List<&2,U32>)) -> List<Deferred.Command<P>> & (Nat & List<&2,U32>):
  match head:
    case Deferred.Raw{apply}:pending_done(~P,Deferred.Raw{apply},0,observed)
    case Deferred.Observed{apply}:pending_done(~P,Deferred.Observed{apply},1,observed)
def pending_commands(~P:Type,values:List<Deferred.Command<P>>) -> List<Deferred.Command<P>> & (Nat & List<&2,U32>):
  match values:
    case []:([],(0n,[]))
    case head <> rest:pending_head(~P,head,pending_commands(~P,rest))
def world_done(+namespace:U32,+events:List<&2,Nat>,+registrations:List<&2,W.RegistrationMeta>,+nextSystem:U32,+clock:U32,va:Alloc.Allocator & Allocator,vs:F.Store() & Store,vr:F.Resources() & (Ledger & Unit),vp:List<Deferred.Command<F.World()>> & (Nat & List<&2,U32>)) -> F.World() & World:
  (allocator,a)=va
  (store,s)=vs
  (resource,(r,sibling))=vr
  (pending,(count,kinds))=vp
  (W.World{namespace,allocator,store,resource,events,pending,registrations,nextSystem,clock},World{namespace,a,s,r,sibling,events,count,kinds,registrations,nextSystem,clock})
def world(value:F.World()) -> F.World() & World:
  match value:
    case W.World{namespace,a,s,r,events,pending,registrations,nextSystem,clock}:world_done(namespace,events,registrations,nextSystem,clock,allocator(a),store(s),resource(r),pending_commands(~F.World(),pending))
