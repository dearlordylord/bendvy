import Base
import ./spawn.bend as S
import ./spawn-identity-observation.bend as ObserveIdentity
import ../../src/ecs/execution-lifetime-scope-description.bend as LinkedText
import ../../src/ecs/execution-reservation-task.bend as Effect
import ../../src/ecs/execution-command-permission.bend as Permission
import ../../src/ecs/execution-command-removed.bend as Removed
import ./controls/positive.bend as P
import ./controls/registered.bend as Registered
import ../../src/ecs/world.bend as W
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-builder.bend as Build
import ../../src/ecs/execution-command-system.bend as Cmd
import ../../src/ecs/execution-command-local.bend as Local
import ../../src/ecs/execution-command-buffer.bend as Buffer
import ../../src/ecs/execution-reservation-bundle.bend as Bundle
import ../../src/ecs/trace-world.bend as Trace
import ../../src/ecs/execution-composer-layout.bend as Layout
import ../../src/ecs/execution-resource-policy.bend as Policy
import ../../src/ecs/execution-parallel-system.bend as Task
import ../../src/ecs/execution-parallel-scope-registry.bend as Tree
import ../../src/ecs/execution-parallel-rootcut.bend as Root
import ../../src/ecs/execution-parallel-root-application.bend as Schedule
import ../../src/ecs/execution-deferred-settings.bend as Settings
import ../../src/ecs/dependency-application.bend as DepApp
import ../../src/ecs/dependency-registration.bend as Reg
import ../../src/ecs/execution-condition-registry.bend as Conditions
import ../../src/ecs/dependency-executor.bend as Exec
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/chunk-column.bend as Column
import ../../src/ecs/change-tick.bend as Tick
import ../../src/ecs/deferred-command.bend as Deferred
import ../../test-fixtures/common/column-observation.bend as Observe

def local_layout() -> Layout.Layout:Layout.LayoutPair{Registered.layout(),Layout.LayoutLeaf{S.Parcel,String,S.parcel_refresh,"parcel",Policy.Ordinary{}}}
def layout() -> Layout.Layout:Layout.LayoutPair{local_layout(),Layout.EmptyLayout{}}
def path() -> Layout.Route:Layout.InLeft{Layout.InLeft{Layout.AtLeaf{}}}
def Left() -> Type:Layout.columns(~S.Schema,local_layout())
def Store() -> Type:Layout.columns(~S.Schema,layout())
def Resources() -> Type:Product.Owner<Unit,Unit>
def resources() -> Layout.Layout:Layout.LayoutPair{Layout.EmptyLayout{},Layout.EmptyLayout{}}
def Ops(Permit:Data,H:Type) -> Type:Unit
def CmdOps(Permit:Data,H:Type,Q:Type) -> Type:Permission.EntityCommands<Q,S.Schema,layout(),Permit>
def author_granted(~Permit:Data,~H:Type,~Q:Type,~B:Type,~K:Type,book:B,result:K & CmdOps(Permit,H,Q)) -> B & (K & CmdOps(Permit,H,Q)):
  match result:
    case (permission,caps):(book,(permission,caps))
def author_declaration(~Permit:Data,~H:Type,~Q:Type,~commands:Local.Commands<Q,S.Schema,P.Token>,~B:Type,~builder:Build.Builder(~S.Schema,~Store(),~Left(),~Unit,~Permit,~H,~B),~K:Type,~entity:Permission.Grant(~S.Schema,~layout(),~Permit,~Q,~K),~relations:Permission.RelationGrant(~S.Schema,~resources(),~Q,~K),~scopes:Permission.ScopeGrant(~S.Schema,~resources(),~Q,~K),book:B,permission:K) -> B & (K & CmdOps(Permit,H,Q)):
  author_granted(~Permit,~H,~Q,~B,~K,book,Permission.entity(~S.Schema,~layout(),~Permit,~Q,~K,~entity,permission))

def peer_declaration(~Permit:Data,~H:Type,~B:Type,~builder:Build.Builder(~S.Schema,~Store(),~Unit,~Unit,~Permit,~H,~B),book:B) -> B & Unit:
  (book,Unit{})
def peer_written(~H:Type,scope:H,result:Array<U32> & U32) -> H & (Array<U32> & Sys.Completion<String,Unit>):
  match result:
    case (token,_):(scope,(token,Sys.Success{Unit{}}))
