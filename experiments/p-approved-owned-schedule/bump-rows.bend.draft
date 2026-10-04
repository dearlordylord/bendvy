import Base
import ./arrays.bend as A
import ./point.bend as P
import ./bump.bend as B
import ./frames.bend as F
import ../p-approved-owned-word-context/helpers.bend as W
import ../p-approved-owned-safety/member-safety.bend as G
import ../p-observe-queries/helpers.bend as H
import ../p-observe-queries/invariants.bend as Q
import ../t11-replacement/runtime.bend as R
import ../t11-replacement/owned-spec.bend as O
import ../t11-replacement/types.bend as T
import ../t11-replacement/model.bend as M
import ../t11-replacement/spec.bend as S

# The tail predicate occurs only in proposition positions; computing it would
# otherwise consume the still-needed affine tail owner.
def and_left(a: Bool, -b: Bool, h: {True{} == Bool.and(a,b) : Bool}) -> {True{} == a : Bool}:
  match a:
    case True{}: {==}
    case False{}: Empty.absurd({True{} == False{} : Bool},H.false_true_absurd(Equal.sym(Bool,True{},False{},h)))
def and_right(a: Bool, -b: Bool, h: {True{} == Bool.and(a,b) : Bool}) -> {True{} == b : Bool}:
  match a:
    case True{}: h
    case False{}: Empty.absurd({True{} == b : Bool},H.false_true_absurd(Equal.sym(Bool,True{},False{},h)))

def model_key(+order: Cmp, +id: U32, +target: U32, e: {order == Nat.cmp(U32.to_nat(id),U32.to_nat(target)) : Cmp})
  -> {Cmp.is_eq(order) == Nat.is_eq(U32.to_nat(target),U32.to_nat(id)) : Bool}:
  Equal.trans(Bool,Cmp.is_eq(order),Nat.is_eq(U32.to_nat(id),U32.to_nat(target)),Nat.is_eq(U32.to_nat(target),U32.to_nat(id)),
    Equal.cong(Cmp,Bool,c => Cmp.is_eq(c),order,Nat.cmp(U32.to_nat(id),U32.to_nat(target)),e),Q.eq_symmetric(U32.to_nat(id),U32.to_nat(target)))

def runtime_key(+order: Cmp, +id: U32, +target: U32, e: {order == Nat.cmp(U32.to_nat(id),U32.to_nat(target)) : Cmp})
  -> {Cmp.is_eq(order) == U32.is_eq(target,id) : Bool}:
  Equal.trans(Bool,Cmp.is_eq(order),Nat.is_eq(U32.to_nat(target),U32.to_nat(id)),U32.is_eq(target,id),model_key(order,id,target,e),
    Equal.sym(Bool,U32.is_eq(target,id),Nat.is_eq(U32.to_nat(target),U32.to_nat(id)),W.equality(target,id)))

def join_exact(+order: Cmp, +id: U32, +target: U32, -array: Array<U32>, +tag: Bool, -tail: List<R.Cell>,
  -head: R.Cell, -rest: List<R.Cell>, e: {order == Nat.cmp(U32.to_nat(id),U32.to_nat(target)) : Cmp},
  first: {head == R.bump_cell(Cmp.is_eq(order),R.Cell{id,array,tag}) : R.Cell},
  last: {rest == R.bump_rows(target,tail) : List<R.Cell>})
  -> {head <> rest == R.bump_rows(target,R.Cell{id,array,tag} <> tail) : List<R.Cell>}:
  %runtime_key(order,id,target,e) : {head <> rest == R.bump_cell(_,R.Cell{id,array,tag}) <> R.bump_rows(target,tail) : List<R.Cell>}
  %first : {head <> rest == _ <> R.bump_rows(target,tail) : List<R.Cell>}
  %last : {head <> rest == head <> _ : List<R.Cell>}
  {==}

def join_observed(+order: Cmp, +id: U32, +target: U32, -array: Array<U32>, +tag: Bool, -tail: List<R.Cell>,
  -head: R.Cell, -rest: List<R.Cell>, e: {order == Nat.cmp(U32.to_nat(id),U32.to_nat(target)) : Cmp},
  first: {O.cell(head) == M.bump_one(Cmp.is_eq(order),O.cell(R.Cell{id,array,tag})) : T.Row},
  last: {O.rows(rest) == M.bump_rows(U32.to_nat(target),O.rows(tail)) : List<&2,T.Row>})
  -> {O.rows(head <> rest) == M.bump_rows(U32.to_nat(target),O.rows(R.Cell{id,array,tag} <> tail)) : List<&2,T.Row>}:
  %model_key(order,id,target,e) : {O.cell(head) <> O.rows(rest) == M.bump_one(_,O.cell(R.Cell{id,array,tag})) <> M.bump_rows(U32.to_nat(target),O.rows(tail)) : List<&2,T.Row>}
  %first : {O.cell(head) <> O.rows(rest) == _ <> M.bump_rows(U32.to_nat(target),O.rows(tail)) : List<&2,T.Row>}
  %last : {O.cell(head) <> O.rows(rest) == O.cell(head) <> _ : List<&2,T.Row>}
  {==}

