import Base
import /workspace/formal-proofs/bendvy-worktrees/bundle41-authority-refresh-v1/experiments/public-bundles/owned-public-result-v1/canonical-world-v1/duplicate-admission-v1/public-relocation-v1/B/runtime.bend as R
import /workspace/formal-proofs/bendvy-worktrees/bundle41-authority-refresh-v1/experiments/public-bundles/owned-public-result-v1/canonical-world-v1/duplicate-admission-v1/public-relocation-v1/B/bundle.bend as B
import /workspace/formal-proofs/bendvy-worktrees/bundle41-authority-refresh-v1/experiments/public-bundles/owned-public-result-v1/canonical-world-v1/complete-families-v1/canonical.bend as K
import /workspace/formal-proofs/bendvy-worktrees/bundle41-authority-refresh-v1/experiments/public-bundles/owned-public-result-v1/canonical-world-v1/duplicate-admission-v1/public-relocation-v1/B/observe.bend as O
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/decode-data.bend as Decode
import /workspace/formal-proofs/bendvy/src/ecs/bundle-pack.bend as P
import /workspace/formal-proofs/bendvy/src/ecs/bundle-requests.bend as Cmd
import /workspace/formal-proofs/bendvy/src/ecs/bundle-insert-adapter.bend as AD

def sample(raw:Decode.Raw,fail:Bool) -> B.Raw():P.Pack{K.Incoming{ANode{ALeaf{11},ALeaf{12}},raw,fail},P.Pack{K.Tail{ANode{ANode{ALeaf{21},ALeaf{22}},ANode{ALeaf{23},ALeaf{24}}},True{},31},P.Pack{K.Tag{},P.Pack{101,Unit{}}}}}
def replacement() -> B.Raw():P.Pack{K.Incoming{ANode{ALeaf{41},ALeaf{42}},Decode.Number{17},False{}},P.Pack{K.Tail{ANode{ANode{ALeaf{51},ALeaf{52}},ANode{ALeaf{53},ALeaf{54}}},False{},61},P.Pack{K.Tag{},P.Pack{202,Unit{}}}}}
def failed_world(error:String,result:R.World() & String) -> String:
  match result:
    case (world,view):"unexpected-system-failure=" ++ error ++ "|" ++ view
def rejected_raw(session:O.Session & String,raw:B.Raw() & String) -> String:
  match session raw:
    case (session,s),(raw,r):"unexpected-registration-refusal=" ++ s ++ "|raw=" ++ r
def rejected(registry:R.Registry(),world:R.World(),args:R.Args()) -> String:
  match args:
    case (context,Cmd.Input{operation,raw}):rejected_raw(O.session(O.Session{registry,world,context}),K.raw_observe(raw))
def after_run(~next:String -> O.Session -> B.Output() -> String,prefix:String,result:R.RunResult()) -> String:
  match result:
    case Sys.Completed{registry,Sys.Succeeded{world,(context,output)}}:next(prefix,O.Session{registry,world,context},output)
    case Sys.Completed{registry,Sys.Failed{world,error}}:failed_world(error,O.world(world))
    case Sys.RegistrationRejected{registry,world,args}:rejected(registry,world,args)
def run(~next:String -> O.Session -> B.Output() -> String,prefix:String,session:O.Session,input:B.Input()) -> String:
  match session:
    case O.Session{registry,world,context}:after_run(~next,prefix,R.run(registry,world,(context,input)))
def barrier(session:O.Session) -> O.Session:
  match session:
    case O.Session{registry,world,context}:O.Session{registry,W.barrier(~K.SchemaB,~B.Store,~R.Mail,~U32,world),context}
def unwind(session:O.Session) -> O.Session:
  match session:
    case O.Session{registry,world,context}:O.Session{registry,R.unwind(world),context}
def finished(prefix:String,result:O.Session & String) -> String:
  match result:
    case (session,view):prefix ++ "\ncleaned=" ++ view
def restored(prefix:String,result:O.Session & String) -> String:
  match result:
    case (session,view):finished(prefix ++ "\nrestored=" ++ view,O.session(unwind(session)))
def replaced(prefix:String,result:O.Session & String) -> String:
  match result:
    case (session,view):restored(prefix ++ "\nreplaced=" ++ view,O.session(unwind(session)))
