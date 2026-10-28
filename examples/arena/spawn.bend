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
import ../../src/ecs/execution-state.bend as State
import ../../src/ecs/execution-query.bend as Query
import ../../src/ecs/chunk-query.bend as Row
import ../../src/ecs/execution-query-recipe.bend as Recipe
import ../../src/ecs/execution-query-matches.bend as Match
import ../../src/ecs/execution-query-store.bend as Store
import ../../src/ecs/execution-generalized-command-leaf.bend as Author
import ../../src/ecs/world.bend as W

def route() -> L.Route:L.AtLeaf{}
type Firing<-Q:Type> is Type:
  Firing{queue:Q,seeds:List<&2,V.Body>,player:Maybe<&2,W.Handle<D.Schema>>,handles:List<&2,W.Handle<D.Schema>>,returned:List<Removed.Removed(D.components())>,visited:Bool}
type Caps<-Permit:Data,-H:Type,-Q:Type> is Type:
  Caps{rows:Query.TaskOutputEach<D.Schema,Permit,H,Firing<Q>,String>,commands:Permission.EntityCommands<Q,D.Schema,D.components(),Permit>}
def Ops(Permit:Data,H:Type,Q:Type) -> Type:Caps<Permit,H,Q>
type User is Type:
  User{seeds:List<&2,V.Body>,handles:List<&2,W.Handle<D.Schema>>,returned:List<Removed.Removed(D.components())>,player:Maybe<&2,W.Handle<D.Schema>>}
def player_seed(seed:V.Body) -> Bool:
  match seed:
    case V.Body{_,_,kind,_,_,_,_,_,_}:U32.is_eq(kind,0)
def capture_player(player:Maybe<&2,W.Handle<D.Schema>>,handle:W.Handle<D.Schema>,selected:Bool) -> Maybe<&2,W.Handle<D.Schema>>:
  match player selected:
    case None{} True{}:Some{handle}
    case player _:player
def captured_player(player:Maybe<&2,W.Handle<D.Schema>>,seed:V.Body,handle:W.Handle<D.Schema>) -> Maybe<&2,W.Handle<D.Schema>>:
  capture_player(player,handle,player_seed(seed))
def admitted(~Permit:Data,~H:Type,~Q:Type,next:H -> Q -> List<&2,W.Handle<D.Schema>> -> Maybe<&2,W.Handle<D.Schema>> -> Task.Task<D.Schema,Permit,H & (Q & (User & Sys.Completion<String,Unit>))>,scope:H,seed:V.Body,remaining:List<&2,V.Body>,handles:List<&2,W.Handle<D.Schema>>,player:Maybe<&2,W.Handle<D.Schema>>,result:Q & Buffer.SpawnAdmission<D.Schema,Removed.Removed(D.components())>) -> Task.Task<D.Schema,Permit,H & (Q & (User & Sys.Completion<String,Unit>))>:
  match result:
    case (queue,Buffer.SpawnQueued{+handle}):next(scope,queue,List.append(&2,W.Handle<D.Schema>,handles,[handle]),captured_player(player,seed,handle))
    case (queue,Buffer.SpawnRejected{bundle,_}):Task.TDone{(scope,(queue,(User{remaining,handles,[bundle],player},Sys.BodyError{"spawn reservation refused",Unit{}})))}
def seeded(~Permit:Data,~H:Type,~Q:Type,seeds:List<&2,V.Body>,scope:H,queue:Q,handles:List<&2,W.Handle<D.Schema>>,player:Maybe<&2,W.Handle<D.Schema>>) -> Task.Task<D.Schema,Permit,H & (Q & (User & Sys.Completion<String,Unit>))>:
  Task.TDone{(scope,(queue,(User{seeds,handles,[],player},Sys.Success{Unit{}})))}
