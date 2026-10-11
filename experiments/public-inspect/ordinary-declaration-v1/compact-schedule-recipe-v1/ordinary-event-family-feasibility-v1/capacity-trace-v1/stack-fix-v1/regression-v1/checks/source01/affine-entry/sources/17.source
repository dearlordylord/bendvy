import Base
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/event-runtime.bend as Ev
import /workspace/formal-proofs/bendvy/src/ecs/event-family-routing.bend as Route
import tree-consumer-affine.bend as C
import tree-setup-affine.bend as Setup
import observer-affine.bend as O
import consumer-public.bend as Source
import /workspace/formal-proofs/bendvy-worktrees/ordinary-schedule-debug-v1/experiments/public-inspect/ordinary-declaration-v1/compact-schedule-recipe-v1/ordinary-schema-debug-v1/refusal-preservation-v1/public-successor/consumer/owner-observer.bend as Physical

type Host is Type:Host{fixture:C.Fixture,args:Maybe<Array<U32>>,reading:Maybe<&2,Ev.Reading<Source.First>>,status:String}
type Action is Data:
  Publish{}
  Read{fail:Bool}
  Retry{}
  Frame{}
def completion(fixture:C.Fixture,completion:Ev.Completion<C.ReadError<Source.First>,C.Output<Source.First>,C.Request>) -> Host:
  match completion:
    case Ev.Succeeded{C.Output{array,reading}}:Host{fixture,Some{array},Some{reading},"Succeeded"}
    case Ev.Failed{C.ReadError{reading}}:Host{fixture,None{},Some{reading},"FailedParked"}
    case Ev.Rejected{C.Request{array,_}}:Host{fixture,Some{array},None{},"Rejected"}
def read_returned(factory:W.Factory,publisher:C.PublisherRegistry(),slow:C.FirstReader(),slowRegistry:C.FirstRegistry(),second:C.SecondReader(),secondRegistry:C.SecondRegistry(),returned:C.FirstRun()) -> Host:
  match returned:
    case Route.Ran{runtime,first,firstRegistry,result}:completion(C.Fixture{factory,publisher,runtime,first,firstRegistry,slow,slowRegistry,second,secondRegistry},result)
def read_fixture(fail:Bool,array:Array<U32>,fixture:C.Fixture) -> Host:
  match fixture:
    case C.Fixture{factory,publisher,runtime,first,firstRegistry,slow,slowRegistry,second,secondRegistry}:read_returned(factory,publisher,slow,slowRegistry,second,secondRegistry,C.run_first(runtime,first,firstRegistry,C.Request{array,fail}))
    case fixture:Host{fixture,Some{array},None{},"SetupUnavailable"}
def read(fail:Bool,host:Host) -> Host:
  match host:
    case Host{fixture,Some{array},_,_}:read_fixture(fail,array,fixture)
    case Host{fixture,None{},reading,_}:Host{fixture,None{},reading,"MissingArgs"}
def extracted_list(base:Array<U32>,retained:List<Array<U32>>,namespace:U32,nextId:U32,highWater:U32,live:Array<Bool>,capacity:U32,depth:Nat,store:Array<U32>,events:List<&2,Setup.Events()>,pending:List<(Setup.World() -> Setup.World())>,registrations:List<&2,W.RegistrationMeta>,nextSystemId:U32,clock:U32) -> Setup.World() & Maybe<Array<U32>>:
  match retained:
    case []:(W.World{namespace,nextId,highWater,live,capacity,depth,store,Setup.Resource{base,[]},events,pending,registrations,nextSystemId,clock},None{})
    case array <> rest:(W.World{namespace,nextId,highWater,live,capacity,depth,store,Setup.Resource{base,rest},events,pending,registrations,nextSystemId,clock},Some{array})
