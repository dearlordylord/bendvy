import Base
import ../core-consumer-v4/consumer.bend as R
import ../core-runtime-v1/main.bend as Existing
import ../owned-retry-consumer.bend as Retry
import ../../../../src/ecs/world.bend as W
import ../../../../src/ecs/world-io.bend as WIO
import ../../../../src/ecs/transaction.bend as T
import ../../../../src/ecs/bundle-requests.bend as Cmd
import ../../../../src/ecs/bundle-insert-adapter.bend as AD
import ../../../../src/ecs/bundle-provider.bend as Provider
import ../../../../src/ecs/bundle-batch.bend as Batch

def completed(previous:Maybe<&2,AD.Refusal<String>>,output:R.Output(),result:Batch.Finished<R.Schema,R.Store,Existing.Mail,U32,R.Packet,String>) -> Existing.World() & (Maybe<&2,AD.Refusal<String>> & R.Output()):
  match result:
    case Batch.Committed{world}:(world,(previous,output))
    case Batch.Failed{world,packets,error}:(world,(previous,output))
def finish(result:R.Owner(Existing.Mail) & (Maybe<&2,AD.Refusal<String>> & R.Output())) -> Existing.World() & (Maybe<&2,AD.Refusal<String>> & R.Output()):
  match result:
    case (AD.Owner{batch,context},(previous,output)):completed(previous,output,Batch.finish(~R.Schema,~R.Store,~Existing.Mail,~U32,~R.Packet,~String,~Existing.attempt,~Existing.recover,batch,T.Success{}))
def requested(world:Existing.World(),+target:W.Handle<R.Schema>) -> Existing.World() & (Maybe<&2,AD.Refusal<String>> & R.Output()):
  finish(Provider.provide_owned(~R.Owner(Existing.Mail),~R.Input(),~R.Output(),~(R.Input() & W.Handle<R.Schema>),~(Maybe<&2,AD.Refusal<String>> & R.Output()),~(ctx => input => R.request(~Existing.Mail,ctx,input)),~supplied,(Cmd.Input{Cmd.Insert{W.Handle{0,0}},R.sample()},target),R.owner(~Existing.Mail,T.begin(~Existing.World(),~U32,world))))
def supplied(~H:Type,~cap:OwnedCap(H),args:R.Input() & W.Handle<R.Schema>,ctx:H) -> H & (Maybe<&2,AD.Refusal<String>> & R.Output()):
  match args:
    case (input,target):Retry.body(~R.Schema,~R.Raw(),~String,~H,~cap,input,target,ctx)
import ../../../../src/ecs/capabilities.bend as Cap
def OwnedCap(~H:Type) -> Type:Cap.OwnedRequest<H,R.Input(),R.Output()>
def cleanup(prefix:String,result:Existing.World() & String) -> String:
  match result:
    case (world,view):prefix ++ "\nretry-cleanup=" ++ view ++ "|" ++ Existing.state(world)
def published(+target:W.Handle<R.Schema>,prefix:String,result:Existing.World() & String) -> String:
  match result:
    case (world,view):cleanup(prefix ++ "\nretry-after=" ++ view,Existing.observe(Existing.unwind(world),target))
def before(+target:W.Handle<R.Schema>,prefix:String,result:Existing.World() & String) -> String:
  match result:
    case (world,view):published(target,prefix ++ "\nretry-before=" ++ view,Existing.observe(W.barrier(~R.Schema,~R.Store,~Existing.Mail,~U32,world),target))
def retried(result:Existing.World() & (Maybe<&2,AD.Refusal<String>> & R.Output())) -> String:
  match result:
    case (world,(Some{AD.EntityRefused{W.MissingEntity{}}},Cmd.Accepted{+target,False{}})):before(target,"retry-first=MissingEntity",Existing.observe(world,target))
    case (world,(previous,Cmd.Refused{raw,error})):"retry-refused=" ++ Existing.raw_text(raw) ++ "|" ++ Existing.state(world)
    case (world,(previous,output)):"unexpected-retry-outcome|" ++ Existing.state(world)
def activated(+target:W.Handle<R.Schema>,result:Existing.World() & W.Status) -> String:
  match result:
    case (world,W.Accepted{}):retried(requested(world,target))
    case (world,W.Rejected{error}):"activation-refused|" ++ Existing.state(world)
def spawned(result:Existing.World() & W.Reservation<R.Schema>) -> String:
  match result:
    case (world,W.Reserved{+target}):activated(target,W.activate(~R.Schema,~R.Store,~Existing.Mail,~U32,world,target))
    case (world,W.ReservationRejected{error}):"spawn-refused|" ++ Existing.state(world)
def created(result:WIO.Creation<R.Schema,R.Store,Existing.Mail,U32>) -> IO(Unit):
  match result:
    case WIO.Created{world}:IO.print(spawned(W.reserve_id(~R.Schema,~R.Store,~Existing.Mail,~U32,world)))
    case WIO.Refused{mail}:IO.print("namespace-refused")
def next(unit:Unit) -> IO(Unit):IO.bind(WIO.Creation<R.Schema,R.Store,Existing.Mail,U32>,Unit,WIO.create(~R.Schema,~R.Store,~Existing.Mail,~U32,~Existing.empty,Existing.Mail{[],[],[],[]}),created)
def main() -> IO(Unit):IO.bind(Unit,Unit,Existing.main(),next)
