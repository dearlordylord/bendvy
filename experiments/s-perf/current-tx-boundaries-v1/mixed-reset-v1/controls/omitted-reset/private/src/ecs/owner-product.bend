import Base
# Generic heterogeneous owner product, not a registry metadata adapter.
# Library-generated paths retain the physical type through arbitrary nesting.
type Owner<-L:Type,-R:Type> is Type:
  Owner{left:L,right:R}
type Path is Data:
  Left{}
  Right{}
def Part(~L:Type,~R:Type,path:Path) -> Type:
  match path:
    case Left{}:L
    case Right{}:R
def Rest(~L:Type,~R:Type,path:Path) -> Type:
  match path:
    case Left{}:R
    case Right{}:L
def take(~L:Type,~R:Type,path:Path,owner:Owner<L,R>) -> Rest(~L,~R,path) & Part(~L,~R,path):
  match path owner:
    case Left{} Owner{left,right}:(right,left)
    case Right{} Owner{left,right}:(left,right)
def put(~L:Type,~R:Type,path:Path,rest:Rest(~L,~R,path),part:Part(~L,~R,path)) -> Owner<L,R>:
  match path:
    case Left{}:Owner{part,rest}
    case Right{}:Owner{rest,part}
# Canonical setup composes these fields; user systems only receive opaque caps.
type Lens<-Whole:Type,-Part:Type,-Rest:Type> is Type:
  Lens{take:Whole -> Rest & Part,put:Rest -> Part -> Whole}
def lens(~L:Type,~R:Type,~path:Path) -> Lens<Owner<L,R>,Part(~L,~R,path),Rest(~L,~R,path)>:
  Lens{owner=>take(~L,~R,path,owner),rest=>part=>put(~L,~R,path,rest,part)}
def get_field(~W:Type,~P:Type,~R:Type,value:Lens<W,P,R>) -> W -> R & P:
  match value:
    case Lens{get,_}:get
def put_field(~W:Type,~P:Type,~R:Type,value:Lens<W,P,R>) -> R -> P -> W:
  match value:
    case Lens{_,put}:put
def joined(~A:Type,~B:Type,~P:Type,outer:A,observed:B & P) -> (A & B) & P:
  match observed:
    case (inner,part):((outer,inner),part)
def inward(~W:Type,~M:Type,~A:Type,~P:Type,~B:Type,~inner:Lens<M,P,B>,observed:A & M) -> (A & B) & P:
  match observed:
    case (rest,middle):joined(~A,~B,~P,rest,get_field(~M,~P,~B,inner)(middle))
def composed_take(~W:Type,~M:Type,~A:Type,~P:Type,~B:Type,~outer:Lens<W,M,A>,~inner:Lens<M,P,B>,owner:W) -> (A & B) & P:
  inward(~W,~M,~A,~P,~B,~inner,get_field(~W,~M,~A,outer)(owner))
def composed_put(~W:Type,~M:Type,~A:Type,~P:Type,~B:Type,~outer:Lens<W,M,A>,~inner:Lens<M,P,B>,rest:A & B,part:P) -> W:
  match rest:
    case (outerRest,innerRest):put_field(~W,~M,~A,outer)(outerRest,put_field(~M,~P,~B,inner)(innerRest,part))
def compose(~W:Type,~M:Type,~A:Type,~P:Type,~B:Type,~outer:Lens<W,M,A>,~inner:Lens<M,P,B>) -> Lens<W,P,A & B>:
  Lens{owner=>composed_take(~W,~M,~A,~P,~B,~outer,~inner,owner),rest=>part=>composed_put(~W,~M,~A,~P,~B,~outer,~inner,rest,part)}
