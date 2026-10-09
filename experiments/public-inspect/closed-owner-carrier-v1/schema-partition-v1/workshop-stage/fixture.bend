import Base
import schema-families.bend as D
import runtime-owners.bend as Consumer
import core-v1/src/ecs/world.bend as W
import core-v1/src/ecs/component.bend as C
import core-v1/src/ecs/column.bend as Col
import core-v1/src/ecs/commands.bend as Cmd

type Fixture<S:Data> is Type:
  Fixture{world:W.World<S,D.Store<S>,Consumer.Resource<S>,U32>,targets:List<&2,W.Handle<S>>,errors:String}
type Built<S:Data> is Type:
  Built{fixture:Fixture<S>}
  BuildRefused{factory:W.Factory,resource:Consumer.Resource<S>}

# Closed diagnostic mutators intentionally dispose replaced payloads; reads never do.
def empty(~S:Data,unit:Unit) -> D.Store<S>:
  D.Store{Col.empty(~S,~D.Stock),Col.empty(~S,~D.Title),Col.empty(~S,~D.Active),Col.empty(~S,~D.Count)}
def stock_replaced(~S:Data,result:C.Replacement<W.World<S,D.Store<S>,Consumer.Resource<S>,U32>,D.Stock>) -> W.World<S,D.Store<S>,Consumer.Resource<S>,U32> & String:
  match result:
    case C.Replaced{world,_}:(world,"")
    case C.ReplaceRejected{world,_,_}:(world,"stock-replacement-refused;")
def stock_write(~S:Data,world:W.World<S,D.Store<S>,Consumer.Resource<S>,U32>,target:W.Handle<S>,incoming:Maybe<&1,D.Stock>) -> W.World<S,D.Store<S>,Consumer.Resource<S>,U32> & String:
  stock_replaced(~S,C.replace(~S,~D.Store<S>,~Consumer.Resource<S>,~U32,~D.StockRest<S>,~D.Stock,~U32,~D.StockToken,~D.take_stock(~S),~D.put_stock(~S),~D.project_stock,D.stock(~S),world,target,incoming))
def stock_selected(~S:Data,allowed:Bool,world:W.World<S,D.Store<S>,Consumer.Resource<S>,U32>,target:W.Handle<S>,value:U32) -> W.World<S,D.Store<S>,Consumer.Resource<S>,U32> & String:
  match allowed:
    case False{}:(world,"")
    case True{}:stock_write(~S,world,target,Some{D.Stock{Array.new(U32,0n,value)}})
def title_replaced(~S:Data,result:C.Replacement<W.World<S,D.Store<S>,Consumer.Resource<S>,U32>,D.Title>) -> W.World<S,D.Store<S>,Consumer.Resource<S>,U32> & String:
  match result:
    case C.Replaced{world,_}:(world,"")
    case C.ReplaceRejected{world,_,_}:(world,"title-replacement-refused;")
def title_write(~S:Data,world:W.World<S,D.Store<S>,Consumer.Resource<S>,U32>,target:W.Handle<S>,incoming:Maybe<&1,D.Title>) -> W.World<S,D.Store<S>,Consumer.Resource<S>,U32> & String:
  title_replaced(~S,C.replace(~S,~D.Store<S>,~Consumer.Resource<S>,~U32,~D.TitleRest<S>,~D.Title,~String,~D.TitleToken,~D.take_title(~S),~D.put_title(~S),~D.project_title,D.title(~S),world,target,incoming))
def title_selected(~S:Data,allowed:Bool,world:W.World<S,D.Store<S>,Consumer.Resource<S>,U32>,target:W.Handle<S>,value:U32) -> W.World<S,D.Store<S>,Consumer.Resource<S>,U32> & String:
  match allowed:
    case False{}:(world,"")
    case True{}:title_write(~S,world,target,Some{D.Title{Array.new(U32,0n,value)}})
def active_replaced(~S:Data,result:C.Replacement<W.World<S,D.Store<S>,Consumer.Resource<S>,U32>,D.Active>) -> W.World<S,D.Store<S>,Consumer.Resource<S>,U32> & String:
  match result:
    case C.Replaced{world,_}:(world,"")
    case C.ReplaceRejected{world,_,_}:(world,"active-replacement-refused;")
