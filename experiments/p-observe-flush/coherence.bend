import Base
import ../t11-replacement/types.bend as T
import ../t11-replacement/model.bend as M
import ../t11-replacement/spec.bend as S
import ../p-observe-lookup/PROOF.bend as Lookup
import ./toolkit.bend as P

def true_family(value: Bool) -> Type:
  match value:
    case True{}: Unit
    case False{}: Empty

def false_true(e: {False{} == True{} : Bool}) -> Empty:
  %Equal.sym(Bool,False{},True{},e) : true_family(_)
  Unit{}

def equality_reflect(+a: Nat, +b: Nat, e: {Nat.is_eq(a,b) == True{} : Bool}) -> {a == b : Nat}:
  match a b:
    case 0n 0n: {==}
    case 0n 1n+p: Empty.absurd({0n == 1n+p : Nat},false_true(e))
    case 1n+p 0n: Empty.absurd({1n+p == 0n : Nat},false_true(e))
    case 1n+p 1n+q:
      %equality_reflect(p,q,e) : {1n+p == 1n+_ : Nat}
      {==}

def true_false(e: {True{} == False{} : Bool}) -> Empty:
  false_true(Equal.sym(Bool,True{},False{},e))

def pick_congruence(+order: Cmp, +row: T.Row, +left: Maybe<&2,T.Row>, +right: Maybe<&2,T.Row>, ih: {left == right : Maybe<&2,T.Row>}) -> {S.pick(order,row,_ => left) == S.pick(order,row,_ => right) : Maybe<&2,T.Row>}:
  match order:
    case EQ{}: {==}
    case LT{}: ih
    case GT{}: ih

def mismatch_pick(+order: Cmp, +row: T.Row, +current: Maybe<&2,T.Row>, e: {Cmp.is_eq(order) == False{} : Bool}) -> {S.pick(order,row,_ => current) == current : Maybe<&2,T.Row>}:
  match order:
    case EQ{}:
      Empty.absurd({Some{row} == current : Maybe<&2,T.Row>},true_false(e))
    case LT{}: {==}
    case GT{}: {==}

def matched_other_head(+order: Cmp, +action: T.Action, +id: Nat, +value: Nat, +tag: Bool, +slot: Nat, +after: List<&2,T.Row>, h: {Nat.cmp(id,slot) == order : Cmp}, e: {Cmp.is_eq(order) == False{} : Bool}) -> {S.at(M.modify_one(True{},action,T.Row{id,value,tag},after),slot) == S.at(after,slot) : Maybe<&2,T.Row>}:
  match order action:
    case EQ{} a:
      Empty.absurd({S.at(M.modify_one(True{},a,T.Row{id,value,tag},after),slot) == S.at(after,slot) : Maybe<&2,T.Row>},true_false(e))
    case LT{} T.Insert{}:
      %Equal.sym(Cmp,Nat.cmp(id,slot),LT{},h) : {S.pick(_,T.Row{id,value,True{}},_ => S.at(after,slot)) == S.at(after,slot) : Maybe<&2,T.Row>}
      {==}
    case GT{} T.Insert{}:
      %Equal.sym(Cmp,Nat.cmp(id,slot),GT{},h) : {S.pick(_,T.Row{id,value,True{}},_ => S.at(after,slot)) == S.at(after,slot) : Maybe<&2,T.Row>}
      {==}
    case LT{} T.Remove{}:
      %Equal.sym(Cmp,Nat.cmp(id,slot),LT{},h) : {S.pick(_,T.Row{id,value,False{}},_ => S.at(after,slot)) == S.at(after,slot) : Maybe<&2,T.Row>}
      {==}
    case GT{} T.Remove{}:
      %Equal.sym(Cmp,Nat.cmp(id,slot),GT{},h) : {S.pick(_,T.Row{id,value,False{}},_ => S.at(after,slot)) == S.at(after,slot) : Maybe<&2,T.Row>}
      {==}
    case LT{} T.Despawn{}: {==}
    case GT{} T.Despawn{}: {==}

def other_row_nonmatch(+target: Nat, +id: Nat, +slot: Nat, equal: {Nat.is_eq(target,id) == True{} : Bool}, neq: {Nat.is_eq(target,slot) == False{} : Bool}) -> {Nat.is_eq(id,slot) == False{} : Bool}:
  %equality_reflect(target,id,equal) : {Nat.is_eq(_,slot) == False{} : Bool}
  neq

