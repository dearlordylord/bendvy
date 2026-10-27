import Base
import ./declarations.bend as Ordinary
import ./execution.bend as Execution
import ./restore-receipt.bend as Receipt
import ./staging.bend as Stage
import ../../src/ecs/execution-save-plan.bend as Plan
import ../../src/ecs/execution-save-world.bend as Save
import ../../src/ecs/execution-save-data.bend as Saved
import ../../src/ecs/execution-save-gate.bend as Gate
import ../../src/ecs/execution-composer-layout.bend as Layout
import ../../src/ecs/execution-parallel-root-application.bend as Schedule
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/dependency-application.bend as App
import ../../src/ecs/dependency-executor.bend as Exec
import ../../src/ecs/decode-data.bend as D
import ../../src/ecs/entity-key-render.bend as Key
import ../../src/ecs/restore-data.bend as R
import ../../src/ecs/world.bend as W
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/execution-lifecycle-notices.bend as Notice
import ../../src/ecs/execution-save-metadata.bend as Metadata
import ../../src/ecs/execution-save-recipe.bend as Recipe
import ../../src/ecs/entity-key.bend as EntityKey

def raw(value:D.Raw) -> String:
  match value:
    case D.Missing{}:"missing"
    case D.Null{}:"null"
    case D.Number{value}:U32.show(value)
    case D.SignedInteger{negative,value}:Bool.show(negative) ++ ":" ++ Nat.show(value)
    case D.Float{value}:F32.show(value)
    case D.Binary64{hi,lo}:U32.show(hi) ++ ":" ++ U32.show(lo)
    case D.BendvyText{value}:value
    case D.Utf16Text{values}:List.show(&2,U32,U32.show,values)
    case D.Boolean{value}:Bool.show(value)
    case D.Handle{namespace,key}:U32.show(namespace) ++ ":" ++ Key.show(key)
    case D.Array{[]}:"[]"
    case D.Array{head <> rest}:"[" ++ raw(head) ++ ";" ++ raw(D.Array{rest}) ++ "]"
    case D.Object{[]}:"{}"
    case D.Object{D.Field{name,value} <> rest}:"{" ++ name ++ "=" ++ raw(value) ++ ";" ++ raw(D.Object{rest}) ++ "}"
def field(value:Saved.Field) -> String:
  match value:
    case Saved.Field{key,present,Saved.Absent{},_}:key ++ "=" ++ Bool.show(present) ++ ":absent"
    case Saved.Field{key,present,Saved.Omitted{},_}:key ++ "=" ++ Bool.show(present) ++ ":transient"
    case Saved.Field{key,present,Saved.Persisted{value},_}:key ++ "=" ++ Bool.show(present) ++ ":" ++ raw(value)
def entity(value:Saved.Entity) -> String:
  match value:
    case Saved.Entity{key,values}:Key.show(key) ++ List.show(&2,Saved.Field,field,values)
def snapshot(~S:Data,value:Saved.Snapshot<S>) -> String:
  match value:
    case Saved.Snapshot{version,Metadata.Metadata{namespace,Metadata.Allocator{next,high,capacity,depth,slots,free,order},clock,_},entities,resources}:"v=" ++ U32.show(version) ++ "/ns=" ++ U32.show(namespace) ++ "/allocator=" ++ U32.show(next) ++ ":" ++ U32.show(high) ++ ":" ++ U32.show(capacity) ++ ":" ++ Nat.show(depth) ++ "/free=" ++ List.show(&2,U32,U32.show,free) ++ "/order=" ++ List.show(&2,EntityKey.Key,Key.show,order) ++ "/entities=" ++ List.show(&2,Saved.Entity,entity,entities) ++ "/resources=" ++ List.show(&2,Saved.Field,field,resources)
def binding(~S:Data,value:R.Binding<S>) -> String:
  match value:
    case R.Binding{saved,W.Handle{namespace,target}}:Key.show(saved) ++ "->" ++ U32.show(namespace) ++ ":" ++ Key.show(target)
def captured(result:Array<U32> & U32) -> String:
  match result:
    case (_,value):U32.show(value)
def locals(~S:Data,app:Execution.Application(~S)) -> String:
  match app:
    case Schedule.Scheduled{App.State{_,Product.Owner{Sys.Owner{_,_,_,_,_,Execution.Local{left,leftRuns}},Sys.Owner{_,_,_,_,_,Execution.ReaderLocal{right,rightRuns,Notice.Reader{namespace,id,cursor},notices}}},_,Execution.Handler{handler,handled},_},_,_,_,_}:"captures=" ++ captured(Array.get(U32,left,0)) ++ "," ++ captured(Array.get(U32,right,0)) ++ "," ++ captured(Array.get(U32,handler,0)) ++ "/runs=" ++ U32.show(leftRuns) ++ "," ++ U32.show(rightRuns) ++ "/reader=" ++ U32.show(namespace) ++ ":" ++ U32.show(id) ++ ":" ++ Nat.show(cursor) ++ "/notices=" ++ U32.show(notices) ++ "/handled=" ++ U32.show(handled)
def observed(~S:Data,before:String,mapping:String,result:Plan.Schema<S,Ordinary.components(~S),Ordinary.resources(~S)> & (Execution.Application(~S) & Gate.Outcome<Saved.Snapshot<S>,Recipe.Refusal>)) -> String:
  match result:
    case (_,(current,Gate.Saved{after})):before ++ "/map=" ++ mapping ++ "/after=" ++ snapshot(~S,after) ++ "/" ++ locals(~S,current)
    case (_,(_,Gate.RefusedPending{})):"save-refused-pending"
    case (_,(_,Gate.Refused{_})):"save-refused"
def resumed(~S:Data,result:Execution.Resumed<S>) -> String:
  match result:
    case Execution.Retained{_,_}:"restore-not-complete"
    case Execution.Resumed{app,Receipt.Receipt{Stage.State{schema,_,_},input,_,_,mapping,_,_,_,_},_}:observed(~S,"before=" ++ snapshot(~S,input),List.show(&2,R.Binding<S>,binding(~S),mapping),Execution.save(~S,schema,app))
