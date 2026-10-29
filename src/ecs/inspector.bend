import Base
import ./change-tick.bend as Tick
import world.bend as W
import component.bend as C
import column.bend as Col
import lifecycle.bend as L
import capabilities.bend as Cap

# Trusted closed setup owns concrete lenses. The callback sees only opaque H.
# Trusted Inspector execution frame owning World and its observation cursor.
# Bodies receive opaque H through grants, not this raw constructor. It is not
# a registered system transaction or a snapshot that can restore World.
type Frame<-S:Data,-Store:Type,-R:Type,-E:Data> is Type:
  Frame{world:W.World<S,Store,R,E>,cursor:Maybe<&2,Tick.Tick>}
# Standalone Inspector lifecycle cursor state. Fresh starts with no previous cursor;
# Active retains its last successful observation cursor and initial clock.
# Schema S is static: this raw value does not carry a runtime world namespace.
# Reuse with its intended world; use runtime-bound wrappers for checked ownership.
type Instance<-S:Data> is Type:
  Fresh{}
  Active{cursor:Maybe<&2,Tick.Tick>,registeredAt:Tick.Tick}
# Detached component lookup result plus added/changed flags relative to the
# Inspector cursor. access is Found, ComponentAbsent or MissingEntity; the
# original affine component remains in World, never in this Data observation.
type Value<V:Data> is Data:
  Value{access:C.Access<V>,added:Bool,changed:Bool}
# Typed read-only lookup operation for a schema-scoped entity handle.
# get returns the opaque owner with a detached Value; no component write
# operation or live payload reference is exposed to the inspection body.
type Lookup<-H:Type,-S:Data,-V:Data> is Type:
  Lookup{get:H -> W.Handle<S> -> H & Value<V>}
# Trusted setup containing the exact Inspector capability shape Ops.
# Concrete lenses/projections stay outside the universally quantified body.
# Arbitrary supplied callbacks remain trusted and must preserve payload owners.
type Plan<-S:Data,-Store:Type,-R:Type,-E:Data,-Ops:Type -> Type> is Type:
  Plan{caps:Ops(Frame<S,Store,R,E>)}
# Inspector result retaining World and its updated Instance with either
# a Data error or output. Failure retains the prior observation cursor; success
# advances the standalone cursor and world clock. It owns no system reader.
type Observed<-S:Data,-Store:Type,-R:Type,-E:Data,U:Data,Out:Data> is Type:
  Observed{world:W.World<S,Store,R,E>,instance:Instance<S>,result:Result<&2,&2,U,Out>}

def lookup_field(~H:Type,~S:Data,~V:Data,cap:Lookup<H,S,V>) -> H -> W.Handle<S> -> H & Value<V>:
  match cap:
    case Lookup{get}:get

# Look up a handle through a declared Inspector capability, returning its
# affine owner and detached Access/lifecycle flags. Stale or foreign handles
# are MissingEntity through canonical family lookup, not an absent component.
def lookup(~H:Type,~S:Data,~V:Data,~cap:Lookup<H,S,V>,ctx:H,target:W.Handle<S>) -> H & Value<V>:
  lookup_field(~H,~S,~V,cap)(ctx,target)

def family_clocked(~S:Data,~Store:Type,~R:Type,~E:Data,~V:Data,+cursor:Maybe<&2,Tick.Tick>,+stamp:L.Stamp,value:C.Access<V>,observed:W.World<S,Store,R,E> & Tick.Tick) -> Frame<S,Store,R,E> & Value<V>:
  (world,+this)=observed
  (Frame{world,cursor},Value{value,L.added(stamp,cursor,this),L.changed(stamp,cursor,this)})
def family_join(~S:Data,~Store:Type,~R:Type,~E:Data,~V:Data,+cursor:Maybe<&2,Tick.Tick>,+stamp:L.Stamp,observed:W.World<S,Store,R,E> & C.Access<V>) -> Frame<S,Store,R,E> & Value<V>:
  (world,value)=observed
  family_clocked(~S,~Store,~R,~E,~V,cursor,stamp,value,W.execution_clock(~S,~Store,~R,~E,world))

def family_stamped(~S:Data,~Store:Type,~R:Type,~E:Data,~Rest:Type,~C:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,C>,~put:Rest -> Col.Column<S,C> -> Store,~project:C -> C & V,~family:C.Family<S,Store,Rest,C,V,Token,take,put,project>,cursor:Maybe<&2,Tick.Tick>,target:W.Handle<S>,observed:W.World<S,Store,R,E> & L.Stamp) -> Frame<S,Store,R,E> & Value<V>:
  (world,stamp)=observed
  family_join(~S,~Store,~R,~E,~V,cursor,stamp,C.get(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,family,world,target))

