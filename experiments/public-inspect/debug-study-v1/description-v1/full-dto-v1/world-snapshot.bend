import Base
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import ./owner-observation.bend as Owner
import ./owner-snapshot.bend as Snapshot
import ../render-fixture.bend as R
import ./render.bend as Render
# Every affine field traversed for evidence is returned; function owners are
# counted structurally without executing any queued closure.
def commands_join(head:W.World<Owner.Schema,Array<U32>,Owner.Owner,U32> -> W.World<Owner.Schema,Array<U32>,Owner.Owner,U32>,tail:List<(W.World<Owner.Schema,Array<U32>,Owner.Owner,U32> -> W.World<Owner.Schema,Array<U32>,Owner.Owner,U32>)> & Nat) -> List<(W.World<Owner.Schema,Array<U32>,Owner.Owner,U32> -> W.World<Owner.Schema,Array<U32>,Owner.Owner,U32>)> & Nat:
  match tail:
    case (rest,count):(head<>rest,Succ{count})
def commands(values:List<(W.World<Owner.Schema,Array<U32>,Owner.Owner,U32> -> W.World<Owner.Schema,Array<U32>,Owner.Owner,U32>)>) -> List<(W.World<Owner.Schema,Array<U32>,Owner.Owner,U32> -> W.World<Owner.Schema,Array<U32>,Owner.Owner,U32>)> & Nat:
  match values:
    case []:([],Zero{})
    case head<>tail:commands_join(head,commands(tail))
def live_join(a:Array<Bool> & List<&2,String>,b:Array<Bool> & List<&2,String>) -> Array<Bool> & List<&2,String>:
  match a b:
    case (left,+xs), (right,+ys):(ANode{left,right},List.append(&2,String,xs,ys))
def observe_live(owner:Array<Bool>) -> Array<Bool> & List<&2,String>:
  match owner:
    case ALeaf{+value}:(ALeaf{value},[Render.boolean(value)])
    case ANode{left,right}:live_join(observe_live(left),observe_live(right))
def registration(value:W.RegistrationMeta) -> String:
  match value:
    case W.RegistrationMeta{id,name,access}:U32.show(id)++":"++name++":"++R.array(R.names(access))
def registrations(values:List<&2,W.RegistrationMeta>) -> List<&2,String>:
  match values:
    case []:[]
    case head<>tail:registration(head)<>registrations(tail)
def gathered(+ns:U32,+next:U32,+high:U32,+capacity:U32,+depth:Nat,resource:Owner.Owner,+resourceText:String,+events:List<&2,U32>,pending:List<(W.World<Owner.Schema,Array<U32>,Owner.Owner,U32> -> W.World<Owner.Schema,Array<U32>,Owner.Owner,U32>)>,+count:Nat,+regs:List<&2,W.RegistrationMeta>,+system:U32,+clock:U32,a:Array<Bool> & List<&2,String>,b:Array<U32> & List<&2,U32>) -> W.World<Owner.Schema,Array<U32>,Owner.Owner,U32> & String:
  match a b:
    case (live,+ls), (store,+ss):(W.World{ns,next,high,live,capacity,depth,store,resource,events,pending,regs,system,clock},String.join([U32.show(next),U32.show(high),R.array(ls),U32.show(capacity),Nat.show(depth),R.array(Snapshot.numbers(ss)),resourceText,R.array(Snapshot.numbers(events)),Nat.show(count),R.array(R.names(registrations(regs))),U32.show(system),U32.show(clock)],"|"))
def counted(+ns:U32,+next:U32,+high:U32,live:Array<Bool>,+capacity:U32,+depth:Nat,store:Array<U32>,resource:Owner.Owner,+resourceText:String,+events:List<&2,U32>,+regs:List<&2,W.RegistrationMeta>,+system:U32,+clock:U32,result:List<(W.World<Owner.Schema,Array<U32>,Owner.Owner,U32> -> W.World<Owner.Schema,Array<U32>,Owner.Owner,U32>)> & Nat) -> W.World<Owner.Schema,Array<U32>,Owner.Owner,U32> & String:
  match result:
    case (pending,count):gathered(ns,next,high,capacity,depth,resource,resourceText,events,pending,count,regs,system,clock,observe_live(live),Snapshot.array(store))
def resource_join(result:W.World<Owner.Schema,Array<U32>,Owner.Owner,U32> & String) -> W.World<Owner.Schema,Array<U32>,Owner.Owner,U32> & String:
  match result:
    case (W.World{+ns,+next,+high,live,+capacity,+depth,store,resource,+events,pending,+regs,+system,+clock},resourceText):counted(ns,next,high,live,capacity,depth,store,resource,resourceText,events,regs,system,clock,commands(pending))
def project(world:W.World<Owner.Schema,Array<U32>,Owner.Owner,U32>) -> W.World<Owner.Schema,Array<U32>,Owner.Owner,U32> & String:
  resource_join(W.observe_resource(~Owner.Schema,~Array<U32>,~Owner.Owner,~U32,~String,~Snapshot.project,world))
