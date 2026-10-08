import Base
import metadata.bend as M
import index.bend as I

def empty(xs:List<&2,String>) -> Bool:
  match xs:
    case []:True{}
    case head<>tail:False{}
def all_in(xs:List<&2,String>,+ys:List<&2,String>) -> Bool:
  match xs:
    case []:True{}
    case head<>tail:Bool.and(I.contains(ys,head),all_in(tail,ys))
def cat(a:String,b:String) -> String:
  String.append(a,b)
def append(a:List<&2,M.Lint>,b:List<&2,M.Lint>) -> List<&2,M.Lint>:
  List.append(&2,M.Lint,a,b)
def if_lint(active:Bool,lint:M.Lint) -> List<&2,M.Lint>:
  match active:
    case False{}:[]
    case True{}:[lint]
def event_one(entry:M.Entry) -> List<&2,M.Lint>:
  match entry:
    case M.Entry{+name,+readers,+writers}:append(if_lint(Bool.and(Bool.not(empty(writers)),empty(readers)),M.Lint{M.Warning{},M.EventNeverRead{},cat(name,cat(" is emitted by ",cat(String.join(writers,", ")," but no described system reads it"))),name}),if_lint(Bool.and(Bool.not(empty(readers)),empty(writers)),M.Lint{M.Warning{},M.EventNeverWritten{},cat(name,cat(" is read by ",cat(String.join(readers,", ")," but no described system emits it"))),name}))
def events(entries:List<&2,M.Entry>) -> List<&2,M.Lint>:
  match entries:
    case []:[]
    case head<>tail:append(event_one(head),events(tail))
def component_one(entry:M.Entry) -> List<&2,M.Lint>:
  match entry:
    case M.Entry{+name,readers,+writers}:if_lint(Bool.and(Bool.not(empty(writers)),all_in(readers,writers)),M.Lint{M.Info{},M.ComponentNeverRead{},cat(name,cat(" is written by ",cat(String.join(writers,", ")," but read by no other described system"))),name})
def components(entries:List<&2,M.Entry>) -> List<&2,M.Lint>:
  match entries:
    case []:[]
    case head<>tail:append(component_one(head),components(tail))
def queuer(s:M.System) -> String:
  match s:
    case M.System{name,placements,qs,resources,events,machines,removed,despawned,relationFailures,services,when}:cat(name,cat(" @ ",String.join(placements,", ")))
def next_names(m:M.MachineAccess) -> List<&2,String>:
  match m:
    case M.MachineAccess{reads,next,transitions,transitionEvents}:next
def queued_step(found:Bool,name:String,values:List<&2,String>,writes:List<&2,String>,tail:List<&2,M.Entry>,missed:List<&2,M.Entry>,value:String) -> List<&2,M.Entry>:
  match found:
    case True{}:M.Entry{name,I.append(values,[value]),writes}<>tail
    case False{}:M.Entry{name,values,writes}<>missed
def queued(index:List<&2,M.Entry>,+subject:String,+value:String) -> List<&2,M.Entry>:
  match index:
    case []:[M.Entry{subject,[value],[]}]
    case M.Entry{+name,values,writes}<>+tail:queued_step(String.eq(name,subject),name,values,writes,tail,queued(tail,subject,value),value)
def queue_names(names:List<&2,String>,index:List<&2,M.Entry>,+value:String) -> List<&2,M.Entry>:
  match names:
    case []:index
    case name<>tail:queue_names(tail,queued(index,name,value),value)
def next_index_one(+s:M.System,index:List<&2,M.Entry>) -> List<&2,M.Entry>:
  match s:
    case M.System{name,placements,qs,resources,events,machines,removed,despawned,relationFailures,services,when}:queue_names(next_names(machines),index,queuer(s))
def next_index(systems:List<&2,M.System>,index:List<&2,M.Entry>) -> List<&2,M.Entry>:
  match systems:
    case []:index
    case head<>tail:next_index(tail,next_index_one(head,index))
def transitions_steps(steps:List<&2,M.ResolvedStep>) -> Bool:
  match steps:
    case []:False{}
    case M.ResolvedTransitions{schedules}<>tail:True{}
    case head<>tail:transitions_steps(tail)
def transitions(schedules:List<&2,M.ResolvedSchedule>) -> Bool:
  match schedules:
    case []:False{}
    case M.ResolvedSchedule{name,steps}<>tail:Bool.or(transitions_steps(steps),transitions(tail))
def next_one(entry:M.Entry) -> M.Lint:
  match entry:
    case M.Entry{+name,readers,writers}:M.Lint{M.Warning{},M.NextStateNeverApplied{},cat("next states of ",cat(name,cat(" are queued by ",cat(String.join(readers,"; "),", but no described schedule has an applyStateTransitions() marker, so they never take effect")))),name}
def next_entries(entries:List<&2,M.Entry>) -> List<&2,M.Lint>:
  match entries:
    case []:[]
    case head<>tail:next_one(head)<>next_entries(tail)
def next_if(applies:Bool,entries:List<&2,M.Entry>) -> List<&2,M.Lint>:
  match applies:
    case True{}:[]
    case False{}:next_entries(entries)

type AccessKind is Data:
  Components{}
  Resources{}
  Events{}
type Witness is Data:
  Witness{subject:String,writer:String,readers:List<&2,String>}
def qreads(qs:List<&2,M.Query>) -> List<&2,String>:
  match qs:
    case []:[]
    case q<>tail:I.append(I.lint_reads(q),qreads(tail))
def qwrites(qs:List<&2,M.Query>) -> List<&2,String>:
  match qs:
    case []:[]
    case q<>tail:I.append(I.query_writes(q),qwrites(tail))
