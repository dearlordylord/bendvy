import Base
import schema.bend as S
import ../../../src/ecs/column.bend as Col
import ../../../src/ecs/restored-row.bend as R
import ../../../src/ecs/owned-family.bend as F
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/compose.bend as Q
import ../../../src/ecs/component.bend as C
import ../../../src/ecs/transaction.bend as T
import ../../../src/ecs/lifecycle.bend as L
import ../../../src/ecs/capabilities.bend as Cap

def Frame() -> Type:
  Q.Frame<S.Schema,S.Store,Unit,Unit>
def id(handle:W.Handle<S.Schema>) -> U32:
  match handle:
    case W.Handle{_,id}: id

type WorkColdState is Type:
  WorkColdState{highWater:U32,capacity:U32,depth:Nat,enabled:Col.Column<S.Schema,S.Enabled>,locked:Col.Column<S.Schema,S.Locked>,resource:Unit,events:List<&2,Unit>,pending:List<(S.World() -> S.World())>,registrations:List<&2,W.RegistrationMeta>,nextSystemId:U32,undo:List<(S.World() -> S.World())>,commands:List<(S.World() -> S.World())>,txEvents:List<&2,Unit>}
type WorkCold is Type:
  WorkCold{state:WorkColdState}
  WorkColdWrapped{inner:WorkCold}
type WorkState is Type:
  WorkState{header:F.Header<S.Schema>,stock:R.Cell<S.Schema,S.Stock>,recipe:R.Cell<S.Schema,S.Recipe>,queue:R.Cell<S.Schema,S.Queue>,cold:WorkCold}
type WorkRow is Type:
  WorkRow{state:WorkState}
  WorkWrapped{inner:WorkRow}
def enter_work(frame:Frame()) -> WorkRow:
  match frame:
    case Q.Frame{T.Tx{W.World{namespace,nextId,highWater,live,capacity,depth,S.Store{stock,recipe,queue,enabled,locked},resource,events,pending,registrations,nextSystemId,clock},undo,commands,txEvents},+handle,error,cursor}:
      WorkRow{WorkState{F.Header{namespace,nextId,live,handle,clock,error,cursor},R.detach(~S.Schema,~S.Stock,stock,id(handle)),R.detach(~S.Schema,~S.Recipe,recipe,id(handle)),R.detach(~S.Schema,~S.Queue,queue,id(handle)),WorkCold{WorkColdState{highWater,capacity,depth,enabled,locked,resource,events,pending,registrations,nextSystemId,undo,commands,txEvents}}}}
type WorkStockRest is Type:
  WorkStockRest{header:F.Header<S.Schema>,recipe:R.Cell<S.Schema,S.Recipe>,queue:R.Cell<S.Schema,S.Queue>,cold:WorkCold}
type WorkStockMetaRest is Type:
  WorkStockMetaRest{recipe:R.Cell<S.Schema,S.Recipe>,queue:R.Cell<S.Schema,S.Queue>,cold:WorkCold}
def take_work_stock(row:WorkRow) -> WorkStockRest & R.Cell<S.Schema,S.Stock>:
  match row:
    case WorkRow{WorkState{header,stock,recipe,queue,cold}}: (WorkStockRest{header,recipe,queue,cold},stock)
    case WorkWrapped{inner}: take_work_stock(inner)
def put_work_stock(rest:WorkStockRest,cell:R.Cell<S.Schema,S.Stock>) -> WorkRow:
  match rest:
    case WorkStockRest{header,recipe,queue,cold}: WorkRow{WorkState{header,cell,recipe,queue,cold}}
def header_work_stock(rest:WorkStockRest) -> WorkStockMetaRest & F.Header<S.Schema>:
  match rest:
    case WorkStockRest{header,recipe,queue,cold}: (WorkStockMetaRest{recipe,queue,cold},header)
def put_header_work_stock(rest:WorkStockMetaRest,header:F.Header<S.Schema>) -> WorkStockRest:
  match rest:
    case WorkStockMetaRest{recipe,queue,cold}: WorkStockRest{header,recipe,queue,cold}
type WorkRecipeRest is Type:
  WorkRecipeRest{header:F.Header<S.Schema>,stock:R.Cell<S.Schema,S.Stock>,queue:R.Cell<S.Schema,S.Queue>,cold:WorkCold}
type WorkRecipeMetaRest is Type:
  WorkRecipeMetaRest{stock:R.Cell<S.Schema,S.Stock>,queue:R.Cell<S.Schema,S.Queue>,cold:WorkCold}
def take_work_recipe(row:WorkRow) -> WorkRecipeRest & R.Cell<S.Schema,S.Recipe>:
  match row:
    case WorkRow{WorkState{header,stock,recipe,queue,cold}}: (WorkRecipeRest{header,stock,queue,cold},recipe)
    case WorkWrapped{inner}: take_work_recipe(inner)
def put_work_recipe(rest:WorkRecipeRest,cell:R.Cell<S.Schema,S.Recipe>) -> WorkRow:
  match rest:
    case WorkRecipeRest{header,stock,queue,cold}: WorkRow{WorkState{header,stock,cell,queue,cold}}
def header_work_recipe(rest:WorkRecipeRest) -> WorkRecipeMetaRest & F.Header<S.Schema>:
  match rest:
    case WorkRecipeRest{header,stock,queue,cold}: (WorkRecipeMetaRest{stock,queue,cold},header)
def put_header_work_recipe(rest:WorkRecipeMetaRest,header:F.Header<S.Schema>) -> WorkRecipeRest:
  match rest:
    case WorkRecipeMetaRest{stock,queue,cold}: WorkRecipeRest{header,stock,queue,cold}
type WorkQueueRest is Type:
  WorkQueueRest{header:F.Header<S.Schema>,stock:R.Cell<S.Schema,S.Stock>,recipe:R.Cell<S.Schema,S.Recipe>,cold:WorkCold}
type WorkQueueMetaRest is Type:
  WorkQueueMetaRest{stock:R.Cell<S.Schema,S.Stock>,recipe:R.Cell<S.Schema,S.Recipe>,cold:WorkCold}
def take_work_queue(row:WorkRow) -> WorkQueueRest & R.Cell<S.Schema,S.Queue>:
  match row:
    case WorkRow{WorkState{header,stock,recipe,queue,cold}}: (WorkQueueRest{header,stock,recipe,cold},queue)
    case WorkWrapped{inner}: take_work_queue(inner)
def put_work_queue(rest:WorkQueueRest,cell:R.Cell<S.Schema,S.Queue>) -> WorkRow:
  match rest:
    case WorkQueueRest{header,stock,recipe,cold}: WorkRow{WorkState{header,stock,recipe,cell,cold}}
def header_work_queue(rest:WorkQueueRest) -> WorkQueueMetaRest & F.Header<S.Schema>:
  match rest:
    case WorkQueueRest{header,stock,recipe,cold}: (WorkQueueMetaRest{stock,recipe,cold},header)
def put_header_work_queue(rest:WorkQueueMetaRest,header:F.Header<S.Schema>) -> WorkQueueRest:
  match rest:
    case WorkQueueMetaRest{stock,recipe,cold}: WorkQueueRest{header,stock,recipe,cold}
