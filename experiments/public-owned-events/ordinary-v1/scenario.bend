import Base
import ./fixture.bend as F
import ./payload.bend as P
import ./observe.bend as O
import ../../../src/ecs/ordinary-owned-event.bend as Pub
import ../../../src/ecs/owned-event-runtime.bend as Read
import ../../../src/ecs/owned-event-storage.bend as Storage
import ../../../src/ecs/owned-event-log.bend as Log
import ../../../src/ecs/event-runtime.bend as Ev
import ../../../src/ecs/system.bend as Sys
import ../../../src/ecs/transaction.bend as T
import ../../../src/ecs/world.bend as W

def publication_status(result:T.Outcome<F.PublishError>) -> String:
  match result:
    case T.Success{}:"committed"
    case T.Failure{_}:"aborted"
def read_status(result:T.Outcome<Read.Failure<P.Error>>) -> String:
  match result:
    case T.Success{}:"read"
    case T.Failure{Read.BodyFailed{_}}:"failed"
    case T.Failure{Read.MissingPayload{}}:"missing-payload"
def set_fail(fail:Bool,args:P.Args) -> P.Args:
  match args:
    case P.Args{_,values,scratch}:P.Args{fail,values,scratch}
def published(~S:Data,result:Sys.RunResult<S,Unit,Storage.Resources<Unit,Array<U32>>,Nat,F.PublishArgs,Unit,Pub.Reply<F.PublishError,Unit,Array<U32>>,Pub.runner(~S,~Unit,~Unit,~Array<U32>,~F.domain(~S),~F.PublishArgs,~F.PublishError,~Unit,~F.write(~S))>) -> F.World(~S) & (F.Publisher(~S) & String):
  match result:
    case Sys.Completed{registry,Sys.Succeeded{world,Pub.Reply{outcome,_,recovered}}}:(world,(registry,publication_status(outcome) ++ ":" ++ O.payloads(recovered) ++ "\n"))
    case Sys.RegistrationRejected{registry,world,F.PublishArgs{fail,payloads}}:(world,(registry,"refused:" ++ Bool.show(fail) ++ ":" ++ O.payloads(payloads) ++ "\n"))
    case Sys.Completed{registry,Sys.Failed{world,_}}:(world,(registry,"unexpected-transport-failure\n"))
def publish_world(~S:Data,registry:F.Publisher(~S),args:F.PublishArgs,world:F.World(~S)) -> F.World(~S) & (F.Publisher(~S) & String):
  published(~S,Pub.run(~S,~Unit,~Unit,~Array<U32>,~F.domain(~S),~F.PublishArgs,~F.PublishError,~Unit,~F.write(~S),registry,world,args))
def publish_returned(~S:Data,foreign:F.World(~S),fast:Ev.Reader<S>,fastRegistry:F.Registry(~S),slow:Ev.Reader<S>,slowRegistry:F.Registry(~S),fastArgs:P.Args,slowArgs:P.Args,result:F.Runtime(~S) & (F.Publisher(~S) & String)) -> F.Host<S> & String:
  match result:
    case (runtime,(publisher,status)):(F.Host{runtime,foreign,publisher,fast,fastRegistry,slow,slowRegistry,fastArgs,slowArgs},status)
def publish(~S:Data,host:F.Host<S>,args:F.PublishArgs) -> F.Host<S> & String:
  match host:
    case F.Host{runtime,foreign,publisher,fast,fastRegistry,slow,slowRegistry,fastArgs,slowArgs}:
      publish_returned(~S,foreign,fast,fastRegistry,slow,slowRegistry,fastArgs,slowArgs,Ev.with_world(~S,~Unit,~Storage.Resources<Unit,Array<U32>>,~Nat,~(F.Publisher(~S) & String),publish_world(~S,publisher,args),runtime))
type ReadBack<S:Data> is Type:
  ReadBack{runtime:F.Runtime(~S),reader:Ev.Reader<S>,registry:F.Registry(~S),args:P.Args,status:String}
