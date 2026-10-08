import Base
import ../../fixture-schema.bend as D
import fixture-matrix.bend as Matrix
import fixture-snapshot.bend as Snap
import ../../core-v1/src/ecs/world.bend as W
import ../../core-v1/src/ecs/check.bend as K
import ../../core-v1/src/ecs/relation-commands.bend as A

type Phase<S:Data> is Data:
  Phase{before:Snap.Snapshot<S>,after:Snap.Snapshot<S>,queries:List<&2,Matrix.Entry<S>>}
def after(~S:Data,before:Snap.Snapshot<S>,queries:List<&2,Matrix.Entry<S>>,observed:K.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & Snap.Snapshot<S>) -> K.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & Phase<S>:
  (frame,last)=observed
  (frame,Phase{before,last,queries})
def queried(~S:Data,before:Snap.Snapshot<S>,observed:K.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & List<&2,Matrix.Entry<S>>) -> K.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & Phase<S>:
  (frame,queries)=observed
  after(~S,before,queries,Snap.observe(~S,frame))
def before(~S:Data,+targets:List<&2,W.Handle<S>>,observed:K.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & Snap.Snapshot<S>) -> K.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & Phase<S>:
  (frame,first)=observed
  queried(~S,first,Matrix.matrix(~S,targets,frame))
def phase(~S:Data,frame:K.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>>,targets:List<&2,W.Handle<S>>) -> K.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & Phase<S>:
  before(~S,targets,Snap.observe(~S,frame))

# Trusted diagnostic boundary emits full detached observations; genuine Check.run
# conditions are wired separately and receive opaque declared capability owners.
type Observed<S:Data> is Type:
  Observed{world:W.World<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>>,value:Result<&2,&2,String,Phase<S>>}
def observed(~S:Data,result:K.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & Phase<S>) -> Observed<S>:
  match result:
    case (K.Frame{world},value):Observed{world,Done{value}}
def observe_world(~S:Data,targets:List<&2,W.Handle<S>>,world:W.World<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>>) -> Observed<S>:
  observed(~S,phase(~S,K.Frame{world},targets))
