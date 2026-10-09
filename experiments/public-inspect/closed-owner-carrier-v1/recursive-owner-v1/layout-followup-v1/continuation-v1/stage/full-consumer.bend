import Base
import query.bend as Q
import consumer-witness.bend as Consumer
import core-v1/src/ecs/world.bend as W
import core-v1/src/ecs/inspector-query.bend as Errors

type Get<S:Data,V:Data> is Data:
  Get{target:W.Handle<S>,result:Result<&2,&2,Errors.LookupError,Q.Row<S,V>>}
type Snapshot<S:Data,V:Data> is Data:
  Snapshot{each:List<&2,Q.Row<S,V>>,get:List<&2,Get<S,V>>,single:Result<&2,&2,Errors.SingleError,Q.Row<S,V>>,singleOptional:Result<&2,&2,Errors.SingleError,Maybe<&2,Q.Row<S,V>>>}
type Prior<S:Data,V:Data> is Data:
  Prior{single:Result<&2,&2,Errors.SingleError,Q.Row<S,V>>}
  PriorLink{next:Prior<S,V>}
def final(~H:Type,~S:Data,~V:Data,rows:List<&2,Q.Row<S,V>>,gets:List<&2,Get<S,V>>,prior:Prior<S,V>,observed:H & Result<&2,&2,Errors.SingleError,Maybe<&2,Q.Row<S,V>>>) -> H & Result<&2,&2,Unit,Snapshot<S,V>>:
  match prior:
    case Prior{single}:
      (owner,optional)=observed
      (owner,Done{Snapshot{rows,gets,single,optional}})
    case PriorLink{next}:final(~H,~S,~V,rows,gets,next,observed)
def after_single(~H:Type,~S:Data,~V:Data,~caps:Consumer.Reads<H,S,V>,rows:List<&2,Q.Row<S,V>>,gets:List<&2,Get<S,V>>,observed:H & Result<&2,&2,Errors.SingleError,Q.Row<S,V>>) -> H & Result<&2,&2,Unit,Snapshot<S,V>>:
  (owner,single)=observed
  final(~H,~S,~V,rows,gets,Prior{single},Q.single_optional(~H,~S,~V,~Consumer.query_field(~H,~S,~V,caps),owner))
def reverse(~S:Data,~V:Data,values:List<&2,Get<S,V>>,acc:List<&2,Get<S,V>>) -> List<&2,Get<S,V>>:
  match values:
    case []:acc
    case value <> rest:reverse(~S,~V,rest,value <> acc)
def fetched(~H:Type,~S:Data,~V:Data,+target:W.Handle<S>,gets:List<&2,Get<S,V>>,observed:H & Result<&2,&2,Errors.LookupError,Q.Row<S,V>>) -> H & List<&2,Get<S,V>>:
  (owner,result)=observed
  (owner,Get{target,result} <> gets)
def fetch_target(~H:Type,~S:Data,~V:Data,~caps:Consumer.Reads<H,S,V>,+target:W.Handle<S>,observed:H & List<&2,Get<S,V>>) -> H & List<&2,Get<S,V>>:
  (owner,gets)=observed
  fetched(~H,~S,~V,target,gets,Q.get(~H,~S,~V,~Consumer.query_field(~H,~S,~V,caps),owner,target))
def fetch_all(~H:Type,~S:Data,~V:Data,~caps:Consumer.Reads<H,S,V>,targets:List<&2,W.Handle<S>>,owner:H) -> H & List<&2,Get<S,V>>:
  match targets:
    case []:(owner,[])
    case target <> rest:fetch_target(~H,~S,~V,~caps,target,fetch_all(~H,~S,~V,~caps,rest,owner))
def after_gets(~H:Type,~S:Data,~V:Data,~caps:Consumer.Reads<H,S,V>,rows:List<&2,Q.Row<S,V>>,observed:H & List<&2,Get<S,V>>) -> H & Result<&2,&2,Unit,Snapshot<S,V>>:
  (owner,gets)=observed
  after_single(~H,~S,~V,~caps,rows,gets,Q.single(~H,~S,~V,~Consumer.query_field(~H,~S,~V,caps),owner))
def after_each(~H:Type,~S:Data,~V:Data,~caps:Consumer.Reads<H,S,V>,targets:List<&2,W.Handle<S>>,observed:H & List<&2,Q.Row<S,V>>) -> H & Result<&2,&2,Unit,Snapshot<S,V>>:
  (owner,rows)=observed
  after_gets(~H,~S,~V,~caps,rows,fetch_all(~H,~S,~V,~caps,targets,owner))
def body(~H:Type,~S:Data,~V:Data,~caps:Consumer.Reads<H,S,V>,targets:List<&2,W.Handle<S>>,owner:H) -> H & Result<&2,&2,Unit,Snapshot<S,V>>:
  after_each(~H,~S,~V,~caps,targets,Q.each(~H,~S,~V,~Consumer.query_field(~H,~S,~V,caps),owner))
