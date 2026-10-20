import Base
import ./system.bend as Sys
import ./machine.bend as M
# One transition engine, independent of the operational state carrier.
type PhaseResult<State:Type,Entry:Type> is Type:
  Complete{entries:List<Entry>,world:State}
  Failed{entries:List<Entry>,world:State,error:String}
type Owners<Entry:Type> is Type:
  Owners{exit:List<Entry>,transition:List<Entry>,enter:List<Entry>}
type HandlerResult<State:Type,Entry:Type,Phase:Data> is Type:
  Completed{owners:Owners<Entry>,world:State}
  Stopped{owners:Owners<Entry>,world:State,phase:Phase,error:String}
type Prepared<S:Data,K:Data,V:Data> is Data:
  Idle{slot:M.Slot<S,K,V>}
  BendvyReady{slot:M.Slot<S,K,V>,transition:M.Transition<V>,skipSame:Bool}
def prepend(~S:Data,~State:Type,~Entry:Type,~Phase:Data,~V:Data,~invoke:Entry -> State -> Phase -> V -> V -> Entry & Sys.Outcome<State,String,Unit>,~initial:Entry -> State -> V -> Entry & Sys.Outcome<State,String,Unit>,~exitPhase:Phase,~transitionPhase:Phase,~enterPhase:Phase,head:Entry,tail:PhaseResult<State,Entry>) -> PhaseResult<State,Entry>:
  match tail:
    case Complete{entries,world}: Complete{head <> entries,world}
    case Failed{entries,world,error}: Failed{head <> entries,world,error}

def entry_outcome(~S:Data,~State:Type,~Entry:Type,~Phase:Data,~V:Data,~invoke:Entry -> State -> Phase -> V -> V -> Entry & Sys.Outcome<State,String,Unit>,~initial:Entry -> State -> V -> Entry & Sys.Outcome<State,String,Unit>,~exitPhase:Phase,~transitionPhase:Phase,~enterPhase:Phase,entry:Entry,outcome:Sys.Outcome<State,String,Unit>,next:State -> Maybe<&2,String> -> PhaseResult<State,Entry>) -> PhaseResult<State,Entry>:
  match outcome:
    case Sys.Failed{world,error}:prepend(~S,~State,~Entry,~Phase,~V,~invoke,~initial,~exitPhase,~transitionPhase,~enterPhase,entry,next(world,Some{error}))
    case Sys.Succeeded{world,_}:prepend(~S,~State,~Entry,~Phase,~V,~invoke,~initial,~exitPhase,~transitionPhase,~enterPhase,entry,next(world,None{}))
def entry_result(~S:Data,~State:Type,~Entry:Type,~Phase:Data,~V:Data,~invoke:Entry -> State -> Phase -> V -> V -> Entry & Sys.Outcome<State,String,Unit>,~initial:Entry -> State -> V -> Entry & Sys.Outcome<State,String,Unit>,~exitPhase:Phase,~transitionPhase:Phase,~enterPhase:Phase,observed:Entry & Sys.Outcome<State,String,Unit>,next:State -> Maybe<&2,String> -> PhaseResult<State,Entry>) -> PhaseResult<State,Entry>:
  match observed:
    case (entry,outcome):entry_outcome(~S,~State,~Entry,~Phase,~V,~invoke,~initial,~exitPhase,~transitionPhase,~enterPhase,entry,outcome,next)
def run_phase(~S:Data,~State:Type,~Entry:Type,~Phase:Data,~V:Data,~invoke:Entry -> State -> Phase -> V -> V -> Entry & Sys.Outcome<State,String,Unit>,~initial:Entry -> State -> V -> Entry & Sys.Outcome<State,String,Unit>,~exitPhase:Phase,~transitionPhase:Phase,~enterPhase:Phase,entries:List<&1,Entry>,world:State,+phase:Phase,+from:V,+to:V,error:Maybe<&2,String>) -> PhaseResult<State,Entry>:
  match entries error:
    case entries Some{error}: Failed{entries,world,error}
    case [] None{}: Complete{[],world}
    case entry <> rest None{}: entry_result(~S,~State,~Entry,~Phase,~V,~invoke,~initial,~exitPhase,~transitionPhase,~enterPhase,invoke(entry,world,phase,from,to),world => error => run_phase(~S,~State,~Entry,~Phase,~V,~invoke,~initial,~exitPhase,~transitionPhase,~enterPhase,rest,world,phase,from,to,error))

