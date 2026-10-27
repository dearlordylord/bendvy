import Base
import ./app-b-schema.bend as D
import ./app-b-commands.bend as Author
import ./app-b-application.bend as App
import ./app-b-inspection.bend as Inspect
import ./app-b-owners.bend as Owners
import ../../src/ecs/world.bend as W
import ../../src/ecs/execution-relation-context.bend as Context
import ../../src/ecs/dependency-application.bend as State

def status(value:Context.RunReport<State.Report<String,String>>) -> String:
  match value:
    case Context.ContextRefused{}:"context-refused"
    case Context.RunReported{State.Finished{_}}:"finished"
    case Context.RunReported{State.Stopped{error,_}}:"stopped:" ++ error
    case Context.RunReported{State.Invalid{_}}:"invalid"
def owners_printed(label:String,continue:App.Bound() -> IO(Unit),text:String,result:App.Bound() & String) -> IO(Unit):
  match result:
    case (bound,owners):IO.bind(Unit,Unit,IO.print(label ++ "|" ++ text ++ "|" ++ owners),_ => continue(bound))
def printed(label:String,continue:App.Bound() -> IO(Unit),result:App.Bound() & String) -> IO(Unit):
  match result:
    case (bound,text):owners_printed(label,continue,text,Owners.observed(bound))
def snapshot(label:String,continue:App.Bound() -> IO(Unit),bound:App.Bound()) -> IO(Unit):
  printed(label,continue,Inspect.observe(bound))
def finish(_:App.Bound()) -> IO(Unit):IO.print("AppB finished")
def repeated(bound:App.Bound()) -> IO(Unit):
  snapshot("after-repeated-inspect",finish,bound)
def reparented(bound:App.Bound()) -> IO(Unit):
  snapshot("reparent-flushed-and-inspected",repeated,App.flush(bound))
def reparent_ran(result:App.Bound() & Context.RunReport<State.Report<String,String>>) -> IO(Unit):
  match result:
    case (bound,report):snapshot("reparent-committed-pending/" ++ status(report),reparented,bound)
def reparent(bound:App.Bound()) -> IO(Unit):IO.bind(App.Bound() & Context.RunReport<State.Report<String,String>>,Unit,App.invoke(bound),reparent_ran)
def relations_flushed(bound:App.Bound()) -> IO(Unit):
  snapshot("relations-flushed-and-inspected",reparent,App.flush(bound))
def relations_ran(result:App.Bound() & Context.RunReport<State.Report<String,String>>) -> IO(Unit):
  match result:
    case (bound,report):snapshot("relations-committed-pending/" ++ status(report),relations_flushed,bound)
def relations(bound:App.Bound()) -> IO(Unit):IO.bind(App.Bound() & Context.RunReport<State.Report<String,String>>,Unit,App.invoke(bound),relations_ran)
def bundles_flushed(bound:App.Bound()) -> IO(Unit):
  snapshot("bundles-explicit-flush",relations,App.flush(bound))
def bundles_ran(result:App.Bound() & Context.RunReport<State.Report<String,String>>) -> IO(Unit):
  match result:
    case (bound,report):snapshot("three-bundles-committed-pending/" ++ status(report),bundles_flushed,bound)
def bundles(bound:App.Bound()) -> IO(Unit):IO.bind(App.Bound() & Context.RunReport<State.Report<String,String>>,Unit,App.invoke(bound),bundles_ran)
def defined(result:App.Definition) -> IO(Unit):
  match result:
    case App.DefinitionReady{bound}:snapshot("created",bundles,bound)
    case App.AuthorRefused{_,_,_}:IO.print("author-registration-refused")
    case App.PeerRefused{_,_,_,_}:IO.print("boundary-registration-refused")
def created(result:Context.Initialization<D.Scene,D.components(),Author.resources(),Unit>) -> IO(Unit):
  match result:
    case Context.ContextCreated{_,world,context}:defined(App.define(context,world))
    case Context.SchemaRefused{_,_,_}:IO.print("schema-refused")
    case Context.NamespaceRefused{_,_}:IO.print("namespace-refused")
def main() -> IO(Unit):created(D.create(~Author.Receipts(),W.factory(),[]))
