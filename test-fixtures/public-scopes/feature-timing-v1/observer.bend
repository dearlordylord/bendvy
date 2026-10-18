import Base
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/relation-commands.bend as A
import ../../../src/ecs/relation-types.bend as G
import ../../../src/ecs/lifetime-scope.bend as Sc
import ../../../src/ecs/column.bend as Col
import ../../../src/ecs/inspector.bend as I
import ../../../src/ecs/inspector-query.bend as IQ
import ../../../src/ecs/ordinary-query-observable.bend as Q
import ../../../src/ecs/compose.bend as Compose
import ../../../src/ecs/capabilities.bend as Cap
import ../../../src/ecs/component.bend as Cmp
import ../ordinary-v1/fixture.bend as Values
import ./fixture.bend as F
def Store(~S:Data) -> Type:
  A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>
def World(~S:Data) -> Type:
  W.World<S,A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,Unit,A.Notice<S,U32>>
def Frame(~S:Data) -> Type:
  I.Frame<S,A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,Unit,A.Notice<S,U32>>
type State<S:Data> is Type:
  State{world:World(~S),cursor:Nat,status:String}
type EdgePair is Data:
  EdgePair{a:U32,b:U32}
# Explicit compact JSON separators; Base List.show intentionally adds spaces.
def compact_tail(~T:Data,~show:T -> String,values:List<&2,T>) -> String:
  match values:
    case []:""
    case item <> rest:"," ++ show(item) ++ compact_tail(~T,~show,rest)
def compact(~T:Data,~show:T -> String,values:List<&2,T>) -> String:
  match values:
    case []:"[]"
    case item <> rest:"[" ++ show(item) ++ compact_tail(~T,~show,rest) ++ "]"
def numbers(values:List<&2,U32>) -> String:
  compact(~U32,~U32.show,values)
def pair_text(value:EdgePair) -> String:
  match value:
    case EdgePair{a,b}:"[" ++ U32.show(a) ++ "," ++ U32.show(b) ++ "]"
def pair_before(left:EdgePair,right:EdgePair) -> Bool:
  match left right:
    case EdgePair{+a,b} EdgePair{+c,d}:U32.is_lt(a,c) || (U32.is_eq(a,c) && U32.is_lt(b,d))
def pair_inserted(before:Bool,item:EdgePair,head:EdgePair,rest:List<&2,EdgePair>,inserted:List<&2,EdgePair>) -> List<&2,EdgePair>:
  match before:
    case True{}:item <> head <> rest
    case False{}:head <> inserted
def pair_insert(+item:EdgePair,items:List<&2,EdgePair>) -> List<&2,EdgePair>:
  match items:
    case []:[item]
    case +head <> +rest:pair_inserted(pair_before(item,head),item,head,rest,pair_insert(item,rest))
def number_inserted(before:Bool,id:U32,head:U32,rest:List<&2,U32>,inserted:List<&2,U32>) -> List<&2,U32>:
  match before:
    case True{}:id <> head <> rest
    case False{}:head <> inserted
def number_insert(+id:U32,items:List<&2,U32>) -> List<&2,U32>:
  match items:
    case []:[id]
    case +head <> +rest:number_inserted(U32.is_lt(id,head),id,head,rest,number_insert(id,rest))
def number_sort(items:List<&2,U32>,acc:List<&2,U32>) -> List<&2,U32>:
  match items:
    case []:acc
    case id <> rest:number_sort(rest,number_insert(id,acc))
def forward_chosen(same:Bool,source:U32,target:U32,acc:List<&2,EdgePair>) -> List<&2,EdgePair>:
  match same:
    case True{}:pair_insert(EdgePair{source,target},acc)
    case False{}:acc
def forward(~S:Data,edges:List<&2,G.Edge<S>>,+key:U32,acc:List<&2,EdgePair>) -> List<&2,EdgePair>:
  match edges:
    case []:acc
    case G.Edge{G.Descriptor{id,_,_,_},source,target} <> rest:forward(~S,rest,key,forward_chosen(U32.is_eq(key,id),source,target,acc))
def source_pairs(+target:U32,sources:List<&2,U32>,acc:List<&2,EdgePair>) -> List<&2,EdgePair>:
  match sources:
    case []:acc
    case source <> rest:source_pairs(target,rest,pair_insert(EdgePair{target,source},acc))
def inverse_chosen(same:Bool,target:U32,sources:List<&2,U32>,acc:List<&2,EdgePair>) -> List<&2,EdgePair>:
  match same:
    case True{}:source_pairs(target,sources,acc)
    case False{}:acc
def inverse(~S:Data,items:List<&2,G.Inverse<S>>,+key:U32,acc:List<&2,EdgePair>) -> List<&2,EdgePair>:
  match items:
    case []:acc
    case G.Inverse{G.Descriptor{id,_,_,_},target,sources} <> rest:inverse(~S,rest,key,inverse_chosen(U32.is_eq(key,id),target,sources,acc))
