import Base
import ./execution-save-plan.bend as Plan
import ./execution-save-data.bend as Saved
import ./persistence-declaration.bend as Decl
import ./owner-product.bend as Product
import ./decode-data.bend as D
import ./decode-size.bend as Size
import ./entity-key.bend as Key

# Internal admission descriptors come from the retained nominal declarations.
# They are observations, never a caller supplied storage or access catalog.
type Policy is Data:Plain{} Transient{} Constructed{codec:D.Codec}
type Descriptor is Data:Descriptor{key:String,policy:Policy}
type Error is Data:
  UnsupportedVersion{version:U32}
  DuplicateEntity{key:Key.Key}
  FieldShape{}
  FieldKey{expected:String,actual:String}
  PlainUnserializable{key:String}
  InvalidValue{key:String}
  InvalidCodec{key:String,error:D.Error}
type Admission is Data:Admitted{} Refused{error:Error}
def first(left:Admission,right:Admission) -> Admission:
  match left:
    case Admitted{}:right
    case Refused{error}:Refused{error}
def retained(-Q:Type,recipe:Q,key:String,policy:Policy) -> Q & List<&2,Descriptor>:
  (recipe,[Descriptor{key,policy}])
def pair_right(-L:Type,-R:Type,left:L,descriptors:List<&2,Descriptor>,result:R & List<&2,Descriptor>) -> Product.Owner<L,R> & List<&2,Descriptor>:
  match result:
    case (right,values):(Product.Owner{left,right},List.append(&2,Descriptor,descriptors,values))
def pair_left(-L:Type,-R:Type,right:R -> R & List<&2,Descriptor>,owner:R,result:L & List<&2,Descriptor>) -> Product.Owner<L,R> & List<&2,Descriptor>:
  match result:
    case (left,values):pair_right(L,R,left,values,right(owner))
def pair(-L:Type,-R:Type,left:L -> L & List<&2,Descriptor>,right:R -> R & List<&2,Descriptor>,owners:Product.Owner<L,R>) -> Product.Owner<L,R> & List<&2,Descriptor>:
  match owners:
    case Product.Owner{l,r}:pair_left(L,R,right,r,left(l))
def constructed_descriptor(~S:Data,-P:Type,+key:String,project:P -> P & D.Raw,declaration:Decl.Constructed<S,P,Plan.identity(~S,~P,key),project>) -> Decl.Constructed<S,P,Plan.identity(~S,~P,key),project> & List<&2,Descriptor>:
  match declaration:
    case Decl.Constructed{+codec}:(Decl.Constructed{codec},[Descriptor{key,Constructed{codec}}])
def descriptors(~S:Data,plan:Plan.Plan) -> Plan.Recipes(~S,plan) -> Plan.Recipes(~S,plan) & List<&2,Descriptor>:
  match plan:
    case Plan.Empty{}:recipe => (recipe,[])
    case Plan.Plain{_,_,_,key}:recipe => retained(Plan.Recipes(~S,plan),recipe,key,Plain{})
    case Plan.Transient{_,_,_,key}:recipe => retained(Plan.Recipes(~S,plan),recipe,key,Transient{})
    case Plan.Constructed{P,_,_,key,project}:recipe => constructed_descriptor(~S,P,key,project,recipe)
    case Plan.Pair{left,right}:recipe => pair(Plan.Recipes(~S,left),Plan.Recipes(~S,right),descriptors(~S,left),descriptors(~S,right),recipe)
def checked(key:String,result:D.Checked) -> Admission:
  match result:
    case D.Accepted{_}:Admitted{}
    case D.Rejected{error}:Refused{InvalidCodec{key,error}}
def admit_value(key:String,policy:Policy,present:Bool,value:Saved.Value,resource:Bool) -> Admission:
  match policy present value resource:
    case Plain{} _ _ _:Refused{PlainUnserializable{key}}
    case Transient{} True{} Saved.Omitted{} _:Admitted{}
    case Transient{} False{} Saved.Absent{} False{}:Admitted{}
    case Constructed{+codec} True{} Saved.Persisted{+raw} _:checked(key,D.validate(Size.budget(codec,raw),D.Continue{[D.Work{codec,raw,"$"}]},raw))
    case Constructed{_} False{} Saved.Absent{} False{}:Admitted{}
    case _ _ _ _:Refused{InvalidValue{key}}
