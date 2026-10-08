import Base
import world.bend as W
import system.bend as Sys
import machine-handlers.bend as H
import machine.bend as M

# Selection metadata has nominal schema/machine indexes; actual registry is affine.
type Selector<S:Data,K:Data,V:Data> is Data:
  ExitFrom{value:V}
  TransitionPair{from:V,to:V}
  EnterTo{value:V}
type Scheduled<S:Data,K:Data,V:Data,Q:Data,C:Type,R:Type,E:Data,-runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>> is Type:
  Scheduled{selector:Selector<S,K,V>,requirements:List<&2,Q>,entry:H.Entry<S,C,R,E,V,runner>}
type Tree<S:Data,K:Data,V:Data,Q:Data,C:Type,R:Type,E:Data,-runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>> is Type:
  Empty{}
  Single{scheduled:Scheduled<S,K,V,Q,C,R,E,runner>}
  Join{left:Tree<S,K,V,Q,C,R,E,runner>,right:Tree<S,K,V,Q,C,R,E,runner>}
type Bundle<S:Data,K:Data,V:Data,Q:Data,C:Type,R:Type,E:Data,-runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>> is Type:
  Bundle{namespace:U32,entries:List<&1,Scheduled<S,K,V,Q,C,R,E,runner>>}
type Choice is Data:
  Kept{}
  SelectedExit{}
  SelectedTransition{}
  SelectedEnter{}
type Position<S:Data,K:Data,V:Data,Q:Data> is Data:
  Position{selector:Selector<S,K,V>,requirements:List<&2,Q>,choice:Choice}
type Partition<S:Data,K:Data,V:Data,Q:Data,C:Type,R:Type,E:Data,-runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>> is Type:
  Partition{positions:List<&2,Position<S,K,V,Q>>,kept:List<&1,H.Entry<S,C,R,E,V,runner>>,owners:H.Owners<S,C,R,E,V,runner>}

def flattened(~S:Data,~K:Data,~V:Data,~Q:Data,~C:Type,~R:Type,~E:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,tree:Tree<S,K,V,Q,C,R,E,runner>) -> List<&1,Scheduled<S,K,V,Q,C,R,E,runner>>:
  match tree:
    case Empty{}: []
    case Single{scheduled}: [scheduled]
    case Join{left,right}: List.append(&1,Scheduled<S,K,V,Q,C,R,E,runner>,flattened(~S,~K,~V,~Q,~C,~R,~E,~runner,left),flattened(~S,~K,~V,~Q,~C,~R,~E,~runner,right))
def bundle(~S:Data,~K:Data,~V:Data,~Q:Data,~C:Type,~R:Type,~E:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,namespace:U32,tree:Tree<S,K,V,Q,C,R,E,runner>) -> Bundle<S,K,V,Q,C,R,E,runner>:
  Bundle{namespace,flattened(~S,~K,~V,~Q,~C,~R,~E,~runner,tree)}

def contains(~Q:Data,~same:Q -> Q -> Bool,items:List<&2,Q>,+value:Q) -> Bool:
  match items:
    case []: False{}
    case head <> tail: Bool.or(same(head,value),contains(~Q,~same,tail,value))
def collected(~Q:Data,seen:Bool,+prior:List<&2,Q>,value:Q) -> List<&2,Q>:
  match seen:
    case True{}: prior
    case False{}: List.append(&2,Q,prior,[value])
def collect(~Q:Data,~same:Q -> Q -> Bool,items:List<&2,Q>,+prior:List<&2,Q>) -> List<&2,Q>:
  match items:
    case []: prior
    case +head <> tail: collect(~Q,~same,tail,collected(~Q,contains(~Q,~same,prior,head),prior,head))
def requirements_join(~S:Data,~K:Data,~V:Data,~Q:Data,~C:Type,~R:Type,~E:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,selector:Selector<S,K,V>,+needs:List<&2,Q>,entry:H.Entry<S,C,R,E,V,runner>,tail:List<&1,Scheduled<S,K,V,Q,C,R,E,runner>> & List<&2,Q>) -> List<&1,Scheduled<S,K,V,Q,C,R,E,runner>> & List<&2,Q>:
  (entries,all)=tail
  (Scheduled{selector,needs,entry} <> entries,List.append(&2,Q,needs,all))
