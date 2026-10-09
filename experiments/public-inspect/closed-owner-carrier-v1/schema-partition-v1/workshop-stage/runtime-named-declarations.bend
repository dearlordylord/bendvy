import Base
import selection.bend as Q
import runtime-declarations.bend as D
import schema-families.bend as Families
import query.bend as Queries
import traversal.bend as Traversal
import core-v1/src/ecs/inspector.bend as I
import core-v1/src/ecs/check.bend as K
import core-v1/src/ecs/component.bend as C

type ValueEmpty is Data:
  ValueEmpty{}
def name_empty(value:Unit) -> ValueEmpty:
  match value:
    case Unit{}:ValueEmpty{}
def inspect_empty(~S:Data,~Resource:Type) -> Q.Selection<I.Frame<S,Families.Store<S>,Resource,U32>,S,ValueEmpty>:
  Q.map(~I.Frame<S,Families.Store<S>,Resource,U32>,~S,~Unit,~ValueEmpty,~D.inspect_empty(~S,~Resource),~name_empty)
def inspect_empty_workshop(~Resource:Type,owner:I.Frame<Families.Workshop,Families.Store<Families.Workshop>,Resource,U32>) -> I.Frame<Families.Workshop,Families.Store<Families.Workshop>,Resource,U32> & List<&2,Queries.Row<Families.Workshop,ValueEmpty>>:
  Queries.each(~I.Frame<Families.Workshop,Families.Store<Families.Workshop>,Resource,U32>,~Families.Workshop,~ValueEmpty,~Queries.grant(~I.Frame<Families.Workshop,Families.Store<Families.Workshop>,Resource,U32>,~Families.Workshop,~ValueEmpty,~inspect_empty(~Families.Workshop,~Resource),~Traversal.inspect_world(~Families.Workshop,~Families.Store<Families.Workshop>,~Resource,~U32)),owner)
def check_empty(~S:Data,~Resource:Type) -> Q.Selection<K.Frame<S,Families.Store<S>,Resource,U32>,S,ValueEmpty>:
  Q.map(~K.Frame<S,Families.Store<S>,Resource,U32>,~S,~Unit,~ValueEmpty,~D.check_empty(~S,~Resource),~name_empty)
def check_empty_workshop(~Resource:Type,owner:K.Frame<Families.Workshop,Families.Store<Families.Workshop>,Resource,U32>) -> K.Frame<Families.Workshop,Families.Store<Families.Workshop>,Resource,U32> & List<&2,Queries.Row<Families.Workshop,ValueEmpty>>:
  Queries.each(~K.Frame<Families.Workshop,Families.Store<Families.Workshop>,Resource,U32>,~Families.Workshop,~ValueEmpty,~Queries.grant(~K.Frame<Families.Workshop,Families.Store<Families.Workshop>,Resource,U32>,~Families.Workshop,~ValueEmpty,~check_empty(~Families.Workshop,~Resource),~Traversal.check_world(~Families.Workshop,~Families.Store<Families.Workshop>,~Resource,~U32)),owner)
type ValueOptionalFour is Data:
  ValueOptionalFour{stock:C.Access<U32>,title:C.Access<String>,active:C.Access<Bool>,count:C.Access<List<&2,U32>>}
def name_optionalFour(value:Q.Product<Q.Product<Q.Product<Q.Product<Unit,C.Access<U32>>,C.Access<String>>,C.Access<Bool>>,C.Access<List<&2,U32>>>) -> ValueOptionalFour:
  match value:
    case Q.Product{Q.Product{Q.Product{Q.Product{Unit{},stock},title},active},count}:ValueOptionalFour{stock,title,active,count}
def inspect_optionalFour(~S:Data,~Resource:Type) -> Q.Selection<I.Frame<S,Families.Store<S>,Resource,U32>,S,ValueOptionalFour>:
  Q.map(~I.Frame<S,Families.Store<S>,Resource,U32>,~S,~Q.Product<Q.Product<Q.Product<Q.Product<Unit,C.Access<U32>>,C.Access<String>>,C.Access<Bool>>,C.Access<List<&2,U32>>>,~ValueOptionalFour,~D.inspect_optionalFour(~S,~Resource),~name_optionalFour)
