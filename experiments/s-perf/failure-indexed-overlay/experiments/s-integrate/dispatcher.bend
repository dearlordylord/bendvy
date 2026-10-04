import Base
import ./types.bend as T
import ./capture.bend as C
import ./schedule.bend as Q
import ./systems.bend as U
import ./readers.bend as R

type Requirement is Data:
  ResourceRequired{name: String}
  ServiceRequired{name: String}
  StateRequired{name: String}
type DispatchOutcome is Data:
  SetupRejected{reason: String}
  Complete{}
  SystemFailure{system: String,code: U32}
  MissingRuntimeRequirements{requirements: List<&2,Requirement>}
type Audit is Type:
  Console{}
  Recorded{effects:List<&2,String>}
# Actual service effect; callers retain the returned service owner.
def recorded_audit(valid:Bool,effects:List<&2,String>,text:String) -> IO(Audit):
  match valid:
    case True{}: IO.pure(Audit,Recorded{text <> effects})
    case False{}: IO.die(Audit,25,"quiet frozen Audit payload length guard")
def audit_log(owner: Audit,+text: String) -> IO(Audit):
  match owner:
    case Console{}:
      do IO<Audit>:
        IO.print(text)
        return Console{}
    case Recorded{effects}: recorded_audit(Nat.is_le(String.length(text),100n),effects,text)
def audit_present(owner: Maybe<Audit>) -> Maybe<Audit> & Bool:
  match owner:
    case None{}: (None{},False{})
    case Some{audit}: (Some{audit},True{})

def requirement_equal(left: Requirement,right: Requirement) -> Bool:
  match left right:
    case ResourceRequired{a} ResourceRequired{b}: String.eq(a,b)
    case ServiceRequired{a} ServiceRequired{b}: String.eq(a,b)
    case StateRequired{a} StateRequired{b}: String.eq(a,b)
    case _ _: False{}
def contains(+value: Requirement,values: List<&2,Requirement>) -> Bool:
  match values:
    case Nil{}: False{}
    case Con{head,tail}: Bool.or(requirement_equal(value,head),contains(value,tail))
def unique_case(found: Bool,+value: Requirement,values: List<&2,Requirement>) -> List<&2,Requirement>:
  match found:
    case True{}: values
    case False{}: List.append(&2,Requirement,values,[value])
def union_acc(other: List<&2,Requirement>,+values: List<&2,Requirement>) -> List<&2,Requirement>:
  match other:
    case Nil{}: values
    case Con{+head,tail}: union_acc(tail,unique_case(contains(head,values),head,values))
def union(values: List<&2,Requirement>,other: List<&2,Requirement>) -> List<&2,Requirement>:
  union_acc(other,values)
def missing_case(wanted: Bool,present: Bool,value: Requirement) -> List<&2,Requirement>:
  match wanted present:
    case True{} False{}: [value]
    case _ _: []
def requirements(system: Q.System,ledger: Bool,audit: Bool,state: Bool,ledgerName: String,stateName: String) -> List<&2,Requirement>:
  match system:
    case Q.System{_,_,_,needLedger,needAudit,gated,_}:
      union(union(missing_case(needLedger,ledger,ResourceRequired{ledgerName}),missing_case(needAudit,audit,ServiceRequired{"Audit"})),missing_case(gated,state,StateRequired{stateName}))
def preflight(nodes: List<&2,Q.Node>,+ledger: Bool,+audit: Bool,+state: Bool,+ledgerName: String,+stateName: String) -> List<&2,Requirement>:
  match nodes:
    case Nil{}: []
    case Con{Q.Call{system,_},tail}: union(requirements(system,ledger,audit,state,ledgerName,stateName),preflight(tail,ledger,audit,state,ledgerName,stateName))
    case Con{Q.Nested{nested},tail}: union(preflight(nested,ledger,audit,state,ledgerName,stateName),preflight(tail,ledger,audit,state,ledgerName,stateName))
    case Con{Q.Deferred{},tail}: preflight(tail,ledger,audit,state,ledgerName,stateName)
    case Con{Q.StateTransition{},tail}: preflight(tail,ledger,audit,state,ledgerName,stateName)