def peer_seen(~H:Type,scope:H,result:Array<U32> & U32) -> H & (Array<U32> & Sys.Completion<String,Unit>):
  match result:
    case (token,value):peer_written(~H,scope,Array.swap(U32,token,0,U32.add(value,1)))
def peer_body_sync(~Permit:Data,~H:Type,~caps:Unit,scope:H,token:Array<U32>) -> H & (Array<U32> & Sys.Completion<String,Unit>):
  peer_seen(~H,scope,Array.get(U32,token,0))

def peer_body(~Permit:Data,~H:Type,~caps:Unit,scope:H,token:Array<U32>) -> Effect.Task<S.Schema,Permit,H & (Array<U32> & Sys.Completion<String,Unit>)>:
  Effect.TRun{_ => Effect.TDone{peer_body_sync(~Permit,~H,~caps,scope,token)}}

type Action is Data:
  Spawn{value:U32}
  Erase{index:Nat}
  Write{index:Nat,value:U32}
  ForeignWrite{}
  ForeignErase{}
  SpawnErase{value:U32}
type AuthorLocal is Type:
  AuthorLocal{phase:U32,handles:List<&2,W.Handle<S.Schema>>,foreign:W.Handle<S.Schema>,rejected:List<Removed.Removed(layout())>,reasons:List<&2,W.WorldError>}
def bundle(+value:U32) -> Removed.Removed(layout()):
  Product.Owner{Product.Owner{Some{P.Token{ALeaf{value}}},Some{S.Parcel{ALeaf{"parcel-" ++ U32.show(value)}}}},Unit{}}
def target(index:Nat,handles:List<&2,W.Handle<S.Schema>>) -> Maybe<&2,W.Handle<S.Schema>>:
  match index handles:
    case _ Nil{}:None{}
    case 0n handle <> _:Some{handle}
    case 1n+rest _ <> tail:target(rest,tail)
def actions(phase:U32) -> List<&2,Action>:
  match phase:
    case 0:[Spawn{100},Spawn{200}]
    case 2:[Erase{0n},Spawn{300}]
    case 4:[Spawn{400}]
    case 5:[Write{0n,900},Erase{0n},ForeignWrite{},ForeignErase{}]
    case 6:[SpawnErase{500}]
    case 7:[Spawn{100},Spawn{200},Spawn{300},Spawn{400},Spawn{500},Spawn{600},Spawn{700},Spawn{800}]
    case 9:[Spawn{1000}]
    case 10:[Spawn{131072},Spawn{131073}]
    case _:[]
def completed(phase:U32) -> Sys.Completion<String,Unit>:
  match phase:
    case 1:Sys.Success{Unit{}}
    case 3:Sys.Success{Unit{}}
    case 8:Sys.Success{Unit{}}
    case _:Sys.BodyError{"after-actions",Unit{}}
def erase_if(~Q:Type,~erase:Q -> W.Handle<S.Schema> -> Q,queue:Q,handle:W.Handle<S.Schema>,enabled:Bool) -> Q:
  match enabled:
    case False{}:queue
    case True{}:erase(queue,handle)
def spawn_join(~Permit:Data,~H:Type,~Q:Type,~erase:Q -> W.Handle<S.Schema> -> Q,eraseAfter:Bool,next:H -> Q -> AuthorLocal -> Effect.Task<S.Schema,Permit,H & (Q & (AuthorLocal & Sys.Completion<String,Unit>))>,scope:H,user:AuthorLocal,result:Q & Buffer.SpawnAdmission<S.Schema,Removed.Removed(layout())>) -> Effect.Task<S.Schema,Permit,H & (Q & (AuthorLocal & Sys.Completion<String,Unit>))>:
  match user result:
    case AuthorLocal{phase,handles,foreign,rejected,reasons} Tuple{queue,Buffer.SpawnQueued{+handle}}:next(scope,erase_if(~Q,~erase,queue,handle,eraseAfter),AuthorLocal{phase,List.append(&2,W.Handle<S.Schema>,handles,[handle]),foreign,rejected,reasons})
    case AuthorLocal{phase,handles,foreign,rejected,reasons} Tuple{queue,Buffer.SpawnRejected{bundle,error}}:next(scope,queue,AuthorLocal{phase,handles,foreign,bundle <> rejected,error <> reasons})
