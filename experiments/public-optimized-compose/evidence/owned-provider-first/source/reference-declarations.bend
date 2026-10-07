import Base
import ../../../src/ecs/optimized-compose.bend as Opt
import schema.bend as S
import gameplay.bend as G
import observe.bend as O
import ../../../src/ecs/capabilities.bend as Cap
import ../../../src/ecs/compose.bend as Q
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/component.bend as C
import ../../../src/ecs/transaction.bend as T

def Frame() -> Type:
  Q.Frame<S.Schema,S.Store,Unit,Unit>
def read_stock() -> Cap.Read<Frame(),S.StockView>:
  Q.read_family(~S.Schema,~S.Store,~Unit,~Unit,~S.StockRest,~S.Stock,~S.StockView,~S.StockToken,~S.take_stock,~S.put_stock,~S.project_stock,~S.stock())
def write_stock() -> Cap.Write<Frame(),S.Stock,S.StockView>:
  Q.write_family(~S.Schema,~S.Store,~Unit,~Unit,~S.StockRest,~S.Stock,~S.StockView,~S.StockToken,~S.take_stock,~S.put_stock,~S.project_stock,~S.stock())
def match_stock(~mode: Q.Selection,frame: Frame()) -> Frame() & Bool:
  Q.family_match(~S.Schema,~S.Store,~Unit,~Unit,~S.StockRest,~S.Stock,~S.StockView,~S.StockToken,~S.take_stock,~S.put_stock,~S.project_stock,~S.stock(),~mode,frame)
def read_recipe() -> Cap.Read<Frame(),S.RecipeView>:
  Q.read_family(~S.Schema,~S.Store,~Unit,~Unit,~S.RecipeRest,~S.Recipe,~S.RecipeView,~S.RecipeToken,~S.take_recipe,~S.put_recipe,~S.project_recipe,~S.recipe())
def write_recipe() -> Cap.Write<Frame(),S.Recipe,S.RecipeView>:
  Q.write_family(~S.Schema,~S.Store,~Unit,~Unit,~S.RecipeRest,~S.Recipe,~S.RecipeView,~S.RecipeToken,~S.take_recipe,~S.put_recipe,~S.project_recipe,~S.recipe())
def match_recipe(~mode: Q.Selection,frame: Frame()) -> Frame() & Bool:
  Q.family_match(~S.Schema,~S.Store,~Unit,~Unit,~S.RecipeRest,~S.Recipe,~S.RecipeView,~S.RecipeToken,~S.take_recipe,~S.put_recipe,~S.project_recipe,~S.recipe(),~mode,frame)
def read_queue() -> Cap.Read<Frame(),S.QueueView>:
  Q.read_family(~S.Schema,~S.Store,~Unit,~Unit,~S.QueueRest,~S.Queue,~S.QueueView,~S.QueueToken,~S.take_queue,~S.put_queue,~S.project_queue,~S.queue())
def write_queue() -> Cap.Write<Frame(),S.Queue,S.QueueView>:
  Q.write_family(~S.Schema,~S.Store,~Unit,~Unit,~S.QueueRest,~S.Queue,~S.QueueView,~S.QueueToken,~S.take_queue,~S.put_queue,~S.project_queue,~S.queue())
def match_queue(~mode: Q.Selection,frame: Frame()) -> Frame() & Bool:
  Q.family_match(~S.Schema,~S.Store,~Unit,~Unit,~S.QueueRest,~S.Queue,~S.QueueView,~S.QueueToken,~S.take_queue,~S.put_queue,~S.project_queue,~S.queue(),~mode,frame)
def read_enabled() -> Cap.Read<Frame(),S.Enabled>:
  Q.read_family(~S.Schema,~S.Store,~Unit,~Unit,~S.EnabledRest,~S.Enabled,~S.Enabled,~S.EnabledToken,~S.take_enabled,~S.put_enabled,~S.project_enabled,~S.enabled())
def write_enabled() -> Cap.Write<Frame(),S.Enabled,S.Enabled>:
  Q.write_family(~S.Schema,~S.Store,~Unit,~Unit,~S.EnabledRest,~S.Enabled,~S.Enabled,~S.EnabledToken,~S.take_enabled,~S.put_enabled,~S.project_enabled,~S.enabled())
def match_enabled(~mode: Q.Selection,frame: Frame()) -> Frame() & Bool:
  Q.family_match(~S.Schema,~S.Store,~Unit,~Unit,~S.EnabledRest,~S.Enabled,~S.Enabled,~S.EnabledToken,~S.take_enabled,~S.put_enabled,~S.project_enabled,~S.enabled(),~mode,frame)
def read_locked() -> Cap.Read<Frame(),S.Locked>:
  Q.read_family(~S.Schema,~S.Store,~Unit,~Unit,~S.LockedRest,~S.Locked,~S.Locked,~S.LockedToken,~S.take_locked,~S.put_locked,~S.project_locked,~S.locked())
