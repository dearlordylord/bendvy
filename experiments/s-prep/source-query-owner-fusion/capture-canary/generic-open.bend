import Base

def invoke(~P:Type,~done:Unit -> P,arg:Unit) -> P:
  done(arg)
def uninstantiated(~P:Type,p:P) -> P:
  invoke(~P,~(_ => p),Unit{})
