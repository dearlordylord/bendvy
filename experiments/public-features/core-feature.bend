import Base
import feature.bend as F
import ../../src/ecs/schema-fragments.bend as SF
import ../../src/ecs/schedule-provision.bend as P
import ../../src/ecs/schedule.bend as Sch
type Tag is Type:
  Tag{}
type Owner is Type:
  Owner{cells:Array<U32>,tag:Tag}
def definition(~S:Data) -> F.Tree<S>:
  F.Feature{"Core",[SF.Entry{SF.Component{},"core","core"}],F.Empty{}}
def build(~S:Data,trace:List<&2,String>,owner:Owner) -> List<&2,String> & F.Output<S,Owner>:
  match owner:
    case Owner{cells,tag}: (List.append(&2,String,trace,["build:Core"]),F.Output{Owner{Array.set(U32,cells,1,212),tag},P.Entry{Sch.Phase{"bootstrap:Core"},[P.Component{1}]},P.Entry{Sch.Phase{"update:Core"},[P.Component{1}]}})
def declaration(~S:Data) -> F.Definition<S>:
  F.Definition{"Core",[SF.Entry{SF.Component{},"core","core"}],F.Empty{}}
def provided(~S:Data,owner:Owner) -> F.Feature<S,List<&2,String>,Owner,Owner>:
  F.FeatureOwner{declaration(~S),owner,build(~S)}
