import Base
import schema.bend as S
import consumers.bend as C
import operations.bend as Op
import ../../src/ecs/world.bend as W
import ../../src/ecs/system.bend as Sys
import ../../src/ecs/event-runtime.bend as Ev
import ../../src/ecs/removals.bend as Rm
import ../../src/ecs/reader-domains.bend as D
import ../../src/ecs/schedule.bend as Sch
import observe.bend as Obs

def EventRegistry() -> Type: Sys.Registry<S.Schema,S.Store,Unit,S.Notice,Ev.Input<S.Notice,C.ReadArgs>,C.Failure,String,C.event_body>
def ChangeRegistry() -> Type: Sys.Registry<S.Schema,S.Store,Unit,S.Notice,C.ReadArgs,C.Failure,String,C.change_runner>
def OpRegistry() -> Type: Sys.Registry<S.Schema,S.Store,Unit,S.Notice,Op.Request,C.Failure,String,Op.runner>
def RemovalReader() -> Type: Rm.Reader<S.Schema,S.Notice,S.AllToken,C.select>
type EventOwner is Type:
  EventOwner{reader: Ev.Reader<S.Schema>,registry: EventRegistry()}
type Config is Data:
  Config{request: Op.Request,eventFail: Bool,changeFail: Bool,removalFail: Bool,own: Bool}
type Slot<A: Type> is Type:
  Empty{}
  Occupied{owner: A}
type Owners is Type:
  Owners{events: Slot<D.Events<S.Schema,S.Notice>>,fast: Slot<EventOwner>,slow: Slot<EventOwner>,changeFast: Slot<ChangeRegistry()>,changeSlow: Slot<ChangeRegistry()>,removalFast: Slot<RemovalReader()>,removalSlow: Slot<RemovalReader()>,operation: Slot<OpRegistry()>,config: Config,reads: List<&2,String>}
type Host is Type:
  Host{world: S.World(),owners: Owners}
def empty_read(text: String) -> List<&2,String>:
  match text:
    case "": []
    case text: [text]
def append_read(+reads: List<&2,String>,text: String) -> List<&2,String>:
  List.append(&2,String,reads,empty_read(text))
def as_unit(result: Sys.Outcome<S.World(),C.Failure,String>) -> Sys.Outcome<S.World(),C.Failure,Unit>:
  match result:
    case Sys.Succeeded{world,_}: Sys.Succeeded{world,Unit{}}
    case Sys.Failed{world,error}: Sys.Failed{world,error}
def invalid(text: String) -> C.Failure: C.Failed{"invalid-owner-slot:" ++ text}
def outcome_world(result: Sys.Outcome<S.World(),C.Failure,String>) -> S.World():
  match result:
    case Sys.Succeeded{world,_}: world
    case Sys.Failed{world,_}: world
def op_world(result: Sys.RunResult<S.Schema,S.Store,Unit,S.Notice,Op.Request,C.Failure,String,Op.runner>) -> S.World():
  match result:
    case Sys.Completed{_,outcome}: outcome_world(outcome)
    case Sys.RegistrationRejected{_,world,_}: world
def change_world(result: Sys.RunResult<S.Schema,S.Store,Unit,S.Notice,C.ReadArgs,C.Failure,String,C.change_runner>) -> S.World():
  match result:
    case Sys.Completed{_,outcome}: outcome_world(outcome)
    case Sys.RegistrationRejected{_,world,_}: world
def refreshed(owners: Owners,result: D.Detached<S.Schema,S.Store,Unit,S.Notice>,error: Maybe<&2,C.Failure>) -> Owners & Sys.Outcome<S.World(),C.Failure,Unit>:
  match owners result error:
    case Owners{_,Occupied{fast},Occupied{slow},Occupied{cf},Occupied{cs},Occupied{rf},Occupied{rs},Occupied{operation},+config,+reads}, D.Detached{world,events}, None{}: (Owners{Occupied{events},Occupied{fast},Occupied{slow},Occupied{cf},Occupied{cs},Occupied{rf},Occupied{rs},Occupied{operation},config,reads},Sys.Succeeded{world,Unit{}})
    case Owners{_,Occupied{fast},Occupied{slow},Occupied{cf},Occupied{cs},Occupied{rf},Occupied{rs},Occupied{operation},+config,+reads}, D.Detached{world,events}, Some{error}: (Owners{Occupied{events},Occupied{fast},Occupied{slow},Occupied{cf},Occupied{cs},Occupied{rf},Occupied{rs},Occupied{operation},config,reads},Sys.Failed{world,error})
    case owners D.Detached{world,_} _: (owners,Sys.Failed{world,invalid("refreshed")})

def collect_result(owners: Owners,result: Sys.Outcome<S.World(),C.Failure,Unit>) -> Owners & Sys.Outcome<S.World(),C.Failure,Unit>:
  match owners result:
    case Owners{Occupied{events},Occupied{fast},Occupied{slow},Occupied{cf},Occupied{cs},Occupied{rf},Occupied{rs},Occupied{operation},+config,+reads}, Sys.Succeeded{world,_}: refreshed(Owners{Empty{},Occupied{fast},Occupied{slow},Occupied{cf},Occupied{cs},Occupied{rf},Occupied{rs},Occupied{operation},config,reads},D.collect(~S.Schema,~S.Store,~Unit,~S.Notice,~S.is_event,events,world),None{})
    case Owners{Occupied{events},Occupied{fast},Occupied{slow},Occupied{cf},Occupied{cs},Occupied{rf},Occupied{rs},Occupied{operation},+config,+reads}, Sys.Failed{world,+error}: refreshed(Owners{Empty{},Occupied{fast},Occupied{slow},Occupied{cf},Occupied{cs},Occupied{rf},Occupied{rs},Occupied{operation},config,reads},D.collect(~S.Schema,~S.Store,~Unit,~S.Notice,~S.is_event,events,world),Some{error})
    case owners result: (owners,result)

