import Base
import ../fixture.bend as F
import ../observe.bend as Obs
import ../authority-v1/legacy.bend as L
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-recovery.bend as Bridge
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-composer.bend as Build
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-recipe.bend as Tree
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-records.bend as Pair
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-capture-query-fields.bend as PriorApp
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-capture-query.bend as PriorOwner
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-recovery-system.bend as System
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys

type State<S:Data> is Type:
  State{app:F.Before(~S),capture:Array<Array<U32>>,text:String}
  Stopped{text:String}
def before_join(~S:Data,+debug:Bool,world:F.World(~S) & String,previous:F.Previous(~S) & String) -> F.Before(~S) & String:
  (world,wt)=world
  (previous,pt)=previous
  (Build.Registered{world,previous,Tree.Recipe{},debug},"world={" ++ wt ++ "}|previous={" ++ pt ++ "}|recipe=Recipe|debug=" ++ Bool.show(debug))

def before(~S:Data,app:F.Before(~S)) -> F.Before(~S) & String:
  match app:
    case Build.Registered{world,previous,Tree.Recipe{},debug}:before_join(~S,debug,Obs.world(~S,world),Obs.previous(~S,previous))

def observed(~S:Data,label:String,text:String,app:F.Before(~S) & String,capture:Array<Array<U32>> & String) -> State<S>:
  (app,at)=app
  (capture,ct)=capture
  State{app,capture,text ++ label ++ "|app={" ++ at ++ "}|incomingCapture=" ++ ct ++ "\n"}

def snapshot(~S:Data,label:String,value:State<S>) -> State<S>:
  match value:
    case State{app,capture,text}:observed(~S,label,text,before(~S,app),Obs.array(capture))
    case Stopped{text}:Stopped{text}

def unexpected_observed(~S:Data,text:String,debug:Bool,+ns:U32,+id:U32,+name:String,+access:List<&2,String>,+cursor:U32,world:F.World(~S) & String,prior:F.Previous(~S) & String,capture:Array<Array<U32>> & String) -> State<S>:
  (_,wt)=world
  (_,pt)=prior
  (_,ct)=capture
  Stopped{text ++ "BUG:opaque-admitted|world={" ++ wt ++ "}|prior={" ++ pt ++ "}|capture=" ++ ct ++ "|registry=" ++ U32.show(ns) ++ ":" ++ U32.show(id) ++ ":" ++ name ++ ":" ++ List.show(&2,String,x=>x,access) ++ ":cursor=" ++ U32.show(cursor) ++ "|debug=" ++ Bool.show(debug) ++ "\n"}

def unexpected(~S:Data,text:String,app:L.After(~S)) -> State<S>:
  match app:
    case Build.Registered{world,(prior,System.Owner{Sys.Registry{ns,id,name,access,cursor},capture}),Tree.Recipe{},debug}:unexpected_observed(~S,text,debug,ns,id,name,access,cursor,Obs.world(~S,world),Obs.previous(~S,prior),Obs.array(capture))

def returned(~S:Data,label:String,text:String,value:Bridge.Appended<F.Before(~S),L.After(~S),Array<Array<U32>>>) -> State<S>:
  match value:
    case Bridge.AppendRejected{app,capture}:snapshot(~S,label ++ ":rejected",State{app,capture,text})
    case Bridge.Appended{app}:unexpected(~S,text,app)

def reject(~S:Data,label:String,value:State<S>) -> State<S>:
  match value:
    case State{app,capture,text}:returned(~S,label,text,L.automatic_register(~S,app,capture))
    case Stopped{text}:Stopped{text}

def finish_observed(~S:Data,text:String,app:F.Before(~S) & String,capture:Array<Array<U32>> & String) -> String:
  (_,at)=app
  (_,ct)=capture
  text ++ "terminal|app={" ++ at ++ "}|incomingCapture=" ++ ct ++ "\n"

def finish(~S:Data,value:State<S>) -> String:
  match value:
    case State{app,capture,text}:finish_observed(~S,text,before(~S,app),Obs.array(capture))
    case Stopped{text}:text

def enabled(~S:Data,app:F.Before(~S)) -> F.Before(~S):Build.enabled(~S,~F.World(~S),~F.Previous(~S),~Unit,~Build.empty_observe(~F.World(~S)),~Pair.fold_pair(~S,~Unit,~PriorOwner.Owner<S,F.Store(~S),F.Resources(),Unit,Array<U32>,F.PriorOps,Unit,Unit,Unit,F.prior_query(~S),F.prior_body>,~Pair.empty(~S),~PriorApp.fold(~S,~F.Store(~S),~F.Resources(),~Unit,~Array<U32>,~F.PriorOps,~Unit,~Unit,~Unit,~F.prior_query(~S),~F.prior_body)),app,True{})

def registration_refused_observed(~S:Data,debug:Bool,world:F.World(~S) & String,capture:Array<U32> & String) -> String:
  (_,wt)=world
  (_,ct)=capture
  "BUG:prior-refused|world={" ++ wt ++ "}|capture=" ++ ct ++ "|debug=" ++ Bool.show(debug) ++ "\n"

def registration_refused(~S:Data,app:F.Initial(~S),capture:Array<U32>) -> String:
  match app:
    case Build.Registered{world,Unit{},Tree.Recipe{},debug}:registration_refused_observed(~S,debug,Obs.world(~S,world),Obs.element(capture))

def registered(~S:Data,value:PriorApp.Appended<F.Initial(~S),F.Before(~S),Array<U32>>) -> String:
  match value:
    case PriorApp.Appended{app}:finish(~S,reject(~S,"repeat",reject(~S,"first",snapshot(~S,"before",State{enabled(~S,app),F.array(700),""}))))
    case PriorApp.AppendRejected{app,capture}:registration_refused(~S,app,capture)

def start(~S:Data,world:F.World(~S)) -> String:
  registered(~S,F.previous_register(~S,Build.empty(~S,~F.World(~S),world),F.pair(600)))