def write_or_erase(~Q:Type,~insert:Q -> W.Handle<S.Schema> -> P.Token -> Q,~erase:Q -> W.Handle<S.Schema> -> Q,queue:Q,handle:W.Handle<S.Schema>,value:Maybe<&2,U32>) -> Q:
  match value:
    case None{}:erase(queue,handle)
    case Some{value}:insert(queue,handle,P.Token{ALeaf{value}})
def target_join(~Permit:Data,~H:Type,~Q:Type,~insert:Q -> W.Handle<S.Schema> -> P.Token -> Q,~erase:Q -> W.Handle<S.Schema> -> Q,next:H -> Q -> AuthorLocal -> Effect.Task<S.Schema,Permit,H & (Q & (AuthorLocal & Sys.Completion<String,Unit>))>,scope:H,queue:Q,user:AuthorLocal,value:Maybe<&2,U32>,found:Maybe<&2,W.Handle<S.Schema>>) -> Effect.Task<S.Schema,Permit,H & (Q & (AuthorLocal & Sys.Completion<String,Unit>))>:
  match found:
    case None{}:Effect.TDone{(scope,(queue,(user,Sys.BodyError{"missing-handle",Unit{}})))}
    case Some{handle}:next(scope,write_or_erase(~Q,~insert,~erase,queue,handle,value),user)
def actions_done(~Permit:Data,~H:Type,~Q:Type,scope:H,queue:Q,user:AuthorLocal) -> Effect.Task<S.Schema,Permit,H & (Q & (AuthorLocal & Sys.Completion<String,Unit>))>:
  match user:
    case AuthorLocal{+phase,handles,foreign,rejected,reasons}:Effect.TDone{(scope,(queue,(AuthorLocal{U32.add(phase,1),handles,foreign,rejected,reasons},completed(phase))))}
def run_actions(~Permit:Data,~H:Type,~Q:Type,~insert:Q -> W.Handle<S.Schema> -> P.Token -> Q,~erase:Q -> W.Handle<S.Schema> -> Q,~spawn:Q -> Removed.Removed(layout()) -> Effect.Task<S.Schema,Permit,Q & Buffer.SpawnAdmission<S.Schema,Removed.Removed(layout())>>,todo:List<&2,Action>,scope:H,queue:Q,user:AuthorLocal) -> Effect.Task<S.Schema,Permit,H & (Q & (AuthorLocal & Sys.Completion<String,Unit>))>:
  match todo:
    case Nil{}:actions_done(~Permit,~H,~Q,scope,queue,user)
    case action <> rest:
      match action user:
        case Spawn{value} AuthorLocal{phase,+handles,+foreign,rejected,reasons}:Effect.TBind{Q & Buffer.SpawnAdmission<S.Schema,Removed.Removed(layout())>,spawn(queue,bundle(value)),result => spawn_join(~Permit,~H,~Q,~erase,False{},scope => queue => user => run_actions(~Permit,~H,~Q,~insert,~erase,~spawn,rest,scope,queue,user),scope,AuthorLocal{phase,handles,foreign,rejected,reasons},result)}
        case SpawnErase{value} AuthorLocal{phase,+handles,+foreign,rejected,reasons}:Effect.TBind{Q & Buffer.SpawnAdmission<S.Schema,Removed.Removed(layout())>,spawn(queue,bundle(value)),result => spawn_join(~Permit,~H,~Q,~erase,True{},scope => queue => user => run_actions(~Permit,~H,~Q,~insert,~erase,~spawn,rest,scope,queue,user),scope,AuthorLocal{phase,handles,foreign,rejected,reasons},result)}
        case Erase{index} AuthorLocal{phase,+handles,+foreign,rejected,reasons}:target_join(~Permit,~H,~Q,~insert,~erase,scope => queue => user => run_actions(~Permit,~H,~Q,~insert,~erase,~spawn,rest,scope,queue,user),scope,queue,AuthorLocal{phase,handles,foreign,rejected,reasons},None{},target(index,handles))
        case Write{index,value} AuthorLocal{phase,+handles,+foreign,rejected,reasons}:target_join(~Permit,~H,~Q,~insert,~erase,scope => queue => user => run_actions(~Permit,~H,~Q,~insert,~erase,~spawn,rest,scope,queue,user),scope,queue,AuthorLocal{phase,handles,foreign,rejected,reasons},Some{value},target(index,handles))
        case ForeignWrite{} AuthorLocal{phase,+handles,+foreign,rejected,reasons}:run_actions(~Permit,~H,~Q,~insert,~erase,~spawn,rest,scope,insert(queue,foreign,P.Token{ALeaf{901}}),AuthorLocal{phase,handles,foreign,rejected,reasons})
        case ForeignErase{} AuthorLocal{phase,+handles,+foreign,rejected,reasons}:run_actions(~Permit,~H,~Q,~insert,~erase,~spawn,rest,scope,erase(queue,foreign),AuthorLocal{phase,handles,foreign,rejected,reasons})