def inspect_optionalFour_workshop(~Resource:Type,owner:I.Frame<Families.Workshop,Families.Store<Families.Workshop>,Resource,U32>) -> I.Frame<Families.Workshop,Families.Store<Families.Workshop>,Resource,U32> & List<&2,Queries.Row<Families.Workshop,ValueOptionalFour>>:
  Queries.each(~I.Frame<Families.Workshop,Families.Store<Families.Workshop>,Resource,U32>,~Families.Workshop,~ValueOptionalFour,~Queries.grant(~I.Frame<Families.Workshop,Families.Store<Families.Workshop>,Resource,U32>,~Families.Workshop,~ValueOptionalFour,~inspect_optionalFour(~Families.Workshop,~Resource),~Traversal.inspect_world(~Families.Workshop,~Families.Store<Families.Workshop>,~Resource,~U32)),owner)
def check_optionalFour(~S:Data,~Resource:Type) -> Q.Selection<K.Frame<S,Families.Store<S>,Resource,U32>,S,ValueOptionalFour>:
  Q.map(~K.Frame<S,Families.Store<S>,Resource,U32>,~S,~Q.Product<Q.Product<Q.Product<Q.Product<Unit,C.Access<U32>>,C.Access<String>>,C.Access<Bool>>,C.Access<List<&2,U32>>>,~ValueOptionalFour,~D.check_optionalFour(~S,~Resource),~name_optionalFour)
def check_optionalFour_workshop(~Resource:Type,owner:K.Frame<Families.Workshop,Families.Store<Families.Workshop>,Resource,U32>) -> K.Frame<Families.Workshop,Families.Store<Families.Workshop>,Resource,U32> & List<&2,Queries.Row<Families.Workshop,ValueOptionalFour>>:
  Queries.each(~K.Frame<Families.Workshop,Families.Store<Families.Workshop>,Resource,U32>,~Families.Workshop,~ValueOptionalFour,~Queries.grant(~K.Frame<Families.Workshop,Families.Store<Families.Workshop>,Resource,U32>,~Families.Workshop,~ValueOptionalFour,~check_optionalFour(~Families.Workshop,~Resource),~Traversal.check_world(~Families.Workshop,~Families.Store<Families.Workshop>,~Resource,~U32)),owner)
type ValueRequiredPair is Data:
  ValueRequiredPair{stock:C.Access<U32>,title:C.Access<String>,active:C.Access<Bool>,count:C.Access<List<&2,U32>>}
def name_requiredPair(value:Q.Product<Q.Product<Q.Product<Q.Product<Unit,C.Access<U32>>,C.Access<String>>,C.Access<Bool>>,C.Access<List<&2,U32>>>) -> ValueRequiredPair:
  match value:
    case Q.Product{Q.Product{Q.Product{Q.Product{Unit{},stock},title},active},count}:ValueRequiredPair{stock,title,active,count}
def inspect_requiredPair(~S:Data,~Resource:Type) -> Q.Selection<I.Frame<S,Families.Store<S>,Resource,U32>,S,ValueRequiredPair>:
  Q.map(~I.Frame<S,Families.Store<S>,Resource,U32>,~S,~Q.Product<Q.Product<Q.Product<Q.Product<Unit,C.Access<U32>>,C.Access<String>>,C.Access<Bool>>,C.Access<List<&2,U32>>>,~ValueRequiredPair,~D.inspect_requiredPair(~S,~Resource),~name_requiredPair)
def inspect_requiredPair_workshop(~Resource:Type,owner:I.Frame<Families.Workshop,Families.Store<Families.Workshop>,Resource,U32>) -> I.Frame<Families.Workshop,Families.Store<Families.Workshop>,Resource,U32> & List<&2,Queries.Row<Families.Workshop,ValueRequiredPair>>:
  Queries.each(~I.Frame<Families.Workshop,Families.Store<Families.Workshop>,Resource,U32>,~Families.Workshop,~ValueRequiredPair,~Queries.grant(~I.Frame<Families.Workshop,Families.Store<Families.Workshop>,Resource,U32>,~Families.Workshop,~ValueRequiredPair,~inspect_requiredPair(~Families.Workshop,~Resource),~Traversal.inspect_world(~Families.Workshop,~Families.Store<Families.Workshop>,~Resource,~U32)),owner)
