import Base
import /tmp/bendvy-threehour-query-transport/experiments/s-prep/source-query-owner-fusion/overlay-cont-v2/experiments/s-integrate/query.bend as Q

def invoke(~P:Type,~done:Unit -> P,arg:Unit) -> P:
  done(arg)
def bad(~P:Type,p:P) -> P:
  invoke(~P,~(_ => p),Unit{})
