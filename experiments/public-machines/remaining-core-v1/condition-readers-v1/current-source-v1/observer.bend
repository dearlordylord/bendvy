import Base
import ../../../../../src/ecs/ordinary-app-schedule.bend as AS
import ../../../../../src/ecs/ordinary-app-schedule-description.bend as SD
import ../../../../../src/ecs/ordinary-app-schema.bend as SA
import ../../../../../src/ecs/ordinary-query-declaration.bend as Q
import ../../../../../src/ecs/schema-fragments.bend as Frag
import ../../../../../src/ecs/schedule-provision.bend as SP
import ../../../../../src/ecs/schedule.bend as Sch
import guards.bend as G
import ../../../../../src/ecs/ordinary-machine-condition.bend as Changed
import ../../../../../src/ecs/ordinary-condition-composition.bend as Comp
import systems.bend as Systems
import ../../../../../src/ecs/system.bend as Sys
import ../../../../../src/ecs/ordinary-app-registration-fields.bend as Fields
import ../../../../../src/ecs/machine.bend as M
import ../provider.bend as P
import fixture.bend as F
import ../../../../../src/ecs/ordinary-machine-initialization.bend as Init
import ../../../../../src/ecs/ordinary-app-observation-data.bend as DTO
import ../../../../../src/ecs/machine-stream.bend as St
import ../../../../../src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy/src/ecs/lifecycle.bend as L
import ../../../../../src/ecs/event-runtime.bend as Ev

def bool(value: Bool) -> String:
  match value:
    case True{}: "true"
    case False{}: "false"
def flow(value: P.Flow) -> String:
  match value:
    case P.Boot{}: "Boot"
    case P.Play{}: "Play"
    case P.Pause{}: "Pause"
def level(value: P.Level) -> String:
  match value:
    case P.Low{}: "0"
    case P.Middle{}: "1"
    case P.High{}: "2"
def pending(~V: Data,~show: V -> String,value: M.Pending<V>) -> String:
  match value:
    case M.NoPending{}: "none"
    case M.Queued{value,skip}: show(value) ++ ":" ++ bool(skip)
def previous(~V: Data,~show: V -> String,value: Maybe<&2,V>) -> String:
  match value:
    case None{}: "none"
    case Some{value}: show(value)
def slot(~S: Data,~K: Data,~V: Data,~show: V -> String,value: M.Slot<S,K,V>) -> String:
  match value:
    case M.Missing{}: "missing"
    case M.Present{current,next,last,changed}: show(current) ++ "(pending=" ++ pending(~V,~show,next) ++ ",previous=" ++ previous(~V,~show,last) ++ ",changed=" ++ bool(changed) ++ ")"
def transition(~V: Data,~show: V -> String,value: M.Transition<V>) -> String:
  match value:
    case M.Transition{from,to}: show(from) ++ ">" ++ show(to)
    case M.Initial{to}: "Initial>" ++ show(to)
def batch(~V: Data,~show: V -> String,value: Ev.Batch<M.Transition<V>>) -> String:
  match value:
    case Ev.Batch{tick,values}: Nat.show(tick) ++ ":" ++ List.show(&2,M.Transition<V>,value => transition(~V,~show,value),values)
def position(value: Ev.Position) -> String:
  match value:
    case Ev.Position{id,cursor,registered}: U32.show(id) ++ ":" ++ Nat.show(cursor) ++ ":" ++ Nat.show(registered)
def stream_snapshot(~V:Data,~show:V -> String,value:List<&2,Ev.Batch<M.Transition<V>>> & (List<&2,Ev.Position> & (Nat & Nat))) -> String:
  match value:
    case (batches,(positions,(dropped,frameStart))): "batches=" ++ List.show(&2,Ev.Batch<M.Transition<V>>,value => batch(~V,~show,value),batches) ++ ",positions=" ++ List.show(&2,Ev.Position,position,positions) ++ ",dropped=" ++ Nat.show(dropped) ++ ",frameStart=" ++ Nat.show(frameStart)
def stream(~V:Data,~show:V -> String,value:St.Stream<V>) -> String:
  stream_snapshot(~V,~show,St.snapshot(~V,value))