def check_requiredPair(~S:Data,~Resource:Type) -> Q.Selection<K.Frame<S,Families.Store<S>,Resource,U32>,S,ValueRequiredPair>:
  Q.map(~K.Frame<S,Families.Store<S>,Resource,U32>,~S,~Q.Product<Q.Product<Q.Product<Q.Product<Unit,C.Access<U32>>,C.Access<String>>,C.Access<Bool>>,C.Access<List<&2,U32>>>,~ValueRequiredPair,~D.check_requiredPair(~S,~Resource),~name_requiredPair)
def check_requiredPair_workshop(~Resource:Type,owner:K.Frame<Families.Workshop,Families.Store<Families.Workshop>,Resource,U32>) -> K.Frame<Families.Workshop,Families.Store<Families.Workshop>,Resource,U32> & List<&2,Queries.Row<Families.Workshop,ValueRequiredPair>>:
  Queries.each(~K.Frame<Families.Workshop,Families.Store<Families.Workshop>,Resource,U32>,~Families.Workshop,~ValueRequiredPair,~Queries.grant(~K.Frame<Families.Workshop,Families.Store<Families.Workshop>,Resource,U32>,~Families.Workshop,~ValueRequiredPair,~check_requiredPair(~Families.Workshop,~Resource),~Traversal.check_world(~Families.Workshop,~Families.Store<Families.Workshop>,~Resource,~U32)),owner)
type ValueFiveAlias is Data:
  ValueFiveAlias{stock:C.Access<U32>,title:C.Access<String>,active:C.Access<Bool>,count:C.Access<List<&2,U32>>,stockAlias:C.Access<U32>}
def name_fiveAlias(value:Q.Product<Q.Product<Q.Product<Q.Product<Q.Product<Unit,C.Access<U32>>,C.Access<String>>,C.Access<Bool>>,C.Access<List<&2,U32>>>,C.Access<U32>>) -> ValueFiveAlias:
  match value:
    case Q.Product{Q.Product{Q.Product{Q.Product{Q.Product{Unit{},stock},title},active},count},stockAlias}:ValueFiveAlias{stock,title,active,count,stockAlias}
def inspect_fiveAlias(~S:Data,~Resource:Type) -> Q.Selection<I.Frame<S,Families.Store<S>,Resource,U32>,S,ValueFiveAlias>:
  Q.map(~I.Frame<S,Families.Store<S>,Resource,U32>,~S,~Q.Product<Q.Product<Q.Product<Q.Product<Q.Product<Unit,C.Access<U32>>,C.Access<String>>,C.Access<Bool>>,C.Access<List<&2,U32>>>,C.Access<U32>>,~ValueFiveAlias,~D.inspect_fiveAlias(~S,~Resource),~name_fiveAlias)
def inspect_fiveAlias_workshop(~Resource:Type,owner:I.Frame<Families.Workshop,Families.Store<Families.Workshop>,Resource,U32>) -> I.Frame<Families.Workshop,Families.Store<Families.Workshop>,Resource,U32> & List<&2,Queries.Row<Families.Workshop,ValueFiveAlias>>:
  Queries.each(~I.Frame<Families.Workshop,Families.Store<Families.Workshop>,Resource,U32>,~Families.Workshop,~ValueFiveAlias,~Queries.grant(~I.Frame<Families.Workshop,Families.Store<Families.Workshop>,Resource,U32>,~Families.Workshop,~ValueFiveAlias,~inspect_fiveAlias(~Families.Workshop,~Resource),~Traversal.inspect_world(~Families.Workshop,~Families.Store<Families.Workshop>,~Resource,~U32)),owner)
def check_fiveAlias(~S:Data,~Resource:Type) -> Q.Selection<K.Frame<S,Families.Store<S>,Resource,U32>,S,ValueFiveAlias>:
  Q.map(~K.Frame<S,Families.Store<S>,Resource,U32>,~S,~Q.Product<Q.Product<Q.Product<Q.Product<Q.Product<Unit,C.Access<U32>>,C.Access<String>>,C.Access<Bool>>,C.Access<List<&2,U32>>>,C.Access<U32>>,~ValueFiveAlias,~D.check_fiveAlias(~S,~Resource),~name_fiveAlias)
