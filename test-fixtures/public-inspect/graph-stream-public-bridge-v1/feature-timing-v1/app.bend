import Base
import ../../../../src/ecs/world.bend as W
import ../../../../src/ecs/inspector.bend as I
import ../../../../src/ecs/event-runtime.bend as Ev
import ../../../../src/ecs/system.bend as Sys
import ../../../../src/ecs/relation-commands.bend as A
import ../../../../src/ecs/inspector-runtime.bend as IR
import ./state.bend as State
import ./setup.bend as Setup
import ./category-run.bend as Cases
import ./reader.bend as Read
import ./reader-types.bend as MT
import ./union.bend as Union
import ./machine-condition.bend as Condition
import ./guard.bend as Guard
import ./render.bend as Render
import ./dump.bend as Dump

def Owner(~S:Data) -> Type: Read.RuntimeOwner<S>
def World(~S:Data) -> Type: Read.World(~S)
def Runtime(~S:Data) -> Type: Read.Runtime(~S)
# Physical diagnostics are a separate route. Every actual owner field is retained;
# the normal run never formats these fields or a discarded World debug dump.
def position(value:Ev.Position) -> String:
  match value:
    case Ev.Position{id,cursor,registeredAt}:U32.show(id) ++ ":" ++ Nat.show(cursor) ++ ":" ++ Nat.show(registeredAt)
def batch(~S:Data,value:Ev.Batch<A.Notice<S,U32>>) -> String:
  match value:
    case Ev.Batch{tick,values}:Nat.show(tick) ++ ":" ++ List.show(&2,A.Notice<S,U32>,Dump.notice(~S),values)
def runtime_dumped(~S:Data,+namespace:U32,+batches:List<&2,Ev.Batch<A.Notice<S,U32>>>,+positions:List<&2,Ev.Position>,+nextReader:U32,+tick:Nat,+frameStart:Nat,+boundary:Nat,+capacity:Nat,+dropped:Nat,observed:World(~S) & String) -> Runtime(~S) & String:
  (world,text)=observed
  (Ev.Runtime{world,namespace,batches,positions,nextReader,tick,frameStart,boundary,capacity,dropped},"EventRuntime(namespace=" ++ U32.show(namespace) ++ "," ++ text ++ ",batches=" ++ List.show(&2,Ev.Batch<A.Notice<S,U32>>,batch(~S),batches) ++ ",positions=" ++ List.show(&2,Ev.Position,position,positions) ++ ",nextReader=" ++ U32.show(nextReader) ++ ",tick=" ++ Nat.show(tick) ++ ",frameStart=" ++ Nat.show(frameStart) ++ ",boundary=" ++ Nat.show(boundary) ++ ",capacity=" ++ Nat.show(capacity) ++ ",dropped=" ++ Nat.show(dropped) ++ ")")
def runtime_view(~S:Data,runtime:Runtime(~S)) -> Runtime(~S) & String:
  match runtime:
    case Ev.Runtime{world,+namespace,+batches,+positions,+nextReader,+tick,+frameStart,+boundary,+capacity,+dropped}:runtime_dumped(~S,namespace,batches,positions,nextReader,tick,frameStart,boundary,capacity,dropped,Dump.world(~S,world))
def stream_value(~S:Data,value:MT.Streams<S>) -> String:
  match value:
    case MT.Streams{flowCurrent,levelCurrent,flow,level,parent,parentLagged}:"{\"flow\":" ++ Union.current(~S,~State.FlowToken,flowCurrent) ++ ",\"level\":" ++ Union.current(~S,~State.LevelToken,levelCurrent) ++ "," ++ Union.stream_fields(Union.reading(flow),Union.reading(level),(Render.array(Union.failures(~S,parent)),Render.boolean(parentLagged))) ++ "}"
def registry_view(~S:Data,registry:Read.Registry(~S)) -> Read.Registry(~S) & String:
  match registry:
    case Sys.Registry{+namespace,+id,+name,+access,+cursor}:(Sys.Registry{namespace,id,name,access,cursor},"Registry(" ++ U32.show(namespace) ++ "," ++ U32.show(id) ++ "," ++ name ++ "," ++ List.show(&2,String,x => x,access) ++ "," ++ U32.show(cursor) ++ ")")
