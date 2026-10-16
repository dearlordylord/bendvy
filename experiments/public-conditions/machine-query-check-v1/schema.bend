import Base
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-schema.bend as Schema
import /workspace/formal-proofs/bendvy/src/ecs/schema-fragments.bend as Fragment
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy/src/ecs/component.bend as C
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-component-binding.bend as B
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-declaration.bend as Identity
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
type Workshop is Data:Workshop{}
type Garden is Data:Garden{}
type PrimaryToken is Data:PrimaryToken{}
type BonusToken is Data:BonusToken{}
type ActiveToken is Data:ActiveToken{}
type HiddenToken is Data:HiddenToken{}
def Store(~S:Data) -> Type:Columns<S>
type Columns<S:Data> is Type:
  Columns{primary:Col.Column<S,Array<U32>>,bonus:Col.Column<S,Array<U32>>,active:Col.Column<S,Unit>,hidden:Col.Column<S,Unit>}
def empty(~S:Data,_:Unit) -> Store(~S):Columns{Col.empty(~S,~Array<U32>),Col.empty(~S,~Array<U32>),Col.empty(~S,~Unit),Col.empty(~S,~Unit)}
def array_view(value:Array<U32>) -> Array<U32> & U32:Array.get(U32,value,0)
def unit_view(value:Unit) -> Unit & Unit:(value,Unit{})
def primary_rest(~S:Data) -> Type:(Col.Column<S,Array<U32>> & Col.Column<S,Unit>) & Col.Column<S,Unit>
def take_primary(~S:Data,value:Store(~S)) -> primary_rest(~S) & Col.Column<S,Array<U32>>:
  match value:
    case Columns{primary,bonus,active,hidden}:(((bonus,active),hidden),primary)
def put_primary(~S:Data,rest:primary_rest(~S),primary:Col.Column<S,Array<U32>>) -> Store(~S):
  match rest:
    case ((bonus,active),hidden):Columns{primary,bonus,active,hidden}
def primary_identity(~S:Data) -> Identity.Declaration<S,Array<U32>>:Identity.component(~S,~Array<U32>,"Primary")
def primary(~S:Data) -> B.Binding<S,Store(~S),primary_rest(~S),Array<U32>,U32,PrimaryToken,take_primary(~S),put_primary(~S),array_view>:
  B.bind(~S,~Store(~S),~primary_rest(~S),~Array<U32>,~U32,~PrimaryToken,~take_primary(~S),~put_primary(~S),~array_view,primary_identity(~S))
def primary_family(~S:Data) -> C.Family<S,Store(~S),primary_rest(~S),Array<U32>,U32,PrimaryToken,take_primary(~S),put_primary(~S),array_view>:
  B.family(~S,~Store(~S),~primary_rest(~S),~Array<U32>,~U32,~PrimaryToken,~take_primary(~S),~put_primary(~S),~array_view,primary(~S))
def bonus_rest(~S:Data) -> Type:(Col.Column<S,Array<U32>> & Col.Column<S,Unit>) & Col.Column<S,Unit>
def take_bonus(~S:Data,value:Store(~S)) -> bonus_rest(~S) & Col.Column<S,Array<U32>>:
  match value:
    case Columns{primary,bonus,active,hidden}:(((primary,active),hidden),bonus)
def put_bonus(~S:Data,rest:bonus_rest(~S),bonus:Col.Column<S,Array<U32>>) -> Store(~S):
  match rest:
    case ((primary,active),hidden):Columns{primary,bonus,active,hidden}
def bonus_identity(~S:Data) -> Identity.Declaration<S,Array<U32>>:Identity.component(~S,~Array<U32>,"Bonus")
def bonus(~S:Data) -> B.Binding<S,Store(~S),bonus_rest(~S),Array<U32>,U32,BonusToken,take_bonus(~S),put_bonus(~S),array_view>:
  B.bind(~S,~Store(~S),~bonus_rest(~S),~Array<U32>,~U32,~BonusToken,~take_bonus(~S),~put_bonus(~S),~array_view,bonus_identity(~S))
