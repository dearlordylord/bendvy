import Base
import ../../src/ecs/lifecycle.bend as Life
import ./spawn.bend as S
import ./controls/positive.bend as P
import ../../src/ecs/world.bend as W
import ../../src/ecs/entity-allocator.bend as A
import ../../src/ecs/entity-key.bend as K
import ../../src/ecs/deferred-command.bend as Deferred
import ../../src/ecs/chunk-column.bend as C
import ../../src/ecs/execution-composer-layout.bend as L
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/execution-lifecycle-notices.bend as N
import ../../src/ecs/change-tick.bend as Tick
import ../../test-fixtures/common/column-observation.bend as O

def joined(-A:Type,-B:Type,-R:Type,result:A & B,next:A -> B -> R) -> R:
  match result:
    case (a,b):next(a,b)

def World() -> Type:W.World<S.Schema,S.Store(),S.Resources(),Unit>
def text_bool(value:Bool) -> String:Bool.pick(String,value,"true","false")
type Runs is Data:Runs{text:String,last:String,count:U32,start:U32}
def flush(value:Runs) -> String:
  match value:
    case Runs{text,_,0,_}:text
    case Runs{text,last,count,start}:text ++ U32.show(start) ++ "+" ++ U32.show(count) ++ "=" ++ last ++ ";"
def pushed(value:Runs,index:U32,text:String,same:Bool) -> Runs:
  match value same:
    case Runs{prior,last,count,start} True{}:Runs{prior,last,U32.add(count,1),start}
    case value False{}:Runs{flush(value),text,1,index}
def push(value:Runs,index:U32,+text:String) -> Runs:
  match value:
    case Runs{prior,+last,count,start}:pushed(Runs{prior,last,count,start},index,text,String.eq(last,text))
def slot_walk(fuel:Nat,+index:U32,state:Runs,slots:Array<A.Slot>) -> Array<A.Slot> & String:
  match fuel:
    case 0n:(slots,flush(state))
    case 1n+rest:
      joined(Array<A.Slot>,A.Slot,Array<A.Slot> & String,Array.get(A.Slot,slots,index),slots => slot =>
        slot_walk(rest,U32.add(index,1),push(state,index,O.allocator_slot(slot)),slots))
def allocator(value:A.Allocator) -> A.Allocator & String:
  match value:
    case A.Allocator{+next,+high,slots,+capacity,+depth,+free,+order}:
      joined(Array<A.Slot>,String,A.Allocator & String,slot_walk(U32.to_nat(capacity),0,Runs{"","",0,0},slots),slots => text =>
        (A.Allocator{next,high,slots,capacity,depth,free,order},"next=" ++ U32.show(next) ++ ",high=" ++ U32.show(high) ++ ",capacity=" ++ U32.show(capacity) ++ ",depth=" ++ Nat.show(depth) ++ ",slots={" ++ text ++ "},free=" ++ List.show(&2,U32,U32.show,free) ++ ",order=" ++ List.show(&2,K.Key,O.key,order)))
def column_walk(~P:Type,~project:P -> P & String,fuel:Nat,+index:U32,state:Runs,column:C.Column<S.Schema,P>) -> C.Column<S.Schema,P> & String:
  match fuel:
    case 0n:(column,flush(state))
    case 1n+rest:
      joined(C.Column<S.Schema,P>,Maybe<&2,String>,C.Column<S.Schema,P> & String,C.view(~S.Schema,~P,~String,~project,column,index),column => value =>
        joined(C.Column<S.Schema,P>,Maybe<&2,Life.Stamp>,C.Column<S.Schema,P> & String,C.lifecycle(~S.Schema,~P,column,index),column => stamp =>
          column_walk(~P,~project,rest,U32.add(index,1),push(state,index,O.optional(value) ++ "@" ++ O.stamp_text(stamp)),column)))
def column(~P:Type,~project:P -> P & String,column:C.Column<S.Schema,P>) -> C.Column<S.Schema,P> & String:
  joined(C.Column<S.Schema,P>,U32,C.Column<S.Schema,P> & String,C.capacity(~S.Schema,~P,column),column => +capacity =>
    joined(C.Column<S.Schema,P>,String,C.Column<S.Schema,P> & String,column_walk(~P,~project,U32.to_nat(capacity),0,Runs{"","",0,0},column),column => text =>
      (column,"capacity=" ++ U32.show(capacity) ++ "{" ++ text ++ "}")))
def store(value:S.Store()) -> S.Store() & String:
  match value:
    case Product.Owner{Product.Owner{L.ColumnSlot{left},L.ColumnSlot{right}},unit}:
      joined(C.Column<S.Schema,L.Viewed<P.Token,U32>>,String,S.Store() & String,column(~L.Viewed<P.Token,U32>,~S.viewed,left),left => lt =>
        joined(C.Column<S.Schema,L.Viewed<S.Parcel,String>>,String,S.Store() & String,column(~L.Viewed<S.Parcel,String>,~S.parcel_viewed,right),right => rt =>
          (Product.Owner{Product.Owner{L.ColumnSlot{left},L.ColumnSlot{right}},unit},"token=" ++ lt ++ ";parcel=" ++ rt)))
