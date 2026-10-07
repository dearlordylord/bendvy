import Base
import ../../trace-value.bend as J
import ../../trace-public.bend as Public
import ../../trace-query.bend as Q
import ../../trace-application.bend as OriginalApp
import ../application.bend as Phase2App
import ../../../../../../src/ecs/world.bend as W
import ../../../../../../src/ecs/relation-commands.bend as A
import ../../../../promotion-stage/application/next-version/v1/owned-world.bend as O

def rows(~S:Data,result:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & List<&2,J.Field>,+root:String) -> W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & J.Value:
  (world,+fields) = result
  OriginalApp.record_graphs(~S,Public.graphs(~S,OriginalApp.descriptors(~S),world,0n),root,"initial",fields,Phase2App.optional_field(fields),None{})
def run(~S:Data,world:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,+root:String) -> J.Value:
  Phase2App.finished(~S,Phase2App.appended(~S,rows(~S,Q.registered_world(~S,world,"query-initial"),root),[]),root)