def active_write(~S:Data,world:W.World<S,D.Store<S>,Consumer.Resource<S>,U32>,target:W.Handle<S>,incoming:Maybe<&1,D.Active>) -> W.World<S,D.Store<S>,Consumer.Resource<S>,U32> & String:
  active_replaced(~S,C.replace(~S,~D.Store<S>,~Consumer.Resource<S>,~U32,~D.ActiveRest<S>,~D.Active,~Bool,~D.ActiveToken,~D.take_active(~S),~D.put_active(~S),~D.project_active,D.active(~S),world,target,incoming))
def active_selected(~S:Data,allowed:Bool,world:W.World<S,D.Store<S>,Consumer.Resource<S>,U32>,target:W.Handle<S>,value:U32) -> W.World<S,D.Store<S>,Consumer.Resource<S>,U32> & String:
  match allowed:
    case False{}:(world,"")
    case True{}:active_write(~S,world,target,Some{D.Active{Array.new(U32,0n,value)}})
def count_replaced(~S:Data,result:C.Replacement<W.World<S,D.Store<S>,Consumer.Resource<S>,U32>,D.Count>) -> W.World<S,D.Store<S>,Consumer.Resource<S>,U32> & String:
  match result:
    case C.Replaced{world,_}:(world,"")
    case C.ReplaceRejected{world,_,_}:(world,"count-replacement-refused;")
def count_write(~S:Data,world:W.World<S,D.Store<S>,Consumer.Resource<S>,U32>,target:W.Handle<S>,incoming:Maybe<&1,D.Count>) -> W.World<S,D.Store<S>,Consumer.Resource<S>,U32> & String:
  count_replaced(~S,C.replace(~S,~D.Store<S>,~Consumer.Resource<S>,~U32,~D.CountRest<S>,~D.Count,~List<&2,U32>,~D.CountToken,~D.take_count(~S),~D.put_count(~S),~D.project_count,D.count(~S),world,target,incoming))
def count_selected(~S:Data,allowed:Bool,world:W.World<S,D.Store<S>,Consumer.Resource<S>,U32>,target:W.Handle<S>,value:U32) -> W.World<S,D.Store<S>,Consumer.Resource<S>,U32> & String:
  match allowed:
    case False{}:(world,"")
    case True{}:count_write(~S,world,target,Some{D.Count{Array.new(U32,0n,value)}})
def populate_3(~S:Data,+target:W.Handle<S>,+id:U32,errors:String,observed:W.World<S,D.Store<S>,Consumer.Resource<S>,U32> & String) -> W.World<S,D.Store<S>,Consumer.Resource<S>,U32> & String:
  (world,error)=observed
  (world,errors ++ error)
def populate_2(~S:Data,+target:W.Handle<S>,+id:U32,errors:String,observed:W.World<S,D.Store<S>,Consumer.Resource<S>,U32> & String) -> W.World<S,D.Store<S>,Consumer.Resource<S>,U32> & String:
  (world,error)=observed
  populate_3(~S,target,id,errors ++ error,count_selected(~S,Bool.not(U32.is_eq(U32.and((id - 1 : U32),8),0)),world,target,(id * 10 + 4 : U32)))
def populate_1(~S:Data,+target:W.Handle<S>,+id:U32,errors:String,observed:W.World<S,D.Store<S>,Consumer.Resource<S>,U32> & String) -> W.World<S,D.Store<S>,Consumer.Resource<S>,U32> & String:
  (world,error)=observed
  populate_2(~S,target,id,errors ++ error,active_selected(~S,Bool.not(U32.is_eq(U32.and((id - 1 : U32),4),0)),world,target,(1 - U32.mod(id,2) : U32)))
def populate_0(~S:Data,+target:W.Handle<S>,+id:U32,errors:String,observed:W.World<S,D.Store<S>,Consumer.Resource<S>,U32> & String) -> W.World<S,D.Store<S>,Consumer.Resource<S>,U32> & String:
  (world,error)=observed
  populate_1(~S,target,id,errors ++ error,title_selected(~S,Bool.not(U32.is_eq(U32.and((id - 1 : U32),2),0)),world,target,(id * 10 + 2 : U32)))
def populated(~S:Data,+target:W.Handle<S>,+targets:List<&2,W.Handle<S>>,errors:String,observed:W.World<S,D.Store<S>,Consumer.Resource<S>,U32> & String) -> Fixture<S>:
  (world,error)=observed
  Fixture{world,List.append(&2,W.Handle<S>,targets,[target]),errors ++ error}
