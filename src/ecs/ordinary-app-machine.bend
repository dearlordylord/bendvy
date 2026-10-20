import Base
import ./ordinary-machine-initialization.bend as Init
import ./ordinary-app-composer.bend as Build
import ./ordinary-app-recipe.bend as Tree
import ./ordinary-app-observation-data.bend as DTO
import ./ordinary-app-registration-fields.bend as Fields
import ./world.bend as W
import ./inspector.bend as I
import ./ordinary-machine-declaration.bend as OD
import ./ordinary-machine-operations.bend as Ops
import ./machine.bend as M
import ./capabilities.bend as Cap
import ./transaction.bend as T
import ./commands.bend as Cmd

# A declaration-derived value observer, not a fabricated resource/system record.
def current_text(~S:Data,~K:Data,~V:Data,~render:V -> String,view:M.CurrentView<S,K,V>) -> String:
  match view:
    case M.Unavailable{}:"Unavailable"
    case M.Current{value}:"Current:" ++ render(value)
# The ordered vocabulary comes from the same operational declaration. The
# registered observer is invoked only on the enabled snapshot branch.
def vocabulary_text(~V:Data,~render:V -> String,values:List<&2,V>) -> List<&2,String>:
  match values:
    case []:[]
    case value <> rest:render(value) <> vocabulary_text(~V,~render,rest)
def vocabulary_description(~V:Data,~render:V -> String,name:String,value:Maybe<&2,List<&2,V>>) -> List<&2,String>:
  match value:
    case None{}:[]
    case Some{values}:[name ++ ":Vocabulary=" ++ List.show(&2,String,x=>x,vocabulary_text(~V,~render,values))]
def presented(~S:Data,~K:Data,~V:Data,~C:Type,~R:Type,~E:Data,~take:R -> R & M.Slot<S,K,V>,~declaration:OD.Declaration<S,K,V,R,take>,~render:V -> String,result:I.Frame<S,C,R,E> & M.CurrentView<S,K,V>) -> W.World<S,C,R,E> & DTO.Observation<M.CurrentView<S,K,V>>:
  match result:
    case (I.Frame{world,_},+view):(world,DTO.Observation{view,List.append(&2,String,[OD.name(~S,~K,~V,~R,~take,declaration) ++ ":" ++ current_text(~S,~K,~V,~render,view)],vocabulary_description(~V,~render,OD.name(~S,~K,~V,~R,~take,declaration),OD.values(~S,~K,~V,~R,~take,declaration)))})
# Advanced declaration-derived current-value observer with detached rendering and
# optional vocabulary. Returns World; the retained slot projector/render function
# are trusted setup, not a newly validated arbitrary resource adapter.
def observe(~S:Data,~K:Data,~V:Data,~C:Type,~R:Type,~E:Data,~take:R -> R & M.Slot<S,K,V>,~declaration:OD.Declaration<S,K,V,R,take>,~render:V -> String,world:W.World<S,C,R,E>) -> W.World<S,C,R,E> & DTO.Observation<M.CurrentView<S,K,V>>:
  presented(~S,~K,~V,~C,~R,~E,~take,~declaration,~render,OD.get(~I.Frame<S,C,R,E>,~S,~K,~V,~OD.inspect(~S,~K,~V,~C,~R,~E,~take,~declaration),I.Frame{world,None{}}))
# Advanced observer attachment pairing prior rows with declared machine current
# view. Retains World, registration owners and debug; does not create machine state.
def attach(~S:Data,~K:Data,~V:Data,~C:Type,~R:Type,~E:Data,~take:R -> R & M.Slot<S,K,V>,~declaration:OD.Declaration<S,K,V,R,take>,~render:V -> String,~Owners:Type,~Rows:Data,~prior:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Fields.Fields<S>>,app:Build.Registered<S,W.World<S,C,R,E>,Owners,Rows,prior,fold>) -> Build.Registered<S,W.World<S,C,R,E>,Owners,DTO.Product<Rows,M.CurrentView<S,K,V>>,Tree.observe_pair(~W.World<S,C,R,E>,~Rows,~M.CurrentView<S,K,V>,~prior,~observe(~S,~K,~V,~C,~R,~E,~take,~declaration,~render)),fold>:
  match app:
    case Build.Registered{world,owners,_,debug}:Build.Registered{world,owners,Tree.Recipe{},debug}