def leave_work_header(stock:Col.Column<S.Schema,S.Stock>,recipe:Col.Column<S.Schema,S.Recipe>,queue:Col.Column<S.Schema,S.Queue>,highWater:U32,capacity:U32,depth:Nat,enabled:Col.Column<S.Schema,S.Enabled>,locked:Col.Column<S.Schema,S.Locked>,resource:Unit,events:List<&2,Unit>,pending:List<(S.World() -> S.World())>,registrations:List<&2,W.RegistrationMeta>,nextSystemId:U32,undo:List<(S.World() -> S.World())>,commands:List<(S.World() -> S.World())>,txEvents:List<&2,Unit>,header:F.Header<S.Schema>) -> Frame():
  match header:
    case F.Header{namespace,nextId,live,handle,clock,error,cursor}: Q.Frame{T.Tx{W.World{namespace,nextId,highWater,live,capacity,depth,S.Store{stock,recipe,queue,enabled,locked},resource,events,pending,registrations,nextSystemId,clock},undo,commands,txEvents},handle,error,cursor}
def leave_work_cold(header:F.Header<S.Schema>,stock:Col.Column<S.Schema,S.Stock>,recipe:Col.Column<S.Schema,S.Recipe>,queue:Col.Column<S.Schema,S.Queue>,cold:WorkCold) -> Frame():
  match cold:
    case WorkCold{WorkColdState{highWater,capacity,depth,enabled,locked,resource,events,pending,registrations,nextSystemId,undo,commands,txEvents}}: leave_work_header(stock,recipe,queue,highWater,capacity,depth,enabled,locked,resource,events,pending,registrations,nextSystemId,undo,commands,txEvents,header)
    case WorkColdWrapped{inner}: leave_work_cold(header,stock,recipe,queue,inner)
def leave_work(row:WorkRow) -> Frame():
  match row:
    case WorkRow{WorkState{header,stock,recipe,queue,cold}}: leave_work_cold(header,R.attach(~S.Schema,~S.Stock,stock),R.attach(~S.Schema,~S.Recipe,recipe),R.attach(~S.Schema,~S.Queue,queue),cold)
    case WorkWrapped{inner}: leave_work(inner)

type DuplicateColdState is Type:
  DuplicateColdState{highWater:U32,capacity:U32,depth:Nat,recipe:Col.Column<S.Schema,S.Recipe>,queue:Col.Column<S.Schema,S.Queue>,enabled:Col.Column<S.Schema,S.Enabled>,locked:Col.Column<S.Schema,S.Locked>,resource:Unit,events:List<&2,Unit>,pending:List<(S.World() -> S.World())>,registrations:List<&2,W.RegistrationMeta>,nextSystemId:U32,undo:List<(S.World() -> S.World())>,commands:List<(S.World() -> S.World())>,txEvents:List<&2,Unit>}
type DuplicateCold is Type:
  DuplicateCold{state:DuplicateColdState}
  DuplicateColdWrapped{inner:DuplicateCold}
type DuplicateState is Type:
  DuplicateState{header:F.Header<S.Schema>,stock:R.Cell<S.Schema,S.Stock>,cold:DuplicateCold}
type DuplicateRow is Type:
  DuplicateRow{state:DuplicateState}
  DuplicateWrapped{inner:DuplicateRow}
def enter_duplicate(frame:Frame()) -> DuplicateRow:
  match frame:
    case Q.Frame{T.Tx{W.World{namespace,nextId,highWater,live,capacity,depth,S.Store{stock,recipe,queue,enabled,locked},resource,events,pending,registrations,nextSystemId,clock},undo,commands,txEvents},+handle,error,cursor}:
      DuplicateRow{DuplicateState{F.Header{namespace,nextId,live,handle,clock,error,cursor},R.detach(~S.Schema,~S.Stock,stock,id(handle)),DuplicateCold{DuplicateColdState{highWater,capacity,depth,recipe,queue,enabled,locked,resource,events,pending,registrations,nextSystemId,undo,commands,txEvents}}}}
type DuplicateStockRest is Type:
  DuplicateStockRest{header:F.Header<S.Schema>,cold:DuplicateCold}
type DuplicateStockMetaRest is Type:
  DuplicateStockMetaRest{cold:DuplicateCold}
def take_duplicate_stock(row:DuplicateRow) -> DuplicateStockRest & R.Cell<S.Schema,S.Stock>:
  match row:
    case DuplicateRow{DuplicateState{header,stock,cold}}: (DuplicateStockRest{header,cold},stock)
    case DuplicateWrapped{inner}: take_duplicate_stock(inner)
def put_duplicate_stock(rest:DuplicateStockRest,cell:R.Cell<S.Schema,S.Stock>) -> DuplicateRow:
  match rest:
    case DuplicateStockRest{header,cold}: DuplicateRow{DuplicateState{header,cell,cold}}
def header_duplicate_stock(rest:DuplicateStockRest) -> DuplicateStockMetaRest & F.Header<S.Schema>:
  match rest:
    case DuplicateStockRest{header,cold}: (DuplicateStockMetaRest{cold},header)
def put_header_duplicate_stock(rest:DuplicateStockMetaRest,header:F.Header<S.Schema>) -> DuplicateStockRest:
  match rest:
    case DuplicateStockMetaRest{cold}: DuplicateStockRest{header,cold}
def leave_duplicate_header(stock:Col.Column<S.Schema,S.Stock>,highWater:U32,capacity:U32,depth:Nat,recipe:Col.Column<S.Schema,S.Recipe>,queue:Col.Column<S.Schema,S.Queue>,enabled:Col.Column<S.Schema,S.Enabled>,locked:Col.Column<S.Schema,S.Locked>,resource:Unit,events:List<&2,Unit>,pending:List<(S.World() -> S.World())>,registrations:List<&2,W.RegistrationMeta>,nextSystemId:U32,undo:List<(S.World() -> S.World())>,commands:List<(S.World() -> S.World())>,txEvents:List<&2,Unit>,header:F.Header<S.Schema>) -> Frame():
  match header:
    case F.Header{namespace,nextId,live,handle,clock,error,cursor}: Q.Frame{T.Tx{W.World{namespace,nextId,highWater,live,capacity,depth,S.Store{stock,recipe,queue,enabled,locked},resource,events,pending,registrations,nextSystemId,clock},undo,commands,txEvents},handle,error,cursor}
def leave_duplicate_cold(header:F.Header<S.Schema>,stock:Col.Column<S.Schema,S.Stock>,cold:DuplicateCold) -> Frame():
  match cold:
    case DuplicateCold{DuplicateColdState{highWater,capacity,depth,recipe,queue,enabled,locked,resource,events,pending,registrations,nextSystemId,undo,commands,txEvents}}: leave_duplicate_header(stock,highWater,capacity,depth,recipe,queue,enabled,locked,resource,events,pending,registrations,nextSystemId,undo,commands,txEvents,header)
    case DuplicateColdWrapped{inner}: leave_duplicate_cold(header,stock,inner)
def leave_duplicate(row:DuplicateRow) -> Frame():
  match row:
    case DuplicateRow{DuplicateState{header,stock,cold}}: leave_duplicate_cold(header,R.attach(~S.Schema,~S.Stock,stock),cold)
    case DuplicateWrapped{inner}: leave_duplicate(inner)

type AdvancedColdState is Type:
  AdvancedColdState{highWater:U32,capacity:U32,depth:Nat,recipe:Col.Column<S.Schema,S.Recipe>,enabled:Col.Column<S.Schema,S.Enabled>,locked:Col.Column<S.Schema,S.Locked>,resource:Unit,events:List<&2,Unit>,pending:List<(S.World() -> S.World())>,registrations:List<&2,W.RegistrationMeta>,nextSystemId:U32,undo:List<(S.World() -> S.World())>,commands:List<(S.World() -> S.World())>,txEvents:List<&2,Unit>}
