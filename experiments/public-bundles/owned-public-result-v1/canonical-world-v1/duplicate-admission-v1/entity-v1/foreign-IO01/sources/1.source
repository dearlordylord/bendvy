import Base
import ../runtime.bend as R
import ../bundle.bend as B
import ../../complete-families-v1/canonical.bend as K
import ../observe.bend as O
import missing-drive.bend as M
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/bundle-requests.bend as Cmd
import /workspace/formal-proofs/bendvy/src/ecs/bundle-insert-adapter.bend as AD

def peer_finished(prefix:String,peer:R.World() & String) -> String:
  match peer:
    case (peer,view):prefix ++ "\npeer-after=" ++ view
def final_seen(prefix:String,peer:R.World(),session:O.Session & String,raw:B.Raw() & String) -> String:
  match session raw:
    case (session,s),(raw,r):peer_finished(prefix ++ "\nforeign-again=MissingEntity|raw=" ++ r ++ "|" ++ s,O.world(peer))
def second(prefix:String,peer:R.World(),result:R.RunResult()) -> String:
  match result:
    case Sys.Completed{reg,Sys.Succeeded{world,(ctx,Cmd.Refused{raw,AD.EntityRefused{W.MissingEntity{}}})}}:final_seen(prefix,peer,O.session(O.Session{reg,world,ctx}),K.raw_observe(raw))
    case Sys.Completed{reg,Sys.Succeeded{world,(ctx,output)}}:M.unexpected("unexpected-foreign-result",O.session(O.Session{reg,world,ctx}))
    case Sys.Completed{reg,Sys.Failed{world,error}}:M.failed(error,O.world(world))
    case Sys.RegistrationRejected{reg,world,args}:M.rejected("unexpected-registration-refusal",reg,world,args)
def seen(+target:W.Handle<K.SchemaA>,prefix:String,peer:R.World(),session:O.Session & String,raw:B.Raw() & String) -> String:
  match session raw:
    case (O.Session{reg,world,ctx},s),(raw,r):second(prefix ++ "\nforeign=MissingEntity|raw=" ++ r ++ "|" ++ s,peer,R.run(reg,world,(ctx,Cmd.Input{Cmd.Insert{target},raw})))
def first(+target:W.Handle<K.SchemaA>,prefix:String,peer:R.World(),result:R.RunResult()) -> String:
  match result:
    case Sys.Completed{reg,Sys.Succeeded{world,(ctx,Cmd.Refused{raw,AD.EntityRefused{W.MissingEntity{}}})}}:seen(target,prefix,peer,O.session(O.Session{reg,world,ctx}),K.raw_observe(raw))
    case Sys.Completed{reg,Sys.Succeeded{world,(ctx,output)}}:M.unexpected("unexpected-foreign-result",O.session(O.Session{reg,world,ctx}))
    case Sys.Completed{reg,Sys.Failed{world,error}}:M.failed(error,O.world(world))
    case Sys.RegistrationRejected{reg,world,args}:M.rejected("unexpected-registration-refusal",reg,world,args)
def initial(+target:W.Handle<K.SchemaA>,peer:R.World(),prefix:String,result:O.Session & String) -> String:
  match result:
    case (O.Session{reg,world,ctx},s):first(target,prefix ++ "\ninitial=" ++ s,peer,R.run(reg,world,(ctx,Cmd.Input{Cmd.Insert{target},M.sample()})))
def registered(peer:R.World(),+target:W.Handle<K.SchemaA>,prefix:String,result:Sys.RegistrationResult<K.SchemaA,B.Store,R.Mail,U32,R.Args(),String,R.OwnedOutput(),R.runner>) -> String:
  match result:
    case Sys.Registered{world,reg}:initial(target,peer,prefix,O.session(O.Session{reg,world,K.context(~K.SchemaA)}))
    case Sys.RegistrationFailed{world}:M.failed("unexpected-registration",O.world(world))
def peer_seen(world:R.World(),+target:W.Handle<K.SchemaA>,result:R.World() & String) -> String:
  match result:
    case (peer,view):registered(peer,target,"peer-before=" ++ view,Sys.register(~K.SchemaA,~B.Store,~R.Mail,~U32,~R.Args(),~String,~R.OwnedOutput(),~R.runner,world,"canonical-bundle",["bundle:write"]))
def activated(world:R.World(),+target:W.Handle<K.SchemaA>,result:R.World() & W.Status) -> String:
  match result:
    case (peer,W.Accepted{}):peer_seen(world,target,O.world(peer))
    case (peer,W.Rejected{error}):M.failed("unexpected-peer-activation",O.world(peer))
def reserved(world:R.World(),result:R.World() & W.Reservation<K.SchemaA>) -> String:
  match result:
    case (peer,W.Reserved{+target}):activated(world,target,W.activate(~K.SchemaA,~B.Store,~R.Mail,~U32,peer,target))
    case (peer,W.ReservationRejected{error}):M.failed("unexpected-peer-reservation",O.world(peer))
def begun(world:R.World(),peer:R.World()) -> String:reserved(world,W.reserve_id(~K.SchemaA,~B.Store,~R.Mail,~U32,peer))
