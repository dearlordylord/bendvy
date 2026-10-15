import Base
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/system.bend as Sys
import ../../../src/ecs/event-runtime.bend as Ev
import ../../../src/ecs/relation-failure-runtime.bend as K
import ../../../src/ecs/relation-failure-disposal.bend as Dispose
import ../../../src/ecs/internal/relation-failures/domains.bend as D
import ../../../src/ecs/internal/relation-failures/readings.bend as Read

type Schema is Data:
  Schema{}
def empty(_:Unit) -> Unit:Unit{}
def bool(value:Bool) -> String:
  match value:
    case True{}:"true"
    case False{}:"false"
def tail(values:List<&2,U32>) -> String:
  match values:
    case []:""
    case value <> rest:","++U32.show(value)++tail(rest)
def numbers(values:List<&2,U32>) -> String:
  match values:
    case []:"[]"
    case value <> rest:"["++U32.show(value)++tail(rest)++"]"
def position(value:Ev.Position) -> String:
  match value:
    case Ev.Position{id,cursor,registered}:"{\"id\":"++U32.show(id)++",\"cursor\":"++Nat.show(cursor)++",\"registeredAt\":"++Nat.show(registered)++"}"
def positions_tail(values:List<&2,Ev.Position>) -> String:
  match values:
    case []:""
    case value <> rest:","++position(value)++positions_tail(rest)
def positions(values:List<&2,Ev.Position>) -> String:
  match values:
    case []:"[]"
    case value <> rest:"["++position(value)++positions_tail(rest)++"]"
def reading(value:Read.KeyReading<Schema,U32>) -> String:
  match value:
    case Read.KeyReading{D.DeclaredKey{key},values,lagged}:"{\"key\":"++U32.show(key)++",\"values\":"++numbers(values)++",\"lagged\":"++bool(lagged)++"}"
def readings_tail(values:List<&2,Read.KeyReading<Schema,U32>>) -> String:
  match values:
    case []:""
    case value <> rest:","++reading(value)++readings_tail(rest)
def readings(values:List<&2,Read.KeyReading<Schema,U32>>) -> String:
  match values:
    case []:"[]"
    case value <> rest:"["++reading(value)++readings_tail(rest)++"]"
def body(world:W.World<Schema,Unit,Unit,U32>,input:K.Input<Schema,U32,Unit>) -> Sys.Outcome<W.World<Schema,Unit,Unit,U32>,Unit,List<&2,Read.KeyReading<Schema,U32>>>:
  match input:
    case K.Input{values,_}:Sys.Succeeded{world,values}
def unrelated(world:W.World<Schema,Unit,Unit,U32>,_:Unit) -> Sys.Outcome<W.World<Schema,Unit,Unit,U32>,Unit,Unit>:Sys.Succeeded{world,Unit{}}
def classify(_:U32) -> Maybe<D.DescriptorKey<Schema>>:Some{D.DeclaredKey{1}}
def publish(world:W.World<Schema,Unit,Unit,U32>) -> W.World<Schema,Unit,Unit,U32> & Unit:
  (W.event_publish(~Schema,~Unit,~Unit,~U32,world,[42]),Unit{})

def exhausted(result:K.Runtime<Schema,Unit,Unit,U32> & Maybe<&2,U32>,prefix:String,last:U32) -> String:
  match result:
    case (K.Runtime{_,_,_,_,_,_,_,next},None{}):prefix++",\"last\":"++U32.show(last)++",\"exhausted\":true,\"next\":"++U32.show(next)++"}"
    case (_,Some{_}):"unexpected-wrap"
def last_reserved(result:K.Runtime<Schema,Unit,Unit,U32> & Maybe<&2,U32>,prefix:String) -> String:
  match result:
    case (runtime,Some{last}):exhausted(K.reserve_reader(~Schema,~Unit,~Unit,~U32,runtime),prefix,last)
    case (_,None{}):"unexpected-early-exhaustion"
def exhaustion(runtime:K.Runtime<Schema,Unit,Unit,U32>,prefix:String) -> String:
  match runtime:
    case K.Runtime{world,domains,positions,tick,start,boundary,capacity,_}:
      last_reserved(K.reserve_reader(~Schema,~Unit,~Unit,~U32,K.Runtime{world,domains,positions,tick,start,boundary,capacity,4294967294}),prefix)
def removed_check(checked:W.World<Schema,Unit,Unit,U32> & Bool,domains:List<&2,D.Domain<Schema,U32>>,positions:List<&2,Ev.Position>,tick:Nat,start:Nat,boundary:Nat,capacity:Nat,+next:U32,prefix:String,remaining:Bool) -> String:
  match checked:
    case (world,disposed):exhaustion(K.Runtime{world,domains,positions,tick,start,boundary,capacity,next},prefix++",\"remainingSystem\":"++bool(remaining)++",\"disposedSystem\":"++bool(disposed)++",\"nextReaderBeforeExhaustion\":"++U32.show(next))
def remaining_check(checked:W.World<Schema,Unit,Unit,U32> & Bool,domains:List<&2,D.Domain<Schema,U32>>,positions:List<&2,Ev.Position>,tick:Nat,start:Nat,boundary:Nat,capacity:Nat,next:U32,prefix:String) -> String:
  match checked:
    case (world,remaining):removed_check(W.registration_matches(~Schema,~Unit,~Unit,~U32,world,2,"real",["Parent"]),domains,positions,tick,start,boundary,capacity,next,prefix,remaining)
