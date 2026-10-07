import Base
import feature.bend as F
import core-feature.bend as Core
import ../../src/ecs/schema-fragments.bend as SF
import ../../src/ecs/schedule-provision.bend as P
import ../../src/ecs/schedule.bend as Sch
type Owner is Type:
  Owner{front:Array<U32>,back:Array<U32>,queued:List<Array<U32>>}
def definition(~S:Data) -> F.Tree<S>:
  F.Feature{"Combat",[SF.Entry{SF.Component{},"combat","combat"}],Core.definition(~S)}
def build(~S:Data,trace:List<&2,String>,owner:Owner) -> List<&2,String> & F.Output<S,Owner>:
  match owner:
    case Owner{front,back,queued}: (List.append(&2,String,trace,["build:Combat"]),F.Output{Owner{Array.set(U32,front,0,131),Array.set(U32,back,1,142),queued},P.Entry{Sch.Phase{"bootstrap:Combat"},[P.Component{2},P.Component{1}]},P.Entry{Sch.Phase{"update:Combat"},[P.Component{2},P.Component{1}]}})
def declaration(~S:Data) -> F.Definition<S>:
  F.Definition{"Combat",[SF.Entry{SF.Component{},"combat","combat"}],Core.definition(~S)}
def provided(~S:Data,owner:Owner) -> F.Feature<S,List<&2,String>,Owner,Owner>:
  F.FeatureOwner{declaration(~S),owner,build(~S)}
