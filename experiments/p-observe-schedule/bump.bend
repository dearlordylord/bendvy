import Base
import ../t11-replacement/types.bend as T
import ../t11-replacement/model.bend as M
import ../t11-replacement/spec.bend as S
import ../p-observe-queries/invariants.bend as Q
import ../p-observe-lookup/PROOF.bend as Lookup

# Value-only mutation leaves the physical head key available to the lookup.
def bump_head(+change: Bool, +id: Nat, +value: Nat, +tag: Bool, +tail: List<&2,T.Row>, +slot: Nat)
  -> {S.at(M.bump_one(change,T.Row{id,value,tag}) <> tail,slot)
    == S.pick(Nat.cmp(id,slot),M.bump_one(change,T.Row{id,value,tag}),_ => S.at(tail,slot)) : Maybe<&2,T.Row>}:
  match change:
    case False{}: {==}
    case True{}: {==}

def bump_decision(+order: Cmp, +row: T.Row)
  -> {Some{M.bump_one(Cmp.is_eq(order),row)} == S.immediate(order,Some{row}) : Maybe<&2,T.Row>}:
  match order row:
    case EQ{} T.Row{id,value,tag}: {==}
    case LT{} T.Row{id,value,tag}: {==}
    case GT{} T.Row{id,value,tag}: {==}

def bump_node(+order: Cmp, +id: Nat, +value: Nat, +tag: Bool, +target: Nat, +slot: Nat,
  +tail: Maybe<&2,T.Row>, e: {order == Nat.cmp(id,slot) : Cmp})
  -> {S.pick(order,M.bump_one(Nat.is_eq(target,id),T.Row{id,value,tag}),_ => S.immediate(Nat.cmp(slot,target),tail))
    == S.immediate(Nat.cmp(slot,target),S.pick(order,T.Row{id,value,tag},_ => tail)) : Maybe<&2,T.Row>}:
  match order:
    case LT{}: {==}
    case GT{}: {==}
    case EQ{}:
      same = Q.eq_reflect(id,slot,Equal.cong(Cmp,Bool,o => Cmp.is_eq(o),EQ{},Nat.cmp(id,slot),e))
      %same : {Some{M.bump_one(Nat.is_eq(target,id),T.Row{id,value,tag})}
        == S.immediate(Nat.cmp(_,target),Some{T.Row{id,value,tag}}) : Maybe<&2,T.Row>}
      %Lookup.comparison_sym(id,target) :
        {Some{M.bump_one(_,T.Row{id,value,tag})} == S.immediate(Nat.cmp(id,target),Some{T.Row{id,value,tag}}) : Maybe<&2,T.Row>}
      bump_decision(Nat.cmp(id,target),T.Row{id,value,tag})

def bump_missing(order: Cmp) -> {None{} == S.immediate(order,None{}) : Maybe<&2,T.Row>}:
  match order:
    case EQ{}: {==}
    case LT{}: {==}
    case GT{}: {==}

# One observed slot, arbitrary raw rows (even duplicates); no world invariant.
def bump_point(+rows: List<&2,T.Row>, +target: Nat, +slot: Nat)
  -> {S.at(M.bump_rows(target,rows),slot)
    == S.immediate(Nat.cmp(slot,target),S.at(rows,slot)) : Maybe<&2,T.Row>}:
  match rows:
    case Nil{}: bump_missing(Nat.cmp(slot,target))
    case Con{T.Row{+id,+value,+tag},+tail}:
      %Equal.sym(Maybe<&2,T.Row>,
        S.at(M.bump_one(Nat.is_eq(target,id),T.Row{id,value,tag}) <> M.bump_rows(target,tail),slot),
        S.pick(Nat.cmp(id,slot),M.bump_one(Nat.is_eq(target,id),T.Row{id,value,tag}),_ => S.at(M.bump_rows(target,tail),slot)),
        bump_head(Nat.is_eq(target,id),id,value,tag,M.bump_rows(target,tail),slot)) :
        {_ == S.immediate(Nat.cmp(slot,target),S.at(T.Row{id,value,tag} <> tail,slot)) : Maybe<&2,T.Row>}
      %Equal.sym(Maybe<&2,T.Row>,S.at(M.bump_rows(target,tail),slot),S.immediate(Nat.cmp(slot,target),S.at(tail,slot)),bump_point(tail,target,slot)) :
        {S.pick(Nat.cmp(id,slot),M.bump_one(Nat.is_eq(target,id),T.Row{id,value,tag}),_ => _)
          == S.immediate(Nat.cmp(slot,target),S.pick(Nat.cmp(id,slot),T.Row{id,value,tag},_ => S.at(tail,slot))) : Maybe<&2,T.Row>}
      bump_node(Nat.cmp(id,slot),id,value,tag,target,slot,S.at(tail,slot),{==})

