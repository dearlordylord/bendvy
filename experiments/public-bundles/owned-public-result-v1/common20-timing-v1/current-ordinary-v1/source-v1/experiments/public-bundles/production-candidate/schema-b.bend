import Base
import /workspace/formal-proofs/bendvy-worktrees/bundle41-authority-refresh-v1/experiments/public-bundles/owned-public-result-v1/common20-timing-v1/current-ordinary-v1/source-v1/experiments/public-bundles/combined-other.bend as A
import /workspace/formal-proofs/bendvy-worktrees/bundle41-authority-refresh-v1/experiments/public-bundles/owned-public-result-v1/common20-timing-v1/current-ordinary-v1/source-v1/experiments/public-bundles/prototype.bend as B
import /workspace/formal-proofs/bendvy/src/ecs/bundle-pack.bend as BPack
import /workspace/formal-proofs/bendvy/src/ecs/bundle-delivery.bend as BDelivery
import /workspace/formal-proofs/bendvy-worktrees/bundle41-authority-refresh-v1/experiments/public-bundles/owned-public-result-v1/common20-timing-v1/current-ordinary-v1/source-v1/experiments/public-bundles/constructor-control.bend as K
import /workspace/formal-proofs/bendvy/src/ecs/bundle-construction.bend as S
import /workspace/formal-proofs/bendvy-worktrees/bundle41-authority-refresh-v1/experiments/public-bundles/owned-public-result-v1/common20-timing-v1/current-ordinary-v1/source-v1/experiments/public-bundles/fallible-spawn.bend as Spawn
import /workspace/formal-proofs/bendvy-worktrees/bundle41-authority-refresh-v1/experiments/public-bundles/owned-public-result-v1/common20-timing-v1/current-ordinary-v1/source-v1/experiments/public-bundles/queue.bend as Q
import /workspace/formal-proofs/bendvy-worktrees/bundle41-authority-refresh-v1/experiments/public-bundles/owned-public-result-v1/common20-timing-v1/current-ordinary-v1/source-v1/experiments/public-bundles/public.bend as Public
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as T
import /workspace/formal-proofs/bendvy/src/ecs/commands.bend as Cmd
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/src/ecs/schema-fragments.bend as SF
import /workspace/formal-proofs/bendvy-worktrees/bundle41-authority-refresh-v1/experiments/public-bundles/owned-public-result-v1/common20-timing-v1/current-ordinary-v1/source-v1/experiments/public-bundles/public-client/declared-other.bend as Declared

type Operation is Data:
  Spawn{}
  PendingSpawn{}
  Insert{target:W.Handle<A.Schema>}
type Input is Type:
  Input{operation:Operation,raw:BPack.Pack<K.Raw<Array<U32>>,BPack.Pack<K.Raw<U32>,BPack.Pack<K.Raw<K.Tag>,BPack.Pack<K.Raw<K.QueueOwner>,Unit>>>>}
type Observation is Data:
  Observation{errors:List<&2,Maybe<&2,String>>}
def empty(unit:Unit) -> A.Store:
  A.Store{Col.empty(~A.Schema,~Array<U32>),Col.Column{ALeaf{None{}},[]},Col.empty(~A.Schema,~Array<U32>),Col.empty(~A.Schema,~K.Tag),Col.empty(~A.Schema,~U32)}
def resource() -> A.Mail:
  A.Mail{K.context(),[],[],[],[]}
def commit(observed:T.Returned<W.World<A.Schema,A.Store,A.Mail,U32>,Unit>) -> W.World<A.Schema,A.Store,A.Mail,U32>:
  match observed:
    case T.Returned{world,outcome}: world
# Queued commands retain actual captured packets until the explicit barrier.
def spawn_result(observed:B.SpawnResult<A.Schema,A.Store,A.Mail,U32,A.Packet>) -> W.World<A.Schema,A.Store,A.Mail,U32>:
  match observed:
    case B.SpawnQueued{tx,handle}: commit(Cmd.tx_finish(~A.Schema,~A.Store,~A.Mail,~U32,~Unit,tx,T.Success{}))
    case B.SpawnRefused{T.Tx{world,undo,commands,events},A.Packet{cooked,inverse},error}: commit(Cmd.tx_finish(~A.Schema,~A.Store,~A.Mail,~U32,~Unit,T.Tx{A.returned(world,A.Original{inverse(cooked)},"reserve-refusal"),undo,commands,events},T.Success{}))