type AdvancedCold is Type:
  AdvancedCold{state:AdvancedColdState}
  AdvancedColdWrapped{inner:AdvancedCold}
type AdvancedState is Type:
  AdvancedState{header:F.Header<S.Schema>,stock:R.Cell<S.Schema,S.Stock>,queue:R.Cell<S.Schema,S.Queue>,cold:AdvancedCold}
type AdvancedRow is Type:
  AdvancedRow{state:AdvancedState}
  AdvancedWrapped{inner:AdvancedRow}
def enter_advanced(frame:Frame()) -> AdvancedRow:
  match frame:
    case Q.Frame{T.Tx{W.World{namespace,nextId,highWater,live,capacity,depth,S.Store{stock,recipe,queue,enabled,locked},resource,events,pending,registrations,nextSystemId,clock},undo,commands,txEvents},+handle,error,cursor}:
      AdvancedRow{AdvancedState{F.Header{namespace,nextId,live,handle,clock,error,cursor},R.detach(~S.Schema,~S.Stock,stock,id(handle)),R.detach(~S.Schema,~S.Queue,queue,id(handle)),AdvancedCold{AdvancedColdState{highWater,capacity,depth,recipe,enabled,locked,resource,events,pending,registrations,nextSystemId,undo,commands,txEvents}}}}
type AdvancedStockRest is Type:
  AdvancedStockRest{header:F.Header<S.Schema>,queue:R.Cell<S.Schema,S.Queue>,cold:AdvancedCold}
type AdvancedStockMetaRest is Type:
  AdvancedStockMetaRest{queue:R.Cell<S.Schema,S.Queue>,cold:AdvancedCold}
def take_advanced_stock(row:AdvancedRow) -> AdvancedStockRest & R.Cell<S.Schema,S.Stock>:
  match row:
    case AdvancedRow{AdvancedState{header,stock,queue,cold}}: (AdvancedStockRest{header,queue,cold},stock)
    case AdvancedWrapped{inner}: take_advanced_stock(inner)
def put_advanced_stock(rest:AdvancedStockRest,cell:R.Cell<S.Schema,S.Stock>) -> AdvancedRow:
  match rest:
    case AdvancedStockRest{header,queue,cold}: AdvancedRow{AdvancedState{header,cell,queue,cold}}
def header_advanced_stock(rest:AdvancedStockRest) -> AdvancedStockMetaRest & F.Header<S.Schema>:
  match rest:
    case AdvancedStockRest{header,queue,cold}: (AdvancedStockMetaRest{queue,cold},header)
def put_header_advanced_stock(rest:AdvancedStockMetaRest,header:F.Header<S.Schema>) -> AdvancedStockRest:
  match rest:
    case AdvancedStockMetaRest{queue,cold}: AdvancedStockRest{header,queue,cold}
type AdvancedQueueRest is Type:
  AdvancedQueueRest{header:F.Header<S.Schema>,stock:R.Cell<S.Schema,S.Stock>,cold:AdvancedCold}
type AdvancedQueueMetaRest is Type:
  AdvancedQueueMetaRest{stock:R.Cell<S.Schema,S.Stock>,cold:AdvancedCold}
def take_advanced_queue(row:AdvancedRow) -> AdvancedQueueRest & R.Cell<S.Schema,S.Queue>:
  match row:
    case AdvancedRow{AdvancedState{header,stock,queue,cold}}: (AdvancedQueueRest{header,stock,cold},queue)
    case AdvancedWrapped{inner}: take_advanced_queue(inner)
def put_advanced_queue(rest:AdvancedQueueRest,cell:R.Cell<S.Schema,S.Queue>) -> AdvancedRow:
  match rest:
    case AdvancedQueueRest{header,stock,cold}: AdvancedRow{AdvancedState{header,stock,cell,cold}}
def header_advanced_queue(rest:AdvancedQueueRest) -> AdvancedQueueMetaRest & F.Header<S.Schema>:
  match rest:
    case AdvancedQueueRest{header,stock,cold}: (AdvancedQueueMetaRest{stock,cold},header)
def put_header_advanced_queue(rest:AdvancedQueueMetaRest,header:F.Header<S.Schema>) -> AdvancedQueueRest:
  match rest:
    case AdvancedQueueMetaRest{stock,cold}: AdvancedQueueRest{header,stock,cold}
def leave_advanced_header(stock:Col.Column<S.Schema,S.Stock>,queue:Col.Column<S.Schema,S.Queue>,highWater:U32,capacity:U32,depth:Nat,recipe:Col.Column<S.Schema,S.Recipe>,enabled:Col.Column<S.Schema,S.Enabled>,locked:Col.Column<S.Schema,S.Locked>,resource:Unit,events:List<&2,Unit>,pending:List<(S.World() -> S.World())>,registrations:List<&2,W.RegistrationMeta>,nextSystemId:U32,undo:List<(S.World() -> S.World())>,commands:List<(S.World() -> S.World())>,txEvents:List<&2,Unit>,header:F.Header<S.Schema>) -> Frame():
  match header:
    case F.Header{namespace,nextId,live,handle,clock,error,cursor}: Q.Frame{T.Tx{W.World{namespace,nextId,highWater,live,capacity,depth,S.Store{stock,recipe,queue,enabled,locked},resource,events,pending,registrations,nextSystemId,clock},undo,commands,txEvents},handle,error,cursor}
def leave_advanced_cold(header:F.Header<S.Schema>,stock:Col.Column<S.Schema,S.Stock>,queue:Col.Column<S.Schema,S.Queue>,cold:AdvancedCold) -> Frame():
  match cold:
    case AdvancedCold{AdvancedColdState{highWater,capacity,depth,recipe,enabled,locked,resource,events,pending,registrations,nextSystemId,undo,commands,txEvents}}: leave_advanced_header(stock,queue,highWater,capacity,depth,recipe,enabled,locked,resource,events,pending,registrations,nextSystemId,undo,commands,txEvents,header)
    case AdvancedColdWrapped{inner}: leave_advanced_cold(header,stock,queue,inner)
def leave_advanced(row:AdvancedRow) -> Frame():
  match row:
    case AdvancedRow{AdvancedState{header,stock,queue,cold}}: leave_advanced_cold(header,R.attach(~S.Schema,~S.Stock,stock),R.attach(~S.Schema,~S.Queue,queue),cold)
    case AdvancedWrapped{inner}: leave_advanced(inner)

type EmptyColdState is Type:
  EmptyColdState{highWater:U32,capacity:U32,depth:Nat,stock:Col.Column<S.Schema,S.Stock>,recipe:Col.Column<S.Schema,S.Recipe>,queue:Col.Column<S.Schema,S.Queue>,enabled:Col.Column<S.Schema,S.Enabled>,locked:Col.Column<S.Schema,S.Locked>,resource:Unit,events:List<&2,Unit>,pending:List<(S.World() -> S.World())>,registrations:List<&2,W.RegistrationMeta>,nextSystemId:U32,undo:List<(S.World() -> S.World())>,commands:List<(S.World() -> S.World())>,txEvents:List<&2,Unit>}
type EmptyCold is Type:
  EmptyCold{state:EmptyColdState}
  EmptyColdWrapped{inner:EmptyCold}
type EmptyState is Type:
  EmptyState{header:F.Header<S.Schema>,cold:EmptyCold}
type EmptyRow is Type:
  EmptyRow{state:EmptyState}
  EmptyWrapped{inner:EmptyRow}
