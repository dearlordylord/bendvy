import Base
import /workspace/formal-proofs/bendvy/src/ecs/decode-data.bend as D
import /workspace/formal-proofs/bendvy/src/ecs/persistence-declaration.bend as Persist
import /workspace/formal-proofs/bendvy/src/ecs/owner-product.bend as Product
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-declaration.bend as Component
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import schema-fragments.bend as Fragment
# One normal declaration drives schema entries and physical Store/Resources types.
# Names default to the one ordinary key. No user metadata or lens input.
type Schema<-S:Data,-Store:Type,-Resources:Type> is Data:
  Schema{entries:List<&2,Fragment.Entry<S>>}
type Resource<-S:Data,-P:Type> is Data:
  Resource{key:String}
def resource(~S:Data,~P:Type,key:String) -> Resource<S,P>:
  Resource{key}
def resource_key(~S:Data,~P:Type,value:Resource<S,P>) -> String:
  match value:
    case Resource{key}:key
def component(~S:Data,~P:Type,declaration:Component.Declaration<S,P>) -> Schema<S,Col.Column<S,P>,Unit>:
  +key=Component.key(~S,~P,declaration)
  Schema{[Fragment.Entry{Fragment.Component{},key,key}]}
def resource_schema(~S:Data,~P:Type,declaration:Resource<S,P>) -> Schema<S,Unit,P>:
  +key=resource_key(~S,~P,declaration)
  Schema{[Fragment.Entry{Fragment.Resource{},key,key}]}
def entries(~S:Data,~C:Type,~R:Type,value:Schema<S,C,R>) -> List<&2,Fragment.Entry<S>>:
  match value:
    case Schema{entries}:entries
def product(~S:Data,~LC:Type,~LR:Type,~RC:Type,~RR:Type,left:Schema<S,LC,LR>,right:Schema<S,RC,RR>) -> Schema<S,Product.Owner<LC,RC>,Product.Owner<LR,RR>>:
  Schema{List.append(&2,Fragment.Entry<S>,entries(~S,~LC,~LR,left),entries(~S,~RC,~RR,right))}
def validate(~S:Data,~C:Type,~R:Type,value:Schema<S,C,R>) -> Fragment.Validation:
  Fragment.validate_loop(~S,entries(~S,~C,~R,value),[])

def component_plain(~S:Data,~P:Type,~identity:Component.Declaration<S,P>,extension:Persist.Plain<S,P,identity>) -> Schema<S,Col.Column<S,P>,Unit>:
  +key=Component.key(~S,~P,identity)
  Schema{[Fragment.Classified{Fragment.Component{},key,key,Fragment.Plain{}}]}

def component_transient(~S:Data,~P:Type,~identity:Component.Declaration<S,P>,extension:Persist.Transient<S,P,identity>) -> Schema<S,Col.Column<S,P>,Unit>:
  +key=Component.key(~S,~P,identity)
  Schema{[Fragment.Classified{Fragment.Component{},key,key,Fragment.Transient{}}]}

def component_constructed(~S:Data,~P:Type,~identity:Component.Declaration<S,P>,~project:P -> P & D.Raw,extension:Persist.Constructed<S,P,identity,project>) -> Schema<S,Col.Column<S,P>,Unit>:
  +key=Component.key(~S,~P,identity)
  Schema{[Fragment.Classified{Fragment.Component{},key,key,Fragment.Constructed{}}]}

def resource_plain(~S:Data,~P:Type,~identity:Component.Declaration<S,P>,extension:Persist.Plain<S,P,identity>) -> Schema<S,Unit,P>:
  +key=Component.key(~S,~P,identity)
  Schema{[Fragment.Classified{Fragment.Resource{},key,key,Fragment.Plain{}}]}

def resource_transient(~S:Data,~P:Type,~identity:Component.Declaration<S,P>,extension:Persist.Transient<S,P,identity>) -> Schema<S,Unit,P>:
  +key=Component.key(~S,~P,identity)
  Schema{[Fragment.Classified{Fragment.Resource{},key,key,Fragment.Transient{}}]}

def resource_constructed(~S:Data,~P:Type,~identity:Component.Declaration<S,P>,~project:P -> P & D.Raw,extension:Persist.Constructed<S,P,identity,project>) -> Schema<S,Unit,P>:
  +key=Component.key(~S,~P,identity)
  Schema{[Fragment.Classified{Fragment.Resource{},key,key,Fragment.Constructed{}}]}
