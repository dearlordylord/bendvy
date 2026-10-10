import Base
import restored-row.bend as R
import lifecycle.bend as L
import world.bend as W
import component.bend as C
import compose.bend as Q

type Header<-S:Data> is Type:
  Header{namespace:U32,nextId:U32,live:Array<Bool>,handle:W.Handle<S>,clock:U32,error:Maybe<&2,W.WorldError>,cursor:U32}
type WriteResult<-H:Type,-C:Type> is Type:
  Written{owner:H}
  Rejected{owner:H,incoming:C,error:W.WorldError}
def checked_live(-S:Data,+namespace:U32,+nextId:U32,+handle:W.Handle<S>,+clock:U32,+error:Maybe<&2,W.WorldError>,+cursor:U32,observed:Array<Bool> & Bool) -> Header<S> & Bool:
  match observed:
    case (live,valid): (Header{namespace,nextId,live,handle,clock,error,cursor},valid)
def checked_metadata(-S:Data,valid:Bool,live:Array<Bool>,+id:U32,+namespace:U32,+nextId:U32,+handle:W.Handle<S>,+clock:U32,+error:Maybe<&2,W.WorldError>,+cursor:U32) -> Header<S> & Bool:
  match valid:
    case False{}: (Header{namespace,nextId,live,handle,clock,error,cursor},False{})
    case True{}: checked_live(S,namespace,nextId,handle,clock,error,cursor,Array.get(Bool,live,id))
def checked(-S:Data,header:Header<S>) -> Header<S> & Bool:
  match header:
    case Header{+namespace,+nextId,live,W.Handle{+ns,+id},+clock,+error,+cursor}: checked_metadata(S,Bool.and(U32.is_eq(namespace,ns),Bool.and(U32.is_lt(0,id),U32.is_lt(id,nextId))),live,id,namespace,nextId,W.Handle{ns,id},clock,error,cursor)
def target(-S:Data,header:Header<S>) -> Header<S> & U32:
  match header:
    case Header{namespace,nextId,live,W.Handle{ns,+id},clock,error,cursor}: (Header{namespace,nextId,live,W.Handle{ns,id},clock,error,cursor},id)

def projected(~S:Data,~H:Type,~Rest:Type,~C:Type,~V:Data,~put:Rest -> R.Cell<S,C> -> H,~bridge:H -> H & C.Access<V>,rest:Rest,result:R.Projected<S,C,V>) -> H & C.Access<V>:
  match result:
    case R.Projected{cell,None{}}: (put(rest,cell),C.ComponentAbsent{})
    case R.Projected{cell,Some{value}}: (put(rest,cell),C.Found{value})
    case R.Deferred{cell}: bridge(put(rest,cell))
def get_ready(~S:Data,~H:Type,~Rest:Type,~C:Type,~V:Data,~put:Rest -> R.Cell<S,C> -> H,~project:C -> C & V,~bridge:H -> H & C.Access<V>,rest:Rest,cell:R.Cell<S,C>,same:Bool) -> H & C.Access<V>:
  match same:
    case False{}: bridge(put(rest,cell))
    case True{}: projected(~S,~H,~Rest,~C,~V,~put,~bridge,rest,R.project(~S,~C,~V,~project,cell))
def cell_matches(~S:Data,~C:Type,cell:R.Cell<S,C>,+id:U32) -> R.Cell<S,C> & Bool:
  match cell:
    case R.Taken{+captured,owner,stamp,dirty,cold}: (R.Taken{captured,owner,stamp,dirty,cold},U32.is_eq(captured,id))
    case other: (other,False{})
def get_matching(~S:Data,~H:Type,~Rest:Type,~C:Type,~V:Data,~put:Rest -> R.Cell<S,C> -> H,~project:C -> C & V,~bridge:H -> H & C.Access<V>,rest:Rest,observed:R.Cell<S,C> & Bool) -> H & C.Access<V>:
  match observed:
    case (cell,same): get_ready(~S,~H,~Rest,~C,~V,~put,~project,~bridge,rest,cell,same)
