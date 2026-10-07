import Base
import ../../../../../../src/ecs/world.bend as W
import ../../../../../../src/ecs/commands.bend as Cmd
import ../../../../../../src/ecs/transaction.bend as X
import ../../../../../../src/ecs/system.bend as Sys
import ../../../../../../src/ecs/component.bend as Cmp
import ../../../../../../src/ecs/column.bend as Col
import ../../../../../../src/ecs/relation-types.bend as G
import ../../../../../../src/ecs/relation-commands.bend as A
import ../../../../promotion-stage/application/next-version/v1/owned-world.bend as O
import ../../trace-query.bend as Q
import ../input.bend as I

type Statistics is Data:
  Statistics{spawns:U32,payloads:U32,relations:U32}
type Ready<S:Data> is Type:
  Ready{world:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,statistics:Statistics}
  Refused{world:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>}
  CreationRefused{}
def empty(~S:Data,_:Unit) -> A.Store<S,O.Components<S>>:
  A.Store{O.Components{Col.empty(~S,~O.Payload)},G.Graph{[],[]}}
def supplied_empty(~S:Data,store:A.Store<S,O.Components<S>>,population:U32) -> A.Store<S,O.Components<S>>:
  match store:
    case A.Store{O.Components{column},graph}:A.Store{O.Components{Col.ensure(~S,~O.Payload,column,population)},graph}
def sized_done(~S:Data,result:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & Unit) -> W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>:
  (world,_) = result
  world
def sized_world(~S:Data,world:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,population:U32) -> W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>:
  sized_done(~S,W.with_store(~S,~A.Store<S,O.Components<S>>,~U32,~A.Notice<S,U32>,~Unit,store => (supplied_empty(~S,store,population),Unit{}),world))
# Every Payload remains affine. None is the original deliberately empty entity5.
def payload(id:U32,+seed:U32) -> Maybe<&1,O.Payload>:
  match id:
    case 1:Some{O.Payload{ALeaf{10},100}}
    case 2:Some{O.Payload{ANode{ALeaf{20},ALeaf{21}},200}}
    case 3:Some{O.Payload{ANode{ANode{ALeaf{30},ALeaf{31}},ANode{ALeaf{32},ALeaf{33}}},300}}
    case 4:Some{O.Payload{ANode{ANode{ANode{ALeaf{40},ALeaf{41}},ANode{ALeaf{42},ALeaf{43}}},ANode{ANode{ALeaf{44},ALeaf{45}},ANode{ALeaf{46},ALeaf{47}}}},400}}
    case 5:None{}
    case _:None{}

def populated(~S:Data,result:Cmp.Replacement<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,O.Payload>) -> W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>:
  match result:
    case Cmp.Replaced{world,_}:world
    case Cmp.ReplaceRejected{world,_,_}:W.event_publish(~S,~A.Store<S,O.Components<S>>,~U32,~A.Notice<S,U32>,world,[A.Original{777}])
def populate(~S:Data,world:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,handle:W.Handle<S>,incoming:Maybe<&1,O.Payload>) -> W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>:
  populated(~S,Cmp.structural_replace(~S,~A.Store<S,O.Components<S>>,~U32,~A.Notice<S,U32>,~Q.Rest<S>,~O.Payload,~List<&2,U32>,~Q.Token<S>,~Q.take(~S),~Q.put(~S),~O.project_payload,Q.family(~S),world,handle,incoming))
def queued(~S:Data,result:X.Tx<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>> & W.Reservation<S>,count:U32,id:U32,next:X.Tx<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>> -> U32 -> X.Tx<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>> & Maybe<&2,Statistics>) -> X.Tx<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>> & Maybe<&2,Statistics>:
  match result:
    case (tx,W.Reserved{_}):next(tx,U32.add(count,1))
    case (tx,W.ReservationRejected{_}):(tx,None{})
def spawn_loop(~S:Data,n:Nat,tx:X.Tx<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>>,+id:U32,+count:U32,+seed:U32) -> X.Tx<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>> & Maybe<&2,Statistics>:
  match n:
    case 0n:(tx,Some{Statistics{count,4,0}})
    case 1n+rest:queued(~S,Cmd.tx_spawn(~S,~A.Store<S,O.Components<S>>,~U32,~A.Notice<S,U32>,~Maybe<&1,O.Payload>,~populate(~S),tx,payload(id,seed)),count,id,tx => count => spawn_loop(~S,rest,tx,U32.add(id,1),count,seed))
