import Base
import fixture-schema.bend as D
import fixture-matrix.bend as Matrix
import fixture-snapshot.bend as Snap
import core-v1/src/ecs/world.bend as W
import core-v1/src/ecs/inspector.bend as I
import core-v1/src/ecs/relation-commands.bend as A

type Phase<S:Data> is Data:
  Phase{before:Snap.Snapshot<S>,after:Snap.Snapshot<S>,queries:List<&2,Matrix.Entry<S>>}
def after(~S:Data,before:Snap.Snapshot<S>,queries:List<&2,Matrix.Entry<S>>,observed:I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & Snap.Snapshot<S>) -> I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & Phase<S>:
  (frame,last)=observed
  (frame,Phase{before,last,queries})
def queried(~S:Data,before:Snap.Snapshot<S>,observed:I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & List<&2,Matrix.Entry<S>>) -> I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & Phase<S>:
  (frame,queries)=observed
  after(~S,before,queries,Snap.observe(~S,frame))
def before(~S:Data,+targets:List<&2,W.Handle<S>>,observed:I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & Snap.Snapshot<S>) -> I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & Phase<S>:
  (frame,first)=observed
  queried(~S,first,Matrix.matrix(~S,targets,frame))
def phase(~S:Data,frame:I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>>,targets:List<&2,W.Handle<S>>) -> I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & Phase<S>:
  before(~S,targets,Snap.observe(~S,frame))
type PhaseCap<-H:Type,-S:Data> is Type:
  PhaseCap{observe:H -> List<&2,W.Handle<S>> -> H & Phase<S>}
def operation(~H:Type,~S:Data,cap:PhaseCap<H,S>) -> H -> List<&2,W.Handle<S>> -> H & Phase<S>:
  match cap:
    case PhaseCap{observe}:observe
def done(~H:Type,~S:Data,observed:H & Phase<S>) -> H & Result<&2,&2,String,Phase<S>>:
  (owner,value)=observed
  (owner,Done{value})
def body(~S:Data,~H:Type,~cap:PhaseCap<H,S>,targets:List<&2,W.Handle<S>>,owner:H) -> H & Result<&2,&2,String,Phase<S>>:
  done(~H,~S,operation(~H,~S,cap)(owner,targets))
def provide(~S:Data) -> PhaseCap<I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>>,S>:
  PhaseCap{phase(~S)}
def inspect(~S:Data,instance:I.Instance<S>,targets:List<&2,W.Handle<S>>,world:W.World<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>>) -> I.Observed<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>,String,Phase<S>>:
  I.run(~S,~A.Store<S,D.Components<S>>,~D.Resources,~A.Notice<S,D.FixtureEvent>,~(H => PhaseCap<H,S>),~List<&2,W.Handle<S>>,~String,~Phase<S>,~I.Plan{provide(~S)},~body(~S),instance,targets,world)
