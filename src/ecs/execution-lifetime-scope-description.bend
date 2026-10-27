import Base
import ./world.bend as W
import ./entity-key.bend as Key
import ./lifetime-scope.bend as Scope
import ./execution-lifetime-scope-command.bend as Commands
import ./execution-lifetime-scope-store.bend as Store
import ./execution-lifetime-scope-resource-dispatch.bend as Dispatch
import ./execution-command-buffer.bend as Buffer

def key(value:Key.Key) -> String:
  match value:
    case Key.EntityKey{index,generation}:U32.show(index) ++ ":" ++ U32.show(generation)
def handle(~S:Data,value:W.Handle<S>) -> String:
  match value:
    case W.Handle{namespace,value}:U32.show(namespace) ++ "/" ++ key(value)
def scope(~S:Data,value:Scope.Scope<S>) -> String:
  match value:
    case Scope.Scope{namespace,name}:U32.show(namespace) ++ "/" ++ name
def operation(~S:Data,value:Commands.Operation<S>) -> String:
  match value:
    case Commands.Assign{group,entity}:"assign(" ++ scope(~S,group) ++ "," ++ handle(~S,entity) ++ ")"
    case Commands.Cleanup{group}:"cleanup(" ++ scope(~S,group) ++ ")"
def request(~S:Data,value:Store.Request<S>) -> String:
  match value:
    case Store.Assign{group,entity}:"assign(" ++ scope(~S,group) ++ "," ++ handle(~S,entity) ++ ")"
    case Store.Select{group}:"select(" ++ scope(~S,group) ++ ")"
    case Store.Forget{entity}:"forget(" ++ handle(~S,entity) ++ ")"
    case Store.Inspect{}:"inspect"
def refusal(value:Store.Refusal) -> String:
  match value:
    case Store.NamespaceMismatch{}:"namespace"
    case Store.MissingEntity{}:"missing-entity"
def result(~S:Data,value:Store.Outcome<S>) -> String:
  match value:
    case Store.Assignment{Store.Assigned{group,entity}}:"assigned(" ++ scope(~S,group) ++ "," ++ handle(~S,entity) ++ ")"
    case Store.Assignment{Store.AssignmentRefused{group,entity,reason}}:"refused(" ++ scope(~S,group) ++ "," ++ handle(~S,entity) ++ "," ++ refusal(reason) ++ ")"
    case Store.Selection{Store.Selected{group,members}}:"selected(" ++ scope(~S,group) ++ "," ++ List.show(&2,Key.Key,key,members) ++ ")"
    case Store.Selection{Store.SnapshotRefused{group}}:"selection-refused(" ++ scope(~S,group) ++ ")"
    case Store.Forgotten{entity}:"forgotten(" ++ handle(~S,entity) ++ ")"
    case Store.Inspected{namespace}:"inspected(" ++ U32.show(namespace) ++ ")"
    case Store.Refused{value}:"refused(" ++ request(~S,value) ++ ")"
def outcome(~S:Data,value:Dispatch.Outcome<S>) -> String:
  match value:
    case Dispatch.Completed{value}:result(~S,value)
    case Dispatch.Undeclared{value}:"undeclared(" ++ request(~S,value) ++ ")"
def status(value:Buffer.ScopeStatus) -> String:
  match value:
    case Buffer.ScopeComplete{}:"complete"
    case Buffer.ScopePaused{}:"paused"
    case Buffer.ScopeDenied{Buffer.MissingAuthority{}}:"missing-authority"
    case Buffer.ScopeDenied{Buffer.ForeignNamespace{}}:"foreign-namespace"
    case Buffer.ScopeDenied{Buffer.ScopeStoreRefused{}}:"store-refused"
def linked_status(value:Buffer.LinkedStatus) -> String:
  match value:
    case Buffer.LinkedComplete{}:"complete"
    case Buffer.LinkedPaused{}:"paused"
    case Buffer.LinkedDenied{reason}:status(Buffer.ScopeDenied{reason})
