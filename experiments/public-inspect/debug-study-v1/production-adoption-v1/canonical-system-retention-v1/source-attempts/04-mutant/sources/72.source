import Base

# Metadata is kind-local, as in the pinned Schema merge. Declaration packs stay affine.
type RegistryKind is Data:
  Component{}
  Resource{}
  Event{}
  Relation{}
  Service{}
type Descriptor<S: Data,Token: Data,Payload: Type> is Data:
  Descriptor{kind: RegistryKind,key: String,name: String}
type Entry<S: Data> is Data:
  Entry{kind: RegistryKind,key: String,name: String}
type Fragment<S: Data,Owners: Type> is Type:
  Fragment{entries: List<&2,Entry<S>>,owners: Owners}
type Error is Data:
  DuplicateKey{kind: RegistryKind,key: String}
  DuplicateName{kind: RegistryKind,name: String}
  UndeclaredDescriptor{kind: RegistryKind,key: String,name: String}
type Validation is Data:
  Valid{}
  Invalid{error: Error}
type Merge<S: Data,L: Type,R: Type> is Type:
  Merged{fragment: Fragment<S,L & R>}
  Rejected{error: Error,left: Fragment<S,L>,right: Fragment<S,R>}
type Bound<S: Data,Owners: Type,Output: Type> is Type:
  Built{output: Output}
  BindRejected{error: Error,fragment: Fragment<S,Owners>}

def same_kind(a: RegistryKind,b: RegistryKind) -> Bool:
  match a b:
    case Component{} Component{}: True{}
    case Resource{} Resource{}: True{}
    case Event{} Event{}: True{}
    case Relation{} Relation{}: True{}
    case Service{} Service{}: True{}
    case _ _: False{}
def entry(~S: Data,~Token: Data,~Payload: Type,descriptor: Descriptor<S,Token,Payload>) -> Entry<S>:
  match descriptor:
    case Descriptor{kind,key,name}: Entry{kind,key,name}
def empty(~S: Data,owners: Unit) -> Fragment<S,Unit>:
  Fragment{[],owners}
def fragment(~S: Data,~Owners: Type,entries: List<&2,Entry<S>>,owners: Owners) -> Fragment<S,Owners>:
  Fragment{entries,owners}
def key_exists(~S: Data,xs: List<&2,Entry<S>>,+kind: RegistryKind,+key: String) -> Bool:
  match xs:
    case Nil{}: False{}
    case Con{Entry{other,otherKey,_},rest}: Bool.or(Bool.and(same_kind(kind,other),String.eq(key,otherKey)),key_exists(~S,rest,kind,key))
def name_exists(~S: Data,xs: List<&2,Entry<S>>,+kind: RegistryKind,+name: String) -> Bool:
  match xs:
    case Nil{}: False{}
    case Con{Entry{other,_,otherName},rest}: Bool.or(Bool.and(same_kind(kind,other),String.eq(name,otherName)),name_exists(~S,rest,kind,name))
def check_entry(keyConflict: Bool,nameConflict: Bool,kind: RegistryKind,key: String,name: String) -> Validation:
  match keyConflict nameConflict:
    case True{} _: Invalid{DuplicateKey{kind,key}}
    case False{} True{}: Invalid{DuplicateName{kind,name}}
    case False{} False{}: Valid{}
def check_one(~S: Data,+seen: List<&2,Entry<S>>,item: Entry<S>) -> Validation:
  match item:
    case Entry{+kind,+key,+name}: check_entry(key_exists(~S,seen,kind,key),name_exists(~S,seen,kind,name),kind,key,name)
def validation_continue(~S: Data,result: Validation,next: Unit -> Validation) -> Validation:
  match result:
    case Invalid{error}: Invalid{error}
    case Valid{}: next(Unit{})
def validate_loop(~S: Data,xs: List<&2,Entry<S>>,+seen: List<&2,Entry<S>>) -> Validation:
  match xs:
    case Nil{}: Valid{}
    case Con{+item,rest}: validation_continue(~S,check_one(~S,seen,item),_ => validate_loop(~S,rest,item <> seen))
def filter_kind_done(~S: Data,selected: Bool,item: Entry<S>,rest: List<&2,Entry<S>>) -> List<&2,Entry<S>>:
  match selected:
    case True{}: item <> rest
    case False{}: rest
def filter_kind(~S: Data,xs: List<&2,Entry<S>>,+kind: RegistryKind) -> List<&2,Entry<S>>:
  match xs:
    case []: []
    case Entry{+itemKind,+key,+name} <> rest: filter_kind_done(~S,same_kind(kind,itemKind),Entry{itemKind,key,name},filter_kind(~S,rest,kind))
