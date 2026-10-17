import Base
import ../../../src/ecs/ordinary-declaration.bend as Identity
import ../../../src/ecs/ordinary-app-execution-recipe.bend as Exec
import ../../../src/ecs/ordinary-app-run.bend as Entry
import ../../../src/ecs/captured-schedule-composition.bend as Choice
import ../../../src/ecs/execution-context.bend as Ctx
import ../../../src/ecs/ordinary-app-execution.bend as Execution
import ../../../src/ecs/schema-fragments.bend as Fragment
import type-schema.bend as S
import ../../../src/ecs/ordinary-app-schema.bend as App
import ../../../src/ecs/ordinary-query-observable.bend as Obs
import ../../../src/ecs/ordinary-component-binding.bend as Binding
import ../../../src/ecs/ordinary-app-component.bend as Component
import ../../../src/ecs/ordinary-app-composer.bend as Build
import ../../../src/ecs/ordinary-app-records.bend as Leaf
import ../../../src/ecs/ordinary-app-observation-data.bend as DTO
import ../../../src/ecs/ordinary-app-registration-fields.bend as Fields
import ../../../src/ecs/inspector-query-projection.bend as P
import ../../../src/ecs/inspector-query.bend as IQ
import ../../../src/ecs/inspector.bend as I
import ../../../src/ecs/compose.bend as Q
import ../../../src/ecs/capabilities.bend as Cap
import ../../../src/ecs/component.bend as Cmp
import ../../../src/ecs/column.bend as Col
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/system.bend as Sys
import ../../../src/ecs/schedule-provision.bend as SP
import ../../../src/ecs/ordinary-app-schedule.bend as Schedule
import ../../../src/ecs/ordinary-schema.bend as Decl
import ../../../src/ecs/transaction.bend as T

type Error is Data: Deliberate{}
def Frame() -> Type:Q.Frame<S.Schema,S.Store,S.Resources,Unit>
def Ops(H:Type) -> Type:Cap.Write<H,Array<U32>,S.CellsView>
def cells_binding() -> Binding.Binding<S.Schema,S.Store,Unit,Array<U32>,S.CellsView,S.CellsToken,S.take_cells,S.put_cells,S.view_cells>:
  Binding.bind(~S.Schema,~S.Store,~Unit,~Array<U32>,~S.CellsView,~S.CellsToken,~S.take_cells,~S.put_cells,~S.view_cells,S.identity())
def Value() -> Data:Cmp.Access<S.CellsView>
def query() -> Obs.Declaration<S.Schema,Frame(),Ops(Frame()),I.Frame<S.Schema,S.Store,S.Resources,Unit>,Value()>:
  Obs.write(~S.Schema,~S.Store,~Unit,~Array<U32>,~S.CellsView,~S.CellsToken,~S.take_cells,~S.put_cells,~S.view_cells,~S.Resources,~Unit,~cells_binding())

def render(value:Value()) -> String:
  match value:
    case Cmp.Found{S.CellsView{first,second}}:U32.show(first) ++ "," ++ U32.show(second)
    case _:"missing"

def successful_body(~H:Type,~caps:Ops(H),_:Unit,owner:H) -> H & (T.Outcome<Error> & Unit):
  updated = Cap.set(~H,~Array<U32>,~S.CellsView,~caps,owner,S.cells(11,12))
  (updated,(T.Success{},Unit{}))

def failing_body(~H:Type,~caps:Ops(H),_:Unit,owner:H) -> H & (T.Outcome<Error> & Unit):
  updated = Cap.set(~H,~Array<U32>,~S.CellsView,~caps,owner,S.cells(90,91))
  (updated,(T.Failure{Deliberate{}},Unit{}))

