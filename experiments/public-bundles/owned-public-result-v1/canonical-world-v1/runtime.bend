import Base
import bundle.bend as B
import canonical.bend as K
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as T
import /workspace/formal-proofs/bendvy/src/ecs/bundle-install.bend as F
import /workspace/formal-proofs/bendvy/src/ecs/bundle-delivery.bend as D
import /workspace/formal-proofs/bendvy/src/ecs/bundle-batch.bend as BT
import /workspace/formal-proofs/bendvy/src/ecs/bundle-requests.bend as Cmd
import /workspace/formal-proofs/bendvy/src/ecs/bundle-insert-adapter.bend as AD
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys

type Saved is Type:Saved{inverse:World() -> F.Restore<World(),B.Entries(),B.Recovery(Mail)>,undo:B.Cooked() -> B.Raw()}
type Quarantine is Type:
  Recovery{recovery:B.Recovery(Mail),undo:B.Cooked() -> B.Raw(),error:W.WorldError}
  Entries{entries:B.Entries(),undo:B.Cooked() -> B.Raw(),error:W.WorldError}
type Mail is Type:Mail{returned:List<B.Raw()>,installed:List<Saved>,quarantine:List<Quarantine>,errors:List<&2,W.WorldError>,spare:Array<U32>}
def World() -> Type:B.World(Mail)
def empty(unit:Unit) -> B.Store:B.Store{Col.empty(~K.SchemaA,~K.Payload),Col.empty(~K.SchemaA,~K.Tail)}
def recover(world:World(),packet:B.Packet,error:W.WorldError) -> World():
  match world:
    case W.World{ns,next,high,live,cap,depth,store,Mail{returned,installed,quarantine,errors,spare},events,pending,regs,system,clock}:W.World{ns,next,high,live,cap,depth,store,Mail{B.unpack(packet) <> returned,installed,quarantine,error <> errors,spare},events,pending,regs,system,clock}
def quarantine_entries(world:World(),entries:B.Entries(),undo:B.Cooked() -> B.Raw(),+error:W.WorldError) -> World():
  match world:
    case W.World{ns,next,high,live,cap,depth,store,Mail{returned,installed,quarantine,errors,spare},events,pending,regs,system,clock}:W.World{ns,next,high,live,cap,depth,store,Mail{returned,installed,Entries{entries,undo,error} <> quarantine,error <> errors,spare},events,pending,regs,system,clock}
def refused_entries(world:World(),undo:B.Cooked() -> B.Raw(),+error:W.WorldError,result:B.Reassembled) -> D.Delivery<World(),B.Packet>:
  match result:
    case B.Ready{cooked}:D.Undelivered{world,B.Packet{cooked,undo},error}
    case B.Missing{entries}:D.Delivered{quarantine_entries(world,entries,undo,error)}
def installed(undo:B.Cooked() -> B.Raw(),result:F.Attempt<World(),B.Entries(),B.Recovery(Mail)>) -> D.Delivery<World(),B.Packet>:
  match result:
    case F.Installed{world,inverse}:
      match world:
        case W.World{ns,next,high,live,cap,depth,store,Mail{returned,receipts,quarantine,errors,spare},events,pending,regs,system,clock}:D.Delivered{W.World{ns,next,high,live,cap,depth,store,Mail{returned,Saved{inverse,undo} <> receipts,quarantine,errors,spare},events,pending,regs,system,clock}}
    case F.Refused{world,entries,error}:refused_entries(world,undo,error,B.cooked_of(entries))
    case F.Quarantined{world,recovery,+error}:
      match world:
        case W.World{ns,next,high,live,cap,depth,store,Mail{returned,receipts,quarantine,errors,spare},events,pending,regs,system,clock}:D.Delivered{W.World{ns,next,high,live,cap,depth,store,Mail{returned,receipts,Recovery{recovery,undo,error} <> quarantine,error <> errors,spare},events,pending,regs,system,clock}}