def extracted_resource(resource:Setup.Resource,namespace:U32,nextId:U32,highWater:U32,live:Array<Bool>,capacity:U32,depth:Nat,store:Array<U32>,events:List<&2,Setup.Events()>,pending:List<(Setup.World() -> Setup.World())>,registrations:List<&2,W.RegistrationMeta>,nextSystemId:U32,clock:U32) -> Setup.World() & Maybe<Array<U32>>:
  match resource:
    case Setup.Resource{base,retained}:extracted_list(base,retained,namespace,nextId,highWater,live,capacity,depth,store,events,pending,registrations,nextSystemId,clock)
def extract(world:Setup.World()) -> Setup.World() & Maybe<Array<U32>>:
  match world:
    case W.World{namespace,nextId,highWater,live,capacity,depth,store,resource,events,pending,registrations,nextSystemId,clock}:extracted_resource(resource,namespace,nextId,highWater,live,capacity,depth,store,events,pending,registrations,nextSystemId,clock)
def retry_extracted(factory:W.Factory,publisher:C.PublisherRegistry(),first:C.FirstReader(),firstRegistry:C.FirstRegistry(),slow:C.FirstReader(),slowRegistry:C.FirstRegistry(),second:C.SecondReader(),secondRegistry:C.SecondRegistry(),state:Setup.State(),tick:Nat,reading:Maybe<&2,Ev.Reading<Source.First>>,returned:Setup.World() & Maybe<Array<U32>>) -> Host:
  match returned:
    case (world,args):read(False{},Host{C.Fixture{factory,publisher,Route.Runtime{world,state,tick},first,firstRegistry,slow,slowRegistry,second,secondRegistry},args,reading,"Extracted"})
def retry_fixture(reading:Maybe<&2,Ev.Reading<Source.First>>,fixture:C.Fixture) -> Host:
  match fixture:
    case C.Fixture{factory,publisher,Route.Runtime{world,state,tick},first,firstRegistry,slow,slowRegistry,second,secondRegistry}:retry_extracted(factory,publisher,first,firstRegistry,slow,slowRegistry,second,secondRegistry,state,tick,reading,extract(world))
    case fixture:Host{fixture,None{},reading,"SetupUnavailable"}
def retry(host:Host) -> Host:
  match host:
    case Host{fixture,None{},reading,_}:retry_fixture(reading,fixture)
    case Host{fixture,Some{array},reading,_}:Host{fixture,Some{array},reading,"AlreadyHasArgs"}
def published(args:Maybe<Array<U32>>,reading:Maybe<&2,Ev.Reading<Source.First>>,returned:C.Fixture & String) -> Host:
  match returned:
    case (fixture,status):Host{fixture,args,reading,status}
def frame_fixture(fixture:C.Fixture) -> C.Fixture:
  match fixture:
    case C.Fixture{factory,publisher,runtime,first,firstRegistry,slow,slowRegistry,second,secondRegistry}:C.Fixture{factory,publisher,Setup.next_frame(runtime),first,firstRegistry,slow,slowRegistry,second,secondRegistry}
    case fixture:fixture
def step(action:Action,host:Host) -> Host:
  match action host:
    case Publish{} Host{fixture,args,reading,_}:published(args,reading,C.publish(fixture))
    case Read{fail} host:read(fail,host)
    case Retry{} host:retry(host)
    case Frame{} Host{fixture,args,reading,_}:Host{frame_fixture(fixture),args,reading,"Framed"}
def argument_array(returned:Array<U32> & String) -> Maybe<Array<U32>> & String:
  match returned:
    case (array,text):(Some{array},"Some(" ++ text ++ ")")
def argument(value:Maybe<Array<U32>>) -> Maybe<Array<U32>> & String:
  match value:
    case None{}:(None{},"None")
    case Some{array}:argument_array(Physical.u32_array(array))
def reading(value:Maybe<&2,Ev.Reading<Source.First>>) -> String:
  match value:
    case None{}:"None"
    case Some{Ev.Reading{values,lagged}}:List.show(&2,Source.First,O.first_text,values) ++ ":" ++ Bool.show(lagged)
