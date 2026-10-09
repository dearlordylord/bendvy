import Base
# One nominal ordinary schema declaration shared by component grants and gates.
# No storage/runtime imports and no user debug metadata adapter.
type Declaration<-S:Data,-P:Type> is Data:
  Declaration{key:String}
def component(~S:Data,~P:Type,key:String) -> Declaration<S,P>:
  Declaration{key}
def key(~S:Data,~P:Type,declaration:Declaration<S,P>) -> String:
  match declaration:
    case Declaration{key}:key
