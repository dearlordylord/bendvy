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

# Ordinary operational binding: setup derives the observer from the same declaration.
def Application(~S:Data,~K:Data,~V:Data,~C:Type,~R:Type,~E:Data,~take:R -> R & M.Slot<S,K,V>,~put:R -> M.Slot<S,K,V> -> R,~same:V -> V -> Bool,~declaration:OD.Declaration<S,K,V,R,take>,~render:V -> String,~Owners:Type,~Rows:Data,~prior:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Fields.Fields<S>>) -> Type:
  Build.Registered<S,W.World<S,C,R,E>,Owners,DTO.Product<Rows,M.CurrentView<S,K,V>>,Tree.observe_pair(~W.World<S,C,R,E>,~Rows,~M.CurrentView<S,K,V>,~prior,~observe(~S,~K,~V,~C,~R,~E,~take,~declaration,~render)),fold>
def install(~S:Data,~K:Data,~V:Data,~C:Type,~R:Type,~E:Data,~take:R -> R & M.Slot<S,K,V>,~put:R -> M.Slot<S,K,V> -> R,~same:V -> V -> Bool,~declaration:OD.Declaration<S,K,V,R,take>,~render:V -> String,~Owners:Type,~Rows:Data,~prior:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Fields.Fields<S>>,app:Build.Registered<S,W.World<S,C,R,E>,Owners,Rows,prior,fold>) -> Application(~S,~K,~V,~C,~R,~E,~take,~put,~same,~declaration,~render,~Owners,~Rows,~prior,~fold):
  attach(~S,~K,~V,~C,~R,~E,~take,~declaration,~render,~Owners,~Rows,~prior,~fold,app)
def returned(~S:Data,~K:Data,~V:Data,~C:Type,~R:Type,~E:Data,~take:R -> R & M.Slot<S,K,V>,~put:R -> M.Slot<S,K,V> -> R,~same:V -> V -> Bool,~declaration:OD.Declaration<S,K,V,R,take>,~render:V -> String,~Owners:Type,~Rows:Data,~prior:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Fields.Fields<S>>,~Error:Data,owners:Owners,recipe:Tree.Recipe<W.World<S,C,R,E>,DTO.Product<Rows,M.CurrentView<S,K,V>>,Tree.observe_pair(~W.World<S,C,R,E>,~Rows,~M.CurrentView<S,K,V>,~prior,~observe(~S,~K,~V,~C,~R,~E,~take,~declaration,~render))>,debug:Bool,result:T.Returned<W.World<S,C,R,E>,Error>) -> Application(~S,~K,~V,~C,~R,~E,~take,~put,~same,~declaration,~render,~Owners,~Rows,~prior,~fold) & T.Outcome<Error>:
  match result:
    case T.Returned{world,status}:(Build.Registered{world,owners,recipe,debug},status)
def queue_app(~S:Data,~K:Data,~V:Data,~C:Type,~R:Type,~E:Data,~take:R -> R & M.Slot<S,K,V>,~put:R -> M.Slot<S,K,V> -> R,~same:V -> V -> Bool,~declaration:OD.Declaration<S,K,V,R,take>,~render:V -> String,~Owners:Type,~Rows:Data,~prior:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Fields.Fields<S>>,~Error:Data,app:Application(~S,~K,~V,~C,~R,~E,~take,~put,~same,~declaration,~render,~Owners,~Rows,~prior,~fold),request:M.QueueInput<V>,outcome:T.Outcome<Error>) -> Application(~S,~K,~V,~C,~R,~E,~take,~put,~same,~declaration,~render,~Owners,~Rows,~prior,~fold) & T.Outcome<Error>:
  match app:
    case Build.Registered{world,owners,recipe,debug}:returned(~S,~K,~V,~C,~R,~E,~take,~put,~same,~declaration,~render,~Owners,~Rows,~prior,~fold,~Error,owners,recipe,debug,queue(~S,~K,~V,~C,~R,~E,~take,~put,~same,~declaration,~Error,world,request,outcome))
def read_finished(~S:Data,~K:Data,~V:Data,~C:Type,~R:Type,~E:Data,~take:R -> R & M.Slot<S,K,V>,~put:R -> M.Slot<S,K,V> -> R,~same:V -> V -> Bool,~declaration:OD.Declaration<S,K,V,R,take>,~render:V -> String,~Owners:Type,~Rows:Data,~prior:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Fields.Fields<S>>,view:M.CurrentView<S,K,V>,result:Application(~S,~K,~V,~C,~R,~E,~take,~put,~same,~declaration,~render,~Owners,~Rows,~prior,~fold) & T.Outcome<Unit>) -> Application(~S,~K,~V,~C,~R,~E,~take,~put,~same,~declaration,~render,~Owners,~Rows,~prior,~fold) & M.CurrentView<S,K,V>:
  match result:
    case (app,_):(app,view)
