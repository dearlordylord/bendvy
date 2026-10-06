import Base

def invoke(~P:Type,~done:Unit -> P,arg:Unit) -> P & P:
  (done(arg),done(Unit{}))
def uninstantiated(~P:Type,p:P) -> P & P:
  invoke(~P,~(_ => p),Unit{})
