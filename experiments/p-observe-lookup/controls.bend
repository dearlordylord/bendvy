import Base
import ./PROOF.bend as P
import ../t11-replacement/types.bend as T
import ../t11-replacement/model.bend as M
import ../t11-replacement/spec.bend as S

def empty() -> {M.lookup(T.World{0n,1n,[],[]},T.Handle{0n,1n},T.Any{}) == T.Missing{} : T.Lookup}:
  {==}
def local() -> {M.lookup(T.World{0n,2n,[T.Row{1n,7n,True{}}],[]},T.Handle{0n,1n},T.Any{}) == T.Found{T.Row{1n,7n,True{}}} : T.Lookup}:
  {==}
def mismatch() -> {M.lookup(T.World{0n,2n,[T.Row{1n,7n,False{}}],[]},T.Handle{0n,1n},T.Present{}) == T.Mismatch{} : T.Lookup}:
  {==}
def foreign_collision() -> {M.lookup(T.World{0n,2n,[T.Row{1n,7n,True{}}],[]},T.Handle{1n,1n},T.Any{}) == T.Missing{} : T.Lookup}:
  {==}
def duplicate_first_mismatch() -> {M.lookup(T.World{0n,2n,[T.Row{1n,7n,False{}},T.Row{1n,8n,True{}}],[]},T.Handle{0n,1n},T.Present{}) == T.Mismatch{} : T.Lookup}:
  {==}
def outside_counter() -> {M.lookup(T.World{0n,0n,[T.Row{7n,9n,False{}}],[]},T.Handle{0n,7n},T.Absent{}) == T.Found{T.Row{7n,9n,False{}}} : T.Lookup}:
  {==}
def pending_missing() -> {M.lookup(T.World{0n,2n,[],[T.Spawn{1n,7n}]},T.Handle{0n,1n},T.Any{}) == T.Missing{} : T.Lookup}:
  {==}
