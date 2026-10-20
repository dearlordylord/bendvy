import Base

# Metadata is kind-local, as in the pinned Schema merge. Declaration packs stay affine.
# Descriptor namespace: component/resource/event/relation/service.
# Keys and names collide within one kind, not across distinct kinds.
type RegistryKind is Data:
  Component{}
  Resource{}
  Event{}
  Relation{}
  Service{}
# Schema/token/payload-indexed descriptor metadata without a live payload.
# Raw construction is trusted schema setup and grants no operational access.
type Descriptor<S: Data,Token: Data,Payload: Type> is Data:
  Descriptor{kind: RegistryKind,key: String,name: String}
# Authored persistence classification for descriptor metadata; does not
# implement a codec, validate raw input or export a snapshot by itself.
type PersistenceKind is Data:
  Plain{}
  Transient{}
  Constructed{}
# Detached descriptor entry, optionally classified by persistence policy.
# Both variants retain the same kind/key/name collision rules.
type Entry<S: Data> is Data:
  Entry{kind: RegistryKind,key: String,name: String}
  Classified{kind: RegistryKind,key: String,name: String,persistence:PersistenceKind}
# Descriptor entries and their actual affine declaration owners. Metadata
# is Data; Owners may contain arbitrary Type payloads and are never duplicated.
type Fragment<S: Data,Owners: Type> is Type:
  Fragment{entries: List<&2,Entry<S>>,owners: Owners}
# Schema refusal identifies duplicate kind-local key/name or a descriptor
# required by a declared initializer but absent from the fragment.
type Error is Data:
  DuplicateKey{kind: RegistryKind,key: String}
  DuplicateName{kind: RegistryKind,name: String}
  UndeclaredDescriptor{kind: RegistryKind,key: String,name: String}
# Pure metadata-validation result, without consuming declaration owners.
type Validation is Data:
  Valid{}
  Invalid{error: Error}
# Merged owns the combined fragment; Rejected returns both original affine
# fragments with the conflict. Refusal does not execute an initializer.
type Merge<S: Data,L: Type,R: Type> is Type:
  Merged{fragment: Fragment<S,L & R>}
  Rejected{error: Error,left: Fragment<S,L>,right: Fragment<S,R>}
# Built owns the initializer output; BindRejected returns the original
# fragment and metadata error, allowing caller recovery without copied owners.
type Bound<S: Data,Owners: Type,Output: Type> is Type:
  Built{output: Output}
  BindRejected{error: Error,fragment: Fragment<S,Owners>}

# Only the operational extension builders choose a classification. Raw schema construction is trusted.
def bare_entry(~S:Data,value:Entry<S>) -> Entry<S>:
  match value:
    case Entry{kind,key,name}:Entry{kind,key,name}
    case Classified{kind,key,name,_}:Entry{kind,key,name}
def bare_entries(~S:Data,values:List<&2,Entry<S>>) -> List<&2,Entry<S>>:
  match values:
    case []:[]
    case head <> rest:bare_entry(~S,head) <> bare_entries(~S,rest)
def same_kind(a: RegistryKind,b: RegistryKind) -> Bool:
  match a b:
    case Component{} Component{}: True{}
    case Resource{} Resource{}: True{}
    case Event{} Event{}: True{}
    case Relation{} Relation{}: True{}
    case Service{} Service{}: True{}
    case _ _: False{}
# Project a typed descriptor to its kind/key/name metadata entry. Does not
# read payloads or grant access to the descriptor's runtime storage.
def entry(~S: Data,~Token: Data,~Payload: Type,descriptor: Descriptor<S,Token,Payload>) -> Entry<S>:
  match descriptor:
    case Descriptor{kind,key,name}: Entry{kind,key,name}
# Create an empty fragment with a Unit owner and no metadata entries.
# Use fragment when supplying arbitrary affine declaration owners.
def empty(~S: Data,owners: Unit) -> Fragment<S,Unit>:
  Fragment{[],owners}
# Trusted setup constructor pairing authored entries with actual owners.
# Does not verify their semantic relationship or reject duplicate entries;
# validate/merge/bind perform their stated metadata checks later.
def fragment(~S: Data,~Owners: Type,entries: List<&2,Entry<S>>,owners: Owners) -> Fragment<S,Owners>:
  Fragment{entries,owners}
