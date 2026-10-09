import Base
import ./world.bend as W
import ./system.bend as Sys
import ./registration.bend as Registration

# Removal streams are retained metadata, not component owners or ordinary events.
# Schema/family are phantom indices; each closed selector defines its typed stream.
type Record<S: Data,F: Data> is Data:
  Removed{entity: W.Handle<S>,family: F}
  Despawned{entity: W.Handle<S>}
type Reader<S: Data,E: Data,F: Data,-select: E -> Maybe<&2,Record<S,F>>> is Type:
  Reader{namespace: U32,id: U32,name: String,cursor: Nat}
type Registered<S: Data,C: Type,R: Type,E: Data,F: Data,-select: E -> Maybe<&2,Record<S,F>>> is Type:
  Registered{world: W.World<S,C,R,E>,reader: Reader<S,E,F,select>}
  Rejected{world: W.World<S,C,R,E>}
type Run<S: Data,C: Type,R: Type,E: Data,F: Data,-select: E -> Maybe<&2,Record<S,F>>,Error: Data,Out: Type> is Type:
  Completed{reader: Reader<S,E,F,select>,outcome: Sys.Outcome<W.World<S,C,R,E>,Error,Out>}
  Invalid{reader: Reader<S,E,F,select>,world: W.World<S,C,R,E>}

type Disposal<S: Data,C: Type,R: Type,E: Data,F: Data,-select: E -> Maybe<&2,Record<S,F>>> is Type:
  Disposed{world: W.World<S,C,R,E>}
  DisposalRejected{world: W.World<S,C,R,E>,reader: Reader<S,E,F,select>}

def count(~E: Data,xs: List<&2,E>) -> Nat:
  match xs:
    case []: 0n
    case _ <> rest: 1n+count(~E,rest)

def include(~S: Data,~F: Data,item: Maybe<&2,Record<S,F>>,rest: List<&2,Record<S,F>>) -> List<&2,Record<S,F>>:
  match item:
    case None{}: rest
    case Some{value}: value <> rest

def since(~S: Data,~E: Data,~F: Data,~select: E -> Maybe<&2,Record<S,F>>,xs: List<&2,E>,cursor: Nat) -> List<&2,Record<S,F>>:
  match xs cursor:
    case [] _: []
    case _ <> rest 1n+p: since(~S,~E,~F,~select,rest,p)
    case value <> rest 0n: include(~S,~F,select(value),since(~S,~E,~F,~select,rest,0n))

def register_result(~S: Data,~C: Type,~R: Type,~E: Data,~F: Data,~select: E -> Maybe<&2,Record<S,F>>,registered: W.World<S,C,R,E> & W.Registration,+namespace: U32,+name: String,cursor: Nat) -> Registered<S,C,R,E,F,select>:
  match registered:
    case (world,W.Registered{id}): Registered{world,Reader{namespace,id,name,cursor}}
    case (world,W.RegistrationRejected{_}): Rejected{world}

def register_view(~S: Data,~C: Type,~R: Type,~E: Data,~F: Data,~select: E -> Maybe<&2,Record<S,F>>,viewed: W.World<S,C,R,E> & List<&2,E>,+namespace: U32,+name: String) -> Registered<S,C,R,E,F,select>:
  (world,values) = viewed
  register_result(~S,~C,~R,~E,~F,~select,W.register(~S,~C,~R,~E,world,name,["removal",name]),namespace,name,0n)

def register_named(~S: Data,~C: Type,~R: Type,~E: Data,~F: Data,~select: E -> Maybe<&2,Record<S,F>>,named: W.World<S,C,R,E> & U32,+name: String) -> Registered<S,C,R,E,F,select>:
  (world,+namespace) = named
  register_view(~S,~C,~R,~E,~F,~select,W.events_view(~S,~C,~R,~E,world),namespace,name)