def write_locked() -> Cap.Write<Frame(),S.Locked,S.Locked>:
  Q.write_family(~S.Schema,~S.Store,~Unit,~Unit,~S.LockedRest,~S.Locked,~S.Locked,~S.LockedToken,~S.take_locked,~S.put_locked,~S.project_locked,~S.locked())
def match_locked(~mode: Q.Selection,frame: Frame()) -> Frame() & Bool:
  Q.family_match(~S.Schema,~S.Store,~Unit,~Unit,~S.LockedRest,~S.Locked,~S.Locked,~S.LockedToken,~S.take_locked,~S.put_locked,~S.project_locked,~S.locked(),~mode,frame)
def id_join(observed: Frame() & W.Handle<S.Schema>) -> Frame() & U32:
  (frame,+handle) = observed
  (frame,O.handle_id(handle))
def id_get(frame: Frame()) -> Frame() & U32:
  id_join(Q.handle_get(~S.Schema,~S.Store,~Unit,~Unit,frame))
def id_read() -> Cap.ValueRead<Frame(),U32>:
  Cap.ValueRead{id_get}
def work_caps() -> G.WorkCaps<Frame()>:
  G.WorkCaps{write_stock(),read_recipe(),read_queue(),id_read()}
def structural_match(frame: Frame()) -> Frame() & Bool:
  Q.both(~S.Schema,~S.Store,~Unit,~Unit,~match_enabled(~Q.Present{}),~match_locked(~Q.Absent{}),frame)
def work_required(frame: Frame()) -> Frame() & Bool:
  Q.both(~S.Schema,~S.Store,~Unit,~Unit,~match_stock(~Q.Required{}),~match_recipe(~Q.Required{}),frame)
def work_match(frame: Frame()) -> Frame() & Bool:
  Q.both(~S.Schema,~S.Store,~Unit,~Unit,~work_required,~structural_match,frame)
def work_plan() -> Q.Plan<S.Schema,S.Store,Unit,Unit,G.WorkOps>:
  Q.Plan{work_caps(),work_match}
def work(world: S.World()) -> Q.Executed<S.World(),Q.Error<G.Error>,Unit>:
  Opt.each(~S.Schema,~S.Store,~Unit,~Unit,~G.WorkOps,~Unit,~G.Error,~Unit,~work_plan(),~G.work_body,~S.prepare_store,~S.recover_store,Unit{},world)
def composed(world: S.World()) -> Q.Executed<S.World(),Q.Error<G.Error>,String>:
  Opt.each(~S.Schema,~S.Store,~Unit,~Unit,~G.WorkOps,~Unit,~G.Error,~String,~work_plan(),~G.compose_body,~S.prepare_store,~S.recover_store,Unit{},world)

def EmptyOps(H: Type) -> Type:
  Cap.ValueRead<H,U32>
def empty_join(~H: Type,observed: H & U32) -> H & (T.Outcome<G.Error> & String):
  (ctx,+id) = observed
  (ctx,(T.Success{},"{\"id\":" ++ U32.show(id) ++ ",\"data\":{}}"))
def empty_body(~H: Type,~caps: Cap.ValueRead<H,U32>,args: Unit,ctx: H) -> H & (T.Outcome<G.Error> & String):
  empty_join(~H,Cap.value_read(~H,~U32,~caps,ctx))
def empty_plan() -> Q.Plan<S.Schema,S.Store,Unit,Unit,EmptyOps>:
  Q.Plan{id_read(),Q.all(~S.Schema,~S.Store,~Unit,~Unit)}
def empty(world: S.World()) -> Q.Executed<S.World(),Q.Error<G.Error>,String>:
  Opt.each(~S.Schema,~S.Store,~Unit,~Unit,~EmptyOps,~Unit,~G.Error,~String,~empty_plan(),~empty_body,~S.identity_store,~S.identity_store,Unit{},world)
def contradictory_match(frame: Frame()) -> Frame() & Bool:
  Q.both(~S.Schema,~S.Store,~Unit,~Unit,~match_enabled(~Q.Present{}),~match_enabled(~Q.Absent{}),frame)
def contradictory_plan() -> Q.Plan<S.Schema,S.Store,Unit,Unit,EmptyOps>:
  Q.Plan{id_read(),contradictory_match}
def contradictory(world: S.World()) -> Q.Executed<S.World(),Q.Error<G.Error>,String>:
  Opt.each(~S.Schema,~S.Store,~Unit,~Unit,~EmptyOps,~Unit,~G.Error,~String,~contradictory_plan(),~empty_body,~S.prepare_enabled,~S.recover_enabled,Unit{},world)
def retry_caps() -> G.RetryCaps<Frame()>:
  G.RetryCaps{write_stock(),write_recipe(),write_queue(),Q.command_insert(~S.Schema,~S.Store,~Unit,~Unit,~S.QueueRest,~S.Queue,~S.QueueView,~S.QueueToken,~S.take_queue,~S.put_queue,~S.project_queue,~S.queue())}
def triple_match(frame: Frame()) -> Frame() & Bool:
  Q.both(~S.Schema,~S.Store,~Unit,~Unit,~work_match,~match_queue(~Q.Required{}),frame)
