import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-parallel-schedule.bend as Ready
import ../../src/ecs/dependency-executor.bend as Exec
import ../../src/ecs/change-tick.bend as Tick
import ../../src/ecs/lifecycle.bend as Life
import Base
import ./ordinary-whole-other-shape.bend as Run
import ./schema.bend as S
import ./schema-walk.bend as Walk
import ../../src/ecs/execution-resource-query-execution.bend as Combined
import ../../src/ecs/execution-composer-layout.bend as L
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/world.bend as W
import ../../src/ecs/clock-state.bend as Clock

def columns(_:Unit) -> Run.WC():Walk.full_b_same_schema()
def resources() -> L.resources(~S.SchemaA,Run.combined_resources()):
  Product.Owner{L.ResourceSlot{L.initialize(Run.combined_resources(),L.InLeft{L.AtLeaf{}},ALeaf{3}),L.unknown_stamp()},L.ResourceSlot{L.initialize(Run.combined_resources(),L.InRight{L.AtLeaf{}},"peer"),L.unknown_stamp()}}
# Ordinary setup initializes canonical stamps from the actual administrative
# clock; neither the first read nor the first write invents a creation tick.
def initialize(world:Run.CombinedWorld()) -> Run.CombinedWorld():
  match world:
    case W.World{namespace,allocator,store,resource,events,pending,registrations,nextSystemId,+clock,lifecycle}:W.World{namespace,allocator,store,L.initialize_resources(~S.SchemaA,Run.combined_resources(),Clock.current(clock),resource),events,pending,registrations,nextSystemId,clock,lifecycle}
def reserved(result:Run.CombinedWorld() & W.Reservation<S.SchemaA>) -> Run.CombinedWorld():
  match result:
    case (world,W.Reserved{handle}):W.discard_status(~S.SchemaA,~Run.WC(),~L.resources(~S.SchemaA,Run.combined_resources()),~Unit,W.activate(~S.SchemaA,~Run.WC(),~L.resources(~S.SchemaA,Run.combined_resources()),~Unit,world,handle))
    case (world,W.ReservationRejected{_}):world
def live(count:Nat,world:Run.CombinedWorld()) -> Run.CombinedWorld():
  match count:
    case 0n:world
    case 1n+rest:live(rest,reserved(W.reserve_id(~S.SchemaA,~Run.WC(),~L.resources(~S.SchemaA,Run.combined_resources()),~Unit,world)))
def array_text(values:Array<U32>) -> String:
  match values:
    case ALeaf{value}:U32.show(value)
    case ANode{left,right}:"[" ++ array_text(left) ++ "," ++ array_text(right) ++ "]"
def local_text(token:Run.CombinedToken) -> String:
  match token:
    case Run.CombinedArray{values}:array_text(values)
    case Run.CombinedDeferred{_}:"unused-transform-retained"
def output_text(value:Maybe<&2,U32>) -> String:
  match value:
    case Some{value}:U32.show(value)
    case None{}:"none"
def invocation_text(value:Exec.Invocation<String,Maybe<&2,U32>>) -> String:
  match value:
    case Exec.Completed{output}:"ok:" ++ output_text(output)
    case Exec.BodyError{error,output}:"error:" ++ error ++ ":" ++ output_text(output)
    case Exec.AdmissionRefused{}:"refused"
def status_text(values:List<&2,Ready.Completed<String,Maybe<&2,U32>>>) -> String:
  match values:
    case []:""
    case Ready.Completed{id,invocation} <> rest:U32.show(id) ++ "=" ++ invocation_text(invocation) ++ ";" ++ status_text(rest)
def stamp_text(value:Life.Stamp) -> String:
  match value:
    case Life.Stamp{added,changed}:Tick.cursor_show(added) ++ "/" ++ Tick.cursor_show(changed)
def world_text(world:Run.CombinedWorld()) -> String:
  match world:
    case W.World{_,_,_,Product.Owner{L.ResourceSlot{L.Viewed{array,arrayCache},arrayStamp},L.ResourceSlot{L.Viewed{string,stringCache},stringStamp}},_,_,_,_,_,_}:"resources=" ++ array_text(array) ++ "/" ++ U32.show(arrayCache) ++ "/" ++ stamp_text(arrayStamp) ++ "," ++ string ++ "/" ++ U32.show(stringCache) ++ "/" ++ stamp_text(stringStamp)
def rendered(~own:Bool,result:Run.CombinedPipeline<own>) -> IO(String):
  match result:
    case Run.CombinedExecuted{Combined.Returned{world,Product.Owner{Sys.Owner{_,_,_,_,leftCursor,Run.CombinedLocal{left}},Sys.Owner{_,_,_,_,rightCursor,Run.CombinedLocal{right}}},status,_}}:IO.pure(String,"returned{" ++ status_text(status) ++ "locals=" ++ local_text(left) ++ "," ++ local_text(right) ++ ";cursors=" ++ Tick.cursor_show(leftCursor) ++ "," ++ Tick.cursor_show(rightCursor) ++ ";" ++ world_text(world) ++ "}")
    case Run.CombinedExecuted{Combined.AdmissionRefused{_,_,_}}:IO.pure(String,"admission-refused")
    case Run.CombinedExecuted{Combined.CutInventoryRefused{_,_,_,_,_}}:IO.pure(String,"cut-inventory-retained")
    case Run.CombinedExecuted{Combined.JoinInventoryRefused{_,_,_,_,_}}:IO.pure(String,"join-inventory-retained")
    case Run.CombinedRegistrationRefused{_}:IO.pure(String,"registration-refused")
def created(~own:Bool,result:W.Creation<S.SchemaA,Run.WC(),L.resources(~S.SchemaA,Run.combined_resources()),Unit>) -> IO(String):
  match result:
    case W.Created{_,world}:IO.bind(Run.CombinedPipeline<own>,String,Run.combined_registered(~own,Run.combined_register(~own,live(20n,initialize(world)),Run.CombinedLocal{Run.CombinedArray{ALeaf{100}}},Run.CombinedLocal{Run.CombinedArray{ALeaf{200}}})),result => rendered(~own,result))
    case W.CreateRejected{_,_}:IO.pure(String,"creation-refused")
def run(~own:Bool) -> IO(String):
  created(~own,W.create(~S.SchemaA,~Run.WC(),~L.resources(~S.SchemaA,Run.combined_resources()),~Unit,~columns,W.factory(),resources()))
def second(serial:String,native:String) -> IO(Unit):IO.print("serial=" ++ serial ++ ";native=" ++ native)
def first(serial:String) -> IO(Unit):IO.bind(String,Unit,run(~False{}),native => second(serial,native))
def main() -> IO(Unit):IO.bind(String,Unit,run(~True{}),serial => first(serial))