def populate_target(~S:Data,+target:W.Handle<S>,targets:List<&2,W.Handle<S>>,errors:String,world:W.World<S,D.Store<S>,Consumer.Resource<S>,U32>) -> Fixture<S>:
  match target:
    case W.Handle{_,+id}:populated(~S,target,targets,errors,populate_0(~S,target,id,"",stock_selected(~S,Bool.not(U32.is_eq(U32.and((id - 1 : U32),1),0)),world,target,(id * 10 + 1 : U32))))
def activated(~S:Data,+target:W.Handle<S>,targets:List<&2,W.Handle<S>>,errors:String,observed:W.World<S,D.Store<S>,Consumer.Resource<S>,U32> & W.Status) -> Fixture<S>:
  match observed:
    case (world,W.Accepted{}):populate_target(~S,target,targets,errors,world)
    case (world,W.Rejected{_}):Fixture{world,List.append(&2,W.Handle<S>,targets,[target]),errors ++ "activation-refused;"}
def reserved(~S:Data,targets:List<&2,W.Handle<S>>,errors:String,observed:W.World<S,D.Store<S>,Consumer.Resource<S>,U32> & W.Reservation<S>) -> Fixture<S>:
  match observed:
    case (world,W.Reserved{+target}):activated(~S,target,targets,errors,W.activate(~S,~D.Store<S>,~Consumer.Resource<S>,~U32,world,target))
    case (world,W.ReservationRejected{_}):Fixture{world,targets,errors ++ "reservation-refused;"}
def populate(~S:Data,fuel:Nat,fixture:Fixture<S>) -> Fixture<S>:
  match fuel fixture:
    case 0n fixture:fixture
    case 1n+rest Fixture{world,targets,errors}:populate(~S,rest,reserved(~S,targets,errors,W.reserve_id(~S,~D.Store<S>,~Consumer.Resource<S>,~U32,world)))
def missing_active(~S:Data,+target:W.Handle<S>,targets:List<&2,W.Handle<S>>,errors:String,observed:W.World<S,D.Store<S>,Consumer.Resource<S>,U32> & W.Status) -> Fixture<S>:
  match observed:
    case (world,W.Accepted{}):Fixture{Cmd.despawn_apply(~S,~D.Store<S>,~Consumer.Resource<S>,~U32,world,target),List.append(&2,W.Handle<S>,targets,[target]),errors}
    case (world,W.Rejected{_}):Fixture{world,List.append(&2,W.Handle<S>,targets,[target]),errors ++ "missing-target-activation-refused;"}
def missing_reserved(~S:Data,targets:List<&2,W.Handle<S>>,errors:String,observed:W.World<S,D.Store<S>,Consumer.Resource<S>,U32> & W.Reservation<S>) -> Fixture<S>:
  match observed:
    case (world,W.Reserved{+target}):missing_active(~S,target,targets,errors,W.activate(~S,~D.Store<S>,~Consumer.Resource<S>,~U32,world,target))
    case (world,W.ReservationRejected{_}):Fixture{world,targets,errors ++ "missing-target-reservation-refused;"}
def missing(~S:Data,fixture:Fixture<S>) -> Fixture<S>:
  match fixture:
    case Fixture{world,targets,errors}:missing_reserved(~S,targets,errors,W.reserve_id(~S,~D.Store<S>,~Consumer.Resource<S>,~U32,world))
def ticked(~S:Data,observed:W.World<S,D.Store<S>,Consumer.Resource<S>,U32> & U32) -> Built<S>:
  (world,_)=observed
  Built{missing(~S,populate(~S,16n,Fixture{world,[],""}))}
def created(~S:Data,result:W.Creation<S,D.Store<S>,Consumer.Resource<S>,U32>) -> Built<S>:
  match result:
    case W.Created{_,world}:ticked(~S,W.advance_clock(~S,~D.Store<S>,~Consumer.Resource<S>,~U32,world))
    case W.CreateRejected{factory,resource}:BuildRefused{factory,resource}
def build(~S:Data) -> Built<S>:
  created(~S,W.create(~S,~D.Store<S>,~Consumer.Resource<S>,~U32,~empty(~S),W.factory(),Consumer.Resource{Array.new(U32,2n,101),Consumer.Extra{Array.new(U32,1n,201),Array.new(U32,1n,301)},Consumer.fresh(~S)}))
def workshop() -> Built<D.Workshop>:
  build(~D.Workshop)
def main() -> Unit:
  Unit{}
