import Base
import ./world.bend as W
import ./machine.bend as M
import ./machine-world.bend as MW
import ./ordinary-machine-initialization.bend as Init
import ./ordinary-machine-declaration.bend as OD
import ./ordinary-machine-condition.bend as Changed
import ./system.bend as Sys
import ./schedule.bend as Sch
import ./schedule-provision.bend as SP

# Closed evaluator indices carry no runtime owner captures.
type LeafDescription is Data:
  StateChanged{namespace:U32,id:U32,name:String,access:List<&2,String>}
  InState{name:String}
  Constant{value:Bool}
type Description is Data: Description{name:String,access:List<&2,String>,leaves:List<&2,LeafDescription>}
type Evaluation<World:Type,Owner:Type> is Type:
  Value{world:World,owner:Owner,value:Bool}
  NoValue{world:World,owner:Owner}
  InvalidRegistration{world:World,owner:Owner}
  NoBinding{world:World,owner:Owner}
type Condition<World:Type,Owner:Type,-evaluate:Owner -> World -> Evaluation<World,Owner>> is Type:
  Condition{owner:Owner,description:Description}
type Returned<World:Type,Owner:Type,-evaluate:Owner -> World -> Evaluation<World,Owner>> is Type:
  Completed{world:World,condition:Condition<World,Owner,evaluate>,value:Bool}
  Unavailable{world:World,condition:Condition<World,Owner,evaluate>}
  RegistrationRejected{world:World,condition:Condition<World,Owner,evaluate>}
def description(~World:Type,~Owner:Type,~evaluate:Owner -> World -> Evaluation<World,Owner>,condition:Condition<World,Owner,evaluate>) -> Condition<World,Owner,evaluate> & Description:
  match condition:
    case Condition{owner,+facts}:(Condition{owner,facts},facts)
def returned(~World:Type,~Owner:Type,~evaluate:Owner -> World -> Evaluation<World,Owner>,facts:Description,result:Evaluation<World,Owner>) -> Returned<World,Owner,evaluate>:
  match result:
    case Value{world,owner,value}:Completed{world,Condition{owner,facts},value}
    case InvalidRegistration{world,owner}:RegistrationRejected{world,Condition{owner,facts}}
    case NoValue{world,owner}:Unavailable{world,Condition{owner,facts}}
    case NoBinding{world,owner}:Unavailable{world,Condition{owner,facts}}
def run(~World:Type,~Owner:Type,~evaluate:Owner -> World -> Evaluation<World,Owner>,condition:Condition<World,Owner,evaluate>,world:World) -> Returned<World,Owner,evaluate>:
  match condition:
    case Condition{owner,facts}:returned(~World,~Owner,~evaluate,facts,evaluate(owner,world))
def constant_value(~World:Type,world:World,+value:Bool) -> Evaluation<World,Bool>:Value{world,value,value}
def constant_run(~World:Type,value:Bool,world:World) -> Evaluation<World,Bool>:constant_value(~World,world,value)
def constant(~World:Type,+value:Bool) -> Condition<World,Bool,constant_run(~World)>:
  Condition{value,Description{Bool.show(value),[],[Constant{value}]}}

def changed_observed(~S:Data,~K:Data,~V:Data,~R:Type,~take:R -> R & Init.State<S,K,V>,~put:R -> Init.State<S,K,V> -> R,~C:Type,~E:Data,result:Changed.Observed<S,K,V,C,R,E,take,put>) -> Evaluation<W.World<S,C,R,E>,Changed.Instance<S,K,V,C,R,E,take,put>>:
  match result:
    case Changed.Observed{world,instance,Some{value}}:Value{world,instance,value}
    case Changed.Observed{world,instance,None{}}:NoValue{world,instance}
    case Changed.RegistrationRejected{world,instance}:InvalidRegistration{world,instance}
def changed_run(~S:Data,~K:Data,~V:Data,~R:Type,~take:R -> R & Init.State<S,K,V>,~put:R -> Init.State<S,K,V> -> R,~C:Type,~E:Data,instance:Changed.Instance<S,K,V,C,R,E,take,put>,world:W.World<S,C,R,E>) -> Evaluation<W.World<S,C,R,E>,Changed.Instance<S,K,V,C,R,E,take,put>>:
  changed_observed(~S,~K,~V,~R,~take,~put,~C,~E,Changed.run(~S,~K,~V,~R,~take,~put,~C,~E,instance,world))