def family_get(~S:Data,~Store:Type,~R:Type,~E:Data,~Rest:Type,~C:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,C>,~put:Rest -> Col.Column<S,C> -> Store,~project:C -> C & V,~family:C.Family<S,Store,Rest,C,V,Token,take,put,project>,frame:Frame<S,Store,R,E>,+target:W.Handle<S>) -> Frame<S,Store,R,E> & Value<V>:
  match frame:
    case Frame{world,cursor}:family_stamped(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,~family,cursor,target,C.lifecycle(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,family,world,target))

# Trusted setup constructor for component observation through canonical
# family lenses. project must return its payload owner alongside Data V.
# Creates a grant only; performs no lookup or cursor advancement itself.
def read_family(~S:Data,~Store:Type,~R:Type,~E:Data,~Rest:Type,~C:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,C>,~put:Rest -> Col.Column<S,C> -> Store,~project:C -> C & V,~family:C.Family<S,Store,Rest,C,V,Token,take,put,project>) -> Lookup<Frame<S,Store,R,E>,S,V>:
  Lookup{frame => target => family_get(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,~family,frame,target)}

def resource_join(~S:Data,~Store:Type,~R:Type,~E:Data,~V:Data,cursor:Maybe<&2,Tick.Tick>,observed:W.World<S,Store,R,E> & V) -> Frame<S,Store,R,E> & V:
  (world,value)=observed
  (Frame{world,cursor},value)

def resource_get(~S:Data,~Store:Type,~R:Type,~E:Data,~V:Data,~project:R -> R & V,frame:Frame<S,Store,R,E>) -> Frame<S,Store,R,E> & V:
  match frame:
    case Frame{world,cursor}:resource_join(~S,~Store,~R,~E,~V,cursor,W.observe_resource(~S,~Store,~R,~E,~V,~project,world))

# Trusted setup constructor for a detached resource Data view. project
# consumes/returns R; it must preserve affine resources and sibling owners.
# No replacement capability is exposed, and no resource is read during setup.
def read_resource(~S:Data,~Store:Type,~R:Type,~E:Data,~V:Data,~project:R -> R & V) -> Cap.ValueRead<Frame<S,Store,R,E>,V>:
  Cap.ValueRead{frame => resource_get(~S,~Store,~R,~E,~V,~project,frame)}

# Advanced projection extracting the capability shape from a trusted plan.
# Does not execute any grant or transfer a World owner.
def plan_caps(~S:Data,~Store:Type,~R:Type,~E:Data,~Ops:Type -> Type,plan:Plan<S,Store,R,E,Ops>) -> Ops(Frame<S,Store,R,E>):
  match plan:
    case Plan{caps}:caps

def succeeded(~S:Data,~Store:Type,~R:Type,~E:Data,~U:Data,~Out:Data,registeredAt:Tick.Tick,value:Out,observed:W.World<S,Store,R,E> & Tick.Tick) -> Observed<S,Store,R,E,U,Out>:
  (world,cursor)=observed
  Observed{world,Active{Some{cursor},registeredAt},Done{value}}

def finished(~S:Data,~Store:Type,~R:Type,~E:Data,~U:Data,~Out:Data,cursor:Maybe<&2,Tick.Tick>,registeredAt:Tick.Tick,frame:Frame<S,Store,R,E>,result:Result<&2,&2,U,Out>) -> Observed<S,Store,R,E,U,Out>:
  match frame result:
    case Frame{world,_} Fail{error}:Observed{world,Active{cursor,registeredAt},Fail{error}}
    case Frame{world,_} Done{value}:succeeded(~S,~Store,~R,~E,~U,~Out,registeredAt,value,W.advance_clock(~S,~Store,~R,~E,world))

def invoked(~S:Data,~Store:Type,~R:Type,~E:Data,~U:Data,~Out:Data,cursor:Maybe<&2,Tick.Tick>,registeredAt:Tick.Tick,result:Frame<S,Store,R,E> & Result<&2,&2,U,Out>) -> Observed<S,Store,R,E,U,Out>:
  (frame,result)=result
  finished(~S,~Store,~R,~E,~U,~Out,cursor,registeredAt,frame,result)