def join(+order: Cmp, +id: U32, +target: U32, -array: Array<U32>, +tag: Bool, -tail: List<R.Cell>,
  +e: {order == Nat.cmp(U32.to_nat(id),U32.to_nat(target)) : Cmp},
  first: F.CellResult<R.bump_cell(Cmp.is_eq(order),R.Cell{id,array,tag}),M.bump_one(Cmp.is_eq(order),O.cell(R.Cell{id,array,tag}))>,
  last: F.RowsResult<R.bump_rows(target,tail),M.bump_rows(U32.to_nat(target),O.rows(tail))>)
  -> F.RowsResult<R.bump_rows(target,R.Cell{id,array,tag} <> tail),M.bump_rows(U32.to_nat(target),O.rows(R.Cell{id,array,tag} <> tail))>:
  match first last:
    case F.CellResult{head,exact,observed} F.RowsResult{rest,exacts,observations}:
      er = join_exact(order,id,target,array,tag,tail,head,rest,e,exact,exacts)
      eo = join_observed(order,id,target,array,tag,tail,head,rest,e,observed,observations)
      F.RowsResult{head <> rest,er,eo}

def safe_read(+bound: G.Bound, +id: U32, +target: U32, +tag: Bool, -array: Array<U32>, -tail: List<R.Cell>, -read_owner: Array<U32>, +value: U32,
  read: {(read_owner,value) == Array.get(U32,array,0) : Array<U32> & U32},
  safe: {True{} == G.guard(bound,EQ{},O.cell(R.Cell{id,array,tag}),G.BumpSafe(bound,O.rows(tail),U32.to_nat(target))) : Bool})
  -> {True{} == Bool.and(G.row_safe(bound,T.Row{U32.to_nat(id),U32.to_nat(value),tag}),G.BumpSafe(bound,O.rows(tail),U32.to_nat(target))) : Bool}:
  %Equal.sym(Nat,U32.to_nat(value),O.payload(Array.get(U32,array,0)),B.source_value(array,read_owner,value,read)) :
    {True{} == Bool.and(G.row_safe(bound,T.Row{U32.to_nat(id),_,tag}),G.BumpSafe(bound,O.rows(tail),U32.to_nat(target))) : Bool}
  safe

def describe_any(+id: Nat, +value: Nat, +tag: Bool)
  -> {S.describe(T.Any{},Some{T.Row{id,value,tag}}) == T.Found{T.Row{id,value,tag}} : T.Lookup}:
  match tag:
    case False{}: {==}
    case True{}: {==}

def overflow_row(+id: Nat, +value: Nat, +tag: Bool)
  -> {G.row_safe(G.Overflow{},T.Row{id,value,tag}) == S.no_overflow_lookup(T.Found{T.Row{id,value,tag}}) : Bool}:
  %describe_any(id,value,tag) : {G.row_safe(G.Overflow{},T.Row{id,value,tag}) == S.no_overflow_lookup(_) : Bool}
  {==}

def row_guard(+id: U32, +value: U32, +tag: Bool)
  -> {G.row_safe(G.Overflow{},T.Row{U32.to_nat(id),U32.to_nat(value),tag}) == U32.is_lt(value,4294967295) : Bool}:
  Equal.trans(Bool,G.row_safe(G.Overflow{},T.Row{U32.to_nat(id),U32.to_nat(value),tag}),S.no_overflow_lookup(T.Found{T.Row{U32.to_nat(id),U32.to_nat(value),tag}}),U32.is_lt(value,4294967295),overflow_row(U32.to_nat(id),U32.to_nat(value),tag),W.bump_guard_agrees(value))

def and_transport(-a: Bool, -b: Bool, -tail: Bool, e: {a == b : Bool}, h: {True{} == Bool.and(a,tail) : Bool})
  -> {True{} == Bool.and(b,tail) : Bool}:
  %e : {True{} == Bool.and(_,tail) : Bool}
  h

