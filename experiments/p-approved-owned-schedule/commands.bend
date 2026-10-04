import Base
import ./frames.bend as F
import ../p-approved-owned-word-context/helpers.bend as W
import ../t11-replacement/runtime.bend as R
import ../t11-replacement/owned-spec.bend as O
import ../t11-replacement/types.bend as T
import ../t11-replacement/model.bend as M

def modify_observation(equal: Bool, +action: T.Action, +id: U32, -array: Array<U32>, +tag: Bool,
  -tail: List<R.Cell>, -expected: List<&2,T.Row>, e: {O.rows(tail) == expected : List<&2,T.Row>})
  -> {O.rows(R.modify_one(equal,action,R.Cell{id,array,tag},tail))
    == M.modify_one(equal,action,O.cell(R.Cell{id,array,tag}),expected) : List<&2,T.Row>}:
  match equal action:
    case False{} _:
      %e : {O.cell(R.Cell{id,array,tag}) <> O.rows(tail) == O.cell(R.Cell{id,array,tag}) <> _ : List<&2,T.Row>}
      {==}
    case True{} T.Insert{}:
      %e : {T.Row{U32.to_nat(id),O.payload(Array.get(U32,array,0)),True{}} <> O.rows(tail)
        == T.Row{U32.to_nat(id),O.payload(Array.get(U32,array,0)),True{}} <> _ : List<&2,T.Row>}
      {==}
    case True{} T.Remove{}:
      %e : {T.Row{U32.to_nat(id),O.payload(Array.get(U32,array,0)),False{}} <> O.rows(tail)
        == T.Row{U32.to_nat(id),O.payload(Array.get(U32,array,0)),False{}} <> _ : List<&2,T.Row>}
      {==}
    case True{} T.Despawn{}: e

def modify_exact(+slot: U32, +action: T.Action, +id: U32, -array: Array<U32>, +tag: Bool,
  -tail: List<R.Cell>, -owner: List<R.Cell>, e: {owner == R.modify(slot,action,tail) : List<R.Cell>})
  -> {R.modify_one(U32.is_eq(slot,id),action,R.Cell{id,array,tag},owner)
    == R.modify(slot,action,R.Cell{id,array,tag} <> tail) : List<R.Cell>}:
  %e : {R.modify_one(U32.is_eq(slot,id),action,R.Cell{id,array,tag},owner)
    == R.modify_one(U32.is_eq(slot,id),action,R.Cell{id,array,tag},_) : List<R.Cell>}
  {==}

def modify_projected(+slot: U32, +action: T.Action, +id: U32, -array: Array<U32>, +tag: Bool,
  -tail: List<R.Cell>, -owner: List<R.Cell>, e: {O.rows(owner) == M.modify(U32.to_nat(slot),action,O.rows(tail)) : List<&2,T.Row>})
  -> {O.rows(R.modify_one(U32.is_eq(slot,id),action,R.Cell{id,array,tag},owner))
    == M.modify(U32.to_nat(slot),action,O.rows(R.Cell{id,array,tag} <> tail)) : List<&2,T.Row>}:
  %W.equality(slot,id) : {O.rows(R.modify_one(U32.is_eq(slot,id),action,R.Cell{id,array,tag},owner))
    == M.modify_one(_,action,O.cell(R.Cell{id,array,tag}),M.modify(U32.to_nat(slot),action,O.rows(tail))) : List<&2,T.Row>}
  modify_observation(U32.is_eq(slot,id),action,id,array,tag,owner,M.modify(U32.to_nat(slot),action,O.rows(tail)),e)

def modify_finish(+slot: U32, +action: T.Action, +id: U32, array: Array<U32>, +tag: Bool,
  -tail: List<R.Cell>, frame: F.RowsResult<R.modify(slot,action,tail),M.modify(U32.to_nat(slot),action,O.rows(tail))>)
  -> F.RowsResult<R.modify(slot,action,R.Cell{id,array,tag} <> tail),M.modify(U32.to_nat(slot),action,O.rows(R.Cell{id,array,tag} <> tail))>:
  match frame:
    case F.RowsResult{owner,exact,observed}:
      er = modify_exact(slot,action,id,array,tag,tail,owner,exact)
      eo = modify_projected(slot,action,id,array,tag,tail,owner,observed)
      F.RowsResult{R.modify_one(U32.is_eq(slot,id),action,R.Cell{id,array,tag},owner),er,eo}