def entry(value: L.Entry) -> String:
  match value:
    case L.Entry{id,L.Stamp{added,changed}}: U32.show(id) ++ ":" ++ U32.show(added) ++ ":" ++ U32.show(changed)
def owner_view_join(pair: Array<U32> & List<&2,U32>) -> Array<U32> & String:
  (owner,values)=pair
  (owner,List.show(&2,U32,U32.show,values))
def owner_view(owner: Array<U32>) -> Array<U32> & String:
  owner_view_join(P.array_view(owner))
def cell_view_join(value: Array<U32> & String) -> Maybe<&1,Array<U32>> & String:
  (owner,text)=value
  (Some{owner},text)
def cell_view(value: Maybe<&1,Array<U32>>) -> Maybe<&1,Array<U32>> & String:
  match value:
    case None{}: (None{},"none")
    case Some{owner}: cell_view_join(owner_view(owner))

def cells_leaf(pair: Maybe<&1,Array<U32>> & String) -> Array<Maybe<&1,Array<U32>>> & List<&2,String>:
  (owner,text)=pair
  (ALeaf{owner},[text])
def cells_join(left: Array<Maybe<&1,Array<U32>>> & List<&2,String>,right: Array<Maybe<&1,Array<U32>>> & List<&2,String>) -> Array<Maybe<&1,Array<U32>>> & List<&2,String>:
  (left,a)=left
  (right,b)=right
  (ANode{left,right},List.append(&2,String,a,b))
def cells_view(values: Array<Maybe<&1,Array<U32>>>) -> Array<Maybe<&1,Array<U32>>> & List<&2,String>:
  match values:
    case ALeaf{owner}: cells_leaf(cell_view(owner))
    case ANode{left,right}: cells_join(cells_view(left),cells_view(right))
def text(value: String) -> String: value
def column_join(~S: Data,pair: Array<Maybe<&1,Array<U32>>> & List<&2,String>,+stamps: List<&2,L.Entry>) -> Col.Column<S,Array<U32>> & String:
  (values,views)=pair
  (Col.Column{values,stamps},List.show(&2,String,text,views) ++ ":stamps=" ++ List.show(&2,L.Entry,entry,stamps))
def store_join(~S: Data,pair: Col.Column<S,Array<U32>> & String) -> P.Store<S> & String:
  (column,view)=pair
  (P.Store{column},view)
def column_view(~S: Data,column: Col.Column<S,Array<U32>>) -> Col.Column<S,Array<U32>> & String:
  match column:
    case Col.Column{values,stamps}: column_join(~S,cells_view(values),stamps)
    case column: (column,"UNSUPPORTED_COLUMN_ROUTE")
def store_view(~S: Data,store: P.Store<S>) -> P.Store<S> & String:
  match store:
    case P.Store{column}: store_join(~S,column_view(~S,column))

def state(~S:Data,~K:Data,~V:Data,~show:V -> String,value:Init.State<S,K,V>) -> String:
  match value:
    case Init.State{current,events,revision}:slot(~S,~K,~V,~show,current) ++ ";stream=" ++ stream(~V,~show,events) ++ ";revision=" ++ Nat.show(revision)
def resources_view(~S:Data,resources:F.Resources<S>) -> F.Resources<S> & String:
  match resources:
    case F.Resources{+flowState,+levelState}:(F.Resources{flowState,levelState},"flow=" ++ state(~S,~P.FlowToken,~P.Flow,~flow,flowState) ++ ";level=" ++ state(~S,~P.LevelToken,~P.Level,~level,levelState))

def live_join(left: Array<Bool> & List<&2,Bool>,right: Array<Bool> & List<&2,Bool>) -> Array<Bool> & List<&2,Bool>:
  (left,a)=left
  (right,b)=right
  (ANode{left,right},List.append(&2,Bool,a,b))
def live_view(live: Array<Bool>) -> Array<Bool> & List<&2,Bool>:
  match live:
    case ALeaf{+value}: (ALeaf{value},[value])
    case ANode{left,right}: live_join(live_view(left),live_view(right))
def queue_join(~W: Type,command: W -> W,pair: List<&1,(W -> W)> & Nat) -> List<&1,(W -> W)> & Nat:
  (rest,count)=pair
  (command <> rest,1n+count)
