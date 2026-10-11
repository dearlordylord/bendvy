import Base
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-component-binding.bend as Binding
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-declaration.bend as Identity
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-schema.bend as Schema
import state.bend as F
import operations.bend as Ops
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-service-registration.bend as Service
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-composer.bend as Build
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-records.bend as Leaf
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-recipe.bend as Tree
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-observation-data.bend as DTO
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-registration-fields.bend as Records
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-machine.bend as Machine
import /workspace/formal-proofs/bendvy/src/ecs/machine.bend as M
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-service-declaration.bend as D
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-system.bend as System
import /workspace/formal-proofs/bendvy/src/ecs/compose.bend as Q
import /workspace/formal-proofs/bendvy/src/ecs/component.bend as Cmp
import /workspace/formal-proofs/bendvy/src/ecs/inspector-query.bend as IQ
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-observation.bend as Leaves
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-component.bend as Component
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-resource-field.bend as Resource
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-resource-field-system.bend as Field
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-resource-field-declaration.bend as RD
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-resource-field-observation.bend as RL
def scan() -> F.World() -> F.World() & List<&2,D.Status<F.S>>:D.world_observed(~F.S,~F.Store,~F.Resources,~F.Events(),~Array<U32>,~F.ClockRest,~F.clock_take,~F.clock_put,~F.clock_call,F.clock_declaration())
def ServiceOwner() -> Type:Service.Owner<F.S,F.Store,F.Resources,F.Events(),Array<U32>,F.ClockRest,F.clock_take,F.clock_put,F.clock_call,F.clock_declaration(),scan()>
def ComponentRegistry() -> Type:Sys.Registry<F.S,F.Store,F.Resources,F.Events(),Unit & U32,Q.Error<Unit>,List<&2,Unit>,System.observable_runner(~F.S,~F.Store,~F.Resources,~F.Events(),~Ops.ComponentOps,~Unit,~Unit,~Unit,~Cmp.Access<U32>,~Ops.component_query(),~Ops.component_body)>
def ComponentRecord() -> Type:Leaf.Record<F.S,Records.Token<ComponentRegistry()>>
def ResourceRegistry() -> Type:Sys.Registry<F.S,F.Store,F.Resources,F.Events(),Unit,Unit,Unit,Field.runner(~F.S,~F.Store,~F.Resources,~F.Events(),~RD.read_ops(~F.S,~Array<U32>,~F.inventory_identity(),~U32),~Unit,~Unit,~Unit,~RD.ordinary(~F.S,~F.Store,~F.Resources,~F.Events(),~RD.read_ops(~F.S,~Array<U32>,~F.inventory_identity(),~U32),~U32,Ops.resource_declaration()),~Ops.resource_body)>
def ResourceRecord() -> Type:Leaf.Record<F.S,Records.Token<ResourceRegistry()>>
def Owners0() -> Type:Unit
def Rows0() -> Data:Unit
def observe0() -> F.World() -> F.World() & DTO.Observation<Rows0()>:Build.empty_observe(~F.World())
def fold0() -> Owners0() -> Owners0() & List<&2,Records.Fields<F.S>>:Leaf.empty(~F.S)
def App0() -> Type:Build.Registered<F.S,F.World(),Owners0(),Rows0(),observe0(),fold0()>
def Owners1() -> Type:Unit
def Rows1() -> Data:DTO.Product<Unit,M.CurrentView<F.S,F.Mode,U32>>
def observe1() -> F.World() -> F.World() & DTO.Observation<Rows1()>:Machine.observation(~F.S,~F.Mode,~U32,~F.Store,~F.Resources,~F.Events(),~F.machine_take,~F.machine_put,~U32.is_eq,~F.mode(),~U32.show,~Unit,~Unit,~observe0(),~fold0())
def fold1() -> Owners1() -> Owners1() & List<&2,Records.Fields<F.S>>:fold0()
def App1() -> Type:Build.Registered<F.S,F.World(),Owners1(),Rows1(),observe1(),fold1()>
def Owners2() -> Type:Owners1() & ServiceOwner()
def Rows2() -> Data:DTO.Product<Rows1(),Service.View<F.S>>
def observe2() -> F.World() -> F.World() & DTO.Observation<Rows2()>:Tree.observe_pair(~F.World(),~Rows1(),~Service.View<F.S>,~observe1(),~Service.observe(~F.S,~F.Store,~F.Resources,~F.Events(),~Array<U32>,~F.ClockRest,~F.clock_take,~F.clock_put,~F.clock_call,~F.clock_declaration(),~scan()))
def fold2() -> Owners2() -> Owners2() & List<&2,Records.Fields<F.S>>:Leaf.fold_pair(~F.S,~Owners1(),~ServiceOwner(),~fold1(),~Service.fields(~F.S,~F.Store,~F.Resources,~F.Events(),~Array<U32>,~F.ClockRest,~F.clock_take,~F.clock_put,~F.clock_call,~F.clock_declaration(),~scan()))
def App2() -> Type:Build.Registered<F.S,F.World(),Owners2(),Rows2(),observe2(),fold2()>
def Owners3() -> Type:Owners2() & ComponentRecord()
def Rows3() -> Data:DTO.Product<Rows2(),DTO.Product<Unit,List<&2,IQ.ProjectedRow<F.S,Cmp.Access<U32>>>>>
def observe3() -> F.World() -> F.World() & DTO.Observation<Rows3()>:Tree.observe_pair(~F.World(),~Rows2(),~DTO.Product<Unit,List<&2,IQ.ProjectedRow<F.S,Cmp.Access<U32>>>>,~observe2(),~Leaves.component_observe(~F.S,~F.Store,~F.Resources,~F.Events(),~Ops.ComponentOps,~Cmp.Access<U32>,~Ops.component_query(),~Ops.component_text))
def fold3() -> Owners3() -> Owners3() & List<&2,Records.Fields<F.S>>:Leaf.fold_pair(~F.S,~Owners2(),~ComponentRecord(),~fold2(),~Leaf.observed(~F.S,~Records.Token<ComponentRegistry()>))
def App3() -> Type:Build.Registered<F.S,F.World(),Owners3(),Rows3(),observe3(),fold3()>
def Owners4() -> Type:Owners3() & ResourceRecord()
def Rows4() -> Data:DTO.Product<Rows3(),U32>
def observe4() -> F.World() -> F.World() & DTO.Observation<Rows4()>:Tree.observe_pair(~F.World(),~Rows3(),~U32,~observe3(),~RL.resource_observe(~F.S,~F.Store,~F.Resources,~F.Events(),~RD.read_ops(~F.S,~Array<U32>,~F.inventory_identity(),~U32),~U32,~Ops.resource_declaration()))
def fold4() -> Owners4() -> Owners4() & List<&2,Records.Fields<F.S>>:Leaf.fold_pair(~F.S,~Owners3(),~ResourceRecord(),~fold3(),~Leaf.observed(~F.S,~Records.Token<ResourceRegistry()>))
def App4() -> Type:Build.Registered<F.S,F.World(),Owners4(),Rows4(),observe4(),fold4()>
def machine(app:App0()) -> App1():Machine.install(~F.S,~F.Mode,~U32,~F.Store,~F.Resources,~F.Events(),~F.machine_take,~F.machine_put,~U32.is_eq,~F.mode(),~U32.show,~Owners0(),~Rows0(),~observe0(),~fold0(),app)
def service(~Out:Type,done:App2() -> Out,failed:App1() -> Out,app:App1()) -> Out:Service.install(~F.S,~F.Store,~F.Resources,~F.Events(),~Array<U32>,~F.ClockRest,~F.clock_take,~F.clock_put,~F.clock_call,~F.clock_declaration(),~scan(),~Owners1(),~Rows1(),~observe1(),~fold1(),~Out,done,failed,D.single(~F.S,~F.Store,~F.Resources,~F.Events(),~Array<U32>,~F.ClockRest,~F.clock_take,~F.clock_put,~F.clock_call,~F.clock_declaration()),"ClockSystem",app)
def component(~Out:Type,done:App3() -> Out,failed:App2() -> Out,app:App2()) -> Out:Component.register(~F.S,~F.Store,~F.Resources,~F.Events(),~Owners2(),~Rows2(),~observe2(),~fold2(),~Ops.ComponentOps,~Unit,~Unit,~Unit,~Cmp.Access<U32>,~Ops.component_query(),~Ops.component_text,~Ops.component_body,~Out,done,failed,app,"FirstRead",Identity.key(~F.S,~Array<U32>,Binding.identity(~F.S,~F.Store,~F.Rest,~Array<U32>,~U32,~F.First,~F.first_take,~F.first_put,~F.view,F.first_binding())))
def resource(~Out:Type,done:App4() -> Out,failed:App3() -> Out,app:App3()) -> Out:Resource.register(~F.S,~F.Store,~F.Resources,~F.Events(),~Owners3(),~Rows3(),~observe3(),~fold3(),~RD.read_ops(~F.S,~Array<U32>,~F.inventory_identity(),~U32),~Unit,~Unit,~Unit,~U32,~Ops.resource_declaration(),~Ops.resource_body,~Out,done,failed,app,"InventoryRead",Schema.resource_key(~F.S,~Array<U32>,F.inventory_identity()))