def spawn_finished(~S:Data,result:X.Tx<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>> & Maybe<&2,Statistics>) -> Sys.Outcome<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,U32,Statistics>:
  match result:
    case (tx,Some{statistics}):Sys.Succeeded{O.commit(~S,tx,X.Success{}),statistics}
    case (tx,None{}):Sys.Failed{O.commit(~S,tx,X.Failure{999}),999}
def spawn_runner(~S:Data,world:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,input:I.Input) -> Sys.Outcome<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,U32,Statistics>:
  match input:
    case I.Input{_,population,_,seed}:spawn_finished(~S,spawn_loop(~S,U32.to_nat(population),X.begin(~W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,~A.Notice<S,U32>,world),1,0,seed))
def seed_runner(~S:Data,world:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,_:I.Input) -> Sys.Outcome<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,U32,Statistics>:
  Sys.Succeeded{O.commit(~S,Q.queue(~S,Q.queue(~S,Q.queue(~S,Q.queue(~S,Q.queue(~S,X.begin(~W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,~A.Notice<S,U32>,world),Q.link(~S),3,1),Q.link(~S),2,1),Q.link(~S),5,1),Q.other(~S),1,4),Q.other(~S),4,2),X.Success{}),Statistics{0,0,5}}
def ran(~S:Data,~runner:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> -> I.Input -> Sys.Outcome<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,U32,Statistics>,result:Sys.RunResult<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>,I.Input,U32,Statistics,runner>) -> Ready<S>:
  match result:
    case Sys.Completed{_,Sys.Succeeded{world,statistics}}:Ready{world,statistics}
    case Sys.Completed{_,Sys.Failed{world,_}}:Refused{world}
    case Sys.RegistrationRejected{_,world,_}:Refused{world}
def registered(~S:Data,~runner:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> -> I.Input -> Sys.Outcome<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,U32,Statistics>,result:Sys.RegistrationResult<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>,I.Input,U32,Statistics,runner>,input:I.Input) -> Ready<S>:
  match result:
    case Sys.Registered{world,registry}:ran(~S,~runner,Sys.run(~S,~A.Store<S,O.Components<S>>,~U32,~A.Notice<S,U32>,~I.Input,~U32,~Statistics,~runner,registry,world,input))
    case Sys.RegistrationFailed{world}:Refused{world}
def invoke(~S:Data,~runner:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> -> I.Input -> Sys.Outcome<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,U32,Statistics>,world:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,input:I.Input,name:String,access:List<&2,String>) -> Ready<S>:
  registered(~S,~runner,Sys.register(~S,~A.Store<S,O.Components<S>>,~U32,~A.Notice<S,U32>,~I.Input,~U32,~Statistics,~runner,world,name,access),input)
def validated_notices(~S:Data,result:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & List<&2,A.Notice<S,U32>>,statistics:Statistics) -> Ready<S>:
  match result:
    case (world,[]):Ready{world,statistics}
    case (world,_):Refused{world}
def merge_seed(~S:Data,result:Ready<S>,spawned:Statistics) -> Ready<S>:
  match result spawned:
    case Ready{world,Statistics{_,_,relations}} Statistics{spawns,payloads,_}:validated_notices(~S,W.events_view(~S,~A.Store<S,O.Components<S>>,~U32,~A.Notice<S,U32>,W.barrier(~S,~A.Store<S,O.Components<S>>,~U32,~A.Notice<S,U32>,world)),Statistics{spawns,payloads,relations})
    case Refused{world} _:Refused{world}
    case CreationRefused{} _:CreationRefused{}
def after_spawn(~S:Data,result:Ready<S>,input:I.Input) -> Ready<S>:
  match result:
    case Ready{world,statistics}:merge_seed(~S,invoke(~S,~seed_runner(~S),W.barrier(~S,~A.Store<S,O.Components<S>>,~U32,~A.Notice<S,U32>,world),input,"seed",["Link.write","OtherLink.write"]),statistics)
    case Refused{world}:Refused{world}
    case CreationRefused{}:CreationRefused{}
def sized_from_input(~S:Data,world:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,input:I.Input) -> W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>:
  match input:
    case I.Input{_,population,_,_}:sized_world(~S,world,population)
def created(~S:Data,result:W.Creation<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,+input:I.Input) -> Ready<S>:
  match result:
    case W.Created{_,world}:after_spawn(~S,invoke(~S,~spawn_runner(~S),sized_from_input(~S,world,input),input,"spawn",["Payload.spawn"]),input)
    case W.CreateRejected{_,_}:CreationRefused{}
def run(~S:Data,+input:I.Input) -> Ready<S>:
  created(~S,W.create(~S,~A.Store<S,O.Components<S>>,~U32,~A.Notice<S,U32>,~empty(~S),W.factory(),77),input)