def queue_view(~W: Type,commands: List<&1,(W -> W)>) -> List<&1,(W -> W)> & Nat:
  match commands:
    case Nil{}: ([],0n)
    case Con{command,rest}: queue_join(~W,command,queue_view(~W,rest))
def registration(value: W.RegistrationMeta) -> String:
  match value:
    case W.RegistrationMeta{id,name,access}: U32.show(id) ++ ":" ++ name ++ ":" ++ List.show(&2,String,text,access)

def world_join(~S: Data,+ns: U32,+next: U32,+high: U32,+capacity: U32,+depth: Nat,pairLive: Array<Bool> & List<&2,Bool>,pairStore: P.Store<S> & String,pairResources: F.Resources<S> & String,+events: List<&2,Unit>,pairCommands: List<&1,(W.World<S,P.Store<S>,F.Resources<S>,Unit> -> W.World<S,P.Store<S>,F.Resources<S>,Unit>)> & Nat,+registrations: List<&2,W.RegistrationMeta>,+nextSystem: U32,+clock: U32) -> W.World<S,P.Store<S>,F.Resources<S>,Unit> & String:
  (live,liveValues)=pairLive
  (store,cells)=pairStore
  (resources,resourceText)=pairResources
  (commands,commandCount)=pairCommands
  (W.World{ns,next,high,live,capacity,depth,store,resources,events,commands,registrations,nextSystem,clock},"ns=" ++ U32.show(ns) ++ ";next=" ++ U32.show(next) ++ ";high=" ++ U32.show(high) ++ ";capacity=" ++ U32.show(capacity) ++ ";depth=" ++ Nat.show(depth) ++ ";live=" ++ List.show(&2,Bool,bool,liveValues) ++ ";cells=" ++ cells ++ ";" ++ resourceText ++ ";queue=" ++ Nat.show(commandCount) ++ ";registrations=" ++ List.show(&2,W.RegistrationMeta,registration,registrations) ++ ";nextSystem=" ++ U32.show(nextSystem) ++ ";componentClock=" ++ U32.show(clock) ++ ";busEvents=" ++ Nat.show(List.length(&2,Unit,events)))
def world(~S: Data,world: W.World<S,P.Store<S>,F.Resources<S>,Unit>) -> W.World<S,P.Store<S>,F.Resources<S>,Unit> & String:
  match world:
    case W.World{ns,next,high,live,capacity,depth,store,resources,events,commands,registrations,nextSystem,clock}:
      world_join(~S,ns,next,high,capacity,depth,live_view(live),store_view(~S,store),resources_view(~S,resources),events,queue_view(~W.World<S,P.Store<S>,F.Resources<S>,Unit>,commands),registrations,nextSystem,clock)

def observed(~S:Data,pair:W.World<S,P.Store<S>,F.Resources<S>,Unit> & String) -> W.World<S,P.Store<S>,F.Resources<S>,Unit> & DTO.Observation<String>:
  match pair:
    case (world,+text):(world,DTO.Observation{text,[text]})
def observe(~S:Data,value:W.World<S,P.Store<S>,F.Resources<S>,Unit>) -> W.World<S,P.Store<S>,F.Resources<S>,Unit> & DTO.Observation<String>:
  observed(~S,world(~S,value))

# Fields are projected from the actual registered instances, not a second catalog.
def fast_fields(~S:Data,value:Systems.Fast<S>) -> Systems.Fast<S> & Fields.Fields<S>:
  match value:
    case Systems.Fast{Sys.Registry{+ns,+id,+name,+access,+cursor},reader,last}:(Systems.Fast{Sys.Registry{ns,id,name,access,cursor},reader,last},Fields.Fields{ns,id,name,access,cursor,name,[],Fields.EventKind{}})
def slow_fields(~S:Data,value:Systems.Slow<S>) -> Systems.Slow<S> & Fields.Fields<S>:
  match value:
    case Systems.Slow{Sys.Registry{+ns,+id,+name,+access,+cursor},reader,last}:(Systems.Slow{Sys.Registry{ns,id,name,access,cursor},reader,last},Fields.Fields{ns,id,name,access,cursor,name,[],Fields.EventKind{}})
