import Base
import ./allocation.bend as A
import ./barrier.bend as B
import ./bump.bend as U
import ./frames.bend as F
import ../t11-replacement/runtime.bend as R
import ../t11-replacement/owned-spec.bend as O
import ../t11-replacement/types.bend as T
import ../t11-replacement/model.bend as M

def reserve_pending() -> F.WorldResult<R.step(4,R.World{7,2,[],[]},R.Reserve{8}),M.step(4n,T.World{7n,2n,[],[]},T.Reserve{8n})>:
  A.reserve(4,R.World{7,2,[],[]},8)
def reserve_rejected() -> F.WorldResult<R.step(2,R.World{7,2,[],[]},R.Reserve{8}),M.step(2n,T.World{7n,2n,[],[]},T.Reserve{8n})>:
  A.reserve(2,R.World{7,2,[],[]},8)
def publish_foreign() -> F.WorldResult<R.step(4,R.World{7,2,[],[]},R.Publish{R.Handle{8,1},T.Despawn{}}),M.step(4n,T.World{7n,2n,[],[]},T.Publish{T.Handle{8n,1n},T.Despawn{}})>:
  A.publish(4,R.World{7,2,[],[]},R.Handle{8,1},T.Despawn{})
def fifo() -> F.WorldResult<R.flush(R.World{7,2,[],[R.Spawn{1,3},R.Target{1,T.Insert{}},R.Target{1,T.Remove{}}]}),M.flush(T.World{7n,2n,[],[T.Spawn{1n,3n},T.Target{1n,T.Insert{}},T.Target{1n,T.Remove{}}]})>:
  B.flush(R.World{7,2,[],[R.Spawn{1,3},R.Target{1,T.Insert{}},R.Target{1,T.Remove{}}]})
def bump_arbitrary_tree() -> F.CellResult<R.bump_cell(True{},R.Cell{1,ANode{ALeaf{3},ANode{ALeaf{8},ALeaf{9}}},True{}}),T.Row{1n,4n,True{}}>:
  U.cell_true(1,ANode{ALeaf{3},ANode{ALeaf{8},ALeaf{9}}},True{},{==})
