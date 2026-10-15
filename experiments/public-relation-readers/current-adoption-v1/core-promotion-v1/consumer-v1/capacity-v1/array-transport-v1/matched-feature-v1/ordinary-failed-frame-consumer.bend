import Base
import ./ordinary-scheduled-reader-consumer.bend as Core
import ../../../../../../../../src/ecs/world.bend as W
import ../../../../../../../../src/ecs/transaction.bend as Tx
import ../../../../../../../../src/ecs/ordinary-reader-system.bend as Ordinary
import ../../../../../../../../src/ecs/event-notice-runtime.bend as Mixed
import ../../../../../../../../src/ecs/event-family-routing.bend as Route
import ../../../../../../../../src/ecs/event-family-runtime.bend as Family
import ../../../../../../../../src/ecs/event-runtime.bend as Ev
import ../../../../../../../../src/ecs/internal/relation-failures/domains.bend as KD
import ../../../../../../../../src/ecs/internal/relation-failures/queue.bend as KQ

# A begins with its first callback only after a scheduled relation mutation has
# crossed the real World barrier. That callback fails. Two real failure frames
# then run before the same provider retries; there is deliberately no earlier
# successful A run that could activate its retention membership.

def boolean(value:Bool) -> String:
  match value:
    case True{}:"true"
    case False{}:"false"
def quoted(value:String) -> String:
  "\""++value++"\""
def list_tail(~A:Data,~render:A -> String,values:List<&2,A>) -> String:
  match values:
    case []:""
    case value <> rest:","++render(value)++list_tail(~A,~render,rest)
def list_json(~A:Data,~render:A -> String,values:List<&2,A>) -> String:
  match values:
    case []:"[]"
    case value <> rest:"["++render(value)++list_tail(~A,~render,rest)++"]"

def position_json(value:Ev.Position) -> String:
  match value:
    case Ev.Position{id,cursor,registeredAt}:"{\"id\":"++U32.show(id)++",\"cursor\":"++Nat.show(cursor)++",\"registeredAt\":"++Nat.show(registeredAt)++"}"
def positions_json(values:List<&2,Ev.Position>) -> String:
  list_json(~Ev.Position,~position_json,values)
def batch_json(value:KQ.Batch<Core.event_type()>) -> String:
  match value:
    case KQ.Batch{tick,count,values}:"{\"tick\":"++Nat.show(tick)++",\"count\":"++Nat.show(count)++",\"values\":"++list_json(~Core.event_type(),~Core.notice_json,values)++"}"
def batches_json(values:List<&2,KQ.Batch<Core.event_type()>>) -> String:
  list_json(~KQ.Batch<Core.event_type()>,~batch_json,values)
def queue_json(value:KQ.Queue<Core.event_type()>) -> String:
  match value:
    case KQ.Queue{front,back,size,dropped}:"{\"front\":"++batches_json(front)++",\"back\":"++batches_json(back)++",\"size\":"++Nat.show(size)++",\"dropped\":"++Nat.show(dropped)++"}"
def domain_key_json(value:KD.DescriptorKey<Core.Schema>) -> String:
  match value:
    case KD.DeclaredKey{id}:U32.show(id)
def domain_json(value:KD.Domain<Core.Schema,Core.event_type()>) -> String:
  match value:
    case KD.Domain{key,queue,readers}:"{\"key\":"++domain_key_json(key)++",\"readers\":"++list_json(~U32,~U32.show,readers)++",\"queue\":"++queue_json(queue)++"}"
def domains_json(values:List<&2,KD.Domain<Core.Schema,Core.event_type()>>) -> String:
  list_json(~KD.Domain<Core.Schema,Core.event_type()>,~domain_json,values)

type FailureImage is Data:
  FailureImage{routeTick:Nat,tick:Nat,frameStart:Nat,boundary:Nat,capacity:Nat,nextReader:U32,domains:List<&2,KD.Domain<Core.Schema,Core.event_type()>>,positions:List<&2,Ev.Position>}
def failure_image(typed:Family.State<Core.Publication,Core.family_type(),Unit>,failures:Mixed.Failures<Core.Schema,Core.Publication>,routeTick:Nat) -> Mixed.State<Core.Schema,Core.Publication,Core.family_type(),Unit> & FailureImage:
  match failures:
    case Mixed.Failures{+domains,+positions,+tick,+frameStart,+boundary,+capacity,+nextReader}:
      (Mixed.State{typed,Mixed.Failures{domains,positions,tick,frameStart,boundary,capacity,nextReader}},FailureImage{routeTick,tick,frameStart,boundary,capacity,nextReader,domains,positions})
