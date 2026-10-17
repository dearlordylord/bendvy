import Base
import ./fixture.bend as F
import ./locals.bend as Local
import ./readers.bend as Readers
import ./machine-reader.bend as Machine
import ../../../../src/ecs/world.bend as W

type Owners<S:Data> is Type:
  Owners{local:Local.Owned(~S),reader:Readers.Reader(~S),registry:Readers.Registry(~S),failures:Readers.FailureReader(~S),machine:Machine.Owned(~S),args:Array<U32>,failureArgs:Array<U32>,machineArgs:Array<U32>,service:Array<U32>,foreign:F.World(~S),foreignHandle:W.Handle<S>,handles:List<&2,W.Handle<S>>}
