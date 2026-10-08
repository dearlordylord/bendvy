import Base
import ../candidate/src/ecs/debug-metadata.bend as M
# This renderer is only for closed ASCII fixture labels/messages, not publication.
def quote(s:String) -> String:
  String.join(["\"",s,"\""],"")
def names(xs:List<&2,String>) -> List<&2,String>:
  match xs:
    case []:[]
    case head<>tail:quote(head)<>names(tail)
def array(xs:List<&2,String>) -> String:
  String.join(["[",String.join(xs,","),"]"],"")
def entry(e:M.Entry) -> String:
  match e:
    case M.Entry{name,reads,writes}:String.join(["{\"name\":",quote(name),",\"readers\":",array(names(reads)),",\"writers\":",array(names(writes)),"}"],"")
def entries(es:List<&2,M.Entry>) -> List<&2,String>:
  match es:
    case []:[]
    case head<>tail:entry(head)<>entries(tail)
def indexes(i:M.Indexes) -> String:
  match i:
    case M.Indexes{cs,rs,es}:String.join(["{\"components\":",array(entries(cs)),",\"resources\":",array(entries(rs)),",\"events\":",array(entries(es)),"}"],"")
def severity(s:M.Severity) -> String:
  match s:
    case M.Warning{}:"warning"
    case M.Info{}:"info"
def code(c:M.Code) -> String:
  match c:
    case M.EventNeverRead{}:"event-never-read"
    case M.EventNeverWritten{}:"event-never-written"
    case M.NextStateNeverApplied{}:"next-state-never-applied"
    case M.ComponentNeverRead{}:"component-never-read"
    case M.ReadBeforeWrite{}:"read-before-write"
def lint(l:M.Lint) -> String:
  match l:
    case M.Lint{s,c,message,subject}:String.join(["{\"severity\":",quote(severity(s)),",\"code\":",quote(code(c)),",\"message\":",quote(message),",\"subject\":",quote(subject),"}"],"")
def lints(ls:List<&2,M.Lint>) -> List<&2,String>:
  match ls:
    case []:[]
    case head<>tail:lint(head)<>lints(tail)
def output(name:String,observation:M.Indexes & List<&2,M.Lint>) -> String:
  (i,ls)=observation
  String.join(["{\"name\":",quote(name),",\"indexes\":",indexes(i),",\"lints\":",array(lints(ls)),"}"],"")
