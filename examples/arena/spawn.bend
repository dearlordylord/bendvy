import Base
import ./schema.bend as D
import ./gameplay.bend as V
import ./system.bend as Decay
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/execution-composer-layout.bend as L
import ../../src/ecs/execution-command-system.bend as Cmd
import ../../src/ecs/execution-command-local.bend as Local
import ../../src/ecs/execution-command-permission.bend as Permission
import ../../src/ecs/execution-command-buffer.bend as Buffer
import ../../src/ecs/execution-command-removed.bend as Removed
import ../../src/ecs/execution-builder.bend as Build
import ../../src/ecs/execution-resource-program.bend as Program
import ../../src/ecs/execution-declaration.bend as Decl
import ../../src/ecs/execution-reservation-task.bend as Task
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-generalized-command-leaf.bend as Author
import ../../src/ecs/world.bend as W

def route() -> L.Route:L.AtLeaf{}
def Ops(Permit:Data,H:Type,Q:Type) -> Type:Permission.EntityCommands<Q,D.Schema,D.components(),Permit>
type User is Type:
  User{seeds:List<&2,V.Body>,handles:List<&2,W.Handle<D.Schema>>,returned:List<Removed.Removed(D.components())>}
def granted(~Permit:Data,~H:Type,~Q:Type,-B:Type,-K:Type,book:B,result:K & Ops(Permit,H,Q)) -> B & (K & Ops(Permit,H,Q)):(book,result)
def declaration(~Permit:Data,~H:Type,~Q:Type,~commands:Local.Commands<Q,D.Schema,V.Body>,~B:Type,~builder:Build.Builder(~D.Schema,~D.Columns(),~Decay.C(),~Decay.R(),~Permit,~H,~B),~K:Type,~entity:Permission.Grant(~D.Schema,~D.components(),~Permit,~Q,~K),~relations:Permission.RelationGrant(~D.Schema,~D.resources(),~Q,~K),~scopes:Permission.ScopeGrant(~D.Schema,~D.resources(),~Q,~K),book:B,permission:K) -> B & (K & Ops(Permit,H,Q)):
  granted(~Permit,~H,~Q,B,K,book,Permission.entity(~D.Schema,~D.components(),~Permit,~Q,~K,~entity,permission))
def admitted(~Permit:Data,~H:Type,~Q:Type,next:H -> Q -> List<&2,W.Handle<D.Schema>> -> Task.Task<D.Schema,Permit,H & (Q & (User & Sys.Completion<String,Unit>))>,scope:H,remaining:List<&2,V.Body>,handles:List<&2,W.Handle<D.Schema>>,result:Q & Buffer.SpawnAdmission<D.Schema,Removed.Removed(D.components())>) -> Task.Task<D.Schema,Permit,H & (Q & (User & Sys.Completion<String,Unit>))>:
  match result:
    case (queue,Buffer.SpawnQueued{handle}):next(scope,queue,List.append(&2,W.Handle<D.Schema>,handles,[handle]))
    case (queue,Buffer.SpawnRejected{bundle,_}):Task.TDone{(scope,(queue,(User{remaining,handles,[bundle]},Sys.BodyError{"spawn reservation refused",Unit{}})))}
def seeded(~Permit:Data,~H:Type,~Q:Type,seeds:List<&2,V.Body>,scope:H,queue:Q,handles:List<&2,W.Handle<D.Schema>>) -> Task.Task<D.Schema,Permit,H & (Q & (User & Sys.Completion<String,Unit>))>:
  Task.TDone{(scope,(queue,(User{seeds,handles,[]},Sys.Success{Unit{}})))}
def queue_seeds(~Permit:Data,~H:Type,~Q:Type,~spawn:Q -> Removed.Removed(D.components()) -> Task.Task<D.Schema,Permit,Q & Buffer.SpawnAdmission<D.Schema,Removed.Removed(D.components())>>,seeds:List<&2,V.Body>,scope:H,queue:Q,handles:List<&2,W.Handle<D.Schema>>) -> Task.Task<D.Schema,Permit,H & (Q & (User & Sys.Completion<String,Unit>))>:
  match seeds:
    case []:seeded(~Permit,~H,~Q,[],scope,queue,handles)
    case seed <> +rest:Task.bind(D.Schema,Permit,Q & Buffer.SpawnAdmission<D.Schema,Removed.Removed(D.components())>,H & (Q & (User & Sys.Completion<String,Unit>)),spawn(queue,Some{seed}),result => admitted(~Permit,~H,~Q,scope => queue => handles => queue_seeds(~Permit,~H,~Q,~spawn,rest,scope,queue,handles),scope,rest,handles,result))
def body(~Permit:Data,~H:Type,~Q:Type,~caps:Ops(Permit,H,Q),~commands:Local.Commands<Q,D.Schema,V.Body>,scope:H,queue:Q,user:User) -> Task.Task<D.Schema,Permit,H & (Q & (User & Sys.Completion<String,Unit>))>:
  match user:
    case User{seeds,handles,[]}:queue_seeds(~Permit,~H,~Q,~Permission.spawn_field(~Q,~D.Schema,~D.components(),~Permit,caps),seeds,scope,queue,handles)
    case user:Task.TDone{(scope,(queue,(user,Sys.BodyError{"spawn bundle retained after refusal",Unit{}})))}
def kernel(~Permit:Data,~token:Permit,~H:Type,~B:Type,~builder:Build.Builder(~D.Schema,~D.Columns(),~Decay.C(),~Decay.R(),~Permit,~H,~B),book:B) -> B & Cmd.ScopedOps(~D.Schema,~D.components(),~D.resources(),~route(),~Ops,Permit,H):
  Cmd.program_for_buffer(~D.Schema,~Decay.C(),~Decay.R(),~D.components(),~D.resources(),~route(),~Ops,~declaration,~Permit,~token,~H,~B,~builder,book)
def compilation() -> Decl.Compilation<D.Schema,D.Columns(),Decay.C(),Decay.R(),Cmd.ScopedOps(~D.Schema,~D.components(),~D.resources(),~route(),~Ops)>:
  Program.compile_framework(~D.Schema,~D.Columns(),~Decay.C(),~Decay.R(),~Cmd.ScopedOps(~D.Schema,~D.components(),~D.resources(),~route(),~Ops),~kernel)
def Node() -> Type:Author.Node(~D.Schema,~D.components(),~D.resources(),~Unit,~route(),~Ops,~User,~String,~Unit,~declaration,~body)