def check_fiveAlias_workshop(~Resource:Type,owner:K.Frame<Families.Workshop,Families.Store<Families.Workshop>,Resource,U32>) -> K.Frame<Families.Workshop,Families.Store<Families.Workshop>,Resource,U32> & List<&2,Queries.Row<Families.Workshop,ValueFiveAlias>>:
  Queries.each(~K.Frame<Families.Workshop,Families.Store<Families.Workshop>,Resource,U32>,~Families.Workshop,~ValueFiveAlias,~Queries.grant(~K.Frame<Families.Workshop,Families.Store<Families.Workshop>,Resource,U32>,~Families.Workshop,~ValueFiveAlias,~check_fiveAlias(~Families.Workshop,~Resource),~Traversal.check_world(~Families.Workshop,~Families.Store<Families.Workshop>,~Resource,~U32)),owner)
type ValueWithWithout is Data:
  ValueWithWithout{}
def name_withWithout(value:Unit) -> ValueWithWithout:
  match value:
    case Unit{}:ValueWithWithout{}
def inspect_withWithout(~S:Data,~Resource:Type) -> Q.Selection<I.Frame<S,Families.Store<S>,Resource,U32>,S,ValueWithWithout>:
  Q.map(~I.Frame<S,Families.Store<S>,Resource,U32>,~S,~Unit,~ValueWithWithout,~D.inspect_withWithout(~S,~Resource),~name_withWithout)
def inspect_withWithout_workshop(~Resource:Type,owner:I.Frame<Families.Workshop,Families.Store<Families.Workshop>,Resource,U32>) -> I.Frame<Families.Workshop,Families.Store<Families.Workshop>,Resource,U32> & List<&2,Queries.Row<Families.Workshop,ValueWithWithout>>:
  Queries.each(~I.Frame<Families.Workshop,Families.Store<Families.Workshop>,Resource,U32>,~Families.Workshop,~ValueWithWithout,~Queries.grant(~I.Frame<Families.Workshop,Families.Store<Families.Workshop>,Resource,U32>,~Families.Workshop,~ValueWithWithout,~inspect_withWithout(~Families.Workshop,~Resource),~Traversal.inspect_world(~Families.Workshop,~Families.Store<Families.Workshop>,~Resource,~U32)),owner)
def check_withWithout(~S:Data,~Resource:Type) -> Q.Selection<K.Frame<S,Families.Store<S>,Resource,U32>,S,ValueWithWithout>:
  Q.map(~K.Frame<S,Families.Store<S>,Resource,U32>,~S,~Unit,~ValueWithWithout,~D.check_withWithout(~S,~Resource),~name_withWithout)
def check_withWithout_workshop(~Resource:Type,owner:K.Frame<Families.Workshop,Families.Store<Families.Workshop>,Resource,U32>) -> K.Frame<Families.Workshop,Families.Store<Families.Workshop>,Resource,U32> & List<&2,Queries.Row<Families.Workshop,ValueWithWithout>>:
  Queries.each(~K.Frame<Families.Workshop,Families.Store<Families.Workshop>,Resource,U32>,~Families.Workshop,~ValueWithWithout,~Queries.grant(~K.Frame<Families.Workshop,Families.Store<Families.Workshop>,Resource,U32>,~Families.Workshop,~ValueWithWithout,~check_withWithout(~Families.Workshop,~Resource),~Traversal.check_world(~Families.Workshop,~Families.Store<Families.Workshop>,~Resource,~U32)),owner)
type ValueMultipleWith is Data:
  ValueMultipleWith{}
def name_multipleWith(value:Unit) -> ValueMultipleWith:
  match value:
    case Unit{}:ValueMultipleWith{}
def inspect_multipleWith(~S:Data,~Resource:Type) -> Q.Selection<I.Frame<S,Families.Store<S>,Resource,U32>,S,ValueMultipleWith>:
  Q.map(~I.Frame<S,Families.Store<S>,Resource,U32>,~S,~Unit,~ValueMultipleWith,~D.inspect_multipleWith(~S,~Resource),~name_multipleWith)
def inspect_multipleWith_workshop(~Resource:Type,owner:I.Frame<Families.Workshop,Families.Store<Families.Workshop>,Resource,U32>) -> I.Frame<Families.Workshop,Families.Store<Families.Workshop>,Resource,U32> & List<&2,Queries.Row<Families.Workshop,ValueMultipleWith>>:
  Queries.each(~I.Frame<Families.Workshop,Families.Store<Families.Workshop>,Resource,U32>,~Families.Workshop,~ValueMultipleWith,~Queries.grant(~I.Frame<Families.Workshop,Families.Store<Families.Workshop>,Resource,U32>,~Families.Workshop,~ValueMultipleWith,~inspect_multipleWith(~Families.Workshop,~Resource),~Traversal.inspect_world(~Families.Workshop,~Families.Store<Families.Workshop>,~Resource,~U32)),owner)
