import Base
import full-provider.bend as P
import full-actions.bend as A
import handlers-tracked.bend as H

def duplicate(~failure:H.Phase -> U32 -> Bool,owner:H.Owners<P.SchemaA,P.Store<P.SchemaA>,P.Resources<P.SchemaA>,P.Ping,P.Flow,A.runner(~P.SchemaA,~failure)>) -> H.Owners<P.SchemaA,P.Store<P.SchemaA>,P.Resources<P.SchemaA>,P.Ping,P.Flow,A.runner(~P.SchemaA,~failure)> & H.Owners<P.SchemaA,P.Store<P.SchemaA>,P.Resources<P.SchemaA>,P.Ping,P.Flow,A.runner(~P.SchemaA,~failure)>:
  (owner,owner)