def folded(~S:Data,a:Systems.Fast<S> & Fields.Fields<S>,b:Systems.Slow<S> & Fields.Fields<S>) -> Systems.Owners<S> & List<&2,Fields.Fields<S>>:
  match a b:
    case (fast,fa),(slow,fb):(Systems.Owners{fast,slow},[fa,fb])
def fold(~S:Data,owners:Systems.Owners<S>) -> Systems.Owners<S> & List<&2,Fields.Fields<S>>:
  match owners:
    case Systems.Owners{fast,slow}:folded(~S,fast_fields(~S,fast),slow_fields(~S,slow))
def reading(~V:Data,~show:V -> String,value:Maybe<&2,Ev.Reading<M.Transition<V>>>) -> String:
  match value:
    case None{}:"none"
    case Some{Ev.Reading{values,lagged}}:List.show(&2,M.Transition<V>,transition(~V,~show),values) ++ ":lagged=" ++ bool(lagged)
def registry_fields(ns:U32,id:U32,name:String,access:List<&2,String>,cursor:U32) -> String:
  U32.show(ns) ++ ":" ++ U32.show(id) ++ ":" ++ name ++ ":" ++ List.show(&2,String,text,access) ++ ":" ++ U32.show(cursor)
def fast_view(~S:Data,value:Systems.Fast<S>) -> Systems.Fast<S> & String:
  match value:
    case Systems.Fast{Sys.Registry{+ns,+id,+name,+access,+cursor},St.Reader{+readerNs,+readerId},+last}:(Systems.Fast{Sys.Registry{ns,id,name,access,cursor},St.Reader{readerNs,readerId},last},"registry=" ++ registry_fields(ns,id,name,access,cursor) ++ ";reader=" ++ U32.show(readerNs) ++ ":" ++ U32.show(readerId) ++ ";last=" ++ reading(~P.Level,~level,last))
def slow_view(~S:Data,value:Systems.Slow<S>) -> Systems.Slow<S> & String:
  match value:
    case Systems.Slow{Sys.Registry{+ns,+id,+name,+access,+cursor},St.Reader{+readerNs,+readerId},+last}:(Systems.Slow{Sys.Registry{ns,id,name,access,cursor},St.Reader{readerNs,readerId},last},"registry=" ++ registry_fields(ns,id,name,access,cursor) ++ ";reader=" ++ U32.show(readerNs) ++ ":" ++ U32.show(readerId) ++ ";last=" ++ reading(~P.Flow,~flow,last))
def owners_joined(~S:Data,a:Systems.Fast<S> & String,b:Systems.Slow<S> & String) -> Systems.Owners<S> & String:
  match a b:
    case (fast,fa),(slow,fb):(Systems.Owners{fast,slow},"fast={" ++ fa ++ "};slow={" ++ fb ++ "}")
def owners(~S:Data,value:Systems.Owners<S>) -> Systems.Owners<S> & String:
  match value:
    case Systems.Owners{fast,slow}:owners_joined(~S,fast_view(~S,fast),slow_view(~S,slow))

def level_changed(~S:Data,value:G.level_changed_type(~S)) -> G.level_changed_type(~S) & String:
  match value:
    case Changed.Instance{Sys.Registry{+ns,+id,+name,+access,+cursor},+revision}:(Changed.Instance{Sys.Registry{ns,id,name,access,cursor},revision},registry_fields(ns,id,name,access,cursor) ++ ";revision=" ++ Nat.show(revision))
def flow_changed(~S:Data,value:G.flow_changed_type(~S)) -> G.flow_changed_type(~S) & String:
  match value:
    case Changed.Instance{Sys.Registry{+ns,+id,+name,+access,+cursor},+revision}:(Changed.Instance{Sys.Registry{ns,id,name,access,cursor},revision},registry_fields(ns,id,name,access,cursor) ++ ";revision=" ++ Nat.show(revision))
def fast_bound_joined(~S:Data,+id:U32,+wanted:P.Flow,pair:G.level_changed_type(~S) & String) -> G.fast_bound_type(~S) & String:
  match pair:
    case (changed,text):(Comp.BoundOwner{id,(wanted,changed)},"system=" ++ U32.show(id) ++ ";wanted=" ++ flow(wanted) ++ ";changed={" ++ text ++ "}")