# Registration is the existing Changed.define; no second instance is allocated.
def state_changed(~S:Data,~K:Data,~V:Data,~R:Type,~take:R -> R & Init.State<S,K,V>,~put:R -> Init.State<S,K,V> -> R,~C:Type,~E:Data,instance:Changed.Instance<S,K,V,C,R,E,take,put>) -> Condition<W.World<S,C,R,E>,Changed.Instance<S,K,V,C,R,E,take,put>,changed_run(~S,~K,~V,~R,~take,~put,~C,~E)>:
  match instance:
    case Changed.Instance{Sys.Registry{+ns,+id,+name,+access,cursor},revision}:Condition{Changed.Instance{Sys.Registry{ns,id,name,access,cursor},revision},Description{name,access,[StateChanged{ns,id,name,access}]}}

def current_observed(~S:Data,~K:Data,~V:Data,~R:Type,~take:R -> R & M.Slot<S,K,V>,~C:Type,~E:Data,~same:V -> V -> Bool,+wanted:V,observed:W.World<S,C,R,E> & M.Slot<S,K,V>) -> Evaluation<W.World<S,C,R,E>,V>:
  match observed:
    case (world,slot):Value{world,wanted,M.current_matches(~S,~K,~V,~same,slot,wanted)}
def current_run(~S:Data,~K:Data,~V:Data,~R:Type,~take:R -> R & M.Slot<S,K,V>,~C:Type,~E:Data,~same:V -> V -> Bool,wanted:V,world:W.World<S,C,R,E>) -> Evaluation<W.World<S,C,R,E>,V>:
  current_observed(~S,~K,~V,~R,~take,~C,~E,~same,wanted,MW.take(~S,~K,~V,~C,~R,~E,~take,world))
def in_state(~S:Data,~K:Data,~V:Data,~R:Type,~take:R -> R & M.Slot<S,K,V>,~C:Type,~E:Data,~same:V -> V -> Bool,~declaration:OD.Declaration<S,K,V,R,take>,wanted:V) -> Condition<W.World<S,C,R,E>,V,current_run(~S,~K,~V,~R,~take,~C,~E,~same)>:
  Condition{wanted,Description{"in_state(" ++ OD.name(~S,~K,~V,~R,~take,declaration) ++ ")",["machine." ++ OD.name(~S,~K,~V,~R,~take,declaration) ++ ".current"],[InState{OD.name(~S,~K,~V,~R,~take,declaration)}]}}

def negated(~World:Type,~Owner:Type,result:Evaluation<World,Owner>) -> Evaluation<World,Owner>:
  match result:
    case Value{world,owner,value}:Value{world,owner,Bool.not(value)}
    case NoValue{world,owner}:NoValue{world,owner}
    case InvalidRegistration{world,owner}:InvalidRegistration{world,owner}
    case NoBinding{world,owner}:NoBinding{world,owner}
def not_run(~World:Type,~Owner:Type,~evaluate:Owner -> World -> Evaluation<World,Owner>,owner:Owner,world:World) -> Evaluation<World,Owner>:negated(~World,~Owner,evaluate(owner,world))
def not(~World:Type,~Owner:Type,~evaluate:Owner -> World -> Evaluation<World,Owner>,condition:Condition<World,Owner,evaluate>) -> Condition<World,Owner,not_run(~World,~Owner,~evaluate)>:
  match condition:
    case Condition{owner,Description{name,access,leaves}}:Condition{owner,Description{"!(" ++ name ++ ")",access,leaves}}
def right_returned(~World:Type,~Left:Type,~Right:Type,left:Left,result:Evaluation<World,Right>) -> Evaluation<World,Left & Right>:
  match result:
    case Value{world,right,value}:Value{world,(left,right),value}
    case NoValue{world,right}:NoValue{world,(left,right)}
    case InvalidRegistration{world,right}:InvalidRegistration{world,(left,right)}
    case NoBinding{world,right}:NoBinding{world,(left,right)}
