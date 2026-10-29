import Base
import ./app-a-schema.bend as D
import ./app-a-payloads.bend as P
import ./app-a-commands.bend as Author
import ./app-a-systems.bend as Systems
import ../../src/ecs/inspector.bend as I
import ../../src/ecs/component.bend as Component
import ../../src/ecs/capabilities.bend as Cap
import ../../src/ecs/execution-inspector.bend as Modern
import ../../src/ecs/execution-inspector-component.bend as Columns
import ../../src/ecs/execution-composer-layout.bend as L
import ../../src/ecs/world.bend as W

def Resources() -> Type:L.resources(~P.AuditWorkshop,Author.resources())
type Reads<-H:Type> is Type:
  Reads{arrays:I.Lookup<H,P.AuditWorkshop,List<&2,U32>>,scalar:I.Lookup<H,P.AuditWorkshop,U32>,counter:Cap.ValueRead<H,List<&2,U32>>}
def Ops(H:Type) -> Type:Reads<H>
def plan() -> I.Plan<P.AuditWorkshop,Systems.Columns(),Resources(),Unit,Ops>:
  I.Plan{Reads{Columns.lookup(~P.AuditWorkshop,~Systems.Columns(),~Resources(),~Unit,~D.components(),~L.InLeft{L.AtLeaf{}},~{==},~{==}),Columns.lookup(~P.AuditWorkshop,~Systems.Columns(),~Resources(),~Unit,~D.components(),~L.InRight{L.AtLeaf{}},~{==},~{==}),Modern.resource_grant(~I.Frame<P.AuditWorkshop,Systems.Columns(),Resources(),Unit>,~List<&2,U32>,Modern.resource(~P.AuditWorkshop,~Systems.Columns(),~Resources(),~Unit,~Author.resources(),~L.InLeft{L.AtLeaf{}},~{==},~{==}))}}
def array_value(value:Component.Access<List<&2,U32>>) -> String:
  match value:
    case Component.Found{values}:List.show(&2,U32,U32.show,values)
    case Component.ComponentAbsent{}:"absent"
    case Component.MissingEntity{}:"missing"
def scalar_value(value:Component.Access<U32>) -> String:
  match value:
    case Component.Found{value}:U32.show(value)
    case Component.ComponentAbsent{}:"absent"
    case Component.MissingEntity{}:"missing"
def array(value:I.Value<List<&2,U32>>) -> String:
  match value:
    case I.Value{value,added,changed}:array_value(value) ++ "/added=" ++ Bool.show(added) ++ "/changed=" ++ Bool.show(changed)
def scalar(value:I.Value<U32>) -> String:
  match value:
    case I.Value{value,added,changed}:scalar_value(value) ++ "/added=" ++ Bool.show(added) ++ "/changed=" ++ Bool.show(changed)
def counter_read(~H:Type,arrays:I.Value<List<&2,U32>>,scalarValue:I.Value<U32>,result:H & List<&2,U32>) -> H & Result<&2,&2,String,String>:
  match result:
    case (owner,counter):(owner,Done{"arrays=" ++ array(arrays) ++ ";scalar=" ++ scalar(scalarValue) ++ ";Counter=" ++ List.show(&2,U32,U32.show,counter)})
def scalar_read(~H:Type,~counter:Cap.ValueRead<H,List<&2,U32>>,arrays:I.Value<List<&2,U32>>,result:H & I.Value<U32>) -> H & Result<&2,&2,String,String>:
  match result:
    case (owner,scalar):counter_read(~H,arrays,scalar,Cap.value_read(~H,~List<&2,U32>,~counter,owner))
def arrays_read(~H:Type,~scalar:I.Lookup<H,P.AuditWorkshop,U32>,~counter:Cap.ValueRead<H,List<&2,U32>>,target:W.Handle<P.AuditWorkshop>,result:H & I.Value<List<&2,U32>>) -> H & Result<&2,&2,String,String>:
  match result:
    case (owner,arrays):scalar_read(~H,~counter,arrays,I.lookup(~H,~P.AuditWorkshop,~U32,~scalar,owner,target))
def arrays_cap(~H:Type,caps:Reads<H>) -> I.Lookup<H,P.AuditWorkshop,List<&2,U32>>:
  match caps:
    case Reads{arrays,_,_}:arrays
def scalar_cap(~H:Type,caps:Reads<H>) -> I.Lookup<H,P.AuditWorkshop,U32>:
  match caps:
    case Reads{_,scalar,_}:scalar
def counter_cap(~H:Type,caps:Reads<H>) -> Cap.ValueRead<H,List<&2,U32>>:
  match caps:
    case Reads{_,_,counter}:counter
def read(~H:Type,~caps:Reads<H>,target:W.Handle<P.AuditWorkshop>,owner:H) -> H & Result<&2,&2,String,String>:
  +actual=target
  arrays_read(~H,~scalar_cap(~H,caps),~counter_cap(~H,caps),actual,I.lookup(~H,~P.AuditWorkshop,~List<&2,U32>,~arrays_cap(~H,caps),owner,actual))
def observed(result:I.Observed<P.AuditWorkshop,Systems.Columns(),Resources(),Unit,String,String>) -> Systems.World() & String:
  match result:
    case I.Observed{world,_,Done{text}}:(world,text)
    case I.Observed{world,_,Fail{error}}:(world,"inspection-error=" ++ error)
def observe(world:Systems.World(),target:W.Handle<P.AuditWorkshop>) -> Systems.World() & String:
  observed(I.passive(~P.AuditWorkshop,~Systems.Columns(),~Resources(),~Unit,~Ops,~W.Handle<P.AuditWorkshop>,~String,~String,~plan(),~read,I.Fresh{},target,world))
def paired_second(first:String,result:Systems.World() & String) -> Systems.World() & String:
  match result:
    case (world,second):(world,"first={" ++ first ++ "};second={" ++ second ++ "}")
def paired_first(target:W.Handle<P.AuditWorkshop>,result:Systems.World() & String) -> Systems.World() & String:
  match result:
    case (world,first):paired_second(first,observe(world,target))
def paired(world:Systems.World(),target:W.Handle<P.AuditWorkshop>) -> Systems.World() & String:
  +actual=target
  paired_first(actual,observe(world,actual))
