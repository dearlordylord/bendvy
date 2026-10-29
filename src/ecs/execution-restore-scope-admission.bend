import Base
import ./lifetime-scope.bend as Scope
import ./entity-key.bend as Key
import ./execution-save-data.bend as Saved
import ./restore-data.bend as Mapping
import ./world.bend as W

type Error is Data:
  MissingEntity{key:Key.Key}
  DuplicateEntity{key:Key.Key}
type Admission is Data:
  Admitted{}
  Refused{reason:Error}
def contains(values:List<&2,Key.Key>,+key:Key.Key) -> Bool:
  match values:
    case []:False{}
    case next <> rest:Bool.or(Key.equal(next,key),contains(rest,key))
def source_contains(values:List<&2,Saved.Entity>,+key:Key.Key) -> Bool:
  match values:
    case []:False{}
    case Saved.Entity{next,_} <> rest:Bool.or(Key.equal(next,key),source_contains(rest,key))
def checked(present:Bool,duplicate:Bool,key:Key.Key,next:Unit -> Admission) -> Admission:
  match present duplicate:
    case False{} _:Refused{MissingEntity{key}}
    case True{} True{}:Refused{DuplicateEntity{key}}
    case True{} False{}:next(Unit{})
# Full-generation source membership and single-scope-per-entity admission.
# The enclosing snapshot admission also validates all basic allocator metadata.
def walk(values:List<&2,Scope.Member>,+entities:List<&2,Saved.Entity>,+seen:List<&2,Key.Key>) -> Admission:
  match values:
    case []:Admitted{}
    case Scope.Member{_,+key} <> rest:checked(source_contains(entities,key),contains(seen,key),key,u => walk(rest,entities,key <> seen))
def admit(values:List<&2,Scope.Member>,entities:List<&2,Saved.Entity>) -> Admission:walk(values,entities,[])
type Mapped is Data:
  Mapped{members:List<&2,Scope.Member>}
  MissingBinding{key:Key.Key}
def mapped(result:Mapped,name:String,key:Key.Key) -> Mapped:
  match result:
    case Mapped{members}:Mapped{Scope.Member{name,key} <> members}
    case MissingBinding{key}:MissingBinding{key}
def found(~S:Data,key:Key.Key,result:Maybe<&2,W.Handle<S>>,next:Key.Key -> Mapped) -> Mapped:
  match result:
    case None{}:MissingBinding{key}
    case Some{W.Handle{_,target}}:next(target)
def remap(~S:Data,values:List<&2,Scope.Member>,+bindings:List<&2,Mapping.Binding<S>>) -> Mapped:
  match values:
    case []:Mapped{[]}
    case Scope.Member{name,+key} <> rest:found(~S,key,Mapping.lookup(~S,key,bindings),target => mapped(remap(~S,rest,bindings),name,target))
