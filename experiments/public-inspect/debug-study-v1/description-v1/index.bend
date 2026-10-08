import Base
import metadata.bend as M

def contains(xs:List<&2,String>,+needle:String) -> Bool:
  match xs:
    case []:False{}
    case head<>tail:Bool.or(String.eq(head,needle),contains(tail,needle))
def append_unique(found:Bool,+name:String,xs:List<&2,String>) -> List<&2,String>:
  match found:
    case True{}:xs
    case False{}:List.append(&2,String,xs,[name])
def unique(+name:String,+xs:List<&2,String>) -> List<&2,String>:
  append_unique(contains(xs,name),name,xs)
def blank_step(found:Bool,name:String,entries:List<&2,M.Entry>) -> List<&2,M.Entry>:
  match found:
    case True{}:entries
    case False{}:M.Entry{name,[],[]}<>entries
def blank_go(names:List<&2,String>,+seen:List<&2,String>) -> List<&2,M.Entry>:
  match names:
    case []:[]
    case +name<>tail:blank_step(contains(seen,name),name,blank_go(tail,name<>seen))
def blank(names:List<&2,String>) -> List<&2,M.Entry>:
  blank_go(names,[])
def updated(write:Bool,entry:M.Entry,+system:String) -> M.Entry:
  match write entry:
    case False{} M.Entry{name,reads,writes}:M.Entry{name,unique(system,reads),writes}
    case True{} M.Entry{name,reads,writes}:M.Entry{name,reads,unique(system,writes)}
def update(found:Bool,+system:String,write:Bool,entry:M.Entry,tail:List<&2,M.Entry>,missed:List<&2,M.Entry>) -> List<&2,M.Entry>:
  match found:
    case False{}:entry<>missed
    case True{}:updated(write,entry,system)<>tail
def entry_name(entry:M.Entry) -> String:
  match entry:
    case M.Entry{name,reads,writes}:name
def touch(entries:List<&2,M.Entry>,+name:String,+system:String,+write:Bool) -> List<&2,M.Entry>:
  match entries:
    case []:[updated(write,M.Entry{name,[],[]},system)]
    case +entry<>+tail:update(String.eq(entry_name(entry),name),system,write,entry,tail,touch(tail,name,system,write))
def touch_names(names:List<&2,String>,entries:List<&2,M.Entry>,+system:String,+write:Bool) -> List<&2,M.Entry>:
  match names:
    case []:entries
    case name<>tail:touch_names(tail,touch(entries,name,system,write),system,write)
def append(a:List<&2,String>,b:List<&2,String>) -> List<&2,String>:
  List.append(&2,String,a,b)
# General component index reads presence-with and write slots; without is excluded.
def query_reads(q:M.Query) -> List<&2,String>:
  match q:
    case M.Query{slot,reads,writes,optional,with,without,added,changed,relations}:append(reads,append(optional,append(with,append(added,append(changed,writes)))))
def lint_reads(q:M.Query) -> List<&2,String>:
  match q:
    case M.Query{slot,reads,writes,optional,with,without,added,changed,relations}:append(reads,append(optional,append(added,changed)))
def query_writes(q:M.Query) -> List<&2,String>:
  match q:
    case M.Query{slot,reads,writes,optional,with,without,added,changed,relations}:writes
def queries(qs:List<&2,M.Query>,entries:List<&2,M.Entry>,+name:String) -> List<&2,M.Entry>:
  match qs:
    case []:entries
    case +q<>tail:queries(tail,touch_names(query_writes(q),touch_names(query_reads(q),entries,name,False{}),name,True{}),name)
def access(a:M.Access,entries:List<&2,M.Entry>,+name:String) -> List<&2,M.Entry>:
  match a:
    case M.Access{reads,writes}:touch_names(writes,touch_names(reads,entries,name,False{}),name,True{})
def system(s:M.System,indexes:M.Indexes) -> M.Indexes:
  match s indexes:
    case M.System{+name,placements,qs,resources,events,machines,removed,despawned,relationFailures,services,when} M.Indexes{components,resIndex,eventIndex}:M.Indexes{touch_names(removed,queries(qs,components,name),name,False{}),access(resources,resIndex,name),access(events,eventIndex,name)}
def build(systems:List<&2,M.System>,indexes:M.Indexes) -> M.Indexes:
  match systems:
    case []:indexes
    case head<>tail:build(tail,system(head,indexes))
