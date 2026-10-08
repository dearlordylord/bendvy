import Base
import fixture-schema.bend as D
import core-v1/src/ecs/world.bend as W
import core-v1/src/ecs/component.bend as C
import core-v1/src/ecs/relation-commands.bend as A

type Fixture<S:Data> is Type:
  Fixture{world:W.World<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>>,targets:List<&2,W.Handle<S>>,errors:String}
type Built<S:Data> is Type:
  Built{factory:W.Factory,fixture:Fixture<S>}
  BuildRefused{factory:W.Factory,resource:D.Resources}
def stock_replaced(~S:Data,result:C.Replacement<W.World<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>>,D.Stock>) -> W.World<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & String:
  match result:
    case C.Replaced{world,_}:(world,"")
    case C.ReplaceRejected{world,_,_}:(world,"stock-replacement-refused;")
def stock_selected(~S:Data,allowed:Bool,world:W.World<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>>,target:W.Handle<S>,value:U32) -> W.World<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & String:
  match allowed:
    case False{}:(world,"")
    case True{}:stock_replaced(~S,C.replace(~S,~A.Store<S,D.Components<S>>,~D.Resources,~A.Notice<S,D.FixtureEvent>,~D.StockRest<S>,~D.Stock,~U32,~D.StockToken,~D.take_stock(~S),~D.put_stock(~S),~D.project_stock,D.stock(~S),world,target,Some{D.Stock{Array.new(U32,0n,value)}}))
def title_replaced(~S:Data,result:C.Replacement<W.World<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>>,D.Title>) -> W.World<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & String:
  match result:
    case C.Replaced{world,_}:(world,"")
    case C.ReplaceRejected{world,_,_}:(world,"title-replacement-refused;")
def title_selected(~S:Data,allowed:Bool,world:W.World<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>>,target:W.Handle<S>,value:U32) -> W.World<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & String:
  match allowed:
    case False{}:(world,"")
    case True{}:title_replaced(~S,C.replace(~S,~A.Store<S,D.Components<S>>,~D.Resources,~A.Notice<S,D.FixtureEvent>,~D.TitleRest<S>,~D.Title,~String,~D.TitleToken,~D.take_title(~S),~D.put_title(~S),~D.project_title,D.title(~S),world,target,Some{D.Title{Array.new(U32,0n,value)}}))
def title_populated(~S:Data,target:W.Handle<S>,targets:List<&2,W.Handle<S>>,errors:String,observed:W.World<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & String) -> Fixture<S>:
  (world,error)=observed
  Fixture{world,List.append(&2,W.Handle<S>,targets,[target]),errors ++ error}
def target_id(~S:Data,target:W.Handle<S>) -> U32:
  match target:
    case W.Handle{_,id}:id
def stock_populated(~S:Data,+base:U32,+target:W.Handle<S>,targets:List<&2,W.Handle<S>>,errors:String,observed:W.World<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & String) -> Fixture<S>:
  (world,error)=observed
  +id=target_id(~S,target)
  title_populated(~S,target,targets,errors ++ error,title_selected(~S,Bool.not(U32.is_eq(id,1)),world,target,(base + 20 + id : U32)))
def activated(~S:Data,+base:U32,+target:W.Handle<S>,targets:List<&2,W.Handle<S>>,errors:String,observed:W.World<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & W.Status) -> Fixture<S>:
  match observed:
    case (world,W.Accepted{}):
      +id=target_id(~S,target)
      stock_populated(~S,base,target,targets,errors,stock_selected(~S,Bool.not(U32.is_eq(id,3)),world,target,(base + 10 + id : U32)))
    case (world,W.Rejected{_}):Fixture{world,targets,errors ++ "activation-refused;"}
def reserved(~S:Data,base:U32,targets:List<&2,W.Handle<S>>,errors:String,observed:W.World<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & W.Reservation<S>) -> Fixture<S>:
  match observed:
    case (world,W.Reserved{+target}):activated(~S,base,target,targets,errors,W.activate(~S,~A.Store<S,D.Components<S>>,~D.Resources,~A.Notice<S,D.FixtureEvent>,world,target))
    case (world,W.ReservationRejected{_}):Fixture{world,targets,errors ++ "reservation-refused;"}
def populate(~S:Data,+base:U32,fuel:Nat,fixture:Fixture<S>) -> Fixture<S>:
  match fuel fixture:
    case 0n fixture:fixture
    case 1n+rest Fixture{world,targets,errors}:populate(~S,base,rest,reserved(~S,base,targets,errors,W.reserve_id(~S,~A.Store<S,D.Components<S>>,~D.Resources,~A.Notice<S,D.FixtureEvent>,world)))
def inactive(~S:Data,targets:List<&2,W.Handle<S>>,errors:String,observed:W.World<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & W.Status) -> Fixture<S>:
  match observed:
    case (world,W.Accepted{}):Fixture{world,targets,errors}
    case (world,W.Rejected{_}):Fixture{world,targets,errors ++ "stale-deactivation-refused;"}
def stale_active(~S:Data,+target:W.Handle<S>,targets:List<&2,W.Handle<S>>,errors:String,observed:W.World<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & W.Status) -> Fixture<S>:
  match observed:
    case (world,W.Accepted{}):inactive(~S,targets,errors,W.deactivate(~S,~A.Store<S,D.Components<S>>,~D.Resources,~A.Notice<S,D.FixtureEvent>,world,target))
    case (world,W.Rejected{_}):Fixture{world,targets,errors ++ "stale-activation-refused;"}
def stale_reserved(~S:Data,targets:List<&2,W.Handle<S>>,errors:String,observed:W.World<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & W.Reservation<S>) -> Fixture<S>:
  match observed:
    case (world,W.Reserved{+target}):stale_active(~S,target,targets,errors,W.activate(~S,~A.Store<S,D.Components<S>>,~D.Resources,~A.Notice<S,D.FixtureEvent>,world,target))
    case (world,W.ReservationRejected{_}):Fixture{world,targets,errors ++ "stale-reservation-refused;"}
def stale(~S:Data,fixture:Fixture<S>) -> Fixture<S>:
  match fixture:
    case Fixture{world,targets,errors}:stale_reserved(~S,targets,errors,W.reserve_id(~S,~A.Store<S,D.Components<S>>,~D.Resources,~A.Notice<S,D.FixtureEvent>,world))
def created(~S:Data,base:U32,result:W.Creation<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>>) -> Built<S>:
  match result:
    case W.Created{factory,world}:Built{factory,stale(~S,populate(~S,base,4n,Fixture{world,[],""}))}
    case W.CreateRejected{factory,resource}:BuildRefused{factory,resource}
def build(~S:Data,+base:U32,factory:W.Factory) -> Built<S>:
  created(~S,base,W.create(~S,~A.Store<S,D.Components<S>>,~D.Resources,~A.Notice<S,D.FixtureEvent>,~D.empty(~S),factory,D.Resources{Array.new(U32,0n,(base + 31 : U32)),Array.new(U32,0n,(base + 32 : U32))}))