def first_failure(first: Validation,second: Validation) -> Validation:
  match first:
    case Invalid{error}: Invalid{error}
    case Valid{}: second
def validate(~S: Data,+entries: List<&2,Entry<S>>) -> Validation:
  first_failure(validate_loop(~S,filter_kind(~S,entries,Component{}),[]),first_failure(validate_loop(~S,filter_kind(~S,entries,Resource{}),[]),first_failure(validate_loop(~S,filter_kind(~S,entries,Event{}),[]),first_failure(validate_loop(~S,filter_kind(~S,entries,Relation{}),[]),validate_loop(~S,filter_kind(~S,entries,Service{}),[])))))
def merge_checked(~S: Data,~L: Type,~R: Type,result: Validation,+entries: List<&2,Entry<S>>,left: Fragment<S,L>,right: Fragment<S,R>) -> Merge<S,L,R>:
  match result left right:
    case Invalid{error} left right: Rejected{error,left,right}
    case Valid{} Fragment{_,l} Fragment{_,r}: Merged{Fragment{entries,(l,r)}}
def merge(~S: Data,~L: Type,~R: Type,left: Fragment<S,L>,right: Fragment<S,R>) -> Merge<S,L,R>:
  match left right:
    case Fragment{+le,l} Fragment{+re,r}: merge_checked(~S,~L,~R,first_failure(validate(~S,le),first_failure(validate(~S,re),validate(~S,List.append(&2,Entry<S>,le,re)))),List.append(&2,Entry<S>,le,re),Fragment{le,l},Fragment{re,r})
def bind_checked(~S: Data,~Owners: Type,~Output: Type,~build: Owners -> Output,result: Validation,fragment: Fragment<S,Owners>) -> Bound<S,Owners,Output>:
  match result fragment:
    case Invalid{error} fragment: BindRejected{error,fragment}
    case Valid{} Fragment{_,owners}: Built{build(owners)}
def bind(~S: Data,~Owners: Type,~Output: Type,~build: Owners -> Output,fragment: Fragment<S,Owners>) -> Bound<S,Owners,Output>:
  match fragment:
    case Fragment{+entries,owners}: bind_checked(~S,~Owners,~Output,~build,validate(~S,entries),Fragment{entries,owners})

# A closed initializer states its required descriptors before receiving any owners.
# As with Family lenses, caller-authored adapters remain trusted provisioning.
def descriptor_present(~S: Data,xs: List<&2,Entry<S>>,item: Entry<S>) -> Bool:
  match xs item:
    case Nil{} _: False{}
    case Con{Entry{+ak,+ax,+an},rest} Entry{+bk,+bx,+bn}: Bool.or(Bool.and(same_kind(ak,bk),Bool.and(String.eq(ax,bx),String.eq(an,bn))),descriptor_present(~S,rest,Entry{bk,bx,bn}))
def required_continue(result: Validation,next: Unit -> Validation) -> Validation:
  match result:
    case Invalid{error}: Invalid{error}
    case Valid{}: next(Unit{})
def required_check(~S: Data,present: Bool,item: Entry<S>) -> Validation:
  match present item:
    case True{} _: Valid{}
    case False{} Entry{kind,key,name}: Invalid{UndeclaredDescriptor{kind,key,name}}
def requirements(~S: Data,required: List<&2,Entry<S>>,+entries: List<&2,Entry<S>>) -> Validation:
  match required:
    case []: Valid{}
    case +item <> rest: required_continue(required_check(~S,descriptor_present(~S,entries,item),item),_ => requirements(~S,rest,entries))
def bind_requirements(~S: Data,~Owners: Type,~Output: Type,~build: Owners -> Output,result: Validation,required: List<&2,Entry<S>>,fragment: Fragment<S,Owners>) -> Bound<S,Owners,Output>:
  match result fragment:
    case Invalid{error} fragment: BindRejected{error,fragment}
    case Valid{} Fragment{+entries,owners}: bind_checked(~S,~Owners,~Output,~build,requirements(~S,required,entries),Fragment{entries,owners})
def bind_declared(~S: Data,~Owners: Type,~Output: Type,~build: Owners -> Output,fragment: Fragment<S,Owners>,required: List<&2,Entry<S>>) -> Bound<S,Owners,Output>:
  match fragment:
    case Fragment{+entries,owners}: bind_requirements(~S,~Owners,~Output,~build,validate(~S,entries),required,Fragment{entries,owners})