def check_multipleWith(~S:Data,~Resource:Type) -> Q.Selection<K.Frame<S,Families.Store<S>,Resource,U32>,S,ValueMultipleWith>:
  Q.map(~K.Frame<S,Families.Store<S>,Resource,U32>,~S,~Unit,~ValueMultipleWith,~D.check_multipleWith(~S,~Resource),~name_multipleWith)
def check_multipleWith_workshop(~Resource:Type,owner:K.Frame<Families.Workshop,Families.Store<Families.Workshop>,Resource,U32>) -> K.Frame<Families.Workshop,Families.Store<Families.Workshop>,Resource,U32> & List<&2,Queries.Row<Families.Workshop,ValueMultipleWith>>:
  Queries.each(~K.Frame<Families.Workshop,Families.Store<Families.Workshop>,Resource,U32>,~Families.Workshop,~ValueMultipleWith,~Queries.grant(~K.Frame<Families.Workshop,Families.Store<Families.Workshop>,Resource,U32>,~Families.Workshop,~ValueMultipleWith,~check_multipleWith(~Families.Workshop,~Resource),~Traversal.check_world(~Families.Workshop,~Families.Store<Families.Workshop>,~Resource,~U32)),owner)
type ValueMultipleWithout is Data:
  ValueMultipleWithout{}
def name_multipleWithout(value:Unit) -> ValueMultipleWithout:
  match value:
    case Unit{}:ValueMultipleWithout{}
def inspect_multipleWithout(~S:Data,~Resource:Type) -> Q.Selection<I.Frame<S,Families.Store<S>,Resource,U32>,S,ValueMultipleWithout>:
  Q.map(~I.Frame<S,Families.Store<S>,Resource,U32>,~S,~Unit,~ValueMultipleWithout,~D.inspect_multipleWithout(~S,~Resource),~name_multipleWithout)
def inspect_multipleWithout_workshop(~Resource:Type,owner:I.Frame<Families.Workshop,Families.Store<Families.Workshop>,Resource,U32>) -> I.Frame<Families.Workshop,Families.Store<Families.Workshop>,Resource,U32> & List<&2,Queries.Row<Families.Workshop,ValueMultipleWithout>>:
  Queries.each(~I.Frame<Families.Workshop,Families.Store<Families.Workshop>,Resource,U32>,~Families.Workshop,~ValueMultipleWithout,~Queries.grant(~I.Frame<Families.Workshop,Families.Store<Families.Workshop>,Resource,U32>,~Families.Workshop,~ValueMultipleWithout,~inspect_multipleWithout(~Families.Workshop,~Resource),~Traversal.inspect_world(~Families.Workshop,~Families.Store<Families.Workshop>,~Resource,~U32)),owner)
def check_multipleWithout(~S:Data,~Resource:Type) -> Q.Selection<K.Frame<S,Families.Store<S>,Resource,U32>,S,ValueMultipleWithout>:
  Q.map(~K.Frame<S,Families.Store<S>,Resource,U32>,~S,~Unit,~ValueMultipleWithout,~D.check_multipleWithout(~S,~Resource),~name_multipleWithout)
def check_multipleWithout_workshop(~Resource:Type,owner:K.Frame<Families.Workshop,Families.Store<Families.Workshop>,Resource,U32>) -> K.Frame<Families.Workshop,Families.Store<Families.Workshop>,Resource,U32> & List<&2,Queries.Row<Families.Workshop,ValueMultipleWithout>>:
  Queries.each(~K.Frame<Families.Workshop,Families.Store<Families.Workshop>,Resource,U32>,~Families.Workshop,~ValueMultipleWithout,~Queries.grant(~K.Frame<Families.Workshop,Families.Store<Families.Workshop>,Resource,U32>,~Families.Workshop,~ValueMultipleWithout,~check_multipleWithout(~Families.Workshop,~Resource),~Traversal.check_world(~Families.Workshop,~Families.Store<Families.Workshop>,~Resource,~U32)),owner)
type ValueRepeated is Data:
  ValueRepeated{}