def enter_empty(frame:Frame()) -> EmptyRow:
  match frame:
    case Q.Frame{T.Tx{W.World{namespace,nextId,highWater,live,capacity,depth,S.Store{stock,recipe,queue,enabled,locked},resource,events,pending,registrations,nextSystemId,clock},undo,commands,txEvents},+handle,error,cursor}:
      EmptyRow{EmptyState{F.Header{namespace,nextId,live,handle,clock,error,cursor},EmptyCold{EmptyColdState{highWater,capacity,depth,stock,recipe,queue,enabled,locked,resource,events,pending,registrations,nextSystemId,undo,commands,txEvents}}}}
def leave_empty_header(highWater:U32,capacity:U32,depth:Nat,stock:Col.Column<S.Schema,S.Stock>,recipe:Col.Column<S.Schema,S.Recipe>,queue:Col.Column<S.Schema,S.Queue>,enabled:Col.Column<S.Schema,S.Enabled>,locked:Col.Column<S.Schema,S.Locked>,resource:Unit,events:List<&2,Unit>,pending:List<(S.World() -> S.World())>,registrations:List<&2,W.RegistrationMeta>,nextSystemId:U32,undo:List<(S.World() -> S.World())>,commands:List<(S.World() -> S.World())>,txEvents:List<&2,Unit>,header:F.Header<S.Schema>) -> Frame():
  match header:
    case F.Header{namespace,nextId,live,handle,clock,error,cursor}: Q.Frame{T.Tx{W.World{namespace,nextId,highWater,live,capacity,depth,S.Store{stock,recipe,queue,enabled,locked},resource,events,pending,registrations,nextSystemId,clock},undo,commands,txEvents},handle,error,cursor}
def leave_empty_cold(header:F.Header<S.Schema>,cold:EmptyCold) -> Frame():
  match cold:
    case EmptyCold{EmptyColdState{highWater,capacity,depth,stock,recipe,queue,enabled,locked,resource,events,pending,registrations,nextSystemId,undo,commands,txEvents}}: leave_empty_header(highWater,capacity,depth,stock,recipe,queue,enabled,locked,resource,events,pending,registrations,nextSystemId,undo,commands,txEvents,header)
    case EmptyColdWrapped{inner}: leave_empty_cold(header,inner)
def leave_empty(row:EmptyRow) -> Frame():
  match row:
    case EmptyRow{EmptyState{header,cold}}: leave_empty_cold(header,cold)
    case EmptyWrapped{inner}: leave_empty(inner)


def bridge_work_stock_get_join(observed:Frame() & C.Access<S.StockView>) -> WorkRow & C.Access<S.StockView>:
  match observed:
    case (frame,value): (enter_work(frame),value)
def bridge_work_stock_get(row:WorkRow) -> WorkRow & C.Access<S.StockView>:
  bridge_work_stock_get_join(Q.get(~S.Schema,~S.Store,~Unit,~Unit,~S.StockRest,~S.Stock,~S.StockView,~S.StockToken,~S.take_stock,~S.put_stock,~S.project_stock,~S.stock(),leave_work(row)))
def journal_work_stock_cold(+handle:W.Handle<S.Schema>,previous:Maybe<&1,S.Stock>,+stamp:L.Stamp,cold:WorkCold) -> WorkCold:
  match cold:
    case WorkCold{WorkColdState{highWater,capacity,depth,enabled,locked,resource,events,pending,registrations,nextSystemId,undo,commands,txEvents}}: WorkCold{WorkColdState{highWater,capacity,depth,enabled,locked,resource,events,pending,registrations,nextSystemId,(world => C.restore_stamp(~S.Schema,~S.Store,~Unit,~Unit,~S.StockRest,~S.Stock,~S.StockView,~S.StockToken,~S.take_stock,~S.put_stock,~S.project_stock,handle,stamp,C.restore(~S.Schema,~S.Store,~Unit,~Unit,~S.StockRest,~S.Stock,~S.StockView,~S.StockToken,~S.take_stock,~S.put_stock,~S.project_stock,S.stock(),handle,previous,world))) <> undo,commands,txEvents}}
    case WorkColdWrapped{inner}: journal_work_stock_cold(handle,previous,stamp,inner)
def journal_work_stock_header(recipe:R.Cell<S.Schema,S.Recipe>,queue:R.Cell<S.Schema,S.Queue>,cold:WorkCold,previous:Maybe<&1,S.Stock>,stamp:L.Stamp,header:F.Header<S.Schema>) -> WorkStockRest:
  match header:
    case F.Header{namespace,nextId,live,+handle,clock,error,cursor}: WorkStockRest{F.Header{namespace,nextId,live,handle,clock,error,cursor},recipe,queue,journal_work_stock_cold(handle,previous,stamp,cold)}
def journal_work_stock(rest:WorkStockRest,previous:Maybe<&1,S.Stock>,stamp:L.Stamp) -> WorkStockRest:
  match rest:
    case WorkStockRest{header,recipe,queue,cold}: journal_work_stock_header(recipe,queue,cold,previous,stamp,header)
def bridge_work_stock_write_result(+handle:W.Handle<S.Schema>,error:Maybe<&2,W.WorldError>,cursor:U32,result:C.SetResult<T.Tx<S.World(),Unit>,S.Stock>) -> F.WriteResult<WorkRow,S.Stock>:
  match result:
    case C.Written{tx}: F.Written{enter_work(Q.Frame{tx,handle,error,cursor})}
    case C.WriteRejected{tx,incoming,+reason}: F.Rejected{enter_work(Q.Frame{tx,handle,Q.first_error(error,reason),cursor}),incoming,reason}
    case C.WriteFailure{tx,reason}: F.Written{enter_work(Q.Frame{tx,handle,Q.first_error(error,reason),cursor})}
def bridge_work_stock_write_frame(incoming:S.Stock,frame:Frame()) -> F.WriteResult<WorkRow,S.Stock>:
  match frame:
    case Q.Frame{tx,+handle,error,cursor}: bridge_work_stock_write_result(handle,error,cursor,C.tx_set(~S.Schema,~S.Store,~Unit,~Unit,~S.StockRest,~S.Stock,~S.StockView,~S.StockToken,~S.take_stock,~S.put_stock,~S.project_stock,S.stock(),tx,handle,incoming))
def bridge_work_stock_write(row:WorkRow,incoming:S.Stock) -> F.WriteResult<WorkRow,S.Stock>:
  bridge_work_stock_write_frame(incoming,leave_work(row))
def get_work_stock(row:WorkRow) -> WorkRow & C.Access<S.StockView>:
  F.get(~S.Schema,~WorkRow,~WorkStockRest,~WorkStockMetaRest,~S.Stock,~S.StockView,~take_work_stock,~put_work_stock,~header_work_stock,~put_header_work_stock,~S.project_stock,~bridge_work_stock_get,row)
def set_work_stock(row:WorkRow,incoming:S.Stock) -> WorkRow:
  F.write_owner(~WorkRow,~S.Stock,F.write(~S.Schema,~WorkRow,~WorkStockRest,~WorkStockMetaRest,~S.Stock,~take_work_stock,~put_work_stock,~header_work_stock,~put_header_work_stock,~journal_work_stock,~bridge_work_stock_write,row,incoming))
def read_work_stock() -> Cap.Read<WorkRow,S.StockView>:
  Cap.Read{get_work_stock}
def write_work_stock() -> Cap.Write<WorkRow,S.Stock,S.StockView>:
  Cap.Write{get_work_stock,set_work_stock}
