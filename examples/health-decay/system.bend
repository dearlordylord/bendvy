import Base
import ./schema.bend as D
import ./components.bend as Value
import ../../src/ecs/world.bend as W
import ../../src/ecs/execution-composer-layout.bend as L
import ../../src/ecs/execution-builder.bend as Build
import ../../src/ecs/execution-query.bend as Q
import ../../src/ecs/execution-query-recipe.bend as Recipe
import ../../src/ecs/execution-query-matches.bend as Match
import ../../src/ecs/execution-query-store.bend as Store
import ../../src/ecs/execution-resource-store.bend as Resources
import ../../src/ecs/execution-resource-program.bend as Program
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-reservation-task.bend as Task
import ../../src/ecs/execution-declaration.bend as Decl
import ../../src/ecs/execution-resource-query-leaf.bend as Leaf

def C() -> Type:Store.owner(~D.Schema,D.components(),Store.Sparse{})
def R() -> Type:Resources.owner(~D.Schema,D.resources(),Resources.Sparse{})
type Cap<-H:Type> is Type:
  Cap{health:Q.GeneralWriter<D.Schema,H,Value.Health,Value.Health>,decay:Q.GeneralReader<D.Schema,H,Value.HealthDecay>}
def Ops(Permit:Data,H:Type) -> Type:Cap<H>
def any_health(_:Maybe<&2,Value.Health>) -> Bool:True{}
def any_decay(_:Maybe<&2,Value.HealthDecay>) -> Bool:True{}
def selected_decay(~H:Type,-B:Type,health:Q.GeneralWriter<D.Schema,H,Value.Health,Value.Health>,result:B & Q.GeneralReader<D.Schema,H,Value.HealthDecay>) -> B & Cap<H>:
  match result:
    case (book,decay):(book,Cap{health,decay})
def selected_health(~Permit:Data,~H:Type,~B:Type,~q:Build.Query(~D.Schema,~D.Columns(),~C(),~R(),~H,~B),result:B & Q.GeneralWriter<D.Schema,H,Value.Health,Value.Health>) -> B & Cap<H>:
  match result:
    case (book,health):selected_decay(~H,B,health,Build.general_query(~D.Schema,~D.Columns(),~C(),~R(),~D.components(),~L.InRight{L.AtLeaf{}},~{==},~{==},~Store.Sparse{},~{==},~Recipe.ReadRows{},~Recipe.AllLive{},~Match.Required{},~any_decay,~H,~B,~q,book))
def selection(~Permit:Data,~H:Type,~B:Type,~cr:Build.ComponentRead(~D.Schema,~C(),~R(),~H,~B),~cw:Build.ComponentWrite(~D.Schema,~C(),~R(),~H,~B),~rr:Build.ResourceRead(~D.Schema,~C(),~R(),~H,~B),~rw:Build.ResourceWrite(~D.Schema,~C(),~R(),~H,~B),~q:Build.Query(~D.Schema,~D.Columns(),~C(),~R(),~H,~B),~life:Build.Lifecycle(~D.Schema,~D.Columns(),~C(),~R(),~H,~B),book:B) -> B & Cap<H>:
  selected_health(~Permit,~H,~B,~q,Build.general_query(~D.Schema,~D.Columns(),~C(),~R(),~D.components(),~L.InLeft{L.AtLeaf{}},~{==},~{==},~Store.Sparse{},~{==},~Recipe.WriteRows{},~Recipe.With{L.InRight{L.AtLeaf{}}},~Match.Required{},~any_health,~H,~B,~q,book))
def program(~Permit:Data,~H:Type,~B:Type,~builder:Build.Builder(~D.Schema,~D.Columns(),~C(),~R(),~Permit,~H,~B),book:B) -> B & Ops(Permit,H):builder(Ops,selection(~Permit,~H,~B),book)
def kernel(~Permit:Data,~token:Permit,~H:Type,~B:Type,~builder:Build.Builder(~D.Schema,~D.Columns(),~C(),~R(),~Permit,~H,~B),book:B) -> B & Ops(Permit,H):Build.framework_program(~D.Schema,~D.Columns(),~C(),~R(),~Ops,~program,~Permit,~token,~H,~B,~builder,book)
def multiply(+factor:F32,value:Value.Health) -> Value.Health & Unit:
  match value:
    case Value.Health{value}:(Value.Health{F32.mul(value,factor)},Unit{})
