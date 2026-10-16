import Base
import ../../../../src/ecs/registration.bend as Reg
import ../fixture.bend as F
import ../../../public-captures/ordinary-owner-v1/payload.bend as P
import ../../../../src/ecs/ordinary-app-local-fields.bend as Ord
import ../resource.bend as R
import ../wiring.bend as Bind
import ../observe.bend as Obs
import ../../../../src/ecs/world.bend as W
import ../../../../src/ecs/column.bend as Col
import ../../../../src/ecs/compose.bend as Q
import ../../../../src/ecs/local.bend as Local
import ../../../../src/ecs/ordinary-capture-query.bend as O
import ../../../../src/ecs/captured-schedule.bend as Run
import ../../../../src/ecs/captured-schedule-composition.bend as Comp
import ../../../../src/ecs/captured-schedule-query.bend as QLeaf
import ../../../../src/ecs/captured-schedule-local.bend as RLeaf
import ../../../../src/ecs/schedule.bend as Sch
import ../../../../src/ecs/schedule-provision.bend as SP

import ../admission-v1/scenario.bend as A
import ../../../../src/ecs/captures.bend as Capture
import ../../../../src/ecs/ordinary-captures.bend as Entry
def new_plan(~S:Data,qid:U32,rid:U32) -> SP.Plan<S>:
  SP.Sequence{SP.Entry{Sch.Phase{"reregistered"},[]},SP.Sequence{SP.Entry{Sch.System{qid,0},[SP.Component{1}]},SP.Sequence{SP.Entry{Sch.System{rid,0},[SP.Resource{2}]},SP.Entry{Sch.Barrier{},[]}}}}
def replanned(~S:Data,world:W.World<S,Col.Column<S,U32>,U32,Unit>,foreign:W.World<S,Col.Column<S,U32>,U32,Unit>,text:String,+ns:U32,+qid:U32,+qname:String,+qaccess:List<&2,String>,cursor:U32,pack:P.Pack,resource:R.Instance(S)) -> String:
  match resource:
    case Local.Instance{nsr,+rid,rname,raccess,array}:A.finish(~S,A.run(~S,"retry-new-ids",F.Args{1,0},R.Args{3,False{}},True{},A.snapshot(~S,"reregistered",A.State{world,foreign,Run.Owned{"lifecycle",new_plan(~S,qid,rid),(QLeaf.Leaf{O.Owner{Local.Instance{ns,qid,qname,qaccess,pack},cursor},F.Args{1,0},True{}},RLeaf.Leaf{Local.Instance{nsr,rid,rname,raccess,array},R.Args{3,False{}},True{}})},text})))
def resource_registered(~S:Data,foreign:W.World<S,Col.Column<S,U32>,U32,Unit>,query:F.Owned(S),text:String,result:Local.Registered<S,Col.Column<S,U32>,U32,Unit,Array<U32>,R.Args,R.Error,Unit,Ord.runner(~S,~Col.Column<S,U32>,~U32,~Unit,~Array<U32>,~R.Args,~R.Error,~Unit,~R.Ops,~R.declaration(~S),~R.body)>) -> String:
  match query result:
    case O.Owner{Local.Instance{ns,id,name,access,pack},cursor}, Local.Registered{world,resource}:replanned(~S,world,foreign,text,ns,id,name,access,cursor,pack,resource)
    case _ _:"BUG:reregister-resource"
def query_registered(~S:Data,foreign:W.World<S,Col.Column<S,U32>,U32,Unit>,array:Array<U32>,text:String,result:O.Registration<W.World<S,Col.Column<S,U32>,U32,Unit>,F.Owned(S),P.Pack>) -> String:
  match result:
    case O.Registered{world,query}:resource_registered(~S,foreign,query,text,Entry.define(~S,~Col.Column<S,U32>,~U32,~Unit,~Array<U32>,~R.Args,~R.Error,~Unit,~R.Ops,~R.declaration(~S),~R.body,world,"resource-counter",array))
    case _:"BUG:reregister-query"