def disposed(result:Dispose.Disposal<Schema,Unit,Unit,U32,Unit,Unit,List<&2,Read.KeyReading<Schema,U32>>,body>,prefix:String) -> String:
  match result:
    case Dispose.ReaderDisposalRejected{_,_}:"unexpected-disposal-refusal"
    case Dispose.ReaderDisposed{K.Runtime{world,domains,+after,tick,start,boundary,capacity,next}}:
      remaining_check(W.registration_matches(~Schema,~Unit,~Unit,~U32,world,1,"unrelated",[]),domains,after,tick,start,boundary,capacity,next,prefix++",\"positionsAfter\":"++positions(after))
def completed(result:K.RunResult<Schema,Unit,Unit,U32,Unit,Unit,List<&2,Read.KeyReading<Schema,U32>>,body>,ids:List<&2,U32>,readerId:U32,systemId:U32) -> String:
  match result:
    case K.Ran{K.Runtime{world,domains,+before,tick,start,boundary,capacity,next},reader,K.Succeeded{values}}:
      disposed(Dispose.dispose(~Schema,~Unit,~Unit,~U32,~Unit,~Unit,~List<&2,Read.KeyReading<Schema,U32>>,~body,K.Runtime{world,domains,before,tick,start,boundary,capacity,next},reader),"{\"reserved\":"++numbers(ids)++",\"reader\":"++U32.show(readerId)++",\"system\":"++U32.show(systemId)++",\"readings\":"++readings(values)++",\"positionsBefore\":"++positions(before))
    case K.Ran{_,_,_}:"unexpected-run-failure"
def seeded(seed:K.Runtime<Schema,Unit,Unit,U32> & Unit,reader:K.Reader<Schema,Unit,Unit,U32,Unit,Unit,List<&2,Read.KeyReading<Schema,U32>>,body>,ids:List<&2,U32>) -> String:
  match seed:
    case (runtime,_):
      match reader:
        case K.Reader{Sys.Registry{+ns,+system,+name,+access,+cursor},+keys,+id}:
          completed(K.run(~Schema,~Unit,~Unit,~U32,~Unit,~Unit,~List<&2,Read.KeyReading<Schema,U32>>,~body,~classify,runtime,K.Reader{Sys.Registry{ns,system,name,access,cursor},keys,id},Unit{}),ids,id,system)
def after_reserve(result:K.Runtime<Schema,Unit,Unit,U32> & Maybe<&2,U32>,reader:K.Reader<Schema,Unit,Unit,U32,Unit,Unit,List<&2,Read.KeyReading<Schema,U32>>,body>,first:U32,second:U32) -> String:
  match result:
    case (runtime,Some{third}):seeded(K.with_world(~Schema,~Unit,~Unit,~U32,~Unit,~classify,publish,runtime),reader,[first,second,third])
    case (_,None{}):"unexpected-reservation-failure"
def registered(result:K.Registered<Schema,Unit,Unit,U32,Unit,Unit,List<&2,Read.KeyReading<Schema,U32>>,body>,first:U32,second:U32) -> String:
  match result:
    case K.RegistrationFailed{_}:"unexpected-registration-failure"
    case K.Registered{runtime,reader}:after_reserve(K.reserve_reader(~Schema,~Unit,~Unit,~U32,runtime),reader,first,second)
def second_reserved(result:K.Runtime<Schema,Unit,Unit,U32> & Maybe<&2,U32>,first:U32) -> String:
  match result:
    case (runtime,Some{second}):registered(K.register(~Schema,~Unit,~Unit,~U32,~Unit,~Unit,~List<&2,Read.KeyReading<Schema,U32>>,~body,runtime,[D.DeclaredKey{1}],"real",["Parent"]),first,second)
    case (_,None{}):"unexpected-reservation-failure"
def first_reserved(result:K.Runtime<Schema,Unit,Unit,U32> & Maybe<&2,U32>) -> String:
  match result:
    case (runtime,Some{first}):second_reserved(K.reserve_reader(~Schema,~Unit,~Unit,~U32,runtime),first)
    case (_,None{}):"unexpected-reservation-failure"
def unrelated_registered(result:Sys.RegistrationResult<Schema,Unit,Unit,U32,Unit,Unit,Unit,unrelated>) -> String:
  match result:
    case Sys.RegistrationFailed{_}:"unexpected-system-failure"
    case Sys.Registered{world,_}:first_reserved(K.reserve_reader(~Schema,~Unit,~Unit,~U32,K.start(~Schema,~Unit,~Unit,~U32,world)))
def created(result:W.Creation<Schema,Unit,Unit,U32>) -> String:
  match result:
    case W.CreateRejected{_,_}:"unexpected-world-failure"
    case W.Created{_,world}:unrelated_registered(Sys.register(~Schema,~Unit,~Unit,~U32,~Unit,~Unit,~Unit,~unrelated,world,"unrelated",[]))
def main() -> IO(Unit):
  IO.print(created(W.create(~Schema,~Unit,~Unit,~U32,~empty,W.factory(),Unit{})))
