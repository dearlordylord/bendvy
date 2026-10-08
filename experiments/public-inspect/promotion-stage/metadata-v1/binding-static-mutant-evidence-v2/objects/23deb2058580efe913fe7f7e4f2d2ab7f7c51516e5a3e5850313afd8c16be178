import Base
import inspect.bend as I
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/component.bend as C
import ../../../src/ecs/column.bend as Col
import ../../../src/ecs/capabilities.bend as Cap

type Row<S:Data,V:Data> is Data:
  Row{entity:W.Handle<S>,value:I.Value<V>}
type Selection is Data:
  Required{}
  Optional{}
  Added{}
  Changed{}

def present(~V:Data,value:C.Access<V>) -> Bool:
  match value:
    case C.Found{_}:True{}
    case _:False{}
def accepts(~V:Data,selection:Selection,value:I.Value<V>) -> Bool:
  match selection value:
    case Optional{} _:True{}
    case Required{} I.Value{access,_,_}:present(~V,access)
    case Added{} I.Value{access,added,_}:Bool.and(present(~V,access),added)
    case Changed{} I.Value{access,_,changed}:Bool.and(present(~V,access),changed)
def included(~S:Data,~V:Data,include:Bool,row:Row<S,V>,rows:List<&2,Row<S,V>>) -> List<&2,Row<S,V>>:
  match include:
    case True{}:row <> rows
    case False{}:rows

def read_row(~S:Data,~Store:Type,~R:Type,~E:Data,~V:Data,~selection:Selection,target:W.Handle<S>,rows:List<&2,Row<S,V>>,continue:I.Frame<S,Store,R,E> -> List<&2,Row<S,V>> -> I.Frame<S,Store,R,E> & List<&2,Row<S,V>>,observed:I.Frame<S,Store,R,E> & I.Value<V>) -> I.Frame<S,Store,R,E> & List<&2,Row<S,V>>:
  (frame,+value)=observed
  continue(frame,included(~S,~V,accepts(~V,selection,value),Row{target,value},rows))

def read_rows(~S:Data,~Store:Type,~R:Type,~E:Data,~Rest:Type,~C:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,C>,~put:Rest -> Col.Column<S,C> -> Store,~project:C -> C & V,~family:C.Family<S,Store,Rest,C,V,Token,take,put,project>,~selection:Selection,handles:List<&2,W.Handle<S>>,frame:I.Frame<S,Store,R,E>,rows:List<&2,Row<S,V>>) -> I.Frame<S,Store,R,E> & List<&2,Row<S,V>>:
  match handles:
    case []:(frame,List.reverse(&2,Row<S,V>,rows))
    case +target <> rest:read_row(~S,~Store,~R,~E,~V,~selection,target,rows,(frame => rows => read_rows(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,~family,~selection,rest,frame,rows)),I.family_get(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,~family,frame,target))

def scanned(~S:Data,~Store:Type,~R:Type,~E:Data,~Rest:Type,~C:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,C>,~put:Rest -> Col.Column<S,C> -> Store,~project:C -> C & V,~family:C.Family<S,Store,Rest,C,V,Token,take,put,project>,~selection:Selection,cursor:U32,observed:W.World<S,Store,R,E> & List<&2,W.Handle<S>>) -> I.Frame<S,Store,R,E> & List<&2,Row<S,V>>:
  (world,handles)=observed
  read_rows(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,~family,~selection,handles,I.Frame{world,cursor},[])
def scan(~S:Data,~Store:Type,~R:Type,~E:Data,~Rest:Type,~C:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,C>,~put:Rest -> Col.Column<S,C> -> Store,~project:C -> C & V,~family:C.Family<S,Store,Rest,C,V,Token,take,put,project>,~selection:Selection,frame:I.Frame<S,Store,R,E>) -> I.Frame<S,Store,R,E> & List<&2,Row<S,V>>:
  match frame:
    case I.Frame{world,cursor}:scanned(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,~family,~selection,cursor,W.handles(~S,~Store,~R,~E,world))
def read_query(~S:Data,~Store:Type,~R:Type,~E:Data,~Rest:Type,~C:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,C>,~put:Rest -> Col.Column<S,C> -> Store,~project:C -> C & V,~family:C.Family<S,Store,Rest,C,V,Token,take,put,project>,~selection:Selection) -> Cap.ValueRead<I.Frame<S,Store,R,E>,List<&2,Row<S,V>>>:
  Cap.ValueRead{frame => scan(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,~family,~selection,frame)}