def recovered(~S:Data,foreign:W.World<S,Col.Column<S,U32>,U32,Unit>,text:String,w:W.World<S,Col.Column<S,U32>,U32,Unit> & String,p:P.Pack & P.Observation,a:Array<U32> & P.Tree) -> String:
  match w p a:
    case (world,wt), (pack,pv), (array,av):query_registered(~S,foreign,array,text ++ "both-removed|" ++ wt ++ "|" ++ Obs.pack(pv) ++ "|" ++ Obs.tree(av) ++ "\n",O.define(~S,~Col.Column<S,U32>,~U32,~Unit,~P.Pack,~F.Ops,~F.Args,~F.Error,~U32,~F.query(~S),~F.body,world,"captured-query",pack))
def removed(~S:Data,foreign:W.World<S,Col.Column<S,U32>,U32,Unit>,pack:P.Pack,text:String,result:Local.Disposal<S,Col.Column<S,U32>,U32,Unit,Array<U32>,R.Args,R.Error,Unit,Ord.runner(~S,~Col.Column<S,U32>,~U32,~Unit,~Array<U32>,~R.Args,~R.Error,~Unit,~R.Ops,~R.declaration(~S),~R.body),Array<U32>>) -> String:
  match result:
    case Local.Disposed{world,array}:recovered(~S,foreign,text,Obs.world(~S,world),P.project(pack),P.observe(array))
    case _:"BUG:resource-remove"
def query_removed(~S:Data,foreign:W.World<S,Col.Column<S,U32>,U32,Unit>,resource:R.Instance(S),text:String,result:O.Removal<W.World<S,Col.Column<S,U32>,U32,Unit>,F.Owned(S),P.Pack>) -> String:
  match result:
    case O.Removed{world,pack}:removed(~S,foreign,pack,text,Capture.unregister(~S,~Col.Column<S,U32>,~U32,~Unit,~Array<U32>,~R.Args,~R.Error,~Unit,~Ord.runner(~S,~Col.Column<S,U32>,~U32,~Unit,~Array<U32>,~R.Args,~R.Error,~Unit,~R.Ops,~R.declaration(~S),~R.body),resource,world))
    case _:"BUG:query-remove"
def sequence(~S:Data,state:A.State<S>) -> String:
  match state:
    case A.State{world,foreign,Run.Owned{_,_,(QLeaf.Leaf{query,_,_},RLeaf.Leaf{resource,_,_})},text}:query_removed(~S,foreign,resource,text,O.unregister(~S,~Col.Column<S,U32>,~U32,~Unit,~P.Pack,~F.Ops,~F.Args,~F.Error,~U32,~F.query(~S),~F.body,query,world))
def resource_defined(~S:Data,foreign:W.World<S,Col.Column<S,U32>,U32,Unit>,query:F.Owned(S),result:Local.Registered<S,Col.Column<S,U32>,U32,Unit,Array<U32>,R.Args,R.Error,Unit,Ord.runner(~S,~Col.Column<S,U32>,~U32,~Unit,~Array<U32>,~R.Args,~R.Error,~Unit,~R.Ops,~R.declaration(~S),~R.body)>) -> String:
  match result:
    case Local.Registered{world,resource}:sequence(~S,A.run(~S,"before-removal-run",F.Args{1,0},R.Args{10,False{}},True{},A.snapshot(~S,"registered",A.State{world,foreign,Bind.bind(~S,query,resource,F.Args{1,0},R.Args{10,False{}},True{}),""})))
    case _:"BUG:resource-registration"
def query_defined(~S:Data,foreign:W.World<S,Col.Column<S,U32>,U32,Unit>,result:O.Registration<W.World<S,Col.Column<S,U32>,U32,Unit>,F.Owned(S),P.Pack>) -> String:
  match result:
    case O.Registered{world,query}:resource_defined(~S,foreign,query,R.define(~S,world))
    case _:"BUG:query-registration"
def start(~S:Data,world:W.World<S,Col.Column<S,U32>,U32,Unit>,foreign:W.World<S,Col.Column<S,U32>,U32,Unit>) -> String:
  query_defined(~S,foreign,F.define(~S,F.populate(~S,F.populate(~S,F.spawn(~S,F.spawn(~S,F.spawn(~S,world))),1,10),2,20)))
