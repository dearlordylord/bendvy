import Base
import ./dependency-plan.bend as Plan
import ./dependency-registration.bend as Reg
import ./dependency-executor.bend as Exec
import ./schema-fragments.bend as Fragment
import ./execution-declaration.bend as D

type Error is Data:
  Schema{error:Fragment.Error}
  Schedule{error:Plan.Invalid<String>}
type Feature<-S:Data,-World:Type,-Owners:Type,-Provisions:Type,-Failure:Data,-Out:Data,-dispatch:Owners -> World -> U32 -> Owners & (World & Exec.Invocation<Failure,Out>)> is Type:
  Feature{registry:Reg.Registry<World,Owners,Failure,Out,dispatch>,fragment:Fragment.Fragment<S,Provisions>,edges:List<&2,Plan.Edge>,invalid:Maybe<&2,Error>}
type Prepared<-S:Data,-World:Type,-Owners:Type,-Provisions:Type,-Failure:Data,-Out:Data,-dispatch:Owners -> World -> U32 -> Owners & (World & Exec.Invocation<Failure,Out>)> is Type:
  CompositionReady{feature:Feature<S,World,Owners,Provisions,Failure,Out,dispatch>,plan:Plan.Build<String>}
  CompositionRefused{feature:Feature<S,World,Owners,Provisions,Failure,Out,dispatch>,error:Error}

def first_error(first:Maybe<&2,Error>,second:Maybe<&2,Error>) -> Maybe<&2,Error>:
  match first:
    case Some{error}:Some{error}
    case None{}:second
def schema_error(value:Fragment.Validation) -> Maybe<&2,Error>:
  match value:
    case Fragment.Valid{}:None{}
    case Fragment.Invalid{error}:Some{Schema{error}}
def schedule_error(value:Maybe<&2,Plan.Invalid<String>>) -> Maybe<&2,Error>:
  match value:
    case None{}:None{}
    case Some{error}:Some{Schedule{error}}
def kind_key(kind:Fragment.RegistryKind,key:String) -> String:
  match kind:
    case Fragment.Component{}:D.requirement_key(D.ComponentAccess{},key)
    case Fragment.Resource{}:D.requirement_key(D.ResourceAccess{},key)
    case Fragment.Service{}:D.requirement_key(D.ServiceAccess{},key)
    case Fragment.Event{}:"event/" ++ key
    case Fragment.Relation{}:"relation/" ++ key
def entry_key(~S:Data,entry:Fragment.Entry<S>) -> String:
  match entry:
    case Fragment.Entry{kind,key,_}:kind_key(kind,key)
    case Fragment.Classified{kind,key,_,_}:kind_key(kind,key)
def provides(~S:Data,entries:List<&2,Fragment.Entry<S>>,+key:String) -> Bool:
  match entries:
    case []:False{}
    case entry <> rest:Bool.or(String.eq(entry_key(~S,entry),key),provides(~S,rest,key))
def missing_step(available:Bool,id:U32,key:String,next:Maybe<&2,Plan.Invalid<String>>) -> Maybe<&2,Plan.Invalid<String>>:
  match available:
    case True{}:next
    case False{}:Some{Plan.Missing{id,key}}
def missing_needs(~S:Data,needs:List<&2,String>,+entries:List<&2,Fragment.Entry<S>>,+id:U32) -> Maybe<&2,Plan.Invalid<String>>:
  match needs:
    case []:None{}
    case +key <> rest:missing_step(provides(~S,entries,key),id,key,missing_needs(~S,rest,entries,id))
def missing(~S:Data,nodes:List<&2,Plan.Node<String>>,+entries:List<&2,Fragment.Entry<S>>) -> Maybe<&2,Plan.Invalid<String>>:
  match nodes:
    case []:None{}
    case Plan.Node{id,needs} <> rest:Plan.first_error(~String,missing_needs(~S,needs,entries,id),missing(~S,rest,entries))
def available(key:String) -> Bool:True{}

def declared(~S:Data,~World:Type,~Owners:Type,~Provisions:Type,~Failure:Data,~Out:Data,~dispatch:Owners -> World -> U32 -> Owners & (World & Exec.Invocation<Failure,Out>),registry:Reg.Registry<World,Owners,Failure,Out,dispatch>,fragment:Fragment.Fragment<S,Provisions>) -> Feature<S,World,Owners,Provisions,Failure,Out,dispatch>:
  Feature{registry,fragment,[],None{}}
