import Base
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-query-selections.bend as Ordinary
import /workspace/formal-proofs/bendvy/src/ecs/inspector-query-projection.bend as Q
import runtime-declarations.bend as D
import schema-families.bend as Families
import /workspace/formal-proofs/bendvy/src/ecs/inspector-query.bend as Queries
import /workspace/formal-proofs/bendvy/src/ecs/inspector-query-world.bend as Traversal
import /workspace/formal-proofs/bendvy/src/ecs/inspector.bend as I
import /workspace/formal-proofs/bendvy/src/ecs/check.bend as K
import /workspace/formal-proofs/bendvy/src/ecs/component.bend as C

type ValueEmpty is Data:
  ValueEmpty{}
type ValueOptionalFour is Data:
  ValueOptionalFour{stock:C.Access<U32>,title:C.Access<String>,active:C.Access<Bool>,count:C.Access<List<&2,U32>>}
type ValueRequiredPair is Data:
  ValueRequiredPair{stock:C.Access<U32>,title:C.Access<String>,active:C.Access<Bool>,count:C.Access<List<&2,U32>>}
type ValueFiveAlias is Data:
  ValueFiveAlias{stock:C.Access<U32>,title:C.Access<String>,active:C.Access<Bool>,count:C.Access<List<&2,U32>>,stockAlias:C.Access<U32>}
type ValueMixedFilters is Data:
  ValueMixedFilters{active:C.Access<Bool>}
type ValueOptionalUnselectedFilter is Data:
  ValueOptionalUnselectedFilter{title:C.Access<String>}
def name_empty(value:Unit) -> ValueEmpty:
  match value:
    case Unit{}:ValueEmpty{}
def inspect_empty(~S:Data,~Resource:Type) -> Q.DeclaredSelection<I.Frame<S,Families.Store<S>,Resource,U32>,S,ValueEmpty>:
  Q.map(~I.Frame<S,Families.Store<S>,Resource,U32>,~S,~Unit,~ValueEmpty,~D.inspect_empty(~S,~Resource),~name_empty)
def check_empty(~S:Data,~Resource:Type) -> Q.DeclaredSelection<K.Frame<S,Families.Store<S>,Resource,U32>,S,ValueEmpty>:
  Q.map(~K.Frame<S,Families.Store<S>,Resource,U32>,~S,~Unit,~ValueEmpty,~D.check_empty(~S,~Resource),~name_empty)
def name_optionalFour(value:Q.Product<Q.Product<Q.Product<Q.Product<Unit,C.Access<U32>>,C.Access<String>>,C.Access<Bool>>,C.Access<List<&2,U32>>>) -> ValueOptionalFour:
  match value:
    case Q.Product{Q.Product{Q.Product{Q.Product{Unit{},stock},title},active},count}:ValueOptionalFour{stock,title,active,count}
def inspect_optionalFour(~S:Data,~Resource:Type) -> Q.DeclaredSelection<I.Frame<S,Families.Store<S>,Resource,U32>,S,ValueOptionalFour>:
  Q.map(~I.Frame<S,Families.Store<S>,Resource,U32>,~S,~Q.Product<Q.Product<Q.Product<Q.Product<Unit,C.Access<U32>>,C.Access<String>>,C.Access<Bool>>,C.Access<List<&2,U32>>>,~ValueOptionalFour,~D.inspect_optionalFour(~S,~Resource),~name_optionalFour)
def check_optionalFour(~S:Data,~Resource:Type) -> Q.DeclaredSelection<K.Frame<S,Families.Store<S>,Resource,U32>,S,ValueOptionalFour>:
  Q.map(~K.Frame<S,Families.Store<S>,Resource,U32>,~S,~Q.Product<Q.Product<Q.Product<Q.Product<Unit,C.Access<U32>>,C.Access<String>>,C.Access<Bool>>,C.Access<List<&2,U32>>>,~ValueOptionalFour,~D.check_optionalFour(~S,~Resource),~name_optionalFour)