# Registry is authoritative; scheduled nodes carry only requested base/mode.
def registry_join(+system:Q.System,local:C.Local,tail:List<Q.Entry> & List<&2,Q.System>) -> List<Q.Entry> & List<&2,Q.System>:
  match tail:
    case (entries,systems): (Q.Entry{system,local} <> entries,system <> systems)
def registry_entries(entries:List<Q.Entry>) -> List<Q.Entry> & List<&2,Q.System>:
  match entries:
    case Nil{}: ([],[])
    case Con{Q.Entry{+system,local},tail}: registry_join(system,local,registry_entries(tail))
def registry_return(next:U32,pair:List<Q.Entry> & List<&2,Q.System>) -> Q.Registry & List<&2,Q.System>:
  match pair:
    case (entries,systems): (Q.Registry{next,entries},systems)
def registry_values(registry:Q.Registry) -> Q.Registry & List<&2,Q.System>:
  match registry:
    case Q.Registry{next,entries}: registry_return(next,registry_entries(entries))
def system_hit(equal:Bool,system:Q.System,tail:Maybe<&2,Q.System>) -> Maybe<&2,Q.System>:
  match equal:
    case True{}: Some{system}
    case False{}: tail
def system_find(+base:U32,systems:List<&2,Q.System>) -> Maybe<&2,Q.System>:
  match systems:
    case Nil{}: None{}
    case Con{Q.System{+key,name,kind,ledger,audit,gated,reader},tail}:
      system_hit(U32.is_eq(base,key),Q.System{key,name,kind,ledger,audit,gated,reader},system_find(base,tail))
type Canonical is Data:
  Accepted{nodes:List<&2,Q.Node>}
  Unknown{base:U32}
def canonical_cons(node:Q.Node,tail:Canonical) -> Canonical:
  match tail:
    case Accepted{nodes}: Accepted{node <> nodes}
    case unknown: unknown
def canonical_call(base:U32,mode:Q.Mode,found:Maybe<&2,Q.System>,tail:Canonical) -> Canonical:
  match found:
    case None{}: Unknown{base}
    case Some{system}: canonical_cons(Q.Call{system,mode},tail)
def canonical_nested(nested:Canonical,tail:Canonical) -> Canonical:
  match nested:
    case Accepted{nodes}: canonical_cons(Q.Nested{nodes},tail)
    case unknown: unknown
def canonical(+systems:List<&2,Q.System>,nodes:List<&2,Q.Node>) -> Canonical:
  match nodes:
    case Nil{}: Accepted{[]}
    case Con{Q.Call{Q.System{+base,_,_,_,_,_,_},mode},tail}: canonical_call(base,mode,system_find(base,systems),canonical(systems,tail))
    case Con{Q.Nested{nested},tail}: canonical_nested(canonical(systems,nested),canonical(systems,tail))
    case Con{node,tail}: canonical_cons(node,canonical(systems,tail))

# Trusted provisioner returns actual world/service/reader owners, not a user World.
type Invoked<-W: Type,-H: Data> is Type:
  Invoked{world: W,audit: Maybe<Audit>,run: Maybe<R.Run>,outcome: T.Outcome,clock:R.Clock,
    escaped: Maybe<&2,H>,observations: List<&2,U.Observation>}
type Visit<-W: Type,-H: Data> is Type:
  Visit{world: W,audit: Maybe<Audit>,run: Maybe<R.Run>,entries: List<Q.Entry>,outcome: DispatchOutcome,clock:R.Clock,
    escaped: Maybe<&2,H>,observations: List<&2,U.Observation>}
