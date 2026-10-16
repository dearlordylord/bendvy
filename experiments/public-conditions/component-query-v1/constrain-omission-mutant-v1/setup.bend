import Base
import ./fixture.bend as F
import /tmp/bendvy-component-query-check/experiments/public-conditions/component-query-v1/schema.bend as Model
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/component.bend as C

type Fact<S:Data> is Data:
  Reserved{result:W.Reservation<S>}
  Activated{result:W.Status}
  Replaced{key:String}
  Rejected{key:String,error:W.WorldError}
type Returned<S:Data> is Type:
  Returned{world:F.World(~S),handles:List<&2,W.Handle<S>>,arrays:List<Maybe<&1,Array<U32>>>,units:List<Maybe<&1,Unit>>,facts:List<&2,Fact<S>>}
def append_fact(~S:Data,facts:List<&2,Fact<S>>,fact:Fact<S>) -> List<&2,Fact<S>>:List.append(&2,Fact<S>,facts,[fact])
def primary_returned(~S:Data,handles:List<&2,W.Handle<S>>,arrays:List<Maybe<&1,Array<U32>>>,units:List<Maybe<&1,Unit>>,facts:List<&2,Fact<S>>,value:C.Replacement<F.World(~S),Array<U32>>) -> Returned<S>:
  match value:
    case C.Replaced{world,previous}:Returned{world,handles,List.append(&1,Maybe<&1,Array<U32>>,arrays,[previous]),units,append_fact(~S,facts,Replaced{"Primary"})}
    case C.ReplaceRejected{world,incoming,error}:Returned{world,handles,List.append(&1,Maybe<&1,Array<U32>>,arrays,[incoming]),units,append_fact(~S,facts,Rejected{"Primary",error})}
def primary(~S:Data,state:Returned<S>,handle:W.Handle<S>,value:Array<U32>) -> Returned<S>:
  match state:
    case Returned{world,handles,arrays,units,facts}:primary_returned(~S,handles,arrays,units,facts,C.replace(~S,~Model.Store(~S),~F.Resources(~S),~Unit,~Model.primary_rest(~S),~Array<U32>,~U32,~Model.PrimaryToken,~Model.take_primary(~S),~Model.put_primary(~S),~Model.array_view,Model.primary_family(~S),world,handle,Some{value}))
def bonus_returned(~S:Data,handles:List<&2,W.Handle<S>>,arrays:List<Maybe<&1,Array<U32>>>,units:List<Maybe<&1,Unit>>,facts:List<&2,Fact<S>>,value:C.Replacement<F.World(~S),Array<U32>>) -> Returned<S>:
  match value:
    case C.Replaced{world,previous}:Returned{world,handles,List.append(&1,Maybe<&1,Array<U32>>,arrays,[previous]),units,append_fact(~S,facts,Replaced{"Bonus"})}
    case C.ReplaceRejected{world,incoming,error}:Returned{world,handles,List.append(&1,Maybe<&1,Array<U32>>,arrays,[incoming]),units,append_fact(~S,facts,Rejected{"Bonus",error})}
def bonus(~S:Data,state:Returned<S>,handle:W.Handle<S>,value:Array<U32>) -> Returned<S>:
  match state:
    case Returned{world,handles,arrays,units,facts}:bonus_returned(~S,handles,arrays,units,facts,C.replace(~S,~Model.Store(~S),~F.Resources(~S),~Unit,~Model.bonus_rest(~S),~Array<U32>,~U32,~Model.BonusToken,~Model.take_bonus(~S),~Model.put_bonus(~S),~Model.array_view,Model.bonus_family(~S),world,handle,Some{value}))
def active_returned(~S:Data,handles:List<&2,W.Handle<S>>,arrays:List<Maybe<&1,Array<U32>>>,units:List<Maybe<&1,Unit>>,facts:List<&2,Fact<S>>,value:C.Replacement<F.World(~S),Unit>) -> Returned<S>:
  match value:
    case C.Replaced{world,previous}:Returned{world,handles,arrays,List.append(&1,Maybe<&1,Unit>,units,[previous]),append_fact(~S,facts,Replaced{"Active"})}
    case C.ReplaceRejected{world,incoming,error}:Returned{world,handles,arrays,List.append(&1,Maybe<&1,Unit>,units,[incoming]),append_fact(~S,facts,Rejected{"Active",error})}
def active(~S:Data,state:Returned<S>,handle:W.Handle<S>,value:Unit) -> Returned<S>:
  match state:
    case Returned{world,handles,arrays,units,facts}:active_returned(~S,handles,arrays,units,facts,C.replace(~S,~Model.Store(~S),~F.Resources(~S),~Unit,~Model.active_rest(~S),~Unit,~Unit,~Model.ActiveToken,~Model.take_active(~S),~Model.put_active(~S),~Model.unit_view,Model.active_family(~S),world,handle,Some{value}))