def queue_seeds(~Permit:Data,~H:Type,~Q:Type,~spawn:Q -> Removed.Removed(D.components()) -> Task.Task<D.Schema,Permit,Q & Buffer.SpawnAdmission<D.Schema,Removed.Removed(D.components())>>,seeds:List<&2,V.Body>,scope:H,queue:Q,handles:List<&2,W.Handle<D.Schema>>,player:Maybe<&2,W.Handle<D.Schema>>) -> Task.Task<D.Schema,Permit,H & (Q & (User & Sys.Completion<String,Unit>))>:
  match seeds:
    case []:seeded(~Permit,~H,~Q,[],scope,queue,handles,player)
    case +seed <> +rest:Task.bind(D.Schema,Permit,Q & Buffer.SpawnAdmission<D.Schema,Removed.Removed(D.components())>,H & (Q & (User & Sys.Completion<String,Unit>)),spawn(queue,Some{seed}),result => admitted(~Permit,~H,~Q,scope => queue => handles => player => queue_seeds(~Permit,~H,~Q,~spawn,rest,scope,queue,handles,player),scope,seed,rest,handles,player,result))
def split_queues(~Q:Type,+seeds:List<&2,V.Body>,+player:Maybe<&2,W.Handle<D.Schema>>,handles:List<&2,W.Handle<D.Schema>>,returned:List<Removed.Removed(D.components())>,+visited:Bool,queues:Q & Q) -> Firing<Q> & Firing<Q>:
  match queues:
    case (left,right):(Firing{left,seeds,player,handles,returned,visited},Firing{right,seeds,player,[],[],visited})
def split_firing(~Q:Type,~commands:Local.Commands<Q,D.Schema,V.Body>,output:Firing<Q>) -> Firing<Q> & Firing<Q>:
  match output:
    case Firing{queue,seeds,player,handles,returned,visited}:split_queues(~Q,seeds,player,handles,returned,visited,Local.split_field(~Q,~D.Schema,~V.Body,commands)(queue))
def pending_intent(left:List<&2,V.Body>,right:List<&2,V.Body>,visited:Bool) -> List<&2,V.Body>:
  match visited:
    case True{}:left
    case False{}:right
def merge_firing(~Q:Type,~commands:Local.Commands<Q,D.Schema,V.Body>,left:Firing<Q>,right:Firing<Q>) -> Firing<Q>:
  match left right:
    case Firing{lq,ls,player,lh,lr,+lv} Firing{rq,rs,_,rh,rr,+rv}:Firing{Local.merge_field(~Q,~D.Schema,~V.Body,commands)(lq,rq),pending_intent(ls,rs,lv),player,List.append(&2,W.Handle<D.Schema>,lh,rh),List.append(&1,Removed.Removed(D.components()),lr,rr),Bool.or(lv,rv)}
def row_completed(~Q:Type,prior:List<Removed.Removed(D.components())>,result:V.Body & (Q & (User & Sys.Completion<String,Unit>))) -> V.Body & (Firing<Q> & Maybe<&2,String>):
  match result:
    case (body,(queue,(User{seeds,handles,returned,player},Sys.Success{_}))):(body,(Firing{queue,seeds,player,handles,List.append(&1,Removed.Removed(D.components()),prior,returned),True{}},None{}))
    case (body,(queue,(User{seeds,handles,returned,player},Sys.BodyError{error,_}))):(body,(Firing{queue,seeds,player,handles,List.append(&1,Removed.Removed(D.components()),prior,returned),True{}},Some{error}))
def row_selected(~Permit:Data,~Q:Type,~spawn:Q -> Removed.Removed(D.components()) -> Task.Task<D.Schema,Permit,Q & Buffer.SpawnAdmission<D.Schema,Removed.Removed(D.components())>>,body:V.Body,output:Firing<Q>,selected:Bool) -> Task.Task<D.Schema,Permit,V.Body & (Firing<Q> & Maybe<&2,String>)>:
  match output selected:
    case Firing{queue,seeds,player,handles,returned,False{}} True{}:Task.TBind{V.Body & (Q & (User & Sys.Completion<String,Unit>)),queue_seeds(~Permit,~V.Body,~Q,~spawn,seeds,body,queue,handles,player),result=>Task.TDone{row_completed(~Q,returned,result)}}
    case output _:Task.TDone{(body,(output,None{}))}
