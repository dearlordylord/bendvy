import Base
import types.bend as T
import bundle.bend as B
import application.bend as App
import systems.bend as Systems
import ../../../../src/ecs/world.bend as W
import ../../../../src/ecs/system.bend as Sys
import ../../../../src/ecs/machine-handlers.bend as H
import ../../../../src/ecs/capabilities.bend as Cap
def denied(selector:B.Selector<T.SchemaA,T.MachineKey,T.State>,needs:List<&2,T.Requirement<T.SchemaB>>,entry:H.Entry<T.SchemaA,T.Store<T.SchemaA>,T.Resources<T.SchemaA>,Unit,T.State,Systems.runner(~T.SchemaA)>) -> B.Scheduled<T.SchemaA,T.MachineKey,T.State,T.Requirement<T.SchemaA>,T.Store<T.SchemaA>,T.Resources<T.SchemaA>,Unit,Systems.runner(~T.SchemaA)>:
  B.Scheduled{selector,needs,entry}