def name_repeated(value:Unit) -> ValueRepeated:
  match value:
    case Unit{}:ValueRepeated{}
def inspect_repeated(~S:Data,~Resource:Type) -> Q.Selection<I.Frame<S,Families.Store<S>,Resource,U32>,S,ValueRepeated>:
  Q.map(~I.Frame<S,Families.Store<S>,Resource,U32>,~S,~Unit,~ValueRepeated,~D.inspect_repeated(~S,~Resource),~name_repeated)
def inspect_repeated_workshop(~Resource:Type,owner:I.Frame<Families.Workshop,Families.Store<Families.Workshop>,Resource,U32>) -> I.Frame<Families.Workshop,Families.Store<Families.Workshop>,Resource,U32> & List<&2,Queries.Row<Families.Workshop,ValueRepeated>>:
  Queries.each(~I.Frame<Families.Workshop,Families.Store<Families.Workshop>,Resource,U32>,~Families.Workshop,~ValueRepeated,~Queries.grant(~I.Frame<Families.Workshop,Families.Store<Families.Workshop>,Resource,U32>,~Families.Workshop,~ValueRepeated,~inspect_repeated(~Families.Workshop,~Resource),~Traversal.inspect_world(~Families.Workshop,~Families.Store<Families.Workshop>,~Resource,~U32)),owner)
def check_repeated(~S:Data,~Resource:Type) -> Q.Selection<K.Frame<S,Families.Store<S>,Resource,U32>,S,ValueRepeated>:
  Q.map(~K.Frame<S,Families.Store<S>,Resource,U32>,~S,~Unit,~ValueRepeated,~D.check_repeated(~S,~Resource),~name_repeated)
def check_repeated_workshop(~Resource:Type,owner:K.Frame<Families.Workshop,Families.Store<Families.Workshop>,Resource,U32>) -> K.Frame<Families.Workshop,Families.Store<Families.Workshop>,Resource,U32> & List<&2,Queries.Row<Families.Workshop,ValueRepeated>>:
  Queries.each(~K.Frame<Families.Workshop,Families.Store<Families.Workshop>,Resource,U32>,~Families.Workshop,~ValueRepeated,~Queries.grant(~K.Frame<Families.Workshop,Families.Store<Families.Workshop>,Resource,U32>,~Families.Workshop,~ValueRepeated,~check_repeated(~Families.Workshop,~Resource),~Traversal.check_world(~Families.Workshop,~Families.Store<Families.Workshop>,~Resource,~U32)),owner)
type ValueContradictory is Data:
  ValueContradictory{}
def name_contradictory(value:Unit) -> ValueContradictory:
  match value:
    case Unit{}:ValueContradictory{}
def inspect_contradictory(~S:Data,~Resource:Type) -> Q.Selection<I.Frame<S,Families.Store<S>,Resource,U32>,S,ValueContradictory>:
  Q.map(~I.Frame<S,Families.Store<S>,Resource,U32>,~S,~Unit,~ValueContradictory,~D.inspect_contradictory(~S,~Resource),~name_contradictory)
def inspect_contradictory_workshop(~Resource:Type,owner:I.Frame<Families.Workshop,Families.Store<Families.Workshop>,Resource,U32>) -> I.Frame<Families.Workshop,Families.Store<Families.Workshop>,Resource,U32> & List<&2,Queries.Row<Families.Workshop,ValueContradictory>>:
  Queries.each(~I.Frame<Families.Workshop,Families.Store<Families.Workshop>,Resource,U32>,~Families.Workshop,~ValueContradictory,~Queries.grant(~I.Frame<Families.Workshop,Families.Store<Families.Workshop>,Resource,U32>,~Families.Workshop,~ValueContradictory,~inspect_contradictory(~Families.Workshop,~Resource),~Traversal.inspect_world(~Families.Workshop,~Families.Store<Families.Workshop>,~Resource,~U32)),owner)
def check_contradictory(~S:Data,~Resource:Type) -> Q.Selection<K.Frame<S,Families.Store<S>,Resource,U32>,S,ValueContradictory>:
  Q.map(~K.Frame<S,Families.Store<S>,Resource,U32>,~S,~Unit,~ValueContradictory,~D.check_contradictory(~S,~Resource),~name_contradictory)
