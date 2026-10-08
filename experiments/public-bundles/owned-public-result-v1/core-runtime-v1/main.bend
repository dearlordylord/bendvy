import Base
import ../core-consumer-v4/consumer.bend as R
import ../../../../src/ecs/world.bend as W
import ../../../../src/ecs/world-io.bend as WIO
import ../../../../src/ecs/column.bend as Col
import ../../../../src/ecs/component.bend as C
import ../../../../src/ecs/transaction.bend as T
import ../../../../src/ecs/bundle-pack.bend as P
import ../../../../src/ecs/bundle-install.bend as F
import ../../../../src/ecs/bundle-delivery.bend as D
import ../../../../src/ecs/bundle-batch.bend as BT
import ../../../../src/ecs/bundle-requests.bend as Cmd
import ../../../../src/ecs/bundle-insert-adapter.bend as AD

# This application's explicit recovery destination. No library default policy.
type Saved is Type:
  Saved{inverse:World() -> F.Restore<World(),R.Entries(),R.RecipeRecovery(Mail)>,undo:R.Raw() -> R.Raw()}
type Quarantine is Type:
  Quarantine{recovery:R.RecipeRecovery(Mail),undo:R.Raw() -> R.Raw(),error:W.WorldError}
type Mail is Type:
  Mail{returned:List<R.Packet>,installed:List<Saved>,quarantined:List<Quarantine>,errors:List<&2,W.WorldError>}
def World() -> Type: R.World(Mail)
def empty(unit:Unit) -> R.Store: R.Store{Col.empty(~R.Schema,~Array<U32>),Col.empty(~R.Schema,~U32)}
def recover(world:World(),packet:R.Packet,error:W.WorldError) -> World():
  match world:
    case W.World{ns,next,high,live,cap,depth,store,Mail{returned,installed,quarantined,errors},events,commands,regs,system,clock}: W.World{ns,next,high,live,cap,depth,store,Mail{packet <> returned,installed,quarantined,error <> errors},events,commands,regs,system,clock}
def installed(undo:R.Raw() -> R.Raw(),observed:F.Attempt<World(),R.Entries(),R.RecipeRecovery(Mail)>) -> D.Delivery<World(),R.Packet>:
  match observed:
    case F.Installed{world,inverse}:
      match world:
        case W.World{ns,next,high,live,cap,depth,store,Mail{returned,receipts,quarantined,errors},events,commands,regs,system,clock}: D.Delivered{W.World{ns,next,high,live,cap,depth,store,Mail{returned,Saved{inverse,undo} <> receipts,quarantined,errors},events,commands,regs,system,clock}}
    case F.Refused{world,entries,error}: D.Undelivered{world,R.Packet{R.raw_of(entries),undo},error}
    case F.Quarantined{world,recovery,+error}:
      match world:
        case W.World{ns,next,high,live,cap,depth,store,Mail{returned,receipts,quarantined,errors},events,commands,regs,system,clock}: D.Delivered{W.World{ns,next,high,live,cap,depth,store,Mail{returned,receipts,Quarantine{recovery,undo,error} <> quarantined,error <> errors},events,commands,regs,system,clock}}
def attempted(result:F.Attempt<World(),R.Entries(),R.RecipeRecovery(Mail)> & (R.Raw() -> R.Raw())) -> D.Delivery<World(),R.Packet>:
  match result:
    case (observed,undo): installed(undo,observed)
def attempt(world:World(),target:W.Handle<R.Schema>,packet:R.Packet) -> D.Delivery<World(),R.Packet>:
  attempted(R.install_recipe(~Mail,world,target,packet))
def finished(output:R.Output(),result:BT.Finished<R.Schema,R.Store,Mail,U32,R.Packet,String>) -> World() & R.Output():
  match result:
    case BT.Committed{world}: (world,output)
    case BT.Failed{world,payloads,error}: (world,output)
