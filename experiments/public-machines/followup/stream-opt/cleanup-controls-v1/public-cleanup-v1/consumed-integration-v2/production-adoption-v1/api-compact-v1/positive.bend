import Base
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import system-instance.bend as Managed

type SchemaA is Data:
  SchemaA{}
type SchemaB is Data:
  SchemaB{}
type Ports is Type:
  Ports{namespace:U32,id:U32,payload:Array<U32>}
def validate(ports:Ports,namespace:U32,id:U32) -> Ports & Bool:
  match ports:
    case Ports{+pns,+pid,payload}: (Ports{pns,pid,payload},Bool.and(U32.is_eq(pns,namespace),U32.is_eq(pid,id)))
def remove(~S:Data,world:W.World<S,Unit,Unit,Unit>,ports:Ports) -> W.World<S,Unit,Unit,Unit>:
  world
def create(~S:Data,namespace:U32,id:U32,world:W.World<S,Unit,Unit,Unit>) -> W.World<S,Unit,Unit,Unit> & Ports:
  (world,Ports{namespace,id,Array.new(U32,1n,73)})
def body(~S:Data,world:W.World<S,Unit,Unit,Unit>,args:Unit) -> Sys.Outcome<W.World<S,Unit,Unit,Unit>,Unit,Unit>:
  Sys.Succeeded{world,Unit{}}
def register_a(world:W.World<SchemaA,Unit,Unit,Unit>) -> Managed.Registration<SchemaA,Unit,Unit,Unit,Unit,Unit,Unit,body(~SchemaA),Ports,validate,remove(~SchemaA)>:
  Managed.register(~SchemaA,~Unit,~Unit,~Unit,~Unit,~Unit,~Unit,~body(~SchemaA),~Ports,~validate,~remove(~SchemaA),~create(~SchemaA),world,"compact",[])
def register_b(world:W.World<SchemaB,Unit,Unit,Unit>) -> Managed.Registration<SchemaB,Unit,Unit,Unit,Unit,Unit,Unit,body(~SchemaB),Ports,validate,remove(~SchemaB)>:
  Managed.register(~SchemaB,~Unit,~Unit,~Unit,~Unit,~Unit,~Unit,~body(~SchemaB),~Ports,~validate,~remove(~SchemaB),~create(~SchemaB),world,"compact",[])
def run_a(instance:Managed.Instance<SchemaA,Unit,Unit,Unit,Unit,Unit,Unit,body(~SchemaA),Ports,validate,remove(~SchemaA)>,world:W.World<SchemaA,Unit,Unit,Unit>) -> Managed.RunResult<SchemaA,Unit,Unit,Unit,Unit,Unit,Unit,body(~SchemaA),Ports,validate,remove(~SchemaA)>:
  Managed.run_tracked(~SchemaA,~Unit,~Unit,~Unit,~Unit,~Unit,~Unit,~body(~SchemaA),~Ports,~validate,~remove(~SchemaA),instance,world,Unit{})
# Arbitrary affine ports are passed through the selected generic bind, not Data-coerced.
def bind_any(~P:Type,~check:P -> U32 -> U32 -> P & Bool,~cleanup:W.World<SchemaA,Unit,Unit,Unit> -> P -> W.World<SchemaA,Unit,Unit,Unit>,registry:Sys.Registry<SchemaA,Unit,Unit,Unit,Unit,Unit,Unit,body(~SchemaA)>,ports:P) -> Managed.Instance<SchemaA,Unit,Unit,Unit,Unit,Unit,Unit,body(~SchemaA),P,check,cleanup>:
  Managed.bind(~SchemaA,~Unit,~Unit,~Unit,~Unit,~Unit,~Unit,~body(~SchemaA),~P,~check,~cleanup,registry,ports)
def main() -> Unit:
  Unit{}
