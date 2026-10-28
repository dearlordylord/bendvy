import Base
import ./actor.bend as Actor
import ./setup.bend as Scene
import ../../src/ecs/world.bend as W
import ../../src/ecs/execution-builder.bend as Build
import ../../src/ecs/execution-composer-layout.bend as Layout
import ../../src/ecs/execution-command-local.bend as Local
import ../../src/ecs/execution-command-permission.bend as Permission
import ../../src/ecs/execution-command-system.bend as Cmd
import ../../src/ecs/execution-reservation-task.bend as Task
import ../../src/ecs/execution-system.bend as Sys

def R(~S:Data) -> Type:Layout.resources(~S,Scene.right_resources(~S,~Actor.Session,~U32,~Actor.project))
def Ops(~S:Data,Permit:Data,H:Type,Q:Type) -> Type:Permission.EntityCommands<Q,S,Actor.components(),Permit>
def declaration(~S:Data,~Permit:Data,~H:Type,~Q:Type,~commands:Local.Commands<Q,S,Actor.Session>,~B:Type,~builder:Build.Builder(~S,~Layout.columns(~S,Actor.components()),~Unit,~R(~S),~Permit,~H,~B),~K:Type,~entity:Permission.Grant(~S,~Actor.components(),~Permit,~Q,~K),~relations:Permission.RelationGrant(~S,~Actor.resources(~S),~Q,~K),~scopes:Permission.ScopeGrant(~S,~Actor.resources(~S),~Q,~K),book:B,permissions:K) -> B & (K & Ops(~S,Permit,H,Q)):
  (book,Permission.entity(~S,~Actor.components(),~Permit,~Q,~K,~entity,permissions))
def queued(~S:Data,~Permit:Data,~H:Type,~Q:Type,~despawn:Q -> W.Handle<S> -> Q,scope:H,queue:Q,handle:W.Handle<S>) -> Task.Task<S,Permit,H & (Q & (W.Handle<S> & Sys.Completion<String,String>))>:
  match handle:
    case +handle:Task.TDone{(scope,(despawn(despawn(queue,handle),handle),(handle,Sys.BodyError{"despawn-only author error","schema cleanup queued"})))}
def body(~S:Data,~Permit:Data,~H:Type,~Q:Type,~caps:Ops(~S,Permit,H,Q),~commands:Local.Commands<Q,S,Actor.Session>,scope:H,queue:Q,handle:W.Handle<S>) -> Task.Task<S,Permit,H & (Q & (W.Handle<S> & Sys.Completion<String,String>))>:
  queued(~S,~Permit,~H,~Q,~Permission.despawn_field(~Q,~S,~Actor.components(),~Permit,caps),scope,queue,handle)
def Owner(~S:Data) -> Type:Cmd.Owner<S,Unit,R(~S),Unit,Actor.components(),Actor.resources(~S),Actor.route(),Ops(~S),W.Handle<S>,String,String,declaration(~S),body(~S)>
