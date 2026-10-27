import Base
import ./execution-query-domain.bend as D
import ./execution-query-slice.bend as Slice
import ./chunk-partition.bend as Part
import ./execution-composer-layout.bend as Layout
import ./change-tick.bend as Tick

# One family's closed declaration. Full-schema lowering folds these branded
# results by Layout route; it must compile EVERY grant before cutting storage.
type Recipe is Data:
  Read{domain:D.Domain}
  Write{domain:D.Domain}
  Both{left:Recipe,right:Recipe}
type ReadCap<-S:Data,-origin:Layout.Layout> is Type:
  ReadCap{domain:D.Domain}
type WriteCap<-S:Data,-origin:Layout.Layout> is Type:
  WriteCap{domain:D.Domain}
type Grants<-S:Data,-origin:Layout.Layout> is Type:
  Reader{cap:ReadCap<S,origin>}
  Writer{cap:WriteCap<S,origin>}
  Together{left:Grants<S,origin>,right:Grants<S,origin>}
type Compiled<-S:Data,-origin:Layout.Layout> is Type:
  Compiled{access:D.Access,grants:Grants<S,origin>}
def combined(-S:Data,-origin:Layout.Layout,left:Compiled<S,origin>,right:Compiled<S,origin>) -> Compiled<S,origin>:
  match left right:
    case Compiled{D.Access{lr,lw},lg} Compiled{D.Access{rr,rw},rg}:Compiled{D.Access{D.union(lr,rr),D.union(lw,rw)},Together{lg,rg}}
def compile(-S:Data,-origin:Layout.Layout,recipe:Recipe) -> Compiled<S,origin>:
  match recipe:
    case Read{+domain}:Compiled{D.Access{domain,D.Domain{[]}},Reader{ReadCap{domain}}}
    case Write{+domain}:Compiled{D.Access{domain,domain},Writer{WriteCap{domain}}}
    case Both{left,right}:combined(S,origin,compile(S,origin,left),compile(S,origin,right))

type Presence is Data:
  Optional{}
  Required{}
  With{}
  Without{}
type Row<-V:Data> is Data:
  Row{offset:U32,view:Maybe<&2,V>}
type Single<-V:Data> is Data:
  NoMatch{}
  One{row:Row<V>}
  Multiple{}
type Query<-S:Data,-P:Type,-V:Data,-origin:Layout.Layout> is Type:
  Selected{slot:Slice.Slot<S,Layout.Viewed<P,V>,origin>,rows:List<&2,Row<V>>}
  QueryRefused{slot:Slice.Slot<S,Layout.Viewed<P,V>,origin>,requested:D.Domain}
def present(-V:Data,value:Maybe<&2,V>) -> Bool:
  match value:
    case None{}:False{}
    case Some{_}:True{}
def membership(-V:Data,presence:Presence,value:Maybe<&2,V>) -> Bool:
  match presence:
    case Optional{}:True{}
    case Required{}:present(V,value)
    case With{}:present(V,value)
    case Without{}:Bool.not(present(V,value))
def selected_row(-V:Data,offset:U32,view:Maybe<&2,V>,rows:List<&2,Row<V>>,matched:Bool) -> List<&2,Row<V>>:
  match matched:
    case False{}:rows
    case True{}:Row{offset,view} <> rows
def query_returned(~S:Data,~P:Type,~V:Data,~origin:Layout.Layout,~predicate:Maybe<&2,V> -> Bool,+presence:Presence,index:U32,next:Slice.Slot<S,Layout.Viewed<P,V>,origin> -> List<&2,Row<V>> -> Query<S,P,V,origin>,rows:List<&2,Row<V>>,result:Slice.Slot<S,Layout.Viewed<P,V>,origin> & Maybe<&2,V>) -> Query<S,P,V,origin>:
  match result:
    case (slot,+view):next(slot,selected_row(V,index,view,rows,Bool.and(membership(V,presence,view),predicate(view))))
def query_rows(~S:Data,~P:Type,~V:Data,~origin:Layout.Layout,~predicate:Maybe<&2,V> -> Bool,offsets:List<&2,U32>,+presence:Presence,slot:Slice.Slot<S,Layout.Viewed<P,V>,origin>,rows:List<&2,Row<V>>) -> Query<S,P,V,origin>:
  match offsets:
    case []:Selected{slot,List.reverse(&2,Row<V>,rows)}
    case +index <> rest:query_returned(~S,~P,~V,~origin,~predicate,presence,index,(slot => rows => query_rows(~S,~P,~V,~origin,~predicate,rest,presence,slot,rows)),rows,Slice.read(S,P,V,origin,slot,index))
def query_checked(~S:Data,~P:Type,~V:Data,~origin:Layout.Layout,~predicate:Maybe<&2,V> -> Bool,slot:Slice.Slot<S,Layout.Viewed<P,V>,origin>,requested:D.Domain,presence:Presence,allowed:Bool) -> Query<S,P,V,origin>:
  match requested allowed:
    case requested False{}:QueryRefused{slot,requested}
    case D.Domain{offsets} True{}:query_rows(~S,~P,~V,~origin,~predicate,offsets,presence,slot,[])
def query(~S:Data,~P:Type,~V:Data,~origin:Layout.Layout,~predicate:Maybe<&2,V> -> Bool,slot:Slice.Slot<S,Layout.Viewed<P,V>,origin>,+requested:D.Domain,presence:Presence) -> Query<S,P,V,origin>:
  match slot:
    case Slice.Slot{Part.Slice{+domain,cells}}:query_checked(~S,~P,~V,~origin,~predicate,Slice.Slot{Part.Slice{domain,cells}},requested,presence,Bool.and(Part.subset(requested,domain),Part.inventory_valid(D.validate(4294967295,requested))))
