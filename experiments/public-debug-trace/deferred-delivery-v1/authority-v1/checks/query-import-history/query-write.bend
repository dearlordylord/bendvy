import Base
import ./subscriber-positive.bend as Positive
import ../../../../src/ecs/execution-trace.bend as Trace
import ../reader-query-context-v1/fixture.bend as F
import ../../../../src/ecs/capabilities.bend as Cap
def denied(~H:Type,~caps:F.Ops(H),owner:H) -> H:Cap.set(~H,~Array<U32>,~U32,~caps,owner,ANode{ALeaf{1},ALeaf{2}})