def owner_registry(~S:Data,runtime:Runtime(~S),reader:Ev.Reader<S>,+warm:MT.Streams<S>,runtimeText:String,observed:Read.Registry(~S) & String) -> Owner(~S) & String:
  match reader observed:
    case Ev.Reader{+namespace,+id,+registryId},(registry,text):(Read.RuntimeOwner{runtime,Ev.Reader{namespace,id,registryId},registry,warm},"{\"runtime\":" ++ Render.quoted(runtimeText) ++ ",\"reader\":" ++ Render.quoted(U32.show(namespace) ++ ":" ++ U32.show(id) ++ ":" ++ U32.show(registryId)) ++ ",\"registry\":" ++ Render.quoted(text) ++ ",\"warmResult\":" ++ stream_value(~S,warm) ++ "}")
def owner_runtime(~S:Data,reader:Ev.Reader<S>,registry:Read.Registry(~S),warm:MT.Streams<S>,observed:Runtime(~S) & String) -> Owner(~S) & String:
  (runtime,text)=observed
  owner_registry(~S,runtime,reader,warm,text,registry_view(~S,registry))
def owner_view(~S:Data,owner:Owner(~S)) -> Owner(~S) & String:
  match owner:
    case Read.RuntimeOwner{runtime,reader,registry,warm}:owner_runtime(~S,reader,registry,warm,runtime_view(~S,runtime))
def captured(~S:Data,logical:String,cursor:String,observed:Owner(~S) & String) -> Owner(~S) & Cases.Entry:
  (owner,text)=observed
  (owner,Cases.Entry{logical,"{\"instance\":" ++ Render.quoted(cursor) ++ ",\"owner\":" ++ text ++ "}"})
def capture(~S:Data,physical:Bool,logical:String,cursor:String,owner:Owner(~S)) -> Owner(~S) & Cases.Entry:
  match physical:
    case True{}:captured(~S,logical,cursor,owner_view(~S,owner))
    case False{}:(owner,Cases.Entry{logical,""})
def next(~S:Data,after:Owner(~S) -> Cases.Entry -> Owner(~S) & List<&2,Cases.Entry>,observed:Owner(~S) & Cases.Entry) -> Owner(~S) & List<&2,Cases.Entry>:
  (owner,entry)=observed
  after(owner,entry)
def union_observed(~S:Data,~physical:Bool,schema:String,pass:String,reader:Ev.Reader<S>,registry:Read.Registry(~S),warm:MT.Streams<S>,result:IR.RunResult<S,A.Store<S,State.Components<S>>,State.Resources<S>,U32,Unit,String>) -> Owner(~S) & Cases.Entry:
  match result:
    case IR.RunResult{runtime,instance,Done{value}}:capture(~S,physical,"{\"schema\":" ++ Render.quoted(schema) ++ ",\"operation\":\"machine-inspect\",\"pass\":" ++ Render.quoted(pass) ++ ",\"result\":" ++ value ++ "}",Cases.instance_if(~S,physical,instance),Read.RuntimeOwner{runtime,reader,registry,warm})
    case IR.RunResult{runtime,instance,Fail{_}}:capture(~S,physical,"{\"schema\":" ++ Render.quoted(schema) ++ ",\"operation\":\"machine-inspect-failed\"}",Cases.instance_if(~S,physical,instance),Read.RuntimeOwner{runtime,reader,registry,warm})
def union_step(~S:Data,~physical:Bool,schema:String,pass:String,owner:Owner(~S)) -> Owner(~S) & Cases.Entry:
  match owner:
    case Read.RuntimeOwner{runtime,reader,registry,warm}:union_observed(~S,~physical,schema,pass,reader,registry,warm,Union.run(~S,runtime))
def read_result(~S:Data,~physical:Bool,schema:String,warm:MT.Streams<S>,result:Read.RunResult(~S)) -> Owner(~S) & Cases.Entry:
  match result:
    case Ev.Ran{runtime,reader,registry,Ev.Succeeded{output}}:capture(~S,physical,"{\"schema\":" ++ Render.quoted(schema) ++ ",\"operation\":\"registered-stream-read\",\"result\":" ++ stream_value(~S,output) ++ "}","ReturnedRegisteredReader",Read.RuntimeOwner{runtime,reader,registry,warm})
    case Ev.Ran{runtime,reader,registry,_}:capture(~S,physical,"{\"schema\":" ++ Render.quoted(schema) ++ ",\"operation\":\"registered-stream-read-failed\"}","ReturnedRegisteredReader",Read.RuntimeOwner{runtime,reader,registry,warm})
def read_step(~S:Data,~physical:Bool,schema:String,owner:Owner(~S)) -> Owner(~S) & Cases.Entry:
  match owner:
    case Read.RuntimeOwner{runtime,Ev.Reader{+ns,+id,+registryId},registry,warm}:read_result(~S,~physical,schema,warm,Read.invoke(~S,id,runtime,Ev.Reader{ns,id,registryId},registry))