def op_completed(owners: Owners,result: Sys.RunResult<S.Schema,S.Store,Unit,S.Notice,Op.Request,C.Failure,String,Op.runner>) -> Owners & Sys.Outcome<S.World(),C.Failure,Unit>:
  match owners result:
    case Owners{Occupied{events},Occupied{fast},Occupied{slow},Occupied{cf},Occupied{cs},Occupied{rf},Occupied{rs},_,+config,+reads}, Sys.Completed{new,Sys.Succeeded{world,+text}}: collect_result(Owners{Occupied{events},Occupied{fast},Occupied{slow},Occupied{cf},Occupied{cs},Occupied{rf},Occupied{rs},Occupied{new},config,reads},Sys.Succeeded{world,Unit{}})
    case Owners{Occupied{events},Occupied{fast},Occupied{slow},Occupied{cf},Occupied{cs},Occupied{rf},Occupied{rs},_,+config,+reads}, Sys.Completed{new,Sys.Failed{world,C.Failed{+text}}}: collect_result(Owners{Occupied{events},Occupied{fast},Occupied{slow},Occupied{cf},Occupied{cs},Occupied{rf},Occupied{rs},Occupied{new},config,reads},Sys.Failed{world,C.Failed{text}})
    case Owners{Occupied{events},Occupied{fast},Occupied{slow},Occupied{cf},Occupied{cs},Occupied{rf},Occupied{rs},_,+config,+reads}, Sys.RegistrationRejected{new,world,_}: (Owners{Occupied{events},Occupied{fast},Occupied{slow},Occupied{cf},Occupied{cs},Occupied{rf},Occupied{rs},Occupied{new},config,reads},Sys.Failed{world,C.Failed{"registration"}})
    case owners result: (owners,Sys.Failed{op_world(result),invalid("operation")})

def cf_completed(owners: Owners,result: Sys.RunResult<S.Schema,S.Store,Unit,S.Notice,C.ReadArgs,C.Failure,String,C.change_runner>) -> Owners & Sys.Outcome<S.World(),C.Failure,Unit>:
  match owners result:
    case Owners{Occupied{events},Occupied{fast},Occupied{slow},_,Occupied{cs},Occupied{rf},Occupied{rs},Occupied{operation},+config,+reads}, Sys.Completed{new,Sys.Succeeded{world,+text}}: collect_result(Owners{Occupied{events},Occupied{fast},Occupied{slow},Occupied{new},Occupied{cs},Occupied{rf},Occupied{rs},Occupied{operation},config,append_read(reads,text)},Sys.Succeeded{world,Unit{}})
    case Owners{Occupied{events},Occupied{fast},Occupied{slow},_,Occupied{cs},Occupied{rf},Occupied{rs},Occupied{operation},+config,+reads}, Sys.Completed{new,Sys.Failed{world,C.Failed{+text}}}: collect_result(Owners{Occupied{events},Occupied{fast},Occupied{slow},Occupied{new},Occupied{cs},Occupied{rf},Occupied{rs},Occupied{operation},config,append_read(reads,text)},Sys.Failed{world,C.Failed{text}})
    case Owners{Occupied{events},Occupied{fast},Occupied{slow},_,Occupied{cs},Occupied{rf},Occupied{rs},Occupied{operation},+config,+reads}, Sys.RegistrationRejected{new,world,_}: (Owners{Occupied{events},Occupied{fast},Occupied{slow},Occupied{new},Occupied{cs},Occupied{rf},Occupied{rs},Occupied{operation},config,reads},Sys.Failed{world,C.Failed{"registration"}})
    case owners result: (owners,Sys.Failed{change_world(result),invalid("change-fast")})

def cs_completed(owners: Owners,result: Sys.RunResult<S.Schema,S.Store,Unit,S.Notice,C.ReadArgs,C.Failure,String,C.change_runner>) -> Owners & Sys.Outcome<S.World(),C.Failure,Unit>:
  match owners result:
    case Owners{Occupied{events},Occupied{fast},Occupied{slow},Occupied{cf},_,Occupied{rf},Occupied{rs},Occupied{operation},+config,+reads}, Sys.Completed{new,Sys.Succeeded{world,+text}}: collect_result(Owners{Occupied{events},Occupied{fast},Occupied{slow},Occupied{cf},Occupied{new},Occupied{rf},Occupied{rs},Occupied{operation},config,append_read(reads,text)},Sys.Succeeded{world,Unit{}})
    case Owners{Occupied{events},Occupied{fast},Occupied{slow},Occupied{cf},_,Occupied{rf},Occupied{rs},Occupied{operation},+config,+reads}, Sys.Completed{new,Sys.Failed{world,C.Failed{+text}}}: collect_result(Owners{Occupied{events},Occupied{fast},Occupied{slow},Occupied{cf},Occupied{new},Occupied{rf},Occupied{rs},Occupied{operation},config,append_read(reads,text)},Sys.Failed{world,C.Failed{text}})
    case Owners{Occupied{events},Occupied{fast},Occupied{slow},Occupied{cf},_,Occupied{rf},Occupied{rs},Occupied{operation},+config,+reads}, Sys.RegistrationRejected{new,world,_}: (Owners{Occupied{events},Occupied{fast},Occupied{slow},Occupied{cf},Occupied{new},Occupied{rf},Occupied{rs},Occupied{operation},config,reads},Sys.Failed{world,C.Failed{"registration"}})
    case owners result: (owners,Sys.Failed{change_world(result),invalid("change-slow")})