def First() -> Type:Component.Application(~S.Schema,~S.Store,~S.Resources,~Unit,~Unit,~Unit,~Build.empty_observe(~S.World()),~Leaf.empty(~S.Schema),~Unit,~Exec.empty_plan(~S.Schema),~Exec.empty_dispatch(~S.World()),~Exec.empty_provide(~S.Schema,~S.World()),~Ops,~Unit,~Error,~Unit,~Value(),~query(),~successful_body,~render)
def FirstOwner() -> Type:Component.execution_owners(~S.Schema,~S.Store,~S.Resources,~Unit,~Unit,~Unit,~Build.empty_observe(~S.World()),~Leaf.empty(~S.Schema),~Unit,~Exec.empty_plan(~S.Schema),~Exec.empty_dispatch(~S.World()),~Exec.empty_provide(~S.Schema,~S.World()),~Ops,~Unit,~Error,~Unit,~Value(),~query(),~successful_body,~render)
def FirstRows() -> Data:Component.execution_rows(~S.Schema,~S.Store,~S.Resources,~Unit,~Unit,~Unit,~Build.empty_observe(~S.World()),~Leaf.empty(~S.Schema),~Unit,~Exec.empty_plan(~S.Schema),~Exec.empty_dispatch(~S.World()),~Exec.empty_provide(~S.Schema,~S.World()),~Ops,~Unit,~Error,~Unit,~Value(),~query(),~successful_body,~render)
def first_observe() -> S.World() -> S.World() & DTO.Observation<FirstRows()>:Component.execution_observe(~S.Schema,~S.Store,~S.Resources,~Unit,~Unit,~Unit,~Build.empty_observe(~S.World()),~Leaf.empty(~S.Schema),~Unit,~Exec.empty_plan(~S.Schema),~Exec.empty_dispatch(~S.World()),~Exec.empty_provide(~S.Schema,~S.World()),~Ops,~Unit,~Error,~Unit,~Value(),~query(),~successful_body,~render)
def first_fold() -> FirstOwner() -> FirstOwner() & List<&2,Fields.Fields<S.Schema>>:Component.execution_fold(~S.Schema,~S.Store,~S.Resources,~Unit,~Unit,~Unit,~Build.empty_observe(~S.World()),~Leaf.empty(~S.Schema),~Unit,~Exec.empty_plan(~S.Schema),~Exec.empty_dispatch(~S.World()),~Exec.empty_provide(~S.Schema,~S.World()),~Ops,~Unit,~Error,~Unit,~Value(),~query(),~successful_body,~render)
def first_plan() -> FirstOwner() -> FirstOwner() & SP.Plan<S.Schema>:Component.execution_plan(~S.Schema,~S.Store,~S.Resources,~Unit,~Unit,~Unit,~Build.empty_observe(~S.World()),~Leaf.empty(~S.Schema),~Unit,~Exec.empty_plan(~S.Schema),~Exec.empty_dispatch(~S.World()),~Exec.empty_provide(~S.Schema,~S.World()),~Ops,~Unit,~Error,~Unit,~Value(),~query(),~successful_body,~render)
def FirstError() -> Data:Choice.Choice<Unit,Component.ExecutionError<Error>>
def first_dispatch() -> FirstOwner() -> Ctx.Context<S.World()> -> U32 -> FirstOwner() & Sys.Outcome<Ctx.Context<S.World()>,FirstError(),Unit>:Component.execution_dispatch(~S.Schema,~S.Store,~S.Resources,~Unit,~Unit,~Unit,~Build.empty_observe(~S.World()),~Leaf.empty(~S.Schema),~Unit,~Exec.empty_plan(~S.Schema),~Exec.empty_dispatch(~S.World()),~Exec.empty_provide(~S.Schema,~S.World()),~Ops,~Unit,~Error,~Unit,~Value(),~query(),~successful_body,~render)
def first_provide() -> S.World() -> S.World() & List<&2,SP.Requirement<S.Schema>>:Component.execution_provide(~S.Schema,~S.Store,~S.Resources,~Unit,~Unit,~Unit,~Build.empty_observe(~S.World()),~Leaf.empty(~S.Schema),~Unit,~Exec.empty_plan(~S.Schema),~Exec.empty_dispatch(~S.World()),~Exec.empty_provide(~S.Schema,~S.World()),~Ops,~Unit,~Error,~Unit,~Value(),~query(),~successful_body,~render)

