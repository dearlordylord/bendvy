import Base
import ./core.bend as F

type Schema is Data:
  Schema{}

def kind_code(kind:F.RegistryKind) -> U32:
  match kind:
    case F.Component{}: 0
    case F.Resource{}: 1
    case F.Event{}: 2
    case F.Relation{}: 3
    case F.Service{}: 4

def same_kind(a:F.RegistryKind,b:F.RegistryKind) -> Bool:
  U32.is_eq(kind_code(a),kind_code(b))

def key_member(xs:List<&2,F.Entry<Schema>>,+kind:F.RegistryKind,+key:String) -> Bool:
  match xs:
    case []: False{}
    case F.Entry{k,x,_} <> rest: (same_kind(kind,k) && String.eq(key,x)) || key_member(rest,kind,key)

def name_member(xs:List<&2,F.Entry<Schema>>,+kind:F.RegistryKind,+name:String) -> Bool:
  match xs:
    case []: False{}
    case F.Entry{k,_,n} <> rest: (same_kind(kind,k) && String.eq(name,n)) || name_member(rest,kind,name)

def classified(key:Bool,name:Bool,kind:F.RegistryKind,k:String,n:String) -> F.Validation:
  match key name:
    case True{} _: F.Invalid{F.DuplicateKey{kind,k}}
    case False{} True{}: F.Invalid{F.DuplicateName{kind,n}}
    case False{} False{}: F.Valid{}

def classify(+seen:List<&2,F.Entry<Schema>>,item:F.Entry<Schema>) -> F.Validation:
  match item:
    case F.Entry{+kind,+key,+name}: classified(key_member(seen,kind,key),name_member(seen,kind,name),kind,key,name)

def continue_validation(result:F.Validation,next:Unit -> F.Validation) -> F.Validation:
  match result:
    case F.Invalid{error}: F.Invalid{error}
    case F.Valid{}: next(Unit{})

# Scan original order, ignoring other kinds; unlike Core, do not pre-filter.
def selected(selected:Bool,+item:F.Entry<Schema>,seen:List<&2,F.Entry<Schema>>) -> F.Validation:
  match selected:
    case False{}: F.Valid{}
    case True{}: classify(seen,item)

def select_item(kind:F.RegistryKind,+item:F.Entry<Schema>,seen:List<&2,F.Entry<Schema>>) -> F.Validation:
  match item:
    case F.Entry{+other,+key,+name}: selected(same_kind(kind,other),F.Entry{other,key,name},seen)

def bucket(xs:List<&2,F.Entry<Schema>>,+seen:List<&2,F.Entry<Schema>>,+kind:F.RegistryKind) -> F.Validation:
  match xs:
    case []: F.Valid{}
    case +item <> rest: continue_validation(select_item(kind,item,seen),_ => bucket(rest,item <> seen,kind))

def first(a:F.Validation,b:F.Validation) -> F.Validation:
  match a:
    case F.Invalid{error}: F.Invalid{error}
    case F.Valid{}: b

def validate(+entries:List<&2,F.Entry<Schema>>) -> F.Validation:
  first(bucket(entries,[],F.Component{}),first(bucket(entries,[],F.Resource{}),first(bucket(entries,[],F.Event{}),first(bucket(entries,[],F.Relation{}),bucket(entries,[],F.Service{})))))

def member(xs:List<&2,F.Entry<Schema>>,+item:F.Entry<Schema>) -> Bool:
  match xs item:
    case [] _: False{}
    case F.Entry{ak,ax,an} <> rest F.Entry{+bk,+bx,+bn}: (same_kind(ak,bk) && String.eq(ax,bx) && String.eq(an,bn)) || member(rest,F.Entry{bk,bx,bn})
