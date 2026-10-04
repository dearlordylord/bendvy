import Base
import ./toolkit.bend as P
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
