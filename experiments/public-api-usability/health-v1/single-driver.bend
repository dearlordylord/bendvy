import Base
import single-query.bend as Single
import ../../../examples/scheduled-health/schema.bend as S
import ../../../examples/scheduled-health/components.bend as D
import ../../../examples/scheduled-health/system.bend as Decay
import ../../../examples/scheduled-health/application.bend as Original
import ../../../src/ecs/world.bend as W
def Application() -> Type:Single.Application<S.Schema,S.Store,Unit,Unit,Decay.PairOps,Unit,Decay.Error,D.Health,Decay.declaration(),Decay.decay_body>
def ResultType() -> Type:Single.ExecutionResult<S.Schema,S.Store,Unit,Unit,Decay.PairOps,Unit,Decay.Error,D.Health,Decay.declaration(),Decay.decay_body>
def Installed() -> Type:Single.Installation<S.Schema,S.Store,Unit,Unit,Decay.PairOps,Unit,Decay.Error,D.Health,Decay.declaration(),Decay.decay_body>
def run(app:Application()) -> ResultType():Single.run(~S.Schema,~S.Store,~Unit,~Unit,~Decay.PairOps,~Unit,~Decay.Error,~D.Health,~Decay.declaration(),~Decay.decay_body,app)
def finish(handle:W.Handle<S.Schema>,app:Application()) -> String:
  match app:
    case Single.Application{world,_}:Original.finished(world,handle)
def tick_done(next:Application() -> String,tick:U32,value:ResultType()) -> String:
  match value:
    case Single.Finished{app,rows}:"tick=" ++ U32.show(tick) ++ " health=" ++ Original.values(rows) ++ "\n" ++ next(app)
    case _:"ERROR: single-system run"
def ticks(left:Nat,+tick:U32,handle:W.Handle<S.Schema>,app:Application()) -> String:
  match left:
    case 0n:finish(handle,app)
    case 1n++rest:tick_done(a => ticks(rest,(tick + 1:U32),handle,a),tick,run(app))
def replanned(handle:W.Handle<S.Schema>,value:Installed()) -> String:
  match value:
    case Single.Installed{app}:ticks(6n,1,handle,app)
    case _:"ERROR: replan"
def pending(handle:W.Handle<S.Schema>,value:ResultType()) -> String:
  match value:
    case Single.Finished{app,rows}:"before-barrier=" ++ Original.values(rows) ++ "\n" ++ replanned(handle,Single.replan(~S.Schema,~S.Store,~Unit,~Unit,~Decay.PairOps,~Unit,~Decay.Error,~D.Health,~Decay.declaration(),~Decay.decay_body,app,True{}))
    case _:"ERROR: pending"
def installed(handle:W.Handle<S.Schema>,value:Installed()) -> String:
  match value:
    case Single.Installed{app}:pending(handle,run(app))
    case _:"ERROR: install"
def start(world:S.World(),handle:W.Handle<S.Schema>) -> String:
  installed(handle,Single.install(~S.Schema,~S.Store,~Unit,~Unit,~Decay.PairOps,~Unit,~Decay.Error,~D.Health,~Decay.declaration(),~Decay.decay_body,world,Unit{},"Health decay","decay",False{}))
