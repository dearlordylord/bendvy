import Base
import ../p-approved-owned-safety/member-safety.bend as G
import ../p-approved-owned-word-context/helpers.bend as W
import ../t11-replacement/types.bend as T
import ../t11-replacement/spec.bend as S


def describe_any(+id: Nat, +value: Nat, +tag: Bool) -> {S.describe(T.Any{},Some{T.Row{id,value,tag}}) == T.Found{T.Row{id,value,tag}} : T.Lookup}:
  match tag:
    case False{}: {==}
    case True{}: {==}

def describe_observed(-observe: T.Lookup -> Bool, +id: Nat, +value: Nat, +tag: Bool) -> {observe(S.describe(T.Any{},Some{T.Row{id,value,tag}})) == observe(T.Found{T.Row{id,value,tag}}) : Bool}:
  Equal.cong(T.Lookup,Bool,observe,S.describe(T.Any{},Some{T.Row{id,value,tag}}),T.Found{T.Row{id,value,tag}},describe_any(id,value,tag))


def source_fun() -> {G.row_safe(G.Overflow{}) == (row => S.no_overflow_lookup(S.describe(T.Any{},Some{row}))) : T.Row -> Bool}:
  {==}
def source_row(+row: T.Row) -> {G.row_safe(G.Overflow{},row) == S.no_overflow_lookup(S.describe(T.Any{},Some{row})) : Bool}:
  Equal.cong(T.Row -> Bool,Bool,f => f(row),G.row_safe(G.Overflow{}),(r => S.no_overflow_lookup(S.describe(T.Any{},Some{r}))),source_fun())

def overflow_found(+id: Nat,+value: Nat,+tag: Bool) -> {S.no_overflow_lookup(S.describe(T.Any{},Some{T.Row{id,value,tag}})) == S.no_overflow_lookup(T.Found{T.Row{id,value,tag}}) : Bool}:
  describe_observed(S.no_overflow_lookup,id,value,tag)