def attempted(result:F.Attempt<World(),B.Entries(),B.Recovery(Mail)> & (B.Cooked() -> B.Raw())) -> D.Delivery<World(),B.Packet>:
  match result:
    case (result,undo):installed(undo,result)
def attempt(world:World(),target:W.Handle<K.SchemaA>,packet:B.Packet) -> D.Delivery<World(),B.Packet>:attempted(B.install_packet(~Mail,world,target,packet))
def Args() -> Type:K.Context<K.SchemaA> & B.Input()
def OwnedOutput() -> Type:K.Context<K.SchemaA> & B.Output()
def finished(context:K.Context<K.SchemaA>,output:B.Output(),result:BT.Finished<K.SchemaA,B.Store,Mail,U32,B.Packet,String>) -> World() & OwnedOutput():
  match result:
    case BT.Committed{world}:(world,(context,output))
    case BT.Failed{world,packets,error}:(world,(context,output))
def finish(result:B.Owner(Mail) & B.Output()) -> World() & OwnedOutput():
  match result:
    case (AD.Owner{batch,context},output):finished(context,output,BT.finish(~K.SchemaA,~B.Store,~Mail,~U32,~B.Packet,~String,~attempt,~recover,batch,T.Success{}))
def request(world:World(),args:Args()) -> World() & OwnedOutput():
  match args:
    case (context,input):finish(B.run(~Mail,AD.Owner{BT.Batch{T.begin(~World(),~U32,world),[]},context},input))
def succeeded(result:World() & OwnedOutput()) -> Sys.Outcome<World(),String,OwnedOutput()>:
  match result:
    case (world,output):Sys.Succeeded{world,output}
def runner(world:World(),args:Args()) -> Sys.Outcome<World(),String,OwnedOutput()>:succeeded(request(world,args))
def Registry() -> Type:Sys.Registry<K.SchemaA,B.Store,Mail,U32,Args(),String,OwnedOutput(),runner>
def RunResult() -> Type:Sys.RunResult<K.SchemaA,B.Store,Mail,U32,Args(),String,OwnedOutput(),runner>
def run(registry:Registry(),world:World(),args:Args()) -> RunResult():Sys.run_tracked(~K.SchemaA,~B.Store,~Mail,~U32,~Args(),~String,~OwnedOutput(),~runner,registry,world,args)
def remember(world:World(),raw:B.Raw()) -> World():
  match world:
    case W.World{ns,next,high,live,cap,depth,store,Mail{returned,saved,quarantine,errors,spare},events,pending,regs,system,clock}:W.World{ns,next,high,live,cap,depth,store,Mail{raw <> returned,saved,quarantine,errors,spare},events,pending,regs,system,clock}
def restored_entries(world:World(),undo:B.Cooked() -> B.Raw(),result:B.Reassembled) -> World():
  match result:
    case B.Ready{cooked}:remember(world,undo(cooked))
    case B.Missing{entries}:quarantine_entries(world,entries,undo,W.CapacityExceeded{})
def unwound(undo:B.Cooked() -> B.Raw(),result:F.Restore<World(),B.Entries(),B.Recovery(Mail)>) -> World():
  match result:
    case F.Restored{world,entries}:restored_entries(world,undo,B.cooked_of(entries))
    case F.Pending{world,recovery,+error}:
      match world:
        case W.World{ns,next,high,live,cap,depth,store,Mail{returned,saved,quarantine,errors,spare},events,pending,regs,system,clock}:W.World{ns,next,high,live,cap,depth,store,Mail{returned,saved,Recovery{recovery,undo,error} <> quarantine,error <> errors,spare},events,pending,regs,system,clock}
def unwind(world:World()) -> World():
  match world:
    case W.World{ns,next,high,live,cap,depth,store,Mail{returned,Saved{inverse,undo} <> saved,quarantine,errors,spare},events,pending,regs,system,clock}:unwound(undo,inverse(W.World{ns,next,high,live,cap,depth,store,Mail{returned,saved,quarantine,errors,spare},events,pending,regs,system,clock}))
    case world:world
