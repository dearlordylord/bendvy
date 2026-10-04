import Base
import ../t11-replacement/types.bend as T
import ../t11-replacement/model.bend as M
import ../t11-replacement/spec.bend as S
import ../p-observe-lookup/PROOF.bend as Lookup

# Whole-list command application is a left-to-right fold for every raw input.
def application_prefix(+prefix: List<&2,T.Command>, +suffix: List<&2,T.Command>, +rows: List<&2,T.Row>) -> {M.apply_all(List.append(&2,T.Command,prefix,suffix),rows) == M.apply_all(suffix,M.apply_all(prefix,rows)) : List<&2,T.Row>}:
  match prefix:
    case Nil{}: {==}
    case Con{+command,+tail}: application_prefix(tail,suffix,M.apply(command,rows))

# Independent per-slot replay has the identical logical prefix sequencing.
def replay_prefix(+prefix: List<&2,T.Command>, +suffix: List<&2,T.Command>, +slot: Nat, +current: Maybe<&2,T.Row>) -> {S.replay(List.append(&2,T.Command,prefix,suffix),slot,current) == S.replay(suffix,slot,S.replay(prefix,slot,current)) : Maybe<&2,T.Row>}:
  match prefix:
    case Nil{}: {==}
    case Con{+command,+tail}: replay_prefix(tail,suffix,slot,S.one(command,slot,current))

def spawn_case(+order: Cmp, +id: Nat, +value: Nat, +current: Maybe<&2,T.Row>) -> {S.pick(order,T.Row{id,value,False{}},_ => current) == S.command_at(order,T.Spawn{id,value},current) : Maybe<&2,T.Row>}:
  match order:
    case EQ{}: {==}
    case LT{}: {==}
    case GT{}: {==}

def spawn_slot(+id: Nat, +value: Nat, +slot: Nat, +rows: List<&2,T.Row>) -> {S.at(M.apply(T.Spawn{id,value},rows),slot) == S.one(T.Spawn{id,value},slot,S.at(rows,slot)) : Maybe<&2,T.Row>}:
  spawn_case(Nat.cmp(id,slot),id,value,S.at(rows,slot))

def comparison_self(+n: Nat) -> {Nat.cmp(n,n) == EQ{} : Cmp}:
  match n:
    case 0n: {==}
    case 1n+p: comparison_self(p)

def despawn_effect(+current: Maybe<&2,T.Row>) -> {S.target_effect(T.Despawn{},current) == None{} : Maybe<&2,T.Row>}:
  match current:
    case None{}: {==}
    case Some{row}: {==}

def target_node(+order: Cmp, +action: T.Action, +id: Nat, +value: Nat, +tag: Bool, +slot: Nat, +after: List<&2,T.Row>, +before: List<&2,T.Row>, equality: {Nat.cmp(id,slot) == order : Cmp}, ih: {S.at(after,slot) == S.target_effect(action,S.at(before,slot)) : Maybe<&2,T.Row>}) -> {S.at(M.modify_one(Cmp.is_eq(order),action,T.Row{id,value,tag},after),slot) == S.target_effect(action,S.pick(order,T.Row{id,value,tag},_ => S.at(before,slot))) : Maybe<&2,T.Row>}:
  match order action:
    case EQ{} T.Insert{}:
      %Equal.sym(Cmp,Nat.cmp(id,slot),order,equality) : {S.pick(_,T.Row{id,value,True{}},_ => S.at(after,slot)) == Some{T.Row{id,value,True{}}} : Maybe<&2,T.Row>}
      {==}
    case EQ{} T.Remove{}:
      %Equal.sym(Cmp,Nat.cmp(id,slot),order,equality) : {S.pick(_,T.Row{id,value,False{}},_ => S.at(after,slot)) == Some{T.Row{id,value,False{}}} : Maybe<&2,T.Row>}
      {==}
    case EQ{} T.Despawn{}:
      Equal.trans(Maybe<&2,T.Row>,S.at(after,slot),S.target_effect(T.Despawn{},S.at(before,slot)),None{},ih,despawn_effect(S.at(before,slot)))
    case LT{} a:
      %Equal.sym(Cmp,Nat.cmp(id,slot),order,equality) : {S.pick(_,T.Row{id,value,tag},_ => S.at(after,slot)) == S.target_effect(a,S.at(before,slot)) : Maybe<&2,T.Row>}
      ih
    case GT{} a:
      %Equal.sym(Cmp,Nat.cmp(id,slot),order,equality) : {S.pick(_,T.Row{id,value,tag},_ => S.at(after,slot)) == S.target_effect(a,S.at(before,slot)) : Maybe<&2,T.Row>}
      ih


def missing_target(+action: T.Action) -> {S.target_effect(action,None{}) == None{} : Maybe<&2,T.Row>}:
  match action:
    case T.Insert{}: {==}
    case T.Remove{}: {==}
    case T.Despawn{}: {==}

# Whole-list update at the command's own slot; duplicate input rows allowed.
def target_own_slot(+rows: List<&2,T.Row>, +slot: Nat, +action: T.Action) -> {S.at(M.modify(slot,action,rows),slot) == S.target_effect(action,S.at(rows,slot)) : Maybe<&2,T.Row>}:
  match rows:
    case Nil{}:
      Equal.sym(Maybe<&2,T.Row>,S.target_effect(action,None{}),None{},missing_target(action))
    case Con{T.Row{+id,+value,+tag},+tail}:
      %Lookup.comparison_sym(id,slot) : {S.at(M.modify_one(_,action,T.Row{id,value,tag},M.modify(slot,action,tail)),slot) == S.target_effect(action,S.pick(Nat.cmp(id,slot),T.Row{id,value,tag},_ => S.at(tail,slot))) : Maybe<&2,T.Row>}
      target_node(Nat.cmp(id,slot),action,id,value,tag,slot,M.modify(slot,action,tail),tail,{==},target_own_slot(tail,slot,action))

# A concrete logical sublanguage used to exercise genuine FIFO induction.
def same_slot_commands(actions: List<&2,T.Action>, +slot: Nat) -> List<&2,T.Command>:
  match actions:
    case Nil{}: []
    case Con{action,tail}: T.Target{slot,action} <> same_slot_commands(tail,slot)

def target_fifo(+actions: List<&2,T.Action>, +slot: Nat, +rows: List<&2,T.Row>) -> {S.at(M.apply_all(same_slot_commands(actions,slot),rows),slot) == S.replay(same_slot_commands(actions,slot),slot,S.at(rows,slot)) : Maybe<&2,T.Row>}:
  match actions:
    case Nil{}: {==}
    case Con{+action,+tail}:
      %Equal.sym(Cmp,Nat.cmp(slot,slot),EQ{},comparison_self(slot)) : {S.at(M.apply_all(same_slot_commands(tail,slot),M.modify(slot,action,rows)),slot) == S.replay(same_slot_commands(tail,slot),slot,S.command_at(_,T.Target{slot,action},S.at(rows,slot))) : Maybe<&2,T.Row>}
      %target_own_slot(rows,slot,action) : {S.at(M.apply_all(same_slot_commands(tail,slot),M.modify(slot,action,rows)),slot) == S.replay(same_slot_commands(tail,slot),slot,_) : Maybe<&2,T.Row>}
      target_fifo(tail,slot,M.modify(slot,action,rows))