def combined_decision(~World:Type,~Left:Type,~Right:Type,~rightRun:Right -> World -> Evaluation<World,Right>,continue:Bool,left:Left,right:Right,world:World,value:Bool) -> Evaluation<World,Left & Right>:
  match continue:
    case False{}:Value{world,(left,right),value}
    case True{}:right_returned(~World,~Left,~Right,left,rightRun(right,world))
def same_bool(a:Bool,b:Bool) -> Bool:
  match a b:
    case True{} True{}:True{}
    case False{} False{}:True{}
    case _ _:False{}
def combined_left(~World:Type,~Left:Type,~Right:Type,~rightRun:Right -> World -> Evaluation<World,Right>,on:Bool,right:Right,result:Evaluation<World,Left>) -> Evaluation<World,Left & Right>:
  match result:
    case Value{world,left,+value}:combined_decision(~World,~Left,~Right,~rightRun,same_bool(value,on),left,right,world,value)
    case NoValue{world,left}:NoValue{world,(left,right)}
    case InvalidRegistration{world,left}:InvalidRegistration{world,(left,right)}
    case NoBinding{world,left}:NoBinding{world,(left,right)}
def and_run(~World:Type,~Left:Type,~Right:Type,~leftRun:Left -> World -> Evaluation<World,Left>,~rightRun:Right -> World -> Evaluation<World,Right>,owner:Left & Right,world:World) -> Evaluation<World,Left & Right>:
  match owner:
    case (left,right):combined_left(~World,~Left,~Right,~rightRun,True{},right,leftRun(left,world))
def or_run(~World:Type,~Left:Type,~Right:Type,~leftRun:Left -> World -> Evaluation<World,Left>,~rightRun:Right -> World -> Evaluation<World,Right>,owner:Left & Right,world:World) -> Evaluation<World,Left & Right>:
  match owner:
    case (left,right):combined_left(~World,~Left,~Right,~rightRun,False{},right,leftRun(left,world))
def and_then(~World:Type,~Left:Type,~Right:Type,~leftRun:Left -> World -> Evaluation<World,Left>,~rightRun:Right -> World -> Evaluation<World,Right>,left:Condition<World,Left,leftRun>,right:Condition<World,Right,rightRun>) -> Condition<World,Left & Right,and_run(~World,~Left,~Right,~leftRun,~rightRun)>:
  match left right:
    case Condition{lo,Description{ln,la,ll}} Condition{ro,Description{rn,ra,rl}}:Condition{(lo,ro),Description{"(" ++ ln ++ " && " ++ rn ++ ")",List.append(&2,String,la,ra),List.append(&2,LeafDescription,ll,rl)}}
def or_else(~World:Type,~Left:Type,~Right:Type,~leftRun:Left -> World -> Evaluation<World,Left>,~rightRun:Right -> World -> Evaluation<World,Right>,left:Condition<World,Left,leftRun>,right:Condition<World,Right,rightRun>) -> Condition<World,Left & Right,or_run(~World,~Left,~Right,~leftRun,~rightRun)>:
  match left right:
    case Condition{lo,Description{ln,la,ll}} Condition{ro,Description{rn,ra,rl}}:Condition{(lo,ro),Description{"(" ++ ln ++ " || " ++ rn ++ ")",List.append(&2,String,la,ra),List.append(&2,LeafDescription,ll,rl)}}

# Bindings are keyed by actual scheduled system ids, not user metadata callbacks.
type BindingDescription is Data: BindingDescription{systemId:U32,condition:Description}
type BoundOwner<Owner:Type> is Type: BoundOwner{id:U32,owner:Owner}
type Bindings<World:Type,Owner:Type,-select:Owner -> World -> U32 -> Evaluation<World,Owner>> is Type:
  Bindings{owners:Owner,descriptions:List<&2,BindingDescription>}
def bound_returned(~World:Type,~Owner:Type,id:U32,result:Evaluation<World,Owner>) -> Evaluation<World,BoundOwner<Owner>>:
  match result:
    case Value{world,owner,value}:Value{world,BoundOwner{id,owner},value}
    case NoValue{world,owner}:NoValue{world,BoundOwner{id,owner}}
    case InvalidRegistration{world,owner}:InvalidRegistration{world,BoundOwner{id,owner}}
    case NoBinding{world,owner}:NoBinding{world,BoundOwner{id,owner}}
