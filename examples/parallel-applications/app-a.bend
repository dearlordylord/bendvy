import Base
import ./app-a-payloads.bend as P
import ./app-a-schema.bend as D
import ./app-a-commands.bend as Author
import ./app-a-bootstrap.bend as Bootstrap
import ./app-a-handoff.bend as Handoff
import ./app-a-events.bend as Events
import ./app-a-execution.bend as Gameplay
import ./app-a-systems.bend as Systems
import ../../src/ecs/world.bend as W
import ../../src/ecs/execution-relation-context.bend as Context
import ../../src/ecs/dependency-application.bend as State
import ../../src/ecs/execution-event-family.bend as Event
import ../../src/ecs/execution-event-io.bend as EventIO
import ../../src/ecs/execution-owner-continuation.bend as Continuation

type Control is Type:
  Control{on:Bool,factory:W.Factory}
type Running is Type:
  Running{application:Gameplay.Application(),bootstrap:Bootstrap.Retained,handoff:Handoff.State,target:W.Handle<P.AuditWorkshop>}
type SessionResult is Type:
  Completed{control:Control,running:Running}
  Refused{-Inventory:Type,inventory:Inventory,text:String}
def mode(on:Bool) -> String:
  match on:
    case False{}:"Off"
    case True{}:"On"
def refused(-Inventory:Type,inventory:Inventory,text:String) -> IO(SessionResult):
  IO.pure(SessionResult,Refused{Inventory,inventory,text})
def finished(control:Control,application:Gameplay.Application(),handoff:Handoff.State,target:W.Handle<P.AuditWorkshop>,result:Bootstrap.Retained & String) -> IO(SessionResult):
  match control result:
    case Control{+on,factory}, (bootstrap,text):IO.bind(Unit,SessionResult,IO.print("AppA " ++ mode(on) ++ " original three runs finished|retained-event-reader|" ++ text),_=>IO.pure(SessionResult,Completed{Control{on,factory},Running{application,bootstrap,handoff,target}}))
def finish(control:Control,running:Running) -> IO(SessionResult):
  match running:
    case Running{application,bootstrap,handoff,target}:finished(control,application,handoff,target,Bootstrap.retained_observed(bootstrap))
def inspected(label:String,next:Control -> Running -> IO(SessionResult),control:Control,bootstrap:Bootstrap.Retained,handoff:Handoff.State,target:W.Handle<P.AuditWorkshop>,result:Gameplay.Application() & String) -> IO(SessionResult):
  match result:
    case (application,text):IO.bind(Unit,SessionResult,IO.print(label ++ "|" ++ text),_=>next(control,Running{application,bootstrap,handoff,target}))
def ran(label:String,next:Control -> Running -> IO(SessionResult),control:Control,bootstrap:Bootstrap.Retained,handoff:Handoff.State,+target:W.Handle<P.AuditWorkshop>,result:Gameplay.Application() & State.Report<String,String>) -> IO(SessionResult):
  match result:
    case (application,report):inspected(label ++ "/" ++ Gameplay.report(report),next,control,bootstrap,handoff,target,Gameplay.snapshot(target,application))
def update(label:String,next:Control -> Running -> IO(SessionResult),control:Control,running:Running) -> IO(SessionResult):
  match control running:
    case Control{+on,factory}, Running{application,bootstrap,handoff,target}:IO.bind(Gameplay.Application() & State.Report<String,String>,SessionResult,Gameplay.run_mode(on,application),result=>ran("AppA " ++ mode(on) ++ " " ++ label,next,Control{on,factory},bootstrap,handoff,target,result))
def third(control:Control,running:Running) -> IO(SessionResult):update("run3",finish,control,running)
def second(control:Control,running:Running) -> IO(SessionResult):update("run2",third,control,running)
def gameplay_defined(control:Control,bootstrap:Bootstrap.Retained,handoff:Handoff.State,target:W.Handle<P.AuditWorkshop>,result:Gameplay.Definition) -> IO(SessionResult):
  match result:
    case Gameplay.Ready{application}:update("run1",second,control,Running{application,bootstrap,handoff,target})
    case Gameplay.RegistrationRefused{inventory}:refused(Control & (Bootstrap.Retained & (Handoff.State & Gameplay.Definition)),(control,(bootstrap,(handoff,Gameplay.RegistrationRefused{inventory}))),"gameplay-registration-refused")
    case Gameplay.GuardRefused{world,writer,query,reader,local}:refused(Control & (Bootstrap.Retained & (Handoff.State & Gameplay.Definition)),(control,(bootstrap,(handoff,Gameplay.GuardRefused{world,writer,query,reader,local}))),"gameplay-condition-registration-refused")
