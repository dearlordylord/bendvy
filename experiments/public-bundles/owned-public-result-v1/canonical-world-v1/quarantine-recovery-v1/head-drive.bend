import Base
import runtime.bend as R
import observe.bend as O
import drive.bend as A
import ../bundle.bend as B
import ../canonical.bend as K
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/bundle-pack.bend as P
import /workspace/formal-proofs/bendvy/src/ecs/bundle-construction.bend as CS
import /workspace/formal-proofs/bendvy/src/ecs/bundle-component-install.bend as I
import /workspace/formal-proofs/bendvy/src/ecs/bundle-delivery.bend as D
import /workspace/formal-proofs/bendvy/src/ecs/decode-data.bend as Decode

type Targets is Data:Targets{head:W.Handle<K.SchemaA>,tail:W.Handle<K.SchemaA>}
def finished(prefix:String,result:O.Session & String) -> String:
  match result:
    case (session,view):prefix ++ "\ncleaned=" ++ view
def restored(prefix:String,result:O.Session & String) -> String:
  match result:
    case (session,view):finished(prefix ++ "\nrestored=" ++ view,O.session(A.unwind(session)))
def pending_again(+targets:Targets,prefix:String,result:O.Session & String) -> String:
  match targets result:
    case Targets{head,tail},(session,view):restored(prefix ++ "\npending-again=" ++ view,O.session(A.resumed(A.active(head,True{},session))))
def pending(+targets:Targets,prefix:String,result:O.Session & String) -> String:
  match result:
    case (session,view):pending_again(targets,prefix ++ "\npending=" ++ view,O.session(A.resumed(session)))
def replaced(targets:Targets,prefix:String,result:O.Session & String) -> String:
  match targets result:
    case Targets{+head,+tail},(session,view):pending(Targets{head,tail},prefix ++ "\nreplaced=" ++ view,O.session(A.unwind(A.active(head,False{},session))))
def delivered(~next:Targets -> String -> (O.Session & String) -> String,+targets:Targets,prefix:String,registry:R.Registry(),context:K.Context<K.SchemaA>,result:D.Delivery<R.World(),B.Packet>) -> String:
  match result:
    case D.Delivered{world}:next(targets,prefix,O.session(O.Session{registry,world,context}))
    case D.Undelivered{world,packet,error}:A.finished("unexpected-install-refusal",O.session(O.Session{registry,R.recover(world,packet,error),context}))
def staged(~next:Targets -> String -> (O.Session & String) -> String,+targets:Targets,prefix:String,registry:R.Registry(),world:R.World(),result:CS.Staged<K.Context<K.SchemaA>,B.Raw(),B.Cooked(),B.ConstructorError()>) -> String:
  match targets result:
    case Targets{+head,+tail},CS.Valid{context,P.Pack{first,last},undo,positions}:delivered(~next,Targets{head,tail},prefix,registry,context,R.installed(undo,B.install_entries(~R.Mail,world,P.Pack{I.Entry{head,Some{first}},P.Pack{I.Entry{tail,Some{last}},Unit{}}})))
    case targets,CS.Failed{context,raw,positions}:A.rejected_raw(O.session(O.Session{registry,world,context}),K.raw_observe(raw))
def install(~next:Targets -> String -> (O.Session & String) -> String,+targets:Targets,prefix:String,session:O.Session,raw:B.Raw()) -> String:
  match session:
    case O.Session{registry,world,context}:staged(~next,targets,prefix,registry,world,K.stage(~K.SchemaA,context,raw))
def installed(targets:Targets,prefix:String,result:O.Session & String) -> String:
  match result:
    case (session,view):install(~replaced,targets,prefix ++ "\ninstalled=" ++ view,session,A.replacement())
def initial(+targets:Targets,result:O.Session & String) -> String:
  match result:
    case (session,view):install(~installed,targets,"initial=" ++ view,session,A.sample(Decode.Number{9},False{}))
def tail_active(+targets:Targets,registry:R.Registry(),result:R.World() & W.Status) -> String:
  match result:
    case (world,status):initial(targets,O.session(O.Session{registry,world,K.context(~K.SchemaA)}))
def head_active(+targets:Targets,registry:R.Registry(),result:R.World() & W.Status) -> String:
  match targets result:
    case Targets{head,+tail},(world,status):tail_active(Targets{head,tail},registry,W.activate(~K.SchemaA,~B.Store,~R.Mail,~U32,world,tail))
def second_reserved(+head:W.Handle<K.SchemaA>,registry:R.Registry(),result:R.World() & W.Reservation<K.SchemaA>) -> String:
  match result:
    case (world,W.Reserved{tail}):head_active(Targets{head,tail},registry,W.activate(~K.SchemaA,~B.Store,~R.Mail,~U32,world,head))
    case (world,W.ReservationRejected{error}):A.failed_world("second-reserve",O.world(world))
def first_reserved(registry:R.Registry(),result:R.World() & W.Reservation<K.SchemaA>) -> String:
  match result:
    case (world,W.Reserved{head}):second_reserved(head,registry,W.reserve_id(~K.SchemaA,~B.Store,~R.Mail,~U32,world))
    case (world,W.ReservationRejected{error}):A.failed_world("first-reserve",O.world(world))
def registered(result:Sys.RegistrationResult<K.SchemaA,B.Store,R.Mail,U32,R.Args(),String,R.OwnedOutput(),R.runner>) -> String:
  match result:
    case Sys.Registered{world,registry}:first_reserved(registry,W.reserve_id(~K.SchemaA,~B.Store,~R.Mail,~U32,world))
    case Sys.RegistrationFailed{world}:A.failed_world("registration",O.world(world))
def begun(world:R.World()) -> String:registered(Sys.register(~K.SchemaA,~B.Store,~R.Mail,~U32,~R.Args(),~String,~R.OwnedOutput(),~R.runner,world,"generic-two-target-inverse",["bundle:write"]))