def Final() -> Type:Component.Application(~S.Schema,~S.Store,~S.Resources,~Unit,~FirstOwner(),~FirstRows(),~first_observe(),~first_fold(),~FirstError(),~first_plan(),~first_dispatch(),~first_provide(),~Ops,~Unit,~Error,~Unit,~Value(),~query(),~failing_body,~render)
def FinalOwners() -> Type:Component.execution_owners(~S.Schema,~S.Store,~S.Resources,~Unit,~FirstOwner(),~FirstRows(),~first_observe(),~first_fold(),~FirstError(),~first_plan(),~first_dispatch(),~first_provide(),~Ops,~Unit,~Error,~Unit,~Value(),~query(),~failing_body,~render)
def FinalRows() -> Data:Component.execution_rows(~S.Schema,~S.Store,~S.Resources,~Unit,~FirstOwner(),~FirstRows(),~first_observe(),~first_fold(),~FirstError(),~first_plan(),~first_dispatch(),~first_provide(),~Ops,~Unit,~Error,~Unit,~Value(),~query(),~failing_body,~render)
def final_observe() -> S.World() -> S.World() & DTO.Observation<FinalRows()>:Component.execution_observe(~S.Schema,~S.Store,~S.Resources,~Unit,~FirstOwner(),~FirstRows(),~first_observe(),~first_fold(),~FirstError(),~first_plan(),~first_dispatch(),~first_provide(),~Ops,~Unit,~Error,~Unit,~Value(),~query(),~failing_body,~render)
def final_fold() -> FinalOwners() -> FinalOwners() & List<&2,Fields.Fields<S.Schema>>:Component.execution_fold(~S.Schema,~S.Store,~S.Resources,~Unit,~FirstOwner(),~FirstRows(),~first_observe(),~first_fold(),~FirstError(),~first_plan(),~first_dispatch(),~first_provide(),~Ops,~Unit,~Error,~Unit,~Value(),~query(),~failing_body,~render)
def final_plan() -> FinalOwners() -> FinalOwners() & SP.Plan<S.Schema>:Component.execution_plan(~S.Schema,~S.Store,~S.Resources,~Unit,~FirstOwner(),~FirstRows(),~first_observe(),~first_fold(),~FirstError(),~first_plan(),~first_dispatch(),~first_provide(),~Ops,~Unit,~Error,~Unit,~Value(),~query(),~failing_body,~render)
def FinalError() -> Data:Choice.Choice<FirstError(),Component.ExecutionError<Error>>
def final_dispatch() -> FinalOwners() -> Ctx.Context<S.World()> -> U32 -> FinalOwners() & Sys.Outcome<Ctx.Context<S.World()>,FinalError(),Unit>:Component.execution_dispatch(~S.Schema,~S.Store,~S.Resources,~Unit,~FirstOwner(),~FirstRows(),~first_observe(),~first_fold(),~FirstError(),~first_plan(),~first_dispatch(),~first_provide(),~Ops,~Unit,~Error,~Unit,~Value(),~query(),~failing_body,~render)
def final_provide() -> S.World() -> S.World() & List<&2,SP.Requirement<S.Schema>>:Component.execution_provide(~S.Schema,~S.Store,~S.Resources,~Unit,~FirstOwner(),~FirstRows(),~first_observe(),~first_fold(),~FirstError(),~first_plan(),~first_dispatch(),~first_provide(),~Ops,~Unit,~Error,~Unit,~Value(),~query(),~failing_body,~render)