def gameplay_detached(control:Control,handoff:Handoff.State,+target:W.Handle<P.AuditWorkshop>,result:Systems.World() & Bootstrap.Retained) -> IO(SessionResult):
  match result:
    case (world,bootstrap):gameplay_defined(control,bootstrap,handoff,target,Gameplay.define(world,target))
def begin_gameplay(control:Control,handoff:Handoff.State,bound:Bootstrap.Bound()) -> IO(SessionResult):
  match handoff:
    case Handoff.State{Some{+target},records,output,loose,history,text}:gameplay_detached(control,Handoff.State{Some{target},records,output,loose,history,text},target,Bootstrap.detach(bound))
    case handoff:refused(Control & (Handoff.State & Bootstrap.Bound()),(control,(handoff,bound)),"gameplay-missing-target")
def handoff_observed(control:Control,handoff:Handoff.State,result:Bootstrap.Bound() & String) -> IO(SessionResult):
  match control result:
    case Control{+on,factory}, (bound,text):IO.bind(Unit,SessionResult,IO.print("AppA " ++ mode(on) ++ " owned handoff|" ++ text),_=>begin_gameplay(Control{on,factory},handoff,bound))
def handoff_ran(control:Control,handoff:Handoff.State,result:Bootstrap.Bound() & Context.RunReport<State.Report<String,String>>) -> IO(SessionResult):
  match result:
    case (bound,report):handoff_observed(control,handoff,Bootstrap.with_events(~String,Events.observed,bound))
def submitted(control:Control,handoff:Handoff.State,result:Bootstrap.Bound() & Maybe<Array<U32>>) -> IO(SessionResult):
  match handoff result:
    case Handoff.State{target,records,output,oldLoose,history,text}, (bound,loose):IO.bind(Bootstrap.Bound() & Context.RunReport<State.Report<String,String>>,SessionResult,Bootstrap.invoke(bound),result=>handoff_ran(control,Handoff.State{target,records,output,loose,history,text},result))
def recovered(control:Control,result:Bootstrap.Bound() & Handoff.State) -> IO(SessionResult):
  match control result:
    case Control{+on,factory}, (bound,Handoff.State{Some{+target},records,output,Some{payload},history,+text}):IO.bind(Unit,SessionResult,IO.print("AppA " ++ mode(on) ++ " recovery|" ++ text),_=>submitted(Control{on,factory},Handoff.State{Some{target},records,output,None{},history,text},Bootstrap.with_events(~Maybe<Array<U32>>,owners=>Events.accept(owners,target,payload),bound)))
    case control, (bound,Handoff.State{target,records,output,loose,history,+text}):refused(Control & (Bootstrap.Bound() & Handoff.State),(control,(bound,Handoff.State{target,records,output,loose,history,text})),"AppA recovery stopped|" ++ text)
def flushed(control:Control,bound:Bootstrap.Bound()) -> IO(SessionResult):
  recovered(control,Bootstrap.with_world(~Handoff.State,Handoff.begin(~Bootstrap.Resources()),Bootstrap.flush(bound)))
def queued(control:Control,result:Bootstrap.Bound() & Context.RunReport<State.Report<String,String>>) -> IO(SessionResult):
  match control result:
    case Control{+on,factory}, (bound,report):IO.bind(Unit,SessionResult,IO.print("AppA " ++ mode(on) ++ " bundle committed pending explicit flush"),_=>flushed(Control{on,factory},bound))
def defined(control:Control,result:Bootstrap.Definition) -> IO(SessionResult):
  match result:
    case Bootstrap.Ready{bound}:IO.bind(Bootstrap.Bound() & Context.RunReport<State.Report<String,String>>,SessionResult,Bootstrap.invoke(bound),result=>queued(control,result))
    case Bootstrap.AuthorRefused{context,world,local,reader}:refused(Control & Bootstrap.Definition,(control,Bootstrap.AuthorRefused{context,world,local,reader}),"author-registration-refused")
    case Bootstrap.PeerRefused{context,author,result}:refused(Control & Bootstrap.Definition,(control,Bootstrap.PeerRefused{context,author,result}),"boundary-registration-refused")