def condition_done(~S:Data,~physical:Bool,schema:String,observed:Owner(~S) & Guard.Value) -> Owner(~S) & Cases.Entry:
  (owner,Guard.Value{value,registry})=observed
  capture(~S,physical,"{\"schema\":" ++ Render.quoted(schema) ++ ",\"operation\":\"machine-check-noop\",\"result\":" ++ value ++ "}",registry,owner)
def condition_step(~S:Data,~physical:Bool,+schema:String,owner:Owner(~S)) -> Owner(~S) & Cases.Entry:
  condition_done(~S,~physical,schema,Read.map_world(~S,~Guard.Value,world => Condition.run(~S,physical,schema ++ "/FlowAndLinkNoop",world),owner))
def machine_last(~S:Data,prefix:List<&2,Cases.Entry>,observed:Owner(~S) & Cases.Entry) -> Owner(~S) & List<&2,Cases.Entry>:
  (owner,entry)=observed
  (owner,List.append(&2,Cases.Entry,prefix,[entry]))
def machine_checked(~S:Data,~physical:Bool,schema:String,prefix:List<&2,Cases.Entry>,observed:Owner(~S) & Cases.Entry) -> Owner(~S) & List<&2,Cases.Entry>:
  (owner,entry)=observed
  machine_last(~S,List.append(&2,Cases.Entry,prefix,[entry]),read_step(~S,~physical,schema,owner))
def machine_second(~S:Data,~physical:Bool,+schema:String,prefix:List<&2,Cases.Entry>,observed:Owner(~S) & Cases.Entry) -> Owner(~S) & List<&2,Cases.Entry>:
  (owner,entry)=observed
  machine_checked(~S,~physical,schema,List.append(&2,Cases.Entry,prefix,[entry]),condition_step(~S,~physical,schema,owner))
def machine_first(~S:Data,~physical:Bool,+schema:String,prefix:List<&2,Cases.Entry>,observed:Owner(~S) & Cases.Entry) -> Owner(~S) & List<&2,Cases.Entry>:
  (owner,entry)=observed
  machine_second(~S,~physical,schema,List.append(&2,Cases.Entry,prefix,[entry]),union_step(~S,~physical,schema,"second",owner))
def categories_done(~S:Data,~physical:Bool,+schema:String,observed:Owner(~S) & List<&2,Cases.Entry>) -> Owner(~S) & List<&2,Cases.Entry>:
  (owner,entries)=observed
  machine_first(~S,~physical,schema,entries,union_step(~S,~physical,schema,"first",owner))
def schema_finished(~S:Data,observed:Owner(~S) & List<&2,Cases.Entry>) -> List<&2,Cases.Entry>:
  (_,entries)=observed
  entries

def schema_run(~S:Data,~physical:Bool,+schema:String,setup:Setup.Setup<S>) -> List<&2,Cases.Entry>:
  match setup:
    case Setup.BendvyReady{world,registry,_,_,_}:schema_finished(~S,categories_done(~S,~physical,schema,Read.map_world(~S,~List<&2,Cases.Entry>,world => Cases.run(~S,~physical,schema,world),Read.attach(~S,world,registry))))
    case Setup.BuildRefused{_}:[Cases.Entry{"{\"setupFailure\":true}","SetupRefused"}]
def lifecycle(~physical:Bool) -> List<&2,Cases.Entry>:
  List.append(&2,Cases.Entry,schema_run(~State.Workshop,~physical,"Workshop",Setup.build(~State.Workshop)),schema_run(~State.Garden,~physical,"Garden",Setup.build(~State.Garden)))
def logical(entries:List<&2,Cases.Entry>) -> List<&2,String>:
  match entries:
    case []:[]
    case Cases.Entry{text,_} <> rest:text <> logical(rest)
def physical(entries:List<&2,Cases.Entry>) -> List<&2,String>:
  match entries:
    case []:[]
    case Cases.Entry{_,text} <> rest:text <> physical(rest)
def runs(fuel:Nat) -> List<&2,String>:
  match fuel:
    case 0n:[]
    case 1n+rest:Render.array(logical(lifecycle(~False{}))) <> runs(rest)
def run(count:Nat) -> IO(String): IO.pure(String,Render.array(runs(count)))
def report(+entries:List<&2,Cases.Entry>) -> String:
  "{\"records\":" ++ Render.array(logical(entries)) ++ ",\"physical\":" ++ Render.array(physical(entries)) ++ "}"
