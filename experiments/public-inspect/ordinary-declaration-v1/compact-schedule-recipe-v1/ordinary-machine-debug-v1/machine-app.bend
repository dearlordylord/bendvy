import Base
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-composer.bend as Build
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-recipe.bend as Tree
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-observation-data.bend as DTO
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-registration-fields.bend as Fields
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/inspector.bend as I
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-machine-declaration.bend as OD
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-machine-operations.bend as Ops
import /workspace/formal-proofs/bendvy/src/ecs/machine.bend as M
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as T
import /workspace/formal-proofs/bendvy/src/ecs/commands.bend as Cmd

# A declaration-derived value observer, not a fabricated resource/system record.
def current_text(~S:Data,~K:Data,~V:Data,~render:V -> String,view:M.CurrentView<S,K,V>) -> String:
  match view:
    case M.Unavailable{}:"Unavailable"
    case M.Current{value}:"Current:" ++ render(value)
def presented(~S:Data,~K:Data,~V:Data,~C:Type,~R:Type,~E:Data,~take:R -> R & M.Slot<S,K,V>,~declaration:OD.Declaration<S,K,V,R,take>,~render:V -> String,result:I.Frame<S,C,R,E> & M.CurrentView<S,K,V>) -> W.World<S,C,R,E> & DTO.Observation<M.CurrentView<S,K,V>>:
  match result:
    case (I.Frame{world,_},+view):(world,DTO.Observation{view,[OD.name(~S,~K,~V,~R,~take,declaration) ++ ":" ++ current_text(~S,~K,~V,~render,view)]})
def observe(~S:Data,~K:Data,~V:Data,~C:Type,~R:Type,~E:Data,~take:R -> R & M.Slot<S,K,V>,~declaration:OD.Declaration<S,K,V,R,take>,~render:V -> String,world:W.World<S,C,R,E>) -> W.World<S,C,R,E> & DTO.Observation<M.CurrentView<S,K,V>>:
  presented(~S,~K,~V,~C,~R,~E,~take,~declaration,~render,OD.get(~I.Frame<S,C,R,E>,~S,~K,~V,~OD.inspect(~S,~K,~V,~C,~R,~E,~take,~declaration),I.Frame{world,0}))
def attach(~S:Data,~K:Data,~V:Data,~C:Type,~R:Type,~E:Data,~take:R -> R & M.Slot<S,K,V>,~declaration:OD.Declaration<S,K,V,R,take>,~render:V -> String,~Owners:Type,~Rows:Data,~prior:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Fields.Fields<S>>,app:Build.Registered<S,W.World<S,C,R,E>,Owners,Rows,prior,fold>) -> Build.Registered<S,W.World<S,C,R,E>,Owners,DTO.Product<Rows,M.CurrentView<S,K,V>>,Tree.observe_pair(~W.World<S,C,R,E>,~Rows,~M.CurrentView<S,K,V>,~prior,~observe(~S,~K,~V,~C,~R,~E,~take,~declaration,~render)),fold>:
  match app:
    case Build.Registered{world,owners,_,debug}:Build.Registered{world,owners,Tree.Recipe{},debug}
# Operational queue and debug current grant are generated from the SAME declaration.
def queue(~S:Data,~K:Data,~V:Data,~C:Type,~R:Type,~E:Data,~take:R -> R & M.Slot<S,K,V>,~put:R -> M.Slot<S,K,V> -> R,~same:V -> V -> Bool,~declaration:OD.Declaration<S,K,V,R,take>,~Error:Data,world:W.World<S,C,R,E>,request:M.QueueInput<V>,outcome:T.Outcome<Error>) -> T.Returned<W.World<S,C,R,E>,Error>:
  Cmd.tx_finish(~S,~C,~R,~E,~Error,Cap.value_set(~T.Tx<W.World<S,C,R,E>,E>,~M.QueueInput<V>,~M.CurrentView<S,K,V>,~Ops.write(~S,~K,~V,~C,~R,~E,~take,~put,~same,~declaration),T.begin(~W.World<S,C,R,E>,~E,world),request),outcome)