def name_requiredPair(value:Q.Product<Q.Product<Q.Product<Q.Product<Unit,C.Access<U32>>,C.Access<String>>,C.Access<Bool>>,C.Access<List<&2,U32>>>) -> ValueRequiredPair:
  match value:
    case Q.Product{Q.Product{Q.Product{Q.Product{Unit{},stock},title},active},count}:ValueRequiredPair{stock,title,active,count}
def inspect_requiredPair(~S:Data,~Resource:Type) -> Q.DeclaredSelection<I.Frame<S,Families.Store<S>,Resource,U32>,S,ValueRequiredPair>:
  Q.map(~I.Frame<S,Families.Store<S>,Resource,U32>,~S,~Q.Product<Q.Product<Q.Product<Q.Product<Unit,C.Access<U32>>,C.Access<String>>,C.Access<Bool>>,C.Access<List<&2,U32>>>,~ValueRequiredPair,~D.inspect_requiredPair(~S,~Resource),~name_requiredPair)
def check_requiredPair(~S:Data,~Resource:Type) -> Q.DeclaredSelection<K.Frame<S,Families.Store<S>,Resource,U32>,S,ValueRequiredPair>:
  Q.map(~K.Frame<S,Families.Store<S>,Resource,U32>,~S,~Q.Product<Q.Product<Q.Product<Q.Product<Unit,C.Access<U32>>,C.Access<String>>,C.Access<Bool>>,C.Access<List<&2,U32>>>,~ValueRequiredPair,~D.check_requiredPair(~S,~Resource),~name_requiredPair)
def name_fiveAlias(value:Q.Product<Q.Product<Q.Product<Q.Product<Q.Product<Unit,C.Access<U32>>,C.Access<String>>,C.Access<Bool>>,C.Access<List<&2,U32>>>,C.Access<U32>>) -> ValueFiveAlias:
  match value:
    case Q.Product{Q.Product{Q.Product{Q.Product{Q.Product{Unit{},stock},title},active},count},stockAlias}:ValueFiveAlias{stock,title,active,count,stockAlias}
def inspect_fiveAlias(~S:Data,~Resource:Type) -> Q.DeclaredSelection<I.Frame<S,Families.Store<S>,Resource,U32>,S,ValueFiveAlias>:
  Q.map(~I.Frame<S,Families.Store<S>,Resource,U32>,~S,~Q.Product<Q.Product<Q.Product<Q.Product<Q.Product<Unit,C.Access<U32>>,C.Access<String>>,C.Access<Bool>>,C.Access<List<&2,U32>>>,C.Access<U32>>,~ValueFiveAlias,~D.inspect_fiveAlias(~S,~Resource),~name_fiveAlias)
def check_fiveAlias(~S:Data,~Resource:Type) -> Q.DeclaredSelection<K.Frame<S,Families.Store<S>,Resource,U32>,S,ValueFiveAlias>:
  Q.map(~K.Frame<S,Families.Store<S>,Resource,U32>,~S,~Q.Product<Q.Product<Q.Product<Q.Product<Q.Product<Unit,C.Access<U32>>,C.Access<String>>,C.Access<Bool>>,C.Access<List<&2,U32>>>,C.Access<U32>>,~ValueFiveAlias,~D.check_fiveAlias(~S,~Resource),~name_fiveAlias)
def inspect_withWithout(~S:Data,~Resource:Type) -> Q.DeclaredSelection<I.Frame<S,Families.Store<S>,Resource,U32>,S,Unit>:
  D.inspect_withWithout(~S,~Resource)
def check_withWithout(~S:Data,~Resource:Type) -> Q.DeclaredSelection<K.Frame<S,Families.Store<S>,Resource,U32>,S,Unit>:
  D.check_withWithout(~S,~Resource)