def bound_selected(~World:Type,~Owner:Type,~evaluate:Owner -> World -> Evaluation<World,Owner>,chosen:Bool,id:U32,owner:Owner,world:World) -> Evaluation<World,BoundOwner<Owner>>:
  match chosen:
    case False{}:NoBinding{world,BoundOwner{id,owner}}
    case True{}:bound_returned(~World,~Owner,id,evaluate(owner,world))
def bound_run(~World:Type,~Owner:Type,~evaluate:Owner -> World -> Evaluation<World,Owner>,bound:BoundOwner<Owner>,world:World,target:U32) -> Evaluation<World,BoundOwner<Owner>>:
  match bound:
    case BoundOwner{+id,owner}:bound_selected(~World,~Owner,~evaluate,U32.is_eq(id,target),id,owner,world)
def bind(~World:Type,~Owner:Type,~evaluate:Owner -> World -> Evaluation<World,Owner>,+systemId:U32,condition:Condition<World,Owner,evaluate>) -> Bindings<World,BoundOwner<Owner>,bound_run(~World,~Owner,~evaluate)>:
  match condition:
    case Condition{owner,facts}:Bindings{BoundOwner{systemId,owner},[BindingDescription{systemId,facts}]}
def selected_left(~World:Type,~Left:Type,~Right:Type,~rightRun:Right -> World -> U32 -> Evaluation<World,Right>,right:Right,id:U32,result:Evaluation<World,Left>) -> Evaluation<World,Left & Right>:
  match result:
    case NoBinding{world,left}:right_returned(~World,~Left,~Right,left,rightRun(right,world,id))
    case Value{world,left,value}:Value{world,(left,right),value}
    case NoValue{world,left}:NoValue{world,(left,right)}
    case InvalidRegistration{world,left}:InvalidRegistration{world,(left,right)}
def sequence_selected(~World:Type,~Left:Type,~Right:Type,~leftRun:Left -> World -> U32 -> Evaluation<World,Left>,~rightRun:Right -> World -> U32 -> Evaluation<World,Right>,owners:Left & Right,world:World,+id:U32) -> Evaluation<World,Left & Right>:
  match owners:
    case (left,right):selected_left(~World,~Left,~Right,~rightRun,right,id,leftRun(left,world,id))
def sequence_run(~World:Type,~Left:Type,~Right:Type,~leftRun:Left -> World -> U32 -> Evaluation<World,Left>,~rightRun:Right -> World -> U32 -> Evaluation<World,Right>,owners:Left & Right,world:World,id:U32) -> Evaluation<World,Left & Right>:
  sequence_selected(~World,~Left,~Right,~leftRun,~rightRun,owners,world,id)
def sequence(~World:Type,~Left:Type,~Right:Type,~leftRun:Left -> World -> U32 -> Evaluation<World,Left>,~rightRun:Right -> World -> U32 -> Evaluation<World,Right>,left:Bindings<World,Left,leftRun>,right:Bindings<World,Right,rightRun>) -> Bindings<World,Left & Right,sequence_run(~World,~Left,~Right,~leftRun,~rightRun)>:
  match left right:
    case Bindings{lo,ld} Bindings{ro,rd}:Bindings{(lo,ro),List.append(&2,BindingDescription,ld,rd)}
def descriptions(~World:Type,~Owner:Type,~select:Owner -> World -> U32 -> Evaluation<World,Owner>,bindings:Bindings<World,Owner,select>) -> Bindings<World,Owner,select> & List<&2,BindingDescription>:
  match bindings:
    case Bindings{owner,+facts}:(Bindings{owner,facts},facts)
def has_binding(facts:List<&2,BindingDescription>,+id:U32) -> Bool:
  match facts:
    case []:False{}
    case BindingDescription{bound,_} <> rest:Bool.or(U32.is_eq(bound,id),has_binding(rest,id))
def unique_bindings(facts:List<&2,BindingDescription>,+seen:List<&2,U32>) -> Bool:
  match facts:
    case []:True{}
    case BindingDescription{+id,_} <> rest:Bool.and(Bool.not(Sch.contains(seen,id)),unique_bindings(rest,id <> seen))