def row_target(handle:W.Handle<D.Schema>,player:Maybe<&2,W.Handle<D.Schema>>) -> Bool:
  match player:
    case None{}:False{}
    case Some{target}:State.same(~D.Schema,handle,target)
def row(~Permit:Data,~Q:Type,~spawn:Q -> Removed.Removed(D.components()) -> Task.Task<D.Schema,Permit,Q & Buffer.SpawnAdmission<D.Schema,Removed.Removed(D.components())>>,handle:W.Handle<D.Schema>,_:V.Body,body:V.Body,output:Firing<Q>) -> Task.Task<D.Schema,Permit,V.Body & (Firing<Q> & Maybe<&2,String>)>:
  match output:
    case Firing{queue,seeds,+player,handles,returned,visited}:row_selected(~Permit,~Q,~spawn,body,Firing{queue,seeds,player,handles,returned,visited},row_target(handle,player))
def any_body(_:Maybe<&2,V.Body>) -> Bool:True{}
def query(~Permit:Data,~H:Type,~Q:Type,~commands:Local.Commands<Q,D.Schema,V.Body>,~spawn:Q -> Removed.Removed(D.components()) -> Task.Task<D.Schema,Permit,Q & Buffer.SpawnAdmission<D.Schema,Removed.Removed(D.components())>>,~B:Type,~cr:Build.ComponentRead(~D.Schema,~Decay.C(),~Decay.R(),~H,~B),~cw:Build.ComponentWrite(~D.Schema,~Decay.C(),~Decay.R(),~H,~B),~rr:Build.ResourceRead(~D.Schema,~Decay.C(),~Decay.R(),~H,~B),~rw:Build.ResourceWrite(~D.Schema,~Decay.C(),~Decay.R(),~H,~B),~q:Build.Query(~D.Schema,~D.Columns(),~Decay.C(),~Decay.R(),~H,~B),~life:Build.Lifecycle(~D.Schema,~D.Columns(),~Decay.C(),~Decay.R(),~H,~B),book:B) -> B & Query.TaskOutputEach<D.Schema,Permit,H,Firing<Q>,String>:
  Build.task_general_query(~D.Schema,~Permit,~D.Columns(),~Decay.C(),~Decay.R(),~D.components(),~route(),~{==},~{==},~Store.Sparse{},~{==},~Recipe.AllLive{},~Match.Required{},~any_body,~Firing<Q>,~String,~split_firing(~Q,~commands),~merge_firing(~Q,~commands),~row(~Permit,~Q,~spawn),~Query.Parallel{},~H,~B,~q,book)
def selected_caps(~Permit:Data,~H:Type,~Q:Type,~B:Type,structural:Permission.EntityCommands<Q,D.Schema,D.components(),Permit>,result:B & Query.TaskOutputEach<D.Schema,Permit,H,Firing<Q>,String>) -> B & Ops(Permit,H,Q):
  match result:
    case (book,rows):(book,Caps{rows,structural})
def entity_selection(~Permit:Data,~H:Type,~Q:Type,~commands:Local.Commands<Q,D.Schema,V.Body>,~B:Type,~builder:Build.Builder(~D.Schema,~D.Columns(),~Decay.C(),~Decay.R(),~Permit,~H,~B),~structural:Permission.EntityCommands<Q,D.Schema,D.components(),Permit>) -> B -> B & Ops(Permit,H,Q):
  book=>selected_caps(~Permit,~H,~Q,~B,structural,builder(Permit=>H=>Query.TaskOutputEach<D.Schema,Permit,H,Firing<Q>,String>,query(~Permit,~H,~Q,~commands,~Permission.spawn_field(~Q,~D.Schema,~D.components(),~Permit,structural),~B),book))
def declared(~Permit:Data,~H:Type,~Q:Type,~B:Type,~K:Type,permission:K,result:B & Ops(Permit,H,Q)) -> B & (K & Ops(Permit,H,Q)):
  match result:
    case (book,ops):(book,(permission,ops))
