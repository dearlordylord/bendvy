import Base
import ./arrays.bend as A
import ./point.bend as P
import ./frames.bend as F
import ../p-approved-owned-word-context/helpers.bend as W
import ../t11-replacement/runtime.bend as R
import ../t11-replacement/owned-spec.bend as O
import ../t11-replacement/types.bend as T
import ../t11-replacement/model.bend as M

def source_value(-source: Array<U32>, -returned: Array<U32>, +value: U32,
  read: {(returned,value) == Array.get(U32,source,0) : Array<U32> & U32})
  -> {U32.to_nat(value) == O.payload(Array.get(U32,source,0)) : Nat}:
  %read : {U32.to_nat(value) == O.payload(_) : Nat}
  {==}

def scalar_safe(-source: Array<U32>, -returned: Array<U32>, +value: U32,
  read: {(returned,value) == Array.get(U32,source,0) : Array<U32> & U32},
  safe: {True{} == Bool.not(Nat.is_ge(O.payload(Array.get(U32,source,0)),U32.to_nat(4294967295))) : Bool})
  -> {True{} == Bool.not(Nat.is_ge(U32.to_nat(value),U32.to_nat(4294967295))) : Bool}:
  %Equal.sym(Nat,U32.to_nat(value),O.payload(Array.get(U32,source,0)),source_value(source,returned,value,read)) :
    {True{} == Bool.not(Nat.is_ge(_,U32.to_nat(4294967295))) : Bool}
  safe

def cell_exact(+id: U32, +tag: Bool, -source: Array<U32>, -read_owner: Array<U32>, +value: U32, -owner: Array<U32>,
  read: {(read_owner,value) == Array.get(U32,source,0) : Array<U32> & U32},
  set: {owner == Array.set(U32,read_owner,0,U32.add(value,1)) : Array<U32>})
  -> {R.Cell{id,owner,tag} == R.bump_cell(True{},R.Cell{id,source,tag}) : R.Cell}:
  %read : {R.Cell{id,owner,tag} == R.bumped_cell(id,tag,_) : R.Cell}
  %set : {R.Cell{id,owner,tag} == R.Cell{id,_,tag} : R.Cell}
  {==}

def cell_observed(+id: U32, +tag: Bool, -source: Array<U32>, -read_owner: Array<U32>, +value: U32, -owner: Array<U32>,
  read: {(read_owner,value) == Array.get(U32,source,0) : Array<U32> & U32},
  point: {(owner,U32.add(value,1)) == Array.get(U32,owner,0) : Array<U32> & U32},
  safe: {True{} == Bool.not(Nat.is_ge(U32.to_nat(value),U32.to_nat(4294967295))) : Bool})
  -> {O.cell(R.Cell{id,owner,tag}) == M.bump_one(True{},O.cell(R.Cell{id,source,tag})) : T.Row}:
  %point : {T.Row{U32.to_nat(id),O.payload(_),tag} == T.Row{U32.to_nat(id),1n+O.payload(Array.get(U32,source,0)),tag} : T.Row}
  %read : {T.Row{U32.to_nat(id),U32.to_nat(U32.add(value,1)),tag} == T.Row{U32.to_nat(id),1n+O.payload(_),tag} : T.Row}
  %W.bump_increment(value,safe) : {T.Row{U32.to_nat(id),U32.to_nat(U32.add(value,1)),tag} == T.Row{U32.to_nat(id),_,tag} : T.Row}
  {==}

def cell_written(+id: U32, +tag: Bool, -source: Array<U32>, -read_owner: Array<U32>, +value: U32,
  +read: {(read_owner,value) == Array.get(U32,source,0) : Array<U32> & U32},
  safe: {True{} == Bool.not(Nat.is_ge(U32.to_nat(value),U32.to_nat(4294967295))) : Bool},
  frame: P.SetFrame<read_owner,0,U32.add(value,1)>)
  -> F.CellResult<R.bump_cell(True{},R.Cell{id,source,tag}),M.bump_one(True{},O.cell(R.Cell{id,source,tag}))>:
  match frame:
    case P.SetFrame{owner,exact,point}:
      er = cell_exact(id,tag,source,read_owner,value,owner,read,exact)
      eo = cell_observed(id,tag,source,read_owner,value,owner,read,point,safe)
      F.CellResult{R.Cell{id,owner,tag},er,eo}

def cell_read(+id: U32, +tag: Bool, -source: Array<U32>,
  safe: {True{} == Bool.not(Nat.is_ge(O.payload(Array.get(U32,source,0)),U32.to_nat(4294967295))) : Bool}, frame: A.ReadFrame<source,0>)
  -> F.CellResult<R.bump_cell(True{},R.Cell{id,source,tag}),M.bump_one(True{},O.cell(R.Cell{id,source,tag}))>:
  match frame:
    case A.ReadFrame{owner,+value,+exact,_}:
      safe_value = scalar_safe(source,owner,value,exact,safe)
      cell_written(id,tag,source,owner,value,exact,safe_value,P.set(owner,0,U32.add(value,1)))

def cell_true(+id: U32, array: Array<U32>, +tag: Bool,
  safe: {True{} == Bool.not(Nat.is_ge(O.payload(Array.get(U32,array,0)),U32.to_nat(4294967295))) : Bool})
  -> F.CellResult<R.bump_cell(True{},R.Cell{id,array,tag}),M.bump_one(True{},O.cell(R.Cell{id,array,tag}))>:
  cell_read(id,tag,array,safe,A.read(array,0))