def author_body(~Permit:Data,~H:Type,~Q:Type,~caps:CmdOps(Permit,H,Q),~commands:Local.Commands<Q,S.Schema,P.Token>,scope:H,queue:Q,user:AuthorLocal) -> Effect.Task<S.Schema,Permit,H & (Q & (AuthorLocal & Sys.Completion<String,Unit>))>:
  match user:
    case AuthorLocal{+phase,handles,foreign,rejected,reasons}:run_actions(~Permit,~H,~Q,~Local.insert_field(~Q,~S.Schema,~P.Token,commands),~Permission.despawn_field(~Q,~S.Schema,~layout(),~Permit,caps),~Permission.spawn_field(~Q,~S.Schema,~layout(),~Permit,caps),actions(phase),scope,queue,AuthorLocal{phase,handles,foreign,rejected,reasons})

def Author() -> Type:Cmd.Owner<S.Schema,Left(),Unit,Unit,layout(),resources(),path(),CmdOps,AuthorLocal,String,Unit,author_declaration,author_body>
def Peer() -> Type:Sys.Owner<S.Schema,Store(),Unit,Unit,Unit,Ops,Array<U32>,String,Unit,Build.framework_program(~S.Schema,~Store(),~Unit,~Unit,~Ops,~peer_declaration),peer_body>
def left(~F:Tree.Family(),~leaf:Tree.Leaf(~S.Schema,~Store(),~Left(),~Unit,~Unit,~resources(),~String,~Unit,~F),~command:Tree.CommandLeaf(~S.Schema,~Store(),~Left(),~Unit,~Unit,~resources(),~String,~Unit,~F),~join:Tree.Join(~F),owner:Author()) -> F(Author()):
  command(layout(),path(),{==},{==},CmdOps,AuthorLocal,author_declaration,author_body,owner)
def right(~F:Tree.Family(),~leaf:Tree.Leaf(~S.Schema,~Store(),~Unit,~Unit,~Unit,~resources(),~String,~Unit,~F),~command:Tree.CommandLeaf(~S.Schema,~Store(),~Unit,~Unit,~Unit,~resources(),~String,~Unit,~F),~join:Tree.Join(~F),owner:Peer()) -> F(Peer()):
  leaf(Ops,Array<U32>,Build.framework_program(~S.Schema,~Store(),~Unit,~Unit,~Ops,~peer_declaration),peer_body,owner)
type Handler is Type:
  Handler{token:Array<U32>,errors:U32}
def handle(handler:Handler,error:String) -> Handler & Exec.Handling:
  match handler:
    case Handler{token,errors}:(Handler{token,U32.add(errors,1)},Exec.Continue{})
def Application() -> Type:Schedule.Scheduled<DepApp.State<W.World<S.Schema,Store(),Resources(),Unit>,Product.Owner<Author(),Peer()>,Unit,Handler>>

def event(value:Exec.Observation<String,Unit>) -> String:
  match value:
    case Exec.Ran{id,_}:"ran:" ++ U32.show(id)
    case Exec.BodyFailed{id,error,_}:"error:" ++ U32.show(id) ++ ":" ++ error
    case Exec.Skipped{id}:"skip:" ++ U32.show(id)
    case Exec.AdmissionRejected{id}:"refused:" ++ U32.show(id)
    case Exec.ConditionFailed{id,error}:"condition-error:" ++ U32.show(id) ++ ":" ++ error
    case Exec.ConditionRejected{id}:"condition-refused:" ++ U32.show(id)
def report(value:DepApp.Report<String,Unit>) -> String:
  match value:
    case DepApp.Finished{events}:List.show(&2,Exec.Observation<String,Unit>,event,events)
    case DepApp.Stopped{_,events}:"stopped:" ++ List.show(&2,Exec.Observation<String,Unit>,event,events)
    case DepApp.Invalid{_}:"invalid"
