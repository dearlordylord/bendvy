import Base
import schema.bend as S
import query.bend as Q
import gameplay.bend as G
import observe.bend as O
import ../../src/ecs/world.bend as W
import ../../src/ecs/system.bend as Sys

def World(~Schema: Data) -> Type: W.World<Schema,S.Store<Schema>,Unit,Unit>
def Writer(~Schema: Data) -> Type: Sys.Registry<Schema,S.Store<Schema>,Unit,Unit,G.Action,String,List<&2,String>,Q.runner(~Schema)>
def Watcher(~Schema: Data) -> Type: Sys.Registry<Schema,S.Store<Schema>,Unit,Unit,U32,String,List<&2,String>,Q.watcher(~Schema)>
type State<Schema: Data> is Type:
  State{factory: W.Factory,world: W.World<Schema,S.Store<Schema>,Unit,Unit>,writer: Writer(~Schema),watcher: Watcher(~Schema),lines: List<&2,String>}
def joined(~Schema: Data,factory: W.Factory,writer: Writer(~Schema),watcher: Watcher(~Schema),+lines: List<&2,String>,+label: String,observed: World(~Schema) & String) -> State<Schema>:
  (world,+rows) = observed
  State{factory,world,writer,watcher,(label ++ "|" ++ rows) <> lines}
def record(~Schema: Data,state: State<Schema>,+label: String) -> State<Schema>:
  match state:
    case State{factory,world,writer,watcher,+lines}: joined(~Schema,factory,writer,watcher,lines,label,O.rows(~Schema,world))
def change(~Schema: Data,~action: World(~Schema) -> World(~Schema),state: State<Schema>) -> State<Schema>:
  match state:
    case State{factory,world,writer,watcher,+lines}: State{factory,action(world),writer,watcher,lines}
def output(values: List<&2,String>) -> String:
  match values:
    case []: ""
    case value <> []: value
    case value <> rest: value ++ "," ++ output(rest)
def written(~Schema: Data,factory: W.Factory,watcher: Watcher(~Schema),+lines: List<&2,String>,+label: String,result: Sys.RunResult<Schema,S.Store<Schema>,Unit,Unit,G.Action,String,List<&2,String>,Q.runner(~Schema)>) -> State<Schema>:
  match result:
    case Sys.Completed{writer,Sys.Succeeded{world,+values}}: State{factory,world,writer,watcher,(label ++ "|" ++ output(values)) <> lines}
    case Sys.Completed{writer,Sys.Failed{world,+error}}: State{factory,world,writer,watcher,(label ++ "|failed:" ++ error) <> lines}
    case Sys.RegistrationRejected{writer,world,_}: State{factory,world,writer,watcher,(label ++ "|registration-rejected") <> lines}
def write(~Schema: Data,state: State<Schema>,action: G.Action,+label: String) -> State<Schema>:
  match state:
    case State{factory,world,writer,watcher,+lines}: written(~Schema,factory,watcher,lines,label,Sys.run(~Schema,~S.Store<Schema>,~Unit,~Unit,~G.Action,~String,~List<&2,String>,~Q.runner(~Schema),writer,world,action))
def watched(~Schema: Data,factory: W.Factory,writer: Writer(~Schema),+lines: List<&2,String>,+label: String,result: Sys.RunResult<Schema,S.Store<Schema>,Unit,Unit,U32,String,List<&2,String>,Q.watcher(~Schema)>) -> State<Schema>:
  match result:
    case Sys.Completed{watcher,Sys.Succeeded{world,+values}}: State{factory,world,writer,watcher,(label ++ "|" ++ output(values)) <> lines}
    case Sys.Completed{watcher,Sys.Failed{world,+error}}: State{factory,world,writer,watcher,(label ++ "|failed:" ++ error) <> lines}
    case Sys.RegistrationRejected{watcher,world,_}: State{factory,world,writer,watcher,(label ++ "|registration-rejected") <> lines}
def watch_cursor(~Schema: Data,factory: W.Factory,world: World(~Schema),writer: Writer(~Schema),+lines: List<&2,String>,+label: String,pair: Watcher(~Schema) & U32) -> State<Schema>:
  (watcher,cursor) = pair
  watched(~Schema,factory,writer,lines,label,Sys.run_tracked(~Schema,~S.Store<Schema>,~Unit,~Unit,~U32,~String,~List<&2,String>,~Q.watcher(~Schema),watcher,world,cursor))
def watch(~Schema: Data,state: State<Schema>,+label: String) -> State<Schema>:
  match state:
    case State{factory,world,writer,watcher,+lines}: watch_cursor(~Schema,factory,world,writer,lines,label,Sys.cursor(~Schema,~S.Store<Schema>,~Unit,~Unit,~U32,~String,~List<&2,String>,~Q.watcher(~Schema),watcher))
