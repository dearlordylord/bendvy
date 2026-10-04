import Base
import ./LAWS.bend as L
import ../t11-replacement/types.bend as T
import ../t11-replacement/model.bend as M
import ../t11-replacement/spec.bend as S

# Contextual equality of the two row-search comparisons; not a U32 bridge.
def comparison_sym(+a: Nat, +b: Nat) -> {Nat.is_eq(a,b) == Nat.is_eq(b,a) : Bool}:
  match a b:
    case 0n 0n: {==}
    case 0n 1n+p: {==}
    case 1n+p 0n: {==}
    case 1n+p 1n+q: comparison_sym(p,q)

def eligibility(+selection: T.Selection, +tag: Bool) -> {M.accepts(selection,tag) == S.eligible(selection,tag) : Bool}:
  match selection tag:
    case T.Any{} _: {==}
    case T.Present{} False{}: {==}
    case T.Present{} True{}: {==}
    case T.Absent{} False{}: {==}
    case T.Absent{} True{}: {==}

def selected(+ok: Bool, +row: T.Row) -> {M.choose_selected(ok,row) == S.selected_lookup(ok,row) : T.Lookup}:
  match ok:
    case False{}: {==}
    case True{}: {==}

def node(+order: Cmp, +selection: T.Selection, +row: T.Row, +left: T.Lookup, +right: Maybe<&2,T.Row>, ih: {left == S.describe(selection,right) : T.Lookup}) -> {M.choose_lookup(Cmp.is_eq(order),selection,row,left) == S.describe(selection,S.pick(order,row,_ => right)) : T.Lookup}:
  match order row:
    case EQ{} T.Row{+id,+value,+tag}:
      %eligibility(selection,tag) : {M.choose_selected(M.accepts(selection,tag),T.Row{id,value,tag}) == S.selected_lookup(_,T.Row{id,value,tag}) : T.Lookup}
      selected(M.accepts(selection,tag),T.Row{id,value,tag})
    case LT{} _: ih
    case GT{} _: ih

def rows_correspond(+rows: List<&2,T.Row>, +slot: Nat, +selection: T.Selection) -> {M.lookup_rows(slot,selection,rows) == S.describe(selection,S.at(rows,slot)) : T.Lookup}:
  match rows:
    case Nil{}: {==}
    case Con{T.Row{+id,+value,+tag},+tail}:
      %comparison_sym(id,slot) : {M.choose_lookup(_,selection,T.Row{id,value,tag},M.lookup_rows(slot,selection,tail)) == S.describe(selection,S.pick(Nat.cmp(id,slot),T.Row{id,value,tag},_ => S.at(tail,slot))) : T.Lookup}
      node(Nat.cmp(id,slot),selection,T.Row{id,value,tag},M.lookup_rows(slot,selection,tail),S.at(tail,slot),rows_correspond(tail,slot,selection))

def namespace_correspond(+order: Cmp, +rows: List<&2,T.Row>, +slot: Nat, +selection: T.Selection) -> {M.lookup_if(Cmp.is_eq(order),slot,selection,rows) == S.lookup_namespace(order,rows,slot,selection) : T.Lookup}:
  match order:
    case EQ{}: rows_correspond(rows,slot,selection)
    case LT{}: {==}
    case GT{}: {==}

def L.lookup_full_exact(world,handle,selection):
  match world handle:
    case T.World{id,_,rows,_} T.Handle{namespace,slot}:
      namespace_correspond(Nat.cmp(id,namespace),rows,slot,selection)