def token_keep(value:P.Token) -> P.Token & String:
  match value:
    case P.Token{array}:
      ObserveIdentity.joined(Array<U32>,U32,P.Token & String,Array.get(U32,array,0),array => value =>
        (P.Token{array},U32.show(value)))
def parcel_keep(value:S.Parcel) -> S.Parcel & String:
  match value:
    case S.Parcel{array}:
      ObserveIdentity.joined(Array<String>,String,S.Parcel & String,Array.get(String,array,0),array => value =>
        (S.Parcel{array},value))
def maybe_keep(~T:Type,~show:T -> T & String,value:Maybe<&1,T>) -> Maybe<&1,T> & String:
  match value:
    case None{}:(None{},"none")
    case Some{value}:
      ObserveIdentity.joined(T,String,Maybe<&1,T> & String,show(value),value => text =>
        (Some{value},text))
def list_keep(~T:Type,~show:T -> T & String,values:List<T>) -> List<T> & String:
  match values:
    case []:([],"")
    case head <> tail:
      ObserveIdentity.joined(T,String,List<T> & String,show(head),head => ht =>
        ObserveIdentity.joined(List<T>,String,List<T> & String,list_keep(~T,~show,tail),tail => tt =>
          (head <> tail,ht ++ ";" ++ tt)))
def bundle_keep(value:Removed.Removed(layout())) -> Removed.Removed(layout()) & String:
  match value:
    case Product.Owner{Product.Owner{token,parcel},unit}:
      ObserveIdentity.joined(Maybe<&1,P.Token>,String,Removed.Removed(layout()) & String,maybe_keep(~P.Token,~token_keep,token),token => tt =>
        ObserveIdentity.joined(Maybe<&1,S.Parcel>,String,Removed.Removed(layout()) & String,maybe_keep(~S.Parcel,~parcel_keep,parcel),parcel => pt =>
          (Product.Owner{Product.Owner{token,parcel},unit},"token=" ++ tt ++ ",parcel=" ++ pt)))
def entry_keep(value:Buffer.Entry<S.Schema,P.Token,Removed.Removed(layout())>) -> Buffer.Entry<S.Schema,P.Token,Removed.Removed(layout())> & String:
  match value:
    case Buffer.Spawn{+handle,owner}:
      ObserveIdentity.joined(Removed.Removed(layout()),String,Buffer.Entry<S.Schema,P.Token,Removed.Removed(layout())> & String,bundle_keep(owner),owner => text =>
        (Buffer.Spawn{handle,owner},"spawn:" ++ S.handle_text(handle) ++ ":" ++ text))
    case Buffer.Entry{+handle,owner}:
      ObserveIdentity.joined(Maybe<&1,P.Token>,String,Buffer.Entry<S.Schema,P.Token,Removed.Removed(layout())> & String,maybe_keep(~P.Token,~token_keep,owner),owner => text =>
        (Buffer.Entry{handle,owner},"write:" ++ S.handle_text(handle) ++ ":" ++ text))
    case Buffer.Despawn{+handle}:(Buffer.Despawn{handle},"despawn:" ++ S.handle_text(handle))
    case value:(value,"unselected-command")