def get_targeted(~S:Data,~H:Type,~Rest:Type,~MetaRest:Type,~C:Type,~V:Data,~put:Rest -> R.Cell<S,C> -> H,~put_header:MetaRest -> Header<S> -> Rest,~project:C -> C & V,~bridge:H -> H & C.Access<V>,rest:MetaRest,cell:R.Cell<S,C>,observed:Header<S> & U32) -> H & C.Access<V>:
  match observed:
    case (header,id): get_matching(~S,~H,~Rest,~C,~V,~put,~project,~bridge,put_header(rest,header),cell_matches(~S,~C,cell,id))
def get_checked(~S:Data,~H:Type,~Rest:Type,~MetaRest:Type,~C:Type,~V:Data,~put:Rest -> R.Cell<S,C> -> H,~put_header:MetaRest -> Header<S> -> Rest,~project:C -> C & V,~bridge:H -> H & C.Access<V>,rest:MetaRest,cell:R.Cell<S,C>,observed:Header<S> & Bool) -> H & C.Access<V>:
  match observed:
    case (header,False{}): (put(put_header(rest,header),cell),C.MissingEntity{})
    case (header,True{}): get_targeted(~S,~H,~Rest,~MetaRest,~C,~V,~put,~put_header,~project,~bridge,rest,cell,target(S,header))
def get_split(~S:Data,~H:Type,~Rest:Type,~MetaRest:Type,~C:Type,~V:Data,~put:Rest -> R.Cell<S,C> -> H,~header:Rest -> MetaRest & Header<S>,~put_header:MetaRest -> Header<S> -> Rest,~project:C -> C & V,~bridge:H -> H & C.Access<V>,cell:R.Cell<S,C>,observed:MetaRest & Header<S>) -> H & C.Access<V>:
  match observed:
    case (rest,meta): get_checked(~S,~H,~Rest,~MetaRest,~C,~V,~put,~put_header,~project,~bridge,rest,cell,checked(S,meta))
def get_taken(~S:Data,~H:Type,~Rest:Type,~MetaRest:Type,~C:Type,~V:Data,~put:Rest -> R.Cell<S,C> -> H,~header:Rest -> MetaRest & Header<S>,~put_header:MetaRest -> Header<S> -> Rest,~project:C -> C & V,~bridge:H -> H & C.Access<V>,observed:Rest & R.Cell<S,C>) -> H & C.Access<V>:
  match observed:
    case (rest,cell): get_split(~S,~H,~Rest,~MetaRest,~C,~V,~put,~header,~put_header,~project,~bridge,cell,header(rest))
def get(~S:Data,~H:Type,~Rest:Type,~MetaRest:Type,~C:Type,~V:Data,~take:H -> Rest & R.Cell<S,C>,~put:Rest -> R.Cell<S,C> -> H,~header:Rest -> MetaRest & Header<S>,~put_header:MetaRest -> Header<S> -> Rest,~project:C -> C & V,~bridge:H -> H & C.Access<V>,owner:H) -> H & C.Access<V>:
  get_taken(~S,~H,~Rest,~MetaRest,~C,~V,~put,~header,~put_header,~project,~bridge,take(owner))

def reject_header(-S:Data,reason:W.WorldError,header:Header<S>) -> Header<S>:
  match header:
    case Header{namespace,nextId,live,handle,clock,error,cursor}: Header{namespace,nextId,live,handle,clock,Q.first_error(error,reason),cursor}
def clock_checked(-S:Data,allowed:Bool,+namespace:U32,+nextId:U32,live:Array<Bool>,+handle:W.Handle<S>,+clock:U32,+error:Maybe<&2,W.WorldError>,+cursor:U32) -> Header<S> & Maybe<&2,U32>:
  match allowed:
    case False{}: (Header{namespace,nextId,live,handle,clock,error,cursor},None{})
    case True{}: (Header{namespace,nextId,live,handle,U32.add(clock,1),error,cursor},Some{U32.add(clock,1)})