def check_contradictory_workshop(~Resource:Type,owner:K.Frame<Families.Workshop,Families.Store<Families.Workshop>,Resource,U32>) -> K.Frame<Families.Workshop,Families.Store<Families.Workshop>,Resource,U32> & List<&2,Queries.Row<Families.Workshop,ValueContradictory>>:
  Queries.each(~K.Frame<Families.Workshop,Families.Store<Families.Workshop>,Resource,U32>,~Families.Workshop,~ValueContradictory,~Queries.grant(~K.Frame<Families.Workshop,Families.Store<Families.Workshop>,Resource,U32>,~Families.Workshop,~ValueContradictory,~check_contradictory(~Families.Workshop,~Resource),~Traversal.check_world(~Families.Workshop,~Families.Store<Families.Workshop>,~Resource,~U32)),owner)
type ValueAddedBoth is Data:
  ValueAddedBoth{}
def name_addedBoth(value:Unit) -> ValueAddedBoth:
  match value:
    case Unit{}:ValueAddedBoth{}
def inspect_addedBoth(~S:Data,~Resource:Type) -> Q.Selection<I.Frame<S,Families.Store<S>,Resource,U32>,S,ValueAddedBoth>:
  Q.map(~I.Frame<S,Families.Store<S>,Resource,U32>,~S,~Unit,~ValueAddedBoth,~D.inspect_addedBoth(~S,~Resource),~name_addedBoth)
def inspect_addedBoth_workshop(~Resource:Type,owner:I.Frame<Families.Workshop,Families.Store<Families.Workshop>,Resource,U32>) -> I.Frame<Families.Workshop,Families.Store<Families.Workshop>,Resource,U32> & List<&2,Queries.Row<Families.Workshop,ValueAddedBoth>>:
  Queries.each(~I.Frame<Families.Workshop,Families.Store<Families.Workshop>,Resource,U32>,~Families.Workshop,~ValueAddedBoth,~Queries.grant(~I.Frame<Families.Workshop,Families.Store<Families.Workshop>,Resource,U32>,~Families.Workshop,~ValueAddedBoth,~inspect_addedBoth(~Families.Workshop,~Resource),~Traversal.inspect_world(~Families.Workshop,~Families.Store<Families.Workshop>,~Resource,~U32)),owner)
type ValueChangedBoth is Data:
  ValueChangedBoth{}
def name_changedBoth(value:Unit) -> ValueChangedBoth:
  match value:
    case Unit{}:ValueChangedBoth{}
def inspect_changedBoth(~S:Data,~Resource:Type) -> Q.Selection<I.Frame<S,Families.Store<S>,Resource,U32>,S,ValueChangedBoth>:
  Q.map(~I.Frame<S,Families.Store<S>,Resource,U32>,~S,~Unit,~ValueChangedBoth,~D.inspect_changedBoth(~S,~Resource),~name_changedBoth)
def inspect_changedBoth_workshop(~Resource:Type,owner:I.Frame<Families.Workshop,Families.Store<Families.Workshop>,Resource,U32>) -> I.Frame<Families.Workshop,Families.Store<Families.Workshop>,Resource,U32> & List<&2,Queries.Row<Families.Workshop,ValueChangedBoth>>:
  Queries.each(~I.Frame<Families.Workshop,Families.Store<Families.Workshop>,Resource,U32>,~Families.Workshop,~ValueChangedBoth,~Queries.grant(~I.Frame<Families.Workshop,Families.Store<Families.Workshop>,Resource,U32>,~Families.Workshop,~ValueChangedBoth,~inspect_changedBoth(~Families.Workshop,~Resource),~Traversal.inspect_world(~Families.Workshop,~Families.Store<Families.Workshop>,~Resource,~U32)),owner)
type ValueMixedFilters is Data:
  ValueMixedFilters{active:C.Access<Bool>}
def name_mixedFilters(value:Q.Product<Unit,C.Access<Bool>>) -> ValueMixedFilters:
  match value:
    case Q.Product{Unit{},active}:ValueMixedFilters{active}
def inspect_mixedFilters(~S:Data,~Resource:Type) -> Q.Selection<I.Frame<S,Families.Store<S>,Resource,U32>,S,ValueMixedFilters>:
  Q.map(~I.Frame<S,Families.Store<S>,Resource,U32>,~S,~Q.Product<Unit,C.Access<Bool>>,~ValueMixedFilters,~D.inspect_mixedFilters(~S,~Resource),~name_mixedFilters)