def inventory_text(value:Maybe<&2,List<&2,String>>) -> String:
  match value:
    case None{}:"None"
    case Some{values}:"Some(" ++ List.show(&2,String,O.text,values) ++ ")"
def observed(fixture:C.Fixture & String,args:Maybe<Array<U32>> & String,+last:Maybe<&2,Ev.Reading<Source.First>>,+status:String,+enabled:Bool,inventory:Maybe<&2,List<&2,String>>) -> Host & String:
  (fixture,physical)=fixture
  (args,argText)=args
  (Host{fixture,args,last,status},"enabled=" ++ Bool.show(enabled) ++ "|inventory=" ++ inventory_text(inventory) ++ "|args=" ++ argText ++ "|reading=" ++ reading(last) ++ "|status=" ++ status ++ "|" ++ physical)
def snapshot_runtime(args:Maybe<Array<U32>>,last:Maybe<&2,Ev.Reading<Source.First>>,status:String,+enabled:Bool,factory:W.Factory,publisher:C.PublisherRegistry(),first:C.FirstReader(),firstRegistry:C.FirstRegistry(),slow:C.FirstReader(),slowRegistry:C.FirstRegistry(),second:C.SecondReader(),secondRegistry:C.SecondRegistry(),returned:Setup.Runtime() & Maybe<&2,List<&2,String>>) -> Host & String:
  match returned:
    case (runtime,inventory):observed(O.fixture(C.Fixture{factory,publisher,runtime,first,firstRegistry,slow,slowRegistry,second,secondRegistry}),argument(args),last,status,enabled,inventory)
def snapshot(+enabled:Bool,host:Host) -> Host & String:
  match host:
    case Host{C.Fixture{factory,publisher,runtime,first,firstRegistry,slow,slowRegistry,second,secondRegistry},args,last,status}:snapshot_runtime(args,last,status,enabled,factory,publisher,first,firstRegistry,slow,slowRegistry,second,secondRegistry,Setup.inspect(enabled,runtime))
    case Host{fixture,args,last,status}:observed(O.fixture(fixture),argument(args),last,status,enabled,None{})
def prepended(row:String,returned:Host & List<&2,String>) -> Host & List<&2,String>:
  match returned:
    case (host,rest):(host,row <> rest)
def snap_join(next:Host -> Host & List<&2,String>,returned:Host & String) -> Host & List<&2,String>:
  match returned:
    case (host,row):prepended(row,next(host))
def flags(values:List<&2,Bool>,host:Host) -> Host & List<&2,String>:
  match values:
    case []:(host,[])
    case flag <> rest:snap_join((host => flags(rest,host)),snapshot(flag,host))
def appended(rows:List<&2,String>,returned:Host & List<&2,String>) -> Host & List<&2,String>:
  match returned:
    case (host,rest):(host,List.append(&2,String,rows,rest))
def phase_join(next:Host -> Host & List<&2,String>,returned:Host & List<&2,String>) -> Host & List<&2,String>:
  match returned:
    case (host,rows):appended(rows,next(host))
def sequence(actions:List<&2,Action>,host:Host) -> Host & List<&2,String>:
  match actions:
    case []:(host,[])
    case action <> rest:phase_join((host => sequence(rest,host)),flags([False{},True{},True{},False{}],step(action,host)))
def detached(returned:Host & List<&2,String>) -> List<&2,String>:
  match returned:
    case (_,rows):rows
def scenario() -> List<&2,String>:detached(phase_join((host => sequence([Publish{},Read{False{}},Publish{},Read{True{}},Retry{},Read{False{}},Frame{},Frame{},Read{False{}}],host)),flags([False{},True{},True{},False{}],Host{C.setup(),Some{ALeaf{71}},None{},"Initial"})))
