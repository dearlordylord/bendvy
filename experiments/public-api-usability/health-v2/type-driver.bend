import Base
import type-core.bend as Core
import type-schema.bend as S
import ../../../src/ecs/ordinary-app-execution.bend as Execution
import ../../../src/ecs/ordinary-app-schedule.bend as Schedule
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/compose.bend as Q
import ../../../src/ecs/captured-schedule-composition.bend as Choice
import ../../../src/ecs/ordinary-app-component.bend as Component

def inspected(before:String,kind:String,after:String) -> String:
  "before=" ++ before ++ "\nrun=" ++ kind ++ "\nafter=" ++ after

def failed_text(handle:W.Handle<S.Schema>,before:String,app:Core.Scheduled(),error:Core.ErrorType()) -> String:
  match error:
    case Choice.RightError{Component.CallbackFailure{Q.UserError{Core.Deliberate{}}}}:inspected(before,"failed",Core.inspect(app,handle))
    case _:"ERROR: wrong failure source"

def result_text(handle:W.Handle<S.Schema>,before:String,result:Execution.Run<Core.Scheduled(),S.Schema,Core.ErrorType()>) -> String:
  match result:
    case Execution.Run{Schedule.Failed{app,error,_},_}:failed_text(handle,before,app,error)
    case Execution.Run{Schedule.Finished{app,_},_}:inspected(before,"finished",Core.inspect(app,handle))
    case _:"ERROR: run rejected"

def attached(handle:W.Handle<S.Schema>,before:String,value:Schedule.Attachment<Core.Registered(),Core.Scheduled()>) -> String:
  match value:
    case Schedule.Attached{app}:result_text(handle,before,Core.run(app))
    case _:"ERROR: schedule attachment rejected"

def second_failed(_:Core.First()) -> String:
  "ERROR: second component registration"

def second_added(handle:W.Handle<S.Schema>,before:String,first:Core.First()) -> String:
  Core.add_second(~String,app => attached(handle,before,Core.attach(app)),second_failed,first)

def first_failed(_:Core.Initial()) -> String:
  "ERROR: first component registration"

def start(world:S.World(),handle:W.Handle<S.Schema>,before:String) -> String:
  Core.add_first(~String,first => second_added(handle,before,first),first_failed,world)