def receipt_keep(value:Buffer.Receipt<S.Schema,P.Token,Removed.Removed(layout())>) -> Buffer.Receipt<S.Schema,P.Token,Removed.Removed(layout())> & String:
  match value:
    case Buffer.Spawned{+handle,owner}:
      ObserveIdentity.joined(Removed.Removed(layout()),String,Buffer.Receipt<S.Schema,P.Token,Removed.Removed(layout())> & String,bundle_keep(owner),owner => text =>
        (Buffer.Spawned{handle,owner},"spawned:" ++ S.handle_text(handle) ++ ":" ++ text))
    case Buffer.SpawnRefused{+handle,owner,+reason}:
      ObserveIdentity.joined(Removed.Removed(layout()),String,Buffer.Receipt<S.Schema,P.Token,Removed.Removed(layout())> & String,bundle_keep(owner),owner => text =>
        (Buffer.SpawnRefused{handle,owner,reason},"spawn-refused:" ++ S.handle_text(handle) ++ ":" ++ text ++ ":" ++ S.spawn_reason(reason)))
    case Buffer.Despawned{+handle,owner}:
      ObserveIdentity.joined(Removed.Removed(layout()),String,Buffer.Receipt<S.Schema,P.Token,Removed.Removed(layout())> & String,bundle_keep(owner),owner => text =>
        (Buffer.Despawned{handle,owner},"despawned:" ++ S.handle_text(handle) ++ ":" ++ text))
    case Buffer.DespawnRefused{+handle}:(Buffer.DespawnRefused{handle},"despawn-refused:" ++ S.handle_text(handle))
    case Buffer.Applied{+handle,owner}:
      ObserveIdentity.joined(Maybe<&1,P.Token>,String,Buffer.Receipt<S.Schema,P.Token,Removed.Removed(layout())> & String,maybe_keep(~P.Token,~token_keep,owner),owner => text =>
        (Buffer.Applied{handle,owner},"applied:" ++ S.handle_text(handle) ++ ":" ++ text))
    case Buffer.Refused{+handle,owner}:
      ObserveIdentity.joined(Maybe<&1,P.Token>,String,Buffer.Receipt<S.Schema,P.Token,Removed.Removed(layout())> & String,maybe_keep(~P.Token,~token_keep,owner),owner => text =>
        (Buffer.Refused{handle,owner},"refused:" ++ S.handle_text(handle) ++ ":" ++ text))
    case value:(value,"unselected-receipt")
def permission_text(value:Permission.Permission) -> String:
  match value:
    case Permission.FamilyOnly{}:"family"
    case Permission.EntityStructural{}:"entity"
def header(namespace:U32,id:U32,name:String,access:List<&2,String>,cursor:Maybe<&2,Tick.Tick>) -> String:
  U32.show(namespace) ++ ":" ++ U32.show(id) ++ ":" ++ name ++ ":" ++ List.show(&2,String,value=>value,access) ++ ":" ++ Tick.cursor_show(cursor)
def snapshot(app:Application()) -> Application() & String:
  match app:
    case Schedule.Scheduled{DepApp.State{world,Product.Owner{Cmd.Owner{Sys.Owner{+an,+ai,+name,+access,+cursor,Local.Local{AuthorLocal{+phase,+handles,+foreign,rejected,+reasons},Buffer.Buffer{pending,receipts},+permission}}},Sys.Owner{+pn,+pi,+pname,+pa,+pc,peer}},guards,Handler{handler,+errors},bindings},plan,appBindings,rules,Schedule.Deferred{+systems,+config,+unapplied}}:
      ObserveIdentity.joined(ObserveIdentity.World(),String,Application() & String,ObserveIdentity.inspected(world,List.append(&2,W.Handle<S.Schema>,handles,[foreign])),world => wt =>
        ObserveIdentity.joined(List<Buffer.Entry<S.Schema,P.Token,Removed.Removed(layout())>>,String,Application() & String,list_keep(~Buffer.Entry<S.Schema,P.Token,Removed.Removed(layout())>,~entry_keep,pending),pending => qt =>
          ObserveIdentity.joined(List<Buffer.Receipt<S.Schema,P.Token,Removed.Removed(layout())>>,String,Application() & String,list_keep(~Buffer.Receipt<S.Schema,P.Token,Removed.Removed(layout())>,~receipt_keep,receipts),receipts => rt =>
            ObserveIdentity.joined(List<Removed.Removed(layout())>,String,Application() & String,list_keep(~Removed.Removed(layout()),~bundle_keep,rejected),rejected => jt =>
              ObserveIdentity.joined(Array<U32>,U32,Application() & String,Array.get(U32,peer,0),peer => pv =>
                ObserveIdentity.joined(Array<U32>,U32,Application() & String,Array.get(U32,handler,0),handler => hv =>
                  (Schedule.Scheduled{DepApp.State{world,Product.Owner{Cmd.Owner{Sys.Owner{an,ai,name,access,cursor,Local.Local{AuthorLocal{phase,handles,foreign,rejected,reasons},Buffer.Buffer{pending,receipts},permission}}},Sys.Owner{pn,pi,pname,pa,pc,peer}},guards,Handler{handler,errors},bindings},plan,appBindings,rules,Schedule.Deferred{systems,config,unapplied}},"world={" ++ wt ++ "}|author=" ++ header(an,ai,name,access,cursor) ++ ":phase=" ++ U32.show(phase) ++ ":permission=" ++ permission_text(permission) ++ "|queue={" ++ qt ++ "}|receipts={" ++ rt ++ "}|rejected={" ++ jt ++ "}:reasons=" ++ List.show(&2,W.WorldError,Trace.error,reasons) ++ "|peer=" ++ header(pn,pi,pname,pa,pc) ++ ":" ++ U32.show(pv) ++ "|handler=" ++ U32.show(hv) ++ ":" ++ U32.show(errors) ++ "|systems=" ++ List.show(&2,U32,U32.show,systems) ++ "|unapplied=" ++ List.show(&2,U32,U32.show,unapplied))))))))