def key_exists_bare(~S: Data,xs: List<&2,Entry<S>>,+kind: RegistryKind,+key: String) -> Bool:
  match xs:
    case Nil{}: False{}
    case Con{Entry{other,otherKey,_},rest}: Bool.or(Bool.and(same_kind(kind,other),String.eq(key,otherKey)),key_exists_bare(~S,rest,kind,key))
    case Con{Classified{other,otherKey,_,_},rest}: Bool.or(Bool.and(same_kind(kind,other),String.eq(key,otherKey)),key_exists_bare(~S,rest,kind,key))
def key_exists(~S:Data,xs:List<&2,Entry<S>>,kind:RegistryKind,key:String) -> Bool:key_exists_bare(~S,bare_entries(~S,xs),kind,key)
def name_exists_bare(~S: Data,xs: List<&2,Entry<S>>,+kind: RegistryKind,+name: String) -> Bool:
  match xs:
    case Nil{}: False{}
    case Con{Entry{other,_,otherName},rest}: Bool.or(Bool.and(same_kind(kind,other),String.eq(name,otherName)),name_exists_bare(~S,rest,kind,name))
    case Con{Classified{other,_,otherName,_},rest}: Bool.or(Bool.and(same_kind(kind,other),String.eq(name,otherName)),name_exists_bare(~S,rest,kind,name))
def name_exists(~S:Data,xs:List<&2,Entry<S>>,kind:RegistryKind,name:String) -> Bool:name_exists_bare(~S,bare_entries(~S,xs),kind,name)
def check_entry(keyConflict: Bool,nameConflict: Bool,kind: RegistryKind,key: String,name: String) -> Validation:
  match keyConflict nameConflict:
    case True{} _: Invalid{DuplicateKey{kind,key}}
    case False{} True{}: Invalid{DuplicateName{kind,name}}
    case False{} False{}: Valid{}
def check_one_bare(~S: Data,+seen: List<&2,Entry<S>>,item: Entry<S>) -> Validation:
  match item:
    case Entry{+kind,+key,+name}: check_entry(key_exists(~S,seen,kind,key),name_exists(~S,seen,kind,name),kind,key,name)
    case Classified{+kind,+key,+name,_}: check_entry(key_exists(~S,seen,kind,key),name_exists(~S,seen,kind,name),kind,key,name)
def check_one(~S:Data,seen:List<&2,Entry<S>>,item:Entry<S>) -> Validation:check_one_bare(~S,bare_entries(~S,seen),bare_entry(~S,item))
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
def filter_kind(~S:Data,xs:List<&2,Entry<S>>,+kind:RegistryKind) -> List<&2,Entry<S>>:
  match xs:
    case []:[]
    case Entry{+itemKind,+key,+name} <> rest:filter_kind_done(~S,same_kind(kind,itemKind),Entry{itemKind,key,name},filter_kind(~S,rest,kind))
    case Classified{+itemKind,+key,+name,+persistence} <> rest:filter_kind_done(~S,same_kind(kind,itemKind),Classified{itemKind,key,name,persistence},filter_kind(~S,rest,kind))
def first_failure(first: Validation,second: Validation) -> Validation:
  match first:
    case Invalid{error}: Invalid{error}
    case Valid{}: second
# Check descriptor key/name collisions within each registry kind.
# Preserves kind-specific error order; this is metadata validation, not proof
# of lens laws, actual payload values or correctness of arbitrary adapters.
def validate(~S: Data,+entries: List<&2,Entry<S>>) -> Validation:
  first_failure(validate_loop(~S,filter_kind(~S,entries,Component{}),[]),first_failure(validate_loop(~S,filter_kind(~S,entries,Resource{}),[]),first_failure(validate_loop(~S,filter_kind(~S,entries,Event{}),[]),first_failure(validate_loop(~S,filter_kind(~S,entries,Relation{}),[]),validate_loop(~S,filter_kind(~S,entries,Service{}),[])))))
def merge_checked(~S: Data,~L: Type,~R: Type,result: Validation,+entries: List<&2,Entry<S>>,left: Fragment<S,L>,right: Fragment<S,R>) -> Merge<S,L,R>:
  match result left right:
    case Invalid{error} left right: Rejected{error,left,right}
    case Valid{} Fragment{_,l} Fragment{_,r}: Merged{Fragment{entries,(l,r)}}
