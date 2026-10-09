import Base
import ./world.bend as W

# Remove exact registration identity, preserving every other system instance.
# IDs are monotonic and are not recycled by disposal.
def retained(keep: Bool,meta: W.RegistrationMeta,rest: List<&2,W.RegistrationMeta>) -> List<&2,W.RegistrationMeta>:
  match keep:
    case True{}: meta <> rest
    case False{}: rest

def without(registrations: List<&2,W.RegistrationMeta>,+id: U32,+name: String,+access: List<&2,String>) -> List<&2,W.RegistrationMeta>:
  match registrations:
    case []: []
    case +meta <> rest: retained(Bool.not(W.registration_meta_matches(meta,id,name,access)),meta,without(rest,id,name,access))

def remove_checked(~S: Data,~Store: Type,~R: Type,~E: Data,allowed: Bool,world: W.World<S,Store,R,E>,+id: U32,+name: String,+access: List<&2,String>) -> W.World<S,Store,R,E> & Bool:
  match allowed world:
    case False{} world: (world,False{})
    case True{} W.World{namespace,nextId,highWater,live,capacity,depth,store,resource,events,pending,registrations,nextSystemId,clock}: (W.World{namespace,nextId,highWater,live,capacity,depth,store,resource,events,pending,without(registrations,id,name,access),nextSystemId,clock},True{})

def remove(~S: Data,~Store: Type,~R: Type,~E: Data,world: W.World<S,Store,R,E>,namespace: U32,+id: U32,+name: String,+access: List<&2,String>) -> W.World<S,Store,R,E> & Bool:
  match world:
    case W.World{+actual,nextId,highWater,live,capacity,depth,store,resource,events,pending,+registrations,nextSystemId,clock}: remove_checked(~S,~Store,~R,~E,Bool.and(U32.is_eq(namespace,actual),W.registration_list_matches(registrations,id,name,access)),W.World{actual,nextId,highWater,live,capacity,depth,store,resource,events,pending,registrations,nextSystemId,clock},id,name,access)
