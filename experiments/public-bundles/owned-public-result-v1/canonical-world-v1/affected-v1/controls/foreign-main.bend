import Base
import foreign-drive.bend as Drive
import ../../runtime.bend as R
import ../../bundle.bend as B
import ../../canonical.bend as K
import ../../observe.bend as O
import /workspace/formal-proofs/bendvy/src/ecs/world-io.bend as WIO
def failed(result:R.World() & String) -> String:
  match result:
    case (world,view):"peer-namespace-refused|" ++ view
def peer_created(world:R.World(),result:WIO.Creation<K.SchemaA,B.Store,R.Mail,U32>) -> IO(Unit):
  match result:
    case WIO.Created{peer}:IO.print(Drive.begun(world,peer))
    case WIO.Refused{mail}:IO.print(failed(O.world(world)))
def created(result:WIO.Creation<K.SchemaA,B.Store,R.Mail,U32>) -> IO(Unit):
  match result:
    case WIO.Created{world}:IO.bind(WIO.Creation<K.SchemaA,B.Store,R.Mail,U32>,Unit,WIO.create(~K.SchemaA,~B.Store,~R.Mail,~U32,~R.empty,R.Mail{[],[],[],[],ANode{ALeaf{80},ALeaf{81}}}),result => peer_created(world,result))
    case WIO.Refused{mail}:IO.print("namespace-refused")
def main() -> IO(Unit):IO.bind(WIO.Creation<K.SchemaA,B.Store,R.Mail,U32>,Unit,WIO.create(~K.SchemaA,~B.Store,~R.Mail,~U32,~R.empty,R.Mail{[],[],[],[],ANode{ALeaf{70},ALeaf{71}}}),created)