def bonus_family(~S:Data) -> C.Family<S,Store(~S),bonus_rest(~S),Array<U32>,U32,BonusToken,take_bonus(~S),put_bonus(~S),array_view>:
  B.family(~S,~Store(~S),~bonus_rest(~S),~Array<U32>,~U32,~BonusToken,~take_bonus(~S),~put_bonus(~S),~array_view,bonus(~S))
def active_rest(~S:Data) -> Type:(Col.Column<S,Array<U32>> & Col.Column<S,Array<U32>>) & Col.Column<S,Unit>
def take_active(~S:Data,value:Store(~S)) -> active_rest(~S) & Col.Column<S,Unit>:
  match value:
    case Columns{primary,bonus,active,hidden}:(((primary,bonus),hidden),active)
def put_active(~S:Data,rest:active_rest(~S),active:Col.Column<S,Unit>) -> Store(~S):
  match rest:
    case ((primary,bonus),hidden):Columns{primary,bonus,active,hidden}
def active_identity(~S:Data) -> Identity.Declaration<S,Unit>:Identity.component(~S,~Unit,"Active")
def active(~S:Data) -> B.Binding<S,Store(~S),active_rest(~S),Unit,Unit,ActiveToken,take_active(~S),put_active(~S),unit_view>:
  B.bind(~S,~Store(~S),~active_rest(~S),~Unit,~Unit,~ActiveToken,~take_active(~S),~put_active(~S),~unit_view,active_identity(~S))
def active_family(~S:Data) -> C.Family<S,Store(~S),active_rest(~S),Unit,Unit,ActiveToken,take_active(~S),put_active(~S),unit_view>:
  B.family(~S,~Store(~S),~active_rest(~S),~Unit,~Unit,~ActiveToken,~take_active(~S),~put_active(~S),~unit_view,active(~S))
def hidden_rest(~S:Data) -> Type:(Col.Column<S,Array<U32>> & Col.Column<S,Array<U32>>) & Col.Column<S,Unit>
def take_hidden(~S:Data,value:Store(~S)) -> hidden_rest(~S) & Col.Column<S,Unit>:
  match value:
    case Columns{primary,bonus,active,hidden}:(((primary,bonus),active),hidden)
def put_hidden(~S:Data,rest:hidden_rest(~S),hidden:Col.Column<S,Unit>) -> Store(~S):
  match rest:
    case ((primary,bonus),active):Columns{primary,bonus,active,hidden}
def hidden_identity(~S:Data) -> Identity.Declaration<S,Unit>:Identity.component(~S,~Unit,"Hidden")
def hidden(~S:Data) -> B.Binding<S,Store(~S),hidden_rest(~S),Unit,Unit,HiddenToken,take_hidden(~S),put_hidden(~S),unit_view>:
  B.bind(~S,~Store(~S),~hidden_rest(~S),~Unit,~Unit,~HiddenToken,~take_hidden(~S),~put_hidden(~S),~unit_view,hidden_identity(~S))
def hidden_family(~S:Data) -> C.Family<S,Store(~S),hidden_rest(~S),Unit,Unit,HiddenToken,take_hidden(~S),put_hidden(~S),unit_view>:
  B.family(~S,~Store(~S),~hidden_rest(~S),~Unit,~Unit,~HiddenToken,~take_hidden(~S),~put_hidden(~S),~unit_view,hidden(~S))
def component_entries(~S:Data) -> List<&2,Fragment.Entry<S>>:
  List.append(&2,Fragment.Entry<S>,Schema.entries(~S,~Col.Column<S,Array<U32>>,~Unit,Schema.component(~S,~Array<U32>,primary_identity(~S))),List.append(&2,Fragment.Entry<S>,Schema.entries(~S,~Col.Column<S,Array<U32>>,~Unit,Schema.component(~S,~Array<U32>,bonus_identity(~S))),List.append(&2,Fragment.Entry<S>,Schema.entries(~S,~Col.Column<S,Unit>,~Unit,Schema.component(~S,~Unit,active_identity(~S))),Schema.entries(~S,~Col.Column<S,Unit>,~Unit,Schema.component(~S,~Unit,hidden_identity(~S))))))