def finish(requested:R.Owner(Mail) & R.Output()) -> World() & R.Output():
  match requested:
    case (AD.Owner{batch,context},output): finished(output,BT.finish(~R.Schema,~R.Store,~Mail,~U32,~R.Packet,~String,~attempt,~recover,batch,T.Success{}))
def request(world:World(),operation:Cmd.Operation<R.Schema>,raw:R.Raw()) -> World() & R.Output():
  finish(R.run(~Mail,R.owner(~Mail,T.begin(~World(),~U32,world)),Cmd.Input{operation,raw}))
def projected_array(result:Array<U32> & List<&2,U32>) -> String:
  match result:
    case (owner,+cells): List.show(&2,U32,U32.show,cells)
def array_text(value:Array<U32>) -> String:
  projected_array(R.project_array(value))
def raw_text(raw:R.Raw()) -> String:
  match raw:
    case P.Pack{Some{array},P.Pack{Some{scalar},Unit{}}}: array_text(array) ++ ":" ++ U32.show(scalar)
    case raw: "optional-empty"
def remember(world:World(),packet:R.Packet) -> World():
  match world:
    case W.World{ns,next,high,live,cap,depth,store,Mail{returned,installed,quarantined,errors},events,commands,regs,system,clock}: W.World{ns,next,high,live,cap,depth,store,Mail{packet <> returned,installed,quarantined,errors},events,commands,regs,system,clock}
def unwound(undo:R.Raw() -> R.Raw(),result:F.Restore<World(),R.Entries(),R.RecipeRecovery(Mail)>) -> World():
  match result:
    case F.Restored{world,entries}: remember(world,R.Packet{undo(R.raw_of(entries)),x => x})
    case F.Pending{world,recovery,+error}:
      match world:
        case W.World{ns,next,high,live,cap,depth,store,Mail{returned,installed,quarantined,errors},events,commands,regs,system,clock}: W.World{ns,next,high,live,cap,depth,store,Mail{returned,installed,Quarantine{recovery,undo,error} <> quarantined,error <> errors},events,commands,regs,system,clock}
def unwind(world:World()) -> World():
  match world:
    case W.World{ns,next,high,live,cap,depth,store,Mail{returned,Saved{inverse,undo} <> receipts,quarantined,errors},events,commands,regs,system,clock}: unwound(undo,inverse(W.World{ns,next,high,live,cap,depth,store,Mail{returned,receipts,quarantined,errors},events,commands,regs,system,clock}))
    case world: world
def returned_text(packets:List<R.Packet>) -> String:
  match packets:
    case []: "end"
    case packet <> rest: raw_text(R.unpack(packet)) ++ "," ++ returned_text(rest)
def count(~A:Type,owners:List<A>) -> U32:
  match owners:
    case []: 0
    case head <> tail: (1 + count(~A,tail):U32)
def state(world:World()) -> String:
  match world:
    case W.World{+ns,+next,+high,live,+cap,+depth,store,Mail{returned,installed,quarantined,+errors},+events,commands,+regs,+system,+clock}: "ns=" ++ U32.show(ns) ++ "|next=" ++ U32.show(next) ++ "|high=" ++ U32.show(high) ++ "|clock=" ++ U32.show(clock) ++ "|returned=" ++ returned_text(returned) ++ "|installed=" ++ U32.show(count(~Saved,installed)) ++ "|quarantine=" ++ U32.show(count(~Quarantine,quarantined)) ++ "|errors=" ++ Nat.show(List.length(&2,W.WorldError,errors)) ++ "|pending=" ++ U32.show(count(~(World() -> World()),commands))
def array_access(value:C.Access<List<&2,U32>>) -> String:
  match value:
    case C.Found{+cells}: List.show(&2,U32,U32.show,cells)
    case C.ComponentAbsent{}: "absent"
    case C.MissingEntity{}: "missing"
