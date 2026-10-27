import Base
import ./app-a-payloads.bend as P
import ./app-a-schema.bend as D
import ../../src/ecs/world.bend as W
import ../../src/ecs/execution-composer-layout.bend as Layout
import ../../src/ecs/execution-recoverable-component.bend as Component
import ../../src/ecs/recoverable-component.bend as RC
import ../../src/ecs/recovery-journal.bend as Journal

# This named explicit facility is separate from the ordinary Root schedule.
def Columns() -> Type:Layout.columns(~P.AuditWorkshop,D.components())
def Records() -> Type:List<RC.Record<P.AuditWorkshop,Array<U32>>>
def World(~R:Type) -> Type:W.World<P.AuditWorkshop,Columns(),R,Unit>
type Reply is Type:
  Completed{success:Bool,records:Records(),output:Maybe<Array<U32>>}
  Refused{incoming:Maybe<Array<U32>>,error:W.WorldError}
def released(~R:Type,records:Records(),result:World(~R) & RC.Record<P.AuditWorkshop,Array<U32>>) -> World(~R) & Records():
  match result:
    case (world,record):(world,List.append(&1,RC.Record<P.AuditWorkshop,Array<U32>>,records,[record]))
def inverse(~R:Type,record:RC.Record<P.AuditWorkshop,Array<U32>>,success:Bool,world:World(~R),records:Records()) -> World(~R) & Records():
  match success:
    case True{}:(world,List.append(&1,RC.Record<P.AuditWorkshop,Array<U32>>,records,[record]))
    case False{}:released(~R,records,Component.undo(~P.AuditWorkshop,~Columns(),~R,~Unit,~D.components(),~Layout.InLeft{Layout.AtLeaf{}},~{==},~{==},~{==},record,world))
def finished(~R:Type,+success:Bool,result:World(~R) & Records()) -> World(~R) & Reply:
  match result:
    case (world,records):(world,Completed{success,records,None{}})
def replaced(~R:Type,+success:Bool,result:RC.Replacement<World(~R),P.AuditWorkshop,Array<U32>>) -> World(~R) & Reply:
  match result:
    case RC.Applied{world,previous}:finished(~R,success,Journal.finish(~World(~R),~Records(),[(success=>world=>records=>inverse(~R,previous,success,world,records))],success,world,[]))
    case RC.Refused{world,incoming,error}:(world,Refused{incoming,error})
def run(~R:Type,world:World(~R),target:W.Handle<P.AuditWorkshop>,incoming:Array<U32>,fail:Bool) -> World(~R) & Reply:
  replaced(~R,Bool.not(fail),Component.replace(~P.AuditWorkshop,~Columns(),~R,~Unit,~D.components(),~Layout.InLeft{Layout.AtLeaf{}},~{==},~{==},~{==},world,target,Some{incoming}))
