import Base
import schema.bend as S
import json.bend as J
import ../../src/ecs/world.bend as W
import ../../src/ecs/component.bend as C

def handle_id(handle: W.Handle<S.Schema>) -> U32:
  match handle:
    case W.Handle{_,id}: id

def row_locked(+handle: W.Handle<S.Schema>,+stock: C.Access<S.StockView>,+recipe: C.Access<S.RecipeView>,+queue: C.Access<S.QueueView>,+enabled: C.Access<S.Enabled>,observed: S.World() & C.Access<S.Locked>) -> S.World() & String:
  (world,+locked) = observed
  (world,"{\"id\":" ++ U32.show(handle_id(handle)) ++ ",\"stock\":" ++ J.stock(stock) ++ ",\"recipe\":" ++ J.recipe(recipe) ++ ",\"queue\":" ++ J.queue(queue) ++ ",\"enabled\":" ++ J.enabled(enabled) ++ ",\"locked\":" ++ J.locked(locked) ++ "}")
def row_enabled(+handle: W.Handle<S.Schema>,+stock: C.Access<S.StockView>,+recipe: C.Access<S.RecipeView>,+queue: C.Access<S.QueueView>,observed: S.World() & C.Access<S.Enabled>) -> S.World() & String:
  (world,+enabled) = observed
  row_locked(handle,stock,recipe,queue,enabled,S.get_locked(world,handle))
def row_queue(+handle: W.Handle<S.Schema>,+stock: C.Access<S.StockView>,+recipe: C.Access<S.RecipeView>,observed: S.World() & C.Access<S.QueueView>) -> S.World() & String:
  (world,+queue) = observed
  row_enabled(handle,stock,recipe,queue,S.get_enabled(world,handle))
def row_recipe(+handle: W.Handle<S.Schema>,+stock: C.Access<S.StockView>,observed: S.World() & C.Access<S.RecipeView>) -> S.World() & String:
  (world,+recipe) = observed
  row_queue(handle,stock,recipe,S.get_queue(world,handle))
def row_stock(+handle: W.Handle<S.Schema>,observed: S.World() & C.Access<S.StockView>) -> S.World() & String:
  (world,+stock) = observed
  row_recipe(handle,stock,S.get_recipe(world,handle))
def row(world: S.World(),+handle: W.Handle<S.Schema>) -> S.World() & String:
  row_stock(handle,S.get_stock(world,handle))
def row_accumulate(+prior: List<&2,String>,observed: S.World() & String) -> S.World() & List<&2,String>:
  (world,+head) = observed
  (world,head <> prior)
def rows(handles: List<&2,W.Handle<S.Schema>>,observed: S.World() & List<&2,String>) -> S.World() & List<&2,String>:
  match handles:
    case []:
      (world,+prior) = observed
      (world,List.reverse(&2,String,prior))
    case +handle <> rest:
      (world,+prior) = observed
      rows(rest,row_accumulate(prior,row(world,handle)))
def all_join(observed: S.World() & List<&2,W.Handle<S.Schema>>) -> S.World() & List<&2,String>:
  (world,+handles) = observed
  rows(handles,(world,[]))
def all(world: S.World()) -> S.World() & List<&2,String>:
  all_join(W.handles(~S.Schema,~S.Store,~Unit,~Unit,world))