def scalar_access(value:C.Access<U32>) -> String:
  match value:
    case C.Found{+value}: U32.show(value)
    case C.ComponentAbsent{}: "absent"
    case C.MissingEntity{}: "missing"
def observed_scalar(array:C.Access<List<&2,U32>>,result:World() & C.Access<U32>) -> World() & String:
  match result:
    case (world,scalar): (world,array_access(array) ++ ":" ++ scalar_access(scalar))
def observed_array(+target:W.Handle<R.Schema>,result:World() & C.Access<List<&2,U32>>) -> World() & String:
  match result:
    case (world,array): observed_scalar(array,C.get(~R.Schema,~R.Store,~Mail,~U32,~Col.Column<R.Schema,Array<U32>>,~U32,~U32,~R.ScalarToken,~R.take_scalar,~R.put_scalar,~R.project_scalar,R.scalar_family(),world,target))
def observe(world:World(),+target:W.Handle<R.Schema>) -> World() & String:
  observed_array(target,C.get(~R.Schema,~R.Store,~Mail,~U32,~Col.Column<R.Schema,U32>,~Array<U32>,~List<&2,U32>,~R.ArrayToken,~R.take_array,~R.put_array,~R.project_array,R.array_family(),world,target))
def cleanup_observed(prefix:String,result:World() & String) -> String:
  match result:
    case (world,+view): prefix ++ "\ncleanup=" ++ view ++ "|" ++ state(world)
def restored_observed(+target:W.Handle<R.Schema>,prefix:String,result:World() & String) -> String:
  match result:
    case (world,view): cleanup_observed(prefix ++ "\nrestore=" ++ view,observe(unwind(world),target))
def replaced_observed(+target:W.Handle<R.Schema>,prefix:String,result:World() & String) -> String:
  match result:
    case (world,view): restored_observed(target,prefix ++ "\ninsert=" ++ view,observe(unwind(world),target))
def replaced_result(prefix:String,result:World() & R.Output()) -> String:
  match result:
    case (world,Cmd.Accepted{+target,spawned}): replaced_observed(target,prefix,observe(W.barrier(~R.Schema,~R.Store,~Mail,~U32,world),target))
    case (world,Cmd.Refused{raw,error}): prefix ++ "\ninsert-refused=" ++ raw_text(raw) ++ "|" ++ state(world)
def replaced(world:World(),+target:W.Handle<R.Schema>,prefix:String) -> String:
  replaced_result(prefix,request(world,Cmd.Insert{target},P.Pack{Some{ANode{ALeaf{13},ALeaf{17}}},P.Pack{Some{19},Unit{}}}))
def spawned_after(+target:W.Handle<R.Schema>,before:String,result:World() & String) -> String:
  match result:
    case (world,after): replaced(world,target,"spawn-before=" ++ before ++ "\nspawn-after=" ++ after)
def spawned_before(+target:W.Handle<R.Schema>,result:World() & String) -> String:
  match result:
    case (world,before): spawned_after(target,before,observe(W.barrier(~R.Schema,~R.Store,~Mail,~U32,world),target))
def spawned(result:World() & R.Output()) -> String:
  match result:
    case (world,Cmd.Accepted{+target,spawned}): spawned_before(target,observe(world,target))
    case (world,Cmd.Refused{raw,error}): "spawn-refused=" ++ raw_text(raw) ++ "|" ++ state(world)
def created(result:WIO.Creation<R.Schema,R.Store,Mail,U32>) -> IO(Unit):
  match result:
    case WIO.Created{world}: IO.print(spawned(request(world,Cmd.Spawn{},R.sample())))
    case WIO.Refused{mail}: IO.print("namespace-refused\n")
def main() -> IO(Unit):
  IO.bind(WIO.Creation<R.Schema,R.Store,Mail,U32>,Unit,WIO.create(~R.Schema,~R.Store,~Mail,~U32,~empty,Mail{[],[],[],[]}),created)