def schedule_has(steps:List<&2,Sch.Step>,+id:U32) -> Bool:
  match steps:
    case []:False{}
    case Sch.System{bound,_} <> rest:Bool.or(U32.is_eq(bound,id),schedule_has(rest,id))
    case _ <> rest:schedule_has(rest,id)
def binding_targets(facts:List<&2,BindingDescription>,+steps:List<&2,Sch.Step>) -> Bool:
  match facts:
    case []:True{}
    case BindingDescription{id,_} <> rest:Bool.and(schedule_has(steps,id),binding_targets(rest,steps))
# Step.condition remains the existing opaque declaration slot. Typed guards are
# attached by system id; an absent binding is unconditional, not a false result.
type Error<BodyError:Data> is Data:
  SystemError{error:BodyError}
  ConditionRegistrationRejected{}
  ConditionUnavailable{}

type Attachment<S:Data,C:Type,R:Type,E:Data,H:Type,B:Type,-select:B -> W.World<S,C,R,E> -> U32 -> Evaluation<W.World<S,C,R,E>,B>> is Type:
  Attached{schedule:Sch.Schedule<S,C,R,E,H & Bindings<W.World<S,C,R,E>,B,select>>}
  AttachmentRejected{schedule:Sch.Schedule<S,C,R,E,H>,bindings:Bindings<W.World<S,C,R,E>,B,select>}
def attached(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~B:Type,~select:B -> W.World<S,C,R,E> -> U32 -> Evaluation<W.World<S,C,R,E>,B>,allowed:Bool,namespace:U32,name:String,+steps:List<&2,Sch.Step>,owners:H,bindings:Bindings<W.World<S,C,R,E>,B,select>,facts:List<&2,BindingDescription>) -> Attachment<S,C,R,E,H,B,select>:
  match allowed:
    case False{}:AttachmentRejected{Sch.Schedule{namespace,name,steps,owners},bindings}
    case True{}:Attached{Sch.Schedule{namespace,name,steps,(owners,bindings)}}
def attach(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~B:Type,~select:B -> W.World<S,C,R,E> -> U32 -> Evaluation<W.World<S,C,R,E>,B>,schedule:Sch.Schedule<S,C,R,E,H>,bindings:Bindings<W.World<S,C,R,E>,B,select>) -> Attachment<S,C,R,E,H,B,select>:
  match schedule bindings:
    case Sch.Schedule{namespace,name,+steps,owners} Bindings{state,+facts}:attached(~S,~C,~R,~E,~H,~B,~select,Bool.and(unique_bindings(facts,[]),binding_targets(facts,steps)),namespace,name,steps,owners,Bindings{state,facts},facts)

def body_outcome(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~B:Type,~select:B -> W.World<S,C,R,E> -> U32 -> Evaluation<W.World<S,C,R,E>,B>,~BodyError:Data,~dispatch:H -> W.World<S,C,R,E> -> U32 -> H & Sys.Outcome<W.World<S,C,R,E>,BodyError,Unit>,bindings:Bindings<W.World<S,C,R,E>,B,select>,owners:H,outcome:Sys.Outcome<W.World<S,C,R,E>,BodyError,Unit>) -> (H & Bindings<W.World<S,C,R,E>,B,select>) & Sys.Outcome<W.World<S,C,R,E>,Error<BodyError>,Unit>:
  match outcome:
    case Sys.Succeeded{world,value}:((owners,bindings),Sys.Succeeded{world,value})
    case Sys.Failed{world,error}:((owners,bindings),Sys.Failed{world,SystemError{error}})
def body_returned(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~B:Type,~select:B -> W.World<S,C,R,E> -> U32 -> Evaluation<W.World<S,C,R,E>,B>,~BodyError:Data,~dispatch:H -> W.World<S,C,R,E> -> U32 -> H & Sys.Outcome<W.World<S,C,R,E>,BodyError,Unit>,bindings:Bindings<W.World<S,C,R,E>,B,select>,returned:H & Sys.Outcome<W.World<S,C,R,E>,BodyError,Unit>) -> (H & Bindings<W.World<S,C,R,E>,B,select>) & Sys.Outcome<W.World<S,C,R,E>,Error<BodyError>,Unit>:
  match returned:
    case (owners,outcome):body_outcome(~S,~C,~R,~E,~H,~B,~select,~BodyError,~dispatch,bindings,owners,outcome)