def bridge_work_recipe_get_join(observed:Frame() & C.Access<S.RecipeView>) -> WorkRow & C.Access<S.RecipeView>:
  match observed:
    case (frame,value): (enter_work(frame),value)
def bridge_work_recipe_get(row:WorkRow) -> WorkRow & C.Access<S.RecipeView>:
  bridge_work_recipe_get_join(Q.get(~S.Schema,~S.Store,~Unit,~Unit,~S.RecipeRest,~S.Recipe,~S.RecipeView,~S.RecipeToken,~S.take_recipe,~S.put_recipe,~S.project_recipe,~S.recipe(),leave_work(row)))
def journal_work_recipe_cold(+handle:W.Handle<S.Schema>,previous:Maybe<&1,S.Recipe>,+stamp:L.Stamp,cold:WorkCold) -> WorkCold:
  match cold:
    case WorkCold{WorkColdState{highWater,capacity,depth,enabled,locked,resource,events,pending,registrations,nextSystemId,undo,commands,txEvents}}: WorkCold{WorkColdState{highWater,capacity,depth,enabled,locked,resource,events,pending,registrations,nextSystemId,(world => C.restore_stamp(~S.Schema,~S.Store,~Unit,~Unit,~S.RecipeRest,~S.Recipe,~S.RecipeView,~S.RecipeToken,~S.take_recipe,~S.put_recipe,~S.project_recipe,handle,stamp,C.restore(~S.Schema,~S.Store,~Unit,~Unit,~S.RecipeRest,~S.Recipe,~S.RecipeView,~S.RecipeToken,~S.take_recipe,~S.put_recipe,~S.project_recipe,S.recipe(),handle,previous,world))) <> undo,commands,txEvents}}
    case WorkColdWrapped{inner}: journal_work_recipe_cold(handle,previous,stamp,inner)
def journal_work_recipe_header(stock:R.Cell<S.Schema,S.Stock>,queue:R.Cell<S.Schema,S.Queue>,cold:WorkCold,previous:Maybe<&1,S.Recipe>,stamp:L.Stamp,header:F.Header<S.Schema>) -> WorkRecipeRest:
  match header:
    case F.Header{namespace,nextId,live,+handle,clock,error,cursor}: WorkRecipeRest{F.Header{namespace,nextId,live,handle,clock,error,cursor},stock,queue,journal_work_recipe_cold(handle,previous,stamp,cold)}
def journal_work_recipe(rest:WorkRecipeRest,previous:Maybe<&1,S.Recipe>,stamp:L.Stamp) -> WorkRecipeRest:
  match rest:
    case WorkRecipeRest{header,stock,queue,cold}: journal_work_recipe_header(stock,queue,cold,previous,stamp,header)
def bridge_work_recipe_write_result(+handle:W.Handle<S.Schema>,error:Maybe<&2,W.WorldError>,cursor:U32,result:C.SetResult<T.Tx<S.World(),Unit>,S.Recipe>) -> F.WriteResult<WorkRow,S.Recipe>:
  match result:
    case C.Written{tx}: F.Written{enter_work(Q.Frame{tx,handle,error,cursor})}
    case C.WriteRejected{tx,incoming,+reason}: F.Rejected{enter_work(Q.Frame{tx,handle,Q.first_error(error,reason),cursor}),incoming,reason}
    case C.WriteFailure{tx,reason}: F.Written{enter_work(Q.Frame{tx,handle,Q.first_error(error,reason),cursor})}
def bridge_work_recipe_write_frame(incoming:S.Recipe,frame:Frame()) -> F.WriteResult<WorkRow,S.Recipe>:
  match frame:
    case Q.Frame{tx,+handle,error,cursor}: bridge_work_recipe_write_result(handle,error,cursor,C.tx_set(~S.Schema,~S.Store,~Unit,~Unit,~S.RecipeRest,~S.Recipe,~S.RecipeView,~S.RecipeToken,~S.take_recipe,~S.put_recipe,~S.project_recipe,S.recipe(),tx,handle,incoming))
def bridge_work_recipe_write(row:WorkRow,incoming:S.Recipe) -> F.WriteResult<WorkRow,S.Recipe>:
  bridge_work_recipe_write_frame(incoming,leave_work(row))
def get_work_recipe(row:WorkRow) -> WorkRow & C.Access<S.RecipeView>:
  F.get(~S.Schema,~WorkRow,~WorkRecipeRest,~WorkRecipeMetaRest,~S.Recipe,~S.RecipeView,~take_work_recipe,~put_work_recipe,~header_work_recipe,~put_header_work_recipe,~S.project_recipe,~bridge_work_recipe_get,row)
def set_work_recipe(row:WorkRow,incoming:S.Recipe) -> WorkRow:
  F.write_owner(~WorkRow,~S.Recipe,F.write(~S.Schema,~WorkRow,~WorkRecipeRest,~WorkRecipeMetaRest,~S.Recipe,~take_work_recipe,~put_work_recipe,~header_work_recipe,~put_header_work_recipe,~journal_work_recipe,~bridge_work_recipe_write,row,incoming))
def read_work_recipe() -> Cap.Read<WorkRow,S.RecipeView>:
  Cap.Read{get_work_recipe}
def write_work_recipe() -> Cap.Write<WorkRow,S.Recipe,S.RecipeView>:
  Cap.Write{get_work_recipe,set_work_recipe}
def bridge_work_queue_get_join(observed:Frame() & C.Access<S.QueueView>) -> WorkRow & C.Access<S.QueueView>:
  match observed:
    case (frame,value): (enter_work(frame),value)
def bridge_work_queue_get(row:WorkRow) -> WorkRow & C.Access<S.QueueView>:
  bridge_work_queue_get_join(Q.get(~S.Schema,~S.Store,~Unit,~Unit,~S.QueueRest,~S.Queue,~S.QueueView,~S.QueueToken,~S.take_queue,~S.put_queue,~S.project_queue,~S.queue(),leave_work(row)))
def journal_work_queue_cold(+handle:W.Handle<S.Schema>,previous:Maybe<&1,S.Queue>,+stamp:L.Stamp,cold:WorkCold) -> WorkCold:
  match cold:
    case WorkCold{WorkColdState{highWater,capacity,depth,enabled,locked,resource,events,pending,registrations,nextSystemId,undo,commands,txEvents}}: WorkCold{WorkColdState{highWater,capacity,depth,enabled,locked,resource,events,pending,registrations,nextSystemId,(world => C.restore_stamp(~S.Schema,~S.Store,~Unit,~Unit,~S.QueueRest,~S.Queue,~S.QueueView,~S.QueueToken,~S.take_queue,~S.put_queue,~S.project_queue,handle,stamp,C.restore(~S.Schema,~S.Store,~Unit,~Unit,~S.QueueRest,~S.Queue,~S.QueueView,~S.QueueToken,~S.take_queue,~S.put_queue,~S.project_queue,S.queue(),handle,previous,world))) <> undo,commands,txEvents}}
    case WorkColdWrapped{inner}: journal_work_queue_cold(handle,previous,stamp,inner)
def journal_work_queue_header(stock:R.Cell<S.Schema,S.Stock>,recipe:R.Cell<S.Schema,S.Recipe>,cold:WorkCold,previous:Maybe<&1,S.Queue>,stamp:L.Stamp,header:F.Header<S.Schema>) -> WorkQueueRest:
  match header:
    case F.Header{namespace,nextId,live,+handle,clock,error,cursor}: WorkQueueRest{F.Header{namespace,nextId,live,handle,clock,error,cursor},stock,recipe,journal_work_queue_cold(handle,previous,stamp,cold)}
