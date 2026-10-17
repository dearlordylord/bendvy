import Base
import ./fixture.bend as F
import ../selector-handlers-v1/fixture.bend as BaseF
import ../selector-handlers-v1/observe.bend as Common
import ../../../../src/ecs/ordinary-app-machine-initialization-field.bend as Initial
import ../../../../src/ecs/machine-stream.bend as St

def app_join(~S:Data,reader:St.Reader<S,BaseF.Mode>,observed:BaseF.Application(~S) & String) -> F.Application(~S) & String:
  match reader observed:
    case St.Reader{+namespace,+id},(app,text):(Initial.Application{app,St.Reader{namespace,id}},"InitialApp{markerReader{namespace=" ++ U32.show(namespace) ++ ";id=" ++ U32.show(id) ++ "};" ++ text ++ "}")
def app(~S:Data,value:F.Application(~S)) -> F.Application(~S) & String:
  match value:
    case Initial.Application{inner,reader}:app_join(~S,reader,Common.app(~S,inner))
def ready(~S:Data,observed:F.Application(~S) & String) -> F.Setup<S> & String:
  match observed:
    case (app,text):(F.Ready{app},"Ready{" ++ text ++ "}")
def base_rejected(~S:Data,observed:BaseF.Setup<S> & String) -> F.Setup<S> & String:
  match observed:
    case (result,text):(F.BaseRejected{result},"BaseRejected{" ++ text ++ "}")
def marker_rejected(~S:Data,observed:BaseF.Application(~S) & String) -> F.Setup<S> & String:
  match observed:
    case (app,text):(F.MarkerRejected{app},"MarkerRejected{" ++ text ++ "}")
def setup(~S:Data,value:F.Setup<S>) -> F.Setup<S> & String:
  match value:
    case F.Ready{inner}:ready(~S,app(~S,inner))
    case F.BaseRejected{result}:base_rejected(~S,Common.setup(~S,result))
    case F.MarkerRejected{inner}:marker_rejected(~S,Common.app(~S,inner))
