import Base
import world.bend as W
import component.bend as C
import column.bend as Col
import lifecycle.bend as L
import capabilities.bend as Cap

# Trusted closed setup owns concrete lenses. The callback sees only opaque H.
type Frame<-S:Data,-Store:Type,-R:Type,-E:Data> is Type:
  Frame{world:W.World<S,Store,R,E>,cursor:U32}
type Instance<-S:Data> is Type:
  Fresh{}
  Active{cursor:U32,registeredAt:U32}
type Value<V:Data> is Data:
  Value{access:C.Access<V>,added:Bool,changed:Bool}
type Lookup<-H:Type,-S:Data,-V:Data> is Type:
  Lookup{get:H -> W.Handle<S> -> H & Value<V>}
type Plan<-S:Data,-Store:Type,-R:Type,-E:Data,-Ops:Type -> Type> is Type:
  Plan{caps:Ops(Frame<S,Store,R,E>)}
type Observed<-S:Data,-Store:Type,-R:Type,-E:Data,U:Data,Out:Data> is Type:
  Observed{world:W.World<S,Store,R,E>,instance:Instance<S>,result:Result<&2,&2,U,Out>}

def lookup_field(~H:Type,~S:Data,~V:Data,cap:Lookup<H,S,V>) -> H -> W.Handle<S> -> H & Value<V>:
  match cap:
    case Lookup{get}:get

def lookup(~H:Type,~S:Data,~V:Data,~cap:Lookup<H,S,V>,ctx:H,target:W.Handle<S>) -> H & Value<V>:
  lookup_field(~H,~S,~V,cap)(ctx,target)

def family_join(~S:Data,~Store:Type,~R:Type,~E:Data,~V:Data,+cursor:U32,+stamp:L.Stamp,observed:W.World<S,Store,R,E> & C.Access<V>) -> Frame<S,Store,R,E> & Value<V>:
  (world,value)=observed
  (Frame{world,cursor},Value{value,L.added(stamp,cursor),L.changed(stamp,cursor)})

def family_stamped(~S:Data,~Store:Type,~R:Type,~E:Data,~Rest:Type,~C:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,C>,~put:Rest -> Col.Column<S,C> -> Store,~project:C -> C & V,~family:C.Family<S,Store,Rest,C,V,Token,take,put,project>,cursor:U32,target:W.Handle<S>,observed:W.World<S,Store,R,E> & L.Stamp) -> Frame<S,Store,R,E> & Value<V>:
  (world,stamp)=observed
  family_join(~S,~Store,~R,~E,~V,cursor,stamp,C.get(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,family,world,target))

def family_get(~S:Data,~Store:Type,~R:Type,~E:Data,~Rest:Type,~C:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,C>,~put:Rest -> Col.Column<S,C> -> Store,~project:C -> C & V,~family:C.Family<S,Store,Rest,C,V,Token,take,put,project>,frame:Frame<S,Store,R,E>,+target:W.Handle<S>) -> Frame<S,Store,R,E> & Value<V>:
  match frame:
    case Frame{world,cursor}:family_stamped(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,~family,cursor,target,C.lifecycle(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,family,world,target))

def read_family(~S:Data,~Store:Type,~R:Type,~E:Data,~Rest:Type,~C:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,C>,~put:Rest -> Col.Column<S,C> -> Store,~project:C -> C & V,~family:C.Family<S,Store,Rest,C,V,Token,take,put,project>) -> Lookup<Frame<S,Store,R,E>,S,V>:
  Lookup{frame => target => family_get(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,~family,frame,target)}

def resource_join(~S:Data,~Store:Type,~R:Type,~E:Data,~V:Data,cursor:U32,observed:W.World<S,Store,R,E> & V) -> Frame<S,Store,R,E> & V:
  (world,value)=observed
  (Frame{world,cursor},value)

def resource_get(~S:Data,~Store:Type,~R:Type,~E:Data,~V:Data,~project:R -> R & V,frame:Frame<S,Store,R,E>) -> Frame<S,Store,R,E> & V:
  match frame:
    case Frame{world,cursor}:resource_join(~S,~Store,~R,~E,~V,cursor,W.observe_resource(~S,~Store,~R,~E,~V,~project,world))

