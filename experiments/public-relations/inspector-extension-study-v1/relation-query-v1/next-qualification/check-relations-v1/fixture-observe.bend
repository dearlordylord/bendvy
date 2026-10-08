import Base
import ../../query.bend as Query
import ../../core-v1/src/ecs/world.bend as W
import ../../core-v1/src/ecs/inspector-query.bend as Errors

type Lookup<S:Data,V:Data> is Data:
  Lookup{requested:W.Handle<S>,result:Result<&2,&2,Errors.LookupError,Query.Row<S,V>>}
type Observation<S:Data,V:Data> is Data:
  Observation{rows:List<&2,Query.Row<S,V>>,lookups:List<&2,Lookup<S,V>>,single:Result<&2,&2,Errors.SingleError,Query.Row<S,V>>,optional:Result<&2,&2,Errors.SingleError,Maybe<&2,Query.Row<S,V>>>}
def looked(~H:Type,~S:Data,~V:Data,target:W.Handle<S>,acc:List<&2,Lookup<S,V>>,next:H -> List<&2,Lookup<S,V>> -> H & List<&2,Lookup<S,V>>,observed:H & Result<&2,&2,Errors.LookupError,Query.Row<S,V>>) -> H & List<&2,Lookup<S,V>>:
  (owner,result)=observed
  next(owner,Lookup{target,result} <> acc)
def lookup_walk(~H:Type,~S:Data,~V:Data,~cap:Query.ReadQuery<H,S,V>,targets:List<&2,W.Handle<S>>,owner:H,acc:List<&2,Lookup<S,V>>) -> H & List<&2,Lookup<S,V>>:
  match targets:
    case []:(owner,List.reverse(&2,Lookup<S,V>,acc))
    case +target <> tail:looked(~H,~S,~V,target,acc,owner => accumulated => lookup_walk(~H,~S,~V,~cap,tail,owner,accumulated),Query.get(~H,~S,~V,~cap,owner,target))
def optional_observed(~H:Type,~S:Data,~V:Data,rows:List<&2,Query.Row<S,V>>,lookups:List<&2,Lookup<S,V>>,single:Result<&2,&2,Errors.SingleError,Query.Row<S,V>>,observed:H & Result<&2,&2,Errors.SingleError,Maybe<&2,Query.Row<S,V>>>) -> H & Observation<S,V>:
  (owner,optional)=observed
  (owner,Observation{rows,lookups,single,optional})
def single_observed(~H:Type,~S:Data,~V:Data,~cap:Query.ReadQuery<H,S,V>,rows:List<&2,Query.Row<S,V>>,lookups:List<&2,Lookup<S,V>>,observed:H & Result<&2,&2,Errors.SingleError,Query.Row<S,V>>) -> H & Observation<S,V>:
  (owner,single)=observed
  optional_observed(~H,~S,~V,rows,lookups,single,Query.single_optional(~H,~S,~V,~cap,owner))
def lookups_observed(~H:Type,~S:Data,~V:Data,~cap:Query.ReadQuery<H,S,V>,rows:List<&2,Query.Row<S,V>>,observed:H & List<&2,Lookup<S,V>>) -> H & Observation<S,V>:
  (owner,lookups)=observed
  single_observed(~H,~S,~V,~cap,rows,lookups,Query.single(~H,~S,~V,~cap,owner))
def each_observed(~H:Type,~S:Data,~V:Data,~cap:Query.ReadQuery<H,S,V>,targets:List<&2,W.Handle<S>>,observed:H & List<&2,Query.Row<S,V>>) -> H & Observation<S,V>:
  (owner,rows)=observed
  lookups_observed(~H,~S,~V,~cap,rows,lookup_walk(~H,~S,~V,~cap,targets,owner,[]))
def observe(~H:Type,~S:Data,~V:Data,~cap:Query.ReadQuery<H,S,V>,owner:H,targets:List<&2,W.Handle<S>>) -> H & Observation<S,V>:
  each_observed(~H,~S,~V,~cap,targets,Query.each(~H,~S,~V,~cap,owner))