def run_initial(~S:Data,~State:Type,~Entry:Type,~Phase:Data,~V:Data,~invoke:Entry -> State -> Phase -> V -> V -> Entry & Sys.Outcome<State,String,Unit>,~initial:Entry -> State -> V -> Entry & Sys.Outcome<State,String,Unit>,~exitPhase:Phase,~transitionPhase:Phase,~enterPhase:Phase,entries:List<&1,Entry>,world:State,+to:V,error:Maybe<&2,String>) -> PhaseResult<State,Entry>:
  match entries error:
    case entries Some{error}: Failed{entries,world,error}
    case [] None{}: Complete{[],world}
    case entry <> rest None{}: entry_result(~S,~State,~Entry,~Phase,~V,~invoke,~initial,~exitPhase,~transitionPhase,~enterPhase,initial(entry,world,to),world => error => run_initial(~S,~State,~Entry,~Phase,~V,~invoke,~initial,~exitPhase,~transitionPhase,~enterPhase,rest,world,to,error))

def choose(~S:Data,~K:Data,~V:Data,skip:Bool,+current:V,+value:V,previous:Maybe<&2,V>,+skipSame:Bool) -> Prepared<S,K,V>:
  match skip:
    case True{}: Idle{M.Present{current,M.NoPending{},previous,False{}}}
    case False{}: BendvyReady{M.Present{current,M.NoPending{},Some{current},False{}},M.Transition{current,value},skipSame}

def prepare(~S:Data,~K:Data,~V:Data,~same:V -> V -> Bool,slot:M.Slot<S,K,V>,captured:M.Snapshot<V>) -> Prepared<S,K,V>:
  match slot captured:
    case slot M.Unscheduled{}: Idle{M.clear_changed(~S,~K,~V,slot)}
    case M.Missing{} M.Scheduled{_,_}: Idle{M.Missing{}}
    case M.Present{+current,_,previous,_} M.Scheduled{+value,+skipSame}: choose(~S,~K,~V,Bool.and(skipSame,same(current,value)),current,value,previous,skipSame)

def committed(~S:Data,~K:Data,~V:Data,slot:M.Slot<S,K,V>,from:V,to:V) -> M.Slot<S,K,V>:
  match slot:
    case M.Missing{}: M.Missing{}
    case M.Present{_,pending,_,_}: M.Present{to,pending,Some{from},True{}}

def requeued(~S:Data,~State:Type,~Entry:Type,~Phase:Data,~V:Data,~invoke:Entry -> State -> Phase -> V -> V -> Entry & Sys.Outcome<State,String,Unit>,~initial:Entry -> State -> V -> Entry & Sys.Outcome<State,String,Unit>,~exitPhase:Phase,~transitionPhase:Phase,~enterPhase:Phase,~K:Data,~take:State -> State & M.Slot<S,K,V>,~put:State -> M.Slot<S,K,V> -> State,~publish:State -> M.Transition<V> -> State,observed:State & M.Slot<S,K,V>,to:V,skipSame:Bool) -> State:
  (world,slot)=observed
  put(world,M.queue(~S,~K,~V,slot,to,skipSame))

def published(~S:Data,~State:Type,~Entry:Type,~Phase:Data,~V:Data,~invoke:Entry -> State -> Phase -> V -> V -> Entry & Sys.Outcome<State,String,Unit>,~initial:Entry -> State -> V -> Entry & Sys.Outcome<State,String,Unit>,~exitPhase:Phase,~transitionPhase:Phase,~enterPhase:Phase,~K:Data,~take:State -> State & M.Slot<S,K,V>,~put:State -> M.Slot<S,K,V> -> State,~publish:State -> M.Transition<V> -> State,observed:State & M.Slot<S,K,V>,+from:V,+to:V) -> State:
  (world,slot)=observed
  publish(put(world,committed(~S,~K,~V,slot,from,to)),M.Transition{from,to})