def journal_work_queue(rest:WorkQueueRest,previous:Maybe<&1,S.Queue>,stamp:L.Stamp) -> WorkQueueRest:
  match rest:
    case WorkQueueRest{header,stock,recipe,cold}: journal_work_queue_header(stock,recipe,cold,previous,stamp,header)
def bridge_work_queue_write_result(+handle:W.Handle<S.Schema>,error:Maybe<&2,W.WorldError>,cursor:U32,result:C.SetResult<T.Tx<S.World(),Unit>,S.Queue>) -> F.WriteResult<WorkRow,S.Queue>:
  match result:
    case C.Written{tx}: F.Written{enter_work(Q.Frame{tx,handle,error,cursor})}
    case C.WriteRejected{tx,incoming,+reason}: F.Rejected{enter_work(Q.Frame{tx,handle,Q.first_error(error,reason),cursor}),incoming,reason}
    case C.WriteFailure{tx,reason}: F.Written{enter_work(Q.Frame{tx,handle,Q.first_error(error,reason),cursor})}
def bridge_work_queue_write_frame(incoming:S.Queue,frame:Frame()) -> F.WriteResult<WorkRow,S.Queue>:
  match frame:
    case Q.Frame{tx,+handle,error,cursor}: bridge_work_queue_write_result(handle,error,cursor,C.tx_set(~S.Schema,~S.Store,~Unit,~Unit,~S.QueueRest,~S.Queue,~S.QueueView,~S.QueueToken,~S.take_queue,~S.put_queue,~S.project_queue,S.queue(),tx,handle,incoming))
def bridge_work_queue_write(row:WorkRow,incoming:S.Queue) -> F.WriteResult<WorkRow,S.Queue>:
  bridge_work_queue_write_frame(incoming,leave_work(row))
def get_work_queue(row:WorkRow) -> WorkRow & C.Access<S.QueueView>:
  F.get(~S.Schema,~WorkRow,~WorkQueueRest,~WorkQueueMetaRest,~S.Queue,~S.QueueView,~take_work_queue,~put_work_queue,~header_work_queue,~put_header_work_queue,~S.project_queue,~bridge_work_queue_get,row)
def set_work_queue(row:WorkRow,incoming:S.Queue) -> WorkRow:
  F.write_owner(~WorkRow,~S.Queue,F.write(~S.Schema,~WorkRow,~WorkQueueRest,~WorkQueueMetaRest,~S.Queue,~take_work_queue,~put_work_queue,~header_work_queue,~put_header_work_queue,~journal_work_queue,~bridge_work_queue_write,row,incoming))
def read_work_queue() -> Cap.Read<WorkRow,S.QueueView>:
  Cap.Read{get_work_queue}
def write_work_queue() -> Cap.Write<WorkRow,S.Queue,S.QueueView>:
  Cap.Write{get_work_queue,set_work_queue}
def id_work_header(stock:R.Cell<S.Schema,S.Stock>,recipe:R.Cell<S.Schema,S.Recipe>,queue:R.Cell<S.Schema,S.Queue>,cold:WorkCold,header:F.Header<S.Schema>) -> WorkRow & U32:
  match header:
    case F.Header{namespace,nextId,live,W.Handle{ns,+key},clock,error,cursor}: (WorkRow{WorkState{F.Header{namespace,nextId,live,W.Handle{ns,key},clock,error,cursor},stock,recipe,queue,cold}},key)
def id_work(row:WorkRow) -> WorkRow & U32:
  match row:
    case WorkRow{WorkState{header,stock,recipe,queue,cold}}: id_work_header(stock,recipe,queue,cold,header)
    case WorkWrapped{inner}: id_work(inner)
def id_read_work() -> Cap.ValueRead<WorkRow,U32>:
  Cap.ValueRead{id_work}
def bridge_duplicate_stock_get_join(observed:Frame() & C.Access<S.StockView>) -> DuplicateRow & C.Access<S.StockView>:
  match observed:
    case (frame,value): (enter_duplicate(frame),value)
def bridge_duplicate_stock_get(row:DuplicateRow) -> DuplicateRow & C.Access<S.StockView>:
  bridge_duplicate_stock_get_join(Q.get(~S.Schema,~S.Store,~Unit,~Unit,~S.StockRest,~S.Stock,~S.StockView,~S.StockToken,~S.take_stock,~S.put_stock,~S.project_stock,~S.stock(),leave_duplicate(row)))
def journal_duplicate_stock_cold(+handle:W.Handle<S.Schema>,previous:Maybe<&1,S.Stock>,+stamp:L.Stamp,cold:DuplicateCold) -> DuplicateCold:
  match cold:
    case DuplicateCold{DuplicateColdState{highWater,capacity,depth,recipe,queue,enabled,locked,resource,events,pending,registrations,nextSystemId,undo,commands,txEvents}}: DuplicateCold{DuplicateColdState{highWater,capacity,depth,recipe,queue,enabled,locked,resource,events,pending,registrations,nextSystemId,(world => C.restore_stamp(~S.Schema,~S.Store,~Unit,~Unit,~S.StockRest,~S.Stock,~S.StockView,~S.StockToken,~S.take_stock,~S.put_stock,~S.project_stock,handle,stamp,C.restore(~S.Schema,~S.Store,~Unit,~Unit,~S.StockRest,~S.Stock,~S.StockView,~S.StockToken,~S.take_stock,~S.put_stock,~S.project_stock,S.stock(),handle,previous,world))) <> undo,commands,txEvents}}
    case DuplicateColdWrapped{inner}: journal_duplicate_stock_cold(handle,previous,stamp,inner)
def journal_duplicate_stock_header(cold:DuplicateCold,previous:Maybe<&1,S.Stock>,stamp:L.Stamp,header:F.Header<S.Schema>) -> DuplicateStockRest:
  match header:
    case F.Header{namespace,nextId,live,+handle,clock,error,cursor}: DuplicateStockRest{F.Header{namespace,nextId,live,handle,clock,error,cursor},journal_duplicate_stock_cold(handle,previous,stamp,cold)}
def journal_duplicate_stock(rest:DuplicateStockRest,previous:Maybe<&1,S.Stock>,stamp:L.Stamp) -> DuplicateStockRest:
  match rest:
    case DuplicateStockRest{header,cold}: journal_duplicate_stock_header(cold,previous,stamp,header)
def bridge_duplicate_stock_write_result(+handle:W.Handle<S.Schema>,error:Maybe<&2,W.WorldError>,cursor:U32,result:C.SetResult<T.Tx<S.World(),Unit>,S.Stock>) -> F.WriteResult<DuplicateRow,S.Stock>:
  match result:
    case C.Written{tx}: F.Written{enter_duplicate(Q.Frame{tx,handle,error,cursor})}
    case C.WriteRejected{tx,incoming,+reason}: F.Rejected{enter_duplicate(Q.Frame{tx,handle,Q.first_error(error,reason),cursor}),incoming,reason}
    case C.WriteFailure{tx,reason}: F.Written{enter_duplicate(Q.Frame{tx,handle,Q.first_error(error,reason),cursor})}