def register(~S: Data,~C: Type,~R: Type,~E: Data,~F: Data,~select: E -> Maybe<&2,Record<S,F>>,world: W.World<S,C,R,E>,name: String) -> Registered<S,C,R,E,F,select>:
  register_named(~S,~C,~R,~E,~F,~select,W.namespace(~S,~C,~R,~E,world),name)

def finished(~S: Data,~C: Type,~R: Type,~E: Data,~F: Data,~select: E -> Maybe<&2,Record<S,F>>,~Error: Data,~Out: Type,reader: Reader<S,E,F,select>,next: Nat,outcome: Sys.Outcome<W.World<S,C,R,E>,Error,Out>) -> Run<S,C,R,E,F,select,Error,Out>:
  match reader outcome:
    case reader Sys.Failed{world,error}: Completed{reader,Sys.Failed{world,error}}
    case Reader{namespace,id,name,_} Sys.Succeeded{world,out}: Completed{Reader{namespace,id,name,next},Sys.Succeeded{world,out}}

def consumed(~S: Data,~C: Type,~R: Type,~E: Data,~F: Data,~select: E -> Maybe<&2,Record<S,F>>,~Error: Data,~Out: Type,reader: Reader<S,E,F,select>,next: Nat,world: W.World<S,C,R,E>,result: Result<&2,&1,Error,Out>) -> Run<S,C,R,E,F,select,Error,Out>:
  match result:
    case Done{out}: finished(~S,~C,~R,~E,~F,~select,~Error,~Out,reader,next,Sys.Succeeded{world,out})
    case Fail{error}: finished(~S,~C,~R,~E,~F,~select,~Error,~Out,reader,next,Sys.Failed{world,error})

def viewed(~S: Data,~C: Type,~R: Type,~E: Data,~F: Data,~select: E -> Maybe<&2,Record<S,F>>,~Error: Data,~Out: Type,~consume: List<&2,Record<S,F>> -> Result<&2,&1,Error,Out>,reader: Reader<S,E,F,select>,cursor: Nat,viewed: W.World<S,C,R,E> & List<&2,E>) -> Run<S,C,R,E,F,select,Error,Out>:
  (world,+values) = viewed
  result = consume(since(~S,~E,~F,~select,values,cursor))
  consumed(~S,~C,~R,~E,~F,~select,~Error,~Out,reader,count(~E,values),world,result)

def checked(~S: Data,~C: Type,~R: Type,~E: Data,~F: Data,~select: E -> Maybe<&2,Record<S,F>>,~Error: Data,~Out: Type,~consume: List<&2,Record<S,F>> -> Result<&2,&1,Error,Out>,allowed: Bool,reader: Reader<S,E,F,select>,world: W.World<S,C,R,E>,cursor: Nat) -> Run<S,C,R,E,F,select,Error,Out>:
  match allowed:
    case False{}: Invalid{reader,world}
    case True{}: viewed(~S,~C,~R,~E,~F,~select,~Error,~Out,~consume,reader,cursor,W.events_view(~S,~C,~R,~E,world))

def named(~S: Data,~C: Type,~R: Type,~E: Data,~F: Data,~select: E -> Maybe<&2,Record<S,F>>,~Error: Data,~Out: Type,~consume: List<&2,Record<S,F>> -> Result<&2,&1,Error,Out>,reader: Reader<S,E,F,select>,world: W.World<S,C,R,E>,actual: U32) -> Run<S,C,R,E,F,select,Error,Out>:
  match reader world:
    case Reader{+namespace,+id,+name,+cursor} W.World{+ns,nextId,highWater,live,capacity,depth,store,resource,events,pending,+registrations,nextSystemId,clock}:
      checked(~S,~C,~R,~E,~F,~select,~Error,~Out,~consume,Bool.and(U32.is_eq(namespace,actual),W.registration_list_matches(registrations,id,name,["removal",name])),Reader{namespace,id,name,cursor},W.World{ns,nextId,highWater,live,capacity,depth,store,resource,events,pending,registrations,nextSystemId,clock},cursor)