def inspect_mixedFilters_workshop(~Resource:Type,owner:I.Frame<Families.Workshop,Families.Store<Families.Workshop>,Resource,U32>) -> I.Frame<Families.Workshop,Families.Store<Families.Workshop>,Resource,U32> & List<&2,Queries.Row<Families.Workshop,ValueMixedFilters>>:
  Queries.each(~I.Frame<Families.Workshop,Families.Store<Families.Workshop>,Resource,U32>,~Families.Workshop,~ValueMixedFilters,~Queries.grant(~I.Frame<Families.Workshop,Families.Store<Families.Workshop>,Resource,U32>,~Families.Workshop,~ValueMixedFilters,~inspect_mixedFilters(~Families.Workshop,~Resource),~Traversal.inspect_world(~Families.Workshop,~Families.Store<Families.Workshop>,~Resource,~U32)),owner)
type ValueRepeatedAdded is Data:
  ValueRepeatedAdded{}
def name_repeatedAdded(value:Unit) -> ValueRepeatedAdded:
  match value:
    case Unit{}:ValueRepeatedAdded{}
def inspect_repeatedAdded(~S:Data,~Resource:Type) -> Q.Selection<I.Frame<S,Families.Store<S>,Resource,U32>,S,ValueRepeatedAdded>:
  Q.map(~I.Frame<S,Families.Store<S>,Resource,U32>,~S,~Unit,~ValueRepeatedAdded,~D.inspect_repeatedAdded(~S,~Resource),~name_repeatedAdded)
def inspect_repeatedAdded_workshop(~Resource:Type,owner:I.Frame<Families.Workshop,Families.Store<Families.Workshop>,Resource,U32>) -> I.Frame<Families.Workshop,Families.Store<Families.Workshop>,Resource,U32> & List<&2,Queries.Row<Families.Workshop,ValueRepeatedAdded>>:
  Queries.each(~I.Frame<Families.Workshop,Families.Store<Families.Workshop>,Resource,U32>,~Families.Workshop,~ValueRepeatedAdded,~Queries.grant(~I.Frame<Families.Workshop,Families.Store<Families.Workshop>,Resource,U32>,~Families.Workshop,~ValueRepeatedAdded,~inspect_repeatedAdded(~Families.Workshop,~Resource),~Traversal.inspect_world(~Families.Workshop,~Families.Store<Families.Workshop>,~Resource,~U32)),owner)
type ValueOptionalUnselectedFilter is Data:
  ValueOptionalUnselectedFilter{title:C.Access<String>}
def name_optionalUnselectedFilter(value:Q.Product<Unit,C.Access<String>>) -> ValueOptionalUnselectedFilter:
  match value:
    case Q.Product{Unit{},title}:ValueOptionalUnselectedFilter{title}
def inspect_optionalUnselectedFilter(~S:Data,~Resource:Type) -> Q.Selection<I.Frame<S,Families.Store<S>,Resource,U32>,S,ValueOptionalUnselectedFilter>:
  Q.map(~I.Frame<S,Families.Store<S>,Resource,U32>,~S,~Q.Product<Unit,C.Access<String>>,~ValueOptionalUnselectedFilter,~D.inspect_optionalUnselectedFilter(~S,~Resource),~name_optionalUnselectedFilter)
def inspect_optionalUnselectedFilter_workshop(~Resource:Type,owner:I.Frame<Families.Workshop,Families.Store<Families.Workshop>,Resource,U32>) -> I.Frame<Families.Workshop,Families.Store<Families.Workshop>,Resource,U32> & List<&2,Queries.Row<Families.Workshop,ValueOptionalUnselectedFilter>>:
  Queries.each(~I.Frame<Families.Workshop,Families.Store<Families.Workshop>,Resource,U32>,~Families.Workshop,~ValueOptionalUnselectedFilter,~Queries.grant(~I.Frame<Families.Workshop,Families.Store<Families.Workshop>,Resource,U32>,~Families.Workshop,~ValueOptionalUnselectedFilter,~inspect_optionalUnselectedFilter(~Families.Workshop,~Resource),~Traversal.inspect_world(~Families.Workshop,~Families.Store<Families.Workshop>,~Resource,~U32)),owner)
def main() -> Unit:
  Unit{}
