import Base
import inspector-metadata.bend as Meta
import inspector.bend as I
import capabilities.bend as Cap

# Trusted schema authoring only, like component.Family's indexed closed lens.
# The index binds which projection constructs this grant; it does not prove an
# arbitrary caller's numeric token/name/lens assertion is canonical or truthful.
type Declaration<-S:Data,-R:Type,-V:Data,-Token:Data,-project:R -> R & V> is Data:
  Declaration{id:U32,name:String}
type BoundRead<-S:Data,-H:Type,-V:Data> is Type:
  BoundRead{metadata:Meta.Resource<S>,read:Cap.ValueRead<H,V>}

def canonical(~S:Data,~R:Type,~V:Data,~Token:Data,~project:R -> R & V,id:U32,name:String) -> Declaration<S,R,V,Token,project>:
  Declaration{id,name}
def bind(~S:Data,~Store:Type,~R:Type,~E:Data,~V:Data,~Token:Data,~project:R -> R & V,declaration:Declaration<S,R,V,Token,project>) -> BoundRead<S,I.Frame<S,Store,R,E>,V>:
  match declaration:
    case Declaration{id,name}:BoundRead{Meta.Resource{id,name},I.read_resource(~S,~Store,~R,~E,~V,~project)}
def split(~S:Data,~H:Type,~V:Data,bound:BoundRead<S,H,V>) -> Meta.Resource<S> & Cap.ValueRead<H,V>:
  match bound:
    case BoundRead{metadata,read}:(metadata,read)