def run(~S: Data,~C: Type,~R: Type,~E: Data,~F: Data,~select: E -> Maybe<&2,Record<S,F>>,~Error: Data,~Out: Type,~consume: List<&2,Record<S,F>> -> Result<&2,&1,Error,Out>,reader: Reader<S,E,F,select>,world: W.World<S,C,R,E>) -> Run<S,C,R,E,F,select,Error,Out>:
  match world:
    case W.World{+ns,nextId,highWater,live,capacity,depth,store,resource,events,pending,registrations,nextSystemId,clock}: named(~S,~C,~R,~E,~F,~select,~Error,~Out,~consume,reader,W.World{ns,nextId,highWater,live,capacity,depth,store,resource,events,pending,registrations,nextSystemId,clock},ns)

# Skipped removal readers keep their original cursor; unlike ordinary events.
def skip(~S: Data,~E: Data,~F: Data,~select: E -> Maybe<&2,Record<S,F>>,reader: Reader<S,E,F,select>) -> Reader<S,E,F,select>:
  reader

def removal_access(access: List<&2,String>) -> Bool:
  match access:
    case []: False{}
    case first <> _: String.eq(first,"removal")

def readers_remain(entries: List<&2,W.RegistrationMeta>) -> Bool:
  match entries:
    case []: False{}
    case W.RegistrationMeta{_,_,access} <> rest: Bool.or(removal_access(access),readers_remain(rest))

def collect_checked(~S: Data,~C: Type,~R: Type,~E: Data,retain: Bool,world: W.World<S,C,R,E>) -> W.World<S,C,R,E>:
  match retain world:
    case True{} world: world
    case False{} W.World{namespace,nextId,highWater,live,capacity,depth,store,resource,_,pending,registrations,nextSystemId,clock}: W.World{namespace,nextId,highWater,live,capacity,depth,store,resource,[],pending,registrations,nextSystemId,clock}

def collected(~S: Data,~C: Type,~R: Type,~E: Data,result: W.World<S,C,R,E> & Bool) -> W.World<S,C,R,E> & Bool:
  match result:
    case (world,False{}): (world,False{})
    case (W.World{namespace,nextId,highWater,live,capacity,depth,store,resource,events,pending,+registrations,nextSystemId,clock},True{}): (collect_checked(~S,~C,~R,~E,readers_remain(registrations),W.World{namespace,nextId,highWater,live,capacity,depth,store,resource,events,pending,registrations,nextSystemId,clock}),True{})

def disposal_collected(~S: Data,~C: Type,~R: Type,~E: Data,~F: Data,~select: E -> Maybe<&2,Record<S,F>>,result: W.World<S,C,R,E> & Bool) -> Disposal<S,C,R,E,F,select>:
  (world,removed) = result
  Disposed{world}

def disposal_result(~S: Data,~C: Type,~R: Type,~E: Data,~F: Data,~select: E -> Maybe<&2,Record<S,F>>,reader: Reader<S,E,F,select>,result: W.World<S,C,R,E> & Bool) -> Disposal<S,C,R,E,F,select>:
  match result:
    case (world,False{}): DisposalRejected{world,reader}
    case (world,True{}): disposal_collected(~S,~C,~R,~E,~F,~select,collected(~S,~C,~R,~E,(world,True{})))

# This owner is removal-only: ordinary event retention uses its own Runtime.
# Disposing the last registered reader releases the retained metadata log.
def dispose(~S: Data,~C: Type,~R: Type,~E: Data,~F: Data,~select: E -> Maybe<&2,Record<S,F>>,reader: Reader<S,E,F,select>,world: W.World<S,C,R,E>) -> Disposal<S,C,R,E,F,select>:
  match reader:
    case Reader{+namespace,+id,+name,+cursor}: disposal_result(~S,~C,~R,~E,~F,~select,Reader{namespace,id,name,cursor},Registration.remove(~S,~C,~R,~E,world,namespace,id,name,["removal",name]))
