import Base
import ./language.bend as P
import ../t11-replacement/runtime.bend as R
import ../t11-replacement/owned-spec.bend as O
import ../t11-replacement/types.bend as T
import ../t11-replacement/model.bend as M
import ../t11-replacement/spec.bend as S

# Narrow contextual command projection, needed only for this empty-row family.
def commands(+pending: List<&2,R.Command>) -> {R.commands_project(pending) == O.commands(pending) : List<&2,T.Command>}:
  match pending:
    case Nil{}: {==}
    case Con{R.Spawn{slot,value},+tail}:
      %commands(tail) : {T.Spawn{U32.to_nat(slot),U32.to_nat(value)} <> R.commands_project(tail) == T.Spawn{U32.to_nat(slot),U32.to_nat(value)} <> _ : List<&2,T.Command>}
      {==}
    case Con{R.Target{slot,action},+tail}:
      %commands(tail) : {T.Target{U32.to_nat(slot),action} <> R.commands_project(tail) == T.Target{U32.to_nat(slot),action} <> _ : List<&2,T.Command>}
      {==}

def enumerate_empty(fuel: Nat, +start: Nat) -> {[] == S.enumerate_rows(fuel,start,[],T.Any{}) : List<&2,T.Row>}:
  match fuel:
    case 0n: {==}
    case 1n+rest: enumerate_empty(rest,1n+start)

# Exact empty-step equation for arbitrary metadata/pending but EMPTY live rows.
def equation(+limit: U32, +id: U32, +next: U32, +pending: List<&2,R.Command>)
  -> {M.observe(R.snapshot(R.project(R.tick([],limit,R.World{id,next,[],pending})))) == S.schedule_observation(U32.to_nat(limit),O.snapshot(R.World{id,next,[],pending}),O.steps([])) : T.Observation}:
  %commands(pending) : {T.Observation{U32.to_nat(id),U32.to_nat(next),[],R.commands_project(pending)} == T.Observation{U32.to_nat(id),U32.to_nat(next),S.enumerate_rows(U32.to_nat(next),0n,[],T.Any{}),_} : T.Observation}
  %enumerate_empty(U32.to_nat(next),0n) : {T.Observation{U32.to_nat(id),U32.to_nat(next),[],R.commands_project(pending)} == T.Observation{U32.to_nat(id),U32.to_nat(next),_,R.commands_project(pending)} : T.Observation}
  {==}

def family(+limit: U32, +id: U32, +next: U32, +pending: List<&2,R.Command>)
  -> S.When(S.run_safe(O.steps([]),U32.to_nat(limit),O.snapshot(R.World{id,next,[],pending})),
    {M.observe(R.snapshot(R.project(R.tick([],limit,R.World{id,next,[],pending})))) == S.schedule_observation(U32.to_nat(limit),O.snapshot(R.World{id,next,[],pending}),O.steps([])) : T.Observation}):
  P.introduce(S.run_safe(O.steps([]),U32.to_nat(limit),O.snapshot(R.World{id,next,[],pending})),
    {M.observe(R.snapshot(R.project(R.tick([],limit,R.World{id,next,[],pending})))) == S.schedule_observation(U32.to_nat(limit),O.snapshot(R.World{id,next,[],pending}),O.steps([])) : T.Observation},equation(limit,id,next,pending))
