import Base
import ./arrays.bend as A
import ../t11-replacement/runtime.bend as R
import ../t11-replacement/owned-spec.bend as O
import ../t11-replacement/types.bend as T

type CellFrame<-original: R.Cell> is Type:
  CellFrame{owner: R.Cell, data: T.Row,
    exact: {(owner,data) == R.cell_observe(original) : R.Cell & T.Row},
    observation: {data == O.cell(original) : T.Row},
    same: {owner == original : R.Cell}}

def cell_exact(+slot: U32, +tag: Bool, -source: Array<U32>, -returned: Array<U32>, +value: U32,
  e: {(returned,value) == Array.get(U32,source,0) : Array<U32> & U32})
  -> {(R.Cell{slot,returned,tag},T.Row{U32.to_nat(slot),U32.to_nat(value),tag})
    == R.cell_observe(R.Cell{slot,source,tag}) : R.Cell & T.Row}:
  %e : {(R.Cell{slot,returned,tag},T.Row{U32.to_nat(slot),U32.to_nat(value),tag}) == R.observed_cell(slot,tag,_) : R.Cell & T.Row}
  {==}

def cell_observation(+slot: U32, +tag: Bool, -source: Array<U32>, -returned: Array<U32>, +value: U32,
  e: {(returned,value) == Array.get(U32,source,0) : Array<U32> & U32})
  -> {T.Row{U32.to_nat(slot),U32.to_nat(value),tag} == O.cell(R.Cell{slot,source,tag}) : T.Row}:
  %e : {T.Row{U32.to_nat(slot),U32.to_nat(value),tag} == T.Row{U32.to_nat(slot),O.payload(_),tag} : T.Row}
  {==}

def cell_same(+slot: U32, +tag: Bool, -source: Array<U32>, -returned: Array<U32>, e: {returned == source : Array<U32>})
  -> {R.Cell{slot,returned,tag} == R.Cell{slot,source,tag} : R.Cell}:
  %e : {R.Cell{slot,returned,tag} == R.Cell{slot,_,tag} : R.Cell}
  {==}

def capture_read(+slot: U32, +tag: Bool, -source: Array<U32>, frame: A.ReadFrame<source,0>) -> CellFrame<R.Cell{slot,source,tag}>:
  match frame:
    case A.ReadFrame{returned,+value,+e,same}:
      exact = cell_exact(slot,tag,source,returned,value,e)
      observation = cell_observation(slot,tag,source,returned,value,e)
      es = cell_same(slot,tag,source,returned,same)
      CellFrame{R.Cell{slot,returned,tag},T.Row{U32.to_nat(slot),U32.to_nat(value),tag},exact,observation,es}

def capture_cell(row: R.Cell) -> CellFrame<row>:
  match row:
    case R.Cell{+slot,array,+tag}: capture_read(slot,tag,array,A.read(array,0))

type RowsFrame<-original: List<R.Cell>> is Type:
  RowsFrame{owners: List<R.Cell>, data: List<&2,T.Row>,
    exact: {(owners,data) == R.rows_observe(original) : List<R.Cell> & List<&2,T.Row>},
    observation: {data == O.rows(original) : List<&2,T.Row>},
    same: {owners == original : List<R.Cell>}}

def rows_exact(-head: R.Cell, -tail: List<R.Cell>, -owner: R.Cell, +data: T.Row,
  -owners: List<R.Cell>, +rows: List<&2,T.Row>,
  first: {(owner,data) == R.cell_observe(head) : R.Cell & T.Row},
  rest: {(owners,rows) == R.rows_observe(tail) : List<R.Cell> & List<&2,T.Row>})
  -> {(owner <> owners,data <> rows) == R.rows_observe(head <> tail) : List<R.Cell> & List<&2,T.Row>}:
  %first : {(owner <> owners,data <> rows) == R.join_projection(_,R.rows_observe(tail)) : List<R.Cell> & List<&2,T.Row>}
  %rest : {(owner <> owners,data <> rows) == R.join_rest(owner,data,_) : List<R.Cell> & List<&2,T.Row>}
  {==}

def rows_observation(-head: R.Cell, -tail: List<R.Cell>, +data: T.Row, +rows: List<&2,T.Row>,
  first: {data == O.cell(head) : T.Row}, rest: {rows == O.rows(tail) : List<&2,T.Row>})
  -> {data <> rows == O.rows(head <> tail) : List<&2,T.Row>}:
  %first : {data <> rows == _ <> O.rows(tail) : List<&2,T.Row>}
  %rest : {data <> rows == data <> _ : List<&2,T.Row>}
  {==}

def rows_same(-head: R.Cell, -tail: List<R.Cell>, -owner: R.Cell, -owners: List<R.Cell>,
  first: {owner == head : R.Cell}, rest: {owners == tail : List<R.Cell>})
  -> {owner <> owners == head <> tail : List<R.Cell>}:
  %first : {owner <> owners == _ <> tail : List<R.Cell>}
  %rest : {owner <> owners == owner <> _ : List<R.Cell>}
  {==}