def init_watcher(~Schema: Data,factory: W.Factory,writer: Writer(~Schema),result: Sys.RegistrationResult<Schema,S.Store<Schema>,Unit,Unit,U32,String,List<&2,String>,Q.watcher(~Schema)>) -> Maybe<&1,State<Schema>>:
  match result:
    case Sys.Registered{world,watcher}: Some{State{factory,world,writer,watcher,[]}}
    case _: None{}
def init_writer(~Schema: Data,factory: W.Factory,result: Sys.RegistrationResult<Schema,S.Store<Schema>,Unit,Unit,G.Action,String,List<&2,String>,Q.runner(~Schema)>) -> Maybe<&1,State<Schema>>:
  match result:
    case Sys.Registered{world,writer}: init_watcher(~Schema,factory,writer,Sys.register(~Schema,~S.Store<Schema>,~Unit,~Unit,~U32,~String,~List<&2,String>,~Q.watcher(~Schema),world,"state-watch",["State/Phase.read","State/Phase.changed","State/Mode.read","State/Mode.changed"]))
    case _: None{}
def init_created(~Schema: Data,result: W.Creation<Schema,S.Store<Schema>,Unit,Unit>) -> Maybe<&1,State<Schema>>:
  match result:
    case W.Created{factory,world}: init_writer(~Schema,factory,Sys.register(~Schema,~S.Store<Schema>,~Unit,~Unit,~G.Action,~String,~List<&2,String>,~Q.runner(~Schema),world,"state-write",["State/Phase.write","State/Mode.write","State/Neighbor.read"]))
    case _: None{}
def barrier(~Schema: Data,world: World(~Schema)) -> World(~Schema):
  W.barrier(~Schema,~S.Store<Schema>,~Unit,~Unit,world)
def seed_phase(~Schema: Data,state: State<Schema>) -> State<Schema>:
  watch(~Schema,record(~Schema,change(~Schema,~barrier(~Schema),record(~Schema,change(~Schema,~S.seed(~Schema),record(~Schema,state,"empty")),"pending")),"seeded"),"changed-initial")
def fail_phase(~Schema: Data,state: State<Schema>) -> State<Schema>:
  watch(~Schema,record(~Schema,write(~Schema,state,G.FailAction{},"fail"),"rollback"),"changed-after-fail")
def advance_phase(~Schema: Data,state: State<Schema>) -> State<Schema>:
  watch(~Schema,record(~Schema,write(~Schema,state,G.Advance{},"advance"),"advanced"),"changed-after-advance")
def stale_phase(~Schema: Data,state: State<Schema>) -> State<Schema>:
  watch(~Schema,record(~Schema,write(~Schema,state,G.Advance{},"stale"),"stale-retains"),"changed-after-stale")
def finish_phase(~Schema: Data,state: State<Schema>) -> State<Schema>:
  watch(~Schema,record(~Schema,write(~Schema,state,G.Finish{},"finish"),"active"),"changed-after-finish")
def raw_phase(~Schema: Data,state: State<Schema>) -> State<Schema>:
  state = watch(~Schema,record(~Schema,write(~Schema,state,G.RawLegal{},"raw-phase-legal"),"raw-phase-value"),"changed-after-raw-phase")
  state = watch(~Schema,record(~Schema,write(~Schema,state,G.RawInvalid{},"raw-phase-invalid"),"raw-phase-retains"),"changed-after-invalid-phase")
  state = watch(~Schema,record(~Schema,write(~Schema,state,G.ModeRawLegal{},"raw-mode-legal"),"raw-mode-value"),"changed-after-raw-mode")
  watch(~Schema,record(~Schema,write(~Schema,state,G.ModeRawInvalid{},"raw-mode-invalid"),"raw-mode-retains"),"changed-after-invalid-mode")
def same_phase(~Schema: Data,state: State<Schema>) -> State<Schema>:
  watch(~Schema,record(~Schema,write(~Schema,state,G.Same{},"same"),"same-retains"),"changed-after-same")
def final(~Schema: Data,state: State<Schema>) -> W.Factory & List<&2,String>:
  match state:
    case State{factory,_,_,_,+lines}: (factory,List.reverse(&2,String,lines))
def scenario(~Schema: Data,state: Maybe<&1,State<Schema>>) -> W.Factory & List<&2,String>:
  match state:
    case None{}: (W.factory(),["initialization-failed"])
    case Some{state}: final(~Schema,same_phase(~Schema,raw_phase(~Schema,finish_phase(~Schema,stale_phase(~Schema,advance_phase(~Schema,fail_phase(~Schema,seed_phase(~Schema,state))))))))
def second(result: W.Factory & List<&2,String>) -> List<&2,String>:
  (_,lines) = result
  lines
def first(result: W.Factory & List<&2,String>) -> List<&2,String>:
  (factory,+lines) = result
  List.append(&2,String,lines,second(scenario(~S.SchemaB,init_created(~S.SchemaB,S.create(~S.SchemaB,factory)))))
def main() -> List<&2,String>:
  first(scenario(~S.SchemaA,init_created(~S.SchemaA,S.create(~S.SchemaA,W.factory()))))
