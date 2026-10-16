import Base
import ./legacy.bend as L
import ../fixture.bend as F
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-recovery.bend as Bridge
type First is Data:First{}
def positive(app:F.Before(~First),capture:Array<Array<U32>>) -> Bridge.Appended<F.Before(~First),L.After(~First),Array<Array<U32>>>:L.automatic_register(~First,app,capture)