def granted(~Permit:Data,~H:Type,~Q:Type,~B:Type,~K:Type,book:B,result:K & (B -> B & Ops(Permit,H,Q))) -> B & (K & Ops(Permit,H,Q)):
  match result:
    case (permission,selection):declared(~Permit,~H,~Q,~B,~K,permission,selection(book))
def declaration(~Permit:Data,~H:Type,~Q:Type,~commands:Local.Commands<Q,D.Schema,V.Body>,~B:Type,~builder:Build.Builder(~D.Schema,~D.Columns(),~Decay.C(),~Decay.R(),~Permit,~H,~B),~K:Type,~entity:Permission.Grant(~D.Schema,~D.components(),~Permit,~Q,~K),~relations:Permission.RelationGrant(~D.Schema,~D.resources(),~Q,~K),~scopes:Permission.ScopeGrant(~D.Schema,~D.resources(),~Q,~K),book:B,permission:K) -> B & (K & Ops(Permit,H,Q)):
  granted(~Permit,~H,~Q,~B,~K,book,entity(B -> B & Ops(Permit,H,Q),entity_selection(~Permit,~H,~Q,~commands,~B,~builder),permission))
def projectile(seed:V.Body) -> Bool:
  match seed:
    case V.Body{_,_,+kind,_,_,_,_,_,_}:Bool.and(U32.is_le(3,kind),U32.is_le(kind,5))
def prepend_seed(seed:V.Body,parts:List<&2,V.Body> & List<&2,V.Body>) -> List<&2,V.Body> & List<&2,V.Body>:
  match parts:
    case (direct,firing):(seed <> direct,firing)
def split_seed(seed:V.Body,rest:List<&2,V.Body>,parts:List<&2,V.Body> & List<&2,V.Body>,isProjectile:Bool) -> List<&2,V.Body> & List<&2,V.Body>:
  match isProjectile:
    case True{}:([],seed <> rest)
    case False{}:prepend_seed(seed,parts)
def split_seeds(seeds:List<&2,V.Body>) -> List<&2,V.Body> & List<&2,V.Body>:
  match seeds:
    case []:([],[])
    case +seed <> +rest:split_seed(seed,rest,split_seeds(rest),projectile(seed))
def firing_status(~H:Type,~Q:Type,scope:H,queue:Q,user:User,visited:Bool,report:Query.Report<String>) -> H & (Q & (User & Sys.Completion<String,Unit>)):
  match visited report:
    case True{} Query.Completed{[]}:(scope,(queue,(user,Sys.Success{Unit{}})))
    case _ Query.Completed{Row.Error{_,error} <> _}:(scope,(queue,(user,Sys.BodyError{error,Unit{}})))
    case _ _:(scope,(queue,(user,Sys.BodyError{"player firing query refused",Unit{}})))
def firing_done(~H:Type,~Q:Type,prior:List<&2,W.Handle<D.Schema>>,result:H & (Firing<Q> & Query.Report<String>)) -> H & (Q & (User & Sys.Completion<String,Unit>)):
  match result:
    case (scope,(Firing{queue,seeds,player,handles,returned,visited},report)):firing_status(~H,~Q,scope,queue,User{seeds,List.append(&2,W.Handle<D.Schema>,prior,handles),returned,player},visited,report)
def rows_field(~Permit:Data,~H:Type,~Q:Type,caps:Ops(Permit,H,Q)) -> Query.TaskOutputEach<D.Schema,Permit,H,Firing<Q>,String>:
  match caps:
    case Caps{rows,_}:rows
def structural_field(~Permit:Data,~H:Type,~Q:Type,caps:Ops(Permit,H,Q)) -> Permission.EntityCommands<Q,D.Schema,D.components(),Permit>:
  match caps:
    case Caps{_,structural}:structural