def population(observed:Spawn.Population<W.World<A.Schema,A.Store,A.Mail,U32>,A.Packet,String>) -> BDelivery.Delivery<W.World<A.Schema,A.Store,A.Mail,U32>,A.Packet>:
  match observed:
    case Spawn.Populated{world}: BDelivery.Delivered{world}
    case Spawn.Unpopulated{world,payload,error}: BDelivery.Undelivered{world,payload,W.MissingEntity{}}
def attempt(world:W.World<A.Schema,A.Store,A.Mail,U32>,handle:W.Handle<A.Schema>,packet:A.Packet) -> BDelivery.Delivery<W.World<A.Schema,A.Store,A.Mail,U32>,A.Packet>:
  population(A.populate(world,handle,packet))
def recover(world:W.World<A.Schema,A.Store,A.Mail,U32>,packet:A.Packet,error:W.WorldError) -> W.World<A.Schema,A.Store,A.Mail,U32>:
  match packet:
    case A.Packet{cooked,inverse}: A.returned(world,A.Original{inverse(cooked)},"insert-refusal")
def inserted(observed:Q.QueueResult<A.Schema,A.Store,A.Mail,U32,A.Packet>) -> W.World<A.Schema,A.Store,A.Mail,U32>:
  match observed:
    case Q.Queued{tx}: commit(Cmd.tx_finish(~A.Schema,~A.Store,~A.Mail,~U32,~Unit,tx,T.Success{}))
    case Q.Refused{T.Tx{world,undo,commands,events},packet,error}: commit(Cmd.tx_finish(~A.Schema,~A.Store,~A.Mail,~U32,~Unit,T.Tx{recover(world,packet,error),undo,commands,events},T.Success{}))
# Only the actual reservation result reaches this closed same-Tx pending seam.
# Existing public FIFO spawn precedes insert; BDelivery.apply revalidates live at barrier.
def empty_population(world:W.World<A.Schema,A.Store,A.Mail,U32>,handle:W.Handle<A.Schema>,unit:Unit) -> W.World<A.Schema,A.Store,A.Mail,U32>:
  world
def pending_reserved(packet:A.Packet,observed:T.Tx<W.World<A.Schema,A.Store,A.Mail,U32>,U32> & W.Reservation<A.Schema>) -> W.World<A.Schema,A.Store,A.Mail,U32>:
  match observed:
    case (tx,W.Reserved{+handle}): commit(Cmd.tx_finish(~A.Schema,~A.Store,~A.Mail,~U32,~Unit,BDelivery.enqueue(~A.Schema,~A.Store,~A.Mail,~U32,~A.Packet,~attempt,~recover,tx,handle,packet),T.Success{}))
    case (T.Tx{world,undo,commands,events},W.ReservationRejected{error}): commit(Cmd.tx_finish(~A.Schema,~A.Store,~A.Mail,~U32,~Unit,T.Tx{recover(world,packet,error),undo,commands,events},T.Success{}))
def dispatch(operation:Operation,world:W.World<A.Schema,A.Store,A.Mail,U32>,packet:A.Packet) -> W.World<A.Schema,A.Store,A.Mail,U32>:
  match operation:
    case PendingSpawn{}: pending_reserved(packet,Cmd.tx_spawn(~A.Schema,~A.Store,~A.Mail,~U32,~Unit,~empty_population,T.begin(~W.World<A.Schema,A.Store,A.Mail,U32>,~U32,world),Unit{}))
    case Spawn{}: spawn_result(Spawn.spawn(~A.Schema,~A.Store,~A.Mail,~U32,~A.Packet,~String,~A.populate,~A.recover,T.begin(~W.World<A.Schema,A.Store,A.Mail,U32>,~U32,world),packet))
    case Insert{target}: inserted(Q.enqueue(~A.Schema,~A.Store,~A.Mail,~U32,~A.Packet,~attempt,~recover,T.begin(~W.World<A.Schema,A.Store,A.Mail,U32>,~U32,world),target,packet))