def visit_done(-W:Type,-H:Data,system:Q.System,local:C.Local,tail:List<Q.Entry>,result:Invoked<W,H>) -> Visit<W,H>:
  match system result:
    case Q.System{base,+name,kind,ledger,service,gated,reader} Invoked{world,audit,run,T.Success{},clock,escaped,observations}:
      Visit{world,audit,run,Q.Entry{Q.System{base,name,kind,ledger,service,gated,reader},local} <> tail,Complete{},clock,escaped,observations}
    case Q.System{base,+name,kind,ledger,service,gated,reader} Invoked{world,audit,run,T.Failure{code},clock,escaped,observations}:
      Visit{world,audit,run,Q.Entry{Q.System{base,name,kind,ledger,service,gated,reader},local} <> tail,SystemFailure{name,code},clock,escaped,observations}
def visit_local(-W:Type,-H:Data,+system:Q.System,+mode:Q.Mode,+clock:R.Clock,tail:List<Q.Entry>,world:W,audit:Maybe<Audit>,run:Maybe<R.Run>,pair:C.Local & U32,
  invoke: Q.System -> Q.Mode -> U32 -> R.Clock -> W -> Maybe<Audit> -> Maybe<R.Run> -> IO(Invoked<W,H>)) -> IO(Visit<W,H>):
  match pair:
    case (local,count): IO.bind(Invoked<W,H>,Visit<W,H>,invoke(system,mode,count,clock,world,audit,run),result => IO.pure(Visit<W,H>,visit_done(W,H,system,local,tail,result)))
def visit_restore(-W:Type,-H:Data,head:Q.Entry,result:Visit<W,H>) -> Visit<W,H>:
  match result:
    case Visit{world,audit,run,entries,outcome,clock,escaped,observations}: Visit{world,audit,run,head <> entries,outcome,clock,escaped,observations}
def visit_decide(~W:Type,~H:Data,~invoke:Q.System -> Q.Mode -> U32 -> R.Clock -> W -> Maybe<Audit> -> Maybe<R.Run> -> IO(Invoked<W,H>),
  ih: List<Q.Entry> -> W -> Maybe<Audit> -> Maybe<R.Run> -> IO(Visit<W,H>),hit:Bool,+base:U32,+mode:Q.Mode,+clock:R.Clock,+style:C.Style,system:Q.System,local:C.Local,tail:List<Q.Entry>,world:W,audit:Maybe<Audit>,run:Maybe<R.Run>) -> IO(Visit<W,H>):
  match hit:
    case True{}: visit_local(W,H,system,mode,clock,tail,world,audit,run,C.invoke(style,local),invoke)
    case False{}: IO.bind(Visit<W,H>,Visit<W,H>,ih(tail,world,audit,run),result => IO.pure(Visit<W,H>,visit_restore(W,H,Q.Entry{system,local},result)))
def visit(~W:Type,~H:Data,~invoke:Q.System -> Q.Mode -> U32 -> R.Clock -> W -> Maybe<Audit> -> Maybe<R.Run> -> IO(Invoked<W,H>),
  fuel:Nat,+base:U32,+mode:Q.Mode,+clock:R.Clock,+style:C.Style,entries:List<Q.Entry>,world:W,audit:Maybe<Audit>,run:Maybe<R.Run>) -> IO(Visit<W,H>):
  match fuel entries:
    case 0n _: IO.pure(Visit<W,H>,Visit{world,audit,run,entries,SetupRejected{"system-search bound"},clock,None{},[]})
    case 1n+rest Nil{}: IO.pure(Visit<W,H>,Visit{world,audit,run,[],SetupRejected{"unregistered base"},clock,None{},[]})
    case 1n+rest Con{Q.Entry{Q.System{+key,name,kind,ledger,service,gated,reader},local},tail}:
      visit_decide(W,H,invoke,es => w => a => r => visit(W,H,invoke,rest,base,mode,clock,style,es,w,a,r),U32.is_eq(base,key),base,mode,clock,style,Q.System{key,name,kind,ledger,service,gated,reader},local,tail,world,audit,run)

type Presence is Data:
  Presence{ledger: Bool,modeOn: Bool}
type Runtime<-W:Type,-H:Data> is Type:
  Runtime{world:W,registry:Q.Registry,readers:R.Readers,clock:R.Clock,audit:Maybe<Audit>,style:C.Style,
    escaped:List<&2,H>,observations:List<&2,U.Observation>,nextMode:Maybe<&2,Bool>}