def hidden_returned(~S:Data,handles:List<&2,W.Handle<S>>,arrays:List<Maybe<&1,Array<U32>>>,units:List<Maybe<&1,Unit>>,facts:List<&2,Fact<S>>,value:C.Replacement<F.World(~S),Unit>) -> Returned<S>:
  match value:
    case C.Replaced{world,previous}:Returned{world,handles,arrays,List.append(&1,Maybe<&1,Unit>,units,[previous]),append_fact(~S,facts,Replaced{"Hidden"})}
    case C.ReplaceRejected{world,incoming,error}:Returned{world,handles,arrays,List.append(&1,Maybe<&1,Unit>,units,[incoming]),append_fact(~S,facts,Rejected{"Hidden",error})}
def hidden(~S:Data,state:Returned<S>,handle:W.Handle<S>,value:Unit) -> Returned<S>:
  match state:
    case Returned{world,handles,arrays,units,facts}:hidden_returned(~S,handles,arrays,units,facts,C.replace(~S,~Model.Store(~S),~F.Resources(~S),~Unit,~Model.hidden_rest(~S),~Unit,~Unit,~Model.HiddenToken,~Model.take_hidden(~S),~Model.put_hidden(~S),~Model.unit_view,Model.hidden_family(~S),world,handle,Some{value}))
def hidden_if(~S:Data,selected:Bool,state:Returned<S>,handle:W.Handle<S>) -> Returned<S>:
  match selected:
    case False{}:state
    case True{}:hidden(~S,state,handle,Unit{})
def active_if(~S:Data,selected:Bool,state:Returned<S>,handle:W.Handle<S>) -> Returned<S>:
  match selected:
    case False{}:state
    case True{}:active(~S,state,handle,Unit{})
def bonus_if(~S:Data,selected:Bool,state:Returned<S>,handle:W.Handle<S>,seed:U32) -> Returned<S>:
  match selected:
    case False{}:state
    case True{}:bonus(~S,state,handle,F.pair(seed))
def primary_if(~S:Data,selected:Bool,state:Returned<S>,handle:W.Handle<S>,seed:U32) -> Returned<S>:
  match selected:
    case False{}:state
    case True{}:primary(~S,state,handle,F.pair(seed))
def populated(~S:Data,state:Returned<S>,+handle:W.Handle<S>,+index:U32) -> Returned<S>:
  hidden_if(~S,U32.is_eq(index,3),active_if(~S,Bool.not(U32.is_eq(index,5)),bonus_if(~S,Bool.and(Bool.not(U32.is_eq(index,2)),Bool.not(U32.is_eq(index,5))),primary_if(~S,Bool.not(U32.is_eq(index,4)),state,handle,(index*10:U32)),handle,(index*100:U32)),handle),handle)
def activated(~S:Data,handles:List<&2,W.Handle<S>>,arrays:List<Maybe<&1,Array<U32>>>,units:List<Maybe<&1,Unit>>,facts:List<&2,Fact<S>>,handle:W.Handle<S>,index:U32,value:F.World(~S) & W.Status) -> Returned<S>:
  match value:
    case (world,status):populated(~S,Returned{world,handles,arrays,units,append_fact(~S,facts,Activated{status})},handle,index)
def reserved(~S:Data,handles:List<&2,W.Handle<S>>,arrays:List<Maybe<&1,Array<U32>>>,units:List<Maybe<&1,Unit>>,facts:List<&2,Fact<S>>,index:U32,value:F.World(~S) & W.Reservation<S>) -> Returned<S>:
  match value:
    case (world,W.ReservationRejected{error}):Returned{world,handles,arrays,units,append_fact(~S,facts,Reserved{W.ReservationRejected{error}})}
    case (world,W.Reserved{+handle}):activated(~S,List.append(&2,W.Handle<S>,handles,[handle]),arrays,units,append_fact(~S,facts,Reserved{W.Reserved{handle}}),handle,index,W.activate(~S,~Model.Store(~S),~F.Resources(~S),~Unit,world,handle))
def one(~S:Data,state:Returned<S>,index:U32) -> Returned<S>:
  match state:
    case Returned{world,handles,arrays,units,facts}:reserved(~S,handles,arrays,units,facts,index,W.reserve_id(~S,~Model.Store(~S),~F.Resources(~S),~Unit,world))
def run(~S:Data,world:F.World(~S)) -> Returned<S>:one(~S,one(~S,one(~S,one(~S,one(~S,Returned{world,[],[],[],[]},1),2),3),4),5)
type Owned<S:Data> is Type:
  Owned{handles:List<&2,W.Handle<S>>,arrays:List<Maybe<&1,Array<U32>>>,units:List<Maybe<&1,Unit>>,facts:List<&2,Fact<S>>}
def retained(~S:Data,value:Returned<S>) -> F.World(~S) & Owned<S>:
  match value:
    case Returned{world,handles,arrays,units,facts}:(world,Owned{handles,arrays,units,facts})
