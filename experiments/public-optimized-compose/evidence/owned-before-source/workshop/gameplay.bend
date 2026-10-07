import Base
import schema.bend as S
import json.bend as J
import ../../../src/ecs/capabilities.bend as Cap
import ../../../src/ecs/component.bend as C
import ../../../src/ecs/transaction.bend as T
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/compose.bend as Q

type Error is Data:
  Rejected{}
  MissingFixture{}
type WorkCaps<-H: Type> is Type:
  WorkCaps{stock: Cap.Write<H,S.Stock,S.StockView>,recipe: Cap.Read<H,S.RecipeView>,queue: Cap.Read<H,S.QueueView>,id: Cap.ValueRead<H,U32>}
def WorkOps(H: Type) -> Type:
  WorkCaps<H>
def work_stock(~H: Type,caps: WorkCaps<H>) -> Cap.Write<H,S.Stock,S.StockView>:
  match caps:
    case WorkCaps{stock,_,_,_}: stock
def work_recipe(~H: Type,caps: WorkCaps<H>) -> Cap.Read<H,S.RecipeView>:
  match caps:
    case WorkCaps{_,recipe,_,_}: recipe
def work_queue(~H: Type,caps: WorkCaps<H>) -> Cap.Read<H,S.QueueView>:
  match caps:
    case WorkCaps{_,_,queue,_}: queue
def work_id(~H: Type,caps: WorkCaps<H>) -> Cap.ValueRead<H,U32>:
  match caps:
    case WorkCaps{_,_,_,id}: id
def queue_value(value: C.Access<S.QueueView>) -> U32:
  match value:
    case C.Found{S.QueueView{value,_}}: value
    case _: 0

def work_queue_read(~H: Type,~caps: WorkCaps<H>,+value: U32,+owned: List<&2,U32>,+r: U32,observed: H & C.Access<S.QueueView>) -> H & (T.Outcome<Error> & Unit):
  (ctx,+queue) = observed
  (Cap.set(~H,~S.Stock,~S.StockView,~work_stock(~H,caps),ctx,S.stock_owner(S.StockView{(value + r : U32),List.append(&2,U32,owned,[queue_value(queue)])})),(T.Success{},Unit{}))
def work_recipe_view(~H: Type,~caps: WorkCaps<H>,+value: U32,+owned: List<&2,U32>,recipe: S.RecipeView,ctx: H) -> H & (T.Outcome<Error> & Unit):
  match recipe:
    case S.RecipeView{+r,_}: work_queue_read(~H,~caps,value,owned,r,Cap.read(~H,~S.QueueView,~work_queue(~H,caps),ctx))
def work_write(~H: Type,~caps: WorkCaps<H>,stock: S.StockView,recipe: S.RecipeView,ctx: H) -> H & (T.Outcome<Error> & Unit):
  match stock:
    case S.StockView{+value,+owned}: work_recipe_view(~H,~caps,value,owned,recipe,ctx)
def work_recipe_read(~H: Type,~caps: WorkCaps<H>,stock: S.StockView,observed: H & C.Access<S.RecipeView>) -> H & (T.Outcome<Error> & Unit):
  match observed:
    case (ctx,C.Found{recipe}): work_write(~H,~caps,stock,recipe,ctx)
    case (ctx,_): (ctx,(T.Failure{MissingFixture{}},Unit{}))
def work_stock_read(~H: Type,~caps: WorkCaps<H>,observed: H & C.Access<S.StockView>) -> H & (T.Outcome<Error> & Unit):
  match observed:
    case (ctx,C.Found{stock}): work_recipe_read(~H,~caps,stock,Cap.read(~H,~S.RecipeView,~work_recipe(~H,caps),ctx))
    case (ctx,_): (ctx,(T.Failure{MissingFixture{}},Unit{}))
def work_body(~H: Type,~caps: WorkCaps<H>,args: Unit,ctx: H) -> H & (T.Outcome<Error> & Unit):
  work_stock_read(~H,~caps,Cap.get(~H,~S.Stock,~S.StockView,~work_stock(~H,caps),ctx))