type Dispatched<-W:Type,-H:Data> is Type:
  Dispatched{runtime:Runtime<W,H>,outcome:DispatchOutcome}

def reader_finish(readers:R.Readers,run:Maybe<R.Run>,outcome:DispatchOutcome) -> R.Readers:
  match run outcome:
    case None{} _: readers
    case Some{run} Complete{}: R.complete(readers,run,T.Success{})
    case Some{run} SystemFailure{_,code}: R.complete(readers,run,T.Failure{code})
    case Some{run} _: R.complete(readers,run,T.Failure{7})
def add_escape(-H:Data,escaped:List<&2,H>,handle:Maybe<&2,H>) -> List<&2,H>:
  match handle:
    case None{}: escaped
    case Some{h}: List.append(&2,H,escaped,[h])
def leaf_done(-W:Type,-H:Data,+next:U32,readers:R.Readers,style:C.Style,escaped:List<&2,H>,observations:List<&2,U.Observation>,nextMode:Maybe<&2,Bool>,visit:Visit<W,H>) -> Dispatched<W,H>:
  match visit:
    case Visit{world,audit,run,entries,+outcome,clock,handle,seen}:
      Dispatched{Runtime{world,Q.Registry{next,entries},reader_finish(readers,run,outcome),clock,audit,style,
        add_escape(H,escaped,handle),List.append(&2,U.Observation,observations,seen),nextMode},outcome}
def clock_tick(clock:R.Clock) -> U32:
  match clock:
    case R.Clock{tick,_,_,_}: tick

def leaf_started(~W:Type,~H:Data,~invoke:Q.System -> Q.Mode -> U32 -> R.Clock -> W -> Maybe<Audit> -> Maybe<R.Run> -> IO(Invoked<W,H>),
  +base:U32,mode:Q.Mode,world:W,registry:Q.Registry,audit:Maybe<Audit>,+style:C.Style,escaped:List<&2,H>,observations:List<&2,U.Observation>,nextMode:Maybe<&2,Bool>,started:R.Started) -> IO(Dispatched<W,H>):
  match registry started:
    case Q.Registry{+next,entries} R.Started{readers,+clock,run}:
      IO.bind(Visit<W,H>,Dispatched<W,H>,visit(W,H,invoke,U32.to_nat(next),base,mode,clock,style,entries,world,audit,Some{run}), v => IO.pure(Dispatched<W,H>,leaf_done(W,H,next,readers,style,escaped,observations,nextMode,v)))
def leaf_unread(~W:Type,~H:Data,~invoke:Q.System -> Q.Mode -> U32 -> R.Clock -> W -> Maybe<Audit> -> Maybe<R.Run> -> IO(Invoked<W,H>),
  +base:U32,mode:Q.Mode,world:W,registry:Q.Registry,readers:R.Readers,+clock:R.Clock,audit:Maybe<Audit>,+style:C.Style,escaped:List<&2,H>,observations:List<&2,U.Observation>,nextMode:Maybe<&2,Bool>) -> IO(Dispatched<W,H>):
  match registry:
    case Q.Registry{+next,entries}:
      IO.bind(Visit<W,H>,Dispatched<W,H>,visit(W,H,invoke,U32.to_nat(next),base,mode,clock,style,entries,world,audit,None{}), v => IO.pure(Dispatched<W,H>,leaf_done(W,H,next,readers,style,escaped,observations,nextMode,v)))
def leaf_reader(~W:Type,~H:Data,~invoke:Q.System -> Q.Mode -> U32 -> R.Clock -> W -> Maybe<Audit> -> Maybe<R.Run> -> IO(Invoked<W,H>),
  reader:Bool,+base:U32,mode:Q.Mode,runtime:Runtime<W,H>) -> IO(Dispatched<W,H>):
  match reader runtime:
    case True{} Runtime{world,registry,readers,clock,audit,style,escaped,observations,nextMode}:
      leaf_started(W,H,invoke,base,mode,world,registry,audit,style,escaped,observations,nextMode,R.begin(readers,base,R.Interests{True{},[0],True{}},clock))
    case False{} Runtime{world,registry,readers,clock,audit,style,escaped,observations,nextMode}:
      leaf_unread(W,H,invoke,base,mode,world,registry,readers,R.advance(clock),audit,style,escaped,observations,nextMode)
