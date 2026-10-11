import Base
import /workspace/formal-proofs/bendvy/experiments/public-inspect/ordinary-declaration-v1/native54-matching-tree-v1/native-blocker-source-research-v1/current-repeat-schedule-v1/removal-inspection-v1/public-relocation-v1/policy-free-v2/consumer-public.bend as C
import ./observer-public.bend as O
import /workspace/formal-proofs/bendvy/experiments/public-inspect/ordinary-declaration-v1/native54-matching-tree-v1/native-blocker-source-research-v1/current-repeat-schedule-v1/ordinary-composed-query-v1/queries.bend as Q
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/removals.bend as Rm
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-removal-provision.bend as Provision
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-declaration.bend as Identity

def appended(~S:Data,text:String,returned:C.Fixture<S> & String) -> C.Fixture<S> & String:
  (owner,physical)=returned
  (owner,physical ++ "|composedQueries{" ++ text ++ "}")
def returned(~S:Data,factory:W.Factory,reader:Rm.Reader<S,Q.Events(~S),Identity.Declaration<S,C.Payload>,Provision.left_select(~S,~C.Payload,~Rm.Record<S,Identity.Declaration<S,C.Payload>>,~Rm.Record<S,Identity.Declaration<S,C.Payload>>,~Provision.leaf_select(~S,~C.Payload))>,projection:Maybe<&2,List<&2,Rm.Record<S,Identity.Declaration<S,C.Payload>>>>,status:String,output:String,result:W.World<S,Q.Store(~S),Array<U32>,Q.Events(~S)> & String) -> C.Fixture<S> & String:
  (world,text)=result
  appended(~S,text,O.observe(~S,C.Fixture{factory,world,reader,projection,status,output}))
def observe(~S:Data,value:C.Fixture<S>) -> C.Fixture<S> & String:
  match value:
    case C.Fixture{factory,world,reader,projection,status,output}:returned(~S,factory,reader,projection,status,output,Q.inspect(~S,world))
    case value:O.observe(~S,value)