# Validate both fragments and their combined entries before combining owners.
# Success retains left-then-right entries and (L & R) owners; refusal returns
# both original fragments. No initializer or gameplay callback is invoked.
def merge(~S: Data,~L: Type,~R: Type,left: Fragment<S,L>,right: Fragment<S,R>) -> Merge<S,L,R>:
  match left right:
    case Fragment{+le,l} Fragment{+re,r}: merge_checked(~S,~L,~R,first_failure(validate(~S,le),first_failure(validate(~S,re),validate(~S,List.append(&2,Entry<S>,le,re)))),List.append(&2,Entry<S>,le,re),Fragment{le,l},Fragment{re,r})
def bind_checked(~S: Data,~Owners: Type,~Output: Type,~build: Owners -> Output,result: Validation,fragment: Fragment<S,Owners>) -> Bound<S,Owners,Output>:
  match result fragment:
    case Invalid{error} fragment: BindRejected{error,fragment}
    case Valid{} Fragment{_,owners}: Built{build(owners)}
# Validate fragment metadata before consuming Owners with a trusted builder.
# BindRejected returns the original fragment; Built contains builder output.
# For a builder with explicit descriptor prerequisites use bind_declared.
def bind(~S: Data,~Owners: Type,~Output: Type,~build: Owners -> Output,fragment: Fragment<S,Owners>) -> Bound<S,Owners,Output>:
  match fragment:
    case Fragment{+entries,owners}: bind_checked(~S,~Owners,~Output,~build,validate(~S,entries),Fragment{entries,owners})

# A closed initializer states its required descriptors before receiving any owners.
# As with Family lenses, caller-authored adapters remain trusted provisioning.
def descriptor_equal(~S:Data,a:Entry<S>,b:Entry<S>) -> Bool:
  match a b:
    case Entry{ak,ax,an} Entry{bk,bx,bn}:Bool.and(same_kind(ak,bk),Bool.and(String.eq(ax,bx),String.eq(an,bn)))
    case _ _:False{}
def descriptor_present(~S:Data,xs:List<&2,Entry<S>>,+item:Entry<S>) -> Bool:
  match xs:
    case []:False{}
    case head <> rest:Bool.or(descriptor_equal(~S,bare_entry(~S,head),bare_entry(~S,item)),descriptor_present(~S,rest,item))
def required_continue(result: Validation,next: Unit -> Validation) -> Validation:
  match result:
    case Invalid{error}: Invalid{error}
    case Valid{}: next(Unit{})
def required_check_bare(~S: Data,present: Bool,item: Entry<S>) -> Validation:
  match present item:
    case True{} _: Valid{}
    case False{} Entry{kind,key,name}: Invalid{UndeclaredDescriptor{kind,key,name}}
    case False{} Classified{kind,key,name,_}: Invalid{UndeclaredDescriptor{kind,key,name}}
def required_check(~S:Data,present:Bool,item:Entry<S>) -> Validation:required_check_bare(~S,present,bare_entry(~S,item))
def requirements(~S: Data,required: List<&2,Entry<S>>,+entries: List<&2,Entry<S>>) -> Validation:
  match required:
    case []: Valid{}
    case +item <> rest: required_continue(required_check(~S,descriptor_present(~S,entries,item),item),_ => requirements(~S,rest,entries))
def bind_requirements(~S: Data,~Owners: Type,~Output: Type,~build: Owners -> Output,result: Validation,required: List<&2,Entry<S>>,fragment: Fragment<S,Owners>) -> Bound<S,Owners,Output>:
  match result fragment:
    case Invalid{error} fragment: BindRejected{error,fragment}
    case Valid{} Fragment{+entries,owners}: bind_checked(~S,~Owners,~Output,~build,requirements(~S,required,entries),Fragment{entries,owners})
# Validate fragment collisions and every explicitly required descriptor
# before invoking the closed builder. Missing kind/key/name yields
# BindRejected with the original fragment, without executing build. Trusted
# builders must still obey their declared requirements; arbitrary callbacks
# are not runtime-confined by metadata alone.
def bind_declared(~S: Data,~Owners: Type,~Output: Type,~build: Owners -> Output,fragment: Fragment<S,Owners>,required: List<&2,Entry<S>>) -> Bound<S,Owners,Output>:
  match fragment:
    case Fragment{+entries,owners}: bind_requirements(~S,~Owners,~Output,~build,validate(~S,entries),required,Fragment{entries,owners})