def requirements(~S:Data,~K:Data,~V:Data,~Q:Data,~C:Type,~R:Type,~E:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,entries:List<&1,Scheduled<S,K,V,Q,C,R,E,runner>>) -> List<&1,Scheduled<S,K,V,Q,C,R,E,runner>> & List<&2,Q>:
  match entries:
    case []: ([],[])
    case Scheduled{selector,+needs,entry} <> tail: requirements_join(~S,~K,~V,~Q,~C,~R,~E,~runner,selector,needs,entry,requirements(~S,~K,~V,~Q,~C,~R,~E,~runner,tail))

def exit_choice(yes:Bool) -> Choice:
  match yes:
    case True{}: SelectedExit{}
    case False{}: Kept{}
def transition_choice(yes:Bool) -> Choice:
  match yes:
    case True{}: SelectedTransition{}
    case False{}: Kept{}
def enter_choice(yes:Bool) -> Choice:
  match yes:
    case True{}: SelectedEnter{}
    case False{}: Kept{}
def choose(~S:Data,~K:Data,~V:Data,~same:V -> V -> Bool,selector:Selector<S,K,V>,from:V,to:V) -> Choice:
  match selector:
    case ExitFrom{value}: exit_choice(same(value,to))
    case TransitionPair{old,new}: transition_choice(Bool.and(same(old,from),same(new,to)))
    case EnterTo{value}: enter_choice(same(value,to))
def placed(~S:Data,~K:Data,~V:Data,~Q:Data,~C:Type,~R:Type,~E:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,+choice:Choice,selector:Selector<S,K,V>,needs:List<&2,Q>,entry:H.Entry<S,C,R,E,V,runner>,tail:Partition<S,K,V,Q,C,R,E,runner>) -> Partition<S,K,V,Q,C,R,E,runner>:
  match choice tail:
    case Kept{} Partition{positions,kept,owners}: Partition{Position{selector,needs,choice} <> positions,entry <> kept,owners}
    case SelectedExit{} Partition{positions,kept,H.Owners{exit,transition,enter}}: Partition{Position{selector,needs,choice} <> positions,kept,H.Owners{entry <> exit,transition,enter}}
    case SelectedTransition{} Partition{positions,kept,H.Owners{exit,transition,enter}}: Partition{Position{selector,needs,choice} <> positions,kept,H.Owners{exit,entry <> transition,enter}}
    case SelectedEnter{} Partition{positions,kept,H.Owners{exit,transition,enter}}: Partition{Position{selector,needs,choice} <> positions,kept,H.Owners{exit,transition,entry <> enter}}
def partition(~S:Data,~K:Data,~V:Data,~Q:Data,~C:Type,~R:Type,~E:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,~same:V -> V -> Bool,entries:List<&1,Scheduled<S,K,V,Q,C,R,E,runner>>,+from:V,+to:V) -> Partition<S,K,V,Q,C,R,E,runner>:
  match entries:
    case []: Partition{[],[],H.Owners{[],[],[]}}
    case Scheduled{+selector,needs,entry} <> tail: placed(~S,~K,~V,~Q,~C,~R,~E,~runner,choose(~S,~K,~V,~same,selector,from,to),selector,needs,entry,partition(~S,~K,~V,~Q,~C,~R,~E,~runner,~same,tail,from,to))

# Recovery explicitly retains all owners even for malformed internal zippers.
# Normal public execution constructs its own partition and never accepts a zipper.
type Recovery<S:Data,K:Data,V:Data,Q:Data,C:Type,R:Type,E:Data,-runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>> is Type:
  Recovery{entries:List<&1,Scheduled<S,K,V,Q,C,R,E,runner>>,positions:List<&2,Position<S,K,V,Q>>,kept:List<&1,H.Entry<S,C,R,E,V,runner>>,owners:H.Owners<S,C,R,E,V,runner>}
