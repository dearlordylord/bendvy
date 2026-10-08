import Base
import fixture-matrix.bend as Matrix
import fixture-format.bend as Format
import ../../fixture-schema.bend as D
import ../../core-v1/src/ecs/check.bend as K
import ../../core-v1/src/ecs/world.bend as W
import ../../core-v1/src/ecs/relation-commands.bend as A
import ../../core-v1/src/ecs/string-equality.bend as Eq

# Gameplay condition sees opaque H and its declared full-matrix read only.
type Reads<-H:Type,-S:Data> is Type:
  Reads{observe:H -> List<&2,W.Handle<S>> -> H & String}
type Args<S:Data> is Data:
  Args{targets:List<&2,W.Handle<S>>,expected:String}
def operation(~H:Type,~S:Data,cap:Reads<H,S>) -> H -> List<&2,W.Handle<S>> -> H & String:
  match cap:
    case Reads{observe}:observe
def matrix_items(~S:Data,+namespace:U32,entries:List<&2,Matrix.Entry<S>>) -> String:
  match entries:
    case []:""
    case entry <> []:Format.entry(~S,namespace,entry)
    case entry <> rest:Format.entry(~S,namespace,entry) ++ ", " ++ matrix_items(~S,namespace,rest)
def rendered(~S:Data,namespace:U32,result:K.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & List<&2,Matrix.Entry<S>>) -> K.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & String:
  (frame,entries)=result
  (frame,"[" ++ matrix_items(~S,namespace,entries) ++ "]")
def named(~S:Data,result:W.World<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & U32) -> K.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & U32:
  (world,namespace)=result
  (K.Frame{world},namespace)
def frame_namespace(~S:Data,frame:K.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>>) -> K.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & U32:
  match frame:
    case K.Frame{world}:named(~S,W.namespace(~S,~A.Store<S,D.Components<S>>,~D.Resources,~A.Notice<S,D.FixtureEvent>,world))
def read_named(~S:Data,targets:List<&2,W.Handle<S>>,result:K.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & U32) -> K.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & String:
  (frame,namespace)=result
  rendered(~S,namespace,Matrix.matrix(~S,targets,frame))
def read(~S:Data,targets:List<&2,W.Handle<S>>,frame:K.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>>) -> K.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & String:
  read_named(~S,targets,frame_namespace(~S,frame))
def compared(~H:Type,expected:String,result:H & String) -> H & Bool:
  (owner,actual)=result
  (owner,Eq.equal(expected,actual))
def body(~S:Data,~H:Type,~cap:Reads<H,S>,args:Args<S>,owner:H) -> H & Bool:
  match args:
    case Args{targets,expected}:compared(~H,expected,operation(~H,~S,cap)(owner,targets))
def provide(~S:Data) -> Reads<K.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>>,S>:
  Reads{frame => targets => read(~S,targets,frame)}
def ready(~S:Data,world:W.World<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>>) -> W.World<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & List<&2,String>:
  (world,[])
def run(~S:Data,args:Args<S>,world:W.World<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>>) -> K.Checked<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>>:
  K.run(~S,~A.Store<S,D.Components<S>>,~D.Resources,~A.Notice<S,D.FixtureEvent>,~(H => Reads<H,S>),~Args<S>,~body(~S),~K.Plan{ready(~S),provide(~S)},args,world)
