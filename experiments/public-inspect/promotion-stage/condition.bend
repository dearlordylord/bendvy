import Base
import ../bend-candidate/inspect.bend as I
import ../bend-candidate/query.bend as Q
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/component.bend as C
import ../../../src/ecs/column.bend as Col
import ../../../src/ecs/capabilities.bend as Cap

# Trusted declaration setup receives a nominal cursor-free frame. The public
# query grant exposes neither lifecycle filters nor added/changed observations.
# Machine conditions belong to #55; services/streams have no grant here.
type Frame<-S:Data,-Store:Type,-R:Type,-E:Data> is Type:
  Frame{world:W.World<S,Store,R,E>}
type PlainSelection is Data:
  Required{}
  Optional{}
type Row<S:Data,V:Data> is Data:
  Row{entity:W.Handle<S>,value:C.Access<V>}
type Error is Data:
  MissingRuntimeRequirements{resources:List<&2,String>}
type Plan<-S:Data,-Store:Type,-R:Type,-E:Data,-Ops:Type -> Type> is Type:
  Plan{required:W.World<S,Store,R,E> -> W.World<S,Store,R,E> & List<&2,String>,caps:Ops(Frame<S,Store,R,E>)}
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
def query_grant(~S:Data,~Store:Type,~R:Type,~E:Data,~Rest:Type,~Payload:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,Payload>,~put:Rest -> Col.Column<S,Payload> -> Store,~project:Payload -> Payload & V,~family:C.Family<S,Store,Rest,Payload,V,Token,take,put,project>,~mode:PlainSelection) -> Cap.ValueRead<Frame<S,Store,R,E>,List<&2,Row<S,V>>>:
  Cap.ValueRead{frame => query_read(~S,~Store,~R,~E,~Rest,~Payload,~V,~Token,~take,~put,~project,~family,~mode,frame)}
def resource_done(~S:Data,~Store:Type,~R:Type,~E:Data,~V:Data,result:W.World<S,Store,R,E> & V) -> Frame<S,Store,R,E> & V:
  (world,value)=result
  (Frame{world},value)
def resource_read(~S:Data,~Store:Type,~R:Type,~E:Data,~V:Data,~project:R -> R & V,frame:Frame<S,Store,R,E>) -> Frame<S,Store,R,E> & V:
  match frame:
    case Frame{world}:resource_done(~S,~Store,~R,~E,~V,W.observe_resource(~S,~Store,~R,~E,~V,~project,world))
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
def run(~S:Data,~Store:Type,~R:Type,~E:Data,~Ops:Type -> Type,~A:Data,~body:@-H:Type -> @-caps:Ops(H) -> A -> H -> H & Bool,~plan:Plan<S,Store,R,E,Ops>,args:A,world:W.World<S,Store,R,E>) -> Checked<S,Store,R,E>:
  ready(~S,~Store,~R,~E,~Ops,~A,~body,~caps_field(~S,~Store,~R,~E,~Ops,plan),args,required_field(~S,~Store,~R,~E,~Ops,plan)(world))