def fast_bound(~S:Data,value:G.fast_bound_type(~S)) -> G.fast_bound_type(~S) & String:
  match value:
    case Comp.BoundOwner{id,(wanted,changed)}:fast_bound_joined(~S,id,wanted,level_changed(~S,changed))
def slow_bound_joined(~S:Data,+id:U32,+wanted:P.Level,pair:G.flow_changed_type(~S) & String) -> G.slow_bound_type(~S) & String:
  match pair:
    case (changed,text):(Comp.BoundOwner{id,(wanted,changed)},"system=" ++ U32.show(id) ++ ";wanted=" ++ level(wanted) ++ ";changed={" ++ text ++ "}")
def slow_bound(~S:Data,value:G.slow_bound_type(~S)) -> G.slow_bound_type(~S) & String:
  match value:
    case Comp.BoundOwner{id,(wanted,changed)}:slow_bound_joined(~S,id,wanted,flow_changed(~S,changed))
def bindings_joined(~S:Data,facts:List<&2,Comp.BindingDescription>,a:G.fast_bound_type(~S) & String,b:G.slow_bound_type(~S) & String) -> G.bindings_type(~S) & String:
  match a b:
    case (fast,fa),(slow,fb):(Comp.Bindings{(fast,slow),facts},"fast={" ++ fa ++ "};slow={" ++ fb ++ "}")
def bindings(~S:Data,value:G.bindings_type(~S)) -> G.bindings_type(~S) & String:
  match value:
    case Comp.Bindings{(fast,slow),facts}:bindings_joined(~S,facts,fast_bound(~S,fast),slow_bound(~S,slow))

def condition_leaf(value:Comp.LeafDescription) -> String:
  match value:
    case Comp.StateChanged{ns,id,name,access}:"changed(" ++ U32.show(ns) ++ ":" ++ U32.show(id) ++ ":" ++ name ++ ":" ++ List.show(&2,String,text,access) ++ ")"
    case Comp.InState{name}:"in(" ++ name ++ ")"
    case Comp.Constant{value}:"constant(" ++ bool(value) ++ ")"
def condition_description(value:Comp.Description) -> String:
  match value:
    case Comp.Description{name,access,leaves}:name ++ ":" ++ List.show(&2,String,text,access) ++ ":" ++ List.show(&2,Comp.LeafDescription,condition_leaf,leaves)
def condition_binding(value:Comp.BindingDescription) -> String:
  match value:
    case Comp.BindingDescription{id,facts}:U32.show(id) ++ ":" ++ condition_description(facts)
def maybe_condition(value:Maybe<&2,Comp.Description>) -> String:
  match value:
    case None{}:"none"
    case Some{facts}:condition_description(facts)
def condition_placement(value:SD.ConditionPlacement) -> String:
  match value:
    case SD.ConditionPlacement{position,ns,id,slot,condition}:Nat.show(position) ++ ":" ++ U32.show(ns) ++ ":" ++ U32.show(id) ++ ":" ++ U32.show(slot) ++ ":" ++ maybe_condition(condition)
def requirement(~S:Data,value:SP.Requirement<S>) -> String:
  match value:
    case SP.Component{id}:"component:" ++ U32.show(id)
    case SP.Resource{id}:"resource:" ++ U32.show(id)
    case SP.Service{id}:"service:" ++ U32.show(id)
def requirements(~S:Data,values:List<&2,SP.Requirement<S>>) -> String:List.show(&2,SP.Requirement<S>,requirement(~S),values)
def step(value:Sch.Step) -> String:
  match value:
    case Sch.System{id,condition}:"system:" ++ U32.show(id) ++ ":" ++ U32.show(condition)
    case Sch.Phase{name}:"phase:" ++ name
    case Sch.Barrier{}:"barrier"
def planned_step(~S:Data,value:AS.PlannedStep<S>) -> String:
  match value:
    case AS.PlannedStep{current,needs}:step(current) ++ ":" ++ requirements(~S,needs)
