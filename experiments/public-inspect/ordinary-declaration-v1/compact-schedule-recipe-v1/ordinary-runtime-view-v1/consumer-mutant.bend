import Base
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-schema.bend as Schema
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-schema.bend as SchemaApp
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-schema-product.bend as Setup
import /workspace/formal-proofs/bendvy/src/ecs/owner-product.bend as Product
import /workspace/formal-proofs/bendvy-worktrees/ordinary-schedule-debug-v1/experiments/public-inspect/ordinary-declaration-v1/compact-schedule-recipe-v1/ordinary-event-access-v1/unified-v1/types.bend as Types
import frontend-mutant.bend as Front
import /workspace/formal-proofs/bendvy-worktrees/ordinary-schedule-debug-v1/experiments/public-inspect/ordinary-declaration-v1/compact-schedule-recipe-v1/ordinary-event-access-v1/unified-v1/schema-frontend.bend as Prior
import /workspace/formal-proofs/bendvy-worktrees/ordinary-schedule-debug-v1/experiments/public-inspect/ordinary-declaration-v1/compact-schedule-recipe-v1/ordinary-event-access-v1/unified-v1/schema-consumer.bend as Mixed

type Host is Type:
  Host{app:Front.Application(),reads:List<&2,Types.Observation>,ok:Bool,presentation:Front.presentation_type()}
def published(presentation:Front.presentation_type(),reads:List<&2,Types.Observation>,result:Front.Application() & Bool) -> Host:
  match result:
    case (app,ok):Host{app,reads,ok,presentation}
def publish(host:Host,request:Types.PublishRequest) -> Host:
  match host:
    case Host{app,reads,_,presentation}:published(presentation,reads,Front.publish(app,request))
def read_returned(presentation:Front.presentation_type(),reads:List<&2,Types.Observation>,result:Front.ReadResult) -> Host:
  match result:
    case Front.ReadResult{app,None{},ok}:Host{app,reads,ok,presentation}
    case Front.ReadResult{app,Some{observation},ok}:Host{app,List.append(&2,Types.Observation,reads,[observation]),ok,presentation}
def read(host:Host,which:Bool,fail:Bool) -> Host:
  match host:
    case Host{app,reads,_,presentation}:read_returned(presentation,reads,Front.read(app,which,fail))
def begin(host:Host) -> Host:
  match host:
    case Host{app,_,_,presentation}:Host{Front.begin(app),[],True{},presentation}
def skip(host:Host) -> Host:
  match host:
    case Host{app,reads,ok,presentation}:Host{Front.skip(app),reads,ok,presentation}
def bool(value: Bool) -> String:
  match value:
    case False{}: "false"
    case True{}: "true"
def raw(value: String) -> String: value
def array(+values: List<&2,String>) -> String: List.show(~&2,~String,~raw,values)
def comma(first: Bool) -> String:
  match first:
    case False{}: ","
    case True{}: ""
def numbers_loop(items: List<&2,U32>,+acc: String,first: Bool) -> String:
  match items:
    case []: "[" ++ acc
    case value <> rest: numbers_loop(rest,U32.show(value) ++ comma(first) ++ acc,False{})
def numbers(+values: List<&2,U32>) -> String: numbers_loop(List.reverse(&2,U32,values),"]",True{})
def observation(observation: Types.Observation) -> String:
  match observation:
    case Types.Observation{reader,values,lagged}: "{\"reader\":\"" ++ reader ++ "\",\"values\":" ++ numbers(values) ++ ",\"lagged\":" ++ bool(lagged) ++ "}"
def observations(items: List<&2,Types.Observation>) -> List<&2,String>:
  match items:
    case []: []
    case item <> rest: observation(item) <> observations(rest)
def debug_returned(presentation:Front.presentation_type(),+reads:List<&2,Types.Observation>,+ok:Bool,result:Front.Application() & String) -> Host & String:
  match result:
    case (app,text):(Host{app,reads,ok,presentation},"ok=" ++ bool(ok) ++ "|reads=" ++ array(observations(reads)) ++ "|" ++ text)
def debug_combined(previous:String,result:Front.Application() & String) -> Front.Application() & String:
  match result:
    case (app,text):(app,previous ++ "|" ++ text)
def debug_runtime(previous:String,result:Front.Application() & String,flag:Bool) -> Front.Application() & String:
  match result:
    case (app,text):debug_combined(previous ++ "|" ++ text,Front.snapshot(app,flag))
def debug_observed(+presentation:Front.presentation_type(),flag:Bool,result:Front.Application() & String) -> Front.Application() & String:
  match result:
    case (app,text):debug_runtime(text,Front.runtime(app),flag)
def debug(host:Host,+flag:Bool) -> Host & String:
  match host:
    case Host{app,+reads,+ok,+presentation}:debug_returned(presentation,reads,ok,debug_observed(presentation,flag,Front.observations(presentation,Front.set_debug(app,flag))))
def repeated_last(label:String,previous:String,result:Host & String) -> Host & String:
  match result:
    case (host,text):(host,label ++ "|" ++ previous ++ "\n" ++ text)
def repeated_second(label:String,previous:String,result:Host & String) -> Host & String:
  match result:
    case (host,text):repeated_last(label,previous ++ "\n" ++ text,debug(host,False{}))
def repeated_first(label:String,previous:String,result:Host & String) -> Host & String:
  match result:
    case (host,text):repeated_second(label,previous ++ "\n" ++ text,debug(host,True{}))
def repeated_initial(label:String,result:Host & String) -> Host & String:
  match result:
    case (host,text):repeated_first(label,text,debug(host,True{}))
