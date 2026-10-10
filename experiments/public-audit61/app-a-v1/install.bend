import Base
import bundle.bend as B
import resources.bend as R
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/owner-product.bend as Product
import /workspace/formal-proofs/bendvy/src/ecs/bundle-install.bend as F
import /workspace/formal-proofs/bendvy/src/ecs/bundle-delivery.bend as D
import /workspace/formal-proofs/bendvy/src/ecs/bundle-batch.bend as BT
import /workspace/formal-proofs/bendvy/src/ecs/bundle-construction.bend as CS
import /workspace/formal-proofs/bendvy/src/ecs/bundle-insert-adapter.bend as AD
import /workspace/formal-proofs/bendvy/src/ecs/bundle-requests.bend as Requests
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as T
def recorded(world:B.World(R.Resources()),inverse:B.World(R.Resources()) -> F.Restore<B.World(R.Resources()),B.Entries(),B.RecipeRecovery(R.Resources())>) -> B.World(R.Resources()):
  match world:
    case W.World{ns,next,high,live,capacity,depth,store,Product.Owner{counter,Product.Owner{sibling,R.Receipts{inverses,returned,errors,quarantines}}},events,pending,registrations,nextSystem,clock}:W.World{ns,next,high,live,capacity,depth,store,Product.Owner{counter,Product.Owner{sibling,R.Receipts{inverse <> inverses,returned,errors,quarantines}}},events,pending,registrations,nextSystem,clock}
def recovered(world:B.World(R.Resources()),packet:B.Packet,error:W.WorldError) -> B.World(R.Resources()):
  match world:
    case W.World{ns,next,high,live,capacity,depth,store,Product.Owner{counter,Product.Owner{sibling,R.Receipts{inverses,returned,errors,quarantines}}},events,pending,registrations,nextSystem,clock}:W.World{ns,next,high,live,capacity,depth,store,Product.Owner{counter,Product.Owner{sibling,R.Receipts{inverses,packet <> returned,error <> errors,quarantines}}},events,pending,registrations,nextSystem,clock}
def quarantined(world:B.World(R.Resources()),recovery:B.RecipeRecovery(R.Resources()),undo:B.Raw() -> B.Raw(),error:W.WorldError) -> B.World(R.Resources()):
  match world:
    case W.World{ns,next,high,live,capacity,depth,store,Product.Owner{counter,Product.Owner{sibling,R.Receipts{inverses,returned,errors,quarantines}}},events,pending,registrations,nextSystem,clock}:W.World{ns,next,high,live,capacity,depth,store,Product.Owner{counter,Product.Owner{sibling,R.Receipts{inverses,returned,errors,R.QuarantineReceipt{recovery,undo,error} <> quarantines}}},events,pending,registrations,nextSystem,clock}
def installation(undo:B.Raw() -> B.Raw(),result:F.Attempt<B.World(R.Resources()),B.Entries(),B.RecipeRecovery(R.Resources())>) -> D.Delivery<B.World(R.Resources()),B.Packet>:
  match result:
    case F.Installed{world,inverse}:D.Delivered{recorded(world,inverse)}
    case F.Refused{world,entries,error}:D.Undelivered{world,B.Packet{B.raw_of(entries),undo},error}
    case F.Quarantined{world,recovery,error}:D.Delivered{quarantined(world,recovery,undo,error)}
def attempted(result:F.Attempt<B.World(R.Resources()),B.Entries(),B.RecipeRecovery(R.Resources())> & (B.Raw() -> B.Raw())) -> D.Delivery<B.World(R.Resources()),B.Packet>:
  match result:
    case (result,undo):installation(undo,result)
def attempt(world:B.World(R.Resources()),handle:W.Handle<B.AuditWorkshop>,packet:B.Packet) -> D.Delivery<B.World(R.Resources()),B.Packet>:
  attempted(B.install_recipe(~R.Resources(),world,handle,packet))
type Seeded is Type:
  Seeded{world:B.World(R.Resources()),handle:W.Handle<B.AuditWorkshop>}
  SeedRejected{world:B.World(R.Resources()),payloads:List<B.Packet>,raw:Maybe<&1,B.Raw()>}
def finished(handle:W.Handle<B.AuditWorkshop>,result:BT.Finished<B.AuditWorkshop,B.Store,R.Resources(),U32,B.Packet,String>) -> Seeded:
  match result:
    case BT.Committed{world}:Seeded{world,handle}
    case BT.Failed{world,payloads,error}:SeedRejected{world,payloads,None{}}
def refused(raw:B.Raw(),result:BT.Finished<B.AuditWorkshop,B.Store,R.Resources(),U32,B.Packet,String>) -> Seeded:
  match result:
    case BT.Committed{world}:SeedRejected{world,[],Some{raw}}
    case BT.Failed{world,payloads,error}:SeedRejected{world,payloads,Some{raw}}
def output(batch:BT.Batch<B.AuditWorkshop,B.Store,R.Resources(),U32,B.Packet>,result:Requests.Output<B.AuditWorkshop,B.Raw(),String>) -> Seeded:
  match result:
    case Requests.Accepted{handle,spawned}:finished(handle,BT.finish(~B.AuditWorkshop,~B.Store,~R.Resources(),~U32,~B.Packet,~String,~attempt,~recovered,batch,T.Success{}))
    case Requests.Refused{raw,error}:refused(raw,BT.finish(~B.AuditWorkshop,~B.Store,~R.Resources(),~U32,~B.Packet,~String,~attempt,~recovered,batch,T.Failure{"request-refused"}))
def requested(result:B.Owner(R.Resources()) & Requests.Output<B.AuditWorkshop,B.Raw(),String>) -> Seeded:
  match result:
    case (AD.Owner{batch,context},result):output(batch,result)
def seed(world:B.World(R.Resources())) -> Seeded:
  requested(B.run(~R.Resources(),B.owner(~R.Resources(),T.begin(~B.World(R.Resources()),~U32,world)),Requests.Input{Requests.Spawn{},B.sample()}))
