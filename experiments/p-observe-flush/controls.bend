import Base
import ./toolkit.bend as P
import ./PROOF.bend as Full
import ../t11-replacement/types.bend as T
import ../t11-replacement/model.bend as M
import ../t11-replacement/spec.bend as S

def spawn_other_slot() -> {S.at(M.apply(T.Spawn{1n,7n},[T.Row{2n,8n,True{}}]),2n) == Some{T.Row{2n,8n,True{}}} : Maybe<&2,T.Row>}:
  {==}
def spawn_own_slot() -> {S.at(M.apply(T.Spawn{1n,7n},[T.Row{1n,8n,True{}}]),1n) == Some{T.Row{1n,7n,False{}}} : Maybe<&2,T.Row>}:
  {==}
def duplicate_despawn() -> {S.at(M.modify(1n,T.Despawn{},[T.Row{1n,7n,False{}},T.Row{2n,8n,True{}},T.Row{1n,9n,True{}}]),1n) == None{} : Maybe<&2,T.Row>}:
  {==}
def survivor() -> {S.at(M.modify(1n,T.Despawn{},[T.Row{1n,7n,False{}},T.Row{2n,8n,True{}},T.Row{1n,9n,True{}}]),2n) == Some{T.Row{2n,8n,True{}}} : Maybe<&2,T.Row>}:
  {==}
def fifo_remove_last() -> {S.at(M.apply_all(P.same_slot_commands([T.Insert{},T.Remove{}],1n),[T.Row{1n,7n,False{}}]),1n) == Some{T.Row{1n,7n,False{}}} : Maybe<&2,T.Row>}:
  {==}
def missing_target() -> {S.at(M.modify(1n,T.Insert{},[T.Row{2n,8n,True{}}]),1n) == None{} : Maybe<&2,T.Row>}:
  {==}

# Fresh complete-world observation: physically unsorted survivors, queued Spawn,
# noncommuting Insert/Remove, unknown target and actual Despawn.
def flush_complete_observation() -> {M.observe(M.flush(T.World{0n,4n,[T.Row{3n,9n,True{}},T.Row{1n,7n,False{}}],[T.Spawn{2n,8n},T.Target{1n,T.Insert{}},T.Target{7n,T.Remove{}},T.Target{1n,T.Remove{}},T.Target{3n,T.Despawn{}}]})) == T.Observation{0n,4n,[T.Row{1n,7n,False{}},T.Row{2n,8n,False{}}],[]} : T.Observation}:
  {==}


def flush_valid_premise() -> {S.admissible(8n,T.World{0n,4n,[T.Row{3n,9n,True{}},T.Row{1n,7n,False{}}],[T.Spawn{2n,8n},T.Target{1n,T.Insert{}},T.Target{7n,T.Remove{}},T.Target{1n,T.Remove{}},T.Target{3n,T.Despawn{}}]}) == True{} : Bool}:
  {==}