# Operational queue and debug current grant are generated from the SAME declaration.
# Queue a machine request through declaration-derived write caps in one Tx, then
# finish with the supplied outcome. Success retains queued state; failure restores
# recorded changes. This does not commit a transition or execute handler phases;
# vocabulary metadata is not a value-membership validation gate.
def queue(~S:Data,~K:Data,~V:Data,~C:Type,~R:Type,~E:Data,~take:R -> R & M.Slot<S,K,V>,~put:R -> M.Slot<S,K,V> -> R,~same:V -> V -> Bool,~declaration:OD.Declaration<S,K,V,R,take>,~Error:Data,world:W.World<S,C,R,E>,request:M.QueueInput<V>,outcome:T.Outcome<Error>) -> T.Returned<W.World<S,C,R,E>,Error>:
  Cmd.tx_finish(~S,~C,~R,~E,~Error,Cap.value_set(~T.Tx<W.World<S,C,R,E>,E>,~M.QueueInput<V>,~M.CurrentView<S,K,V>,~Ops.write(~S,~K,~V,~C,~R,~E,~take,~put,~same,~declaration),T.begin(~W.World<S,C,R,E>,~E,world),request),outcome)

# Ordinary operational binding: setup derives the observer from the same declaration.
# Composer App type adding this declaration's detached current-value observation.
# Machine storage remains in World resources; no fabricated system owner is added.
def Application(~S:Data,~K:Data,~V:Data,~C:Type,~R:Type,~E:Data,~take:R -> R & M.Slot<S,K,V>,~put:R -> M.Slot<S,K,V> -> R,~same:V -> V -> Bool,~declaration:OD.Declaration<S,K,V,R,take>,~render:V -> String,~Owners:Type,~Rows:Data,~prior:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Fields.Fields<S>>) -> Type:
  Build.Registered<S,W.World<S,C,R,E>,Owners,DTO.Product<Rows,M.CurrentView<S,K,V>>,Tree.observe_pair(~W.World<S,C,R,E>,~Rows,~M.CurrentView<S,K,V>,~prior,~observe(~S,~K,~V,~C,~R,~E,~take,~declaration,~render)),fold>
# Install the declaration-derived machine observer, preserving actual App owners.
# Does not initialize state, register handlers or apply a queued transition.
def install(~S:Data,~K:Data,~V:Data,~C:Type,~R:Type,~E:Data,~take:R -> R & M.Slot<S,K,V>,~put:R -> M.Slot<S,K,V> -> R,~same:V -> V -> Bool,~declaration:OD.Declaration<S,K,V,R,take>,~render:V -> String,~Owners:Type,~Rows:Data,~prior:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Fields.Fields<S>>,app:Build.Registered<S,W.World<S,C,R,E>,Owners,Rows,prior,fold>) -> Application(~S,~K,~V,~C,~R,~E,~take,~put,~same,~declaration,~render,~Owners,~Rows,~prior,~fold):
  attach(~S,~K,~V,~C,~R,~E,~take,~declaration,~render,~Owners,~Rows,~prior,~fold,app)
def returned(~S:Data,~K:Data,~V:Data,~C:Type,~R:Type,~E:Data,~take:R -> R & M.Slot<S,K,V>,~put:R -> M.Slot<S,K,V> -> R,~same:V -> V -> Bool,~declaration:OD.Declaration<S,K,V,R,take>,~render:V -> String,~Owners:Type,~Rows:Data,~prior:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Fields.Fields<S>>,~Error:Data,owners:Owners,recipe:Tree.Recipe<W.World<S,C,R,E>,DTO.Product<Rows,M.CurrentView<S,K,V>>,Tree.observe_pair(~W.World<S,C,R,E>,~Rows,~M.CurrentView<S,K,V>,~prior,~observe(~S,~K,~V,~C,~R,~E,~take,~declaration,~render))>,debug:Bool,result:T.Returned<W.World<S,C,R,E>,Error>) -> Application(~S,~K,~V,~C,~R,~E,~take,~put,~same,~declaration,~render,~Owners,~Rows,~prior,~fold) & T.Outcome<Error>:
  match result:
    case T.Returned{world,status}:(Build.Registered{world,owners,recipe,debug},status)
