import Base
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-machine.bend as Machine
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-machine-declaration.bend as OD
import /workspace/formal-proofs/bendvy/src/ecs/machine.bend as M
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-composer.bend as Build
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-records.bend as Leaf
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as T
type Schema is Data:
  Schema{}
type First is Data:
  First{}
type Second is Data:
  Second{}
type Resource is Type:
  Resource{first:M.Slot<Schema,First,U32>,second:M.Slot<Schema,First,U32>,sibling:Array<U32>}
def first_take(resource:Resource) -> Resource & M.Slot<Schema,First,U32>:
  match resource:
    case Resource{+first,second,sibling}:(Resource{first,second,sibling},first)
def second_take(resource:Resource) -> Resource & M.Slot<Schema,First,U32>:
  match resource:
    case Resource{first,+second,sibling}:(Resource{first,second,sibling},second)
def first_put(resource:Resource,value:M.Slot<Schema,First,U32>) -> Resource:
  match resource:
    case Resource{_,second,sibling}:Resource{value,second,sibling}
def second_put(resource:Resource,value:M.Slot<Schema,First,U32>) -> Resource:
  match resource:
    case Resource{first,_,sibling}:Resource{first,value,sibling}
def first_declaration() -> OD.Declaration<Schema,First,U32,Resource,first_take>:
  OD.declared(~Schema,~First,~U32,~Resource,~first_take,"First",[7,8,42,6])
def second_declaration() -> OD.Declaration<Schema,First,U32,Resource,second_take>:
  OD.declared(~Schema,~First,~U32,~Resource,~second_take,"Second",[7,8,42,6])
def World() -> Type:
  W.World<Schema,Unit,Resource,U32>
def installed(world:World()) -> Machine.Application(~Schema,~First,~U32,~Unit,~Resource,~U32,~first_take,~first_put,~U32.is_eq,~first_declaration(),~U32.show,~Unit,~Unit,~Build.empty_observe(~World()),~Leaf.empty(~Schema)):
  Machine.install(~Schema,~First,~U32,~Unit,~Resource,~U32,~first_take,~first_put,~U32.is_eq,~first_declaration(),~U32.show,~Unit,~Unit,~Build.empty_observe(~World()),~Leaf.empty(~Schema),Build.empty(~Schema,~World(),world))
def rejected(world:World()) -> Machine.Application(~Schema,~First,~U32,~Unit,~Resource,~U32,~second_take,~second_put,~U32.is_eq,~second_declaration(),~U32.show,~Unit,~Unit,~Build.empty_observe(~World()),~Leaf.empty(~Schema)) & T.Outcome<Unit>:
  Machine.queue_app(~Schema,~First,~U32,~Unit,~Resource,~U32,~second_take,~second_put,~U32.is_eq,~second_declaration(),~U32.show,~Unit,~Unit,~Build.empty_observe(~World()),~Leaf.empty(~Schema),~Unit,installed(world),M.Set{8,False{}},T.Success{})
