import Base
import ./declarations.bend as D
import ./payloads.bend as P
import ./bodies.bend as Body
import ./actor.bend as Actor
import ./peer.bend as Peer
import ./exit.bend as Exit
import ./events.bend as Events
import ./registry.bend as Registry
import ./guard-registry.bend as Guards
import ./observation.bend as Observe
import ../../src/ecs/world.bend as W
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-command-system.bend as Cmd
import ../../src/ecs/execution-command-local.bend as Commands
import ../../src/ecs/execution-command-buffer.bend as Buffer
import ../../src/ecs/execution-command-removed.bend as Removed
import ../../src/ecs/execution-command-permission.bend as Permission
import ../../src/ecs/dependency-registration.bend as Reg
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/change-tick.bend as Tick
import ../../src/ecs/execution-reservation-bundle.bend as Bundle

def metadata(namespace:U32,id:U32,name:String,access:List<&2,String>,cursor:Maybe<&2,Tick.Tick>,local:String) -> String:
  U32.show(namespace) ++ ":" ++ U32.show(id) ++ ":" ++ name ++ ":access=" ++ List.show(&2,String,Observe.text,access) ++ ":cursor=" ++ Tick.cursor_show(cursor) ++ ":local=" ++ local
def apply(~S:Data,value:Registry.ApplyOwner(~S)) -> String:
  match value:
    case Sys.Owner{namespace,id,name,access,cursor,local}:metadata(namespace,id,name,access,cursor,Observe.local(local))
def read(~S:Data,value:Registry.ReadOwner(~S)) -> String:
  match value:
    case Sys.Owner{namespace,id,name,access,cursor,local}:metadata(namespace,id,name,access,cursor,Observe.local(local))
def enter(~S:Data,value:Registry.RequestOwner(~S)) -> String:
  match value:
    case Sys.Owner{namespace,id,name,access,cursor,local}:metadata(namespace,id,name,access,cursor,Observe.local(local))
def actor(~S:Data,value:Registry.ActorOwner(~S)) -> String:
  match value:
    case Sys.Owner{namespace,id,name,access,cursor,local}:metadata(namespace,id,name,access,cursor,Observe.actor_local(~S,local))
def events(~S:Data,value:Events.Owner(~S)) -> String:
  match value:
    case Sys.Owner{namespace,id,name,access,cursor,local}:metadata(namespace,id,name,access,cursor,Observe.events_local(~S,local))
def peer(~S:Data,value:Peer.Owner(~S)) -> String:
  match value:
    case Sys.Owner{namespace,id,name,access,cursor,local}:metadata(namespace,id,name,access,cursor,Observe.peer_local(~S,local))
def guard(~S:Data,value:Guards.Owner(~S)) -> String:
  match value:
    case Sys.Owner{namespace,id,name,access,cursor,local}:metadata(namespace,id,name,access,cursor,Observe.condition(local))
def permission(value:Permission.Permission) -> String:
  match value:
    case Permission.FamilyOnly{}:"family"
    case Permission.EntityStructural{}:"entity"
def user(~S:Data,value:Exit.User<S>) -> String:
  match value:
    case Exit.User{handle,retained}:Observe.handle(~S,handle) ++ ":" ++ Observe.local(retained)
def spawn_refusal(value:Bundle.Refusal) -> String:
  match value:
    case Bundle.InvalidPending{W.MissingEntity{}}:"invalid-pending/missing-entity"
    case Bundle.InvalidPending{W.ReservationUnauthorized{}}:"invalid-pending/reservation-unauthorized"
    case Bundle.InvalidPending{W.CapacityExceeded{}}:"invalid-pending/capacity-exceeded"
    case Bundle.InvalidPending{W.NamespaceExhausted{}}:"invalid-pending/namespace-exhausted"
    case Bundle.InvalidPending{W.SystemIdExhausted{}}:"invalid-pending/system-id-exhausted"
    case Bundle.PermissionDenied{}:"permission-denied"
    case Bundle.DuplicateFamily{}:"duplicate-family"
    case Bundle.PhysicalIndex{}:"physical-index"
    case Bundle.MalformedColumn{key}:"malformed-column/" ++ key
    case Bundle.OccupiedFamily{key}:"occupied-family/" ++ key