def snapshot(host:Host,label:String) -> Host & String:repeated_initial(label,debug(host,False{}))

type Action is Data:
  Publish{request:Types.PublishRequest}
  Read{fast: Bool,fail: Bool}
  Skip{}
type Step is Data:
  Step{label: String,actions: List<&2,Action>}
def action(action: Action,host: Host) -> Host:
  match action:
    case Publish{request}: publish(host,request)
    case Read{fast,fail}: read(host,fast,fail)
    case Skip{}: skip(host)
def actions(items: List<&2,Action>,host: Host) -> Host:
  match items:
    case []: host
    case item <> rest: actions(rest,action(item,host))
def step_finish(joined: Host & String,+previous: List<&2,String>,ih: Host -> List<&2,String> -> List<&2,String>) -> List<&2,String>:
  (host,checkpoint) = joined
  ih(host,List.append(&2,String,previous,[checkpoint]))
def steps(items: List<&2,Step>,host: Host,+previous: List<&2,String>) -> List<&2,String>:
  match items:
    case []: previous
    case Step{label,commands} <> rest: step_finish(snapshot(actions(commands,begin(host)),label),previous,host => checkpoints => steps(rest,host,checkpoints))

def scenario(host: Host,+count: U32) -> List<&2,String>:
  steps([
    Step{"initial",[]},
    Step{"register",[Read{True{},False{}},Read{False{},False{}}]},
    Step{"publish-fast",[Publish{Types.PublishRequest{10,1,Some{11},False{}}},Read{True{},False{}}]},
    Step{"slow-retains-first",[]},Step{"slow-retains-second",[]},
    Step{"failed-read",[Read{False{},True{}}]},Step{"retry-read",[Read{False{},False{}}]},
    Step{"cleanup-passed",[]},
    Step{"publish-skip",[Publish{Types.PublishRequest{20,1,None{},False{}}},Skip{}]},
    Step{"after-skip",[Read{True{},False{}}]},Step{"slow-after-skip",[Read{False{},False{}}]},
    Step{"failed-publication",[Publish{Types.PublishRequest{999,1,None{},True{}}}]},
    Step{"retry-publication",[Publish{Types.PublishRequest{21,1,None{},False{}}}]},
    Step{"both-read-retry",[Read{True{},False{}},Read{False{},False{}}]},
    Step{"capacity-first-batch",[Publish{Types.PublishRequest{30,count,None{},False{}}}]},
    Step{"capacity-second-batch",[Publish{Types.PublishRequest{40,1,Some{41},False{}}}]},
    Step{"capacity-enforced",[]},Step{"lagged-readers",[Read{True{},False{}},Read{False{},False{}}]},
    Step{"cleanup-after-lag",[]}
  ],host,[])
def ready_observed(result:Host & String) -> List<&2,String>:
  match result:
    case (host,text):List.append(&2,String,[text],scenario(host,2))
def ready(presentation:Front.presentation_type(),app:Front.Application()) -> List<&2,String>:ready_observed(snapshot(Host{Front.unsynchronized(app),[],True{},presentation},"unsynchronized-before-frame"))
def events_ready(presentation:Front.presentation_type(),app:Front.Initial()) -> List<&2,String>:
  Front.registered(~List<&2,String>,ready(presentation),Front.registration_failed(~Front.FirstReader()),Front.registration_failed(~Front.Publisher()),Front.registration_failed(~Front.Initial()),app)
def prior_ready(presentation:Front.presentation_type(),schema:Schema.Schema<Types.Schema,Setup.store(~Types.Schema,~Array<U32>),Setup.resources(~Array<U32>)>,result:Prior.SetupResult<Types.Schema>) -> List<&2,String>:
  match result:
    case Prior.Ready{app}:Front.prior_operations(events_ready(presentation),Front.start(SchemaApp.attached(~Types.Schema,~Setup.store(~Types.Schema,~Array<U32>),~Setup.resources(~Array<U32>),~U32,~Prior.owners(~Types.Schema),~Prior.rows(~Types.Schema),~Prior.observe(~Types.Schema),~Prior.fold(~Types.Schema),schema,app)))
    case _:["PriorRegistrationFailed"]
def created(presentation:Front.presentation_type(),result:Schema.Schema<Types.Schema,Setup.store(~Types.Schema,~Array<U32>),Setup.resources(~Array<U32>)> & W.Creation<Types.Schema,Setup.store(~Types.Schema,~Array<U32>),Setup.resources(~Array<U32>),U32>) -> List<&2,String>:
  match result:
    case (schema,W.Created{_,world}):prior_ready(presentation,schema,Prior.register(~Types.Schema,W.enqueue(~Types.Schema,~Setup.store(~Types.Schema,~Array<U32>),~Setup.resources(~Array<U32>),~U32,Mixed.entities(~Types.Schema,2n,True{},world),Mixed.pending(~Types.Schema))))
    case _:["CreationFailed"]
def prepared(result:Schema.Schema<Types.Schema,Setup.store(~Types.Schema,~Array<U32>),Setup.resources(~Array<U32>)> & Front.presentation_type()) -> List<&2,String>:
  match result:
    case (schema,presentation):created(presentation,SchemaApp.create(~Types.Schema,~Setup.store(~Types.Schema,~Array<U32>),~Setup.resources(~Array<U32>),~U32,~Mixed.empty_store(~Types.Schema),schema,W.factory(),Product.Owner{Unit{},Array.new(U32,0n,10)}))

def run() -> List<&2,String>:prepared(Front.prepared(Prior.declarations(~Types.Schema)))