def event_detached(which: Bool,owners: Owners,new: EventOwner,+text: String,error: Maybe<&2,C.Failure>,result: D.Detached<S.Schema,S.Store,Unit,S.Notice>) -> Owners & Sys.Outcome<S.World(),C.Failure,Unit>:
  match which owners:
    case True{} Owners{_,_,Occupied{slow},Occupied{cf},Occupied{cs},Occupied{rf},Occupied{rs},Occupied{operation},+config,+reads}: refreshed(Owners{Empty{},Occupied{new},Occupied{slow},Occupied{cf},Occupied{cs},Occupied{rf},Occupied{rs},Occupied{operation},config,append_read(reads,text)},result,error)
    case False{} Owners{_,Occupied{fast},_,Occupied{cf},Occupied{cs},Occupied{rf},Occupied{rs},Occupied{operation},+config,+reads}: refreshed(Owners{Empty{},Occupied{fast},Occupied{new},Occupied{cf},Occupied{cs},Occupied{rf},Occupied{rs},Occupied{operation},config,append_read(reads,text)},result,error)
    case _ owners: match result:
      case D.Detached{world,_}: (owners,Sys.Failed{world,invalid("event")})

def event_completed(which: Bool,owners: Owners,+removals: List<&2,S.Notice>,result: Ev.RunResult<S.Schema,S.Store,Unit,S.Notice,C.ReadArgs,C.Failure,String,C.event_body>) -> Owners & Sys.Outcome<S.World(),C.Failure,Unit>:
  match result:
    case Ev.Ran{runtime,reader,registry,Ev.Succeeded{+text}}: event_detached(which,owners,EventOwner{reader,registry},text,None{},D.recover(~S.Schema,~S.Store,~Unit,~S.Notice,~S.is_event,runtime,removals))
    case Ev.Ran{runtime,reader,registry,Ev.Failed{C.Failed{+text}}}: event_detached(which,owners,EventOwner{reader,registry},text,Some{C.Failed{text}},D.recover(~S.Schema,~S.Store,~Unit,~S.Notice,~S.is_event,runtime,removals))
    case Ev.Ran{runtime,reader,registry,Ev.Rejected{_}}: event_detached(which,owners,EventOwner{reader,registry},"registration",Some{C.Failed{"registration"}},D.recover(~S.Schema,~S.Store,~Unit,~S.Notice,~S.is_event,runtime,removals))
def event_args(config: Config,+name: String) -> C.ReadArgs:
  match config:
    case Config{_,fail,_,_,_}: C.ReadArgs{name,fail,False{},0}
def event_read(which: Bool,owners: Owners,observed: S.World() & List<&2,S.Notice>) -> Owners & Sys.Outcome<S.World(),C.Failure,Unit>:
  match which owners observed:
    case True{} Owners{Occupied{events},Occupied{EventOwner{reader,registry}},Occupied{slow},Occupied{cf},Occupied{cs},Occupied{rf},Occupied{rs},Occupied{operation},+config,+reads}, (world,+removals): event_completed(True{},Owners{Empty{},Empty{},Occupied{slow},Occupied{cf},Occupied{cs},Occupied{rf},Occupied{rs},Occupied{operation},config,reads},removals,Ev.run(~S.Schema,~S.Store,~Unit,~S.Notice,~C.ReadArgs,~C.Failure,~String,~C.event_body,D.attach(~S.Schema,~S.Store,~Unit,~S.Notice,events,world),reader,registry,event_args(config,"event-fast")))
    case False{} Owners{Occupied{events},Occupied{fast},Occupied{EventOwner{reader,registry}},Occupied{cf},Occupied{cs},Occupied{rf},Occupied{rs},Occupied{operation},+config,+reads}, (world,+removals): event_completed(False{},Owners{Empty{},Occupied{fast},Empty{},Occupied{cf},Occupied{cs},Occupied{rf},Occupied{rs},Occupied{operation},config,reads},removals,Ev.run(~S.Schema,~S.Store,~Unit,~S.Notice,~C.ReadArgs,~C.Failure,~String,~C.event_body,D.attach(~S.Schema,~S.Store,~Unit,~S.Notice,events,world),reader,registry,event_args(config,"event-slow")))

    case _ owners, (world,_): (owners,Sys.Failed{world,invalid("event-read")})

def removal_rejoined(which: Bool,owners: Owners,reader: RemovalReader(),world: S.World(),+text: String,fail: Bool) -> Owners & Sys.Outcome<S.World(),C.Failure,Unit>:
  match which owners:
    case True{} Owners{Occupied{events},Occupied{fast},Occupied{slow},Occupied{cf},Occupied{cs},_,Occupied{rs},Occupied{operation},+config,+reads}: collect_result(Owners{Occupied{events},Occupied{fast},Occupied{slow},Occupied{cf},Occupied{cs},Occupied{reader},Occupied{rs},Occupied{operation},config,append_read(reads,text)},as_unit(C.finish(world,text,fail)))
    case False{} Owners{Occupied{events},Occupied{fast},Occupied{slow},Occupied{cf},Occupied{cs},Occupied{rf},_,Occupied{operation},+config,+reads}: collect_result(Owners{Occupied{events},Occupied{fast},Occupied{slow},Occupied{cf},Occupied{cs},Occupied{rf},Occupied{reader},Occupied{operation},config,append_read(reads,text)},as_unit(C.finish(world,text,fail)))
    case _ owners: (owners,Sys.Failed{world,invalid("removal")})

def removal_finished(which: Bool,+name: String,owners: Owners,result: Rm.Run<S.Schema,S.Store,Unit,S.Notice,S.AllToken,C.select,String,String>) -> Owners & Sys.Outcome<S.World(),C.Failure,Unit>:
  match result:
    case Rm.Completed{reader,Sys.Succeeded{world,+text}}: removal_rejoined(which,owners,reader,world,"{\"kind\":\"removal\",\"name\":" ++ C.quoted(name) ++ "," ++ text ++ "}",False{})
    case Rm.Completed{reader,Sys.Failed{world,+text}}: removal_rejoined(which,owners,reader,world,"{\"kind\":\"removal\",\"name\":" ++ C.quoted(name) ++ "," ++ text ++ "}",True{})
    case Rm.Invalid{reader,world}: removal_rejoined(which,owners,reader,world,"removal-invalid",True{})