# App-level queue adapter returning actual App and transaction outcome. Retains
# observer/debug/registration owners; transition application remains explicit.
def queue_app(~S:Data,~K:Data,~V:Data,~C:Type,~R:Type,~E:Data,~take:R -> R & M.Slot<S,K,V>,~put:R -> M.Slot<S,K,V> -> R,~same:V -> V -> Bool,~declaration:OD.Declaration<S,K,V,R,take>,~render:V -> String,~Owners:Type,~Rows:Data,~prior:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Fields.Fields<S>>,~Error:Data,app:Application(~S,~K,~V,~C,~R,~E,~take,~put,~same,~declaration,~render,~Owners,~Rows,~prior,~fold),request:M.QueueInput<V>,outcome:T.Outcome<Error>) -> Application(~S,~K,~V,~C,~R,~E,~take,~put,~same,~declaration,~render,~Owners,~Rows,~prior,~fold) & T.Outcome<Error>:
  match app:
    case Build.Registered{world,owners,recipe,debug}:returned(~S,~K,~V,~C,~R,~E,~take,~put,~same,~declaration,~render,~Owners,~Rows,~prior,~fold,~Error,owners,recipe,debug,queue(~S,~K,~V,~C,~R,~E,~take,~put,~same,~declaration,~Error,world,request,outcome))
def read_finished(~S:Data,~K:Data,~V:Data,~C:Type,~R:Type,~E:Data,~take:R -> R & M.Slot<S,K,V>,~put:R -> M.Slot<S,K,V> -> R,~same:V -> V -> Bool,~declaration:OD.Declaration<S,K,V,R,take>,~render:V -> String,~Owners:Type,~Rows:Data,~prior:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Fields.Fields<S>>,view:M.CurrentView<S,K,V>,result:Application(~S,~K,~V,~C,~R,~E,~take,~put,~same,~declaration,~render,~Owners,~Rows,~prior,~fold) & T.Outcome<Unit>) -> Application(~S,~K,~V,~C,~R,~E,~take,~put,~same,~declaration,~render,~Owners,~Rows,~prior,~fold) & M.CurrentView<S,K,V>:
  match result:
    case (app,_):(app,view)
def read_taken(~S:Data,~K:Data,~V:Data,~C:Type,~R:Type,~E:Data,~take:R -> R & M.Slot<S,K,V>,~put:R -> M.Slot<S,K,V> -> R,~same:V -> V -> Bool,~declaration:OD.Declaration<S,K,V,R,take>,~render:V -> String,~Owners:Type,~Rows:Data,~prior:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Fields.Fields<S>>,owners:Owners,recipe:Tree.Recipe<W.World<S,C,R,E>,DTO.Product<Rows,M.CurrentView<S,K,V>>,Tree.observe_pair(~W.World<S,C,R,E>,~Rows,~M.CurrentView<S,K,V>,~prior,~observe(~S,~K,~V,~C,~R,~E,~take,~declaration,~render))>,debug:Bool,result:T.Tx<W.World<S,C,R,E>,E> & M.CurrentView<S,K,V>) -> Application(~S,~K,~V,~C,~R,~E,~take,~put,~same,~declaration,~render,~Owners,~Rows,~prior,~fold) & M.CurrentView<S,K,V>:
  match result:
    case (frame,view):read_finished(~S,~K,~V,~C,~R,~E,~take,~put,~same,~declaration,~render,~Owners,~Rows,~prior,~fold,view,returned(~S,~K,~V,~C,~R,~E,~take,~put,~same,~declaration,~render,~Owners,~Rows,~prior,~fold,~Unit,owners,recipe,debug,Cmd.tx_finish(~S,~C,~R,~E,~Unit,frame,T.Success{})))
