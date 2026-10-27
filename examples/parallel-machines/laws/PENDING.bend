import Base
import ../pending-boundaries.bend as Ordinary
import ../../../src/ecs/dependency-application.bend as App
import ../../../src/ecs/dependency-executor.bend as Exec
import ../../../src/ecs/execution-deferred-schedule.bend as Deferred

# Draft, unapproved and unproved. Actual affine applications are erased logical
# binders, not reusable owner projections. These laws constrain result handling,
# not whole-run scheduling, physical concurrency or native IO.

# Guarantees: the actual machine completion hook preserves a Stopped application,
# its error and observations, including every queued owner it already contains.
# Bevy code: https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_app/src/sub_app.rs#L145-L159
# Bevy behavior: tracker maintenance follows the default schedule update.
# Bend adaptation: explicit Stopped does not complete an update or rotate stream
# generations. This does not prove the executor chooses Stopped on escalation.
law stopped_machine_application_exact:
  for -app:Ordinary.Application()
  for -error:String
  for -events:List<&2,Exec.Observation<String,String>>
  {Ordinary.completed((app,App.Stopped{error,events})) == (app,App.Stopped{error,events}) : (Ordinary.Application() & App.Report<String,String>)}

# Guarantees: disabling final application returns the actual completed state and
# unapplied IDs intact, for every affine state and actual application callback.
# Bevy code: https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_ecs/src/schedule/executor/single_threaded.rs#L138-L166
# Bevy behavior: the executor distinguishes running systems from applying their
# deferred buffers. This law does not establish that IDs enumerate every buffer;
# the ordinary consumer separately calls Schedule.pending on actual owners.
law final_off_retains_actual_state:
  for -Actual:Type
  for -Error:Data
  for -Out:Data
  for -apply:List<&2,U32> -> Actual -> Actual & List<&2,U32>
  for -state:Actual
  for -unapplied:List<&2,U32>
  for -events:List<&2,Exec.Observation<Error,Out>>
  {Deferred.finish(~Actual,~Error,~Out,~apply,False{},state,unapplied,events) == Deferred.Outcome{Exec.Finished{state,events},unapplied} : Deferred.Outcome<Actual,Error,Out>}