def compose_queue(~H: Type,~caps: WorkCaps<H>,+id: U32,+stock: C.Access<S.StockView>,+recipe: C.Access<S.RecipeView>,observed: H & C.Access<S.QueueView>) -> H & (T.Outcome<Error> & String):
  (ctx,+queue) = observed
  (ctx,(T.Success{},"{\"id\":" ++ U32.show(id) ++ ",\"stock\":" ++ J.stock(stock) ++ ",\"recipe\":" ++ J.recipe(recipe) ++ ",\"queue\":" ++ J.queue(queue) ++ "}"))
def compose_recipe(~H: Type,~caps: WorkCaps<H>,+id: U32,+stock: C.Access<S.StockView>,observed: H & C.Access<S.RecipeView>) -> H & (T.Outcome<Error> & String):
  (ctx,+recipe) = observed
  compose_queue(~H,~caps,id,stock,recipe,Cap.read(~H,~S.QueueView,~work_queue(~H,caps),ctx))
def compose_stock(~H: Type,~caps: WorkCaps<H>,+id: U32,observed: H & C.Access<S.StockView>) -> H & (T.Outcome<Error> & String):
  (ctx,+stock) = observed
  compose_recipe(~H,~caps,id,stock,Cap.read(~H,~S.RecipeView,~work_recipe(~H,caps),ctx))
def compose_id(~H: Type,~caps: WorkCaps<H>,observed: H & U32) -> H & (T.Outcome<Error> & String):
  (ctx,+id) = observed
  compose_stock(~H,~caps,id,Cap.get(~H,~S.Stock,~S.StockView,~work_stock(~H,caps),ctx))
def compose_body(~H: Type,~caps: WorkCaps<H>,args: Unit,ctx: H) -> H & (T.Outcome<Error> & String):
  compose_id(~H,~caps,Cap.value_read(~H,~U32,~work_id(~H,caps),ctx))

type RetryArgs is Data:
  RetryArgs{fail: Bool,target: W.Handle<S.Schema>}
type RetryCaps<-H: Type> is Type:
  RetryCaps{stock: Cap.Write<H,S.Stock,S.StockView>,recipe: Cap.Write<H,S.Recipe,S.RecipeView>,queue: Cap.Write<H,S.Queue,S.QueueView>,insert: Cap.Send<H,Q.Insert<S.Schema,S.Queue>>}
def RetryOps(H: Type) -> Type: RetryCaps<H>
def retry_stock(~H: Type,caps: RetryCaps<H>) -> Cap.Write<H,S.Stock,S.StockView>:
  match caps:
    case RetryCaps{stock,_,_,_}: stock
def retry_recipe(~H: Type,caps: RetryCaps<H>) -> Cap.Write<H,S.Recipe,S.RecipeView>:
  match caps:
    case RetryCaps{_,recipe,_,_}: recipe
def retry_queue(~H: Type,caps: RetryCaps<H>) -> Cap.Write<H,S.Queue,S.QueueView>:
  match caps:
    case RetryCaps{_,_,queue,_}: queue
def retry_insert(~H: Type,caps: RetryCaps<H>) -> Cap.Send<H,Q.Insert<S.Schema,S.Queue>>:
  match caps:
    case RetryCaps{_,_,_,insert}: insert
def retry_value(fail: Bool) -> U32:
  match fail:
    case True{}: 900
    case False{}: 100
def command_value(fail: Bool) -> U32:
  match fail:
    case True{}: 999
    case False{}: 31
def retry_outcome(fail: Bool) -> T.Outcome<Error>:
  match fail:
    case True{}: T.Failure{Rejected{}}
    case False{}: T.Success{}