def replacement_queued(prefix:String,result:O.Session & String) -> String:
  match result:
    case (session,view):replaced(prefix ++ "\nreplacement-queued=" ++ view,O.session(barrier(session)))
def replacement_result(prefix:String,session:O.Session,output:B.Output()) -> String:
  match output:
    case Cmd.Accepted{target,spawned}:replacement_queued(prefix,O.session(session))
    case Cmd.Refused{raw,error}:rejected_raw(O.session(session),K.raw_observe(raw))
def installed(+target:W.Handle<K.SchemaB>,prefix:String,result:O.Session & String) -> String:
  match result:
    case (session,view):run(~replacement_result,prefix ++ "\ninstalled=" ++ view,session,Cmd.Input{Cmd.Insert{target},replacement()})
def spawn_queued(+target:W.Handle<K.SchemaB>,prefix:String,result:O.Session & String) -> String:
  match result:
    case (session,view):installed(target,prefix ++ "\nspawn-queued=" ++ view,O.session(barrier(session)))
def spawn_result(prefix:String,session:O.Session,output:B.Output()) -> String:
  match output:
    case Cmd.Accepted{+target,spawned}:spawn_queued(target,prefix,O.session(session))
    case Cmd.Refused{raw,error}:rejected_raw(O.session(session),K.raw_observe(raw))
def refusal_seen(+positions:List<&2,Maybe<&2,B.ConstructorError()>>,prefix:String,session:O.Session & String,raw:B.Raw() & String) -> String:
  match session raw:
    case (session,s),(raw,r):run(~spawn_result,prefix ++ "\nrefused=" ++ List.show(&2,Maybe<&2,B.ConstructorError()>,K.position,positions) ++ "|raw=" ++ r ++ "|" ++ s,session,Cmd.Input{Cmd.Spawn{},K.repaired(raw)})
def refusal_result(prefix:String,session:O.Session,output:B.Output()) -> String:
  match output:
    case Cmd.Refused{raw,AD.ConstructionRefused{positions}}:refusal_seen(positions,prefix,O.session(session),K.raw_observe(raw))
    case Cmd.Refused{raw,error}:rejected_raw(O.session(session),K.raw_observe(raw))
    case Cmd.Accepted{target,spawned}:finished("unexpected-construction-acceptance",O.session(session))
def initial(result:O.Session & String) -> String:
  match result:
    case (session,view):run(~refusal_result,"initial=" ++ view,session,Cmd.Input{Cmd.Spawn{},sample(Decode.Text{"bad"},False{})})
def registered(result:Sys.RegistrationResult<K.SchemaB,B.Store,R.Mail,U32,R.Args(),String,R.OwnedOutput(),R.runner>) -> String:
  match result:
    case Sys.Registered{world,registry}:initial(O.session(O.Session{registry,world,K.context(~K.SchemaB)}))
    case Sys.RegistrationFailed{world}:failed_world("registration",O.world(world))
def begun(world:R.World()) -> String:registered(Sys.register(~K.SchemaB,~B.Store,~R.Mail,~U32,~R.Args(),~String,~R.OwnedOutput(),~R.runner,world,"canonical-bundle",["bundle:write"]))

def initial_returned(raw:B.Raw(),result:O.Session & String) -> String:
  match result:
    case (session,view):run(~refusal_result,"initial=" ++ view,session,Cmd.Input{Cmd.Spawn{},raw})
def registered_returned(context:K.Context<K.SchemaB>,raw:B.Raw(),result:Sys.RegistrationResult<K.SchemaB,B.Store,R.Mail,U32,R.Args(),String,R.OwnedOutput(),R.runner>) -> String:
  match result:
    case Sys.Registered{world,registry}:initial_returned(raw,O.session(O.Session{registry,world,context}))
    case Sys.RegistrationFailed{world}:failed_world("registration",O.world(world))
def begin_returned(world:R.World(),context:K.Context<K.SchemaB>,raw:B.Raw()) -> String:registered_returned(context,raw,Sys.register(~K.SchemaB,~B.Store,~R.Mail,~U32,~R.Args(),~String,~R.OwnedOutput(),~R.runner,world,"canonical-bundle",["bundle:write"]))