def after_enter(~S:Data,~State:Type,~Entry:Type,~Phase:Data,~V:Data,~invoke:Entry -> State -> Phase -> V -> V -> Entry & Sys.Outcome<State,String,Unit>,~initial:Entry -> State -> V -> Entry & Sys.Outcome<State,String,Unit>,~exitPhase:Phase,~transitionPhase:Phase,~enterPhase:Phase,exit:List<&1,Entry>,transition:List<&1,Entry>,observed:PhaseResult<State,Entry>) -> HandlerResult<State,Entry,Phase>:
  match observed:
    case Complete{enter,world}: Completed{Owners{exit,transition,enter},world}
    case Failed{enter,world,error}: Stopped{Owners{exit,transition,enter},world,enterPhase,error}

def after_transition(~S:Data,~State:Type,~Entry:Type,~Phase:Data,~V:Data,~invoke:Entry -> State -> Phase -> V -> V -> Entry & Sys.Outcome<State,String,Unit>,~initial:Entry -> State -> V -> Entry & Sys.Outcome<State,String,Unit>,~exitPhase:Phase,~transitionPhase:Phase,~enterPhase:Phase,~K:Data,~take:State -> State & M.Slot<S,K,V>,~put:State -> M.Slot<S,K,V> -> State,~publish:State -> M.Transition<V> -> State,exit:List<&1,Entry>,enter:List<&1,Entry>,observed:PhaseResult<State,Entry>,+from:V,+to:V,skipSame:Bool) -> HandlerResult<State,Entry,Phase>:
  match observed:
    case Failed{transition,world,error}: Stopped{Owners{exit,transition,enter},requeued(~S,~State,~Entry,~Phase,~V,~invoke,~initial,~exitPhase,~transitionPhase,~enterPhase,~K,~take,~put,~publish,take(world),to,skipSame),transitionPhase,error}
    case Complete{transition,world}: after_enter(~S,~State,~Entry,~Phase,~V,~invoke,~initial,~exitPhase,~transitionPhase,~enterPhase,exit,transition,run_phase(~S,~State,~Entry,~Phase,~V,~invoke,~initial,~exitPhase,~transitionPhase,~enterPhase,enter,published(~S,~State,~Entry,~Phase,~V,~invoke,~initial,~exitPhase,~transitionPhase,~enterPhase,~K,~take,~put,~publish,take(world),from,to),enterPhase,from,to,None{}))

def after_exit(~S:Data,~State:Type,~Entry:Type,~Phase:Data,~V:Data,~invoke:Entry -> State -> Phase -> V -> V -> Entry & Sys.Outcome<State,String,Unit>,~initial:Entry -> State -> V -> Entry & Sys.Outcome<State,String,Unit>,~exitPhase:Phase,~transitionPhase:Phase,~enterPhase:Phase,~K:Data,~take:State -> State & M.Slot<S,K,V>,~put:State -> M.Slot<S,K,V> -> State,~publish:State -> M.Transition<V> -> State,transition:List<&1,Entry>,enter:List<&1,Entry>,observed:PhaseResult<State,Entry>,+from:V,+to:V,skipSame:Bool) -> HandlerResult<State,Entry,Phase>:
  match observed:
    case Failed{exit,world,error}: Stopped{Owners{exit,transition,enter},requeued(~S,~State,~Entry,~Phase,~V,~invoke,~initial,~exitPhase,~transitionPhase,~enterPhase,~K,~take,~put,~publish,take(world),to,skipSame),exitPhase,error}
    case Complete{exit,world}: after_transition(~S,~State,~Entry,~Phase,~V,~invoke,~initial,~exitPhase,~transitionPhase,~enterPhase,~K,~take,~put,~publish,exit,enter,run_phase(~S,~State,~Entry,~Phase,~V,~invoke,~initial,~exitPhase,~transitionPhase,~enterPhase,transition,world,transitionPhase,from,to,None{}),from,to,skipSame)

