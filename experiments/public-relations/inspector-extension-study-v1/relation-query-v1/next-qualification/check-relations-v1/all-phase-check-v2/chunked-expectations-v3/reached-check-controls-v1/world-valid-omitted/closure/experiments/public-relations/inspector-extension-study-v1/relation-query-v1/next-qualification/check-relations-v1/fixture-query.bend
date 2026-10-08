import Base
import ../../fixture-schema.bend as D
import ../../fixture-specs.bend as Spec
import adapter.bend as Bridge
import ../../families.bend as Family
import ../../selection.bend as Select
import ../../query.bend as Query
import ../../core-v1/src/ecs/check.bend as K
import ../../core-v1/src/ecs/component.bend as C
import ../../core-v1/src/ecs/relation-query.bend as RQ
import ../../core-v1/src/ecs/relation-commands.bend as A

def stock(~S:Data,~mode:Family.SlotMode) -> Select.Selection<K.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>>,S,C.Access<U32>>:
  Family.check_slot(~S,~A.Store<S,D.Components<S>>,~D.Resources,~A.Notice<S,D.FixtureEvent>,~D.StockRest<S>,~D.Stock,~U32,~D.StockToken,~D.take_stock(~S),~D.put_stock(~S),~D.project_stock,~D.stock(~S),~mode)
def title(~S:Data,~mode:Family.SlotMode) -> Select.Selection<K.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>>,S,C.Access<String>>:
  Family.check_slot(~S,~A.Store<S,D.Components<S>>,~D.Resources,~A.Notice<S,D.FixtureEvent>,~D.TitleRest<S>,~D.Title,~String,~D.TitleToken,~D.take_title(~S),~D.put_title(~S),~D.project_title,~D.title(~S),~mode)
def combined(~S:Data,~stockMode:Family.SlotMode,~titleMode:Family.SlotMode) -> Select.Selection<K.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>>,S,Select.Product<C.Access<U32>,C.Access<String>>>:
  Select.pair(~K.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>>,~S,~C.Access<U32>,~C.Access<String>,~stock(~S,~stockMode),~title(~S,~titleMode))
def declared(~S:Data,~stockMode:Family.SlotMode,~titleMode:Family.SlotMode,~shape:Spec.RelationShape) -> Query.ReadQuery<K.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>>,S,Select.Product<Select.Product<C.Access<U32>,C.Access<String>>,List<&2,RQ.Cell<S>>>>:
  Bridge.grant(~S,~D.Components<S>,~D.Resources,~D.FixtureEvent,~Select.Product<C.Access<U32>,C.Access<String>>,~combined(~S,~stockMode,~titleMode),~Spec.spec(~S,shape))
