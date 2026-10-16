import Base
import ./fixture.bend as F
import ./host.bend as H
import ../ordinary-v1/payload.bend as P
import ../ordinary-v1/observe.bend as R
import ../family-readers-v1/observe.bend as Readers
import ../families-v1/fixture.bend as Pub
import ../families-v1/observe.bend as Publisher
import ../../../src/ecs/system.bend as Sys

def args_done(+delta:U32,+failValue:U32,value:Array<U32> & String) -> F.Args & String:
  (scratch,text) = value
  (F.Args{delta,failValue,scratch},"args(delta=" ++ U32.show(delta) ++ ",failValue=" ++ U32.show(failValue) ++ ",scratch=" ++ text ++ ")")
def args(value:F.Args) -> F.Args & String:
  match value:
    case F.Args{+delta,+failValue,scratch}:args_done(delta,failValue,R.payload(scratch))
def observation_done(+projection:P.Projection,value:Array<U32> & String) -> F.Observation & String:
  (entered,text) = value
  (F.Observation{projection,entered},"observation(projection=" ++ R.projection(projection) ++ ",entered=" ++ text ++ ")")
def observation(value:F.Observation) -> F.Observation & String:
  match value:
    case F.Observation{projection,entered}:observation_done(projection,R.payload(entered))
def observations_join(head:F.Observation & String,tail:List<F.Observation> & String) -> List<F.Observation> & String:
  match head tail:
    case (head,h),(tail,t):(head <> tail,h ++ ";" ++ t)
def observation_rows(value:List<F.Observation>) -> List<F.Observation> & String:
  match value:
    case []:([],"[]")
    case head <> tail:observations_join(observation(head),observation_rows(tail))
def observations_done(value:List<F.Observation> & String) -> String:
  (_,text) = value
  text
def observations(value:List<F.Observation>) -> String:observations_done(observation_rows(value))
def registry(~S:Data,value:F.Registry(~S)) -> F.Registry(~S) & String:
  match value:
    case Sys.Registry{+ns,+id,+name,+access,+cursor}:(Sys.Registry{ns,id,name,access,cursor},"registry(ns=" ++ U32.show(ns) ++ ",id=" ++ U32.show(id) ++ ",name=" ++ name ++ ",access=" ++ List.show(~&2,~String,~R.text,access) ++ ",cursor=" ++ U32.show(cursor) ++ ")")
def snapshot_join(~S:Data,label:String,a:F.Runtime(~S) & String,b:F.Runtime(~S) & String,c:Pub.PublisherRegistry(~S) & String,d:F.Reader(~S) & String,e:F.Registry(~S) & String,f:F.Args & String,g:List<F.Observation> & String) -> H.Host<S> & String:
  match a b c d e f g:
    case (a,at),(b,bt),(c,ct),(d,dt),(e,et),(f,ft),(g,gt):(H.Host{a,b,c,d,e,f,g},label ++ "|" ++ at ++ "|foreign=" ++ bt ++ "|publisher=" ++ ct ++ "|reader=" ++ dt ++ "|" ++ et ++ "|" ++ ft ++ "|observations=" ++ gt)
def snapshot(~S:Data,label:String,value:H.Host<S>) -> H.Host<S> & String:
  match value:
    case H.Host{a,b,c,d,e,f,g}:snapshot_join(~S,label,Readers.runtime(~S,a),Readers.runtime(~S,b),Publisher.publisher_registry(~S,c),Readers.reader_a(~S,d),registry(~S,e),args(f),observation_rows(g))
