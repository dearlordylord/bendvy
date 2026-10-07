import Base
import ../../../src/ecs/column.bend as Col
import ../../../src/ecs/owner-handoff.bend as H
import ../../../src/ecs/indexed-lifecycle.bend as M
# This trusted seam starts only from Inspect. Public arbitrary Choice remains
# with the exact original helper. Every Decision owns all its actual fields.
type Decision<-S:Data,-C:Type> is Type:
  Found{owner:C,remaining:H.PrototypeHandoffRows<S,C>,past:Col.History<S,C>}
  Absent{remaining:H.PrototypeHandoffRows<S,C>,past:Col.History<S,C>}
  Advance{remaining:H.PrototypeHandoffRows<S,C>,past:Col.History<S,C>}
  Exhausted{remaining:H.PrototypeHandoffRows<S,C>,past:Col.History<S,C>}
  Wrapped{inner:Decision<S,C>}
def choose(~S:Data,~C:Type,+id:U32,owner:C,remaining:H.PrototypeHandoffRows<S,C>,past:Col.History<S,C>,equal:Bool,before:Bool) -> Decision<S,C>:
  match equal before:
    case True{} _: Found{owner,remaining,past}
    case False{} True{}: Absent{H.HandoffCon{id,owner,remaining},past}
    case False{} False{}: Advance{remaining,Col.HistoryCon{id,Some{owner},past}}
def step(~S:Data,~C:Type,fuel:Nat,remaining:H.PrototypeHandoffRows<S,C>,past:Col.History<S,C>,+target:U32) -> Decision<S,C>:
  match fuel remaining:
    case _ H.HandoffNil{}: Absent{H.HandoffNil{},past}
    case 0n H.HandoffCon{id,owner,rest}: Exhausted{H.HandoffCon{id,owner,rest},past}
    case 1n H.HandoffCon{id,owner,rest}: Exhausted{H.HandoffCon{id,owner,rest},past}
    case 2n+more H.HandoffCon{+id,owner,rest}: choose(~S,~C,id,owner,rest,past,U32.is_eq(target,id),U32.is_lt(target,id))
def finish_absent(~S:Data,~C:Type,~V:Data,values:Array<Maybe<&1,C>>,metadata:M.Metadata,capacity:U32,current:U32,remaining:H.PrototypeHandoffRows<S,C>,past:Col.History<S,C>) -> Col.Column<S,C> & Maybe<&2,V>:
  (Col.PreparedIndexed{Col.IndexedPreparedOwned{Col.IndexedPreparedState{values,metadata,capacity,current,None{},remaining,past}}},None{})
def loop(~S:Data,~C:Type,~V:Data,~project:C -> C & V,fuel:Nat,values:Array<Maybe<&1,C>>,metadata:M.Metadata,capacity:U32,+target:U32,decision:Decision<S,C>) -> Col.Column<S,C> & Maybe<&2,V>:
  match fuel decision:
    case _ Found{owner,remaining,past}: Col.indexed_prepared_view_projected(~S,~C,~V,values,metadata,capacity,target,remaining,past,project(owner))
    case _ Absent{remaining,past}: finish_absent(~S,~C,~V,values,metadata,capacity,target,remaining,past)
    case _ Exhausted{remaining,past}: finish_absent(~S,~C,~V,values,metadata,capacity,0,remaining,past)
    case _ Wrapped{inner}: loop(~S,~C,~V,~project,fuel,values,metadata,capacity,target,inner)
    case 0n Advance{remaining,past}: finish_absent(~S,~C,~V,values,metadata,capacity,0,remaining,past)
    case 1n Advance{remaining,past}: finish_absent(~S,~C,~V,values,metadata,capacity,0,remaining,past)
    case 2n++more Advance{remaining,past}: loop(~S,~C,~V,~project,more,values,metadata,capacity,target,step(~S,~C,more,remaining,past,target))
def inspect(~S:Data,~C:Type,~V:Data,~project:C -> C & V,+fuel:Nat,values:Array<Maybe<&1,C>>,metadata:M.Metadata,capacity:U32,+target:U32,remaining:H.PrototypeHandoffRows<S,C>,past:Col.History<S,C>) -> Col.Column<S,C> & Maybe<&2,V>:
  loop(~S,~C,~V,~project,fuel,values,metadata,capacity,target,step(~S,~C,fuel,remaining,past,target))