def body_dispatch(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~B:Type,~select:B -> W.World<S,C,R,E> -> U32 -> Evaluation<W.World<S,C,R,E>,B>,~BodyError:Data,~dispatch:H -> W.World<S,C,R,E> -> U32 -> H & Sys.Outcome<W.World<S,C,R,E>,BodyError,Unit>,owners:H & Bindings<W.World<S,C,R,E>,B,select>,world:W.World<S,C,R,E>,id:U32) -> (H & Bindings<W.World<S,C,R,E>,B,select>) & Sys.Outcome<W.World<S,C,R,E>,Error<BodyError>,Unit>:
  match owners:
    case (gameplay,bindings):body_returned(~S,~C,~R,~E,~H,~B,~select,~BodyError,~dispatch,bindings,dispatch(gameplay,world,id))
def guard_decision(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~B:Type,~select:B -> W.World<S,C,R,E> -> U32 -> Evaluation<W.World<S,C,R,E>,B>,~BodyError:Data,~dispatch:H -> W.World<S,C,R,E> -> U32 -> H & Sys.Outcome<W.World<S,C,R,E>,BodyError,Unit>,next:(H & Bindings<W.World<S,C,R,E>,B,select>) -> W.World<S,C,R,E> -> List<&2,Sch.Observation> -> Sch.RunResult<S,C,R,E,H & Bindings<W.World<S,C,R,E>,B,select>,Error<BodyError>>,value:Bool,owners:H,bindings:Bindings<W.World<S,C,R,E>,B,select>,world:W.World<S,C,R,E>,+namespace:U32,+name:String,+all:List<&2,Sch.Step>,+observations:List<&2,Sch.Observation>,+id:U32) -> Sch.RunResult<S,C,R,E,H & Bindings<W.World<S,C,R,E>,B,select>,Error<BodyError>>:
  match value:
    case False{}:next((owners,bindings),world,List.append(&2,Sch.Observation,observations,[Sch.Skipped{id}]))
    case True{}:Sch.after_dispatch(~S,~C,~R,~E,~(H & Bindings<W.World<S,C,R,E>,B,select>),~Error<BodyError>,next,body_dispatch(~S,~C,~R,~E,~H,~B,~select,~BodyError,~dispatch,(owners,bindings),world,id),namespace,name,all,observations,id)
def guard_returned(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~B:Type,~select:B -> W.World<S,C,R,E> -> U32 -> Evaluation<W.World<S,C,R,E>,B>,~BodyError:Data,~dispatch:H -> W.World<S,C,R,E> -> U32 -> H & Sys.Outcome<W.World<S,C,R,E>,BodyError,Unit>,next:(H & Bindings<W.World<S,C,R,E>,B,select>) -> W.World<S,C,R,E> -> List<&2,Sch.Observation> -> Sch.RunResult<S,C,R,E,H & Bindings<W.World<S,C,R,E>,B,select>,Error<BodyError>>,facts:List<&2,BindingDescription>,owners:H,result:Evaluation<W.World<S,C,R,E>,B>,namespace:U32,name:String,all:List<&2,Sch.Step>,observations:List<&2,Sch.Observation>,id:U32) -> Sch.RunResult<S,C,R,E,H & Bindings<W.World<S,C,R,E>,B,select>,Error<BodyError>>:
  match result:
    case Value{world,state,value}:guard_decision(~S,~C,~R,~E,~H,~B,~select,~BodyError,~dispatch,next,value,owners,Bindings{state,facts},world,namespace,name,all,observations,id)
    case NoBinding{world,state}:guard_decision(~S,~C,~R,~E,~H,~B,~select,~BodyError,~dispatch,next,True{},owners,Bindings{state,facts},world,namespace,name,all,observations,id)
    case NoValue{world,state}:Sch.Failed{Sch.Schedule{namespace,name,all,(owners,Bindings{state,facts})},world,ConditionUnavailable{},observations}
    case InvalidRegistration{world,state}:Sch.Failed{Sch.Schedule{namespace,name,all,(owners,Bindings{state,facts})},world,ConditionRegistrationRejected{},observations}