def leaf_condition(~W:Type,~H:Data,~invoke:Q.System -> Q.Mode -> U32 -> R.Clock -> W -> Maybe<Audit> -> Maybe<R.Run> -> IO(Invoked<W,H>),
  allowed:Bool,system:Q.System,mode:Q.Mode,runtime:Runtime<W,H>) -> IO(Dispatched<W,H>):
  match allowed system runtime:
    case False{} Q.System{base,_,_,_,_,_,_} Runtime{world,registry,readers,+clock,audit,style,escaped,observations,nextMode}:
      IO.pure(Dispatched<W,H>,Dispatched{Runtime{world,registry,R.skip(readers,base,clock_tick(clock)),clock,audit,style,escaped,observations,nextMode},Complete{}})
    case True{} Q.System{base,_,_,_,_,_,reader} state: leaf_reader(W,H,invoke,reader,base,mode,state)

def continue_case(-W:Type,-H:Data,continuation:Runtime<W,H> -> IO(Dispatched<W,H>),result:Dispatched<W,H>) -> IO(Dispatched<W,H>):
  match result:
    case Dispatched{runtime,Complete{}}: continuation(runtime)
    case other: IO.pure(Dispatched<W,H>,other)

# Trusted mode observer must inspect the actual nominal World.mode, not flags.
def call_actual(~W:Type,~H:Data,~invoke:Q.System -> Q.Mode -> U32 -> R.Clock -> W -> Maybe<Audit> -> Maybe<R.Run> -> IO(Invoked<W,H>),
  system:Q.System,mode:Q.Mode,registry:Q.Registry,readers:R.Readers,clock:R.Clock,audit:Maybe<Audit>,style:C.Style,escaped:List<&2,H>,observations:List<&2,U.Observation>,nextMode:Maybe<&2,Bool>,world:W,actual:Presence) -> IO(Dispatched<W,H>):
  match system actual:
    case Q.System{base,name,kind,ledger,service,+gated,reader} Presence{_,on}:
      leaf_condition(W,H,invoke,Bool.or(Bool.not(gated),on),Q.System{base,name,kind,ledger,service,gated,reader},mode,Runtime{world,registry,readers,clock,audit,style,escaped,observations,nextMode})

def call_presence(~W:Type,~H:Data,~invoke:Q.System -> Q.Mode -> U32 -> R.Clock -> W -> Maybe<Audit> -> Maybe<R.Run> -> IO(Invoked<W,H>),
  system:Q.System,mode:Q.Mode,registry:Q.Registry,readers:R.Readers,clock:R.Clock,audit:Maybe<Audit>,style:C.Style,escaped:List<&2,H>,observations:List<&2,U.Observation>,nextMode:Maybe<&2,Bool>,pair:W & Presence) -> IO(Dispatched<W,H>):
  match pair:
    case (world,actual): call_actual(W,H,invoke,system,mode,registry,readers,clock,audit,style,escaped,observations,nextMode,world,actual)

def pending_kind(kind:Q.BodyKind,previous:Maybe<&2,Bool>) -> Maybe<&2,Bool>:
  match kind:
    case Q.SetOn{}: Some{True{}}
    case Q.SetOff{}: Some{False{}}
    case _: previous
def record_mode(-W:Type,-H:Data,system:Q.System,result:Dispatched<W,H>) -> Dispatched<W,H>:
  match system result:
    case Q.System{_,_,kind,_,_,_,_} Dispatched{Runtime{world,registry,readers,clock,audit,style,escaped,observations,nextMode},Complete{}}:
      Dispatched{Runtime{world,registry,readers,clock,audit,style,escaped,observations,pending_kind(kind,nextMode)},Complete{}}
    case _ other: other