def removed(~S:Data,value:Removed.Removed(D.component_layout(~S))) -> String:
  match value:
    case Product.Owner{left,right}:Observe.maybe_actor(~S,left) ++ "/" ++ Observe.maybe_peer(~S,right)

def pending_entry(~S:Data,value:Buffer.Entry<S,P.Actor<S,D.Mode>,Removed.Removed(D.component_layout(~S))>) -> String:
  match value:
    case Buffer.Entry{handle,incoming}:"family:" ++ Observe.handle(~S,handle) ++ ":" ++ Observe.maybe_actor(~S,incoming)
    case Buffer.Despawn{handle}:"despawn:" ++ Observe.handle(~S,handle)
    case Buffer.Spawn{handle,bundle}:"spawn:" ++ Observe.handle(~S,handle) ++ ":" ++ removed(~S,bundle)
def receipt(~S:Data,value:Buffer.Receipt<S,P.Actor<S,D.Mode>,Removed.Removed(D.component_layout(~S))>) -> String:
  match value:
    case Buffer.Applied{handle,previous}:"applied:" ++ Observe.handle(~S,handle) ++ ":" ++ Observe.maybe_actor(~S,previous)
    case Buffer.Refused{handle,incoming}:"refused:" ++ Observe.handle(~S,handle) ++ ":" ++ Observe.maybe_actor(~S,incoming)
    case Buffer.Despawned{handle,owners}:"despawned:" ++ Observe.handle(~S,handle) ++ ":" ++ removed(~S,owners)
    case Buffer.DespawnRefused{handle}:"despawn-refused:" ++ Observe.handle(~S,handle)
    case Buffer.Spawned{handle,previous}:"spawned:" ++ Observe.handle(~S,handle) ++ ":" ++ removed(~S,previous)
    case Buffer.SpawnRefused{handle,bundle,reason}:"spawn-refused:" ++ Observe.handle(~S,handle) ++ ":" ++ removed(~S,bundle) ++ ":" ++ spawn_refusal(reason)
def buffer(~S:Data,value:Buffer.Buffer<S,P.Actor<S,D.Mode>,Removed.Removed(D.component_layout(~S))>) -> String:
  match value:
    case Buffer.Buffer{pending,receipts}:"pending=" ++ List.show(&1,Buffer.Entry<S,P.Actor<S,D.Mode>,Removed.Removed(D.component_layout(~S))>,pending_entry(~S),pending) ++ "/receipts=" ++ List.show(&1,Buffer.Receipt<S,P.Actor<S,D.Mode>,Removed.Removed(D.component_layout(~S))>,receipt(~S),receipts)
def captures(~S:Data,value:Exit.Captures(~S)) -> String:
  match value:
    case Commands.Local{owner,commands,grant}:user(~S,owner) ++ "/permission=" ++ permission(grant) ++ "/" ++ buffer(~S,commands)
def exit(~S:Data,value:Exit.Owner(~S)) -> String:
  match value:
    case Cmd.Owner{Sys.Owner{namespace,id,name,access,cursor,local}}:metadata(namespace,id,name,access,cursor,captures(~S,local))
def left(~S:Data,value:Registry.Owners(~S)) -> String:
  match value:
    case Product.Owner{marker,Product.Owner{onExit,Product.Owner{transition,Product.Owner{onEnter,Product.Owner{state,reader}}}}}:"apply{" ++ apply(~S,marker) ++ "};exit{" ++ exit(~S,onExit) ++ "};transition{" ++ read(~S,transition) ++ "};enter{" ++ enter(~S,onEnter) ++ "};actor{" ++ actor(~S,state) ++ "};events{" ++ events(~S,reader) ++ "}"
def guard_pair(~S:Data,value:Guards.GuardPair(~S)) -> String:
  match value:
    case Reg.Product{left,right,ids}:"ids=" ++ List.show(&2,U32,U32.show,ids) ++ "{" ++ guard(~S,left) ++ ";" ++ guard(~S,right) ++ "}"
def guards(~S:Data,value:Guards.Owners(~S)) -> String:
  match value:
    case Reg.Product{left,right,ids}:"ids=" ++ List.show(&2,U32,U32.show,ids) ++ "{" ++ guard_pair(~S,left) ++ ";" ++ guard_pair(~S,right) ++ "}"
