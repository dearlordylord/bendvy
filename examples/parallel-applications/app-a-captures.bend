import Base
import ./app-a-payloads.bend as P
import ./app-a-systems.bend as Systems
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-parallel-scope.bend as Scope
import ../../src/ecs/execution-resource-query-leaf.bend as Leaf
import ../../src/ecs/execution-resource-query-execution.bend as Execution
import ../../src/ecs/execution-compiled-binding.bend as Binding
import ../../src/ecs/execution-prepared.bend as Prep
import ../../src/ecs/change-tick.bend as Tick
import ../../src/ecs/world.bend as W

def array_projected(result:Array<U32> & List<&2,U32>) -> Array<U32> & String:
  match result:
    case (owner,view):(owner,List.show(&2,U32,U32.show,view))
def array(owner:Array<U32>) -> Array<U32> & String:array_projected(P.project(owner))
def array_cons(head:Array<U32> & String,tail:List<Array<U32>> & List<&2,String>) -> List<Array<U32>> & List<&2,String>:
  match head tail:
    case (head,text), (tail,texts):(head <> tail,text <> texts)
def arrays(owners:List<Array<U32>>) -> List<Array<U32>> & List<&2,String>:
  match owners:
    case []:([],[])
    case head <> tail:array_cons(array(head),arrays(tail))
def text(value:String) -> String:value
def writer_returned(namespace:U32,id:U32,name:String,access:List<&2,String>,+cursor:Maybe<&2,Tick.Tick>,unused:List<(Array<U32> -> Array<U32> & Array<U32>)>,result:List<Array<U32>> & List<&2,String>) -> Systems.Writer() & String:
  match result:
    case (returned,texts):(Sys.Owner{namespace,id,name,access,cursor,Systems.WriterLocal{returned,unused}},"counter-displaced=" ++ List.show(&2,String,text,texts) ++ ";cursor=" ++ Tick.cursor_show(cursor))
def writer(owner:Systems.Writer()) -> Systems.Writer() & String:
  match owner:
    case Sys.Owner{namespace,id,name,access,cursor,Systems.WriterLocal{returned,unused}}:writer_returned(namespace,id,name,access,cursor,unused,arrays(returned))
def query_returned(namespace:U32,id:U32,name:String,access:List<&2,String>,+cursor:Maybe<&2,Tick.Tick>,target:W.Handle<P.AuditWorkshop>,calls:Array<U32> & String,values:Array<U32> & String) -> Systems.Query() & String:
  match calls values:
    case (calls,callText), (values,valueText):(Sys.Owner{namespace,id,name,access,cursor,Systems.QueryReady{target,P.QueryPack{calls,values}}},"query-calls=" ++ callText ++ ";query-values=" ++ valueText ++ ";cursor=" ++ Tick.cursor_show(cursor))
def query(owner:Systems.Query()) -> Systems.Query() & String:
  match owner:
    case Sys.Owner{namespace,id,name,access,cursor,Systems.QueryReady{target,P.QueryPack{calls,values}}}:query_returned(namespace,id,name,access,cursor,target,array(calls),array(values))
    case owner:(owner,"query-capture-retained-in-refused-operation")
def reader_returned(namespace:U32,id:U32,name:String,access:List<&2,String>,+cursor:Maybe<&2,Tick.Tick>,result:Array<U32> & String) -> Systems.Reader() & String:
  match result:
    case (owner,text):(Sys.Owner{namespace,id,name,access,cursor,owner},"resource-capture=" ++ text ++ ";cursor=" ++ Tick.cursor_show(cursor))
def reader(owner:Systems.Reader()) -> Systems.Reader() & String:
  match owner:
    case Sys.Owner{namespace,id,name,access,cursor,local}:reader_returned(namespace,id,name,access,cursor,array(local))

# Diagnostics retain the same Compilation, admission evidence and Prepared owner.
def rebuilt(~Owner:Type,~Node:Type,rebuild:Owner -> Node,result:Owner & String) -> Node & String:
  match result:
    case (owner,text):(rebuild(owner),text)
def node(~Compilation:Type,~World:Type,~Owner:Type,~Evidence:Data,~Permit:Data,observe:Owner -> Owner & String,held:Leaf.Node<Compilation,World,Owner,Evidence,Permit>) -> Leaf.Node<Compilation,World,Owner,Evidence,Permit> & String:
  match held:
    case Leaf.Uninspected{Scope.CompiledBinding{compilation,owner}}:rebuilt(~Owner,~Leaf.Node<Compilation,World,Owner,Evidence,Permit>,owner=>Leaf.Uninspected{Scope.CompiledBinding{compilation,owner}},observe(owner))
    case Leaf.Inspected{Scope.CompiledBinding{compilation,owner},evidence,id,valid}:rebuilt(~Owner,~Leaf.Node<Compilation,World,Owner,Evidence,Permit>,owner=>Leaf.Inspected{Scope.CompiledBinding{compilation,owner},evidence,id,valid},observe(owner))
    case Leaf.Prepared{Execution.HeldReady{Binding.Binding{compilation,Prep.Prepared{namespace,owner,permits,provenance},evidence}}}:rebuilt(~Owner,~Leaf.Node<Compilation,World,Owner,Evidence,Permit>,owner=>Leaf.Prepared{Execution.HeldReady{Binding.Binding{compilation,Prep.Prepared{namespace,owner,permits,provenance},evidence}}},observe(owner))
    case Leaf.Prepared{Execution.HeldInventory{compilation,Prep.Inventory{owner,provenance},evidence}}:rebuilt(~Owner,~Leaf.Node<Compilation,World,Owner,Evidence,Permit>,owner=>Leaf.Prepared{Execution.HeldInventory{compilation,Prep.Inventory{owner,provenance},evidence}},observe(owner))
