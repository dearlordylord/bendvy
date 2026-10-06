import Base
import ./query.bend as Q

def invoke(~P:Type,~done:Unit -> P,arg:Unit) -> P:
  done(arg)
def bad(~P:Type,p:P) -> P:
  invoke(~P,~(_ => p),Unit{})
