import Base
import schema.bend as S
import ../../src/ecs/capabilities.bend as Cap
import ../../src/ecs/compose.bend as Q
import ../../src/ecs/component.bend as C
import ../../src/ecs/world.bend as W
import ../../src/ecs/system.bend as Sys
import ../../src/ecs/transaction.bend as T
import ../../src/ecs/removals.bend as Rm
import ../../src/ecs/event-runtime.bend as Ev

def comma(first: Bool) -> String:
  match first:
    case True{}: ""
    case False{}: ","
def numbers_loop(items: List<&2,U32>,+acc: String,first: Bool) -> String:
  match items:
    case []: "[" ++ acc
    case value <> rest: numbers_loop(rest,U32.show(value) ++ comma(first) ++ acc,False{})
def numbers(+values: List<&2,U32>) -> String:
  numbers_loop(List.reverse(&2,U32,values),"]",True{})
def raw(x: String) -> String: x
def array(xs: List<&2,String>) -> String:
  List.show(~&2,~String,~raw,xs)
def quoted(x: String) -> String: "\"" ++ x ++ "\""
def boolean(x: Bool) -> String:
  match x:
    case True{}: "true"
    case False{}: "false"
def id(handle: W.Handle<S.Schema>) -> U32:
  match handle:
    case W.Handle{_,id}: id
def ping_loop(values: List<&2,S.Notice>,acc: List<&2,U32>) -> List<&2,U32>:
  match values:
    case []: List.reverse(&2,U32,acc)
    case S.Ping{value} <> rest: ping_loop(rest,value <> acc)
    case _ <> rest: ping_loop(rest,acc)
def ping_values(values: List<&2,S.Notice>) -> List<&2,U32>:
  ping_loop(values,[])
def select(value: S.Notice) -> Maybe<&2,Rm.Record<S.Schema,S.AllToken>>:
  match value:
    case S.RemovedStock{handle}: Some{Rm.Removed{handle,S.StockFamily{}}}
    case S.RemovedAux{handle}: Some{Rm.Removed{handle,S.AuxFamily{}}}
    case S.Gone{handle}: Some{Rm.Despawned{handle}}
    case _: None{}
def removal_stock(xs: List<&2,Rm.Record<S.Schema,S.AllToken>>) -> List<&2,U32>:
  match xs:
    case []: []
    case Rm.Removed{handle,S.StockFamily{}} <> rest: id(handle) <> removal_stock(rest)
    case _ <> rest: removal_stock(rest)
def removal_aux(xs: List<&2,Rm.Record<S.Schema,S.AllToken>>) -> List<&2,U32>:
  match xs:
    case []: []
    case Rm.Removed{handle,S.AuxFamily{}} <> rest: id(handle) <> removal_aux(rest)
    case _ <> rest: removal_aux(rest)
def removal_gone(xs: List<&2,Rm.Record<S.Schema,S.AllToken>>) -> List<&2,U32>:
  match xs:
    case []: []
    case Rm.Despawned{handle} <> rest: id(handle) <> removal_gone(rest)
    case _ <> rest: removal_gone(rest)
def removal_text(+xs: List<&2,Rm.Record<S.Schema,S.AllToken>>) -> String:
  "\"stock\":" ++ numbers(removal_stock(xs)) ++ ",\"aux\":" ++ numbers(removal_aux(xs)) ++ ",\"despawned\":" ++ numbers(removal_gone(xs))
def removal_success(xs: List<&2,Rm.Record<S.Schema,S.AllToken>>) -> Result<&2,&1,String,String>:
  Done{removal_text(xs)}
def removal_fail(xs: List<&2,Rm.Record<S.Schema,S.AllToken>>) -> Result<&2,&1,String,String>:
  Fail{removal_text(xs)}
type ReadArgs is Data:
  ReadArgs{name: String,fail: Bool,own: Bool,cursor: U32}
type Failure is Data:
  Failed{observation: String}
def finish(world: S.World(),+text: String,fail: Bool) -> Sys.Outcome<S.World(),Failure,String>:
  match fail:
    case True{}: Sys.Failed{world,Failed{text}}
    case False{}: Sys.Succeeded{world,text}
def event_body(world: S.World(),input: Ev.Input<S.Notice,ReadArgs>) -> Sys.Outcome<S.World(),Failure,String>:
  match input:
    case Ev.Input{+values,+lagged,ReadArgs{+name,fail,_,_}}: finish(world,"{\"kind\":\"event\",\"name\":" ++ quoted(name) ++ ",\"values\":" ++ numbers(ping_values(values)) ++ ",\"lagged\":" ++ boolean(lagged) ++ "}",fail)
type ChangeCaps<-H: Type> is Type:
  ChangeCaps{stock: Cap.Write<H,S.Stock,S.StockView>,handle: Cap.ValueRead<H,W.Handle<S.Schema>>}
def Ops(H: Type) -> Type: ChangeCaps<H>
def stock(~H: Type,caps: ChangeCaps<H>) -> Cap.Write<H,S.Stock,S.StockView>:
  match caps:
    case ChangeCaps{stock,_}: stock
def handle(~H: Type,caps: ChangeCaps<H>) -> Cap.ValueRead<H,W.Handle<S.Schema>>:
  match caps:
    case ChangeCaps{_,handle}: handle
