import Base
import ./schema-fragments.bend as F
import ./ordinary-schema.bend as Schema
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
def ordinary() -> List<&2,String>:
  +values=List.append(&2,F.Entry<S>,plain(),List.append(&2,F.Entry<S>,transient(),bare()))
  ["all=" ++ entries(values),"component=" ++ entries(F.filter_kind(~S,values,F.Component{})),"resource=" ++ entries(F.filter_kind(~S,values,F.Resource{})),"valid=" ++ validation(F.validate(~S,values)),"duplicate=" ++ validation(F.validate(~S,List.append(&2,F.Entry<S>,plain(),plain()))),"required-bare=" ++ validation(F.requirements(~S,F.bare_entries(~S,values),values)),"required-classified=" ++ validation(F.requirements(~S,values,F.bare_entries(~S,values))),observed(merge(F.merge(~S,~Array<U32>,~Array<U32>,F.Fragment{plain(),ALeaf{41}},F.Fragment{List.append(&2,F.Entry<S>,transient(),bare()),ALeaf{43}}))),observed(merge(F.merge(~S,~Array<U32>,~Array<U32>,F.Fragment{plain(),ALeaf{41}},F.Fragment{plain(),ALeaf{43}})))]

def controls() -> List<&2,String>:
  ["bare:empty=" ++ validation(F.check_one_bare(~S,[],F.Entry{F.Component{},"a","A"})),"bare:key-only=" ++ validation(F.check_one_bare(~S,[F.Entry{F.Component{},"a","A"}],F.Entry{F.Component{},"a","B"})),"bare:name-only=" ++ validation(F.check_one_bare(~S,[F.Entry{F.Component{},"a","A"}],F.Entry{F.Component{},"b","A"})),"bare:both-key-wins=" ++ validation(F.check_one_bare(~S,[F.Entry{F.Component{},"a","A"}],F.Entry{F.Component{},"a","A"})),"bare:classified-seen=" ++ validation(F.check_one_bare(~S,[F.Classified{F.Component{},"a","A",F.Plain{}}],F.Entry{F.Component{},"a","B"})),"bare:classified-item=" ++ validation(F.check_one_bare(~S,[F.Entry{F.Component{},"a","A"}],F.Classified{F.Component{},"b","A",F.Transient{}})),"bare:classified-both=" ++ validation(F.check_one_bare(~S,[F.Classified{F.Component{},"a","A",F.Constructed{}}],F.Classified{F.Component{},"a","A",F.Plain{}})),"bare:mixed-later=" ++ validation(F.check_one_bare(~S,[F.Classified{F.Resource{},"a","A",F.Transient{}},F.Entry{F.Component{},"x","X"},F.Classified{F.Component{},"a","A",F.Plain{}}],F.Classified{F.Component{},"a","B",F.Constructed{}})),"bare:same-domain-0=" ++ validation(F.check_one_bare(~S,[F.Entry{F.Component{},"a","A"}],F.Classified{F.Component{},"a","B",F.Plain{}})),"bare:same-domain-1=" ++ validation(F.check_one_bare(~S,[F.Entry{F.Resource{},"a","A"}],F.Classified{F.Resource{},"a","B",F.Plain{}})),"bare:same-domain-2=" ++ validation(F.check_one_bare(~S,[F.Entry{F.Event{},"a","A"}],F.Classified{F.Event{},"a","B",F.Plain{}})),"bare:same-domain-3=" ++ validation(F.check_one_bare(~S,[F.Entry{F.Relation{},"a","A"}],F.Classified{F.Relation{},"a","B",F.Plain{}})),"bare:same-domain-4=" ++ validation(F.check_one_bare(~S,[F.Entry{F.Service{},"a","A"}],F.Classified{F.Service{},"a","B",F.Plain{}})),"bare:cross-domain-0=" ++ validation(F.check_one_bare(~S,[F.Classified{F.Component{},"a","A",F.Plain{}}],F.Classified{F.Resource{},"a","A",F.Transient{}})),"bare:cross-domain-1=" ++ validation(F.check_one_bare(~S,[F.Classified{F.Resource{},"a","A",F.Plain{}}],F.Classified{F.Event{},"a","A",F.Transient{}})),"bare:cross-domain-2=" ++ validation(F.check_one_bare(~S,[F.Classified{F.Event{},"a","A",F.Plain{}}],F.Classified{F.Relation{},"a","A",F.Transient{}})),"bare:cross-domain-3=" ++ validation(F.check_one_bare(~S,[F.Classified{F.Relation{},"a","A",F.Plain{}}],F.Classified{F.Service{},"a","A",F.Transient{}})),"bare:cross-domain-4=" ++ validation(F.check_one_bare(~S,[F.Classified{F.Service{},"a","A",F.Plain{}}],F.Classified{F.Component{},"a","A",F.Transient{}})),"normalized:empty=" ++ validation(F.check_one(~S,[],F.Entry{F.Component{},"a","A"})),"normalized:key-only=" ++ validation(F.check_one(~S,[F.Entry{F.Component{},"a","A"}],F.Entry{F.Component{},"a","B"})),"normalized:name-only=" ++ validation(F.check_one(~S,[F.Entry{F.Component{},"a","A"}],F.Entry{F.Component{},"b","A"})),"normalized:both-key-wins=" ++ validation(F.check_one(~S,[F.Entry{F.Component{},"a","A"}],F.Entry{F.Component{},"a","A"})),"normalized:classified-seen=" ++ validation(F.check_one(~S,[F.Classified{F.Component{},"a","A",F.Plain{}}],F.Entry{F.Component{},"a","B"})),"normalized:classified-item=" ++ validation(F.check_one(~S,[F.Entry{F.Component{},"a","A"}],F.Classified{F.Component{},"b","A",F.Transient{}})),"normalized:classified-both=" ++ validation(F.check_one(~S,[F.Classified{F.Component{},"a","A",F.Constructed{}}],F.Classified{F.Component{},"a","A",F.Plain{}})),"normalized:mixed-later=" ++ validation(F.check_one(~S,[F.Classified{F.Resource{},"a","A",F.Transient{}},F.Entry{F.Component{},"x","X"},F.Classified{F.Component{},"a","A",F.Plain{}}],F.Classified{F.Component{},"a","B",F.Constructed{}})),"normalized:same-domain-0=" ++ validation(F.check_one(~S,[F.Entry{F.Component{},"a","A"}],F.Classified{F.Component{},"a","B",F.Plain{}})),"normalized:same-domain-1=" ++ validation(F.check_one(~S,[F.Entry{F.Resource{},"a","A"}],F.Classified{F.Resource{},"a","B",F.Plain{}})),"normalized:same-domain-2=" ++ validation(F.check_one(~S,[F.Entry{F.Event{},"a","A"}],F.Classified{F.Event{},"a","B",F.Plain{}})),"normalized:same-domain-3=" ++ validation(F.check_one(~S,[F.Entry{F.Relation{},"a","A"}],F.Classified{F.Relation{},"a","B",F.Plain{}})),"normalized:same-domain-4=" ++ validation(F.check_one(~S,[F.Entry{F.Service{},"a","A"}],F.Classified{F.Service{},"a","B",F.Plain{}})),"normalized:cross-domain-0=" ++ validation(F.check_one(~S,[F.Classified{F.Component{},"a","A",F.Plain{}}],F.Classified{F.Resource{},"a","A",F.Transient{}})),"normalized:cross-domain-1=" ++ validation(F.check_one(~S,[F.Classified{F.Resource{},"a","A",F.Plain{}}],F.Classified{F.Event{},"a","A",F.Transient{}})),"normalized:cross-domain-2=" ++ validation(F.check_one(~S,[F.Classified{F.Event{},"a","A",F.Plain{}}],F.Classified{F.Relation{},"a","A",F.Transient{}})),"normalized:cross-domain-3=" ++ validation(F.check_one(~S,[F.Classified{F.Relation{},"a","A",F.Plain{}}],F.Classified{F.Service{},"a","A",F.Transient{}})),"normalized:cross-domain-4=" ++ validation(F.check_one(~S,[F.Classified{F.Service{},"a","A",F.Plain{}}],F.Classified{F.Component{},"a","A",F.Transient{}})),"validate:empty-order=" ++ validation(F.validate(~S,[])),"validate:mixed-order=" ++ validation(F.validate(~S,[F.Classified{F.Component{},"a","A",F.Plain{}},F.Classified{F.Resource{},"a","A",F.Transient{}}])),"validate:name-before-later-key=" ++ validation(F.validate(~S,[F.Entry{F.Component{},"a","A"},F.Classified{F.Component{},"b","B",F.Plain{}},F.Classified{F.Component{},"c","B",F.Transient{}},F.Entry{F.Component{},"a","C"}])),"validate:component-before-resource=" ++ validation(F.validate(~S,[F.Entry{F.Resource{},"r","R"},F.Classified{F.Resource{},"r","S",F.Plain{}},F.Classified{F.Component{},"a","A",F.Plain{}},F.Classified{F.Component{},"b","A",F.Transient{}}])),"validate:retained-classification=" ++ validation(F.validate(~S,[F.Classified{F.Service{},"s","S",F.Constructed{}},F.Classified{F.Event{},"e","E",F.Transient{}},F.Classified{F.Relation{},"r","R",F.Plain{}}]))]
def main() -> List<&2,String>:
  List.append(&2,String,ordinary(),controls())
