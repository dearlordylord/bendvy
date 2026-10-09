import Base
import ./mutant-handle-fixture.bend as Handle
import ../canonical-v1/source/fixture.bend as Input
import /workspace/formal-proofs/bendvy/src/ecs/decode-data.bend as D

type Resources is Data:Resources{valid:Input.ResourceReport,invalid:Input.ResourceReport,rollback:Input.ResourceReport}
def resources(~S:Data) -> Resources:Resources{Input.resource(~S,~D.HandleValue{1},D.Handle{1,4},False{}),Input.resource(~S,~D.HandleValue{1},D.Handle{2,4},False{}),Input.resource(~S,~D.HandleValue{1},D.Handle{1,4},True{})}
type Candidate is Data:Candidate{first:Handle.Cases<Input.First>,second:Handle.Cases<Input.Second>,firstResource:Resources,secondResource:Resources}
def main() -> Candidate:Candidate{Handle.cases(~Input.First),Handle.cases(~Input.Second),resources(~Input.First),resources(~Input.Second)}
