import Base
import full-provider.bend as P
import full-actions.bend as A
import handlers-tracked.bend as H
import ../../public-machines/machine.bend as M
import ../../../src/ecs/system.bend as Sys
import ../../../src/ecs/capabilities.bend as Cap

# Positive siblings for intended authority refusals, not replacement laws.
def owner_move(~failure:H.Phase -> U32 -> Bool,owner:H.Owners<P.SchemaA,P.Store<P.SchemaA>,P.Resources<P.SchemaA>,P.Ping,P.Flow,A.runner(~P.SchemaA,~failure)>) -> H.Owners<P.SchemaA,P.Store<P.SchemaA>,P.Resources<P.SchemaA>,P.Ping,P.Flow,A.runner(~P.SchemaA,~failure)>:
  owner
def schema_move(~failure:H.Phase -> U32 -> Bool,owner:Sys.Registry<P.SchemaA,P.Store<P.SchemaA>,P.Resources<P.SchemaA>,P.Ping,H.Invocation<P.Flow>,String,Unit,A.runner(~P.SchemaA,~failure)>) -> Sys.Registry<P.SchemaA,P.Store<P.SchemaA>,P.Resources<P.SchemaA>,P.Ping,H.Invocation<P.Flow>,String,Unit,A.runner(~P.SchemaA,~failure)>:
  owner
def read(~F:Type,~cap:Cap.ValueRead<F,M.CurrentView<P.SchemaA,P.FlowToken,P.Flow>>,owner:F) -> F & M.CurrentView<P.SchemaA,P.FlowToken,P.Flow>:
  Cap.value_read(~F,~M.CurrentView<P.SchemaA,P.FlowToken,P.Flow>,~cap,owner)
type ReadOnly<F:Type> is Type:
  ReadOnly{flow:Cap.ValueRead<F,M.CurrentView<P.SchemaA,P.FlowToken,P.Flow>>}
def declared(-F:Type,caps:ReadOnly<F>,owner:F) -> F:
  match caps:
    case ReadOnly{flow}: owner
