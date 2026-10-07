import Base
import schema.bend as S
import gameplay.bend as G
import reference-declarations.bend as D
import owned-rows.bend as R
import ../../../src/ecs/owned-compose.bend as O
import ../../../src/ecs/owned-optimized-compose.bend as Opt
import ../../../src/ecs/compose.bend as Q
import ../../../src/ecs/capabilities.bend as Cap

# Zero-family queries retain their original Frame; there are no hot row owners.
def frame_identity(frame:D.Frame()) -> D.Frame():
  frame
def work_plan() -> O.Plan<S.Schema,S.Store,Unit,Unit,G.WorkOps,R.WorkRow>:
  O.Plan{G.WorkCaps{R.write_work_stock(),R.read_work_recipe(),R.read_work_queue(),R.id_read_work()},D.work_match,R.enter_work,R.leave_work}
def work(world:S.World()) -> Q.Executed<S.World(),Q.Error<G.Error>,Unit>:
  Opt.each_fields(~S.Schema,~S.Store,~Unit,~Unit,~G.WorkOps,~R.WorkRow,~Unit,~G.Error,~Unit,~G.WorkCaps{R.write_work_stock(),R.read_work_recipe(),R.read_work_queue(),R.id_read_work()},~D.work_match,~R.enter_work,~R.leave_work,~G.work_body,~S.prepare_store,~S.recover_store,Unit{},world)
def composed(world:S.World()) -> Q.Executed<S.World(),Q.Error<G.Error>,String>:
  Opt.each_fields(~S.Schema,~S.Store,~Unit,~Unit,~G.WorkOps,~R.WorkRow,~Unit,~G.Error,~String,~G.WorkCaps{R.write_work_stock(),R.read_work_recipe(),R.read_work_queue(),R.id_read_work()},~D.work_match,~R.enter_work,~R.leave_work,~G.compose_body,~S.prepare_store,~S.recover_store,Unit{},world)
def empty_plan() -> O.Plan<S.Schema,S.Store,Unit,Unit,D.EmptyOps,R.EmptyRow>:
  O.Plan{R.id_read_empty(),Q.all(~S.Schema,~S.Store,~Unit,~Unit),R.enter_empty,R.leave_empty}
def empty(world:S.World()) -> Q.Executed<S.World(),Q.Error<G.Error>,String>:
  Opt.each_fields(~S.Schema,~S.Store,~Unit,~Unit,~D.EmptyOps,~D.Frame(),~Unit,~G.Error,~String,~D.id_read(),~Q.all(~S.Schema,~S.Store,~Unit,~Unit),~frame_identity,~frame_identity,~D.empty_body,~S.identity_store,~S.identity_store,Unit{},world)
def contradictory_plan() -> O.Plan<S.Schema,S.Store,Unit,Unit,D.EmptyOps,R.EmptyRow>:
  O.Plan{R.id_read_empty(),D.contradictory_match,R.enter_empty,R.leave_empty}
def contradictory(world:S.World()) -> Q.Executed<S.World(),Q.Error<G.Error>,String>:
  Opt.each_fields(~S.Schema,~S.Store,~Unit,~Unit,~D.EmptyOps,~D.Frame(),~Unit,~G.Error,~String,~D.id_read(),~D.contradictory_match,~frame_identity,~frame_identity,~D.empty_body,~S.prepare_enabled,~S.recover_enabled,Unit{},world)
def duplicate_plan() -> O.Plan<S.Schema,S.Store,Unit,Unit,G.DuplicateOps,R.DuplicateRow>:
  O.Plan{G.DuplicateCaps{R.write_duplicate_stock(),R.write_duplicate_stock(),R.read_duplicate_stock(),R.id_read_duplicate()},D.match_stock(~Q.Required{}),R.enter_duplicate,R.leave_duplicate}
def duplicate(world:S.World()) -> Q.Executed<S.World(),Q.Error<G.Error>,String>:
  Opt.each_fields(~S.Schema,~S.Store,~Unit,~Unit,~G.DuplicateOps,~R.DuplicateRow,~Unit,~G.Error,~String,~G.DuplicateCaps{R.write_duplicate_stock(),R.write_duplicate_stock(),R.read_duplicate_stock(),R.id_read_duplicate()},~D.match_stock(~Q.Required{}),~R.enter_duplicate,~R.leave_duplicate,~G.duplicate_body,~S.prepare_stock,~S.recover_stock,Unit{},world)
def advanced_plan() -> O.Plan<S.Schema,S.Store,Unit,Unit,D.AdvancedOps,R.AdvancedRow>:
  O.Plan{D.AdvancedCaps{R.read_advanced_stock(),R.read_advanced_queue(),R.id_read_advanced()},D.advanced_match,R.enter_advanced,R.leave_advanced}
def advanced(world:S.World(),cursor:U32) -> Q.Executed<S.World(),Q.Error<G.Error>,U32>:
  Opt.each_fields_since(~S.Schema,~S.Store,~Unit,~Unit,~D.AdvancedOps,~R.AdvancedRow,~Unit,~G.Error,~U32,~D.AdvancedCaps{R.read_advanced_stock(),R.read_advanced_queue(),R.id_read_advanced()},~D.advanced_match,~R.enter_advanced,~R.leave_advanced,~D.advanced_body,~S.prepare_advanced,~S.recover_advanced,Unit{},world,cursor)
def queue_send(row:R.WorkRow,request:Q.Insert<S.Schema,S.Queue>) -> R.WorkRow:
  R.enter_work(Q.insert(~S.Schema,~S.Store,~Unit,~Unit,~S.QueueRest,~S.Queue,~S.QueueView,~S.QueueToken,~S.take_queue,~S.put_queue,~S.project_queue,~S.queue(),R.leave_work(row),request))
def retry_plan() -> O.Plan<S.Schema,S.Store,Unit,Unit,G.RetryOps,R.WorkRow>:
  O.Plan{G.RetryCaps{R.write_work_stock(),R.write_work_recipe(),R.write_work_queue(),Cap.Send{queue_send}},D.triple_match,R.enter_work,R.leave_work}
def retry(world:S.World(),args:G.RetryArgs) -> Q.Executed<S.World(),Q.Error<G.Error>,Unit>:
  Opt.each_fields(~S.Schema,~S.Store,~Unit,~Unit,~G.RetryOps,~R.WorkRow,~G.RetryArgs,~G.Error,~Unit,~G.RetryCaps{R.write_work_stock(),R.write_work_recipe(),R.write_work_queue(),Cap.Send{queue_send}},~D.triple_match,~R.enter_work,~R.leave_work,~G.retry_body,~S.prepare_store,~S.recover_store,args,world)