def system_access(kind:AccessKind,s:M.System) -> M.Access:
  match kind s:
    case Components{} M.System{name,placements,+qs,resources,events,machines,removed,despawned,relationFailures,services,when}:M.Access{qreads(qs),qwrites(qs)}
    case Resources{} M.System{name,placements,qs,resources,events,machines,removed,despawned,relationFailures,services,when}:resources
    case Events{} M.System{name,placements,qs,resources,events,machines,removed,despawned,relationFailures,services,when}:events
def system_name(s:M.System) -> String:
  match s:
    case M.System{name,placements,qs,resources,events,machines,removed,despawned,relationFailures,services,when}:name
def lookup_step(found:Bool,readers:List<&2,String>,otherwise:List<&2,String>) -> List<&2,String>:
  match found:
    case True{}:readers
    case False{}:otherwise
def readers(index:List<&2,M.Entry>,+subject:String) -> List<&2,String>:
  match index:
    case []:[]
    case M.Entry{name,reads,writes}<>tail:lookup_step(String.eq(name,subject),reads,readers(tail,subject))
def witness_subjects(ws:List<&2,Witness>) -> List<&2,String>:
  match ws:
    case []:[]
    case Witness{subject,writer,readers}<>tail:subject<>witness_subjects(tail)
def witness_step(seen:Bool,subject:String,writer:String,reads:List<&2,String>,ws:List<&2,Witness>) -> List<&2,Witness>:
  match seen:
    case True{}:ws
    case False{}:List.append(&2,Witness,ws,[Witness{subject,writer,reads}])
def record_writes(writes:List<&2,String>,+writer:String,+index:List<&2,M.Entry>,+ws:List<&2,Witness>) -> List<&2,Witness>:
  match writes:
    case []:ws
    case +subject<>tail:record_writes(tail,writer,index,witness_step(I.contains(witness_subjects(ws),subject),subject,writer,readers(index,subject),ws))
def include_read(is_write:Bool,subject:String,remaining:List<&2,String>) -> List<&2,String>:
  match is_write:
    case True{}:remaining
    case False{}:subject<>remaining
def readonly_reads(reads:List<&2,String>,+writes:List<&2,String>) -> List<&2,String>:
  match reads:
    case []:[]
    case +subject<>tail:include_read(I.contains(writes,subject),subject,readonly_reads(tail,writes))
type Scan is Data:
  Scan{index:List<&2,M.Entry>,witnesses:List<&2,Witness>}
def scan_step(a:M.Access,+name:String,+index:List<&2,M.Entry>,ws:List<&2,Witness>) -> Scan:
  match a:
    case M.Access{reads,+writes}:Scan{I.touch_names(readonly_reads(reads,writes),index,name,False{}),record_writes(writes,name,index,ws)}
def scan(systems:List<&2,M.System>,+kind:AccessKind,state:Scan) -> List<&2,Witness>:
  match systems state:
    case [] Scan{index,ws}:ws
    case +head<>tail Scan{index,ws}:scan(tail,kind,scan_step(system_access(kind,head),system_name(head),index,ws))
def system_steps(steps:List<&2,M.ResolvedStep>) -> List<&2,M.System>:
  match steps:
    case []:[]
    case M.ResolvedSystem{metadata}<>tail:metadata<>system_steps(tail)
    case head<>tail:system_steps(tail)
def singular(readers:List<&2,String>) -> Bool:
  match readers:
    case name<>[]:True{}
    case other:False{}
def runs(one:Bool) -> String:
  match one:
    case True{}:"runs"
    case False{}:"run"
def pronoun(one:Bool) -> String:
  match one:
    case True{}:"it sees"
    case False{}:"they see"
def sees(kind:AccessKind,subject:String) -> String:
  match kind:
    case Events{}:cat(subject," events one run late")
    case other:cat("the ",cat(subject," value from the previous run"))
def message(schedule:String,kind:AccessKind,+subject:String,writer:String,+reads:List<&2,String>) -> String:
  String.join(["in ",schedule,", ",String.join(reads,", ")," ",runs(singular(reads))," before ",writer," writes ",subject,", so ",pronoun(singular(reads))," ",sees(kind,subject)],"")
def witness_lint(schedule:String,kind:AccessKind,w:Witness) -> List<&2,M.Lint>:
  match w:
    case Witness{+subject,writer,+reads}:if_lint(Bool.not(empty(reads)),M.Lint{M.Info{},M.ReadBeforeWrite{},message(schedule,kind,subject,writer,reads),subject})
def witness_lints(ws:List<&2,Witness>,+schedule:String,+kind:AccessKind) -> List<&2,M.Lint>:
  match ws:
    case []:[]
    case head<>tail:append(witness_lint(schedule,kind,head),witness_lints(tail,schedule,kind))
def schedule_lints(schedule:M.ResolvedSchedule) -> List<&2,M.Lint>:
  match schedule:
    case M.ResolvedSchedule{+name,+steps}:append(witness_lints(scan(system_steps(steps),Components{},Scan{[],[]}),name,Components{}),append(witness_lints(scan(system_steps(steps),Resources{},Scan{[],[]}),name,Resources{}),witness_lints(scan(system_steps(steps),Events{},Scan{[],[]}),name,Events{})))
def read_before(schedules:List<&2,M.ResolvedSchedule>) -> List<&2,M.Lint>:
  match schedules:
    case []:[]
    case head<>tail:append(schedule_lints(head),read_before(tail))
def assemble(schedules:List<&2,M.ResolvedSchedule>,systems:List<&2,M.System>,indexes:M.Indexes) -> List<&2,M.Lint>:
  match schedules indexes:
    case [] M.Indexes{cs,rs,es}:[]
    case +schedules M.Indexes{cs,rs,es}:append(events(es),append(next_if(transitions(schedules),next_index(systems,[])),append(read_before(schedules),components(cs))))