def scalar_from_word(+value: U32, h: {True{} == U32.is_lt(value,4294967295) : Bool})
  -> {True{} == Bool.not(Nat.is_ge(U32.to_nat(value),U32.to_nat(4294967295))) : Bool}:
  %Equal.sym(Bool,Bool.not(Nat.is_ge(U32.to_nat(value),U32.to_nat(4294967295))),U32.is_lt(value,4294967295),W.bump_guard_agrees(value)) : {True{} == _ : Bool}
  h

def equal_read(+id: U32, +target: U32, +tag: Bool, -array: Array<U32>, -tail: List<R.Cell>,
  e: {EQ{} == Nat.cmp(U32.to_nat(id),U32.to_nat(target)) : Cmp},
  safe: {True{} == G.guard(G.Overflow{},EQ{},O.cell(R.Cell{id,array,tag}),G.BumpSafe(G.Overflow{},O.rows(tail),U32.to_nat(target))) : Bool},
  frame: A.ReadFrame<array,0>,
  ih: {True{} == G.BumpSafe(G.Overflow{},O.rows(tail),U32.to_nat(target)) : Bool}
    -> F.RowsResult<R.bump_rows(target,tail),M.bump_rows(U32.to_nat(target),O.rows(tail))>)
  -> F.RowsResult<R.bump_rows(target,R.Cell{id,array,tag} <> tail),M.bump_rows(U32.to_nat(target),O.rows(R.Cell{id,array,tag} <> tail))>:
  match frame:
    case A.ReadFrame{owner,+value,+read,_}:
      +both = safe_read(G.Overflow{},id,target,tag,array,tail,owner,value,read,safe)
      +words = and_transport(G.row_safe(G.Overflow{},T.Row{U32.to_nat(id),U32.to_nat(value),tag}),U32.is_lt(value,4294967295),G.BumpSafe(G.Overflow{},O.rows(tail),U32.to_nat(target)),row_guard(id,value,tag),both)
      first = scalar_from_word(value,and_left(U32.is_lt(value,4294967295),G.BumpSafe(G.Overflow{},O.rows(tail),U32.to_nat(target)),words))
      rest = and_right(U32.is_lt(value,4294967295),G.BumpSafe(G.Overflow{},O.rows(tail),U32.to_nat(target)),words)
      join(EQ{},id,target,array,tag,tail,e,B.cell_written(id,tag,array,owner,value,read,first,P.set(owner,0,U32.add(value,1))),ih(rest))

def rows_case(order: Cmp, +id: U32, +target: U32, array: Array<U32>, +tag: Bool, -tail: List<R.Cell>,
  e: {order == Nat.cmp(U32.to_nat(id),U32.to_nat(target)) : Cmp},
  safe: {True{} == G.guard(G.Overflow{},order,O.cell(R.Cell{id,array,tag}),G.BumpSafe(G.Overflow{},O.rows(tail),U32.to_nat(target))) : Bool},
  ih: {True{} == G.BumpSafe(G.Overflow{},O.rows(tail),U32.to_nat(target)) : Bool}
    -> F.RowsResult<R.bump_rows(target,tail),M.bump_rows(U32.to_nat(target),O.rows(tail))>)
  -> F.RowsResult<R.bump_rows(target,R.Cell{id,array,tag} <> tail),M.bump_rows(U32.to_nat(target),O.rows(R.Cell{id,array,tag} <> tail))>:
  match order:
    case EQ{}: equal_read(id,target,tag,array,tail,e,safe,A.read(array,0),ih)
    case LT{}: join(LT{},id,target,array,tag,tail,e,F.CellResult{R.Cell{id,array,tag},{==},{==}},ih(safe))
    case GT{}: join(GT{},id,target,array,tag,tail,e,F.CellResult{R.Cell{id,array,tag},{==},{==}},ih(safe))

def rows(+target: U32, cells: List<R.Cell>, safe: {True{} == G.BumpSafe(G.Overflow{},O.rows(cells),U32.to_nat(target)) : Bool})
  -> F.RowsResult<R.bump_rows(target,cells),M.bump_rows(U32.to_nat(target),O.rows(cells))>:
  match cells:
    case Nil{}: F.RowsResult{[],{==},{==}}
    case Con{R.Cell{+id,array,+tag},tail}:
      rows_case(Nat.cmp(U32.to_nat(id),U32.to_nat(target)),id,target,array,tag,tail,{==},safe,h => rows(target,tail,h))