# Read declared current value while returning App, without depending on debug.
# Unavailable remains an explicit view. Does not apply queue or run handlers.
def read_app(~S:Data,~K:Data,~V:Data,~C:Type,~R:Type,~E:Data,~take:R -> R & M.Slot<S,K,V>,~put:R -> M.Slot<S,K,V> -> R,~same:V -> V -> Bool,~declaration:OD.Declaration<S,K,V,R,take>,~render:V -> String,~Owners:Type,~Rows:Data,~prior:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Fields.Fields<S>>,app:Application(~S,~K,~V,~C,~R,~E,~take,~put,~same,~declaration,~render,~Owners,~Rows,~prior,~fold)) -> Application(~S,~K,~V,~C,~R,~E,~take,~put,~same,~declaration,~render,~Owners,~Rows,~prior,~fold) & M.CurrentView<S,K,V>:
  match app:
    case Build.Registered{world,owners,recipe,debug}:read_taken(~S,~K,~V,~C,~R,~E,~take,~put,~same,~declaration,~render,~Owners,~Rows,~prior,~fold,owners,recipe,debug,Cap.value_read(~T.Tx<W.World<S,C,R,E>,E>,~M.CurrentView<S,K,V>,~Ops.read(~S,~K,~V,~C,~R,~E,~take,~declaration),T.begin(~W.World<S,C,R,E>,~E,world)))
# Type spelling and snapshot assembly are generated by the operational library.
# Advanced detached row type: prior observation paired with current machine view.
def ObservedRows(~S:Data,~K:Data,~V:Data,~Rows:Data) -> Data:
  DTO.Product<Rows,M.CurrentView<S,K,V>>
# Advanced closed observer composition threading World through prior then machine.
def observation(~S:Data,~K:Data,~V:Data,~C:Type,~R:Type,~E:Data,~take:R -> R & M.Slot<S,K,V>,~put:R -> M.Slot<S,K,V> -> R,~same:V -> V -> Bool,~declaration:OD.Declaration<S,K,V,R,take>,~render:V -> String,~Owners:Type,~Rows:Data,~prior:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Fields.Fields<S>>) -> W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<DTO.Product<Rows,M.CurrentView<S,K,V>>>:
  Tree.observe_pair(~W.World<S,C,R,E>,~Rows,~M.CurrentView<S,K,V>,~prior,~observe(~S,~K,~V,~C,~R,~E,~take,~declaration,~render))
# Advanced typed observation recipe projection, with no separate machine owner.
def Recipe(~S:Data,~K:Data,~V:Data,~C:Type,~R:Type,~E:Data,~take:R -> R & M.Slot<S,K,V>,~put:R -> M.Slot<S,K,V> -> R,~same:V -> V -> Bool,~declaration:OD.Declaration<S,K,V,R,take>,~render:V -> String,~Owners:Type,~Rows:Data,~prior:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Fields.Fields<S>>) -> Type:
  Tree.Recipe<W.World<S,C,R,E>,DTO.Product<Rows,M.CurrentView<S,K,V>>,Tree.observe_pair(~W.World<S,C,R,E>,~Rows,~M.CurrentView<S,K,V>,~prior,~observe(~S,~K,~V,~C,~R,~E,~take,~declaration,~render))>