def prepared(~S:Data,~State:Type,~Entry:Type,~Phase:Data,~V:Data,~invoke:Entry -> State -> Phase -> V -> V -> Entry & Sys.Outcome<State,String,Unit>,~initial:Entry -> State -> V -> Entry & Sys.Outcome<State,String,Unit>,~exitPhase:Phase,~transitionPhase:Phase,~enterPhase:Phase,~K:Data,~take:State -> State & M.Slot<S,K,V>,~put:State -> M.Slot<S,K,V> -> State,~publish:State -> M.Transition<V> -> State,owners:Owners<Entry>,world:State,prepared:Prepared<S,K,V>) -> HandlerResult<State,Entry,Phase>:
  match owners prepared:
    case owners Idle{slot}: Completed{owners,put(world,slot)}
    case Owners{exit,transition,enter} BendvyReady{slot,M.Initial{to},_}:after_enter(~S,~State,~Entry,~Phase,~V,~invoke,~initial,~exitPhase,~transitionPhase,~enterPhase,exit,transition,run_initial(~S,~State,~Entry,~Phase,~V,~invoke,~initial,~exitPhase,~transitionPhase,~enterPhase,enter,put(world,slot),to,None{}))
    case Owners{exit,transition,enter} BendvyReady{slot,M.Transition{+from,+to},skipSame}: after_exit(~S,~State,~Entry,~Phase,~V,~invoke,~initial,~exitPhase,~transitionPhase,~enterPhase,~K,~take,~put,~publish,transition,enter,run_phase(~S,~State,~Entry,~Phase,~V,~invoke,~initial,~exitPhase,~transitionPhase,~enterPhase,exit,put(world,slot),exitPhase,from,to,None{}),from,to,skipSame)

def taken(~S:Data,~State:Type,~Entry:Type,~Phase:Data,~V:Data,~invoke:Entry -> State -> Phase -> V -> V -> Entry & Sys.Outcome<State,String,Unit>,~initial:Entry -> State -> V -> Entry & Sys.Outcome<State,String,Unit>,~exitPhase:Phase,~transitionPhase:Phase,~enterPhase:Phase,~K:Data,~take:State -> State & M.Slot<S,K,V>,~put:State -> M.Slot<S,K,V> -> State,~publish:State -> M.Transition<V> -> State,~same:V -> V -> Bool,owners:Owners<Entry>,observed:State & M.Slot<S,K,V>,captured:M.Snapshot<V>) -> HandlerResult<State,Entry,Phase>:
  (world,slot)=observed
  prepared(~S,~State,~Entry,~Phase,~V,~invoke,~initial,~exitPhase,~transitionPhase,~enterPhase,~K,~take,~put,~publish,owners,world,prepare(~S,~K,~V,~same,slot,captured))

def run(~S:Data,~State:Type,~Entry:Type,~Phase:Data,~V:Data,~invoke:Entry -> State -> Phase -> V -> V -> Entry & Sys.Outcome<State,String,Unit>,~initial:Entry -> State -> V -> Entry & Sys.Outcome<State,String,Unit>,~exitPhase:Phase,~transitionPhase:Phase,~enterPhase:Phase,~K:Data,~take:State -> State & M.Slot<S,K,V>,~put:State -> M.Slot<S,K,V> -> State,~publish:State -> M.Transition<V> -> State,~same:V -> V -> Bool,owners:Owners<Entry>,world:State,captured:M.Snapshot<V>) -> HandlerResult<State,Entry,Phase>:
  taken(~S,~State,~Entry,~Phase,~V,~invoke,~initial,~exitPhase,~transitionPhase,~enterPhase,~K,~take,~put,~publish,~same,owners,take(world),captured)
