import Base
import ./leaf.bend as Leaf
import ./declaration.bend as Decl
import /workspace/formal-proofs/bendvy/experiments/public-decode/typed.bend as D
import /workspace/formal-proofs/bendvy/src/ecs/schema-fragments.bend as Fragment
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy-worktrees/parity-61-audit/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/canonical-component-declaration.bend as Canonical
import /workspace/formal-proofs/bendvy-worktrees/parity-61-audit/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/canonical-product.bend as Product
import /workspace/formal-proofs/bendvy-worktrees/parity-61-audit/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/canonical-schema-product.bend as Ordinary

# The same schema factory derives ordinary inventory, physical product and save
# eligibility/closed traversal. Runtime recipes live in the leaf owners.
type Schema<-S:Data,-C:Type,-R:Type,-eligible:Bool,-components:U32 -> C -> C & List<&2,D.Field>,-resources:R -> R & List<&2,D.Field>> is Data:
  Schema{ordinary:Ordinary.Schema<S,C,R>}
def unit_component(id:U32,value:Unit) -> Unit & List<&2,D.Field>:
  (value,[])
def unit_resource(value:Unit) -> Unit & List<&2,D.Field>:
  (value,[])
def plain_component_fields(~S:Data,~P:Type,id:U32,value:Col.Column<S,P>) -> Col.Column<S,P> & List<&2,D.Field>:
  (value,[])
def entry(~S:Data,~P:Type,~identity:Canonical.Declaration<S,P>,kind:Fragment.RegistryKind) -> Fragment.Entry<S>:
  +key=Canonical.key(~S,~P,identity)
  Fragment.Entry{kind,key,key}
def component(~S:Data,~P:Type,~identity:Canonical.Declaration<S,P>,~project:P -> P & D.Raw) -> Schema<S,Leaf.Component<S,P,identity,project>,Unit,True{},Leaf.component_fields(~S,~P,~identity,~project),unit_resource>:
  Schema{Ordinary.Schema{[entry(~S,~P,~identity,Fragment.Component{})]}}
def transient_component(~S:Data,~P:Type,~identity:Canonical.Declaration<S,P>) -> Schema<S,Leaf.TransientComponent<S,P,identity>,Unit,True{},Leaf.transient_component_fields(~S,~P,~identity),unit_resource>:
  Schema{Ordinary.Schema{[entry(~S,~P,~identity,Fragment.Component{})]}}
def plain_component(~S:Data,~P:Type,~identity:Canonical.Declaration<S,P>) -> Schema<S,Col.Column<S,P>,Unit,False{},plain_component_fields(~S,~P),unit_resource>:
  Schema{Ordinary.Schema{[entry(~S,~P,~identity,Fragment.Component{})]}}
def resource(~S:Data,~P:Type,~identity:Canonical.Declaration<S,P>,~project:P -> P & D.Raw) -> Schema<S,Unit,Leaf.Resource<S,P,identity,project>,True{},unit_component,Leaf.resource_fields(~S,~P,~identity,~project)>:
  Schema{Ordinary.Schema{[entry(~S,~P,~identity,Fragment.Resource{})]}}
def transient_resource(~S:Data,~P:Type,~identity:Canonical.Declaration<S,P>) -> Schema<S,Unit,Leaf.TransientResource<S,P,identity>,True{},unit_component,Leaf.transient_resource_fields(~S,~P,~identity)>:
  Schema{Ordinary.Schema{[entry(~S,~P,~identity,Fragment.Resource{})]}}
def plain_resource_fields(~P:Type,value:P) -> P & List<&2,D.Field>:
  (value,[])
def plain_resource(~S:Data,~P:Type,~identity:Canonical.Declaration<S,P>) -> Schema<S,Unit,P,False{},unit_component,plain_resource_fields(~P)>:
  Schema{Ordinary.Schema{[entry(~S,~P,~identity,Fragment.Resource{})]}}
def inventory(~S:Data,~C:Type,~R:Type,~eligible:Bool,~components:U32 -> C -> C & List<&2,D.Field>,~resources:R -> R & List<&2,D.Field>,schema:Schema<S,C,R,eligible,components,resources>) -> Ordinary.Schema<S,C,R>:
  match schema:
    case Schema{ordinary}:ordinary