def removal_execute(which: Bool,+name: String,owners: Owners,reader: RemovalReader(),world: S.World(),fail: Bool) -> Owners & Sys.Outcome<S.World(),C.Failure,Unit>:
  match fail:
    case True{}: removal_finished(which,name,owners,Rm.run(~S.Schema,~S.Store,~Unit,~S.Notice,~S.AllToken,~C.select,~String,~String,~C.removal_fail,reader,world))
    case False{}: removal_finished(which,name,owners,Rm.run(~S.Schema,~S.Store,~Unit,~S.Notice,~S.AllToken,~C.select,~String,~String,~C.removal_success,reader,world))
def removal_config(config: Config) -> Bool:
  match config:
    case Config{_,_,_,fail,_}: fail
def change_args(config: Config,+name: String,+cursor: U32) -> C.ReadArgs:
  match config:
    case Config{_,_,fail,_,own}: C.ReadArgs{name,fail,own,cursor}
def config_request(config: Config) -> Op.Request:
  match config:
    case Config{request,_,_,_,_}: request
def change_run(which: Bool,owners: Owners,world: S.World(),identified: ChangeRegistry() & U32) -> Owners & Sys.Outcome<S.World(),C.Failure,Unit>:
  match which owners identified:
    case True{} Owners{Occupied{events},Occupied{fast},Occupied{slow},_,Occupied{cs},Occupied{rf},Occupied{rs},Occupied{operation},+config,+reads}, (registry,+cursor): cf_completed(Owners{Occupied{events},Occupied{fast},Occupied{slow},Empty{},Occupied{cs},Occupied{rf},Occupied{rs},Occupied{operation},config,reads},Sys.run_tracked(~S.Schema,~S.Store,~Unit,~S.Notice,~C.ReadArgs,~C.Failure,~String,~C.change_runner,registry,world,change_args(config,"change-fast",cursor)))
    case False{} Owners{Occupied{events},Occupied{fast},Occupied{slow},Occupied{cf},_,Occupied{rf},Occupied{rs},Occupied{operation},+config,+reads}, (registry,+cursor): cs_completed(Owners{Occupied{events},Occupied{fast},Occupied{slow},Occupied{cf},Empty{},Occupied{rf},Occupied{rs},Occupied{operation},config,reads},Sys.run_tracked(~S.Schema,~S.Store,~Unit,~S.Notice,~C.ReadArgs,~C.Failure,~String,~C.change_runner,registry,world,change_args(config,"change-slow",cursor)))
    case _ owners _: (owners,Sys.Failed{world,invalid("change-run")})

def dispatch_value(owners: Owners,world: S.World(),id: U32) -> Owners & Sys.Outcome<S.World(),C.Failure,Unit>:
  match owners id:
    case owners 4: event_read(True{},owners,W.events_view(~S.Schema,~S.Store,~Unit,~S.Notice,world))
    case owners 5: event_read(False{},owners,W.events_view(~S.Schema,~S.Store,~Unit,~S.Notice,world))
    case Owners{Occupied{events},Occupied{fast},Occupied{slow},Occupied{cf},Occupied{cs},Occupied{rf},Occupied{rs},Occupied{operation},+config,+reads} 6: change_run(True{},Owners{Occupied{events},Occupied{fast},Occupied{slow},Empty{},Occupied{cs},Occupied{rf},Occupied{rs},Occupied{operation},config,reads},world,Sys.cursor(~S.Schema,~S.Store,~Unit,~S.Notice,~C.ReadArgs,~C.Failure,~String,~C.change_runner,cf))
    case Owners{Occupied{events},Occupied{fast},Occupied{slow},Occupied{cf},Occupied{cs},Occupied{rf},Occupied{rs},Occupied{operation},+config,+reads} 7: change_run(False{},Owners{Occupied{events},Occupied{fast},Occupied{slow},Occupied{cf},Empty{},Occupied{rf},Occupied{rs},Occupied{operation},config,reads},world,Sys.cursor(~S.Schema,~S.Store,~Unit,~S.Notice,~C.ReadArgs,~C.Failure,~String,~C.change_runner,cs))
    case Owners{Occupied{events},Occupied{fast},Occupied{slow},Occupied{cf},Occupied{cs},Occupied{rf},Occupied{rs},Occupied{operation},+config,+reads} 8: removal_execute(True{},"removal-fast",Owners{Occupied{events},Occupied{fast},Occupied{slow},Occupied{cf},Occupied{cs},Empty{},Occupied{rs},Occupied{operation},config,reads},rf,world,removal_config(config))
    case Owners{Occupied{events},Occupied{fast},Occupied{slow},Occupied{cf},Occupied{cs},Occupied{rf},Occupied{rs},Occupied{operation},+config,+reads} 9: removal_execute(False{},"removal-slow",Owners{Occupied{events},Occupied{fast},Occupied{slow},Occupied{cf},Occupied{cs},Occupied{rf},Empty{},Occupied{operation},config,reads},rs,world,removal_config(config))
    case Owners{Occupied{events},Occupied{fast},Occupied{slow},Occupied{cf},Occupied{cs},Occupied{rf},Occupied{rs},Occupied{operation},+config,+reads} _: op_completed(Owners{Occupied{events},Occupied{fast},Occupied{slow},Occupied{cf},Occupied{cs},Occupied{rf},Occupied{rs},Empty{},config,reads},Sys.run(~S.Schema,~S.Store,~Unit,~S.Notice,~Op.Request,~C.Failure,~String,~Op.runner,operation,world,config_request(config)))
    case owners _: (owners,Sys.Failed{world,invalid("dispatch")})