def bridge_duplicate_stock_write_frame(incoming:S.Stock,frame:Frame()) -> F.WriteResult<DuplicateRow,S.Stock>:
  match frame:
    case Q.Frame{tx,+handle,error,cursor}: bridge_duplicate_stock_write_result(handle,error,cursor,C.tx_set(~S.Schema,~S.Store,~Unit,~Unit,~S.StockRest,~S.Stock,~S.StockView,~S.StockToken,~S.take_stock,~S.put_stock,~S.project_stock,S.stock(),tx,handle,incoming))
def bridge_duplicate_stock_write(row:DuplicateRow,incoming:S.Stock) -> F.WriteResult<DuplicateRow,S.Stock>:
  bridge_duplicate_stock_write_frame(incoming,leave_duplicate(row))
def get_duplicate_stock(row:DuplicateRow) -> DuplicateRow & C.Access<S.StockView>:
  F.get(~S.Schema,~DuplicateRow,~DuplicateStockRest,~DuplicateStockMetaRest,~S.Stock,~S.StockView,~take_duplicate_stock,~put_duplicate_stock,~header_duplicate_stock,~put_header_duplicate_stock,~S.project_stock,~bridge_duplicate_stock_get,row)
def set_duplicate_stock(row:DuplicateRow,incoming:S.Stock) -> DuplicateRow:
  F.write_owner(~DuplicateRow,~S.Stock,F.write(~S.Schema,~DuplicateRow,~DuplicateStockRest,~DuplicateStockMetaRest,~S.Stock,~take_duplicate_stock,~put_duplicate_stock,~header_duplicate_stock,~put_header_duplicate_stock,~journal_duplicate_stock,~bridge_duplicate_stock_write,row,incoming))
def read_duplicate_stock() -> Cap.Read<DuplicateRow,S.StockView>:
  Cap.Read{get_duplicate_stock}
def write_duplicate_stock() -> Cap.Write<DuplicateRow,S.Stock,S.StockView>:
  Cap.Write{get_duplicate_stock,set_duplicate_stock}
def id_duplicate_header(stock:R.Cell<S.Schema,S.Stock>,cold:DuplicateCold,header:F.Header<S.Schema>) -> DuplicateRow & U32:
  match header:
    case F.Header{namespace,nextId,live,W.Handle{ns,+key},clock,error,cursor}: (DuplicateRow{DuplicateState{F.Header{namespace,nextId,live,W.Handle{ns,key},clock,error,cursor},stock,cold}},key)
def id_duplicate(row:DuplicateRow) -> DuplicateRow & U32:
  match row:
    case DuplicateRow{DuplicateState{header,stock,cold}}: id_duplicate_header(stock,cold,header)
    case DuplicateWrapped{inner}: id_duplicate(inner)
def id_read_duplicate() -> Cap.ValueRead<DuplicateRow,U32>:
  Cap.ValueRead{id_duplicate}
def bridge_advanced_stock_get_join(observed:Frame() & C.Access<S.StockView>) -> AdvancedRow & C.Access<S.StockView>:
  match observed:
    case (frame,value): (enter_advanced(frame),value)
def bridge_advanced_stock_get(row:AdvancedRow) -> AdvancedRow & C.Access<S.StockView>:
  bridge_advanced_stock_get_join(Q.get(~S.Schema,~S.Store,~Unit,~Unit,~S.StockRest,~S.Stock,~S.StockView,~S.StockToken,~S.take_stock,~S.put_stock,~S.project_stock,~S.stock(),leave_advanced(row)))
def journal_advanced_stock_cold(+handle:W.Handle<S.Schema>,previous:Maybe<&1,S.Stock>,+stamp:L.Stamp,cold:AdvancedCold) -> AdvancedCold:
  match cold:
    case AdvancedCold{AdvancedColdState{highWater,capacity,depth,recipe,enabled,locked,resource,events,pending,registrations,nextSystemId,undo,commands,txEvents}}: AdvancedCold{AdvancedColdState{highWater,capacity,depth,recipe,enabled,locked,resource,events,pending,registrations,nextSystemId,(world => C.restore_stamp(~S.Schema,~S.Store,~Unit,~Unit,~S.StockRest,~S.Stock,~S.StockView,~S.StockToken,~S.take_stock,~S.put_stock,~S.project_stock,handle,stamp,C.restore(~S.Schema,~S.Store,~Unit,~Unit,~S.StockRest,~S.Stock,~S.StockView,~S.StockToken,~S.take_stock,~S.put_stock,~S.project_stock,S.stock(),handle,previous,world))) <> undo,commands,txEvents}}
    case AdvancedColdWrapped{inner}: journal_advanced_stock_cold(handle,previous,stamp,inner)
def journal_advanced_stock_header(queue:R.Cell<S.Schema,S.Queue>,cold:AdvancedCold,previous:Maybe<&1,S.Stock>,stamp:L.Stamp,header:F.Header<S.Schema>) -> AdvancedStockRest:
  match header:
    case F.Header{namespace,nextId,live,+handle,clock,error,cursor}: AdvancedStockRest{F.Header{namespace,nextId,live,handle,clock,error,cursor},queue,journal_advanced_stock_cold(handle,previous,stamp,cold)}
def journal_advanced_stock(rest:AdvancedStockRest,previous:Maybe<&1,S.Stock>,stamp:L.Stamp) -> AdvancedStockRest:
  match rest:
    case AdvancedStockRest{header,queue,cold}: journal_advanced_stock_header(queue,cold,previous,stamp,header)
def bridge_advanced_stock_write_result(+handle:W.Handle<S.Schema>,error:Maybe<&2,W.WorldError>,cursor:U32,result:C.SetResult<T.Tx<S.World(),Unit>,S.Stock>) -> F.WriteResult<AdvancedRow,S.Stock>:
  match result:
    case C.Written{tx}: F.Written{enter_advanced(Q.Frame{tx,handle,error,cursor})}
    case C.WriteRejected{tx,incoming,+reason}: F.Rejected{enter_advanced(Q.Frame{tx,handle,Q.first_error(error,reason),cursor}),incoming,reason}
    case C.WriteFailure{tx,reason}: F.Written{enter_advanced(Q.Frame{tx,handle,Q.first_error(error,reason),cursor})}
def bridge_advanced_stock_write_frame(incoming:S.Stock,frame:Frame()) -> F.WriteResult<AdvancedRow,S.Stock>:
  match frame:
    case Q.Frame{tx,+handle,error,cursor}: bridge_advanced_stock_write_result(handle,error,cursor,C.tx_set(~S.Schema,~S.Store,~Unit,~Unit,~S.StockRest,~S.Stock,~S.StockView,~S.StockToken,~S.take_stock,~S.put_stock,~S.project_stock,S.stock(),tx,handle,incoming))
def bridge_advanced_stock_write(row:AdvancedRow,incoming:S.Stock) -> F.WriteResult<AdvancedRow,S.Stock>:
  bridge_advanced_stock_write_frame(incoming,leave_advanced(row))
def get_advanced_stock(row:AdvancedRow) -> AdvancedRow & C.Access<S.StockView>:
  F.get(~S.Schema,~AdvancedRow,~AdvancedStockRest,~AdvancedStockMetaRest,~S.Stock,~S.StockView,~take_advanced_stock,~put_advanced_stock,~header_advanced_stock,~put_header_advanced_stock,~S.project_stock,~bridge_advanced_stock_get,row)
def set_advanced_stock(row:AdvancedRow,incoming:S.Stock) -> AdvancedRow:
  F.write_owner(~AdvancedRow,~S.Stock,F.write(~S.Schema,~AdvancedRow,~AdvancedStockRest,~AdvancedStockMetaRest,~S.Stock,~take_advanced_stock,~put_advanced_stock,~header_advanced_stock,~put_header_advanced_stock,~journal_advanced_stock,~bridge_advanced_stock_write,row,incoming))
