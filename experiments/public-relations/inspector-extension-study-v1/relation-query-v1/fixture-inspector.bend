import Base
import fixture-schema.bend as D
import fixture-matrix.bend as Matrix
import core-v1/src/ecs/inspector.bend as I
import core-v1/src/ecs/world.bend as W
import core-v1/src/ecs/relation-commands.bend as A

# Diagnostic fixture capability; gameplay body sees opaque H, never Frame/World.
type MatrixCap<-H:Type,-S:Data> is Type:
  MatrixCap{observe:H -> List<&2,W.Handle<S>> -> H & List<&2,Matrix.Entry<S>>}
def operation(~H:Type,~S:Data,cap:MatrixCap<H,S>) -> H -> List<&2,W.Handle<S>> -> H & List<&2,Matrix.Entry<S>>:
  match cap:
    case MatrixCap{observe}:observe
def done(~H:Type,~S:Data,observed:H & List<&2,Matrix.Entry<S>>) -> H & Result<&2,&2,String,List<&2,Matrix.Entry<S>>>:
  (owner,entries)=observed
  (owner,Done{entries})
def body(~S:Data,~H:Type,~cap:MatrixCap<H,S>,targets:List<&2,W.Handle<S>>,owner:H) -> H & Result<&2,&2,String,List<&2,Matrix.Entry<S>>>:
  done(~H,~S,operation(~H,~S,cap)(owner,targets))
def provide(~S:Data) -> MatrixCap<I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>>,S>:
  MatrixCap{frame => targets => Matrix.matrix(~S,targets,frame)}
def inspect(~S:Data,instance:I.Instance<S>,targets:List<&2,W.Handle<S>>,world:W.World<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>>) -> I.Observed<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>,String,List<&2,Matrix.Entry<S>>>:
  I.run(~S,~A.Store<S,D.Components<S>>,~D.Resources,~A.Notice<S,D.FixtureEvent>,~(H => MatrixCap<H,S>),~List<&2,W.Handle<S>>,~String,~List<&2,Matrix.Entry<S>>,~I.Plan{provide(~S)},~body(~S),instance,targets,world)