type Status<Q:Data> is Data:
  Completed{}
  HandlerFailed{phase:H.Phase,error:String}
  MissingRequirements{missing:List<&2,Q>}
  ForeignBundle{}
  MachineUnavailable{}
type BundleResult<S:Data,K:Data,V:Data,Q:Data,C:Type,R:Type,E:Data,-runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>> is Type:
  Returned{bundle:Bundle<S,K,V,Q,C,R,E,runner>,world:W.World<S,C,R,E>,status:Status<Q>}
  InternalOwnerRemainder{namespace:U32,recovery:Recovery<S,K,V,Q,C,R,E,runner>,world:W.World<S,C,R,E>,status:Status<Q>}

def recovery_join(~S:Data,~K:Data,~V:Data,~Q:Data,~C:Type,~R:Type,~E:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,selector:Selector<S,K,V>,needs:List<&2,Q>,entry:H.Entry<S,C,R,E,V,runner>,tail:Recovery<S,K,V,Q,C,R,E,runner>) -> Recovery<S,K,V,Q,C,R,E,runner>:
  match tail:
    case Recovery{entries,positions,kept,owners}: Recovery{Scheduled{selector,needs,entry} <> entries,positions,kept,owners}
def recover(~S:Data,~K:Data,~V:Data,~Q:Data,~C:Type,~R:Type,~E:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,positions:List<&2,Position<S,K,V,Q>>,kept:List<&1,H.Entry<S,C,R,E,V,runner>>,owners:H.Owners<S,C,R,E,V,runner>) -> Recovery<S,K,V,Q,C,R,E,runner>:
  match positions kept owners:
    case [] kept owners: Recovery{[],[],kept,owners}
    case Position{selector,needs,Kept{}} <> rest head <> tail owners: recovery_join(~S,~K,~V,~Q,~C,~R,~E,~runner,selector,needs,head,recover(~S,~K,~V,~Q,~C,~R,~E,~runner,rest,tail,owners))
    case Position{selector,needs,SelectedExit{}} <> rest kept H.Owners{head <> tail,transition,enter}: recovery_join(~S,~K,~V,~Q,~C,~R,~E,~runner,selector,needs,head,recover(~S,~K,~V,~Q,~C,~R,~E,~runner,rest,kept,H.Owners{tail,transition,enter}))
    case Position{selector,needs,SelectedTransition{}} <> rest kept H.Owners{exit,head <> tail,enter}: recovery_join(~S,~K,~V,~Q,~C,~R,~E,~runner,selector,needs,head,recover(~S,~K,~V,~Q,~C,~R,~E,~runner,rest,kept,H.Owners{exit,tail,enter}))
    case Position{selector,needs,SelectedEnter{}} <> rest kept H.Owners{exit,transition,head <> tail}: recovery_join(~S,~K,~V,~Q,~C,~R,~E,~runner,selector,needs,head,recover(~S,~K,~V,~Q,~C,~R,~E,~runner,rest,kept,H.Owners{exit,transition,tail}))
    case positions kept owners: Recovery{[],positions,kept,owners}
def recovered(~S:Data,~K:Data,~V:Data,~Q:Data,~C:Type,~R:Type,~E:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,namespace:U32,recovery:Recovery<S,K,V,Q,C,R,E,runner>,world:W.World<S,C,R,E>,status:Status<Q>) -> BundleResult<S,K,V,Q,C,R,E,runner>:
  match recovery:
    case Recovery{entries,[],[],H.Owners{[],[],[]}}: Returned{Bundle{namespace,entries},world,status}
    case recovery: InternalOwnerRemainder{namespace,recovery,world,status}
def finished(~S:Data,~K:Data,~V:Data,~Q:Data,~C:Type,~R:Type,~E:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,namespace:U32,positions:List<&2,Position<S,K,V,Q>>,kept:List<&1,H.Entry<S,C,R,E,V,runner>>,result:H.HandlerResult<S,C,R,E,V,runner>) -> BundleResult<S,K,V,Q,C,R,E,runner>:
  match result:
    case H.Completed{owners,world}: recovered(~S,~K,~V,~Q,~C,~R,~E,~runner,namespace,recover(~S,~K,~V,~Q,~C,~R,~E,~runner,positions,kept,owners),world,Completed{})
    case H.Stopped{owners,world,phase,error}: recovered(~S,~K,~V,~Q,~C,~R,~E,~runner,namespace,recover(~S,~K,~V,~Q,~C,~R,~E,~runner,positions,kept,owners),world,HandlerFailed{phase,error})