def capture_cons(-head: R.Cell, -tail: List<R.Cell>, first: CellFrame<head>, rest: RowsFrame<tail>)
  -> RowsFrame<head <> tail>:
  match first rest:
    case CellFrame{owner,+data,exact,observation,same} RowsFrame{owners,+rows,exacts,observations,sames}:
      er = rows_exact(head,tail,owner,data,owners,rows,exact,exacts)
      eo = rows_observation(head,tail,data,rows,observation,observations)
      es = rows_same(head,tail,owner,owners,same,sames)
      RowsFrame{owner <> owners,data <> rows,er,eo,es}

def capture_rows(rows: List<R.Cell>) -> RowsFrame<rows>:
  match rows:
    case Nil{}: RowsFrame{[],[],{==},{==},{==}}
    case Con{head,tail}: capture_cons(head,tail,capture_cell(head),capture_rows(tail))

def commands(+pending: List<&2,R.Command>) -> {R.commands_project(pending) == O.commands(pending) : List<&2,T.Command>}:
  match pending:
    case Nil{}: {==}
    case Con{R.Spawn{slot,value},+tail}:
      %commands(tail) : {T.Spawn{U32.to_nat(slot),U32.to_nat(value)} <> R.commands_project(tail) == T.Spawn{U32.to_nat(slot),U32.to_nat(value)} <> _ : List<&2,T.Command>}
      {==}
    case Con{R.Target{slot,action},+tail}:
      %commands(tail) : {T.Target{U32.to_nat(slot),action} <> R.commands_project(tail) == T.Target{U32.to_nat(slot),action} <> _ : List<&2,T.Command>}
      {==}

type WorldFrame<-original: R.World> is Type:
  WorldFrame{owner: R.World, data: T.World,
    exact: {(owner,data) == R.project(original) : R.World & T.World},
    observation: {data == O.snapshot(original) : T.World},
    same: {owner == original : R.World}}

def world_exact(+id: U32, +next: U32, +pending: List<&2,R.Command>,
  -source: List<R.Cell>, -owners: List<R.Cell>, +rows: List<&2,T.Row>,
  exact: {(owners,rows) == R.rows_observe(source) : List<R.Cell> & List<&2,T.Row>})
  -> {(R.World{id,next,owners,pending},T.World{U32.to_nat(id),U32.to_nat(next),rows,R.commands_project(pending)})
    == R.project(R.World{id,next,source,pending}) : R.World & T.World}:
  %exact : {(R.World{id,next,owners,pending},T.World{U32.to_nat(id),U32.to_nat(next),rows,R.commands_project(pending)})
    == R.world_projection(id,next,pending,_) : R.World & T.World}
  {==}

def world_observation(+id: U32, +next: U32, +pending: List<&2,R.Command>, -source: List<R.Cell>, +rows: List<&2,T.Row>,
  observed: {rows == O.rows(source) : List<&2,T.Row>})
  -> {T.World{U32.to_nat(id),U32.to_nat(next),rows,R.commands_project(pending)} == O.snapshot(R.World{id,next,source,pending}) : T.World}:
  %observed : {T.World{U32.to_nat(id),U32.to_nat(next),rows,R.commands_project(pending)} == T.World{U32.to_nat(id),U32.to_nat(next),_,O.commands(pending)} : T.World}
  %commands(pending) : {T.World{U32.to_nat(id),U32.to_nat(next),rows,R.commands_project(pending)} == T.World{U32.to_nat(id),U32.to_nat(next),rows,_} : T.World}
  {==}

def world_same(+id: U32, +next: U32, +pending: List<&2,R.Command>, -source: List<R.Cell>, -owners: List<R.Cell>,
  e: {owners == source : List<R.Cell>}) -> {R.World{id,next,owners,pending} == R.World{id,next,source,pending} : R.World}:
  %e : {R.World{id,next,owners,pending} == R.World{id,next,_,pending} : R.World}
  {==}

def capture_world_rows(+id: U32, +next: U32, +pending: List<&2,R.Command>, -source: List<R.Cell>, frame: RowsFrame<source>)
  -> WorldFrame<R.World{id,next,source,pending}>:
  match frame:
    case RowsFrame{owners,+rows,exact,observed,same}:
      er = world_exact(id,next,pending,source,owners,rows,exact)
      eo = world_observation(id,next,pending,source,rows,observed)
      es = world_same(id,next,pending,source,owners,same)
      WorldFrame{R.World{id,next,owners,pending},T.World{U32.to_nat(id),U32.to_nat(next),rows,R.commands_project(pending)},er,eo,es}

def capture_world(world: R.World) -> WorldFrame<world>:
  match world:
    case R.World{+id,+next,rows,+pending}: capture_world_rows(id,next,pending,rows,capture_rows(rows))
