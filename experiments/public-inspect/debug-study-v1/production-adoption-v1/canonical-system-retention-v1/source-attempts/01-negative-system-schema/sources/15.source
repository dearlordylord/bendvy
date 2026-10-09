import Base
import ./persistence-declaration.bend as Decl
import ./snapshot-gate.bend as Gate
import ./decode-data.bend as D
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import ./ordinary-declaration.bend as Canonical

# Ordinary leaf stores retain the recipe used for admission and export together.
type Component<-S:Data,-P:Type,-identity:Canonical.Declaration<S,P>,-project:P -> P & D.Raw> is Type:
  Component{column:Col.Column<S,P>,declaration:Decl.Constructed<S,P,identity,project>}
type TransientComponent<-S:Data,-P:Type,-identity:Canonical.Declaration<S,P>> is Type:
  TransientComponent{column:Col.Column<S,P>,declaration:Decl.Transient<S,P,identity>}
type Resource<-S:Data,-P:Type,-identity:Canonical.Declaration<S,P>,-project:P -> P & D.Raw> is Type:
  Resource{owner:P,declaration:Decl.Constructed<S,P,identity,project>}
type TransientResource<-S:Data,-P:Type,-identity:Canonical.Declaration<S,P>> is Type:
  TransientResource{owner:P,declaration:Decl.Transient<S,P,identity>}
def factory(~S:Data,~P:Type,~identity:Canonical.Declaration<S,P>,~project:P -> P & D.Raw,declaration:Decl.Constructed<S,P,identity,project>) -> Gate.Gate<S,P,identity>:
  Gate.persisted(~S,~P,~identity,Decl.codec(~S,~P,~identity,~project,declaration),project)
def fields(field:Gate.Field) -> List<&2,D.Field>:
  match field:
    case Gate.Omitted{_}:[]
    case Gate.Saved{name,value}:[D.Field{name,value}]
def component_restored(~S:Data,~P:Type,~identity:Canonical.Declaration<S,P>,~project:P -> P & D.Raw,declaration:Decl.Constructed<S,P,identity,project>,observed:Col.Column<S,P> & Maybe<&2,Gate.Field>) -> Component<S,P,identity,project> & List<&2,D.Field>:
  match observed:
    case (column,None{}):(Component{column,declaration},[])
    case (column,Some{field}):(Component{column,declaration},fields(field))
def component_taken(~S:Data,~P:Type,~identity:Canonical.Declaration<S,P>,~project:P -> P & D.Raw,+id:U32,+declaration:Decl.Constructed<S,P,identity,project>,outcome:Col.SwapOutcome<S,P>) -> Component<S,P,identity,project> & List<&2,D.Field>:
  match outcome:
    case Col.Rejected{column,_}:(Component{column,declaration},[])
    case Col.Accepted{column,None{}}:(Component{column,declaration},[])
    case Col.Accepted{column,Some{owner}}:component_restored(~S,~P,~identity,~project,declaration,Col.viewed(~S,~P,~Gate.Field,Gate.export_owner(~S,~P,~identity,factory(~S,~P,~identity,~project,declaration),owner),column,id))
def component_fields_owned(~S:Data,~P:Type,~identity:Canonical.Declaration<S,P>,~project:P -> P & D.Raw,+id:U32,value:Component<S,P,identity,project>) -> Component<S,P,identity,project> & List<&2,D.Field>:
  match value:
    case Component{column,declaration}:component_taken(~S,~P,~identity,~project,id,declaration,Col.swap(~S,~P,column,id,None{}))
def component_fields(~S:Data,~P:Type,~identity:Canonical.Declaration<S,P>,~project:P -> P & D.Raw,id:U32,value:Component<S,P,identity,project>) -> Component<S,P,identity,project> & List<&2,D.Field>:
  component_fields_owned(~S,~P,~identity,~project,id,value)
def transient_component_fields(~S:Data,~P:Type,~identity:Canonical.Declaration<S,P>,id:U32,value:TransientComponent<S,P,identity>) -> TransientComponent<S,P,identity> & List<&2,D.Field>:
  (value,[])
def resource_restored(~S:Data,~P:Type,~identity:Canonical.Declaration<S,P>,~project:P -> P & D.Raw,declaration:Decl.Constructed<S,P,identity,project>,observed:P & Gate.Field) -> Resource<S,P,identity,project> & List<&2,D.Field>:
  match observed:
    case (owner,field):(Resource{owner,declaration},fields(field))
def resource_fields(~S:Data,~P:Type,~identity:Canonical.Declaration<S,P>,~project:P -> P & D.Raw,value:Resource<S,P,identity,project>) -> Resource<S,P,identity,project> & List<&2,D.Field>:
  match value:
    case Resource{owner,+declaration}:resource_restored(~S,~P,~identity,~project,declaration,Gate.export_owner(~S,~P,~identity,factory(~S,~P,~identity,~project,declaration),owner))
def transient_resource_fields(~S:Data,~P:Type,~identity:Canonical.Declaration<S,P>,value:TransientResource<S,P,identity>) -> TransientResource<S,P,identity> & List<&2,D.Field>:
  (value,[])