def missing_selected(~Q:Data,allowed:Bool,value:Q,rest:List<&2,Q>) -> List<&2,Q>:
  match allowed:
    case True{}: rest
    case False{}: value <> rest
def missing_join(~S:Data,~C:Type,~R:Type,~E:Data,~Q:Data,allowed:Bool,value:Q,pair:W.World<S,C,R,E> & List<&2,Q>) -> W.World<S,C,R,E> & List<&2,Q>:
  (world,rest)=pair
  (world,missing_selected(~Q,allowed,value,rest))
def missing_checked(~S:Data,~C:Type,~R:Type,~E:Data,~Q:Data,~has:W.World<S,C,R,E> -> Q -> W.World<S,C,R,E> & Bool,pair:W.World<S,C,R,E> & Bool,+value:Q,next:W.World<S,C,R,E> -> W.World<S,C,R,E> & List<&2,Q>) -> W.World<S,C,R,E> & List<&2,Q>:
  (world,allowed)=pair
  missing_join(~S,~C,~R,~E,~Q,allowed,value,next(world))
def missing(~S:Data,~C:Type,~R:Type,~E:Data,~Q:Data,~has:W.World<S,C,R,E> -> Q -> W.World<S,C,R,E> & Bool,needs:List<&2,Q>,world:W.World<S,C,R,E>) -> W.World<S,C,R,E> & List<&2,Q>:
  match needs:
    case []: (world,[])
    case +value <> rest: missing_checked(~S,~C,~R,~E,~Q,~has,has(world,value),value,w => missing(~S,~C,~R,~E,~Q,~has,rest,w))

def partitioned_run(~S:Data,~K:Data,~V:Data,~Q:Data,~C:Type,~R:Type,~E:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,~take:W.World<S,C,R,E> -> W.World<S,C,R,E> & M.Slot<S,K,V>,~put:W.World<S,C,R,E> -> M.Slot<S,K,V> -> W.World<S,C,R,E>,~publish:W.World<S,C,R,E> -> M.Transition<V> -> W.World<S,C,R,E>,~same:V -> V -> Bool,namespace:U32,world:W.World<S,C,R,E>,captured:M.Snapshot<V>,selected:Partition<S,K,V,Q,C,R,E,runner>) -> BundleResult<S,K,V,Q,C,R,E,runner>:
  match selected:
    case Partition{positions,kept,owners}: finished(~S,~K,~V,~Q,~C,~R,~E,~runner,namespace,positions,kept,H.run(~S,~C,~R,~E,~V,~runner,~K,~take,~put,~publish,~same,owners,world,captured))
def selected_target(~S:Data,~K:Data,~V:Data,~Q:Data,~C:Type,~R:Type,~E:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,~take:W.World<S,C,R,E> -> W.World<S,C,R,E> & M.Slot<S,K,V>,~put:W.World<S,C,R,E> -> M.Slot<S,K,V> -> W.World<S,C,R,E>,~publish:W.World<S,C,R,E> -> M.Transition<V> -> W.World<S,C,R,E>,~same:V -> V -> Bool,namespace:U32,entries:List<&1,Scheduled<S,K,V,Q,C,R,E,runner>>,world:W.World<S,C,R,E>,+slot:M.Slot<S,K,V>,+current:V,pending:M.Pending<V>) -> BundleResult<S,K,V,Q,C,R,E,runner>:
  match pending:
    case M.NoPending{}: Returned{Bundle{namespace,entries},put(world,M.clear_changed(~S,~K,~V,slot)),Completed{}}
    case M.Queued{+value,+skipSame}: partitioned_run(~S,~K,~V,~Q,~C,~R,~E,~runner,~take,~put,~publish,~same,namespace,put(world,slot),M.Scheduled{value,skipSame},partition(~S,~K,~V,~Q,~C,~R,~E,~runner,~same,entries,current,value))
