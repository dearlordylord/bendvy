import Base
import ../t11-replacement/runtime.bend as R
import ../t11-replacement/owned-spec.bend as O
import ../t11-replacement/types.bend as T

type CellResult<-actual: R.Cell, -expected: T.Row> is Type:
  CellResult{owner: R.Cell, exact: {owner == actual : R.Cell},
    observed: {O.cell(owner) == expected : T.Row}}

type RowsResult<-actual: List<R.Cell>, -expected: List<&2,T.Row>> is Type:
  RowsResult{owner: List<R.Cell>, exact: {owner == actual : List<R.Cell>},
    observed: {O.rows(owner) == expected : List<&2,T.Row>}}

type WorldResult<-actual: R.World, -expected: T.World> is Type:
  WorldResult{owner: R.World, exact: {owner == actual : R.World},
    observed: {O.snapshot(owner) == expected : T.World}}