def modify(+slot: U32, +action: T.Action, rows: List<R.Cell>)
  -> F.RowsResult<R.modify(slot,action,rows),M.modify(U32.to_nat(slot),action,O.rows(rows))>:
  match rows:
    case Nil{}: F.RowsResult{[],{==},{==}}
    case Con{R.Cell{+id,array,+tag},tail}: modify_finish(slot,action,id,array,tag,tail,modify(slot,action,tail))

def apply(+command: R.Command, rows: List<R.Cell>)
  -> F.RowsResult<R.apply(command,rows),M.apply(O.command(command),O.rows(rows))>:
  match command:
    case R.Spawn{+slot,+value}: F.RowsResult{R.Cell{slot,[value : U32^0n],False{}} <> rows,{==},{==}}
    case R.Target{slot,action}: modify(slot,action,rows)

def all_exact(+command: R.Command, +tail: List<&2,R.Command>, -source: List<R.Cell>, -middle: List<R.Cell>, -owner: List<R.Cell>,
  first: {middle == R.apply(command,source) : List<R.Cell>},
  rest: {owner == R.apply_all(tail,middle) : List<R.Cell>})
  -> {owner == R.apply_all(command <> tail,source) : List<R.Cell>}:
  %first : {owner == R.apply_all(tail,_) : List<R.Cell>}
  rest

def all_observed(+command: R.Command, +tail: List<&2,R.Command>, -source: List<R.Cell>, -middle: List<R.Cell>, -owner: List<R.Cell>,
  first: {O.rows(middle) == M.apply(O.command(command),O.rows(source)) : List<&2,T.Row>},
  rest: {O.rows(owner) == M.apply_all(O.commands(tail),O.rows(middle)) : List<&2,T.Row>})
  -> {O.rows(owner) == M.apply_all(O.commands(command <> tail),O.rows(source)) : List<&2,T.Row>}:
  %first : {O.rows(owner) == M.apply_all(O.commands(tail),_) : List<&2,T.Row>}
  rest

def all_finish(+command: R.Command, +tail: List<&2,R.Command>, -source: List<R.Cell>, -middle: List<R.Cell>,
  first: {middle == R.apply(command,source) : List<R.Cell>}, projected: {O.rows(middle) == M.apply(O.command(command),O.rows(source)) : List<&2,T.Row>},
  frame: F.RowsResult<R.apply_all(tail,middle),M.apply_all(O.commands(tail),O.rows(middle))>)
  -> F.RowsResult<R.apply_all(command <> tail,source),M.apply_all(O.commands(command <> tail),O.rows(source))>:
  match frame:
    case F.RowsResult{owner,exact,observed}:
      er = all_exact(command,tail,source,middle,owner,first,exact)
      eo = all_observed(command,tail,source,middle,owner,projected,observed)
      F.RowsResult{owner,er,eo}

def all_step(+command: R.Command, +tail: List<&2,R.Command>, -source: List<R.Cell>,
  first: F.RowsResult<R.apply(command,source),M.apply(O.command(command),O.rows(source))>,
  ih: @rows:List<R.Cell> -> F.RowsResult<R.apply_all(tail,rows),M.apply_all(O.commands(tail),O.rows(rows))>)
  -> F.RowsResult<R.apply_all(command <> tail,source),M.apply_all(O.commands(command <> tail),O.rows(source))>:
  match first:
    case F.RowsResult{middle,exact,observed}: all_finish(command,tail,source,middle,exact,observed,ih(middle))

def apply_all(+commands: List<&2,R.Command>, rows: List<R.Cell>)
  -> F.RowsResult<R.apply_all(commands,rows),M.apply_all(O.commands(commands),O.rows(rows))>:
  match commands:
    case Nil{}: F.RowsResult{rows,{==},{==}}
    case Con{+command,+tail}: all_step(command,tail,rows,apply(command,rows),rest => apply_all(tail,rest))