def single(-V:Data,rows:List<&2,Row<V>>) -> Single<V>:
  match rows:
    case []:NoMatch{}
    case row <> []:One{row}
    case _ <> _ <> _:Multiple{}
def count(-V:Data,rows:List<&2,Row<V>>) -> U32:
  match rows:
    case []:0
    case _ <> rest:U32.add(1,count(V,rest))

def cap_read_done(-S:Data,-P:Type,-V:Data,-origin:Layout.Layout,cap:ReadCap<S,origin>,result:Slice.Slot<S,Layout.Viewed<P,V>,origin> & Maybe<&2,V>) -> ReadCap<S,origin> & (Slice.Slot<S,Layout.Viewed<P,V>,origin> & Maybe<&2,V>):
  (cap,result)
def cap_read_allowed(-S:Data,-P:Type,-V:Data,-origin:Layout.Layout,slot:Slice.Slot<S,Layout.Viewed<P,V>,origin>,index:U32,allowed:Bool) -> Slice.Slot<S,Layout.Viewed<P,V>,origin> & Maybe<&2,V>:
  match allowed:
    case False{}:(slot,None{})
    case True{}:Slice.read(S,P,V,origin,slot,index)
def cap_read(-S:Data,-P:Type,-V:Data,-origin:Layout.Layout,cap:ReadCap<S,origin>,slot:Slice.Slot<S,Layout.Viewed<P,V>,origin>,+index:U32) -> ReadCap<S,origin> & (Slice.Slot<S,Layout.Viewed<P,V>,origin> & Maybe<&2,V>):
  match cap:
    case ReadCap{+domain}:cap_read_done(S,P,V,origin,ReadCap{domain},cap_read_allowed(S,P,V,origin,slot,index,D.contains(domain,index)))
def cap_edit_allowed(~S:Data,~layout:Layout.Layout,~route:Layout.Route,-Out:Type,slot:Slice.Slot<S,Layout.stored(layout,route),Layout.origin(layout,route)>,index:U32,tick:Tick.Tick,transform:Layout.payload(layout,route) -> Layout.payload(layout,route) & Out,allowed:Bool) -> Slice.Edit<S,Layout.stored(layout,route),Layout.origin(layout,route),Layout.payload(layout,route),Out>:
  match allowed:
    case False{}:Slice.Unchanged{slot,transform}
    case True{}:Slice.edit(~S,~layout,~route,Out,slot,index,tick,transform)
def cap_edit(~S:Data,~layout:Layout.Layout,~route:Layout.Route,-Out:Type,cap:WriteCap<S,Layout.origin(layout,route)>,slot:Slice.Slot<S,Layout.stored(layout,route),Layout.origin(layout,route)>,+index:U32,tick:Tick.Tick,transform:Layout.payload(layout,route) -> Layout.payload(layout,route) & Out) -> WriteCap<S,Layout.origin(layout,route)> & Slice.Edit<S,Layout.stored(layout,route),Layout.origin(layout,route),Layout.payload(layout,route),Out>:
  match cap:
    case WriteCap{+domain}:(WriteCap{domain},cap_edit_allowed(~S,~layout,~route,Out,slot,index,tick,transform,D.contains(domain,index)))

def validate_recipe(+capacity:U32,recipe:Recipe) -> Bool:
  match recipe:
    case Read{domain}:Part.inventory_valid(D.validate(capacity,domain))
    case Write{domain}:Part.inventory_valid(D.validate(capacity,domain))
    case Both{left,right}:Bool.and(validate_recipe(capacity,left),validate_recipe(capacity,right))
type Preparation<-S:Data,-origin:Layout.Layout> is Type:
  InvalidRecipe{recipe:Recipe}
  Prepared{compiled:Compiled<S,origin>}
def prepare_checked(-S:Data,-origin:Layout.Layout,recipe:Recipe,valid:Bool) -> Preparation<S,origin>:
  match valid:
    case False{}:InvalidRecipe{recipe}
    case True{}:Prepared{compile(S,origin,recipe)}
def prepare(-S:Data,-origin:Layout.Layout,capacity:U32,+recipe:Recipe) -> Preparation<S,origin>:
  prepare_checked(S,origin,recipe,validate_recipe(capacity,recipe))

# Explicit cache capture is an observation, never new mutation authority. A
# scheduler may share it for admitted read/read access only after conflicts.
type ReadCache<-S:Data,-V:Data,-origin:Layout.Layout> is Data:
  ReadCache{rows:List<&2,Row<V>>}
type Capture<-S:Data,-P:Type,-V:Data,-origin:Layout.Layout> is Type:
  Captured{slot:Slice.Slot<S,Layout.Viewed<P,V>,origin>,cache:ReadCache<S,V,origin>}
  CaptureRefused{slot:Slice.Slot<S,Layout.Viewed<P,V>,origin>,requested:D.Domain}
def accept(-V:Data,value:Maybe<&2,V>) -> Bool:True{}
def captured(-S:Data,-P:Type,-V:Data,-origin:Layout.Layout,result:Query<S,P,V,origin>) -> Capture<S,P,V,origin>:
  match result:
    case Selected{slot,rows}:Captured{slot,ReadCache{rows}}
    case QueryRefused{slot,requested}:CaptureRefused{slot,requested}
def capture(~S:Data,~P:Type,~V:Data,~origin:Layout.Layout,slot:Slice.Slot<S,Layout.Viewed<P,V>,origin>,requested:D.Domain) -> Capture<S,P,V,origin>:
  captured(S,P,V,origin,query(~S,~P,~V,~origin,~accept(V),slot,requested,Optional{}))