def domain_dispatch(events: D.Events<S.Schema,S.Notice>,args: Owners & U32,world: S.World()) -> Owners & Sys.Outcome<S.World(),C.Failure,Unit>:
  match args:
    case (Owners{_,fast,slow,cf,cs,rf,rs,op,config,reads},id): dispatch_value(Owners{Occupied{events},fast,slow,cf,cs,rf,rs,op,config,reads},world,id)
def dispatch(owners: Owners,world: S.World(),id: U32) -> Owners & Sys.Outcome<S.World(),C.Failure,Unit>:
  match owners:
    case Owners{Occupied{events},fast,slow,cf,cs,rf,rs,op,config,reads}: D.drive(~S.Schema,~S.Store,~Unit,~S.Notice,~(Owners & U32),~(Owners & Sys.Outcome<S.World(),C.Failure,Unit>),~S.is_event,~domain_dispatch,events,(Owners{Empty{},fast,slow,cf,cs,rf,rs,op,config,reads},id),world)
    case owners: (owners,Sys.Failed{world,invalid("dispatch-domain")})

def skipped_detached(owners: Owners,registry: EventRegistry(),reader: Ev.Reader<S.Schema>,result: D.Detached<S.Schema,S.Store,Unit,S.Notice>) -> Owners & S.World():
  match owners result:
    case Owners{_,_,Occupied{slow},Occupied{cf},Occupied{cs},Occupied{rf},Occupied{rs},Occupied{op},+config,+reads}, D.Detached{world,events}: (Owners{Occupied{events},Occupied{EventOwner{reader,registry}},Occupied{slow},Occupied{cf},Occupied{cs},Occupied{rf},Occupied{rs},Occupied{op},config,reads},world)
    case owners D.Detached{world,_}: (owners,world)

def skipped_runtime(owners: Owners,registry: EventRegistry(),+removals: List<&2,S.Notice>,result: Ev.Runtime<S.Schema,S.Store,Unit,S.Notice> & Ev.Reader<S.Schema>) -> Owners & S.World():
  (runtime,reader) = result
  skipped_detached(owners,registry,reader,D.detach(~S.Schema,~S.Store,~Unit,~S.Notice,runtime,removals))
def skip_event(owners: Owners,observed: S.World() & List<&2,S.Notice>) -> Owners & S.World():
  match owners observed:
    case Owners{Occupied{events},Occupied{EventOwner{reader,registry}},Occupied{slow},Occupied{cf},Occupied{cs},Occupied{rf},Occupied{rs},Occupied{op},+config,+reads}, (world,+removals): skipped_runtime(Owners{Empty{},Empty{},Occupied{slow},Occupied{cf},Occupied{cs},Occupied{rf},Occupied{rs},Occupied{op},config,reads},registry,removals,Ev.skip(~S.Schema,~S.Store,~Unit,~S.Notice,D.attach(~S.Schema,~S.Store,~Unit,~S.Notice,events,world),reader))
    case owners, (world,_): (owners,world)

def skip_collected(owners: Owners,result: D.Detached<S.Schema,S.Store,Unit,S.Notice>) -> Owners & S.World():
  match owners result:
    case Owners{_,fast,slow,cf,cs,rf,rs,op,config,reads}, D.Detached{world,events}: skip_event(Owners{Occupied{events},fast,slow,cf,cs,rf,rs,op,config,reads},W.events_view(~S.Schema,~S.Store,~Unit,~S.Notice,world))
def skip(owners: Owners,world: S.World(),id: U32) -> Owners & S.World():
  match owners id:
    case Owners{Occupied{events},fast,slow,cf,cs,rf,rs,op,config,reads} 4: skip_collected(Owners{Empty{},fast,slow,cf,cs,rf,rs,op,config,reads},D.collect(~S.Schema,~S.Store,~Unit,~S.Notice,~S.is_event,events,world))
    case owners _: (owners,world)
def framed(owners: Owners,result: D.Detached<S.Schema,S.Store,Unit,S.Notice>) -> Host:
  match owners result:
    case Owners{_,Occupied{fast},Occupied{slow},Occupied{cf},Occupied{cs},Occupied{rf},Occupied{rs},Occupied{op},+config,_}, D.Detached{world,events}: Host{world,Owners{Occupied{events},Occupied{fast},Occupied{slow},Occupied{cf},Occupied{cs},Occupied{rf},Occupied{rs},Occupied{op},config,[]}}
    case owners D.Detached{world,_}: Host{world,owners}

def frame_observed(owners: Owners,observed: S.World() & List<&2,S.Notice>) -> Host:
  match owners observed:
    case Owners{Occupied{events},Occupied{fast},Occupied{slow},Occupied{cf},Occupied{cs},Occupied{rf},Occupied{rs},Occupied{op},+config,+reads}, (world,+removals): framed(Owners{Empty{},Occupied{fast},Occupied{slow},Occupied{cf},Occupied{cs},Occupied{rf},Occupied{rs},Occupied{op},config,reads},D.detach(~S.Schema,~S.Store,~Unit,~S.Notice,Ev.frame(~S.Schema,~S.Store,~Unit,~S.Notice,D.attach(~S.Schema,~S.Store,~Unit,~S.Notice,events,world)),removals))
    case owners, (world,_): Host{world,owners}

def frame_collected(owners: Owners,result: D.Detached<S.Schema,S.Store,Unit,S.Notice>) -> Host:
  match owners result:
    case Owners{_,fast,slow,cf,cs,rf,rs,op,config,reads}, D.Detached{world,events}: frame_observed(Owners{Occupied{events},fast,slow,cf,cs,rf,rs,op,config,reads},W.events_view(~S.Schema,~S.Store,~Unit,~S.Notice,world))
