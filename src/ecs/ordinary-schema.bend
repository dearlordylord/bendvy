import Base
import ./decode-data.bend as D
import ./persistence-declaration.bend as Persist
import ./owner-product.bend as Product
import ./ordinary-declaration.bend as Component
import ./column.bend as Col
import ./schema-fragments.bend as Fragment
# One normal declaration drives schema entries and physical Store/Resources types.
# Names default to the one ordinary key. No user metadata or lens input.
# Detached schema description indexed by the component and resource owner
# types. It contains no world or payloads; product derives matching owner
# products. Raw Schema construction is trusted metadata setup.
type Schema<-S:Data,-Store:Type,-Resources:Type> is Data:
  Schema{entries:List<&2,Fragment.Entry<S>>}
# Schema-scoped resource key and payload type, without a resource instance.
# Convert with resource_schema before composition and collision validation.
type Resource<-S:Data,-P:Type> is Data:
  Resource{key:String}
# Declare a resource key for schema S and payload P. No payload is allocated
# or provisioned and duplicate keys are not checked until schema validation.
def resource(~S:Data,~P:Type,key:String) -> Resource<S,P>:
  Resource{key}
# Return the authored resource key; does not read a runtime resource.
def resource_key(~S:Data,~P:Type,value:Resource<S,P>) -> String:
  match value:
    case Resource{key}:key
# Describe a component declaration and derive its column owner type.
# Does not allocate storage or validate collisions. Compose with product and
# validate before App attachment; examples/scheduled-health/registration.bend.
def component(~S:Data,~P:Type,declaration:Component.Declaration<S,P>) -> Schema<S,Col.Column<S,P>,Unit>:
  +key=Component.key(~S,~P,declaration)
  Schema{[Fragment.Entry{Fragment.Component{},key,key}]}
# Describe a resource and derive its resource owner type without constructing
# its payload. This declaration supplies metadata, not a live resource value.
def resource_schema(~S:Data,~P:Type,declaration:Resource<S,P>) -> Schema<S,Unit,P>:
  +key=resource_key(~S,~P,declaration)
  Schema{[Fragment.Entry{Fragment.Resource{},key,key}]}
# Return schema entries in composition order, detached from all world owners.
def entries(~S:Data,~C:Type,~R:Type,value:Schema<S,C,R>) -> List<&2,Fragment.Entry<S>>:
  match value:
    case Schema{entries}:entries
# Compose two same-schema declarations, appending entries left then right
# and deriving matching component/resource Product.Owner types. Supports
# arbitrary affine payload types; does not copy payloads or reject collisions.
def product(~S:Data,~LC:Type,~LR:Type,~RC:Type,~RR:Type,left:Schema<S,LC,LR>,right:Schema<S,RC,RR>) -> Schema<S,Product.Owner<LC,RC>,Product.Owner<LR,RR>>:
  Schema{List.append(&2,Fragment.Entry<S>,entries(~S,~LC,~LR,left),entries(~S,~RC,~RR,right))}
# Check composed declaration entries for schema conflicts, returning the
# structured Fragment.Validation result. No World exists in this operation;
# validation neither constructs payloads nor proves trusted storage lens laws.
def validate(~S:Data,~C:Type,~R:Type,value:Schema<S,C,R>) -> Fragment.Validation:
  Fragment.validate_loop(~S,entries(~S,~C,~R,value),[])

# Declare a component with plain persistence classification from its bound
# extension. Records the classification and derives the owner type; does not
# execute codecs, validate input, allocate payloads or export a snapshot.
# Use the matching persistence declaration and identity when composing a schema.
def component_plain(~S:Data,~P:Type,~identity:Component.Declaration<S,P>,extension:Persist.Plain<S,P,identity>) -> Schema<S,Col.Column<S,P>,Unit>:
  +key=Component.key(~S,~P,identity)
  Schema{[Fragment.Classified{Fragment.Component{},key,key,Fragment.Plain{}}]}

# Declare a component with transient persistence classification from its bound
# extension. Records the classification and derives the owner type; does not
# execute codecs, validate input, allocate payloads or export a snapshot.
# Use the matching persistence declaration and identity when composing a schema.
def component_transient(~S:Data,~P:Type,~identity:Component.Declaration<S,P>,extension:Persist.Transient<S,P,identity>) -> Schema<S,Col.Column<S,P>,Unit>:
  +key=Component.key(~S,~P,identity)
  Schema{[Fragment.Classified{Fragment.Component{},key,key,Fragment.Transient{}}]}

# Declare a component with constructed persistence classification from its bound
# extension. Records the classification and derives the owner type; does not
# execute codecs, validate input, allocate payloads or export a snapshot.
# Use the matching persistence declaration and identity when composing a schema.
def component_constructed(~S:Data,~P:Type,~identity:Component.Declaration<S,P>,~project:P -> P & D.Raw,extension:Persist.Constructed<S,P,identity,project>) -> Schema<S,Col.Column<S,P>,Unit>:
  +key=Component.key(~S,~P,identity)
  Schema{[Fragment.Classified{Fragment.Component{},key,key,Fragment.Constructed{}}]}

# Declare a resource with plain persistence classification from its bound
# extension. Records the classification and derives the owner type; does not
# execute codecs, validate input, allocate payloads or export a snapshot.
# Use the matching persistence declaration and identity when composing a schema.
def resource_plain(~S:Data,~P:Type,~identity:Component.Declaration<S,P>,extension:Persist.Plain<S,P,identity>) -> Schema<S,Unit,P>:
  +key=Component.key(~S,~P,identity)
  Schema{[Fragment.Classified{Fragment.Resource{},key,key,Fragment.Plain{}}]}

# Declare a resource with transient persistence classification from its bound
# extension. Records the classification and derives the owner type; does not
# execute codecs, validate input, allocate payloads or export a snapshot.
# Use the matching persistence declaration and identity when composing a schema.
def resource_transient(~S:Data,~P:Type,~identity:Component.Declaration<S,P>,extension:Persist.Transient<S,P,identity>) -> Schema<S,Unit,P>:
  +key=Component.key(~S,~P,identity)
  Schema{[Fragment.Classified{Fragment.Resource{},key,key,Fragment.Transient{}}]}

# Declare a resource with constructed persistence classification from its bound
# extension. Records the classification and derives the owner type; does not
# execute codecs, validate input, allocate payloads or export a snapshot.
# Use the matching persistence declaration and identity when composing a schema.
def resource_constructed(~S:Data,~P:Type,~identity:Component.Declaration<S,P>,~project:P -> P & D.Raw,extension:Persist.Constructed<S,P,identity,project>) -> Schema<S,Unit,P>:
  +key=Component.key(~S,~P,identity)
  Schema{[Fragment.Classified{Fragment.Resource{},key,key,Fragment.Constructed{}}]}