def call(~W:Type,~H:Data,~presence:W -> W & Presence,
  ~invoke:Q.System -> Q.Mode -> U32 -> R.Clock -> W -> Maybe<Audit> -> Maybe<R.Run> -> IO(Invoked<W,H>),
  +system:Q.System,mode:Q.Mode,runtime:Runtime<W,H>) -> IO(Dispatched<W,H>):
  match runtime:
    case Runtime{world,registry,readers,clock,audit,style,escaped,observations,nextMode}:
      IO.bind(Dispatched<W,H>,Dispatched<W,H>,call_presence(W,H,invoke,system,mode,registry,readers,clock,audit,style,escaped,observations,nextMode,presence(world)),result => IO.pure(Dispatched<W,H>,record_mode(W,H,system,result)))

def marker_done(-W:Type,-H:Data,registry:Q.Registry,readers:R.Readers,audit:Maybe<Audit>,style:C.Style,escaped:List<&2,H>,observations:List<&2,U.Observation>,nextMode:Maybe<&2,Bool>,owners:W & R.Clock) -> Runtime<W,H>:
  match owners:
    case (world,clock): Runtime{world,registry,readers,clock,audit,style,escaped,observations,nextMode}
def deferred(~W:Type,~H:Data,~barrier:W -> R.Clock -> IO(W & R.Clock),runtime:Runtime<W,H>) -> IO(Runtime<W,H>):
  match runtime:
    case Runtime{world,registry,readers,clock,audit,style,escaped,observations,nextMode}:
      IO.bind(W & R.Clock,Runtime<W,H>,barrier(world,clock),owners => IO.pure(Runtime<W,H>,marker_done(W,H,registry,readers,audit,style,escaped,observations,nextMode,owners)))
def transition_after(~W:Type,~transition:W -> Maybe<&2,Bool> -> R.Clock -> W & R.Clock,nextMode:Maybe<&2,Bool>,owners:W & R.Clock) -> W & R.Clock:
  match owners:
    case (world,clock): transition(world,nextMode,clock)
def state_transition(~W:Type,~H:Data,~barrier:W -> R.Clock -> IO(W & R.Clock),~transition:W -> Maybe<&2,Bool> -> R.Clock -> W & R.Clock,runtime:Runtime<W,H>) -> IO(Runtime<W,H>):
  match runtime:
    case Runtime{world,registry,readers,clock,audit,style,escaped,observations,nextMode}:
      IO.bind(W & R.Clock,Runtime<W,H>,barrier(world,clock),owners => IO.pure(Runtime<W,H>,marker_done(W,H,registry,readers,audit,style,escaped,observations,None{},transition_after(W,transition,nextMode,owners))))

def run(~W:Type,~H:Data,~presence:W -> W & Presence,
  ~invoke:Q.System -> Q.Mode -> U32 -> R.Clock -> W -> Maybe<Audit> -> Maybe<R.Run> -> IO(Invoked<W,H>),
  ~barrier:W -> R.Clock -> IO(W & R.Clock),~transition:W -> Maybe<&2,Bool> -> R.Clock -> W & R.Clock,
  nodes:List<&2,Q.Node>,runtime:Runtime<W,H>) -> IO(Dispatched<W,H>):
  match nodes:
    case Nil{}: IO.pure(Dispatched<W,H>,Dispatched{runtime,Complete{}})
    case Con{Q.Nested{nested},+tail}:
      IO.bind(Dispatched<W,H>,Dispatched<W,H>,run(W,H,presence,invoke,barrier,transition,nested,runtime),result => continue_case(W,H,state => run(W,H,presence,invoke,barrier,transition,tail,state),result))
    case Con{Q.Call{system,mode},+tail}:
      IO.bind(Dispatched<W,H>,Dispatched<W,H>,call(W,H,presence,invoke,system,mode,runtime),result => continue_case(W,H,state => run(W,H,presence,invoke,barrier,transition,tail,state),result))
    case Con{Q.Deferred{},tail}: IO.bind(Runtime<W,H>,Dispatched<W,H>,deferred(W,H,barrier,runtime),state => run(W,H,presence,invoke,barrier,transition,tail,state))
    case Con{Q.StateTransition{},tail}: IO.bind(Runtime<W,H>,Dispatched<W,H>,state_transition(W,H,barrier,transition,runtime),state => run(W,H,presence,invoke,barrier,transition,tail,state))