def state_image(state:Mixed.State<Core.Schema,Core.Publication,Core.family_type(),Unit>,routeTick:Nat) -> Mixed.State<Core.Schema,Core.Publication,Core.family_type(),Unit> & FailureImage:
  match state:
    case Mixed.State{typed,failures}:failure_image(typed,failures,routeTick)
def failure_image_json(value:FailureImage) -> String:
  match value:
    case FailureImage{routeTick,tick,frameStart,boundary,capacity,nextReader,domains,positions}:"{\"routeTick\":"++Nat.show(routeTick)++",\"tick\":"++Nat.show(tick)++",\"frameStart\":"++Nat.show(frameStart)++",\"boundary\":"++Nat.show(boundary)++",\"capacity\":"++Nat.show(capacity)++",\"nextReader\":"++U32.show(nextReader)++",\"positions\":"++positions_json(positions)++",\"domains\":"++domains_json(domains)++"}"

def snapshot_state(world:Core.world_type(),worldImage:Core.WorldObservation,state:Mixed.State<Core.Schema,Core.Publication,Core.family_type(),Unit> & FailureImage,routeTick:Nat) -> Core.context_type() & String:
  match state:
    case (state,image):(Route.Runtime{world,state,routeTick},"{\"shared\":"++failure_image_json(image)++",\"world\":"++Core.world_observation_json(worldImage)++"}")
def snapshot_parts(world:Core.world_type() & Core.WorldObservation,state:Mixed.State<Core.Schema,Core.Publication,Core.family_type(),Unit> & FailureImage,routeTick:Nat) -> Core.context_type() & String:
  match world state:
    case (world,worldImage) state:snapshot_state(world,worldImage,state,routeTick)
def snapshot_context(context:Core.context_type()) -> Core.context_type() & String:
  match context:
    case Route.Runtime{world,state,+routeTick}:snapshot_parts(Core.world_snapshot(world),state_image(state,routeTick),routeTick)

def phase_record_cursor(context:Core.context_type(),state:String,cursor:Core.provider_type() & U32,phase:String,status:String,error:String,view:String) -> Core.context_type() & (Core.provider_type() & String):
  match cursor:
    case (provider,queryCursor):
      (context,(provider,"{\"phase\":"++quoted(phase)++",\"status\":"++quoted(status)++",\"error\":"++error++",\"queryCursor\":"++U32.show(queryCursor)++",\"view\":"++view++",\"state\":"++state++"}"))
def phase_record_join(snapshot:Core.context_type() & String,cursor:Core.provider_type() & U32,phase:String,status:String,error:String,view:String) -> Core.context_type() & (Core.provider_type() & String):
  match snapshot:
    case (context,state):phase_record_cursor(context,state,cursor,phase,status,error,view)
def phase_record(context:Core.context_type(),provider:Core.provider_type(),phase:String,status:String,error:String,view:String) -> Core.context_type() & (Core.provider_type() & String):
  phase_record_join(snapshot_context(context),Core.provider_cursor(provider),phase,status,error,view)
def append_row(rows:String,row:String) -> String:
  match rows:
    case "":row
    case _:rows++","++row

def final_output(report:Core.MutationReport,rows:String) -> String:
  "{\"mutation\":"++Core.mutation_json(report)++",\"observations\":["++rows++"]}"
def retry_completed(report:Core.MutationReport,rows:String,observed:Core.context_type() & (Core.provider_type() & String)) -> String:
  match observed:
    case (context,(provider,row)):final_output(report,append_row(rows,row))
def retry_failed(report:Core.MutationReport,rows:String,context:Core.context_type(),provider:Core.provider_type(),error:U32,view:Core.all_view()) -> String:
  retry_completed(report,rows,phase_record(context,provider,"retry","failed",U32.show(error),Core.view_json(view)))
def retry_completed_run(report:Core.MutationReport,rows:String,context:Core.context_type(),provider:Core.provider_type(),view:Core.all_view()) -> String:
  retry_completed(report,rows,phase_record(context,provider,"retry","completed","null",Core.view_json(view)))
def retry_result(report:Core.MutationReport,rows:String,result:Core.run_type()) -> String:
  match result:
    case Ordinary.RunCompleted{context,provider,output}:retry_completed_run(report,rows,context,provider,output)
    case Ordinary.RunFailed{context,provider,error,output}:retry_failed(report,rows,context,provider,error,output)
    case Ordinary.RunInvalidReader{_,_}:final_output(report,append_row(rows,"{\"phase\":\"retry\",\"status\":\"invalidReader\"}"))
    case Ordinary.RunRegistrationRejected{_,_,_}:final_output(report,append_row(rows,"{\"phase\":\"retry\",\"status\":\"registrationRejected\"}"))
    case Ordinary.RunSkipped{_,_}:final_output(report,append_row(rows,"{\"phase\":\"retry\",\"status\":\"skipped\"}"))