def read_back(~S:Data,result:Ev.RunResult<S,Unit,Storage.Resources<Unit,Array<U32>>,Nat,P.Args,Unit,Read.Reply<P.Error,P.Args>,Read.runner(~S,~Unit,~Unit,~Array<U32>,~P.Request,~P.Projection,~P.Args,~P.Error,~F.domain(~S),~P.at,~P.read)>) -> ReadBack<S>:
  match result:
    case Ev.Ran{runtime,reader,registry,Ev.Succeeded{Read.Reply{outcome,args,lagged}}}:ReadBack{runtime,reader,registry,args,read_status(outcome) ++ ":lagged=" ++ Bool.show(lagged) ++ "\n"}
    case Ev.Ran{runtime,reader,registry,Ev.Rejected{args}}:ReadBack{runtime,reader,registry,args,"reader-refused\n"}
    case Ev.Ran{runtime,reader,registry,Ev.Failed{_}}:ReadBack{runtime,reader,registry,P.args(False{},9999),"unexpected-transport-failure\n"}
def fast_back(~S:Data,foreign:F.World(~S),publisher:F.Publisher(~S),slow:Ev.Reader<S>,slowRegistry:F.Registry(~S),slowArgs:P.Args,result:ReadBack<S>) -> F.Host<S> & String:
  match result:
    case ReadBack{runtime,fast,fastRegistry,fastArgs,status}:(F.Host{runtime,foreign,publisher,fast,fastRegistry,slow,slowRegistry,fastArgs,slowArgs},status)
def slow_back(~S:Data,foreign:F.World(~S),publisher:F.Publisher(~S),fast:Ev.Reader<S>,fastRegistry:F.Registry(~S),fastArgs:P.Args,result:ReadBack<S>) -> F.Host<S> & String:
  match result:
    case ReadBack{runtime,slow,slowRegistry,slowArgs,status}:(F.Host{runtime,foreign,publisher,fast,fastRegistry,slow,slowRegistry,fastArgs,slowArgs},status)
def read(~S:Data,which:Bool,fail:Bool,host:F.Host<S>) -> F.Host<S> & String:
  match which host:
    case True{} F.Host{runtime,foreign,publisher,fast,fastRegistry,slow,slowRegistry,fastArgs,slowArgs}:fast_back(~S,foreign,publisher,slow,slowRegistry,slowArgs,read_back(~S,Read.run(~S,~Unit,~Unit,~Array<U32>,~P.Request,~P.Projection,~P.Args,~P.Error,~F.domain(~S),~P.at,~P.read,runtime,fast,fastRegistry,set_fail(fail,fastArgs))))
    case False{} F.Host{runtime,foreign,publisher,fast,fastRegistry,slow,slowRegistry,fastArgs,slowArgs}:slow_back(~S,foreign,publisher,fast,fastRegistry,fastArgs,read_back(~S,Read.run(~S,~Unit,~Unit,~Array<U32>,~P.Request,~P.Projection,~P.Args,~P.Error,~F.domain(~S),~P.at,~P.read,runtime,slow,slowRegistry,set_fail(fail,slowArgs))))
def maintained(~S:Data,foreign:F.World(~S),publisher:F.Publisher(~S),fast:Ev.Reader<S>,fastRegistry:F.Registry(~S),slow:Ev.Reader<S>,slowRegistry:F.Registry(~S),fastArgs:P.Args,slowArgs:P.Args,result:F.Runtime(~S) & List<Log.Row<Array<U32>>>) -> F.Host<S> & String:
  match result:
    case (runtime,retired):(F.Host{runtime,foreign,publisher,fast,fastRegistry,slow,slowRegistry,fastArgs,slowArgs},"retired:" ++ O.retired(retired) ++ "\n")
def maintenance(~S:Data,drain:Bool,host:F.Host<S>) -> F.Host<S> & String:
  match drain host:
    case False{} F.Host{runtime,foreign,publisher,fast,fastRegistry,slow,slowRegistry,fastArgs,slowArgs}:maintained(~S,foreign,publisher,fast,fastRegistry,slow,slowRegistry,fastArgs,slowArgs,Storage.frame(~S,~Unit,~Unit,~Array<U32>,runtime))
    case True{} F.Host{runtime,foreign,publisher,fast,fastRegistry,slow,slowRegistry,fastArgs,slowArgs}:maintained(~S,foreign,publisher,fast,fastRegistry,slow,slowRegistry,fastArgs,slowArgs,Storage.drain(~S,~Unit,~Unit,~Array<U32>,runtime))