def clocked(-S:Data,header:Header<S>) -> Header<S> & Maybe<&2,U32>:
  match header:
    case Header{+namespace,+nextId,live,+handle,+clock,+error,+cursor}: clock_checked(S,U32.is_lt(clock,4294967295),namespace,nextId,live,handle,clock,error,cursor)
def rejected(~S:Data,~H:Type,~Rest:Type,~MetaRest:Type,~C:Type,~put:Rest -> R.Cell<S,C> -> H,~put_header:MetaRest -> Header<S> -> Rest,rest:MetaRest,cell:R.Cell<S,C>,incoming:C,+reason:W.WorldError,header:Header<S>) -> WriteResult<H,C>:
  Rejected{put(put_header(rest,reject_header(S,reason,header)),cell),incoming,reason}
def replace_refused(~S:Data,~H:Type,~Rest:Type,~MetaRest:Type,~C:Type,~put:Rest -> R.Cell<S,C> -> H,~put_header:MetaRest -> Header<S> -> Rest,cell:R.Cell<S,C>,incoming:C,observed:MetaRest & Header<S>) -> WriteResult<H,C>:
  match observed:
    case (rest,header): rejected(~S,~H,~Rest,~MetaRest,~C,~put,~put_header,rest,cell,incoming,W.CapacityExceeded{},header)
def replaced(~S:Data,~H:Type,~Rest:Type,~MetaRest:Type,~C:Type,~put:Rest -> R.Cell<S,C> -> H,~header:Rest -> MetaRest & Header<S>,~put_header:MetaRest -> Header<S> -> Rest,~journal:Rest -> Maybe<&1,C> -> L.Stamp -> Rest,rest:Rest,result:R.Replacement<S,C>) -> WriteResult<H,C>:
  match result:
    case R.Replaced{cell,previous,stamp}: Written{put(journal(rest,previous,stamp),cell)}
    case R.Refused{cell,incoming}: replace_refused(~S,~H,~Rest,~MetaRest,~C,~put,~put_header,cell,incoming,header(rest))
def write_clocked(~S:Data,~H:Type,~Rest:Type,~MetaRest:Type,~C:Type,~put:Rest -> R.Cell<S,C> -> H,~header:Rest -> MetaRest & Header<S>,~put_header:MetaRest -> Header<S> -> Rest,~journal:Rest -> Maybe<&1,C> -> L.Stamp -> Rest,rest:MetaRest,cell:R.Cell<S,C>,incoming:C,observed:Header<S> & Maybe<&2,U32>) -> WriteResult<H,C>:
  match observed:
    case (meta,None{}): rejected(~S,~H,~Rest,~MetaRest,~C,~put,~put_header,rest,cell,incoming,W.CapacityExceeded{},meta)
    case (meta,Some{tick}): replaced(~S,~H,~Rest,~MetaRest,~C,~put,~header,~put_header,~journal,put_header(rest,meta),R.replace(~S,~C,cell,incoming,tick))
def write_matching(~S:Data,~H:Type,~Rest:Type,~MetaRest:Type,~C:Type,~put:Rest -> R.Cell<S,C> -> H,~header:Rest -> MetaRest & Header<S>,~put_header:MetaRest -> Header<S> -> Rest,~journal:Rest -> Maybe<&1,C> -> L.Stamp -> Rest,~bridge:H -> C -> WriteResult<H,C>,rest:MetaRest,meta:Header<S>,incoming:C,observed:R.Cell<S,C> & Bool) -> WriteResult<H,C>:
  match observed:
    case (cell,False{}): bridge(put(put_header(rest,meta),cell),incoming)
    case (cell,True{}): write_clocked(~S,~H,~Rest,~MetaRest,~C,~put,~header,~put_header,~journal,rest,cell,incoming,clocked(S,meta))
