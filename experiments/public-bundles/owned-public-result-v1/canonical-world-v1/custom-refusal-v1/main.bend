import Base
import drive.bend as Drive
import ../runtime.bend as R
import ../bundle.bend as B
import ../canonical.bend as K
import /workspace/formal-proofs/bendvy/src/ecs/world-io.bend as WIO
def created(result:WIO.Creation<K.SchemaA,B.Store,R.Mail,U32>) -> IO(Unit):
  match result:
    case WIO.Created{world}:IO.print(Drive.begun(world))
    case WIO.Refused{mail}:IO.print("namespace-refused")
def main() -> IO(Unit):IO.bind(WIO.Creation<K.SchemaA,B.Store,R.Mail,U32>,Unit,WIO.create(~K.SchemaA,~B.Store,~R.Mail,~U32,~R.empty,R.Mail{[],[],[],[],ANode{ALeaf{70},ALeaf{71}}}),created)