def other_slot_node(+hit: Bool, +target: Nat, +slot: Nat, +action: T.Action, +id: Nat, +value: Nat, +tag: Bool, +after: List<&2,T.Row>, +before: List<&2,T.Row>, hit_e: {Nat.is_eq(target,id) == hit : Bool}, neq: {Nat.is_eq(target,slot) == False{} : Bool}, ih: {S.at(after,slot) == S.at(before,slot) : Maybe<&2,T.Row>}) -> {S.at(M.modify_one(hit,action,T.Row{id,value,tag},after),slot) == S.pick(Nat.cmp(id,slot),T.Row{id,value,tag},_ => S.at(before,slot)) : Maybe<&2,T.Row>}:
  match hit:
    case False{}:
      pick_congruence(Nat.cmp(id,slot),T.Row{id,value,tag},S.at(after,slot),S.at(before,slot),ih)
    case True{}:
      +e = other_row_nonmatch(target,id,slot,hit_e,neq)
      Equal.trans(Maybe<&2,T.Row>,S.at(M.modify_one(True{},action,T.Row{id,value,tag},after),slot),S.at(after,slot),S.pick(Nat.cmp(id,slot),T.Row{id,value,tag},_ => S.at(before,slot)),matched_other_head(Nat.cmp(id,slot),action,id,value,tag,slot,after,{==},e),Equal.trans(Maybe<&2,T.Row>,S.at(after,slot),S.at(before,slot),S.pick(Nat.cmp(id,slot),T.Row{id,value,tag},_ => S.at(before,slot)),ih,Equal.sym(Maybe<&2,T.Row>,S.pick(Nat.cmp(id,slot),T.Row{id,value,tag},_ => S.at(before,slot)),S.at(before,slot),mismatch_pick(Nat.cmp(id,slot),T.Row{id,value,tag},S.at(before,slot),e))))

def target_other_slot(+rows: List<&2,T.Row>, +target: Nat, +slot: Nat, +action: T.Action, +neq: {Nat.is_eq(target,slot) == False{} : Bool}) -> {S.at(M.modify(target,action,rows),slot) == S.at(rows,slot) : Maybe<&2,T.Row>}:
  match rows:
    case Nil{}: {==}
    case Con{T.Row{+id,+value,+tag},+tail}:
      other_slot_node(Nat.is_eq(target,id),target,slot,action,id,value,tag,M.modify(target,action,tail),tail,{==},neq,target_other_slot(tail,target,slot,action,neq))

def target_slot_case(+order: Cmp, +target: Nat, +slot: Nat, +action: T.Action, +rows: List<&2,T.Row>, h: {Nat.cmp(target,slot) == order : Cmp}) -> {S.at(M.modify(target,action,rows),slot) == S.command_at(order,T.Target{target,action},S.at(rows,slot)) : Maybe<&2,T.Row>}:
  match order:
    case EQ{}:
      %Equal.sym(Nat,target,slot,equality_reflect(target,slot,Equal.cong(Cmp,Bool,Cmp.is_eq,Nat.cmp(target,slot),EQ{},h))) : {S.at(M.modify(_,action,rows),slot) == S.target_effect(action,S.at(rows,slot)) : Maybe<&2,T.Row>}
      P.target_own_slot(rows,slot,action)
    case LT{}:
      target_other_slot(rows,target,slot,action,Equal.cong(Cmp,Bool,Cmp.is_eq,Nat.cmp(target,slot),LT{},h))
    case GT{}:
      target_other_slot(rows,target,slot,action,Equal.cong(Cmp,Bool,Cmp.is_eq,Nat.cmp(target,slot),GT{},h))

def command_slot(+command: T.Command, +rows: List<&2,T.Row>, +slot: Nat) -> {S.at(M.apply(command,rows),slot) == S.one(command,slot,S.at(rows,slot)) : Maybe<&2,T.Row>}:
  match command:
    case T.Spawn{+id,+value}: P.spawn_slot(id,value,slot,rows)
    case T.Target{+target,+action}: target_slot_case(Nat.cmp(target,slot),target,slot,action,rows,{==})

def mixed_fifo_slot(+commands: List<&2,T.Command>, +rows: List<&2,T.Row>, +slot: Nat) -> {S.at(M.apply_all(commands,rows),slot) == S.replay(commands,slot,S.at(rows,slot)) : Maybe<&2,T.Row>}:
  match commands:
    case Nil{}: {==}
    case Con{+command,+tail}:
      %command_slot(command,rows,slot) : {S.at(M.apply_all(tail,M.apply(command,rows)),slot) == S.replay(tail,slot,_) : Maybe<&2,T.Row>}
      mixed_fifo_slot(tail,M.apply(command,rows),slot)