# Trusted frame adapter trims actual logs using real registered holders.
def tick_frame(~W:Type,~H:Data,~presence:W -> W & Presence,
  ~invoke:Q.System -> Q.Mode -> U32 -> R.Clock -> W -> Maybe<Audit> -> Maybe<R.Run> -> IO(Invoked<W,H>),
  ~barrier:W -> R.Clock -> IO(W & R.Clock),~transition:W -> Maybe<&2,Bool> -> R.Clock -> W & R.Clock,
  ~frame:W -> R.Readers -> R.Frame -> W & (R.Readers & R.Clock),
  +nodes:List<&2,Q.Node>,registry:Q.Registry,audit:Maybe<Audit>,style:C.Style,escaped:List<&2,H>,observations:List<&2,U.Observation>,nextMode:Maybe<&2,Bool>,owners:W & (R.Readers & R.Clock)) -> IO(Dispatched<W,H>):
  match owners:
    case (world,(readers,clock)):
      run(W,H,presence,invoke,barrier,transition,nodes,Runtime{world,registry,readers,clock,audit,style,escaped,observations,nextMode})
def tick_missing(~W:Type,~H:Data,~presence:W -> W & Presence,
  ~invoke:Q.System -> Q.Mode -> U32 -> R.Clock -> W -> Maybe<Audit> -> Maybe<R.Run> -> IO(Invoked<W,H>),
  ~barrier:W -> R.Clock -> IO(W & R.Clock),~transition:W -> Maybe<&2,Bool> -> R.Clock -> W & R.Clock,
  ~frame:W -> R.Readers -> R.Frame -> W & (R.Readers & R.Clock),
  +nodes:List<&2,Q.Node>,missing:List<&2,Requirement>,runtime:Runtime<W,H>) -> IO(Dispatched<W,H>):
  match missing runtime:
    case Nil{} Runtime{world,registry,readers,clock,audit,style,escaped,observations,nextMode}:
      tick_frame(W,H,presence,invoke,barrier,transition,frame,nodes,registry,audit,style,escaped,observations,nextMode,frame(world,readers,R.frame(clock)))
    case requirements state: IO.pure(Dispatched<W,H>,Dispatched{state,MissingRuntimeRequirements{requirements}})
def tick_audit(~W:Type,~H:Data,~presence:W -> W & Presence,
  ~invoke:Q.System -> Q.Mode -> U32 -> R.Clock -> W -> Maybe<Audit> -> Maybe<R.Run> -> IO(Invoked<W,H>),
  ~barrier:W -> R.Clock -> IO(W & R.Clock),~transition:W -> Maybe<&2,Bool> -> R.Clock -> W & R.Clock,
  ~frame:W -> R.Readers -> R.Frame -> W & (R.Readers & R.Clock),
  +nodes:List<&2,Q.Node>,+ledger:Bool,+ledgerName:String,+stateName:String,world:W,registry:Q.Registry,readers:R.Readers,clock:R.Clock,style:C.Style,escaped:List<&2,H>,observations:List<&2,U.Observation>,nextMode:Maybe<&2,Bool>,service:Maybe<Audit> & Bool) -> IO(Dispatched<W,H>):
  match service:
    case (audit,available):
      tick_missing(W,H,presence,invoke,barrier,transition,frame,nodes,preflight(nodes,ledger,available,True{},ledgerName,stateName),Runtime{world,registry,readers,clock,audit,style,escaped,observations,nextMode})