def initialized(~S:Data,~Store:Type,~R:Type,~E:Data,~Ops:Type -> Type,~A:Data,~U:Data,~Out:Data,~plan:Plan<S,Store,R,E,Ops>,~body:@-H:Type -> @-caps:Ops(H) -> A -> H -> H & Result<&2,&2,U,Out>,args:A,+cursor:Maybe<&2,Tick.Tick>,+registeredAt:Tick.Tick,world:W.World<S,Store,R,E>) -> Observed<S,Store,R,E,U,Out>:
  invoked(~S,~Store,~R,~E,~U,~Out,cursor,registeredAt,Cap.invoke(~Ops,~A,~Result<&2,&2,U,Out>,~body,~Frame<S,Store,R,E>,~plan_caps(~S,~Store,~R,~E,~Ops,plan),args,Frame{world,cursor}))

def first(~S:Data,~Store:Type,~R:Type,~E:Data,~Ops:Type -> Type,~A:Data,~U:Data,~Out:Data,~plan:Plan<S,Store,R,E,Ops>,~body:@-H:Type -> @-caps:Ops(H) -> A -> H -> H & Result<&2,&2,U,Out>,args:A,observed:W.World<S,Store,R,E> & Tick.Tick) -> Observed<S,Store,R,E,U,Out>:
  (world,registeredAt)=observed
  initialized(~S,~Store,~R,~E,~Ops,~A,~U,~Out,~plan,~body,args,None{},registeredAt,world)

# Run a standalone read-only Inspector body with its own Instance cursor.
# Returns World and Instance on both body success and failure. Success advances
# World clock and observation cursor; failure retains the prior cursor. Neither
# path advances a registered system cursor or owns event retention. This raw
# Instance has no world namespace check; canonical runtime-bound wrappers
# enforce their separate registration/world contracts. Trusted projections
# must preserve owners; arbitrary host effects are not automatically rolled back.
# Inspection contract and consumers: docs/parity/inspect.md.
def run(~S:Data,~Store:Type,~R:Type,~E:Data,~Ops:Type -> Type,~A:Data,~U:Data,~Out:Data,~plan:Plan<S,Store,R,E,Ops>,~body:@-H:Type -> @-caps:Ops(H) -> A -> H -> H & Result<&2,&2,U,Out>,instance:Instance<S>,args:A,world:W.World<S,Store,R,E>) -> Observed<S,Store,R,E,U,Out>:
  match instance:
    case Fresh{}:first(~S,~Store,~R,~E,~Ops,~A,~U,~Out,~plan,~body,args,W.clock(~S,~Store,~R,~E,world))
    case Active{cursor,registeredAt}:initialized(~S,~Store,~R,~E,~Ops,~A,~U,~Out,~plan,~body,args,cursor,registeredAt,world)

# Passive application inspection preserves its own cursor and the World clock.
# Unlike run, this operation does not create an observation boundary.
def passive_returned(~S:Data,~Store:Type,~R:Type,~E:Data,~U:Data,~Out:Data,instance:Instance<S>,observed:Frame<S,Store,R,E> & Result<&2,&2,U,Out>) -> Observed<S,Store,R,E,U,Out>:
  match observed:
    case (Frame{world,_},result):Observed{world,instance,result}
def passive_cursor(~S:Data,~Store:Type,~R:Type,~E:Data,~Ops:Type -> Type,~A:Data,~U:Data,~Out:Data,~plan:Plan<S,Store,R,E,Ops>,~body:@-H:Type -> @-caps:Ops(H) -> A -> H -> H & Result<&2,&2,U,Out>,instance:Instance<S>,cursor:Maybe<&2,Tick.Tick>,args:A,world:W.World<S,Store,R,E>) -> Observed<S,Store,R,E,U,Out>:
  passive_returned(~S,~Store,~R,~E,~U,~Out,instance,Cap.invoke(~Ops,~A,~Result<&2,&2,U,Out>,~body,~Frame<S,Store,R,E>,~plan_caps(~S,~Store,~R,~E,~Ops,plan),args,Frame{world,cursor}))
def passive(~S:Data,~Store:Type,~R:Type,~E:Data,~Ops:Type -> Type,~A:Data,~U:Data,~Out:Data,~plan:Plan<S,Store,R,E,Ops>,~body:@-H:Type -> @-caps:Ops(H) -> A -> H -> H & Result<&2,&2,U,Out>,instance:Instance<S>,args:A,world:W.World<S,Store,R,E>) -> Observed<S,Store,R,E,U,Out>:
  match instance:
    case Fresh{}:passive_cursor(~S,~Store,~R,~E,~Ops,~A,~U,~Out,~plan,~body,Fresh{},None{},args,world)
    case Active{+cursor,+registeredAt}:passive_cursor(~S,~Store,~R,~E,~Ops,~A,~U,~Out,~plan,~body,Active{cursor,registeredAt},cursor,args,world)