def nested_actual(~S:Data,~World:Type,~Owners:Type,~Provisions:Type,~Failure:Data,~Out:Data,~dispatch:Owners -> World -> U32 -> Owners & (World & Exec.Invocation<Failure,Out>),feature:Feature<S,World,Owners,Provisions,Failure,Out,dispatch>,+edges:List<&2,Plan.Edge>) -> Feature<S,World,Owners,Provisions,Failure,Out,dispatch>:
  match feature:
    case Feature{Reg.Registry{owners,+nodes},fragment,prior,invalid}:Feature{Reg.Registry{owners,nodes},fragment,List.append(&2,Plan.Edge,prior,edges),first_error(invalid,schedule_error(Plan.endpoints(~String,edges,nodes)))}
def nested(~S:Data,~World:Type,~Owners:Type,~Provisions:Type,~Failure:Data,~Out:Data,~dispatch:Owners -> World -> U32 -> Owners & (World & Exec.Invocation<Failure,Out>),feature:Feature<S,World,Owners,Provisions,Failure,Out,dispatch>,edges:List<&2,Plan.Edge>) -> Feature<S,World,Owners,Provisions,Failure,Out,dispatch>:
  nested_actual(~S,~World,~Owners,~Provisions,~Failure,~Out,~dispatch,feature,edges)
def paired(~S:Data,~World:Type,~L:Type,~R:Type,~LP:Type,~RP:Type,~Failure:Data,~Out:Data,~ld:L -> World -> U32 -> L & (World & Exec.Invocation<Failure,Out>),~rd:R -> World -> U32 -> R & (World & Exec.Invocation<Failure,Out>),left:Feature<S,World,L,LP,Failure,Out,ld>,right:Feature<S,World,R,RP,Failure,Out,rd>) -> Feature<S,World,Reg.Product<L,R>,LP & RP,Failure,Out,Reg.paired_dispatch(~World,~L,~R,~Failure,~Out,~ld,~rd)>:
  match left right:
    case Feature{lr,Fragment.Fragment{le,lp},ledges,li} Feature{rr,Fragment.Fragment{re,rp},redges,ri}:Feature{Reg.paired(~World,~L,~R,~Failure,~Out,~ld,~rd,lr,rr),Fragment.Fragment{List.append(&2,Fragment.Entry<S>,le,re),(lp,rp)},List.append(&2,Plan.Edge,ledges,redges),first_error(li,ri)}
def prepared_plan(~S:Data,~World:Type,~Owners:Type,~Provisions:Type,~Failure:Data,~Out:Data,~dispatch:Owners -> World -> U32 -> Owners & (World & Exec.Invocation<Failure,Out>),feature:Feature<S,World,Owners,Provisions,Failure,Out,dispatch>,plan:Plan.Build<String>) -> Prepared<S,World,Owners,Provisions,Failure,Out,dispatch>:
  match plan:
    case Plan.Rejected{error}:CompositionRefused{feature,Schedule{error}}
    case Plan.Planned{order,edges}:CompositionReady{feature,Plan.Planned{order,edges}}
def prepared_checked(~S:Data,~World:Type,~Owners:Type,~Provisions:Type,~Failure:Data,~Out:Data,~dispatch:Owners -> World -> U32 -> Owners & (World & Exec.Invocation<Failure,Out>),invalid:Maybe<&2,Error>,feature:Feature<S,World,Owners,Provisions,Failure,Out,dispatch>,plan:Plan.Build<String>) -> Prepared<S,World,Owners,Provisions,Failure,Out,dispatch>:
  match invalid:
    case Some{error}:CompositionRefused{feature,error}
    case None{}:prepared_plan(~S,~World,~Owners,~Provisions,~Failure,~Out,~dispatch,feature,plan)
def prepare(~S:Data,~World:Type,~Owners:Type,~Provisions:Type,~Failure:Data,~Out:Data,~dispatch:Owners -> World -> U32 -> Owners & (World & Exec.Invocation<Failure,Out>),feature:Feature<S,World,Owners,Provisions,Failure,Out,dispatch>) -> Prepared<S,World,Owners,Provisions,Failure,Out,dispatch>:
  match feature:
    case Feature{Reg.Registry{owners,+nodes},Fragment.Fragment{+entries,provisions},+edges,+invalid}:prepared_checked(~S,~World,~Owners,~Provisions,~Failure,~Out,~dispatch,first_error(invalid,first_error(schema_error(Fragment.validate(~S,entries)),schedule_error(missing(~S,nodes,entries)))),Feature{Reg.Registry{owners,nodes},Fragment.Fragment{entries,provisions},edges,invalid},Plan.build(~String,~available,nodes,edges))