def inspect_multipleWith(~S:Data,~Resource:Type) -> Q.DeclaredSelection<I.Frame<S,Families.Store<S>,Resource,U32>,S,Unit>:
  D.inspect_multipleWith(~S,~Resource)
def check_multipleWith(~S:Data,~Resource:Type) -> Q.DeclaredSelection<K.Frame<S,Families.Store<S>,Resource,U32>,S,Unit>:
  D.check_multipleWith(~S,~Resource)
def inspect_multipleWithout(~S:Data,~Resource:Type) -> Q.DeclaredSelection<I.Frame<S,Families.Store<S>,Resource,U32>,S,Unit>:
  D.inspect_multipleWithout(~S,~Resource)
def check_multipleWithout(~S:Data,~Resource:Type) -> Q.DeclaredSelection<K.Frame<S,Families.Store<S>,Resource,U32>,S,Unit>:
  D.check_multipleWithout(~S,~Resource)
def inspect_repeated(~S:Data,~Resource:Type) -> Q.DeclaredSelection<I.Frame<S,Families.Store<S>,Resource,U32>,S,Unit>:
  D.inspect_repeated(~S,~Resource)
def check_repeated(~S:Data,~Resource:Type) -> Q.DeclaredSelection<K.Frame<S,Families.Store<S>,Resource,U32>,S,Unit>:
  D.check_repeated(~S,~Resource)
def inspect_contradictory(~S:Data,~Resource:Type) -> Q.DeclaredSelection<I.Frame<S,Families.Store<S>,Resource,U32>,S,Unit>:
  D.inspect_contradictory(~S,~Resource)
def check_contradictory(~S:Data,~Resource:Type) -> Q.DeclaredSelection<K.Frame<S,Families.Store<S>,Resource,U32>,S,Unit>:
  D.check_contradictory(~S,~Resource)
def inspect_addedBoth(~S:Data,~Resource:Type) -> Q.DeclaredSelection<I.Frame<S,Families.Store<S>,Resource,U32>,S,Unit>:
  D.inspect_addedBoth(~S,~Resource)
def inspect_changedBoth(~S:Data,~Resource:Type) -> Q.DeclaredSelection<I.Frame<S,Families.Store<S>,Resource,U32>,S,Unit>:
  D.inspect_changedBoth(~S,~Resource)
def name_mixedFilters(value:Q.Product<Unit,C.Access<Bool>>) -> ValueMixedFilters:
  match value:
    case Q.Product{Unit{},active}:ValueMixedFilters{active}
def inspect_mixedFilters(~S:Data,~Resource:Type) -> Q.DeclaredSelection<I.Frame<S,Families.Store<S>,Resource,U32>,S,ValueMixedFilters>:
  Q.map(~I.Frame<S,Families.Store<S>,Resource,U32>,~S,~Q.Product<Unit,C.Access<Bool>>,~ValueMixedFilters,~D.inspect_mixedFilters(~S,~Resource),~name_mixedFilters)
def inspect_repeatedAdded(~S:Data,~Resource:Type) -> Q.DeclaredSelection<I.Frame<S,Families.Store<S>,Resource,U32>,S,Unit>:
  D.inspect_repeatedAdded(~S,~Resource)
def name_optionalUnselectedFilter(value:Q.Product<Unit,C.Access<String>>) -> ValueOptionalUnselectedFilter:
  match value:
    case Q.Product{Unit{},title}:ValueOptionalUnselectedFilter{title}
def inspect_optionalUnselectedFilter(~S:Data,~Resource:Type) -> Q.DeclaredSelection<I.Frame<S,Families.Store<S>,Resource,U32>,S,ValueOptionalUnselectedFilter>:
  Q.map(~I.Frame<S,Families.Store<S>,Resource,U32>,~S,~Q.Product<Unit,C.Access<String>>,~ValueOptionalUnselectedFilter,~D.inspect_optionalUnselectedFilter(~S,~Resource),~name_optionalUnselectedFilter)
def main() -> Unit:
  Unit{}