def fire(~Permit:Data,~H:Type,~Q:Type,~caps:Ops(Permit,H,Q),scope:H,queue:Q,user:User) -> Task.Task<D.Schema,Permit,H & (Q & (User & Sys.Completion<String,Unit>))>:
  match user:
    case User{[],handles,returned,player}:Task.TDone{(scope,(queue,(User{[],handles,returned,player},Sys.Success{Unit{}})))}
    case User{seeds,handles,returned,player}:Task.TBind{H & (Firing<Q> & Query.Report<String>),Query.each_task_output(~D.Schema,~Permit,~H,~Firing<Q>,~String,rows_field(~Permit,~H,~Q,caps))(scope,Firing{queue,seeds,player,[],returned,False{}}),result=>Task.TDone{firing_done(~H,~Q,handles,result)}}
def direct_done(~Permit:Data,~H:Type,~Q:Type,~caps:Ops(Permit,H,Q),firing:List<&2,V.Body>,result:H & (Q & (User & Sys.Completion<String,Unit>))) -> Task.Task<D.Schema,Permit,H & (Q & (User & Sys.Completion<String,Unit>))>:
  match result:
    case (scope,(queue,(User{_,handles,returned,player},Sys.Success{_}))):fire(~Permit,~H,~Q,~caps,scope,queue,User{firing,handles,returned,player})
    case (scope,(queue,(User{seeds,handles,returned,player},completion))):Task.TDone{(scope,(queue,(User{List.append(&2,V.Body,seeds,firing),handles,returned,player},completion)))}
def direct(~Permit:Data,~H:Type,~Q:Type,~caps:Ops(Permit,H,Q),scope:H,queue:Q,handles:List<&2,W.Handle<D.Schema>>,player:Maybe<&2,W.Handle<D.Schema>>,parts:List<&2,V.Body> & List<&2,V.Body>) -> Task.Task<D.Schema,Permit,H & (Q & (User & Sys.Completion<String,Unit>))>:
  match parts:
    case (seeds,firing):Task.TBind{H & (Q & (User & Sys.Completion<String,Unit>)),queue_seeds(~Permit,~H,~Q,~Permission.spawn_field(~Q,~D.Schema,~D.components(),~Permit,structural_field(~Permit,~H,~Q,caps)),seeds,scope,queue,handles,player),result=>direct_done(~Permit,~H,~Q,~caps,firing,result)}
def body(~Permit:Data,~H:Type,~Q:Type,~caps:Ops(Permit,H,Q),~commands:Local.Commands<Q,D.Schema,V.Body>,scope:H,queue:Q,user:User) -> Task.Task<D.Schema,Permit,H & (Q & (User & Sys.Completion<String,Unit>))>:
  match user:
    case User{seeds,handles,[],None{}}:queue_seeds(~Permit,~H,~Q,~Permission.spawn_field(~Q,~D.Schema,~D.components(),~Permit,structural_field(~Permit,~H,~Q,caps)),seeds,scope,queue,handles,None{})
    case User{seeds,handles,[],player}:direct(~Permit,~H,~Q,~caps,scope,queue,handles,player,split_seeds(seeds))
    case user:Task.TDone{(scope,(queue,(user,Sys.BodyError{"spawn bundle retained after refusal",Unit{}})))}
def kernel(~Permit:Data,~token:Permit,~H:Type,~B:Type,~builder:Build.Builder(~D.Schema,~D.Columns(),~Decay.C(),~Decay.R(),~Permit,~H,~B),book:B) -> B & Cmd.ScopedOps(~D.Schema,~D.components(),~D.resources(),~route(),~Ops,Permit,H):
  Cmd.program_for_buffer(~D.Schema,~Decay.C(),~Decay.R(),~D.components(),~D.resources(),~route(),~Ops,~declaration,~Permit,~token,~H,~B,~builder,book)
def compilation() -> Decl.Compilation<D.Schema,D.Columns(),Decay.C(),Decay.R(),Cmd.ScopedOps(~D.Schema,~D.components(),~D.resources(),~route(),~Ops)>:
  Program.compile_framework(~D.Schema,~D.Columns(),~Decay.C(),~Decay.R(),~Cmd.ScopedOps(~D.Schema,~D.components(),~D.resources(),~route(),~Ops),~kernel)
def Node() -> Type:Author.Node(~D.Schema,~D.components(),~D.resources(),~Unit,~route(),~Ops,~User,~String,~Unit,~declaration,~body)
