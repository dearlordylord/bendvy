import Base
import ./app-a-payloads.bend as P
import ./app-a-schema.bend as D
import ./app-a-commands.bend as Author
import ./app-a-bootstrap.bend as Bootstrap
import ./app-a-handoff.bend as Handoff
import ./app-a-events.bend as Events
import ../../src/ecs/world.bend as W
import ../../src/ecs/execution-relation-context.bend as Context
import ../../src/ecs/dependency-application.bend as State
import ../../src/ecs/execution-event-family.bend as Event
import ../../src/ecs/execution-event-io.bend as EventIO

def handoff_observed(handoff:Handoff.State,result:Bootstrap.Bound() & String) -> IO(Unit):
  match result:
    case (bound,text):IO.print("AppA owned handoff|" ++ text)
def handoff_ran(handoff:Handoff.State,result:Bootstrap.Bound() & Context.RunReport<State.Report<String,String>>) -> IO(Unit):
  match result:
    case (bound,report):handoff_observed(handoff,Bootstrap.with_events(~String,Events.observed,bound))
def submitted(handoff:Handoff.State,result:Bootstrap.Bound() & Maybe<Array<U32>>) -> IO(Unit):
  match handoff result:
    case Handoff.State{target,records,output,oldLoose,history,text}, (bound,loose):IO.bind(Bootstrap.Bound() & Context.RunReport<State.Report<String,String>>,Unit,Bootstrap.invoke(bound),result=>handoff_ran(Handoff.State{target,records,output,loose,history,text},result))
def recovered(result:Bootstrap.Bound() & Handoff.State) -> IO(Unit):
  match result:
    case (bound,Handoff.State{Some{+target},records,output,Some{payload},history,+text}):IO.bind(Unit,Unit,IO.print("AppA recovery|" ++ text),_=>submitted(Handoff.State{Some{target},records,output,None{},history,text},Bootstrap.with_events(~Maybe<Array<U32>>,owners=>Events.accept(owners,target,payload),bound)))
    case (bound,Handoff.State{target,records,output,loose,history,text}):IO.print("AppA recovery stopped|" ++ text)
def flushed(bound:Bootstrap.Bound()) -> IO(Unit):
  recovered(Bootstrap.with_world(~Handoff.State,Handoff.begin(~Bootstrap.Resources()),Bootstrap.flush(bound)))
def queued(result:Bootstrap.Bound() & Context.RunReport<State.Report<String,String>>) -> IO(Unit):
  match result:
    case (bound,report):IO.bind(Unit,Unit,IO.print("AppA bundle committed pending explicit flush"),_=>flushed(bound))
def defined(result:Bootstrap.Definition) -> IO(Unit):
  match result:
    case Bootstrap.Ready{bound}:IO.bind(Bootstrap.Bound() & Context.RunReport<State.Report<String,String>>,Unit,Bootstrap.invoke(bound),queued)
    case Bootstrap.AuthorRefused{_,_,_,_}:IO.print("author-registration-refused")
    case Bootstrap.PeerRefused{_,_,_}:IO.print("boundary-registration-refused")
def created(reader:Events.Reader(),result:Context.Initialization<P.AuditWorkshop,D.components(),Author.resources(),Unit>) -> IO(Unit):
  match result:
    case Context.ContextCreated{_,world,context}:defined(Bootstrap.define(context,world,reader))
    case Context.SchemaRefused{_,_,_}:IO.print("schema-refused")
    case Context.NamespaceRefused{_,_}:IO.print("namespace-refused")
def event_registered(result:Events.Family() & Event.Registration<P.AuditWorkshop,Array<U32>,"RecoveredCargoLog">) -> IO(Unit):
  match result:
    case (family,Event.Registered{reader}):created(reader,D.create(~Author.Receipts(),W.factory(),D.Seed{[],family}))
    case (family,Event.RegistrationRefused{_}):IO.print("event-reader-registration-refused")
def event_created(result:Event.Creation<P.AuditWorkshop,Array<U32>,"RecoveredCargoLog">) -> IO(Unit):
  match result:
    case Event.Created{family}:event_registered(Event.register(~P.AuditWorkshop,~Array<U32>,~"RecoveredCargoLog",Event.Retained{},family))
    case Event.CreationRefused{}:IO.print("event-family-creation-refused")
def main() -> IO(Unit):IO.bind(Event.Creation<P.AuditWorkshop,Array<U32>,"RecoveredCargoLog">,Unit,EventIO.create(~P.AuditWorkshop,~Array<U32>,~"RecoveredCargoLog"),event_created)