def read_advanced_stock() -> Cap.Read<AdvancedRow,S.StockView>:
  Cap.Read{get_advanced_stock}
def write_advanced_stock() -> Cap.Write<AdvancedRow,S.Stock,S.StockView>:
  Cap.Write{get_advanced_stock,set_advanced_stock}
def bridge_advanced_queue_get_join(observed:Frame() & C.Access<S.QueueView>) -> AdvancedRow & C.Access<S.QueueView>:
  match observed:
    case (frame,value): (enter_advanced(frame),value)
def bridge_advanced_queue_get(row:AdvancedRow) -> AdvancedRow & C.Access<S.QueueView>:
  bridge_advanced_queue_get_join(Q.get(~S.Schema,~S.Store,~Unit,~Unit,~S.QueueRest,~S.Queue,~S.QueueView,~S.QueueToken,~S.take_queue,~S.put_queue,~S.project_queue,~S.queue(),leave_advanced(row)))
def journal_advanced_queue_cold(+handle:W.Handle<S.Schema>,previous:Maybe<&1,S.Queue>,+stamp:L.Stamp,cold:AdvancedCold) -> AdvancedCold:
  match cold:
    case AdvancedCold{AdvancedColdState{highWater,capacity,depth,recipe,enabled,locked,resource,events,pending,registrations,nextSystemId,undo,commands,txEvents}}: AdvancedCold{AdvancedColdState{highWater,capacity,depth,recipe,enabled,locked,resource,events,pending,registrations,nextSystemId,(world => C.restore_stamp(~S.Schema,~S.Store,~Unit,~Unit,~S.QueueRest,~S.Queue,~S.QueueView,~S.QueueToken,~S.take_queue,~S.put_queue,~S.project_queue,handle,stamp,C.restore(~S.Schema,~S.Store,~Unit,~Unit,~S.QueueRest,~S.Queue,~S.QueueView,~S.QueueToken,~S.take_queue,~S.put_queue,~S.project_queue,S.queue(),handle,previous,world))) <> undo,commands,txEvents}}
    case AdvancedColdWrapped{inner}: journal_advanced_queue_cold(handle,previous,stamp,inner)
def journal_advanced_queue_header(stock:R.Cell<S.Schema,S.Stock>,cold:AdvancedCold,previous:Maybe<&1,S.Queue>,stamp:L.Stamp,header:F.Header<S.Schema>) -> AdvancedQueueRest:
  match header:
    case F.Header{namespace,nextId,live,+handle,clock,error,cursor}: AdvancedQueueRest{F.Header{namespace,nextId,live,handle,clock,error,cursor},stock,journal_advanced_queue_cold(handle,previous,stamp,cold)}
def journal_advanced_queue(rest:AdvancedQueueRest,previous:Maybe<&1,S.Queue>,stamp:L.Stamp) -> AdvancedQueueRest:
  match rest:
    case AdvancedQueueRest{header,stock,cold}: journal_advanced_queue_header(stock,cold,previous,stamp,header)
def bridge_advanced_queue_write_result(+handle:W.Handle<S.Schema>,error:Maybe<&2,W.WorldError>,cursor:U32,result:C.SetResult<T.Tx<S.World(),Unit>,S.Queue>) -> F.WriteResult<AdvancedRow,S.Queue>:
  match result:
    case C.Written{tx}: F.Written{enter_advanced(Q.Frame{tx,handle,error,cursor})}
    case C.WriteRejected{tx,incoming,+reason}: F.Rejected{enter_advanced(Q.Frame{tx,handle,Q.first_error(error,reason),cursor}),incoming,reason}
    case C.WriteFailure{tx,reason}: F.Written{enter_advanced(Q.Frame{tx,handle,Q.first_error(error,reason),cursor})}
def bridge_advanced_queue_write_frame(incoming:S.Queue,frame:Frame()) -> F.WriteResult<AdvancedRow,S.Queue>:
  match frame:
    case Q.Frame{tx,+handle,error,cursor}: bridge_advanced_queue_write_result(handle,error,cursor,C.tx_set(~S.Schema,~S.Store,~Unit,~Unit,~S.QueueRest,~S.Queue,~S.QueueView,~S.QueueToken,~S.take_queue,~S.put_queue,~S.project_queue,S.queue(),tx,handle,incoming))
def bridge_advanced_queue_write(row:AdvancedRow,incoming:S.Queue) -> F.WriteResult<AdvancedRow,S.Queue>:
  bridge_advanced_queue_write_frame(incoming,leave_advanced(row))
def get_advanced_queue(row:AdvancedRow) -> AdvancedRow & C.Access<S.QueueView>:
  F.get(~S.Schema,~AdvancedRow,~AdvancedQueueRest,~AdvancedQueueMetaRest,~S.Queue,~S.QueueView,~take_advanced_queue,~put_advanced_queue,~header_advanced_queue,~put_header_advanced_queue,~S.project_queue,~bridge_advanced_queue_get,row)
def set_advanced_queue(row:AdvancedRow,incoming:S.Queue) -> AdvancedRow:
  F.write_owner(~AdvancedRow,~S.Queue,F.write(~S.Schema,~AdvancedRow,~AdvancedQueueRest,~AdvancedQueueMetaRest,~S.Queue,~take_advanced_queue,~put_advanced_queue,~header_advanced_queue,~put_header_advanced_queue,~journal_advanced_queue,~bridge_advanced_queue_write,row,incoming))
def read_advanced_queue() -> Cap.Read<AdvancedRow,S.QueueView>:
  Cap.Read{get_advanced_queue}
def write_advanced_queue() -> Cap.Write<AdvancedRow,S.Queue,S.QueueView>:
  Cap.Write{get_advanced_queue,set_advanced_queue}
def id_advanced_header(stock:R.Cell<S.Schema,S.Stock>,queue:R.Cell<S.Schema,S.Queue>,cold:AdvancedCold,header:F.Header<S.Schema>) -> AdvancedRow & U32:
  match header:
    case F.Header{namespace,nextId,live,W.Handle{ns,+key},clock,error,cursor}: (AdvancedRow{AdvancedState{F.Header{namespace,nextId,live,W.Handle{ns,key},clock,error,cursor},stock,queue,cold}},key)
def id_advanced(row:AdvancedRow) -> AdvancedRow & U32:
  match row:
    case AdvancedRow{AdvancedState{header,stock,queue,cold}}: id_advanced_header(stock,queue,cold,header)
    case AdvancedWrapped{inner}: id_advanced(inner)
def id_read_advanced() -> Cap.ValueRead<AdvancedRow,U32>:
  Cap.ValueRead{id_advanced}
def id_empty_header(cold:EmptyCold,header:F.Header<S.Schema>) -> EmptyRow & U32:
  match header:
    case F.Header{namespace,nextId,live,W.Handle{ns,+key},clock,error,cursor}: (EmptyRow{EmptyState{F.Header{namespace,nextId,live,W.Handle{ns,key},clock,error,cursor},cold}},key)
def id_empty(row:EmptyRow) -> EmptyRow & U32:
  match row:
    case EmptyRow{EmptyState{header,cold}}: id_empty_header(cold,header)
    case EmptyWrapped{inner}: id_empty(inner)
def id_read_empty() -> Cap.ValueRead<EmptyRow,U32>:
  Cap.ValueRead{id_empty}
