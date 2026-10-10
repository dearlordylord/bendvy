import Base
import ../resource-system-v1/provider.bend as P
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-schema.bend as Schema
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as T
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-query-declaration.bend as Query
# One static declaration constructs operational and owner-preserving observation routes.
# It carries no runtime-owned World or resource payload.
type Declaration<-S:Data,-C:Type,-R:Type,-E:Data,-Ops:Type -> Type,-V:Data> is Type:
  Declaration{ordinary:P.Declaration<S,R,T.Tx<W.World<S,C,R,E>,E>,Ops(T.Tx<W.World<S,C,R,E>,E>)>,observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & V,render:V -> String}
def read_ops(~V:Data,H:Type) -> Type:
  Cap.ValueRead<H,V>
def write_ops(~R:Type,~V:Data,H:Type) -> Type:
  Cap.ValueWrite<H,R,V>
def read(~S:Data,~C:Type,~R:Type,~E:Data,~V:Data,~project:R -> R & V,~render:V -> String,identity:Schema.Resource<S,R>) -> Declaration<S,C,R,E,read_ops(~V),V>:
  Declaration{P.read(~S,~C,~R,~E,~V,~project,identity),W.observe_resource(~S,~C,~R,~E,~V,~project),render}
def write(~S:Data,~C:Type,~R:Type,~E:Data,~V:Data,~project:R -> R & V,~render:V -> String,identity:Schema.Resource<S,R>) -> Declaration<S,C,R,E,write_ops(~R,~V),V>:
  Declaration{P.write(~S,~C,~R,~E,~V,~project,identity),W.observe_resource(~S,~C,~R,~E,~V,~project),render}
def ordinary(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~V:Data,declaration:Declaration<S,C,R,E,Ops,V>) -> P.Declaration<S,R,T.Tx<W.World<S,C,R,E>,E>,Ops(T.Tx<W.World<S,C,R,E>,E>)>:
  match declaration:
    case Declaration{ordinary,_,_}:ordinary
def observer(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~V:Data,declaration:Declaration<S,C,R,E,Ops,V>) -> W.World<S,C,R,E> -> W.World<S,C,R,E> & V:
  match declaration:
    case Declaration{_,observe,_}:observe
def presenter(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~V:Data,declaration:Declaration<S,C,R,E,Ops,V>) -> V -> String:
  match declaration:
    case Declaration{_,_,render}:render
def named(~S:Data,value:Query.Clause<S>) -> String:
  match value:
    case Query.Clause{key,_}:key
def name(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~V:Data,declaration:Declaration<S,C,R,E,Ops,V>) -> String:
  named(~S,P.clause(~S,~R,~T.Tx<W.World<S,C,R,E>,E>,~Ops(T.Tx<W.World<S,C,R,E>,E>),ordinary(~S,~C,~R,~E,~Ops,~V,declaration)))