def graph_text(~S:Data,graph:G.Graph<S>) -> String:
  match graph:
    case G.Graph{+edges,+inverses}:
      "\"parent\":" ++ compact(~EdgePair,~pair_text,forward(~S,edges,2,[])) ++ ",\"children\":" ++ compact(~EdgePair,~pair_text,inverse(~S,inverses,2,[])) ++ ",\"link\":" ++ compact(~EdgePair,~pair_text,forward(~S,edges,1,[])) ++ ",\"incoming\":" ++ compact(~EdgePair,~pair_text,inverse(~S,inverses,1,[]))
def graph_store(~S:Data,store:Store(~S)) -> Store(~S) & String:
  match store:
    case A.Store{components,+graph}:(A.Store{components,graph},graph_text(~S,graph))
def count(~S:Data,events:List<&2,A.Notice<S,U32>>,acc:Nat) -> Nat:
  match events:
    case []:acc
    case _ <> rest:count(~S,rest,1n+acc)
def notice(~S:Data,value:A.Notice<S,U32>,removed:List<&2,U32>,despawned:List<&2,U32>) -> List<&2,U32> & List<&2,U32>:
  match value:
    case A.ComponentRemoved{id}:(number_insert(id,removed),despawned)
    case A.Original{id}:(removed,number_insert(id,despawned))
    case _:(removed,despawned)
def noticed(~S:Data,value:A.Notice<S,U32>,seen:List<&2,U32> & List<&2,U32>) -> List<&2,U32> & List<&2,U32>:
  match seen:
    case (removed,despawned):notice(~S,value,removed,despawned)
def notices(~S:Data,events:List<&2,A.Notice<S,U32>>,cursor:Nat,removed:List<&2,U32>,despawned:List<&2,U32>) -> List<&2,U32> & List<&2,U32>:
  match events cursor:
    case [] _:(removed,despawned)
    case _ <> rest 1n+p:notices(~S,rest,p,removed,despawned)
    case value <> rest 0n:noticed(~S,value,notices(~S,rest,0n,removed,despawned))
def notices_text(seen:List<&2,U32> & List<&2,U32>) -> String:
  match seen:
    case (removed,despawned):",\"removed\":" ++ numbers(removed) ++ ",\"despawned\":" ++ numbers(despawned)
def row_access(id:U32,value:Cmp.Access<List<&2,U32>>) -> String:
  match value:
    case Cmp.Found{values}:"{\"id\":" ++ U32.show(id) ++ ",\"payload\":" ++ numbers(values) ++ "}"
    case _:"UnexpectedMissingPayload"
def row_text(~S:Data,row:IQ.ProjectedRow<S,Cmp.Access<List<&2,U32>>>) -> String:
  match row:
    case IQ.ProjectedRow{W.Handle{_,id},values}:row_access(id,values)
def rows_ready(~S:Data,seen:Frame(~S) & List<&2,IQ.ProjectedRow<S,Cmp.Access<List<&2,U32>>>>) -> World(~S) & String:
  match seen:
    case (I.Frame{world,_},rows):(world,compact(~IQ.ProjectedRow<S,Cmp.Access<List<&2,U32>>>,~row_text(~S),rows))
def rows(~S:Data,world:World(~S)) -> World(~S) & String:
  rows_ready(~S,IQ.each_composed(~Frame(~S),~S,~Cmp.Access<List<&2,U32>>,~Q.inspect_query(~S,~A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,~Unit,~A.Notice<S,U32>,~Compose.Frame<S,A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,Unit,A.Notice<S,U32>>,~Cap.Read<Compose.Frame<S,A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,Unit,A.Notice<S,U32>>,List<&2,U32>>,~Cmp.Access<List<&2,U32>>,~F.query(~S)),I.Frame{world,0}))
def observed_events(~S:Data,head:String,rowtext:String,graph:String,cursor:Nat,status:String,seen:World(~S) & List<&2,A.Notice<S,U32>>) -> State<S> & String:
  match seen:
    case (world,+events):(State{world,count(~S,events,0n),status},head ++ "\"rows\":" ++ rowtext ++ "," ++ graph ++ notices_text(notices(~S,events,cursor,[],[])) ++ "}")
def observed_graph(~S:Data,head:String,rowtext:String,cursor:Nat,status:String,seen:World(~S) & String) -> State<S> & String:
  match seen:
    case (world,graph):observed_events(~S,head,rowtext,graph,cursor,status,W.events_view(~S,~A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,~Unit,~A.Notice<S,U32>,world))
def observed_rows(~S:Data,head:String,cursor:Nat,status:String,seen:World(~S) & String) -> State<S> & String:
  match seen:
    case (world,rowtext):observed_graph(~S,head,rowtext,cursor,status,W.with_store(~S,~A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,~Unit,~A.Notice<S,U32>,~String,graph_store(~S),world))
def observe(~S:Data,+repeat:U32,+schema:String,+scenario:String,phase:String,state:State<S>) -> State<S> & String:
  match state:
    case State{world,cursor,+status}:observed_rows(~S,"{\"repeat\":" ++ U32.show(repeat) ++ ",\"schema\":\"" ++ schema ++ "\",\"case\":\"" ++ scenario ++ "\",\"phase\":\"" ++ phase ++ "\",\"status\":\"" ++ status ++ "\",",cursor,status,rows(~S,world))
