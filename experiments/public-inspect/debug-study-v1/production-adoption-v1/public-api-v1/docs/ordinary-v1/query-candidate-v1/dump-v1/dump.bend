import Base
import ../app.bend as App
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy/src/ecs/component.bend as C
import /workspace/formal-proofs/bendvy/src/ecs/inspector.bend as I
import /workspace/formal-proofs/bendvy/src/ecs/inspector-query-projection.bend as Scan
import /workspace/formal-proofs/bendvy/experiments/public-snapshot/persistence-gate-v1/basic-world-v1/public-adoption-v1/core-promotion-v1/library/ordinary-declaration.bend as Identity

type Population<S:Data,V:Data> is Data:
  Population{name:String,rows:List<&2,Scan.Row<S,V>>}
def observed(~S:Data,~Store:Type,~R:Type,~E:Data,~V:Data,name:String,got:I.Frame<S,Store,R,E> & List<&2,Scan.Row<S,V>>) -> W.World<S,Store,R,E> & Maybe<&2,Population<S,V>>:
  match got:
    case (I.Frame{world,_},rows):(world,Some{Population{name,rows}})
# A detached population view, never a registered Inspector instance or snapshot.
# The only user-specific rendering callback is the ordinary opaque payload view.
def component(~S:Data,~P:Type,~Store:Type,~R:Type,~E:Data,~Rest:Type,~V:Data,~Token:Data,~identity:Identity.Declaration<S,P>,~view:P -> P & V,~take:Store -> Rest & Col.Column<S,P>,~put:Rest -> Col.Column<S,P> -> Store,debug:App.Debug,world:W.World<S,Store,R,E>) -> W.World<S,Store,R,E> & Maybe<&2,Population<S,V>>:
  match debug:
    case App.Disabled{}:(world,None{})
    case App.Enabled{}:observed(~S,~Store,~R,~E,~V,Identity.key(~S,~P,identity),Scan.scan(~S,~Store,~R,~E,~Rest,~P,~V,~Token,~take,~put,~view,~C.Family{Identity.key(~S,~P,identity)},~Scan.Optional{},I.Frame{world,0}))