def placement(~S:Data,value:SD.Placement<S>) -> String:
  match value:
    case SD.System{position,ns,id,name,condition,needs}:Nat.show(position) ++ ":system:" ++ U32.show(ns) ++ ":" ++ U32.show(id) ++ ":" ++ previous(~String,~text,name) ++ ":" ++ U32.show(condition) ++ ":" ++ requirements(~S,needs)
    case SD.Phase{position,name,needs}:Nat.show(position) ++ ":phase:" ++ name ++ ":" ++ requirements(~S,needs)
    case SD.Barrier{position,needs}:Nat.show(position) ++ ":barrier:" ++ requirements(~S,needs)
def mode(value:Q.Mode) -> String:
  match value:
    case Q.Read{}:"read"
    case Q.Write{}:"write"
    case Q.Optional{}:"optional"
    case Q.With{}:"with"
    case Q.Without{}:"without"
    case Q.Added{}:"added"
    case Q.Changed{}:"changed"
def clause(~S:Data,value:Q.Clause<S>) -> String:
  match value:
    case Q.Clause{name,access}:name ++ ":" ++ mode(access)
def debug_binding(~S:Data,value:DTO.Binding<S>) -> String:
  match value:
    case DTO.Binding{ns,id,name,access,cursor,slot,clauses}:registry_fields(ns,id,name,access,cursor) ++ ":" ++ slot ++ ":" ++ List.show(&2,Q.Clause<S>,clause(~S),clauses)
def kind(value:Frag.RegistryKind) -> String:
  match value:
    case Frag.Component{}:"component"
    case Frag.Resource{}:"resource"
    case Frag.Event{}:"event"
    case Frag.Relation{}:"relation"
    case Frag.Service{}:"service"
def persistence(value:Frag.PersistenceKind) -> String:
  match value:
    case Frag.Plain{}:"plain"
    case Frag.Transient{}:"transient"
    case Frag.Constructed{}:"constructed"
def schema_entry(~S:Data,value:Frag.Entry<S>) -> String:
  match value:
    case Frag.Entry{category,key,name}:kind(category) ++ ":" ++ key ++ ":" ++ name
    case Frag.Classified{category,key,name,policy}:kind(category) ++ ":" ++ key ++ ":" ++ name ++ ":" ++ persistence(policy)
def application(~S:Data,value:SA.Description<S,String>) -> String:
  match value:
    case SA.Description{schema,DTO.Product{registrations,DTO.Observation{rows,rendered}}}:"schema=" ++ List.show(&2,Frag.Entry<S>,schema_entry(~S),schema) ++ ";bindings=" ++ List.show(&2,DTO.Binding<S>,debug_binding(~S),registrations) ++ ";rows={" ++ rows ++ "};rendered=" ++ List.show(&2,String,text,rendered)
def schedule_description(~S:Data,value:AS.Description<S,String>) -> String:
  match value:
    case AS.Description{app,ns,name,steps}:"application={" ++ application(~S,app) ++ "};namespace=" ++ U32.show(ns) ++ ";name=" ++ name ++ ";steps=" ++ List.show(&2,AS.PlannedStep<S>,planned_step(~S),steps)
def detailed_description(~S:Data,value:SD.Description<S,String>) -> String:
  match value:
    case SD.Description{original,placements}:schedule_description(~S,original) ++ ";placements=" ++ List.show(&2,SD.Placement<S>,placement(~S),placements)
def debug(~S:Data,value:Maybe<&2,SD.ConditionedDescription<S,String>>) -> String:
  match value:
    case None{}:"disabled"
    case Some{SD.ConditionedDescription{original,conditions,placements}}:detailed_description(~S,original) ++ ";conditions=" ++ List.show(&2,Comp.BindingDescription,condition_binding,conditions) ++ ";conditionPlacements=" ++ List.show(&2,SD.ConditionPlacement,condition_placement,placements)
def schedule_observation(value:Sch.Observation) -> String:
  match value:
    case Sch.Entered{name}:"entered:" ++ name
    case Sch.Ran{id}:"ran:" ++ U32.show(id)
    case Sch.Skipped{id}:"skipped:" ++ U32.show(id)
    case Sch.Applied{}:"applied"
def schedule_observations(values:List<&2,Sch.Observation>) -> String:List.show(&2,Sch.Observation,schedule_observation,values)