def selected_run(~S:Data,~K:Data,~V:Data,~Q:Data,~C:Type,~R:Type,~E:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,~take:W.World<S,C,R,E> -> W.World<S,C,R,E> & M.Slot<S,K,V>,~put:W.World<S,C,R,E> -> M.Slot<S,K,V> -> W.World<S,C,R,E>,~publish:W.World<S,C,R,E> -> M.Transition<V> -> W.World<S,C,R,E>,~same:V -> V -> Bool,namespace:U32,entries:List<&1,Scheduled<S,K,V,Q,C,R,E,runner>>,world:W.World<S,C,R,E>,slot:M.Slot<S,K,V>) -> BundleResult<S,K,V,Q,C,R,E,runner>:
  match slot:
    case M.Missing{}: Returned{Bundle{namespace,entries},put(world,M.Missing{}),MachineUnavailable{}}
    case M.Present{+current,+pending,+previous,+changed}: selected_target(~S,~K,~V,~Q,~C,~R,~E,~runner,~take,~put,~publish,~same,namespace,entries,world,M.Present{current,pending,previous,changed},current,pending)
def taken_run(~S:Data,~K:Data,~V:Data,~Q:Data,~C:Type,~R:Type,~E:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,~take:W.World<S,C,R,E> -> W.World<S,C,R,E> & M.Slot<S,K,V>,~put:W.World<S,C,R,E> -> M.Slot<S,K,V> -> W.World<S,C,R,E>,~publish:W.World<S,C,R,E> -> M.Transition<V> -> W.World<S,C,R,E>,~same:V -> V -> Bool,namespace:U32,entries:List<&1,Scheduled<S,K,V,Q,C,R,E,runner>>,pair:W.World<S,C,R,E> & M.Slot<S,K,V>) -> BundleResult<S,K,V,Q,C,R,E,runner>:
  (world,slot)=pair
  selected_run(~S,~K,~V,~Q,~C,~R,~E,~runner,~take,~put,~publish,~same,namespace,entries,world,slot)
def preflighted(~S:Data,~K:Data,~V:Data,~Q:Data,~C:Type,~R:Type,~E:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,~take:W.World<S,C,R,E> -> W.World<S,C,R,E> & M.Slot<S,K,V>,~put:W.World<S,C,R,E> -> M.Slot<S,K,V> -> W.World<S,C,R,E>,~publish:W.World<S,C,R,E> -> M.Transition<V> -> W.World<S,C,R,E>,~same:V -> V -> Bool,~requirement_same:Q -> Q -> Bool,~has:W.World<S,C,R,E> -> Q -> W.World<S,C,R,E> & Bool,~frame:W.World<S,C,R,E> -> W.World<S,C,R,E>,namespace:U32,entries:List<&1,Scheduled<S,K,V,Q,C,R,E,runner>>,checked:W.World<S,C,R,E> & List<&2,Q>) -> BundleResult<S,K,V,Q,C,R,E,runner>:
  match checked:
    case (world,[]): taken_run(~S,~K,~V,~Q,~C,~R,~E,~runner,~take,~put,~publish,~same,namespace,entries,take(frame(world)))
    case (world,missing): Returned{Bundle{namespace,entries},world,MissingRequirements{missing}}
def gathered(~S:Data,~K:Data,~V:Data,~Q:Data,~C:Type,~R:Type,~E:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,~take:W.World<S,C,R,E> -> W.World<S,C,R,E> & M.Slot<S,K,V>,~put:W.World<S,C,R,E> -> M.Slot<S,K,V> -> W.World<S,C,R,E>,~publish:W.World<S,C,R,E> -> M.Transition<V> -> W.World<S,C,R,E>,~same:V -> V -> Bool,~requirement_same:Q -> Q -> Bool,~has:W.World<S,C,R,E> -> Q -> W.World<S,C,R,E> & Bool,~frame:W.World<S,C,R,E> -> W.World<S,C,R,E>,namespace:U32,world:W.World<S,C,R,E>,pair:List<&1,Scheduled<S,K,V,Q,C,R,E,runner>> & List<&2,Q>) -> BundleResult<S,K,V,Q,C,R,E,runner>:
  (entries,needs)=pair
  preflighted(~S,~K,~V,~Q,~C,~R,~E,~runner,~take,~put,~publish,~same,~requirement_same,~has,~frame,namespace,entries,missing(~S,~C,~R,~E,~Q,~has,collect(~Q,~requirement_same,needs,[]),world))
