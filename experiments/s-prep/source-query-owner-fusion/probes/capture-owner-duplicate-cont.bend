import Base
import /tmp/bendvy-threehour-query-transport/experiments/s-prep/source-query-owner-fusion/overlay-cont-v2/experiments/s-integrate/query.bend as Q

def invoke(~P:Type,~done:Unit -> P,arg:Unit) -> P & P:
  (done(arg),done(Unit{}))
def bad(~P:Type,p:P) -> P & P:
  invoke(~P,~(_ => p),Unit{})