def guard(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~B:Type,~select:B -> W.World<S,C,R,E> -> U32 -> Evaluation<W.World<S,C,R,E>,B>,~BodyError:Data,~dispatch:H -> W.World<S,C,R,E> -> U32 -> H & Sys.Outcome<W.World<S,C,R,E>,BodyError,Unit>,next:(H & Bindings<W.World<S,C,R,E>,B,select>) -> W.World<S,C,R,E> -> List<&2,Sch.Observation> -> Sch.RunResult<S,C,R,E,H & Bindings<W.World<S,C,R,E>,B,select>,Error<BodyError>>,owners:H & Bindings<W.World<S,C,R,E>,B,select>,world:W.World<S,C,R,E>,namespace:U32,name:String,all:List<&2,Sch.Step>,observations:List<&2,Sch.Observation>,+id:U32) -> Sch.RunResult<S,C,R,E,H & Bindings<W.World<S,C,R,E>,B,select>,Error<BodyError>>:
  match owners:
    case (gameplay,Bindings{state,facts}):guard_returned(~S,~C,~R,~E,~H,~B,~select,~BodyError,~dispatch,next,facts,gameplay,select(state,world,id),namespace,name,all,observations,id)
def execute(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~B:Type,~select:B -> W.World<S,C,R,E> -> U32 -> Evaluation<W.World<S,C,R,E>,B>,~BodyError:Data,~dispatch:H -> W.World<S,C,R,E> -> U32 -> H & Sys.Outcome<W.World<S,C,R,E>,BodyError,Unit>,steps:List<&2,Sch.Step>,owners:H & Bindings<W.World<S,C,R,E>,B,select>,world:W.World<S,C,R,E>,+namespace:U32,+name:String,+all:List<&2,Sch.Step>,observations:List<&2,Sch.Observation>) -> Sch.RunResult<S,C,R,E,H & Bindings<W.World<S,C,R,E>,B,select>,Error<BodyError>>:
  match steps:
    case []:Sch.Finished{Sch.Schedule{namespace,name,all,owners},world,observations}
    case Sch.Phase{phase} <> rest:execute(~S,~C,~R,~E,~H,~B,~select,~BodyError,~dispatch,rest,owners,world,namespace,name,all,List.append(&2,Sch.Observation,observations,[Sch.Entered{phase}]))
    case Sch.Barrier{} <> rest:execute(~S,~C,~R,~E,~H,~B,~select,~BodyError,~dispatch,rest,owners,W.barrier(~S,~C,~R,~E,world),namespace,name,all,List.append(&2,Sch.Observation,observations,[Sch.Applied{}]))
    case Sch.System{id,_} <> rest:guard(~S,~C,~R,~E,~H,~B,~select,~BodyError,~dispatch,h => w => obs => execute(~S,~C,~R,~E,~H,~B,~select,~BodyError,~dispatch,rest,h,w,namespace,name,all,obs),owners,world,namespace,name,all,observations,id)
def run_checked(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~B:Type,~select:B -> W.World<S,C,R,E> -> U32 -> Evaluation<W.World<S,C,R,E>,B>,~BodyError:Data,~dispatch:H -> W.World<S,C,R,E> -> U32 -> H & Sys.Outcome<W.World<S,C,R,E>,BodyError,Unit>,allowed:Bool,schedule:Sch.Schedule<S,C,R,E,H & Bindings<W.World<S,C,R,E>,B,select>>,world:W.World<S,C,R,E>) -> Sch.RunResult<S,C,R,E,H & Bindings<W.World<S,C,R,E>,B,select>,Error<BodyError>>:
  match allowed schedule:
    case False{} schedule:Sch.Rejected{schedule,world}
    case True{} Sch.Schedule{+namespace,+name,+steps,owners}:execute(~S,~C,~R,~E,~H,~B,~select,~BodyError,~dispatch,steps,owners,world,namespace,name,steps,[])
