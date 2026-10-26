import Base
import ./ordinary-declaration.bend as Identity
import ./ordinary-schema.bend as Resource
import ./schema-fragments.bend as Fragment
import ./chunk-column.bend as Column
import ./owner-product.bend as Product
import ./persistence-declaration.bend as Persist
import ./decode-data.bend as Decode

type FragmentSchema<-S:Data,-C:Type,-R:Type> is Data:
  FragmentSchema{entries:List<&2,Fragment.Entry<S>>}
def component(~S:Data,~P:Type,identity:Identity.Declaration<S,P>) -> FragmentSchema<S,Column.Column<S,P>,Unit>:
  +key=Identity.key(~S,~P,identity)
  FragmentSchema{[Fragment.Entry{Fragment.Component{},key,key}]}
def resource(~S:Data,~P:Type,identity:Resource.Resource<S,P>) -> FragmentSchema<S,Unit,P>:
  +key=Resource.resource_key(~S,~P,identity)
  FragmentSchema{[Fragment.Entry{Fragment.Resource{},key,key}]}
def component_plain(~S:Data,~P:Type,~identity:Identity.Declaration<S,P>,extension:Persist.Plain<S,P,identity>) -> FragmentSchema<S,Column.Column<S,P>,Unit>:
  +key=Identity.key(~S,~P,identity)
  FragmentSchema{[Fragment.Classified{Fragment.Component{},key,key,Fragment.Plain{}}]}
def component_transient(~S:Data,~P:Type,~identity:Identity.Declaration<S,P>,extension:Persist.Transient<S,P,identity>) -> FragmentSchema<S,Column.Column<S,P>,Unit>:
  +key=Identity.key(~S,~P,identity)
  FragmentSchema{[Fragment.Classified{Fragment.Component{},key,key,Fragment.Transient{}}]}
def component_constructed(~S:Data,~P:Type,~identity:Identity.Declaration<S,P>,~project:P -> P & Decode.Raw,extension:Persist.Constructed<S,P,identity,project>) -> FragmentSchema<S,Column.Column<S,P>,Unit>:
  +key=Identity.key(~S,~P,identity)
  FragmentSchema{[Fragment.Classified{Fragment.Component{},key,key,Fragment.Constructed{}}]}
def entries(~S:Data,~C:Type,~R:Type,value:FragmentSchema<S,C,R>) -> List<&2,Fragment.Entry<S>>:
  match value:
    case FragmentSchema{entries}:entries
def product(~S:Data,~LC:Type,~LR:Type,~RC:Type,~RR:Type,left:FragmentSchema<S,LC,LR>,right:FragmentSchema<S,RC,RR>) -> FragmentSchema<S,Product.Owner<LC,RC>,Product.Owner<LR,RR>>:
  FragmentSchema{List.append(&2,Fragment.Entry<S>,entries(~S,~LC,~LR,left),entries(~S,~RC,~RR,right))}
def fragment(~S:Data,~C:Type,~R:Type,~Provisions:Type,schema:FragmentSchema<S,C,R>,provisions:Provisions) -> Fragment.Fragment<S,Provisions>:
  Fragment.Fragment{entries(~S,~C,~R,schema),provisions}
