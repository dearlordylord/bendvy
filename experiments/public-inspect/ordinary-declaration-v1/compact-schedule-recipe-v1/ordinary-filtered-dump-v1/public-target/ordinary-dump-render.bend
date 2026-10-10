import Base
import ./world.bend as W
import ./schema-fragments.bend as Fragment
import ./ordinary-dump-filter.bend as Filter
# Selected handles only reach this stage. Entries remain the sole schema key list.
def components(~S:Data,pairs:List<&1,Fragment.Entry<S> & Maybe<&2,String>>) -> List<&2,Filter.Value>:
  match pairs:
    case []:[]
    case (Fragment.Entry{Fragment.Component{},key,_},Some{text}) <> rest:Filter.Value{key,text} <> components(~S,rest)
    case _ <> rest:components(~S,rest)
def resources(~S:Data,pairs:List<&1,Fragment.Entry<S> & Maybe<&2,String>>) -> List<&2,Filter.Value>:
  match pairs:
    case []:[]
    case (Fragment.Entry{Fragment.Resource{},key,_},Some{text}) <> rest:Filter.Value{key,text} <> resources(~S,rest)
    case _ <> rest:resources(~S,rest)
def finished(~S:Data,~C:Type,row:Filter.Row<S>,result:C & List<&2,Filter.Row<S>>) -> C & List<&2,Filter.Row<S>>:
  match result:
    case (store,rows):(store,row <> rows)
def rendered(~S:Data,~C:Type,entries:List<&2,Fragment.Entry<S>>,handle:W.Handle<S>,rest:C -> C & List<&2,Filter.Row<S>>,result:C & List<&2,Maybe<&2,String>>) -> C & List<&2,Filter.Row<S>>:
  match result:
    case (store,slots):finished(~S,~C,Filter.Row{handle,components(~S,List.zip(&2,Fragment.Entry<S>,&2,Maybe<&2,String>,entries,slots))},rest(store))
def rows(~S:Data,~C:Type,~read:C -> U32 -> C & List<&2,Maybe<&2,String>>,handles:List<&2,W.Handle<S>>,+entries:List<&2,Fragment.Entry<S>>,store:C) -> C & List<&2,Filter.Row<S>>:
  match handles:
    case []:(store,[])
    case W.Handle{+namespace,+id} <> rest:rendered(~S,~C,entries,W.Handle{namespace,id},next => rows(~S,~C,~read,rest,entries,next),read(store,id))