def frame(host: Host) -> Host:
  match host:
    case Host{world,Owners{Occupied{events},fast,slow,cf,cs,rf,rs,op,config,reads}}: frame_collected(Owners{Empty{},fast,slow,cf,cs,rf,rs,op,config,reads},D.collect(~S.Schema,~S.Store,~Unit,~S.Notice,~S.is_event,events,world))
    case host: host
def returned_collected(owners: Owners,+ok: Bool,result: D.Detached<S.Schema,S.Store,Unit,S.Notice>) -> Host & Bool:
  match owners result:
    case Owners{_,fast,slow,cf,cs,rf,rs,op,config,reads}, D.Detached{world,events}: (Host{world,Owners{Occupied{events},fast,slow,cf,cs,rf,rs,op,config,reads}},ok)
def returned(owners: Owners,world: S.World(),+ok: Bool) -> Host & Bool:
  match owners:
    case Owners{Occupied{events},fast,slow,cf,cs,rf,rs,op,config,reads}: returned_collected(Owners{Empty{},fast,slow,cf,cs,rf,rs,op,config,reads},ok,D.collect(~S.Schema,~S.Store,~Unit,~S.Notice,~S.is_event,events,world))
    case owners: (Host{world,owners},ok)
def run_result(result: Sch.RunResult<S.Schema,S.Store,Unit,S.Notice,Owners,C.Failure>) -> Host & Bool:
  match result:
    case Sch.Finished{Sch.Schedule{_,_,_,owners},world,_}: returned(owners,world,True{})
    case Sch.Failed{Sch.Schedule{_,_,_,owners},world,_,_}: returned(owners,world,False{})
    case Sch.Rejected{Sch.Schedule{_,_,_,owners},world}: returned(owners,world,False{})
def built(world: S.World(),result: Sch.Build<S.Schema,S.Store,Unit,S.Notice,Owners>) -> Host & Bool:
  match result:
    case Sch.Built{schedule}: run_result(Sch.run_with_skip(~S.Schema,~S.Store,~Unit,~S.Notice,~Owners,~C.Failure,~skip,~dispatch,~Op.condition,schedule,world))
    case Sch.Invalid{owners}: (Host{world,owners},False{})
def build_named(owners: Owners,+steps: List<&2,Sch.Step>,named: S.World() & U32) -> Host & Bool:
  (world,+namespace) = named
  built(world,Sch.build(~S.Schema,~S.Store,~Unit,~S.Notice,~Owners,namespace,"reader-tick",steps,[1,2,3,4,5,6,7,8,9],owners))
def tick(host: Host,+steps: List<&2,Sch.Step>) -> Host & Bool:
  match host:
    case Host{world,owners}: build_named(owners,steps,W.namespace(~S.Schema,~S.Store,~Unit,~S.Notice,world))

def init_detached(fast: EventOwner,slow: EventOwner,cf: ChangeRegistry(),cs: ChangeRegistry(),rf: RemovalReader(),rs: RemovalReader(),op: OpRegistry(),result: D.Detached<S.Schema,S.Store,Unit,S.Notice>) -> Maybe<&1,Host>:
  match result:
    case D.Detached{world,events}: Some{Host{world,Owners{Occupied{events},Occupied{fast},Occupied{slow},Occupied{cf},Occupied{cs},Occupied{rf},Occupied{rs},Occupied{op},Config{Op.Request{4,0,0,None{},False{}},False{},False{},False{},False{}},[]}}}
def init_removal_slow(events: D.Events<S.Schema,S.Notice>,fast: EventOwner,slow: EventOwner,cf: ChangeRegistry(),cs: ChangeRegistry(),rf: RemovalReader(),op: OpRegistry(),result: Rm.Registered<S.Schema,S.Store,Unit,S.Notice,S.AllToken,C.select>) -> Maybe<&1,Host>:
  match result:
    case Rm.Registered{world,rs}: Some{Host{world,Owners{Occupied{events},Occupied{fast},Occupied{slow},Occupied{cf},Occupied{cs},Occupied{rf},Occupied{rs},Occupied{op},Config{Op.Request{4,0,0,None{},False{}},False{},False{},False{},False{}},[]}}}
    case _: None{}
def init_removal_fast(events: D.Events<S.Schema,S.Notice>,fast: EventOwner,slow: EventOwner,cf: ChangeRegistry(),cs: ChangeRegistry(),op: OpRegistry(),result: Rm.Registered<S.Schema,S.Store,Unit,S.Notice,S.AllToken,C.select>) -> Maybe<&1,Host>:
  match result:
    case Rm.Registered{world,rf}: init_removal_slow(events,fast,slow,cf,cs,rf,op,Rm.register(~S.Schema,~S.Store,~Unit,~S.Notice,~S.AllToken,~C.select,world,"removal-slow"))
    case _: None{}
def init_changes_detached(fast: EventOwner,slow: EventOwner,cf: ChangeRegistry(),cs: ChangeRegistry(),op: OpRegistry(),result: D.Detached<S.Schema,S.Store,Unit,S.Notice>) -> Maybe<&1,Host>:
  match result:
    case D.Detached{world,events}: init_removal_fast(events,fast,slow,cf,cs,op,Rm.register(~S.Schema,~S.Store,~Unit,~S.Notice,~S.AllToken,~C.select,world,"removal-fast"))