def read_resource(~S:Data,~Store:Type,~R:Type,~E:Data,~V:Data,~project:R -> R & V) -> Cap.ValueRead<Frame<S,Store,R,E>,V>:
  Cap.ValueRead{frame => resource_get(~S,~Store,~R,~E,~V,~project,frame)}

def plan_caps(~S:Data,~Store:Type,~R:Type,~E:Data,~Ops:Type -> Type,plan:Plan<S,Store,R,E,Ops>) -> Ops(Frame<S,Store,R,E>):
  match plan:
    case Plan{caps}:caps

def succeeded(~S:Data,~Store:Type,~R:Type,~E:Data,~U:Data,~Out:Data,registeredAt:U32,value:Out,observed:W.World<S,Store,R,E> & U32) -> Observed<S,Store,R,E,U,Out>:
  (world,cursor)=observed
  Observed{world,Active{cursor,registeredAt},Done{value}}

def finished(~S:Data,~Store:Type,~R:Type,~E:Data,~U:Data,~Out:Data,cursor:U32,registeredAt:U32,frame:Frame<S,Store,R,E>,result:Result<&2,&2,U,Out>) -> Observed<S,Store,R,E,U,Out>:
  match frame result:
    case Frame{world,_} Fail{error}:Observed{world,Active{cursor,registeredAt},Fail{error}}
    case Frame{world,_} Done{value}:succeeded(~S,~Store,~R,~E,~U,~Out,registeredAt,value,W.advance_clock(~S,~Store,~R,~E,world))

def invoked(~S:Data,~Store:Type,~R:Type,~E:Data,~U:Data,~Out:Data,cursor:U32,registeredAt:U32,result:Frame<S,Store,R,E> & Result<&2,&2,U,Out>) -> Observed<S,Store,R,E,U,Out>:
  (frame,result)=result
  finished(~S,~Store,~R,~E,~U,~Out,cursor,registeredAt,frame,result)

def initialized(~S:Data,~Store:Type,~R:Type,~E:Data,~Ops:Type -> Type,~A:Data,~U:Data,~Out:Data,~plan:Plan<S,Store,R,E,Ops>,~body:@-H:Type -> @-caps:Ops(H) -> A -> H -> H & Result<&2,&2,U,Out>,args:A,+cursor:U32,+registeredAt:U32,world:W.World<S,Store,R,E>) -> Observed<S,Store,R,E,U,Out>:
  invoked(~S,~Store,~R,~E,~U,~Out,cursor,registeredAt,Cap.invoke(~Ops,~A,~Result<&2,&2,U,Out>,~body,~Frame<S,Store,R,E>,~plan_caps(~S,~Store,~R,~E,~Ops,plan),args,Frame{world,cursor}))

def first(~S:Data,~Store:Type,~R:Type,~E:Data,~Ops:Type -> Type,~A:Data,~U:Data,~Out:Data,~plan:Plan<S,Store,R,E,Ops>,~body:@-H:Type -> @-caps:Ops(H) -> A -> H -> H & Result<&2,&2,U,Out>,args:A,observed:W.World<S,Store,R,E> & U32) -> Observed<S,Store,R,E,U,Out>:
  (world,registeredAt)=observed
  initialized(~S,~Store,~R,~E,~Ops,~A,~U,~Out,~plan,~body,args,0,registeredAt,world)

def run(~S:Data,~Store:Type,~R:Type,~E:Data,~Ops:Type -> Type,~A:Data,~U:Data,~Out:Data,~plan:Plan<S,Store,R,E,Ops>,~body:@-H:Type -> @-caps:Ops(H) -> A -> H -> H & Result<&2,&2,U,Out>,instance:Instance<S>,args:A,world:W.World<S,Store,R,E>) -> Observed<S,Store,R,E,U,Out>:
  match instance:
    case Fresh{}:first(~S,~Store,~R,~E,~Ops,~A,~U,~Out,~plan,~body,args,W.clock(~S,~Store,~R,~E,world))
    case Active{cursor,registeredAt}:initialized(~S,~Store,~R,~E,~Ops,~A,~U,~Out,~plan,~body,args,cursor,registeredAt,world)