def selector(value:N.Selector) -> String:
  match value:
    case N.Removed{key}:"removed:" ++ key
    case N.Despawned{}:"despawned"
def identity(value:N.Identity<S.Schema>) -> String:
  match value:
    case N.Identity{namespace,key}:U32.show(namespace) ++ ":" ++ O.key(key)
def notice(value:N.Row<S.Schema>) -> String:
  match value:
    case N.Row{sequence,entity,tick}:Nat.show(sequence) ++ ":" ++ identity(entity) ++ "@" ++ Tick.show(tick)
def channel(value:N.Channel<S.Schema>) -> String:
  match value:
    case N.Channel{kind,next,previous,current,dropped}:selector(kind) ++ ":next=" ++ Nat.show(next) ++ ":previous=" ++ List.show(&2,N.Row<S.Schema>,notice,previous) ++ ":current=" ++ List.show(&2,N.Row<S.Schema>,notice,current) ++ ":dropped=" ++ Nat.show(dropped)
def active(value:N.Active) -> String:
  match value:
    case N.Active{id,kind}:U32.show(id) ++ ":" ++ selector(kind)
def journal(value:N.Journal<S.Schema>) -> N.Journal<S.Schema> & String:
  match value:
    case N.Journal{+namespace,+channels,+next,+readers}:(N.Journal{namespace,channels,next,readers},"namespace=" ++ U32.show(namespace) ++ ";channels=" ++ List.show(&2,N.Channel<S.Schema>,channel,channels) ++ ";next=" ++ U32.show(next) ++ ";readers=" ++ List.show(&2,N.Active,active,readers))
def count_keep(~T:Type,values:List<T>) -> List<T> & Nat:
  match values:
    case []:([],0n)
    case head <> tail:
      joined(List<T>,Nat,List<T> & Nat,count_keep(~T,tail),tail => count =>
        (head <> tail,1n+count))
def world_text(value:World()) -> World() & String:
  match value:
    case W.World{+namespace,alloc,columns,resource,+events,pending,+registrations,+next,+clock,lifecycle}:
      joined(A.Allocator,String,World() & String,allocator(alloc),alloc => at =>
        joined(S.Store(),String,World() & String,store(columns),columns => ct =>
          joined(N.Journal<S.Schema>,String,World() & String,journal(lifecycle),lifecycle => lt =>
            joined(List<Deferred.Command<World()>>,Nat,World() & String,count_keep(~Deferred.Command<World()>,pending),pending => pc =>
              (W.World{namespace,alloc,columns,resource,events,pending,registrations,next,clock,lifecycle},"namespace=" ++ U32.show(namespace) ++ ";allocator={" ++ at ++ "};" ++ ct ++ ";events=" ++ Nat.show(List.length(&2,Unit,events)) ++ ";legacy-pending=" ++ Nat.show(pc) ++ ";resources=Unit,Unit;registrations=" ++ List.show(&2,W.RegistrationMeta,O.registration,registrations) ++ ";next=" ++ U32.show(next) ++ ";clock=" ++ O.clock(clock) ++ ";lifecycle={" ++ lt ++ "}")))))
def handle_status(world:World(),+handle:W.Handle<S.Schema>) -> World() & String:
  joined(World(),Bool,World() & String,W.valid(~S.Schema,~S.Store(),~S.Resources(),~Unit,world,handle),world => live =>
    joined(World(),Bool,World() & String,W.pending_valid(~S.Schema,~S.Store(),~S.Resources(),~Unit,world,handle),world => pending =>
      joined(World(),Bool,World() & String,W.metadata_valid(~S.Schema,~S.Store(),~S.Resources(),~Unit,world,handle),world => metadata =>
        (world,S.handle_text(handle) ++ ":live=" ++ text_bool(live) ++ ":pending=" ++ text_bool(pending) ++ ":metadata=" ++ text_bool(metadata)))))
def handle_states(handles:List<&2,W.Handle<S.Schema>>,world:World()) -> World() & String:
  match handles:
    case []:(world,"")
    case head <> rest:
      joined(World(),String,World() & String,handle_status(world,head),world => text =>
        joined(World(),String,World() & String,handle_states(rest,world),world => tail =>
          (world,text ++ ";" ++ tail)))
def inspected(world:World(),handles:List<&2,W.Handle<S.Schema>>) -> World() & String:
  joined(World(),String,World() & String,handle_states(handles,world),world => status =>
    joined(World(),List<&2,W.Handle<S.Schema>>,World() & String,W.handles(~S.Schema,~S.Store(),~S.Resources(),~Unit,world),world => visible =>
      joined(World(),String,World() & String,world_text(world),world => text =>
        (world,text ++ ";handles={" ++ status ++ "};visible=" ++ List.show(&2,W.Handle<S.Schema>,S.handle_text,visible)))))
