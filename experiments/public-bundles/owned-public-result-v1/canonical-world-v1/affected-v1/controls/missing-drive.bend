import Base
import ../../runtime.bend as R
import ../../bundle.bend as B
import ../../canonical.bend as K
import ../../observe.bend as O
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/decode-data.bend as Decode
import /workspace/formal-proofs/bendvy/src/ecs/bundle-pack.bend as P
import /workspace/formal-proofs/bendvy/src/ecs/bundle-requests.bend as Cmd
import /workspace/formal-proofs/bendvy/src/ecs/bundle-insert-adapter.bend as AD

def sample() -> B.Raw():P.Pack{K.Incoming{ANode{ALeaf{11},ALeaf{12}},Decode.Number{7},False{}},K.Tail{ANode{ANode{ALeaf{21},ALeaf{22}},ANode{ALeaf{23},ALeaf{24}}},True{},31}}
def unexpected(prefix:String,result:O.Session & String) -> String:
  match result:
    case (session,view):prefix ++ "|" ++ view
def failed(prefix:String,result:R.World() & String) -> String:
  match result:
    case (world,view):prefix ++ "|" ++ view
def rejected(prefix:String,registry:R.Registry(),world:R.World(),args:R.Args()) -> String:
  match args:
    case (ctx,Cmd.Input{operation,raw}):unexpected(prefix,O.session(O.Session{registry,world,ctx}))
def cleaned(prefix:String,result:O.Session & String) -> String:
  match result:
    case (session,view):prefix ++ "\ncleaned=" ++ view
def unwound(prefix:String,session:O.Session) -> String:
  match session:
    case O.Session{reg,world,ctx}:cleaned(prefix,O.session(O.Session{reg,R.unwind(world),ctx}))
def installed(prefix:String,result:O.Session & String) -> String:
  match result:
    case (session,view):unwound(prefix ++ "\ninstalled=" ++ view,session)
def queued(prefix:String,result:O.Session & String) -> String:
  match result:
    case (O.Session{reg,world,ctx},view):installed(prefix ++ "\nretry-queued=" ++ view,O.session(O.Session{reg,W.barrier(~K.SchemaA,~B.Store,~R.Mail,~U32,world),ctx}))
def retried(prefix:String,result:R.RunResult()) -> String:
  match result:
    case Sys.Completed{reg,Sys.Succeeded{world,(ctx,Cmd.Accepted{target,spawned})}}:queued(prefix,O.session(O.Session{reg,world,ctx}))
    case Sys.Completed{reg,Sys.Succeeded{world,(ctx,Cmd.Refused{raw,error})}}:unexpected("unexpected-retry-refusal",O.session(O.Session{reg,world,ctx}))
    case Sys.Completed{reg,Sys.Failed{world,error}}:failed(error,O.world(world))
    case Sys.RegistrationRejected{reg,world,args}:rejected("unexpected-registration-refusal",reg,world,args)
def activated(prefix:String,reg:R.Registry(),ctx:K.Context<K.SchemaA>,raw:B.Raw(),+target:W.Handle<K.SchemaA>,result:R.World() & W.Status) -> String:
  match result:
    case (world,W.Accepted{}):retried(prefix,R.run(reg,world,(ctx,Cmd.Input{Cmd.Insert{target},raw})))
    case (world,W.Rejected{error}):unexpected("unexpected-activation-refusal",O.session(O.Session{reg,world,ctx}))
def seen(+target:W.Handle<K.SchemaA>,prefix:String,session:O.Session & String,raw:B.Raw() & String) -> String:
  match session raw:
    case (O.Session{reg,world,ctx},view),(raw,r):activated(prefix ++ "\nmissing=MissingEntity|raw=" ++ r ++ "|" ++ view,reg,ctx,raw,target,W.activate(~K.SchemaA,~B.Store,~R.Mail,~U32,world,target))
def first(+target:W.Handle<K.SchemaA>,prefix:String,result:R.RunResult()) -> String:
  match result:
    case Sys.Completed{reg,Sys.Succeeded{world,(ctx,Cmd.Refused{raw,AD.EntityRefused{W.MissingEntity{}}})}}:seen(target,prefix,O.session(O.Session{reg,world,ctx}),K.raw_observe(raw))
    case Sys.Completed{reg,Sys.Succeeded{world,(ctx,output)}}:unexpected("unexpected-entity-result",O.session(O.Session{reg,world,ctx}))
    case Sys.Completed{reg,Sys.Failed{world,error}}:failed(error,O.world(world))
    case Sys.RegistrationRejected{reg,world,args}:rejected("unexpected-registration-refusal",reg,world,args)
def initial(+target:W.Handle<K.SchemaA>,result:O.Session & String) -> String:
  match result:
    case (O.Session{reg,world,ctx},view):first(target,"initial=" ++ view,R.run(reg,world,(ctx,Cmd.Input{Cmd.Insert{target},sample()})))
def reserved(reg:R.Registry(),result:R.World() & W.Reservation<K.SchemaA>) -> String:
  match result:
    case (world,W.Reserved{+target}):initial(target,O.session(O.Session{reg,world,K.context(~K.SchemaA)}))
    case (world,W.ReservationRejected{error}):unexpected("unexpected-reservation-refusal",O.session(O.Session{reg,world,K.context(~K.SchemaA)}))
def registered(result:Sys.RegistrationResult<K.SchemaA,B.Store,R.Mail,U32,R.Args(),String,R.OwnedOutput(),R.runner>) -> String:
  match result:
    case Sys.Registered{world,reg}:reserved(reg,W.reserve_id(~K.SchemaA,~B.Store,~R.Mail,~U32,world))
    case Sys.RegistrationFailed{world}:failed("unexpected-registration",O.world(world))
def begun(world:R.World()) -> String:registered(Sys.register(~K.SchemaA,~B.Store,~R.Mail,~U32,~R.Args(),~String,~R.OwnedOutput(),~R.runner,world,"canonical-bundle",["bundle:write"]))
