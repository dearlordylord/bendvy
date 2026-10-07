import Base
import full-provider.bend as P
import full-actions.bend as A
import handlers-tracked.bend as H
import ../../../src/ecs/system.bend as Sys

def cross(~failure:H.Phase -> U32 -> Bool,owner:Sys.Registry<P.SchemaA,P.Store<P.SchemaA>,P.Resources<P.SchemaA>,P.Ping,H.Invocation<P.Flow>,String,Unit,A.runner(~P.SchemaA,~failure)>) -> Sys.Registry<P.SchemaB,P.Store<P.SchemaB>,P.Resources<P.SchemaB>,P.Ping,H.Invocation<P.Flow>,String,Unit,A.runner(~P.SchemaB,~failure)>:
  owner