def selected(app:Application()) -> IO(Application() & DepApp.Report<String,Unit>):
  Schedule.run_native(~S.Schema,~Left(),~Unit,~Unit,~Unit,~Unit,~resources(),~{==},~String,~Unit,~Author(),~Peer(),~left,~right,~Unit,~Handler,~Conditions.empty_dispatch(~W.World<S.Schema,Store(),Resources(),Unit>,~String),~Conditions.empty(~W.World<S.Schema,Store(),Resources(),Unit>,~String),~handle,app)
def settings(phase:U32) -> Settings.Settings:
  match phase:
    case 0:Settings.Settings{True{},False{},[],[]}
    case 2:Settings.Settings{True{},False{},[],[]}
    case 7:Settings.Settings{True{},False{},[],[]}
    case _:Settings.defaults()
def cancel_handles(skip:Nat,fuel:Nat,handles:List<&2,W.Handle<S.Schema>>,world:ObserveIdentity.World()) -> ObserveIdentity.World():
  match skip fuel handles:
    case _ _ Nil{}:world
    case 1n+skip fuel _ <> rest:cancel_handles(skip,fuel,rest,world)
    case 0n 0n _:world
    case 0n 1n+fuel handle <> rest:cancel_handles(0n,fuel,rest,W.clear_pending(~S.Schema,~Store(),~Resources(),~Unit,world,handle))
def cancel(app:Application()) -> Application():
  match app:
    case Schedule.Scheduled{DepApp.State{world,Product.Owner{Cmd.Owner{Sys.Owner{an,ai,name,access,cursor,Local.Local{AuthorLocal{phase,+handles,foreign,rejected,reasons},queue,permission}}},peer},guards,handler,bindings},plan,appBindings,rules,deferred}:Schedule.Scheduled{DepApp.State{cancel_handles(6n,7n,handles,world),Product.Owner{Cmd.Owner{Sys.Owner{an,ai,name,access,cursor,Local.Local{AuthorLocal{phase,handles,foreign,rejected,reasons},queue,permission}}},peer},guards,handler,bindings},plan,appBindings,rules,deferred}
def before(phase:U32,app:Application()) -> Application():
  match phase:
    case 8:cancel(app)
    case _:app
def updates(fuel:Nat,+phase:U32,app:Application(),foreign:ObserveIdentity.World(),log:String) -> IO(String):
  match fuel:
    case 0n:
      ObserveIdentity.joined(ObserveIdentity.World(),String,IO(String),ObserveIdentity.world_text(foreign),_ => text =>
        IO.pure(String,log ++ "foreign-final={" ++ text ++ "}"))
    case 1n+rest:
      ObserveIdentity.joined(Application(),String,IO(String),snapshot(before(phase,app)),app => prior =>
        IO.bind(Application() & DepApp.Report<String,Unit>,String,selected(Schedule.configure(~(DepApp.State<W.World<S.Schema,Store(),Resources(),Unit>,Product.Owner<Author(),Peer()>,Unit,Handler>),settings(phase),app)),result =>
          ObserveIdentity.joined(Application(),DepApp.Report<String,Unit>,IO(String),result,app => done =>
            ObserveIdentity.joined(Application(),String,IO(String),snapshot(app),app => text =>
              updates(rest,U32.add(phase,1),app,foreign,log ++ "step=" ++ U32.show(phase) ++ ":before={" ++ prior ++ "}:report=" ++ report(done) ++ ":after={" ++ text ++ "}\n")))))
