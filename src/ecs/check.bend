import Base
import inspector.bend as I
import inspector-query-projection.bend as Q
import world.bend as W
import component.bend as C
import column.bend as Col
import capabilities.bend as Cap

# Trusted declaration setup receives a nominal cursor-free frame. The public
# query grant exposes neither lifecycle filters nor added/changed observations.
# Machine conditions belong to #55; services/streams have no grant here.
# Trusted cursor-free Check frame owning World. Ordinary condition bodies
# receive opaque H with read capabilities, not raw world constructors.
# No lifecycle cursor or event reader is allocated by this frame.
type Frame<-S:Data,-Store:Type,-R:Type,-E:Data> is Type:
  Frame{world:W.World<S,Store,R,E>}
# Condition query membership: Required excludes absent components; Optional
# retains live rows with explicit absence. No Added/Changed mode is offered.
type PlainSelection is Data:
  Required{}
  Optional{}
# Detached condition-query row: entity handle plus component Access<V>.
# Does not expose added/changed flags or an affine component payload.
type Row<S:Data,V:Data> is Data:
  Row{entity:W.Handle<S>,value:C.Access<V>}
# Preflight failure listing required runtime resources absent from the plan.
# Check body is not invoked when this error is returned.
type Error is Data:
  MissingRuntimeRequirements{resources:List<&2,String>}
# Trusted setup pairing runtime-requirement observation with read grants.
# required must return World; arbitrary callback mutations are not isolated
# by the Check abstraction. Bodies receive only the declared Ops(H).
type Plan<-S:Data,-Store:Type,-R:Type,-E:Data,-Ops:Type -> Type> is Type:
  Plan{required:W.World<S,Store,R,E> -> W.World<S,Store,R,E> & List<&2,String>,caps:Ops(Frame<S,Store,R,E>)}
# Check outcome retaining World with either a preflight Error or Bool.
# False is a successful condition result, distinct from missing requirements.
type Checked<S:Data,Store:Type,R:Type,E:Data> is Type:
  Checked{world:W.World<S,Store,R,E>,result:Result<&2,&2,Error,Bool>}

def selection(value:PlainSelection) -> Q.Selection:
  match value:
    case Required{}:Q.Required{}
    case Optional{}:Q.Optional{}
def plain_row(~S:Data,~V:Data,value:Q.Row<S,V>) -> Row<S,V>:
  match value:
    case Q.Row{entity,I.Value{access,_,_}}:Row{entity,access}
def plain_rows(~S:Data,~V:Data,values:List<&2,Q.Row<S,V>>) -> List<&2,Row<S,V>>:
  match values:
    case []:[]
    case value <> rest:plain_row(~S,~V,value) <> plain_rows(~S,~V,rest)
def query_done(~S:Data,~Store:Type,~R:Type,~E:Data,~V:Data,result:I.Frame<S,Store,R,E> & List<&2,Q.Row<S,V>>) -> Frame<S,Store,R,E> & List<&2,Row<S,V>>:
  match result:
    case (I.Frame{world,_},rows):(Frame{world},plain_rows(~S,~V,rows))
def query_read(~S:Data,~Store:Type,~R:Type,~E:Data,~Rest:Type,~Payload:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,Payload>,~put:Rest -> Col.Column<S,Payload> -> Store,~project:Payload -> Payload & V,~family:C.Family<S,Store,Rest,Payload,V,Token,take,put,project>,~mode:PlainSelection,frame:Frame<S,Store,R,E>) -> Frame<S,Store,R,E> & List<&2,Row<S,V>>:
  match frame:
    case Frame{world}:query_done(~S,~Store,~R,~E,~V,Q.scan(~S,~Store,~R,~E,~Rest,~Payload,~V,~Token,~take,~put,~project,~family,~selection(mode),I.Frame{world,0}))
