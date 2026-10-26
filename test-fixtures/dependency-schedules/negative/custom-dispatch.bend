import Base
import ../ordinary/schema.bend as Schema
import ../ordinary/bodies.bend as Body
import ../ordinary/admission-controls.bend as Control
import ../../../src/ecs/dependency-application.bend as App
import ../../../src/ecs/dependency-registration.bend as Reg
import ../../../src/ecs/dependency-registry-program.bend as Prog
import ../../../src/ecs/dependency-executor.bend as Exec

def custom(~S:Data,guard:Control.Guard(~S),world:Schema.World(~S),_:U32) -> Control.Guard(~S) & (Schema.World(~S) & Exec.Invocation<String,Bool>):
  (guard,(world,Exec.AdmissionRefused{}))
def rejected(~S:Data,~F:Prog.Family(~String,~Bool),~leaf:Prog.Leaf(~String,~Bool,~F),~pair:Prog.Join(~String,~Bool,~F),~partition:Prog.Partition(~String,~Bool,~F),~rootcut:Prog.Rootcut(~String,~Bool,~F),~empty:Prog.Vacant(~String,~Bool,~F),guard:Control.Guard(~S)) -> F(Schema.World(~S),Control.Guard(~S),custom(~S)):
  leaf(S,Unit,Schema.Resources(~S),Unit,Schema.Write(),Schema.Local,Schema.write(~S),Control.writable,guard)