def namespace_checked(~S:Data,~K:Data,~V:Data,~Q:Data,~C:Type,~R:Type,~E:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,~take:W.World<S,C,R,E> -> W.World<S,C,R,E> & M.Slot<S,K,V>,~put:W.World<S,C,R,E> -> M.Slot<S,K,V> -> W.World<S,C,R,E>,~publish:W.World<S,C,R,E> -> M.Transition<V> -> W.World<S,C,R,E>,~same:V -> V -> Bool,~requirement_same:Q -> Q -> Bool,~has:W.World<S,C,R,E> -> Q -> W.World<S,C,R,E> & Bool,~frame:W.World<S,C,R,E> -> W.World<S,C,R,E>,allowed:Bool,bundle:Bundle<S,K,V,Q,C,R,E,runner>,world:W.World<S,C,R,E>) -> BundleResult<S,K,V,Q,C,R,E,runner>:
  match allowed bundle:
    case False{} bundle: Returned{bundle,world,ForeignBundle{}}
    case True{} Bundle{namespace,entries}: gathered(~S,~K,~V,~Q,~C,~R,~E,~runner,~take,~put,~publish,~same,~requirement_same,~has,~frame,namespace,world,requirements(~S,~K,~V,~Q,~C,~R,~E,~runner,entries))
def namespace_join(~S:Data,~K:Data,~V:Data,~Q:Data,~C:Type,~R:Type,~E:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,~take:W.World<S,C,R,E> -> W.World<S,C,R,E> & M.Slot<S,K,V>,~put:W.World<S,C,R,E> -> M.Slot<S,K,V> -> W.World<S,C,R,E>,~publish:W.World<S,C,R,E> -> M.Transition<V> -> W.World<S,C,R,E>,~same:V -> V -> Bool,~requirement_same:Q -> Q -> Bool,~has:W.World<S,C,R,E> -> Q -> W.World<S,C,R,E> & Bool,~frame:W.World<S,C,R,E> -> W.World<S,C,R,E>,+namespace:U32,entries:List<&1,Scheduled<S,K,V,Q,C,R,E,runner>>,pair:W.World<S,C,R,E> & U32) -> BundleResult<S,K,V,Q,C,R,E,runner>:
  (world,actual)=pair
  namespace_checked(~S,~K,~V,~Q,~C,~R,~E,~runner,~take,~put,~publish,~same,~requirement_same,~has,~frame,U32.is_eq(namespace,actual),Bundle{namespace,entries},world)
def run(~S:Data,~K:Data,~V:Data,~Q:Data,~C:Type,~R:Type,~E:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,~take:W.World<S,C,R,E> -> W.World<S,C,R,E> & M.Slot<S,K,V>,~put:W.World<S,C,R,E> -> M.Slot<S,K,V> -> W.World<S,C,R,E>,~publish:W.World<S,C,R,E> -> M.Transition<V> -> W.World<S,C,R,E>,~same:V -> V -> Bool,~requirement_same:Q -> Q -> Bool,~has:W.World<S,C,R,E> -> Q -> W.World<S,C,R,E> & Bool,~frame:W.World<S,C,R,E> -> W.World<S,C,R,E>,bundle:Bundle<S,K,V,Q,C,R,E,runner>,world:W.World<S,C,R,E>) -> BundleResult<S,K,V,Q,C,R,E,runner>:
  match bundle:
    case Bundle{namespace,entries}: namespace_join(~S,~K,~V,~Q,~C,~R,~E,~runner,~take,~put,~publish,~same,~requirement_same,~has,~frame,namespace,entries,W.namespace(~S,~C,~R,~E,world))
