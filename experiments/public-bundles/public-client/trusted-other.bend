import Base
import ../public.bend as P
import ../combined-other.bend as A
import ../combined-control.bend as B
import ../prototype.bend as Pack
import ../constructor-control.bend as K
import ../../../src/ecs/capabilities.bend as Cap
import ../../../src/ecs/world.bend as W
type Observation is Data:
  Observation{errors:List<&2,Maybe<&2,String>>}
def observed(world:W.World<A.Schema,A.Store,A.Mail,U32>) -> W.World<A.Schema,A.Store,A.Mail,U32> & Observation:
  match world:
    case W.World{ns,next,high,live,cap,depth,store,A.Mail{context,items,installed,quarantine,+errors},events,commands,regs,system,clock}: (W.World{ns,next,high,live,cap,depth,store,A.Mail{context,items,installed,quarantine,errors},events,commands,regs,system,clock},Observation{errors})
def request(world:W.World<A.Schema,A.Store,A.Mail,U32>,payload:Pack.Pack<K.Raw<Array<U32>>,Pack.Pack<K.Raw<U32>,Pack.Pack<K.Raw<K.Tag>,Pack.Pack<K.Raw<K.QueueOwner>,Unit>>>>) -> W.World<A.Schema,A.Store,A.Mail,U32> & Observation:
  observed(A.eager(world,payload))
def finished(observed:W.World<A.Schema,A.Store,A.Mail,U32> & Unit) -> String:
  match observed:
    case (world,Unit{}): A.snapshot(W.barrier(~A.Schema,~A.Store,~A.Mail,~U32,world))
