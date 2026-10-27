import Base
import ./execution-composer-layout.bend as Layout
import ./ordinary-declaration.bend as C
import ./persistence-declaration.bend as Decl
import ./schema-fragments.bend as Fragment
import ./decode-data.bend as D
import ./owner-product.bend as Product
import ./execution-resource-policy.bend as Policy

# An ordinary persistence extension determines its canonical storage layout and
# retained declarations together. A separate route/key catalog is not accepted.
type Plan is Type:
  Empty{}
  Plain{P:Type,V:Data,refresh:P -> P & V,key:String}
  Transient{P:Type,V:Data,refresh:P -> P & V,key:String}
  Constructed{P:Type,V:Data,refresh:P -> P & V,key:String,project:P -> P & D.Raw}
  Pair{left:Plan,right:Plan}
def layout(plan:Plan) -> Layout.Layout:
  match plan:
    case Empty{}:Layout.EmptyLayout{}
    case Plain{P,V,refresh,key}:Layout.ClassifiedLayoutLeaf{P,V,refresh,key,Fragment.Plain{},Policy.Ordinary{}}
    case Transient{P,V,refresh,key}:Layout.ClassifiedLayoutLeaf{P,V,refresh,key,Fragment.Transient{},Policy.Ordinary{}}
    case Constructed{P,V,refresh,key,_}:Layout.ClassifiedLayoutLeaf{P,V,refresh,key,Fragment.Constructed{},Policy.Ordinary{}}
    case Pair{left,right}:Layout.LayoutPair{layout(left),layout(right)}
def identity(~S:Data,~P:Type,key:String) -> C.Declaration<S,P>:C.Declaration{key}
def unused(~P:Type,owner:P) -> P & D.Raw:(owner,D.Missing{})
def Recipes(~S:Data,plan:Plan) -> Type:
  match plan:
    case Empty{}:Unit
    case Plain{P,_,_,key}:Decl.Plain<S,P,identity(~S,~P,key)>
    case Transient{P,_,_,key}:Decl.Transient<S,P,identity(~S,~P,key)>
    case Constructed{P,_,_,key,project}:Decl.Constructed<S,P,identity(~S,~P,key),project>
    case Pair{left,right}:Product.Owner<Recipes(~S,left),Recipes(~S,right)>
def first(left:Maybe<&2,String>,right:Maybe<&2,String>) -> Maybe<&2,String>:
  match left:
    case Some{key}:Some{key}
    case None{}:right
def ineligible(plan:Plan) -> Maybe<&2,String>:
  match plan:
    case Empty{}:None{}
    case Plain{_,_,_,key}:Some{key}
    case Transient{_,_,_,_}:None{}
    case Constructed{_,_,_,_,_}:None{}
    case Pair{left,right}:first(ineligible(left),ineligible(right))
type Schema<-S:Data,-components:Plan,-resources:Plan> is Type:
  Schema{components:Recipes(~S,components),resources:Recipes(~S,resources)}