def write_targeted(~S:Data,~H:Type,~Rest:Type,~MetaRest:Type,~C:Type,~put:Rest -> R.Cell<S,C> -> H,~header:Rest -> MetaRest & Header<S>,~put_header:MetaRest -> Header<S> -> Rest,~journal:Rest -> Maybe<&1,C> -> L.Stamp -> Rest,~bridge:H -> C -> WriteResult<H,C>,rest:MetaRest,cell:R.Cell<S,C>,incoming:C,observed:Header<S> & U32) -> WriteResult<H,C>:
  match observed:
    case (meta,id): write_matching(~S,~H,~Rest,~MetaRest,~C,~put,~header,~put_header,~journal,~bridge,rest,meta,incoming,cell_matches(~S,~C,cell,id))
def write_checked(~S:Data,~H:Type,~Rest:Type,~MetaRest:Type,~C:Type,~put:Rest -> R.Cell<S,C> -> H,~header:Rest -> MetaRest & Header<S>,~put_header:MetaRest -> Header<S> -> Rest,~journal:Rest -> Maybe<&1,C> -> L.Stamp -> Rest,~bridge:H -> C -> WriteResult<H,C>,rest:MetaRest,cell:R.Cell<S,C>,incoming:C,observed:Header<S> & Bool) -> WriteResult<H,C>:
  match observed:
    case (meta,False{}): rejected(~S,~H,~Rest,~MetaRest,~C,~put,~put_header,rest,cell,incoming,W.MissingEntity{},meta)
    case (meta,True{}): write_targeted(~S,~H,~Rest,~MetaRest,~C,~put,~header,~put_header,~journal,~bridge,rest,cell,incoming,target(S,meta))
def write_split(~S:Data,~H:Type,~Rest:Type,~MetaRest:Type,~C:Type,~put:Rest -> R.Cell<S,C> -> H,~header:Rest -> MetaRest & Header<S>,~put_header:MetaRest -> Header<S> -> Rest,~journal:Rest -> Maybe<&1,C> -> L.Stamp -> Rest,~bridge:H -> C -> WriteResult<H,C>,cell:R.Cell<S,C>,incoming:C,observed:MetaRest & Header<S>) -> WriteResult<H,C>:
  match observed:
    case (rest,meta): write_checked(~S,~H,~Rest,~MetaRest,~C,~put,~header,~put_header,~journal,~bridge,rest,cell,incoming,checked(S,meta))
def write_taken(~S:Data,~H:Type,~Rest:Type,~MetaRest:Type,~C:Type,~put:Rest -> R.Cell<S,C> -> H,~header:Rest -> MetaRest & Header<S>,~put_header:MetaRest -> Header<S> -> Rest,~journal:Rest -> Maybe<&1,C> -> L.Stamp -> Rest,~bridge:H -> C -> WriteResult<H,C>,incoming:C,observed:Rest & R.Cell<S,C>) -> WriteResult<H,C>:
  match observed:
    case (rest,cell): write_split(~S,~H,~Rest,~MetaRest,~C,~put,~header,~put_header,~journal,~bridge,cell,incoming,header(rest))
def write(~S:Data,~H:Type,~Rest:Type,~MetaRest:Type,~C:Type,~take:H -> Rest & R.Cell<S,C>,~put:Rest -> R.Cell<S,C> -> H,~header:Rest -> MetaRest & Header<S>,~put_header:MetaRest -> Header<S> -> Rest,~journal:Rest -> Maybe<&1,C> -> L.Stamp -> Rest,~bridge:H -> C -> WriteResult<H,C>,owner:H,incoming:C) -> WriteResult<H,C>:
  write_taken(~S,~H,~Rest,~MetaRest,~C,~put,~header,~put_header,~journal,~bridge,incoming,take(owner))
# The public capability setter consumes refused incoming exactly like Q.written.
def write_owner(~H:Type,~C:Type,result:WriteResult<H,C>) -> H:
  match result:
    case Written{owner}: owner
    case Rejected{owner,_,_}: owner