def Registered() -> Type:Final()
def Initial() -> Type:Exec.Registered<S.Schema,S.World(),Unit,Unit,Build.empty_observe(~S.World()),Leaf.empty(~S.Schema),Unit,Exec.empty_plan(~S.Schema),Exec.empty_dispatch(~S.World()),Exec.empty_provide(~S.Schema,~S.World())>
def Owners() -> Type:FinalOwners()
def Rows() -> Data:FinalRows()
def observer() -> S.World() -> S.World() & DTO.Observation<Rows()>:final_observe()
def folder() -> Owners() -> Owners() & List<&2,Fields.Fields<S.Schema>>:final_fold()
def plan() -> Owners() -> Owners() & SP.Plan<S.Schema>:final_plan()
def provide() -> S.World() -> S.World() & List<&2,SP.Requirement<S.Schema>>:final_provide()
def ErrorType() -> Data:FinalError()
def dispatch() -> Owners() -> Ctx.Context<S.World()> -> U32 -> Owners() & Sys.Outcome<Ctx.Context<S.World()>,ErrorType(),Unit>:final_dispatch()
def Scheduled() -> Type:Entry.Application<S.Schema,S.Store,S.Resources,Unit,Owners(),Rows(),observer(),folder(),ErrorType(),plan(),dispatch(),provide()>
def run(app:Scheduled()) -> Execution.Run<Scheduled(),S.Schema,ErrorType()>:Entry.run(~S.Schema,~S.Store,~S.Resources,~Unit,~Owners(),~Rows(),~observer(),~folder(),~ErrorType(),~plan(),~dispatch(),~provide(),app)
def attach(app:Registered()) -> Schedule.Attachment<Registered(),Scheduled()>:
  Entry.attach(~S.Schema,~S.Store,~S.Resources,~Unit,~Owners(),~Rows(),~observer(),~folder(),~ErrorType(),~plan(),~dispatch(),~provide(),Decl.Schema{Decl.entries(~S.Schema,~Col.Column<S.Schema,Array<U32>>,~Unit,Decl.component(~S.Schema,~Array<U32>,S.identity()))},app,"Type component rollback",False{})
def text_only(result:S.World() & (W.Handle<S.Schema> & String)) -> String:
  match result:
    case (_,(handle,text)):text

def inspect(app:Scheduled(),handle:W.Handle<S.Schema>) -> String:
  match app:
    case Entry.Application{Schedule.Application{App.Application{_,Build.Registered{world,_,_,_}},_,_,_,_,_},_}:text_only(S.read_text(world,handle))

def add_first(~Output:Type,done:First() -> Output,failed:Exec.Registered<S.Schema,S.World(),Unit,Unit,Build.empty_observe(~S.World()),Leaf.empty(~S.Schema),Unit,Exec.empty_plan(~S.Schema),Exec.empty_dispatch(~S.World()),Exec.empty_provide(~S.Schema,~S.World())> -> Output,world:S.World()) -> Output:
  Component.add(~S.Schema,~S.Store,~S.Resources,~Unit,~Unit,~Unit,~Build.empty_observe(~S.World()),~Leaf.empty(~S.Schema),~Unit,~Exec.empty_plan(~S.Schema),~Exec.empty_dispatch(~S.World()),~Exec.empty_provide(~S.Schema,~S.World()),~Ops,~Unit,~Error,~Unit,~Value(),~query(),~successful_body,~render,~Output,done,failed,Exec.empty(~S.Schema,~S.World(),world),Unit{},"commit cells","commit-cells")

def add_second(~Output:Type,done:Final() -> Output,failed:First() -> Output,first:First()) -> Output:
  Component.add(~S.Schema,~S.Store,~S.Resources,~Unit,~FirstOwner(),~FirstRows(),~first_observe(),~first_fold(),~FirstError(),~first_plan(),~first_dispatch(),~first_provide(),~Ops,~Unit,~Error,~Unit,~Value(),~query(),~failing_body,~render,~Output,done,failed,first,Unit{},"fail cells","fail-cells")