def foreign_returned(~S:Data,runtime:F.Runtime(~S),fast:Ev.Reader<S>,fastRegistry:F.Registry(~S),slow:Ev.Reader<S>,slowRegistry:F.Registry(~S),fastArgs:P.Args,slowArgs:P.Args,result:F.World(~S) & (F.Publisher(~S) & String)) -> F.Host<S> & String:
  match result:
    case (foreign,(publisher,status)):(F.Host{runtime,foreign,publisher,fast,fastRegistry,slow,slowRegistry,fastArgs,slowArgs},status)
def foreign(~S:Data,host:F.Host<S>) -> F.Host<S> & String:
  match host:
    case F.Host{runtime,foreign,publisher,fast,fastRegistry,slow,slowRegistry,fastArgs,slowArgs}:foreign_returned(~S,runtime,fast,fastRegistry,slow,slowRegistry,fastArgs,slowArgs,publish_world(~S,publisher,F.PublishArgs{False{},[P.payload(500)]},foreign))
def skipped(~S:Data,foreign:F.World(~S),publisher:F.Publisher(~S),fastRegistry:F.Registry(~S),slow:Ev.Reader<S>,slowRegistry:F.Registry(~S),fastArgs:P.Args,slowArgs:P.Args,result:F.Runtime(~S) & Ev.Reader<S>) -> F.Host<S> & String:
  match result:
    case (runtime,fast):(F.Host{runtime,foreign,publisher,fast,fastRegistry,slow,slowRegistry,fastArgs,slowArgs},"skipped\n")
def skip(~S:Data,host:F.Host<S>) -> F.Host<S> & String:
  match host:
    case F.Host{runtime,foreign,publisher,fast,fastRegistry,slow,slowRegistry,fastArgs,slowArgs}:skipped(~S,foreign,publisher,fastRegistry,slow,slowRegistry,fastArgs,slowArgs,Ev.skip(~S,~Unit,~Storage.Resources<Unit,Array<U32>>,~Nat,runtime,fast))
type Action is Data:
  Fast{}
  Slow{}
  Failed{}
  Publish{}
  Next{}
  Abort{}
  Frame{}
  Skip{}
  Foreign{}
  Drain{}
def act(~S:Data,action:Action,host:F.Host<S>) -> F.Host<S> & String:
  match action:
    case Fast{}:read(~S,True{},False{},host)
    case Slow{}:read(~S,False{},False{},host)
    case Failed{}:read(~S,False{},True{},host)
    case Publish{}:publish(~S,host,F.PublishArgs{False{},[P.payload(10),P.payload(20)]})
    case Next{}:publish(~S,host,F.PublishArgs{False{},[P.payload(30)]})
    case Abort{}:publish(~S,host,F.PublishArgs{True{},[P.payload(40),P.payload(50)]})
    case Frame{}:maintenance(~S,False{},host)
    case Skip{}:skip(~S,host)
    case Foreign{}:foreign(~S,host)
    case Drain{}:maintenance(~S,True{},host)
def checkpoint(~S:Data,next:F.Host<S> -> String,result:F.Host<S> & String) -> String:
  match result:
    case (host,text):text ++ next(host)
def stepped(~S:Data,next:F.Host<S> -> String,result:F.Host<S> & String) -> String:
  match result:
    case (host,status):status ++ checkpoint(~S,next,O.snapshot(~S,"step",host))
def steps(~S:Data,actions:List<&2,Action>,host:F.Host<S>) -> String:
  match actions:
    case []:""
    case action <> rest:stepped(~S,next => steps(~S,rest,next),act(~S,action,host))
def started(~S:Data,result:F.Started<S>) -> String:
  match result:
    case F.SetupFailed{}:"SETUP_FAILED\n"
    case F.Started{host}:checkpoint(~S,next => steps(~S,[Fast{},Slow{},Publish{},Failed{},Slow{},Abort{},Next{},Frame{},Fast{},Skip{},Frame{},Frame{},Foreign{},Drain{},Drain{}],next),O.snapshot(~S,"initial",host))
def start(~S:Data,world:F.World(~S),foreign:F.World(~S)) -> String:started(~S,F.start(~S,world,foreign))