def run_namespaced(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~B:Type,~select:B -> W.World<S,C,R,E> -> U32 -> Evaluation<W.World<S,C,R,E>,B>,~BodyError:Data,~dispatch:H -> W.World<S,C,R,E> -> U32 -> H & Sys.Outcome<W.World<S,C,R,E>,BodyError,Unit>,schedule:Sch.Schedule<S,C,R,E,H & Bindings<W.World<S,C,R,E>,B,select>>,observed:W.World<S,C,R,E> & U32) -> Sch.RunResult<S,C,R,E,H & Bindings<W.World<S,C,R,E>,B,select>,Error<BodyError>>:
  match schedule observed:
    case Sch.Schedule{+namespace,name,+steps,(gameplay,Bindings{state,+facts})}, (world,actual):run_checked(~S,~C,~R,~E,~H,~B,~select,~BodyError,~dispatch,Bool.and(U32.is_eq(namespace,actual),Bool.and(unique_bindings(facts,[]),binding_targets(facts,steps))),Sch.Schedule{namespace,name,steps,(gameplay,Bindings{state,facts})},world)
def run_schedule(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~B:Type,~select:B -> W.World<S,C,R,E> -> U32 -> Evaluation<W.World<S,C,R,E>,B>,~BodyError:Data,~dispatch:H -> W.World<S,C,R,E> -> U32 -> H & Sys.Outcome<W.World<S,C,R,E>,BodyError,Unit>,schedule:Sch.Schedule<S,C,R,E,H & Bindings<W.World<S,C,R,E>,B,select>>,world:W.World<S,C,R,E>) -> Sch.RunResult<S,C,R,E,H & Bindings<W.World<S,C,R,E>,B,select>,Error<BodyError>>:
  run_namespaced(~S,~C,~R,~E,~H,~B,~select,~BodyError,~dispatch,schedule,W.namespace(~S,~C,~R,~E,world))

def provision_checked(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~B:Type,~select:B -> W.World<S,C,R,E> -> U32 -> Evaluation<W.World<S,C,R,E>,B>,~BodyError:Data,~dispatch:H -> W.World<S,C,R,E> -> U32 -> H & Sys.Outcome<W.World<S,C,R,E>,BodyError,Unit>,missing:List<&2,SP.Requirement<S>>,schedule:Sch.Schedule<S,C,R,E,H & Bindings<W.World<S,C,R,E>,B,select>>,world:W.World<S,C,R,E>,needs:List<&2,SP.Requirement<S>>) -> SP.ProvisionResult<S,C,R,E,H & Bindings<W.World<S,C,R,E>,B,select>,Error<BodyError>>:
  match missing:
    case first <> rest:SP.Missing{SP.Provisioned{schedule,needs},world,first <> rest}
    case []:SP.Executed{run_schedule(~S,~C,~R,~E,~H,~B,~select,~BodyError,~dispatch,schedule,world),needs}
def provision_available(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~B:Type,~select:B -> W.World<S,C,R,E> -> U32 -> Evaluation<W.World<S,C,R,E>,B>,~BodyError:Data,~dispatch:H -> W.World<S,C,R,E> -> U32 -> H & Sys.Outcome<W.World<S,C,R,E>,BodyError,Unit>,observed:W.World<S,C,R,E> & List<&2,SP.Requirement<S>>,schedule:Sch.Schedule<S,C,R,E,H & Bindings<W.World<S,C,R,E>,B,select>>,+needs:List<&2,SP.Requirement<S>>) -> SP.ProvisionResult<S,C,R,E,H & Bindings<W.World<S,C,R,E>,B,select>,Error<BodyError>>:
  match observed:
    case (world,available):provision_checked(~S,~C,~R,~E,~H,~B,~select,~BodyError,~dispatch,SP.missing_requirements(~S,needs,available),schedule,world,needs)
def run_provisioned(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~B:Type,~select:B -> W.World<S,C,R,E> -> U32 -> Evaluation<W.World<S,C,R,E>,B>,~BodyError:Data,~dispatch:H -> W.World<S,C,R,E> -> U32 -> H & Sys.Outcome<W.World<S,C,R,E>,BodyError,Unit>,~provision:W.World<S,C,R,E> -> W.World<S,C,R,E> & List<&2,SP.Requirement<S>>,schedule:SP.Provisioned<S,C,R,E,H & Bindings<W.World<S,C,R,E>,B,select>>,world:W.World<S,C,R,E>) -> SP.ProvisionResult<S,C,R,E,H & Bindings<W.World<S,C,R,E>,B,select>,Error<BodyError>>:
  match schedule:
    case SP.Provisioned{schedule,needs}:provision_available(~S,~C,~R,~E,~H,~B,~select,~BodyError,~dispatch,provision(world),schedule,needs)