def view(value: S.StockView) -> String:
  match value:
    case S.StockView{value,owned}: "\"value\":" ++ U32.show(value) ++ ",\"owned\":" ++ numbers(owned)
def row(+entity: W.Handle<S.Schema>,+value: S.StockView) -> String:
  "{\"id\":" ++ U32.show(id(entity)) ++ "," ++ view(value) ++ "}"
def increment(value: S.StockView) -> S.Stock:
  match value:
    case S.StockView{+value,+owned}: S.stock_owner(S.StockView{(value + 1 : U32),List.append(&2,U32,owned,[(value + 1 : U32)])})
def change_write(~H: Type,~caps: ChangeCaps<H>,own: Bool,+entity: W.Handle<S.Schema>,+value: S.StockView,ctx: H) -> H & (T.Outcome<String> & String):
  match own:
    case True{}: (Cap.set(~H,~S.Stock,~S.StockView,~stock(~H,caps),ctx,increment(value)),(T.Success{},row(entity,value)))
    case False{}: (ctx,(T.Success{},row(entity,value)))
def change_value(~H: Type,~caps: ChangeCaps<H>,own: Bool,+entity: W.Handle<S.Schema>,observed: H & C.Access<S.StockView>) -> H & (T.Outcome<String> & String):
  match observed:
    case (ctx,C.Found{+value}): change_write(~H,~caps,own,entity,value,ctx)
    case (ctx,_): (ctx,(T.Failure{"missing"},"missing"))
def change_handle(~H: Type,~caps: ChangeCaps<H>,own: Bool,observed: H & W.Handle<S.Schema>) -> H & (T.Outcome<String> & String):
  (ctx,+entity) = observed
  change_value(~H,~caps,own,entity,Cap.get(~H,~S.Stock,~S.StockView,~stock(~H,caps),ctx))
def change_body(~H: Type,~caps: ChangeCaps<H>,own: Bool,ctx: H) -> H & (T.Outcome<String> & String):
  change_handle(~H,~caps,own,Cap.value_read(~H,~W.Handle<S.Schema>,~handle(~H,caps),ctx))
def frame() -> Type: Q.Frame<S.Schema,S.Store,Unit,S.Notice>
def changed(ctx: frame()) -> frame() & Bool:
  Q.lifecycle_match(~S.Schema,~S.Store,~Unit,~S.Notice,~S.StockRest,~S.Stock,~S.StockView,~S.StockToken,~S.take_stock,~S.put_stock,~S.project_stock,~S.stock(),~Q.Changed{},ctx)
def plan() -> Q.Plan<S.Schema,S.Store,Unit,S.Notice,Ops>:
  Q.Plan{ChangeCaps{Q.write_family(~S.Schema,~S.Store,~Unit,~S.Notice,~S.StockRest,~S.Stock,~S.StockView,~S.StockToken,~S.take_stock,~S.put_stock,~S.project_stock,~S.stock()),Q.handle_read(~S.Schema,~S.Store,~Unit,~S.Notice)},changed}
type Mode is Data:
  Mode{own: Bool,fail: Bool}
def row_outcome(fail: Bool,+row: String) -> T.Outcome<String>:
  match fail:
    case True{}: T.Failure{row}
    case False{}: T.Success{}
def change_return_outcome(~H: Type,fail: Bool,ctx: H,result: T.Outcome<String> & String) -> H & (T.Outcome<String> & String):
  match result:
    case (T.Success{},+value): (ctx,(row_outcome(fail,value),value))
    case (T.Failure{error},value): (ctx,(T.Failure{error},value))
def change_return(~H: Type,fail: Bool,observed: H & (T.Outcome<String> & String)) -> H & (T.Outcome<String> & String):
  (ctx,result) = observed
  change_return_outcome(~H,fail,ctx,result)
def transactional_body(~H: Type,~caps: ChangeCaps<H>,mode: Mode,ctx: H) -> H & (T.Outcome<String> & String):
  match mode:
    case Mode{own,fail}: change_return(~H,fail,change_body(~H,~caps,own,ctx))
def change_result(+name: String,result: Q.Executed<S.World(),Q.Error<String>,String>) -> Sys.Outcome<S.World(),Failure,String>:
  match result:
    case Q.Executed{world,T.Success{},+values}: finish(world,"{\"kind\":\"change\",\"name\":" ++ quoted(name) ++ ",\"values\":" ++ array(values) ++ "}",False{})
    case Q.Executed{world,T.Failure{Q.UserError{+value}},_}: finish(world,"{\"kind\":\"change\",\"name\":" ++ quoted(name) ++ ",\"values\":" ++ array([value]) ++ "}",True{})
    case Q.Executed{world,_,_}: finish(world,"unexpected-change-failure",True{})
def change_runner(world: S.World(),args: ReadArgs) -> Sys.Outcome<S.World(),Failure,String>:
  match args:
    case ReadArgs{+name,fail,own,cursor}: change_result(name,Q.each_since(~S.Schema,~S.Store,~Unit,~S.Notice,~Ops,~Mode,~String,~String,~plan(),~transactional_body,Mode{own,fail},world,cursor))