def read_taken(~S:Data,~K:Data,~V:Data,~C:Type,~R:Type,~E:Data,~take:R -> R & M.Slot<S,K,V>,~put:R -> M.Slot<S,K,V> -> R,~same:V -> V -> Bool,~declaration:OD.Declaration<S,K,V,R,take>,~render:V -> String,~Owners:Type,~Rows:Data,~prior:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Fields.Fields<S>>,owners:Owners,recipe:Tree.Recipe<W.World<S,C,R,E>,DTO.Product<Rows,M.CurrentView<S,K,V>>,Tree.observe_pair(~W.World<S,C,R,E>,~Rows,~M.CurrentView<S,K,V>,~prior,~observe(~S,~K,~V,~C,~R,~E,~take,~declaration,~render))>,debug:Bool,result:T.Tx<W.World<S,C,R,E>,E> & M.CurrentView<S,K,V>) -> Application(~S,~K,~V,~C,~R,~E,~take,~put,~same,~declaration,~render,~Owners,~Rows,~prior,~fold) & M.CurrentView<S,K,V>:
  match result:
    case (frame,view):read_finished(~S,~K,~V,~C,~R,~E,~take,~put,~same,~declaration,~render,~Owners,~Rows,~prior,~fold,view,returned(~S,~K,~V,~C,~R,~E,~take,~put,~same,~declaration,~render,~Owners,~Rows,~prior,~fold,~Unit,owners,recipe,debug,Cmd.tx_finish(~S,~C,~R,~E,~Unit,frame,T.Success{})))
def read_app(~S:Data,~K:Data,~V:Data,~C:Type,~R:Type,~E:Data,~take:R -> R & M.Slot<S,K,V>,~put:R -> M.Slot<S,K,V> -> R,~same:V -> V -> Bool,~declaration:OD.Declaration<S,K,V,R,take>,~render:V -> String,~Owners:Type,~Rows:Data,~prior:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Fields.Fields<S>>,app:Application(~S,~K,~V,~C,~R,~E,~take,~put,~same,~declaration,~render,~Owners,~Rows,~prior,~fold)) -> Application(~S,~K,~V,~C,~R,~E,~take,~put,~same,~declaration,~render,~Owners,~Rows,~prior,~fold) & M.CurrentView<S,K,V>:
  match app:
    case Build.Registered{world,owners,recipe,debug}:read_taken(~S,~K,~V,~C,~R,~E,~take,~put,~same,~declaration,~render,~Owners,~Rows,~prior,~fold,owners,recipe,debug,Cap.value_read(~T.Tx<W.World<S,C,R,E>,E>,~M.CurrentView<S,K,V>,~Ops.read(~S,~K,~V,~C,~R,~E,~take,~declaration),T.begin(~W.World<S,C,R,E>,~E,world)))
# Type spelling and snapshot assembly are generated by the operational library.
def ObservedRows(~S:Data,~K:Data,~V:Data,~Rows:Data) -> Data:
  DTO.Product<Rows,M.CurrentView<S,K,V>>
def observation(~S:Data,~K:Data,~V:Data,~C:Type,~R:Type,~E:Data,~take:R -> R & M.Slot<S,K,V>,~put:R -> M.Slot<S,K,V> -> R,~same:V -> V -> Bool,~declaration:OD.Declaration<S,K,V,R,take>,~render:V -> String,~Owners:Type,~Rows:Data,~prior:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Fields.Fields<S>>) -> W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<DTO.Product<Rows,M.CurrentView<S,K,V>>>:
  Tree.observe_pair(~W.World<S,C,R,E>,~Rows,~M.CurrentView<S,K,V>,~prior,~observe(~S,~K,~V,~C,~R,~E,~take,~declaration,~render))
def Recipe(~S:Data,~K:Data,~V:Data,~C:Type,~R:Type,~E:Data,~take:R -> R & M.Slot<S,K,V>,~put:R -> M.Slot<S,K,V> -> R,~same:V -> V -> Bool,~declaration:OD.Declaration<S,K,V,R,take>,~render:V -> String,~Owners:Type,~Rows:Data,~prior:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Fields.Fields<S>>) -> Type:
  Tree.Recipe<W.World<S,C,R,E>,DTO.Product<Rows,M.CurrentView<S,K,V>>,Tree.observe_pair(~W.World<S,C,R,E>,~Rows,~M.CurrentView<S,K,V>,~prior,~observe(~S,~K,~V,~C,~R,~E,~take,~declaration,~render))>
def snapshot_app(~S:Data,~K:Data,~V:Data,~C:Type,~R:Type,~E:Data,~take:R -> R & M.Slot<S,K,V>,~put:R -> M.Slot<S,K,V> -> R,~same:V -> V -> Bool,~declaration:OD.Declaration<S,K,V,R,take>,~render:V -> String,~Owners:Type,~Rows:Data,~prior:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Fields.Fields<S>>,app:Application(~S,~K,~V,~C,~R,~E,~take,~put,~same,~declaration,~render,~Owners,~Rows,~prior,~fold),flag:Bool) -> Application(~S,~K,~V,~C,~R,~E,~take,~put,~same,~declaration,~render,~Owners,~Rows,~prior,~fold) & Maybe<&2,DTO.Product<List<&2,DTO.Binding<S>>,DTO.Observation<DTO.Product<Rows,M.CurrentView<S,K,V>>>>>:
  Build.snapshot(~S,~W.World<S,C,R,E>,~Owners,~DTO.Product<Rows,M.CurrentView<S,K,V>>,~Tree.observe_pair(~W.World<S,C,R,E>,~Rows,~M.CurrentView<S,K,V>,~prior,~observe(~S,~K,~V,~C,~R,~E,~take,~declaration,~render)),~fold,Build.enabled(~S,~W.World<S,C,R,E>,~Owners,~DTO.Product<Rows,M.CurrentView<S,K,V>>,~Tree.observe_pair(~W.World<S,C,R,E>,~Rows,~M.CurrentView<S,K,V>,~prior,~observe(~S,~K,~V,~C,~R,~E,~take,~declaration,~render)),~fold,app,flag))