def retry_body(~H: Type,~caps: RetryCaps<H>,args: RetryArgs,ctx: H) -> H & (T.Outcome<Error> & Unit):
  match args:
    case RetryArgs{+fail,+target}:
      ctx = Cap.set(~H,~S.Stock,~S.StockView,~retry_stock(~H,caps),ctx,S.stock_payload(retry_value(fail)))
      ctx = Cap.set(~H,~S.Recipe,~S.RecipeView,~retry_recipe(~H,caps),ctx,S.recipe_payload(retry_value(fail)))
      ctx = Cap.set(~H,~S.Queue,~S.QueueView,~retry_queue(~H,caps),ctx,S.queue_payload(retry_value(fail)))
      ctx = Cap.send(~H,~Q.Insert<S.Schema,S.Queue>,~retry_insert(~H,caps),ctx,Q.Insert{target,S.queue_payload(command_value(fail))})
      (ctx,(retry_outcome(fail),Unit{}))

type DuplicateCaps<-H: Type> is Type:
  DuplicateCaps{a: Cap.Write<H,S.Stock,S.StockView>,b: Cap.Write<H,S.Stock,S.StockView>,r: Cap.Read<H,S.StockView>,id: Cap.ValueRead<H,U32>}
def DuplicateOps(H: Type) -> Type: DuplicateCaps<H>
def duplicate_a(~H: Type,caps: DuplicateCaps<H>) -> Cap.Write<H,S.Stock,S.StockView>:
  match caps:
    case DuplicateCaps{a,_,_,_}: a
def duplicate_b(~H: Type,caps: DuplicateCaps<H>) -> Cap.Write<H,S.Stock,S.StockView>:
  match caps:
    case DuplicateCaps{_,b,_,_}: b
def duplicate_r(~H: Type,caps: DuplicateCaps<H>) -> Cap.Read<H,S.StockView>:
  match caps:
    case DuplicateCaps{_,_,r,_}: r
def duplicate_id(~H: Type,caps: DuplicateCaps<H>) -> Cap.ValueRead<H,U32>:
  match caps:
    case DuplicateCaps{_,_,_,id}: id
def duplicate_after_b(~H: Type,+afterA: C.Access<S.StockView>,observed: H & C.Access<S.StockView>) -> H & (T.Outcome<Error> & String):
  (ctx,+afterB) = observed
  (ctx,(T.Success{},"{\"label\":\"duplicate-family-reference\",\"afterA\":" ++ J.stock(afterA) ++ ",\"afterB\":" ++ J.stock(afterB) ++ ",\"readHasSet\":false}"))
def duplicate_after_a(~H: Type,~caps: DuplicateCaps<H>,observed: H & C.Access<S.StockView>) -> H & (T.Outcome<Error> & String):
  (ctx,+afterA) = observed
  duplicate_after_b(~H,afterA,Cap.read(~H,~S.StockView,~duplicate_r(~H,caps),Cap.set(~H,~S.Stock,~S.StockView,~duplicate_b(~H,caps),ctx,S.stock_payload(71))))
def duplicate_selected(~H: Type,~caps: DuplicateCaps<H>,selected: Bool,ctx: H) -> H & (T.Outcome<Error> & String):
  match selected:
    case False{}: (ctx,(T.Success{},""))
    case True{}: duplicate_after_a(~H,~caps,Cap.get(~H,~S.Stock,~S.StockView,~duplicate_b(~H,caps),Cap.set(~H,~S.Stock,~S.StockView,~duplicate_a(~H,caps),ctx,S.stock_payload(70))))
def duplicate_named(~H: Type,~caps: DuplicateCaps<H>,observed: H & U32) -> H & (T.Outcome<Error> & String):
  (ctx,+id) = observed
  duplicate_selected(~H,~caps,U32.is_eq(id,1),ctx)
def duplicate_body(~H: Type,~caps: DuplicateCaps<H>,args: Unit,ctx: H) -> H & (T.Outcome<Error> & String):
  duplicate_named(~H,~caps,Cap.value_read(~H,~U32,~duplicate_id(~H,caps),ctx))