def init_change_slow(runtime: D.Events<S.Schema,S.Notice>,fast: EventOwner,slow: EventOwner,cf: ChangeRegistry(),op: OpRegistry(),result: Sys.RegistrationResult<S.Schema,S.Store,Unit,S.Notice,C.ReadArgs,C.Failure,String,C.change_runner>) -> Maybe<&1,Host>:
  match runtime result:
    case D.Events{ns,batches,positions,next,tick,start,boundary,capacity,dropped,_}, Sys.Registered{world,cs}: init_changes_detached(fast,slow,cf,cs,op,D.detach(~S.Schema,~S.Store,~Unit,~S.Notice,Ev.Runtime{world,ns,batches,positions,next,tick,start,boundary,capacity,dropped},[]))
    case _ _: None{}
def init_change_fast(runtime: D.Events<S.Schema,S.Notice>,fast: EventOwner,slow: EventOwner,op: OpRegistry(),result: Sys.RegistrationResult<S.Schema,S.Store,Unit,S.Notice,C.ReadArgs,C.Failure,String,C.change_runner>) -> Maybe<&1,Host>:
  match result:
    case Sys.Registered{world,cf}: init_change_slow(runtime,fast,slow,cf,op,Sys.register(~S.Schema,~S.Store,~Unit,~S.Notice,~C.ReadArgs,~C.Failure,~String,~C.change_runner,world,"change-slow",["Stock.write","Stock.changed"]))
    case _: None{}
def init_operation(runtime: D.Events<S.Schema,S.Notice>,fast: EventOwner,slow: EventOwner,result: Sys.RegistrationResult<S.Schema,S.Store,Unit,S.Notice,Op.Request,C.Failure,String,Op.runner>) -> Maybe<&1,Host>:
  match result:
    case Sys.Registered{world,op}: init_change_fast(runtime,fast,slow,op,Sys.register(~S.Schema,~S.Store,~Unit,~S.Notice,~C.ReadArgs,~C.Failure,~String,~C.change_runner,world,"change-fast",["Stock.write","Stock.changed"]))
    case _: None{}
def init_event_slow(fast: EventOwner,result: Ev.Registered<S.Schema,S.Store,Unit,S.Notice,C.ReadArgs,C.Failure,String,C.event_body>) -> Maybe<&1,Host>:
  match result:
    case Ev.Registered{Ev.Runtime{world,+ns,+batches,+positions,+next,+tick,+start,+boundary,+capacity,+dropped},reader,registry}: init_operation(D.Events{ns,batches,positions,next,tick,start,boundary,capacity,dropped,[]},fast,EventOwner{reader,registry},Sys.register(~S.Schema,~S.Store,~Unit,~S.Notice,~Op.Request,~C.Failure,~String,~Op.runner,world,"operations",["Ping.write","Stock.insert","Stock.remove","Aux.remove","despawn","spawn"]))
    case _: None{}
def init_event_fast(result: Ev.Registered<S.Schema,S.Store,Unit,S.Notice,C.ReadArgs,C.Failure,String,C.event_body>) -> Maybe<&1,Host>:
  match result:
    case Ev.Registered{runtime,reader,registry}: init_event_slow(EventOwner{reader,registry},Ev.register(~S.Schema,~S.Store,~Unit,~S.Notice,~C.ReadArgs,~C.Failure,~String,~C.event_body,runtime,"event-slow",["Ping.read"]))
    case _: None{}
def init_created(result: W.Creation<S.Schema,S.Store,Unit,S.Notice>) -> Maybe<&1,Host>:
  match result:
    case W.Created{_,world}: init_event_fast(Ev.register(~S.Schema,~S.Store,~Unit,~S.Notice,~C.ReadArgs,~C.Failure,~String,~C.event_body,Ev.start(~S.Schema,~S.Store,~Unit,~S.Notice,world,65536n),"event-fast",["Ping.read"]))
    case _: None{}

def snapshot_events(+label: String,+ok: Bool,owners: Owners,+rows: List<&2,String>,observed: D.Events<S.Schema,S.Notice> & (String & String),world: S.World()) -> Host & String:
  match owners observed:
    case Owners{_,Occupied{fast},Occupied{slow},Occupied{cf},Occupied{cs},Occupied{rf},Occupied{rs},Occupied{op},+config,+reads}, (events,(values,statuses)): (Host{world,Owners{Occupied{events},Occupied{fast},Occupied{slow},Occupied{cf},Occupied{cs},Occupied{rf},Occupied{rs},Occupied{op},config,reads}},"{\"label\":" ++ C.quoted(label) ++ ",\"ok\":" ++ C.boolean(ok) ++ ",\"reads\":" ++ C.array(reads) ++ ",\"entities\":" ++ C.array(rows) ++ ",\"events\":" ++ values ++ ",\"readers\":" ++ statuses ++ "}")
    case owners _: (Host{world,owners},"{\"invalidSlot\":true}")

def snapshot_rows(+label: String,+ok: Bool,owners: Owners,observed: S.World() & List<&2,String>) -> Host & String:
  match owners observed:
    case Owners{Occupied{events},Occupied{fast},Occupied{slow},Occupied{cf},Occupied{cs},Occupied{rf},Occupied{rs},Occupied{op},+config,+reads}, (world,+rows): snapshot_events(label,ok,Owners{Empty{},Occupied{fast},Occupied{slow},Occupied{cf},Occupied{cs},Occupied{rf},Occupied{rs},Occupied{op},config,reads},rows,Obs.event_observation(events),world)
    case owners, (world,_): (Host{world,owners},"{\"invalidSlot\":true}")

def snapshot(+label: String,observed: Host & Bool) -> Host & String:
  match observed:
    case (Host{world,owners},+ok): snapshot_rows(label,ok,owners,Obs.all(world))
type Step is Data:
  Step{label: String,enabled: Bool,config: Config,steps: List<&2,Sch.Step>}
def configure(host: Host,+enabled: Bool,+config: Config) -> Host:
  match host:
    case Host{world,Owners{Occupied{events},Occupied{fast},Occupied{slow},Occupied{cf},Occupied{cs},Occupied{rf},Occupied{rs},Occupied{op},_,+reads}}: Host{Op.condition_set(world,enabled),Owners{Occupied{events},Occupied{fast},Occupied{slow},Occupied{cf},Occupied{cs},Occupied{rf},Occupied{rs},Occupied{op},config,reads}}
    case Host{world,owners}: Host{world,owners}

