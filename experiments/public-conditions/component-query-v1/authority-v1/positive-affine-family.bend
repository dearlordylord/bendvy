import Base
import ../fixture.bend as F
import ../schema.bend as Model
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-check-query.bend as CQ
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-check-declaration.bend as D
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-component-binding.bend as B
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-checked-condition.bend as Cond
import /workspace/formal-proofs/bendvy/src/ecs/inspector-query.bend as Query
import /workspace/formal-proofs/bendvy/src/ecs/component.bend as C
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy/src/ecs/check.bend as K
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
def accepted(~S:Data,~Store:Type,~R:Type,~E:Data,~Rest:Type,~P:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,P>,~put:Rest -> Col.Column<S,P> -> Store,~view:P -> P & V,~binding:B.Binding<S,Store,Rest,P,V,Token,take,put,view>) -> CQ.Selection<K.Frame<S,Store,R,E>,S,C.Access<V>>:CQ.read(~S,~Store,~R,~E,~Rest,~P,~V,~Token,~take,~put,~view,~binding)