# Set observation flag then return optional combined snapshot with App. Disabled
# bypasses current-value projection/rendering; no queue application or barrier.
def snapshot_app(~S:Data,~K:Data,~V:Data,~C:Type,~R:Type,~E:Data,~take:R -> R & M.Slot<S,K,V>,~put:R -> M.Slot<S,K,V> -> R,~same:V -> V -> Bool,~declaration:OD.Declaration<S,K,V,R,take>,~render:V -> String,~Owners:Type,~Rows:Data,~prior:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Fields.Fields<S>>,app:Application(~S,~K,~V,~C,~R,~E,~take,~put,~same,~declaration,~render,~Owners,~Rows,~prior,~fold),flag:Bool) -> Application(~S,~K,~V,~C,~R,~E,~take,~put,~same,~declaration,~render,~Owners,~Rows,~prior,~fold) & Maybe<&2,DTO.Product<List<&2,DTO.Binding<S>>,DTO.Observation<DTO.Product<Rows,M.CurrentView<S,K,V>>>>>:
  Build.snapshot(~S,~W.World<S,C,R,E>,~Owners,~DTO.Product<Rows,M.CurrentView<S,K,V>>,~Tree.observe_pair(~W.World<S,C,R,E>,~Rows,~M.CurrentView<S,K,V>,~prior,~observe(~S,~K,~V,~C,~R,~E,~take,~declaration,~render)),~fold,Build.enabled(~S,~W.World<S,C,R,E>,~Owners,~DTO.Product<Rows,M.CurrentView<S,K,V>>,~Tree.observe_pair(~W.World<S,C,R,E>,~Rows,~M.CurrentView<S,K,V>,~prior,~observe(~S,~K,~V,~C,~R,~E,~take,~declaration,~render)),~fold,app,flag))

# Ordinary initialization preserves the existing app's sole owners and debug recipe.
def initialized_app(~S:Data,~K:Data,~V:Data,~R:Type,~take:R -> R & Init.State<S,K,V>,~put:R -> Init.State<S,K,V> -> R,~C:Type,~E:Data,~Owners:Type,~Rows:Data,~prior:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Fields.Fields<S>>,owners:Owners,recipe:Tree.Recipe<W.World<S,C,R,E>,Rows,prior>,debug:Bool,world:W.World<S,C,R,E>) -> Build.Registered<S,W.World<S,C,R,E>,Owners,Rows,prior,fold>:
  Build.Registered{world,owners,recipe,debug}
# Initialize missing state from make; already-present state skips make. Preserve
# actual App owners/recipe/debug. Uses ordinary initialization and its initial
# publication/revision semantics, not handler execution or generic undo recovery.
def init_app(~S:Data,~K:Data,~V:Data,~R:Type,~take:R -> R & Init.State<S,K,V>,~put:R -> Init.State<S,K,V> -> R,~C:Type,~E:Data,~declaration:OD.Declaration<S,K,V,R,Init.take_slot(~S,~K,~V,~R,~take,~put)>,~make:W.World<S,C,R,E> -> W.World<S,C,R,E> & V,~Owners:Type,~Rows:Data,~prior:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Fields.Fields<S>>,app:Build.Registered<S,W.World<S,C,R,E>,Owners,Rows,prior,fold>) -> Build.Registered<S,W.World<S,C,R,E>,Owners,Rows,prior,fold>:
  match app:
    case Build.Registered{world,owners,recipe,debug}:initialized_app(~S,~K,~V,~R,~take,~put,~C,~E,~Owners,~Rows,~prior,~fold,owners,recipe,debug,Init.init_state(~S,~K,~V,~R,~take,~put,~C,~E,~declaration,~make,world))
# Explicitly insert/replace state value through ordinary initialization storage.
# Preserve App owners; occupied insertion resets transition messages under the
# existing insertion contract. This is distinct from a queued transition request.
def insert_app(~S:Data,~K:Data,~V:Data,~R:Type,~take:R -> R & Init.State<S,K,V>,~put:R -> Init.State<S,K,V> -> R,~C:Type,~E:Data,~declaration:OD.Declaration<S,K,V,R,Init.take_slot(~S,~K,~V,~R,~take,~put)>,~Owners:Type,~Rows:Data,~prior:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Fields.Fields<S>>,app:Build.Registered<S,W.World<S,C,R,E>,Owners,Rows,prior,fold>,value:V) -> Build.Registered<S,W.World<S,C,R,E>,Owners,Rows,prior,fold>:
  match app:
    case Build.Registered{world,owners,recipe,debug}:initialized_app(~S,~K,~V,~R,~take,~put,~C,~E,~Owners,~Rows,~prior,~fold,owners,recipe,debug,Init.insert_state(~S,~K,~V,~R,~take,~put,~C,~E,~declaration,world,value))