# Commute the immediate value update through one logical enumeration emission.
def bump_emit_decision(+order: Cmp, +id: Nat, +value: Nat, +tag: Bool, +tail: List<&2,T.Row>)
  -> {M.bump_one(Cmp.is_eq(order),T.Row{id,value,tag}) <> tail
    == S.query_at(T.Any{},S.immediate(order,Some{T.Row{id,value,tag}}),tail) : List<&2,T.Row>}:
  match order:
    case EQ{}: {==}
    case LT{}: {==}
    case GT{}: {==}

def bump_emit(+found: Maybe<&2,T.Row>, +slot: Nat, +target: Nat, +tail: List<&2,T.Row>, key: Q.AtKey(found,slot))
  -> {M.bump_rows(target,S.query_at(T.Any{},found,tail))
    == S.query_at(T.Any{},S.immediate(Nat.cmp(slot,target),found),M.bump_rows(target,tail)) : List<&2,T.Row>}:
  match found:
    case None{}:
      %bump_missing(Nat.cmp(slot,target)) : {M.bump_rows(target,tail) == S.query_at(T.Any{},_,M.bump_rows(target,tail)) : List<&2,T.Row>}
      {==}
    case Some{T.Row{+id,+value,+tag}}:
      %Q.eq_reflect(id,slot,key) :
        {M.bump_one(Nat.is_eq(target,id),T.Row{id,value,tag}) <> M.bump_rows(target,tail)
          == S.query_at(T.Any{},S.immediate(Nat.cmp(_,target),Some{T.Row{id,value,tag}}),M.bump_rows(target,tail)) : List<&2,T.Row>}
      %Lookup.comparison_sym(id,target) :
        {M.bump_one(_,T.Row{id,value,tag}) <> M.bump_rows(target,tail)
          == S.query_at(T.Any{},S.immediate(Nat.cmp(id,target),Some{T.Row{id,value,tag}}),M.bump_rows(target,tail)) : List<&2,T.Row>}
      bump_emit_decision(Nat.cmp(id,target),id,value,tag,M.bump_rows(target,tail))

# Bump materialization is a value update of the ordinary enumerated rows.
# This is the contextual bridge to the query lane's enumeration lookup theorem.
def bump_enumeration(+fuel: Nat, +slot: Nat, +target: Nat, +rows: List<&2,T.Row>)
  -> {M.bump_rows(target,S.enumerate_rows(fuel,slot,rows,T.Any{})) == S.bumped(fuel,slot,target,rows) : List<&2,T.Row>}:
  match fuel:
    case 0n: {==}
    case 1n+rest:
      Equal.trans(List<&2,T.Row>,
        M.bump_rows(target,S.query_at(T.Any{},S.at(rows,slot),S.enumerate_rows(rest,1n+slot,rows,T.Any{}))),
        S.query_at(T.Any{},S.immediate(Nat.cmp(slot,target),S.at(rows,slot)),M.bump_rows(target,S.enumerate_rows(rest,1n+slot,rows,T.Any{}))),
        S.query_at(T.Any{},S.immediate(Nat.cmp(slot,target),S.at(rows,slot)),S.bumped(rest,1n+slot,target,rows)),
        bump_emit(S.at(rows,slot),slot,target,S.enumerate_rows(rest,1n+slot,rows,T.Any{}),Q.at_key(rows,slot)),
        Equal.cong(List<&2,T.Row>,List<&2,T.Row>,tail => S.query_at(T.Any{},S.immediate(Nat.cmp(slot,target),S.at(rows,slot)),tail),
          M.bump_rows(target,S.enumerate_rows(rest,1n+slot,rows,T.Any{})),S.bumped(rest,1n+slot,target,rows),bump_enumeration(rest,1n+slot,target,rows)))