# Build a read-only component query for Required or Optional membership.
# Canonical scan returns detached Access rows in its live-handle traversal order,
# without lifecycle flags or consuming registered system cursors. project must
# preserve payload owners; raw family lenses remain trusted schema setup.
def query_grant(~S:Data,~Store:Type,~R:Type,~E:Data,~Rest:Type,~Payload:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,Payload>,~put:Rest -> Col.Column<S,Payload> -> Store,~project:Payload -> Payload & V,~family:C.Family<S,Store,Rest,Payload,V,Token,take,put,project>,~mode:PlainSelection) -> Cap.ValueRead<Frame<S,Store,R,E>,List<&2,Row<S,V>>>:
  Cap.ValueRead{frame => query_read(~S,~Store,~R,~E,~Rest,~Payload,~V,~Token,~take,~put,~project,~family,~mode,frame)}
def resource_done(~S:Data,~Store:Type,~R:Type,~E:Data,~V:Data,result:W.World<S,Store,R,E> & V) -> Frame<S,Store,R,E> & V:
  (world,value)=result
  (Frame{world},value)
def resource_read(~S:Data,~Store:Type,~R:Type,~E:Data,~V:Data,~project:R -> R & V,frame:Frame<S,Store,R,E>) -> Frame<S,Store,R,E> & V:
  match frame:
    case Frame{world}:resource_done(~S,~Store,~R,~E,~V,W.observe_resource(~S,~Store,~R,~E,~V,~project,world))
# Build read-only access to a detached resource Data view. project threads
# affine R back unchanged in ownership; no replacement or event-read grant
# is provided and no resource projection runs during declaration construction.
def resource_grant(~S:Data,~Store:Type,~R:Type,~E:Data,~V:Data,~project:R -> R & V) -> Cap.ValueRead<Frame<S,Store,R,E>,V>:
  Cap.ValueRead{frame => resource_read(~S,~Store,~R,~E,~V,~project,frame)}

def completed(~S:Data,~Store:Type,~R:Type,~E:Data,result:Frame<S,Store,R,E> & Bool) -> Checked<S,Store,R,E>:
  match result:
    case (Frame{world},value):Checked{world,Done{value}}
def ready(~S:Data,~Store:Type,~R:Type,~E:Data,~Ops:Type -> Type,~A:Data,~body:@-H:Type -> @-caps:Ops(H) -> A -> H -> H & Bool,~caps:Ops(Frame<S,Store,R,E>),args:A,result:W.World<S,Store,R,E> & List<&2,String>) -> Checked<S,Store,R,E>:
  match result:
    case (world,[]):completed(~S,~Store,~R,~E,Cap.invoke(~Ops,~A,~Bool,~body,~Frame<S,Store,R,E>,~caps,args,Frame{world}))
    case (world,name <> rest):Checked{world,Fail{MissingRuntimeRequirements{name <> rest}}}
def required_field(~S:Data,~Store:Type,~R:Type,~E:Data,~Ops:Type -> Type,plan:Plan<S,Store,R,E,Ops>) -> W.World<S,Store,R,E> -> W.World<S,Store,R,E> & List<&2,String>:
  match plan:
    case Plan{required,_}:required
def caps_field(~S:Data,~Store:Type,~R:Type,~E:Data,~Ops:Type -> Type,plan:Plan<S,Store,R,E,Ops>) -> Ops(Frame<S,Store,R,E>):
  match plan:
    case Plan{_,caps}:caps
# Check runtime requirements, then evaluate a cursor-free Bool body through
# its declared capabilities. Missing requirements return Checked with Fail
# without invoking body; otherwise Done contains True or False. World is
# returned on both paths, including any changes made by trusted requirement
# callbacks. Check itself advances no system/lifecycle/event cursor or clock.
# No automatic transaction rollback applies to arbitrary setup callbacks.
# Condition contract and consumers: docs/parity/inspect.md.
def run(~S:Data,~Store:Type,~R:Type,~E:Data,~Ops:Type -> Type,~A:Data,~body:@-H:Type -> @-caps:Ops(H) -> A -> H -> H & Bool,~plan:Plan<S,Store,R,E,Ops>,args:A,world:W.World<S,Store,R,E>) -> Checked<S,Store,R,E>:
  ready(~S,~Store,~R,~E,~Ops,~A,~body,~caps_field(~S,~Store,~R,~E,~Ops,plan),args,required_field(~S,~Store,~R,~E,~Ops,plan)(world))