def tick_presence(~W:Type,~H:Data,~presence:W -> W & Presence,
  ~invoke:Q.System -> Q.Mode -> U32 -> R.Clock -> W -> Maybe<Audit> -> Maybe<R.Run> -> IO(Invoked<W,H>),
  ~barrier:W -> R.Clock -> IO(W & R.Clock),~transition:W -> Maybe<&2,Bool> -> R.Clock -> W & R.Clock,
  ~frame:W -> R.Readers -> R.Frame -> W & (R.Readers & R.Clock),
  +nodes:List<&2,Q.Node>,+ledgerName:String,+stateName:String,registry:Q.Registry,readers:R.Readers,clock:R.Clock,audit:Maybe<Audit>,style:C.Style,escaped:List<&2,H>,observations:List<&2,U.Observation>,nextMode:Maybe<&2,Bool>,owners:W & Presence) -> IO(Dispatched<W,H>):
  match owners:
    case (world,Presence{ledger,_}):
      tick_audit(W,H,presence,invoke,barrier,transition,frame,nodes,ledger,ledgerName,stateName,world,registry,readers,clock,style,escaped,observations,nextMode,audit_present(audit))
def tick_canonical(~W:Type,~H:Data,~presence:W -> W & Presence,
  ~invoke:Q.System -> Q.Mode -> U32 -> R.Clock -> W -> Maybe<Audit> -> Maybe<R.Run> -> IO(Invoked<W,H>),
  ~barrier:W -> R.Clock -> IO(W & R.Clock),~transition:W -> Maybe<&2,Bool> -> R.Clock -> W & R.Clock,
  ~frame:W -> R.Readers -> R.Frame -> W & (R.Readers & R.Clock),
  ledgerName:String,stateName:String,checked:Canonical,runtime:Runtime<W,H>) -> IO(Dispatched<W,H>):
  match checked runtime:
    case Unknown{base} state: IO.pure(Dispatched<W,H>,Dispatched{state,SetupRejected{"unregistered base:" ++ U32.show(base)}})
    case Accepted{nodes} Runtime{world,registry,readers,clock,audit,style,escaped,observations,nextMode}:
      tick_presence(W,H,presence,invoke,barrier,transition,frame,nodes,ledgerName,stateName,registry,readers,clock,audit,style,escaped,observations,nextMode,presence(world))
def tick_registry(~W:Type,~H:Data,~presence:W -> W & Presence,
  ~invoke:Q.System -> Q.Mode -> U32 -> R.Clock -> W -> Maybe<Audit> -> Maybe<R.Run> -> IO(Invoked<W,H>),
  ~barrier:W -> R.Clock -> IO(W & R.Clock),~transition:W -> Maybe<&2,Bool> -> R.Clock -> W & R.Clock,
  ~frame:W -> R.Readers -> R.Frame -> W & (R.Readers & R.Clock),
  nodes:List<&2,Q.Node>,ledgerName:String,stateName:String,world:W,readers:R.Readers,clock:R.Clock,audit:Maybe<Audit>,style:C.Style,escaped:List<&2,H>,observations:List<&2,U.Observation>,nextMode:Maybe<&2,Bool>,scan:Q.Registry & List<&2,Q.System>) -> IO(Dispatched<W,H>):
  match scan:
    case (registry,systems): tick_canonical(W,H,presence,invoke,barrier,transition,frame,ledgerName,stateName,canonical(systems,nodes),Runtime{world,registry,readers,clock,audit,style,escaped,observations,nextMode})
def tick(~W:Type,~H:Data,~presence:W -> W & Presence,
  ~invoke:Q.System -> Q.Mode -> U32 -> R.Clock -> W -> Maybe<Audit> -> Maybe<R.Run> -> IO(Invoked<W,H>),
  ~barrier:W -> R.Clock -> IO(W & R.Clock),~transition:W -> Maybe<&2,Bool> -> R.Clock -> W & R.Clock,
  ~frame:W -> R.Readers -> R.Frame -> W & (R.Readers & R.Clock),
  nodes:List<&2,Q.Node>,ledgerName:String,stateName:String,runtime:Runtime<W,H>) -> IO(Dispatched<W,H>):
  match runtime:
    case Runtime{world,registry,readers,clock,audit,style,escaped,observations,nextMode}:
      tick_registry(W,H,presence,invoke,barrier,transition,frame,nodes,ledgerName,stateName,world,readers,clock,audit,style,escaped,observations,nextMode,registry_values(registry))