def staged(operation:Operation,world:W.World<A.Schema,A.Store,A.Mail,U32>,observed:S.Staged<K.Context,BPack.Pack<K.Raw<Array<U32>>,BPack.Pack<K.Raw<U32>,BPack.Pack<K.Raw<K.Tag>,BPack.Pack<K.Raw<K.QueueOwner>,Unit>>>>,BPack.Pack<K.Cooked<Array<U32>>,BPack.Pack<K.Cooked<U32>,BPack.Pack<K.Cooked<K.Tag>,BPack.Pack<K.Cooked<K.QueueOwner>,Unit>>>>,String>) -> W.World<A.Schema,A.Store,A.Mail,U32>:
  match world observed:
    case W.World{ns,next,high,live,cap,depth,store,A.Mail{old,items,installed,quarantine,previous},events,commands,regs,system,clock} S.Failed{context,raw,errors}: W.World{ns,next,high,live,cap,depth,store,A.Mail{context,A.Original{raw} <> items,installed,quarantine,errors},events,commands,regs,system,clock}
    case W.World{ns,next,high,live,cap,depth,store,A.Mail{old,items,installed,quarantine,previous},events,commands,regs,system,clock} S.Valid{context,cooked,inverse,errors}: dispatch(operation,W.World{ns,next,high,live,cap,depth,store,A.Mail{context,items,installed,quarantine,errors},events,commands,regs,system,clock},A.Packet{cooked,inverse})
def requested(world:W.World<A.Schema,A.Store,A.Mail,U32>,input:Input) -> W.World<A.Schema,A.Store,A.Mail,U32>:
  match world input:
    case W.World{ns,next,high,live,cap,depth,store,A.Mail{context,items,installed,quarantine,errors},events,commands,regs,system,clock} Input{operation,raw}: staged(operation,W.World{ns,next,high,live,cap,depth,store,A.Mail{K.context(),items,installed,quarantine,errors},events,commands,regs,system,clock},K.stage_0(context,raw))
def observation(world:W.World<A.Schema,A.Store,A.Mail,U32>) -> W.World<A.Schema,A.Store,A.Mail,U32> & Observation:
  match world:
    case W.World{ns,next,high,live,cap,depth,store,A.Mail{context,items,installed,quarantine,+errors},events,commands,regs,system,clock}: (W.World{ns,next,high,live,cap,depth,store,A.Mail{context,items,installed,quarantine,errors},events,commands,regs,system,clock},Observation{errors})
def request(world:W.World<A.Schema,A.Store,A.Mail,U32>,input:Input) -> W.World<A.Schema,A.Store,A.Mail,U32> & Observation:
  observation(requested(world,input))
def done(-H:Type,observed:H & Observation) -> H & Unit:
  match observed:
    case (ctx,result): (ctx,Unit{})
def gameplay(-H:Type,cap:Cap.Request<H,Input,Observation>,input:Input,ctx:H) -> H & Unit:
  done(H,Public.apply(H,Input,Observation,cap,input,ctx))
def finished(observed:W.World<A.Schema,A.Store,A.Mail,U32> & Unit) -> W.World<A.Schema,A.Store,A.Mail,U32>:
  match observed:
    case (world,unit): world
def invoke(owners:W.World<A.Schema,A.Store,A.Mail,U32> & Input) -> W.World<A.Schema,A.Store,A.Mail,U32>:
  match owners:
    case (world,input): finished(Public.provide(~W.World<A.Schema,A.Store,A.Mail,U32>,~Input,~Observation,~request,~gameplay,input,world))