def advance(+previous: List<&2,String>,observed: Host & String,next: Host -> List<&2,String> -> List<&2,String>) -> List<&2,String>:
  (host,+value) = observed
  next(host,List.append(&2,String,previous,[value]))
def execute(steps: List<&2,Step>,host: Host,+previous: List<&2,String>) -> List<&2,String>:
  match steps:
    case []: previous
    case Step{+label,+enabled,+config,+plan} <> rest: advance(previous,snapshot(label,tick(frame(configure(host,enabled,config)),plan)),host => rows => execute(rest,host,rows))
def scenario(host: Host) -> List<&2,String>:
  execute([
    Step{"seed",True{},Config{Op.Request{4,0,0,None{},False{}},False{},False{},False{},False{}},[Sch.System{1,1},Sch.Barrier{}]},
    Step{"register",True{},Config{Op.Request{1,0,0,None{},False{}},False{},False{},False{},False{}},[Sch.System{4,0},Sch.System{5,1},Sch.System{6,0},Sch.System{7,1},Sch.System{8,0},Sch.System{9,1}]},
    Step{"publish-pending",True{},Config{Op.Request{1,1,1,Some{2},False{}},False{},False{},False{},False{}},[Sch.System{1,1},Sch.System{4,0},Sch.System{6,0},Sch.System{8,0}]},
    Step{"skip-all",False{},Config{Op.Request{2,0,0,None{},False{}},False{},False{},False{},False{}},[Sch.System{2,1},Sch.System{4,0},Sch.System{6,0},Sch.System{8,0}]},
    Step{"barrier-skipped",False{},Config{Op.Request{1,0,0,None{},False{}},False{},False{},False{},False{}},[Sch.Barrier{},Sch.System{4,0},Sch.System{6,0},Sch.System{8,0}]},
    Step{"resume-fast",True{},Config{Op.Request{1,0,0,None{},False{}},False{},False{},False{},False{}},[Sch.System{4,0},Sch.System{6,0},Sch.System{8,0}]},
    Step{"event-fail",True{},Config{Op.Request{1,0,0,None{},False{}},True{},False{},False{},False{}},[Sch.System{5,1}]},
    Step{"event-retry",True{},Config{Op.Request{1,0,0,None{},False{}},False{},False{},False{},False{}},[Sch.System{5,1}]},
    Step{"change-fail-own-write",True{},Config{Op.Request{1,0,0,None{},False{}},False{},True{},False{},True{}},[Sch.System{7,1}]},
    Step{"change-retry-own-write",True{},Config{Op.Request{1,0,0,None{},False{}},False{},False{},False{},True{}},[Sch.System{7,1}]},
    Step{"change-own-write-consumed",True{},Config{Op.Request{1,0,0,None{},False{}},False{},False{},False{},True{}},[Sch.System{7,1}]},
    Step{"churn-pending",True{},Config{Op.Request{3,0,0,None{},False{}},False{},False{},False{},False{}},[Sch.System{3,1},Sch.System{8,0}]},
    Step{"churn-visible",True{},Config{Op.Request{1,0,0,None{},False{}},False{},False{},False{},False{}},[Sch.Barrier{}]},
    Step{"removal-fail",True{},Config{Op.Request{1,0,0,None{},False{}},False{},False{},True{},False{}},[Sch.System{9,1}]},
    Step{"removal-retry",True{},Config{Op.Request{1,0,0,None{},False{}},False{},False{},False{},False{}},[Sch.System{9,1}]},
    Step{"removal-consumed",True{},Config{Op.Request{1,0,0,None{},False{}},False{},False{},False{},False{}},[Sch.System{9,1}]},
    Step{"earlier-commit",True{},Config{Op.Request{1,3,1,None{},False{}},False{},False{},False{},False{}},[Sch.System{1,1}]},
    Step{"failed-publisher",True{},Config{Op.Request{1,999,1,None{},True{}},False{},False{},False{},False{}},[Sch.System{1,1},Sch.Barrier{},Sch.System{4,0}]},
    Step{"earlier-command-survives",True{},Config{Op.Request{1,0,0,None{},False{}},False{},False{},False{},False{}},[Sch.Barrier{},Sch.System{4,0},Sch.System{8,0}]},
    Step{"publisher-retry",True{},Config{Op.Request{1,4,1,None{},False{}},False{},False{},False{},False{}},[Sch.System{1,1},Sch.System{5,1}]},
    Step{"lag-batch",True{},Config{Op.Request{1,7,65535,None{},False{}},False{},False{},False{},False{}},[Sch.System{1,1}]},
    Step{"lag-overflow",True{},Config{Op.Request{1,8,1,Some{9},False{}},False{},False{},False{},False{}},[Sch.System{1,1}]},
    Step{"lag-retention",True{},Config{Op.Request{1,0,0,None{},False{}},False{},False{},False{},False{}},[]},
    Step{"lag-readers",True{},Config{Op.Request{1,0,0,None{},False{}},False{},False{},False{},False{}},[Sch.System{4,0},Sch.System{5,1}]},
    Step{"after-lag",True{},Config{Op.Request{1,0,0,None{},False{}},False{},False{},False{},False{}},[]}
  ],host,[])
def ready(result: Maybe<&1,Host>) -> List<&2,String>:
  match result:
    case None{}: ["setup-failure"]
    case Some{host}: scenario(host)
def main() -> IO(Unit):
  IO.print("{\"format\":1,\"checkpoints\":" ++ C.array(ready(init_created(S.create(W.factory())))) ++ "}")