def named(equal:Bool,key:String,actual:String,policy:Policy,present:Bool,value:Saved.Value,resource:Bool) -> Admission:
  match equal:
    case False{}:Refused{FieldKey{key,actual}}
    case True{}:admit_value(key,policy,present,value,resource)
def fields(descriptors:List<&2,Descriptor>,values:List<&2,Saved.Field>,+resource:Bool) -> Admission:
  match descriptors values:
    case [], []:Admitted{}
    case Descriptor{+key,policy} <> rest, Saved.Field{+actual,present,value,_} <> tail:first(named(String.eq(key,actual),key,actual,policy,present,value,resource),fields(rest,tail,resource))
    case _ _:Refused{FieldShape{}}
def seen(+key:Key.Key,previous:List<&2,Key.Key>) -> Bool:
  match previous:
    case []:False{}
    case other <> rest:Bool.or(Key.equal(key,other),seen(key,rest))
def entity(duplicate:Bool,key:Key.Key,descriptors:List<&2,Descriptor>,values:List<&2,Saved.Field>) -> Admission:
  match duplicate:
    case True{}:Refused{DuplicateEntity{key}}
    case False{}:fields(descriptors,values,False{})
def entities(values:List<&2,Saved.Entity>,+descriptors:List<&2,Descriptor>,+previous:List<&2,Key.Key>) -> Admission:
  match values:
    case []:Admitted{}
    case Saved.Entity{+key,fields} <> rest:first(entity(seen(key,previous),key,descriptors,fields),entities(rest,descriptors,key <> previous))
# This is detached input admission only. It neither constructs Type payloads nor
# mutates a receiver, copies its source namespace, or resumes an application.
def header(valid:Bool,version:U32,components:List<&2,Descriptor>,resources:List<&2,Descriptor>,values:List<&2,Saved.Entity>,resourceValues:List<&2,Saved.Field>) -> Admission:
  match valid:
    case False{}:Refused{UnsupportedVersion{version}}
    case True{}:first(entities(values,components,[]),fields(resources,resourceValues,True{}))
def snapshot(~S:Data,components:List<&2,Descriptor>,resources:List<&2,Descriptor>,input:Saved.Snapshot<S>) -> Admission:
  match input:
    case Saved.Snapshot{+version,_,values,resourceValues}:header(U32.is_eq(version,2),version,components,resources,values,resourceValues)
def schema_resources(~S:Data,~cp:Plan.Plan,~rp:Plan.Plan,components:Plan.Recipes(~S,cp),componentDescriptors:List<&2,Descriptor>,+input:Saved.Snapshot<S>,result:Plan.Recipes(~S,rp) & List<&2,Descriptor>) -> Plan.Schema<S,cp,rp> & (Saved.Snapshot<S> & Admission):
  match result:
    case (resources,resourceDescriptors):(Plan.Schema{components,resources},(input,snapshot(~S,componentDescriptors,resourceDescriptors,input)))
def schema_components(~S:Data,~cp:Plan.Plan,~rp:Plan.Plan,resources:Plan.Recipes(~S,rp),input:Saved.Snapshot<S>,result:Plan.Recipes(~S,cp) & List<&2,Descriptor>) -> Plan.Schema<S,cp,rp> & (Saved.Snapshot<S> & Admission):
  match result:
    case (components,componentDescriptors):schema_resources(~S,~cp,~rp,components,componentDescriptors,input,descriptors(~S,rp)(resources))
def prepare(~S:Data,~cp:Plan.Plan,~rp:Plan.Plan,schema:Plan.Schema<S,cp,rp>,input:Saved.Snapshot<S>) -> Plan.Schema<S,cp,rp> & (Saved.Snapshot<S> & Admission):
  match schema:
    case Plan.Schema{components,resources}:schema_components(~S,~cp,~rp,resources,input,descriptors(~S,cp)(components))