def edited(~Permit:Data,~H:Type,next:H -> Task.Task<D.Schema,Permit,H & (Unit & Sys.Completion<String,Unit>)>,result:H & Q.GeneralEdit<Value.Health,Unit>) -> Task.Task<D.Schema,Permit,H & (Unit & Sys.Completion<String,Unit>)>:
  match result:
    case (scope,Q.GeneralEdited{_}):next(scope)
    case (scope,Q.GeneralUnchanged{_}):Task.TDone{(scope,(Unit{},Sys.BodyError{"health write refused",Unit{}}))}
def found_decay(~Permit:Data,~H:Type,~modify:@-Out:Type -> H -> W.Handle<D.Schema> -> (Value.Health -> Value.Health & Out) -> H & Q.GeneralEdit<Value.Health,Out>,handle:W.Handle<D.Schema>,next:H -> Task.Task<D.Schema,Permit,H & (Unit & Sys.Completion<String,Unit>)>,result:H & Q.GeneralLookup<Value.HealthDecay>) -> Task.Task<D.Schema,Permit,H & (Unit & Sys.Completion<String,Unit>)>:
  match result:
    case (scope,Q.Matched{Some{Value.HealthDecay{factor}}}):edited(~Permit,~H,next,modify(Unit,scope,handle,multiply(factor)))
    case (scope,_):Task.TDone{(scope,(Unit{},Sys.BodyError{"required decay query refused",Unit{}}))}
def decay_rows(~Permit:Data,~H:Type,~read:H -> W.Handle<D.Schema> -> H & Q.GeneralLookup<Value.HealthDecay>,~modify:@-Out:Type -> H -> W.Handle<D.Schema> -> (Value.Health -> Value.Health & Out) -> H & Q.GeneralEdit<Value.Health,Out>,values:List<&2,Q.GeneralRow<D.Schema,Value.Health>>,scope:H) -> Task.Task<D.Schema,Permit,H & (Unit & Sys.Completion<String,Unit>)>:
  match values:
    case []:Task.TDone{(scope,(Unit{},Sys.Success{Unit{}}))}
    case Q.GeneralRow{+handle,_} <> rest:found_decay(~Permit,~H,~modify,handle,scope => decay_rows(~Permit,~H,~read,~modify,rest,scope),read(scope,handle))
def selected(~Permit:Data,~H:Type,~read:H -> W.Handle<D.Schema> -> H & Q.GeneralLookup<Value.HealthDecay>,~modify:@-Out:Type -> H -> W.Handle<D.Schema> -> (Value.Health -> Value.Health & Out) -> H & Q.GeneralEdit<Value.Health,Out>,result:H & Q.GeneralReport<D.Schema,Value.Health>) -> Task.Task<D.Schema,Permit,H & (Unit & Sys.Completion<String,Unit>)>:
  match result:
    case (scope,Q.SelectedRows{values}):decay_rows(~Permit,~H,~read,~modify,values,scope)
    case (scope,Q.SelectionRefused{}):Task.TDone{(scope,(Unit{},Sys.BodyError{"health query refused",Unit{}}))}
def read_decay(~H:Type,caps:Cap<H>) -> H -> W.Handle<D.Schema> -> H & Q.GeneralLookup<Value.HealthDecay>:
  match caps:
    case Cap{_,Q.GeneralReader{_,read}}:read
    case _:scope => _ => (scope,Q.LookupRefused{})
def write_health(~H:Type,caps:Cap<H>) -> @-Out:Type -> H -> W.Handle<D.Schema> -> (Value.Health -> Value.Health & Out) -> H & Q.GeneralEdit<Value.Health,Out>:
  match caps:
    case Cap{Q.GeneralWriter{_,modify,_},_}:modify
    case _:Out => scope => _ => unused => (scope,Q.GeneralUnchanged{unused})
def select_health(~H:Type,caps:Cap<H>) -> H -> H & Q.GeneralReport<D.Schema,Value.Health>:
  match caps:
    case Cap{Q.GeneralWriter{Q.GeneralReader{query,_},_,_},_}:query
    case _:scope => (scope,Q.SelectionRefused{})
def body(~Permit:Data,~H:Type,~caps:Ops(Permit,H),scope:H,_:Unit) -> Task.Task<D.Schema,Permit,H & (Unit & Sys.Completion<String,Unit>)>:
  selected(~Permit,~H,~read_decay(~H,caps),~write_health(~H,caps),select_health(~H,caps)(scope))
def compiled() -> Decl.Compilation<D.Schema,D.Columns(),C(),R(),Ops>:Program.compile_framework(~D.Schema,~D.Columns(),~C(),~R(),~Ops,~kernel)
def Node() -> Type:Leaf.node_type(~D.Schema,~D.components(),~D.resources(),~Unit,~String,~Unit,~Ops,~Unit,~kernel,~body)