def built(start:U32,fuel:Nat,world:ObserveIdentity.World(),author:Author(),peer:Peer(),foreign:ObserveIdentity.World()) -> IO(String):
  ObserveIdentity.joined(ObserveIdentity.World(),String,IO(String),ObserveIdentity.world_text(foreign),foreign => initial =>
    updates(fuel,start,Schedule.build(~S.Schema,~Left(),~Unit,~Unit,~Unit,~Unit,~resources(),~{==},~String,~Unit,~Author(),~Peer(),~left,~right,~Unit,~Handler,~Conditions.empty_dispatch(~W.World<S.Schema,Store(),Resources(),Unit>,~String),~Conditions.empty(~W.World<S.Schema,Store(),Resources(),Unit>,~String),~handle,~(name => True{}),world,Product.Owner{author,peer},Unit{},Handler{ALeaf{901},0},[],[]),foreign,"foreign-initial={" ++ initial ++ "}\n"))
def peer_defined(start:U32,fuel:Nat,author:Author(),foreign:ObserveIdentity.World(),result:Sys.Defined<W.World<S.Schema,Store(),Resources(),Unit>,Peer(),Array<U32>>) -> IO(String):
  match result:
    case Sys.Defined{world,peer}:built(start,fuel,world,author,peer,foreign)
    case Sys.DefinitionRefused{_,_}:IO.pure(String,"peer-refused")
def author_defined(start:U32,fuel:Nat,foreign:ObserveIdentity.World(),result:Sys.Defined<W.World<S.Schema,Store(),Resources(),Unit>,Author(),Cmd.Captures(~S.Schema,~layout(),~resources(),~path(),~AuthorLocal)>) -> IO(String):
  match result:
    case Sys.Defined{world,author}:peer_defined(start,fuel,author,foreign,Task.define(~S.Schema,~Store(),~Unit,~Unit,~Unit,~Ops,~Array<U32>,~String,~Unit,~peer_declaration,~peer_body,~Resources(),world,"peer",ALeaf{801}))
    case Sys.DefinitionRefused{_,_}:IO.pure(String,"author-refused")
def registered_at(+start:U32,fuel:Nat,world:ObserveIdentity.World(),foreign:ObserveIdentity.World(),handle:W.Handle<S.Schema>) -> IO(String):
  author_defined(start,fuel,foreign,Cmd.define(~S.Schema,~Left(),~Unit,~Unit,~layout(),~resources(),~path(),~{==},~CmdOps,~AuthorLocal,~String,~Unit,~author_declaration,~author_body,~Resources(),world,"author",AuthorLocal{start,[],handle,[],[]}))
def activated_join(next:ObserveIdentity.World() -> IO(String),result:ObserveIdentity.World() & W.Status) -> IO(String):
  match result:
    case (world,W.Accepted{}):next(world)
    case (_,_):IO.pure(String,"activation-refused")
def reserved_join(next:ObserveIdentity.World() -> W.Handle<S.Schema> -> IO(String),result:ObserveIdentity.World() & W.Reservation<S.Schema>) -> IO(String):
  match result:
    case (world,W.Reserved{+handle}):activated_join(world => next(world,handle),W.activate(~S.Schema,~Store(),~Resources(),~Unit,world,handle))
    case (_,_):IO.pure(String,"reservation-refused")
def foreign_created(world:ObserveIdentity.World(),result:W.Creation<S.Schema,Store(),Resources(),Unit>) -> IO(String):
  match result:
    case W.Created{_,foreign}:reserved_join(foreign => handle => registered_at(0,10n,world,foreign,handle),W.reserve_id(~S.Schema,~Store(),~Resources(),~Unit,foreign))
    case W.CreateRejected{_,_}:IO.pure(String,"foreign-creation-refused")
def created(result:W.Creation<S.Schema,Store(),Resources(),Unit>) -> IO(String):
  match result:
    case W.Created{factory,world}:reserved_join(world => _ => foreign_created(world,W.create(~S.Schema,~Store(),~Resources(),~Unit,~S.empty,factory,Product.Owner{Unit{},Unit{}})),W.reserve_id(~S.Schema,~Store(),~Resources(),~Unit,world))
    case W.CreateRejected{_,_}:IO.pure(String,"creation-refused")
def main() -> IO(Unit):
  IO.bind(String,Unit,created(W.create(~S.Schema,~Store(),~Resources(),~Unit,~S.empty,W.factory(),Product.Owner{Unit{},Unit{}})),IO.print)
