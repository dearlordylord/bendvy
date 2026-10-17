import Base
import ../../../src/ecs/ordinary-schema.bend as Schema
import app-core.bend as Core
import failure-core.bend as Fail
import app-run.bend as Observe
import ../../../examples/scheduled-health/components.bend as D
import ../../../examples/scheduled-health/schema.bend as S
import ../../../examples/scheduled-health/application.bend as Original
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/world-io.bend as WI
import ../../../src/ecs/ordinary-app-schema.bend as App
import ../../../src/ecs/ordinary-app-composer.bend as Build
import ../../../src/ecs/ordinary-app-schedule.bend as Schedule
import ../../../src/ecs/schedule-provision.bend as SP
import ../../../src/ecs/schedule.bend as Sch
import ../../../src/ecs/ordinary-app-records.bend as Leaf
import ../../../src/ecs/ordinary-app-registration-fields.bend as Fields
import ../../../src/ecs/ordinary-app-recipe.bend as Tree

def world_fact(value:S.World() & U32) -> S.World() & String:
  match value:
    case (world,pending):(world,"pending=" ++ U32.show(pending))

def cursor(fields:Fields.Fields<S.Schema>) -> U32:
  match fields:
    case Fields.Fields{_,_,_,_,cursor,_,_,_}:cursor

def missing_world(handle:W.Handle<S.Schema>,schema:Schema.Schema<S.Schema,S.Store,Unit>,prior:Unit,record:Core.Record(),recipe:Tree.Recipe<S.World(),Core.Rows(),Core.observer()>,debug:Bool,position:U32,value:S.World() & String) -> String:
  match value:
    case (world,fact):"missing-before-effects " ++ fact ++ " cursor=" ++ U32.show(position) ++ "\n" ++ Observe.pending_attached(handle,Core.attach(False{},App.Application{schema,Build.Registered{world,(prior,record),recipe,debug}}))

def missing_result(handle:W.Handle<S.Schema>,value:Schedule.RunResult<Core.Scheduled(),S.Schema,Core.Error>) -> String:
  match value:
    case Schedule.Missing{Schedule.Application{App.Application{schema,Build.Registered{world,(prior,Leaf.Record{token,+fields}),recipe,debug}},_,_,_,_,_},[SP.Component{777}]}:missing_world(handle,schema,prior,Leaf.Record{token,fields},recipe,debug,cursor(fields),world_fact(W.pending_count(~S.Schema,~S.Store,~Unit,~Unit,world)))
    case _:"ERROR: expected missing requirement"

def missing_attached(handle:W.Handle<S.Schema>,value:Schedule.Attachment<Core.Application(),Core.Scheduled()>) -> String:
  match value:
    case Schedule.Attached{app}:missing_result(handle,Core.run(app))
    case _:"ERROR: missing setup"

def missing_identified(handle:W.Handle<S.Schema>,schema:Schema.Schema<S.Schema,S.Store,Unit>,world:S.World(),prior:Unit,recipe:Tree.Recipe<S.World(),Core.Rows(),Core.observer()>,debug:Bool,value:Core.Record() & U32) -> String:
  match value:
    case (record,id):missing_attached(handle,Schedule.attach(~S.Schema,~S.Store,~Unit,~Unit,~Core.Owners(),~Core.Rows(),~Core.observer(),~Core.folder(),App.Application{schema,Build.Registered{world,(prior,record),recipe,debug}},"Missing",SP.Sequence{SP.Entry{Sch.Barrier{},[]},SP.Entry{Sch.System{id,0},[SP.Component{777}]} }))

def missing_created(handle:W.Handle<S.Schema>,value:Core.Creation) -> String:
  match value:
    case Core.Created{App.Application{schema,Build.Registered{world,(prior,record),recipe,_}}}:missing_identified(handle,schema,world,prior,recipe,True{},Core.identify(record))
    case _:"ERROR: missing registration"

def failure_observed(handle:W.Handle<S.Schema>,value:Fail.Scheduled() & Maybe<&2,Schedule.Description<S.Schema,Fail.Rows()>>) -> String:
  match value:
    case (Schedule.Application{App.Application{_,Build.Registered{world,(_,Leaf.Record{_,fields}),_,_}},_,_,_,_,_},view):"failed health=" ++ Observe.snapshot_text(view) ++ " cursor=" ++ U32.show(cursor(fields)) ++ " " ++ Original.finished(world,handle)
def failure_result(handle:W.Handle<S.Schema>,value:Schedule.RunResult<Fail.Scheduled(),S.Schema,Fail.Error>) -> String:
  match value:
    case Schedule.Failed{app,_,_}:failure_observed(handle,Schedule.snapshot(~S.Schema,~S.Store,~Unit,~Unit,~Fail.Owners(),~Fail.Rows(),~Fail.observer(),~Fail.folder(),app))
    case _:"ERROR: expected failure"
def failure_attached(handle:W.Handle<S.Schema>,value:Schedule.Attachment<Fail.Application(),Fail.Scheduled()>) -> String:
  match value:
    case Schedule.Attached{app}:failure_result(handle,Fail.run(app))
    case _:"ERROR: failure setup"
def failure_created(handle:W.Handle<S.Schema>,value:Fail.Creation) -> String:
  match value:
    case Fail.Created{app}:failure_attached(handle,Fail.attach(True{},App.enabled(~S.Schema,~S.Store,~Unit,~Unit,~Fail.Owners(),~Fail.Rows(),~Fail.observer(),~Fail.folder(),app,True{})))
    case _:"ERROR: failure registration"
def seeded(mode:U32,result:S.Spawned) -> String:
  match mode result:
    case 0, S.Spawned{world,handle}:missing_created(handle,Core.create(world))
    case _, S.Spawned{world,handle}:failure_created(handle,Fail.create(world))
    case _ _:"ERROR: seed sentinel"
def second(mode:U32,result:S.Spawned) -> String:
  match result:
    case S.Spawned{world,_}:seeded(mode,S.spawn(world,D.EntitySeed{D.Health{30.0},None{}}))
    case _:"ERROR: second seed"
def first(mode:U32,result:S.Spawned) -> String:
  match result:
    case S.Spawned{world,_}:second(mode,S.spawn(world,D.EntitySeed{D.Health{20.0},Some{D.HealthDecay{0.25}}}))
    case _:"ERROR: first seed"
def created(mode:U32,result:WI.Creation<S.Schema,S.Store,Unit,Unit>) -> IO(Unit):
  match result:
    case WI.Created{world}:IO.print(first(mode,S.spawn(world,D.EntitySeed{D.Health{10.0},Some{D.HealthDecay{0.5}}})))
    case _:IO.die(Unit,1,"World creation refused")
def scenario(mode:U32) -> IO(Unit):
  IO.bind(WI.Creation<S.Schema,S.Store,Unit,Unit>,Unit,WI.create(~S.Schema,~S.Store,~Unit,~Unit,~S.empty,Unit{}),created(mode))
def main() -> IO(Unit):
  do IO<Unit>:
    scenario(0)
    scenario(1)