def second_frame(report:Core.MutationReport,rows:String,context:Core.context_type(),provider:Core.provider_type()) -> String:
  retry_result(report,rows,Core.run_all(provider,context,False{}))
def second_frame_observed(report:Core.MutationReport,rows:String,observed:Core.context_type() & (Core.provider_type() & String)) -> String:
  match observed:
    case (context,(provider,row)):second_frame(report,append_row(rows,row),context,provider)
def frame_record(context:Core.context_type(),provider:Core.provider_type(),phase:String) -> Core.context_type() & (Core.provider_type() & String):
  phase_record(context,provider,phase,"frame","null","null")
def apply_second_frame(report:Core.MutationReport,rows:String,context:Core.context_type(),provider:Core.provider_type()) -> String:
  second_frame_observed(report,rows,frame_record(Mixed.frame_failures(~Core.Schema,~Core.store_type(),~Unit,~Core.Publication,~Core.family_type(),~Unit,context),provider,"frame-2"))
def first_frame_observed(report:Core.MutationReport,rows:String,observed:Core.context_type() & (Core.provider_type() & String)) -> String:
  match observed:
    case (context,(provider,row)):apply_second_frame(report,append_row(rows,row),context,provider)
def apply_first_frame(report:Core.MutationReport,rows:String,context:Core.context_type(),provider:Core.provider_type()) -> String:
  first_frame_observed(report,rows,frame_record(Mixed.frame_failures(~Core.Schema,~Core.store_type(),~Unit,~Core.Publication,~Core.family_type(),~Unit,context),provider,"frame-1"))

def first_failed_record(report:Core.MutationReport,rows:String,observed:Core.context_type() & (Core.provider_type() & String)) -> String:
  match observed:
    case (context,(provider,row)):apply_first_frame(report,append_row(rows,row),context,provider)
def first_failed_run(report:Core.MutationReport,rows:String,result:Core.run_type()) -> String:
  match result:
    case Ordinary.RunFailed{context,provider,error,output}:
      first_failed_record(report,rows,phase_record(context,provider,"A-first-after-barrier","failed",U32.show(error),Core.view_json(output)))
    case Ordinary.RunCompleted{context,provider,output}:
      final_output(report,append_row(rows,"{\"phase\":\"A-first-after-barrier\",\"status\":\"unexpectedlyCompleted\",\"view\":"++Core.view_json(output)++"}"))
    case Ordinary.RunInvalidReader{_,_}:final_output(report,append_row(rows,"{\"phase\":\"A-first-after-barrier\",\"status\":\"invalidReader\"}"))
    case Ordinary.RunRegistrationRejected{_,_,_}:final_output(report,append_row(rows,"{\"phase\":\"A-first-after-barrier\",\"status\":\"registrationRejected\"}"))
    case Ordinary.RunSkipped{_,_}:final_output(report,append_row(rows,"{\"phase\":\"A-first-after-barrier\",\"status\":\"skipped\"}"))
def first_barrier_record(report:Core.MutationReport,observed:Core.context_type() & (Core.provider_type() & String)) -> String:
  match observed:
    case (context,(provider,row)):first_failed_run(report,row,Core.run_all(provider,context,True{}))
def after_barrier(context:Core.context_type(),provider:Core.provider_type(),report:Core.MutationReport) -> String:
  first_barrier_record(report,phase_record(context,provider,"after-real-barrier-before-first-callback","published","null","null"))

def scheduled_observation(provider:Core.provider_type(),scheduled:Core.context_type() & Core.MutationReport) -> String:
  match scheduled:
    case (context,report):after_barrier(Core.barrier_context(context),provider,report)
def define_result(entity:W.Handle<Core.Schema>,defined:Core.definition_type()) -> String:
  match defined:
    case Ordinary.DefinitionRegistered{context,provider}:scheduled_observation(provider,Core.schedule_relation(context,entity))
    case Ordinary.DefinitionRejected{_,_,_}:"{\"status\":\"definitionRejected\"}"
    case Ordinary.DefinitionDisposalRejected{_,_,_}:"{\"status\":\"definitionDisposalRejected\"}"
def setup_ready(state:Core.Setup) -> String:
  match state:
    case Core.Ready{context,entity}:define_result(entity,Core.define_all(context,"A"))
    case Core.SetupFailed{}:"{\"status\":\"setupFailed\"}"
def main() -> IO(Unit):
  IO.print(setup_ready(Core.setup()))