def retry_plan() -> Q.Plan<S.Schema,S.Store,Unit,Unit,G.RetryOps>:
  Q.Plan{retry_caps(),triple_match}
def retry(world: S.World(),args: G.RetryArgs) -> Q.Executed<S.World(),Q.Error<G.Error>,Unit>:
  Opt.each(~S.Schema,~S.Store,~Unit,~Unit,~G.RetryOps,~G.RetryArgs,~G.Error,~Unit,~retry_plan(),~G.retry_body,~S.prepare_store,~S.recover_store,args,world)
def duplicate_caps() -> G.DuplicateCaps<Frame()>:
  G.DuplicateCaps{write_stock(),write_stock(),read_stock(),id_read()}
def duplicate_plan() -> Q.Plan<S.Schema,S.Store,Unit,Unit,G.DuplicateOps>:
  Q.Plan{duplicate_caps(),match_stock(~Q.Required{})}
def duplicate(world: S.World()) -> Q.Executed<S.World(),Q.Error<G.Error>,String>:
  Opt.each(~S.Schema,~S.Store,~Unit,~Unit,~G.DuplicateOps,~Unit,~G.Error,~String,~duplicate_plan(),~G.duplicate_body,~S.prepare_stock,~S.recover_stock,Unit{},world)

def lifecycle_recipe(frame: Frame()) -> Frame() & Bool:
  Q.lifecycle_match(~S.Schema,~S.Store,~Unit,~Unit,~S.RecipeRest,~S.Recipe,~S.RecipeView,~S.RecipeToken,~S.take_recipe,~S.put_recipe,~S.project_recipe,~S.recipe(),~Q.Added{},frame)
def lifecycle_stock(frame: Frame()) -> Frame() & Bool:
  Q.lifecycle_match(~S.Schema,~S.Store,~Unit,~Unit,~S.StockRest,~S.Stock,~S.StockView,~S.StockToken,~S.take_stock,~S.put_stock,~S.project_stock,~S.stock(),~Q.Changed{},frame)
def advanced_lifecycle(frame: Frame()) -> Frame() & Bool:
  Q.both(~S.Schema,~S.Store,~Unit,~Unit,~lifecycle_recipe,~lifecycle_stock,frame)
def advanced_match(frame: Frame()) -> Frame() & Bool:
  Q.both(~S.Schema,~S.Store,~Unit,~Unit,~structural_match,~advanced_lifecycle,frame)
type AdvancedCaps<-H: Type> is Type:
  AdvancedCaps{stock: Cap.Read<H,S.StockView>,queue: Cap.Read<H,S.QueueView>,id: Cap.ValueRead<H,U32>}
def AdvancedOps(H: Type) -> Type: AdvancedCaps<H>
def advanced_stock(~H: Type,caps: AdvancedCaps<H>) -> Cap.Read<H,S.StockView>:
  match caps:
    case AdvancedCaps{stock,_,_}: stock
def advanced_queue(~H: Type,caps: AdvancedCaps<H>) -> Cap.Read<H,S.QueueView>:
  match caps:
    case AdvancedCaps{_,queue,_}: queue
def advanced_handle(~H: Type,caps: AdvancedCaps<H>) -> Cap.ValueRead<H,U32>:
  match caps:
    case AdvancedCaps{_,_,id}: id
def advanced_caps() -> AdvancedCaps<Frame()>:
  AdvancedCaps{read_stock(),read_queue(),id_read()}
def advanced_plan() -> Q.Plan<S.Schema,S.Store,Unit,Unit,AdvancedOps>:
  Q.Plan{advanced_caps(),advanced_match}
def advanced_id(~H: Type,observed: H & U32) -> H & (T.Outcome<G.Error> & U32):
  (ctx,+id) = observed
  (ctx,(T.Success{},id))
def advanced_queue_read(~H: Type,~caps: AdvancedCaps<H>,observed: H & C.Access<S.QueueView>) -> H & (T.Outcome<G.Error> & U32):
  (ctx,_) = observed
  advanced_id(~H,Cap.value_read(~H,~U32,~advanced_handle(~H,caps),ctx))
def advanced_stock_read(~H: Type,~caps: AdvancedCaps<H>,observed: H & C.Access<S.StockView>) -> H & (T.Outcome<G.Error> & U32):
  (ctx,_) = observed
  advanced_queue_read(~H,~caps,Cap.read(~H,~S.QueueView,~advanced_queue(~H,caps),ctx))
def advanced_body(~H: Type,~caps: AdvancedCaps<H>,args: Unit,ctx: H) -> H & (T.Outcome<G.Error> & U32):
  advanced_stock_read(~H,~caps,Cap.read(~H,~S.StockView,~advanced_stock(~H,caps),ctx))
def advanced(world: S.World(),+cursor: U32) -> Q.Executed<S.World(),Q.Error<G.Error>,U32>:
  Opt.each_since(~S.Schema,~S.Store,~Unit,~Unit,~AdvancedOps,~Unit,~G.Error,~U32,~advanced_plan(),~advanced_body,~S.prepare_advanced,~S.recover_advanced,Unit{},world,cursor)
