import Base
import /workspace/formal-proofs/bendvy/src/ecs/schema-fragments.bend as F
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-schema.bend as Schema
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-declaration.bend as I
import /workspace/formal-proofs/bendvy/src/ecs/persistence-declaration.bend as P
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-dump-builtin.bend as Builtin
type S is Data:
  S{}
def identity() -> I.Declaration<S,Unit>:I.component(~S,~Unit,"A")
def plain() -> List<&2,F.Entry<S>>:Schema.entries(~S,~Col.Column<S,Unit>,~Unit,Schema.component_plain(~S,~Unit,~identity(),P.plain(~S,~Unit,~identity())))
def transient() -> List<&2,F.Entry<S>>:Schema.entries(~S,~Unit,~Unit,Schema.resource_transient(~S,~Unit,~identity(),P.transient(~S,~Unit,~identity())))
def bare() -> List<&2,F.Entry<S>>:Schema.entries(~S,~Col.Column<S,Unit>,~Unit,Schema.component(~S,~Unit,I.component(~S,~Unit,"B")))
def kind(value:F.RegistryKind) -> String:
  match value:
    case F.Component{}:"Component"
    case F.Resource{}:"Resource"
    case F.Event{}:"Event"
    case F.Relation{}:"Relation"
    case F.Service{}:"Service"
def persistence(value:F.PersistenceKind) -> String:
  match value:
    case F.Plain{}:"Plain"
    case F.Transient{}:"Transient"
    case F.Constructed{}:"Constructed"
def entry(value:F.Entry<S>) -> String:
  match value:
    case F.Entry{tag,key,name}:kind(tag) ++ ":" ++ key ++ ":" ++ name ++ ":bare"
    case F.Classified{tag,key,name,extension}:kind(tag) ++ ":" ++ key ++ ":" ++ name ++ ":" ++ persistence(extension)
def entries(values:List<&2,F.Entry<S>>) -> String:
  match values:
    case []:"end"
    case value <> rest:entry(value) ++ ";" ++ entries(rest)
def error(value:F.Error) -> String:
  match value:
    case F.DuplicateKey{tag,key}:"DuplicateKey:" ++ kind(tag) ++ ":" ++ key
    case F.DuplicateName{tag,name}:"DuplicateName:" ++ kind(tag) ++ ":" ++ name
    case F.UndeclaredDescriptor{tag,key,name}:"Undeclared:" ++ kind(tag) ++ ":" ++ key ++ ":" ++ name
def validation(value:F.Validation) -> String:
  match value:
    case F.Valid{}:"Valid"
    case F.Invalid{reason}:error(reason)
def fragment_observed(+values:List<&2,F.Entry<S>>,result:Array<U32> & String) -> F.Fragment<S,Array<U32>> & String:
  match result:
    case (owner,text):(F.Fragment{values,owner},entries(values) ++ "|owner=" ++ text)
def fragment(value:F.Fragment<S,Array<U32>>) -> F.Fragment<S,Array<U32>> & String:
  match value:
    case F.Fragment{values,owner}:fragment_observed(values,Builtin.array(owner))
def rejected(+reason:F.Error,left:F.Fragment<S,Array<U32>> & String,right:F.Fragment<S,Array<U32>> & String) -> F.Merge<S,Array<U32>,Array<U32>> & String:
  match left right:
    case (left,a),(right,b):(F.Rejected{reason,left,right},error(reason) ++ "|left=" ++ a ++ "|right=" ++ b)
def merged(+values:List<&2,F.Entry<S>>,left:Array<U32> & String,right:Array<U32> & String) -> F.Merge<S,Array<U32>,Array<U32>> & String:
  match left right:
    case (left,a),(right,b):(F.Merged{F.Fragment{values,(left,right)}},"Merged:" ++ entries(values) ++ "|left=" ++ a ++ "|right=" ++ b)
def merge(value:F.Merge<S,Array<U32>,Array<U32>>) -> F.Merge<S,Array<U32>,Array<U32>> & String:
  match value:
    case F.Merged{F.Fragment{values,(left,right)}}:merged(values,Builtin.array(left),Builtin.array(right))
    case F.Rejected{reason,left,right}:rejected(reason,fragment(left),fragment(right))
def observed(result:F.Merge<S,Array<U32>,Array<U32>> & String) -> String:
  match result:
    case (_,text):text
def main() -> List<&2,String>:
  +values=List.append(&2,F.Entry<S>,plain(),List.append(&2,F.Entry<S>,transient(),bare()))
  ["all=" ++ entries(values),"component=" ++ entries(F.filter_kind(~S,values,F.Component{})),"resource=" ++ entries(F.filter_kind(~S,values,F.Resource{})),"valid=" ++ validation(F.validate(~S,values)),"duplicate=" ++ validation(F.validate(~S,List.append(&2,F.Entry<S>,plain(),plain()))),"required-bare=" ++ validation(F.requirements(~S,F.bare_entries(~S,values),values)),"required-classified=" ++ validation(F.requirements(~S,values,F.bare_entries(~S,values))),observed(merge(F.merge(~S,~Array<U32>,~Array<U32>,F.Fragment{plain(),ALeaf{41}},F.Fragment{List.append(&2,F.Entry<S>,transient(),bare()),ALeaf{43}}))),observed(merge(F.merge(~S,~Array<U32>,~Array<U32>,F.Fragment{plain(),ALeaf{41}},F.Fragment{plain(),ALeaf{43}})))]
