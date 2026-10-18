import Base
import capabilities.bend as Cap
import owned-event-scope.bend as Scope
# Sequential identities belong to the log; payloads are never copied.
type Row<P:Type> is Type:Row{id:Nat,payload:P}
type Log<P:Type> is Type:Log{next:Nat,rows:List<Row<P>>}
type ReadResult<Args:Type,Observation:Type> is Type:
  Found{observation:Observation}
  Missing{args:Args}
def empty(~P:Type) -> Log<P>:Log{1n,[]}
def append(~P:Type,log:Log<P>,payload:P) -> Log<P> & Nat:
  match log:
    case Log{+next,rows}:(Log{1n+next,List.append(&1,Row<P>,rows,[Row{next,payload}])},next)
def appended_many(~P:Type,id:Nat,result:Log<P> & List<&2,Nat>) -> Log<P> & List<&2,Nat>:
  match result:
    case (log,ids):(log,id <> ids)
def append_remaining(~P:Type,next:Log<P> -> Log<P> & List<&2,Nat>,result:Log<P> & Nat) -> Log<P> & List<&2,Nat>:
  match result:
    case (log,id):appended_many(~P,id,next(log))
def append_rows(~P:Type,payloads:List<P>,log:Log<P>) -> Log<P> & List<&2,Nat>:
  match payloads:
    case []:(log,[])
    case payload <> rest:append_remaining(~P,next => append_rows(~P,rest,next),append(~P,log,payload))
def append_many(~P:Type,log:Log<P>,payloads:List<P>) -> Log<P> & List<&2,Nat>:
  append_rows(~P,payloads,log)
def contains(+ids:List<&2,Nat>,+id:Nat) -> Bool:
  match ids:
    case []:False{}
    case head <> rest:Bool.or(Nat.is_eq(head,id),contains(rest,id))
def partitioned(~P:Type,keep:Bool,row:Row<P>,result:List<Row<P>> & List<Row<P>>) -> List<Row<P>> & List<Row<P>>:
  match keep result:
    case True{}, (retained,retired):(row <> retained,retired)
    case False{}, (retained,retired):(retained,row <> retired)
def partition(~P:Type,rows:List<Row<P>>,+ids:List<&2,Nat>) -> List<Row<P>> & List<Row<P>>:
  match rows:
    case []:([],[])
    case Row{+id,payload} <> rest:partitioned(~P,contains(ids,id),Row{id,payload},partition(~P,rest,ids))
def retired(~P:Type,next:Nat,result:List<Row<P>> & List<Row<P>>) -> Log<P> & List<Row<P>>:
  match result:
    case (retained,removed):(Log{next,retained},removed)
def retire(~P:Type,log:Log<P>,ids:List<&2,Nat>) -> Log<P> & List<Row<P>>:
  match log:
    case Log{next,rows}:retired(~P,next,partition(~P,rows,ids))
def retain(~P:Type,log:Log<P>,ids:List<&2,Nat>) -> Log<P> & List<Row<P>>:
  retire(~P,log,ids)
def drain(~P:Type,log:Log<P>) -> Log<P> & List<Row<P>>:
  match log:
    case Log{next,rows}:(Log{next,[]},rows)
def read_returned(~P:Type,~Args:Type,~Observation:Type,id:Nat,tail:List<Row<P>>,observed:P & Observation) -> List<Row<P>> & ReadResult<Args,Observation>:
  match observed:
    case (payload,value):(Row{id,payload} <> tail,Found{value})
def read_rebuilt(~P:Type,~Args:Type,~Observation:Type,row:Row<P>,result:List<Row<P>> & ReadResult<Args,Observation>) -> List<Row<P>> & ReadResult<Args,Observation>:
  match result:
    case (tail,result):(row <> tail,result)
def read_selected(~P:Type,~Request:Type,~Projection:Data,~Args:Type,~Observation:Type,~at:P -> Request -> P & Projection,~body:@-H:Type -> @-read:Cap.Request<H,Request,Projection> -> H -> Args -> H & Observation,next:List<Row<P>> -> Args -> List<Row<P>> & ReadResult<Args,Observation>,selected:Bool,id:Nat,payload:P,tail:List<Row<P>>,args:Args) -> List<Row<P>> & ReadResult<Args,Observation>:
  match selected:
    case True{}:read_returned(~P,~Args,~Observation,id,tail,Scope.provide(~P,~Request,~Projection,~Args,~Observation,~at,~body,payload,args))
    case False{}:read_rebuilt(~P,~Args,~Observation,Row{id,payload},next(tail,args))
def read_rows(~P:Type,~Request:Type,~Projection:Data,~Args:Type,~Observation:Type,~at:P -> Request -> P & Projection,~body:@-H:Type -> @-read:Cap.Request<H,Request,Projection> -> H -> Args -> H & Observation,fuel:Nat,rows:List<Row<P>>,+wanted:Nat,args:Args) -> List<Row<P>> & ReadResult<Args,Observation>:
  match fuel rows:
    case _, []:([],Missing{args})
    case 0n, rows:(rows,Missing{args})
    case 1n+fuel, Row{+id,payload} <> tail:read_selected(~P,~Request,~Projection,~Args,~Observation,~at,~body,rows => args => read_rows(~P,~Request,~Projection,~Args,~Observation,~at,~body,fuel,rows,wanted,args),Nat.is_eq(id,wanted),id,payload,tail,args)
def counted_row(~P:Type,row:Row<P>,result:List<Row<P>> & Nat) -> List<Row<P>> & Nat:
  match result:
    case (rows,count):(row <> rows,1n+count)
def count_rows(~P:Type,rows:List<Row<P>>) -> List<Row<P>> & Nat:
  match rows:
    case []:([],0n)
    case row <> rest:counted_row(~P,row,count_rows(~P,rest))
def read_finished(~P:Type,~Args:Type,~Observation:Type,next:Nat,result:List<Row<P>> & ReadResult<Args,Observation>) -> Log<P> & ReadResult<Args,Observation>:
  match result:
    case (rows,result):(Log{next,rows},result)
def read_counted(~P:Type,~Request:Type,~Projection:Data,~Args:Type,~Observation:Type,~at:P -> Request -> P & Projection,~body:@-H:Type -> @-read:Cap.Request<H,Request,Projection> -> H -> Args -> H & Observation,next:Nat,id:Nat,args:Args,counted:List<Row<P>> & Nat) -> Log<P> & ReadResult<Args,Observation>:
  match counted:
    case (rows,count):read_finished(~P,~Args,~Observation,next,read_rows(~P,~Request,~Projection,~Args,~Observation,~at,~body,count,rows,id,args))
def read(~P:Type,~Request:Type,~Projection:Data,~Args:Type,~Observation:Type,~at:P -> Request -> P & Projection,~body:@-H:Type -> @-read:Cap.Request<H,Request,Projection> -> H -> Args -> H & Observation,log:Log<P>,id:Nat,args:Args) -> Log<P> & ReadResult<Args,Observation>:
  match log:
    case Log{next,rows}:read_counted(~P,~Request,~Projection,~Args,~Observation,~at,~body,next,id,args,count_rows(~P,rows))