def created(on:Bool,reader:Events.Reader(),result:Context.Initialization<P.AuditWorkshop,D.components(),Author.resources(),Unit>) -> IO(SessionResult):
  match result:
    case Context.ContextCreated{factory,world,context}:defined(Control{on,factory},Bootstrap.define(context,world,reader))
    case Context.SchemaRefused{factory,owners,error}:refused(Events.Reader() & Context.Initialization<P.AuditWorkshop,D.components(),Author.resources(),Unit>,(reader,Context.SchemaRefused{factory,owners,error}),"schema-refused")
    case Context.NamespaceRefused{factory,owners}:refused(Events.Reader() & Context.Initialization<P.AuditWorkshop,D.components(),Author.resources(),Unit>,(reader,Context.NamespaceRefused{factory,owners}),"namespace-refused")
def event_registered(control:Control,result:Events.Family() & Event.Registration<P.AuditWorkshop,Array<U32>,"RecoveredCargoLog">) -> IO(SessionResult):
  match control result:
    case Control{on,factory}, (family,Event.Registered{reader}):created(on,reader,D.create(~Author.Receipts(),factory,D.Seed{[],family}))
    case control, inventory:refused(Control & (Events.Family() & Event.Registration<P.AuditWorkshop,Array<U32>,"RecoveredCargoLog">),(control,inventory),"event-reader-registration-refused")
def event_created(control:Control,result:Event.Creation<P.AuditWorkshop,Array<U32>,"RecoveredCargoLog">) -> IO(SessionResult):
  match result:
    case Event.Created{family}:event_registered(control,Event.register(~P.AuditWorkshop,~Array<U32>,~"RecoveredCargoLog",Event.Retained{},family))
    case inventory:refused(Control & Event.Creation<P.AuditWorkshop,Array<U32>,"RecoveredCargoLog">,(control,inventory),"event-family-creation-refused")
def session(on:Bool,factory:W.Factory) -> IO(SessionResult):
  IO.bind(Event.Creation<P.AuditWorkshop,Array<U32>,"RecoveredCargoLog">,SessionResult,EventIO.create(~P.AuditWorkshop,~Array<U32>,~"RecoveredCargoLog"),result=>event_created(Control{on,factory},result))
def running_rebuilt(handoff:Handoff.State,target:W.Handle<P.AuditWorkshop>,applicationResult:Gameplay.Application() & String,bootstrapResult:Bootstrap.Retained & String) -> Running & String:
  match applicationResult bootstrapResult:
    case (application,values), (bootstrap,events):(Running{application,bootstrap,handoff,target},values ++ ";retained-event-reader={" ++ events ++ "}")
def running_observed(running:Running) -> Running & String:
  match running:
    case Running{application,bootstrap,handoff,+target}:running_rebuilt(handoff,target,Gameplay.snapshot(target,application),Bootstrap.retained_observed(bootstrap))
def both_observed(control:Control,offResult:Running & String,onResult:Running & String) -> IO(Unit):
  match offResult onResult:
    case (off,offText), (on,onText):IO.print("AppA terminal Off after On|" ++ offText ++ "\nAppA terminal On|" ++ onText)
def on_observed(pair:(Control & (Running & String)) & (Running & String)) -> IO(Unit):
  match pair:
    case ((control,offResult),onResult):both_observed(control,offResult,onResult)
def off_observed(pair:(Control & Running) & (Running & String)) -> IO(Unit):
  match pair:
    case ((control,on),offResult):
      continuation:Continuation.PairedHeader<(Running & String),IO(Unit)> = Continuation.PairedHeader{Control & (Running & String),(control,offResult),on_observed}
      Continuation.paired_returned(Running & String,IO(Unit),continuation,running_observed(on))
def both(pair:Running & SessionResult) -> IO(Unit):
  match pair:
    case (off,Completed{control,on}):
      continuation:Continuation.PairedHeader<(Running & String),IO(Unit)> = Continuation.PairedHeader{Control & Running,(control,on),off_observed}
      Continuation.paired_returned(Running & String,IO(Unit),continuation,running_observed(off))
    case (off,Refused{Inventory,inventory,text}):IO.print("AppA On stopped|" ++ text)
def off_finished(result:SessionResult) -> IO(Unit):
  match result:
    case Completed{Control{_,factory},off}:
      continuation:Continuation.PairedHeader<SessionResult,IO(Unit)> = Continuation.PairedHeader{Running,off,both}
      IO.bind(SessionResult,Unit,session(True{},factory),result=>Continuation.paired_returned(SessionResult,IO(Unit),continuation,result))
    case Refused{Inventory,inventory,text}:IO.print("AppA Off stopped|" ++ text)
# Off and On are actual executions. The second World consumes the advanced
# Factory; its namespace and its separately issued event family stay visible.
def main() -> IO(Unit):IO.bind(SessionResult,Unit,session(False{},W.factory()),off_finished)