def bound(observed:SF.Bound<A.Schema,W.World<A.Schema,A.Store,A.Mail,U32> & Input,W.World<A.Schema,A.Store,A.Mail,U32>>) -> W.World<A.Schema,A.Store,A.Mail,U32>:
  match observed:
    case SF.Built{world}: world
    case SF.BindRejected{error,SF.Fragment{entries,(world,Input{operation,raw})}}: A.returned(world,A.Original{raw},"undeclared-refusal")
def call_with(entries:List<&2,SF.Entry<A.Schema>>,world:W.World<A.Schema,A.Store,A.Mail,U32>,operation:Operation,raw:BPack.Pack<K.Raw<Array<U32>>,BPack.Pack<K.Raw<U32>,BPack.Pack<K.Raw<K.Tag>,BPack.Pack<K.Raw<K.QueueOwner>,Unit>>>>) -> W.World<A.Schema,A.Store,A.Mail,U32>:
  bound(Public.provision_declared(~A.Schema,~(W.World<A.Schema,A.Store,A.Mail,U32> & Input),~W.World<A.Schema,A.Store,A.Mail,U32>,~invoke,SF.Fragment{entries,(world,Input{operation,raw})},Declared.required()))
def call(world:W.World<A.Schema,A.Store,A.Mail,U32>,operation:Operation,raw:BPack.Pack<K.Raw<Array<U32>>,BPack.Pack<K.Raw<U32>,BPack.Pack<K.Raw<K.Tag>,BPack.Pack<K.Raw<K.QueueOwner>,Unit>>>>) -> W.World<A.Schema,A.Store,A.Mail,U32>:
  call_with(Declared.available(),world,operation,raw)
def barrier(world:W.World<A.Schema,A.Store,A.Mail,U32>) -> W.World<A.Schema,A.Store,A.Mail,U32>:
  W.barrier(~A.Schema,~A.Store,~A.Mail,~U32,world)
def replacement() -> BPack.Pack<K.Raw<Array<U32>>,BPack.Pack<K.Raw<U32>,BPack.Pack<K.Raw<K.Tag>,BPack.Pack<K.Raw<K.QueueOwner>,Unit>>>>:
  BPack.Pack{K.Raw{True{},ANode{ALeaf{71},ALeaf{72}}},BPack.Pack{K.Raw{True{},27},BPack.Pack{K.Raw{True{},K.Tag{}},BPack.Pack{K.Raw{True{},K.QueueOwner{ANode{ALeaf{91},ALeaf{92}},ANode{ALeaf{101},ALeaf{102}},[ANode{ALeaf{111},ALeaf{112}}]}},Unit{}}}}}
def insert_local(world:W.World<A.Schema,A.Store,A.Mail,U32>) -> W.World<A.Schema,A.Store,A.Mail,U32>:
  match world:
    case W.World{+ns,next,high,live,cap,depth,store,resource,events,commands,regs,system,clock}: call(W.World{ns,next,high,live,cap,depth,store,resource,events,commands,regs,system,clock},Insert{W.Handle{ns,1}},replacement())
def insert_missing(world:W.World<A.Schema,A.Store,A.Mail,U32>) -> W.World<A.Schema,A.Store,A.Mail,U32>:
  match world:
    case W.World{+ns,next,high,live,cap,depth,store,resource,events,commands,regs,system,clock}: call(W.World{ns,next,high,live,cap,depth,store,resource,events,commands,regs,system,clock},Insert{W.Handle{ns,99}},replacement())
def seed(world:W.World<A.Schema,A.Store,A.Mail,U32>) -> W.World<A.Schema,A.Store,A.Mail,U32>:
  barrier(call(world,Spawn{},K.input(True{},True{})))
def retry(world:W.World<A.Schema,A.Store,A.Mail,U32>) -> W.World<A.Schema,A.Store,A.Mail,U32>:
  match world:
    case W.World{+ns,next,high,live,cap,depth,store,A.Mail{context,A.Original{raw} <> rest,installed,quarantine,errors},events,commands,regs,system,clock}: call(W.World{ns,next,high,live,cap,depth,store,A.Mail{context,rest,installed,quarantine,errors},events,commands,regs,system,clock},Insert{W.Handle{ns,1}},raw)
    case world: world
