import Base
import ./app-a-payloads.bend as P
import ./app-a-schema.bend as D
import ./app-a-commands.bend as Author
import ./app-a-bootstrap.bend as Bootstrap
import ./app-a-handoff.bend as Handoff
import ../../src/ecs/world.bend as W
import ../../src/ecs/execution-relation-context.bend as Context
import ../../src/ecs/dependency-application.bend as State
import ../../src/ecs/execution-event-family.bend as Event
import ../../src/ecs/execution-event-io.bend as EventIO

def recovered(result:Bootstrap.Bound() & Handoff.State) -> IO(Unit):
  match result:
    case (bound,Handoff.State{target,records,output,loose,history,text}):IO.print("AppA recovery prefix|" ++ text)
def flushed(bound:Bootstrap.Bound()) -> IO(Unit):
  recovered(Bootstrap.with_world(~Handoff.State,Handoff.begin(~Bootstrap.Resources()),Bootstrap.flush(bound)))
def queued(result:Bootstrap.Bound() & Context.RunReport<State.Report<String,String>>) -> IO(Unit):
  match result:
    case (bound,report):IO.bind(Unit,Unit,IO.print("AppA bundle committed pending explicit flush"),_=>flushed(bound))
def defined(result:Bootstrap.Definition) -> IO(Unit):
  match result:
    case Bootstrap.Ready{bound}:IO.bind(Bootstrap.Bound() & Context.RunReport<State.Report<String,String>>,Unit,Bootstrap.invoke(bound),queued)
    case Bootstrap.AuthorRefused{_,_,_}:IO.print("author-registration-refused")
    case Bootstrap.PeerRefused{_,_,_,_}:IO.print("boundary-registration-refused")
def created(result:Context.Initialization<P.AuditWorkshop,D.components(),Author.resources(),Unit>) -> IO(Unit):
  match result:
    case Context.ContextCreated{_,world,context}:defined(Bootstrap.define(context,world))
    case Context.SchemaRefused{_,_,_}:IO.print("schema-refused")
    case Context.NamespaceRefused{_,_}:IO.print("namespace-refused")
def event_created(result:Event.Creation<P.AuditWorkshop,Array<U32>,"RecoveredCargoLog">) -> IO(Unit):
  match result:
    case Event.Created{family}:created(D.create(~Author.Receipts(),W.factory(),D.Seed{[],family}))
    case Event.CreationRefused{}:IO.print("event-family-creation-refused")
def main() -> IO(Unit):IO.bind(Event.Creation<P.AuditWorkshop,Array<U32>,"RecoveredCargoLog">,Unit,EventIO.create(~P.AuditWorkshop,~Array<U32>,~"RecoveredCargoLog"),event_created)
