from pathlib import Path
import re

HELPERS='''
# Diagnostic traversal returns every affine payload and preserves list order.
def diag_cons(-C: Type,head: C,pair: List<C> & U32) -> List<C> & U32:
  match pair:
    case (tail,count): (head <> tail,U32.add(count,1))
def diag_length(-C: Type,values: List<C>) -> List<C> & U32:
  match values:
    case Nil{}: ([],0)
    case Con{head,tail}: diag_cons(C,head,diag_length(C,tail))
def diag_finish(-W: Type,-H: Data,-C: Type,world: W,selected: H,+undo: List<&2,Inverse<H>>,+pings: List<&2,U32>,+marks: List<&2,H>,+meter: String,phase: String,pair: List<C> & U32) -> Tx<W,H,C>:
  match pair:
    case (commands,count): Tx{world,selected,undo,commands,pings,marks,meter ++ phase ++ ":" ++ U32.show(count) ++ ":" ++ Nat.show(List.length(&2,U32,pings)) ++ ":" ++ Nat.show(List.length(&2,Inverse<H>,undo)) ++ ":" ++ Nat.show(List.length(&2,H,marks)) ++ ";"}
def diag_sample(-W: Type,-H: Data,-C: Type,phase: String,t: Tx<W,H,C>) -> Tx<W,H,C>:
  match t:
    case Tx{world,selected,undo,commands,pings,marks,meter}: diag_finish(W,H,C,world,selected,undo,pings,marks,meter,phase,diag_length(C,commands))
'''

def constructors(text,name,extra,wrap=False):
 pattern=re.compile(r'(?<![\w])'+re.escape(name)+r'\{'); out=[];pos=0
 for m in list(pattern.finditer(text)):
  if m.start()<pos: continue
  end=m.end();depth=1
  while depth:
   depth+=(text[end]=='{')-(text[end]=='}');end+=1
  body=text[m.end():end-1]
  if ': ' in body or ':W' in body: continue
  before=text[text.rfind('\n',0,m.start())+1:m.start()]
  ispattern='case ' in before and ':' not in before
  addition=extra(body,ispattern)
  value=name+'{'+body+','+addition+'}'
  if wrap and not ispattern:
   phase=text[:m.start()].rsplit('def ',1)[-1].split('(',1)[0]
   value='diag_sample(W,H,C,"'+phase+'",'+value+')'
  out.extend([text[pos:m.start()],value]);pos=end
 return ''.join(out)+text[pos:]

def prepare(dest):
 dest=Path(dest);p=dest/'transaction.bend';t=p.read_text()
 t=t.replace('marks: List<&2,H>}','marks: List<&2,H>, meter: String}')
 t=t.replace('Reverted{world: W}','Reverted{world: W, meter: String}')
 # Extra meter parameter on owner-rebuilding helper seams.
 t=t.replace('marks: List<&2,H>,result:', 'marks: List<&2,H>,meter: String,result:')
 t=t.replace('commands,pings,marks,write(', 'commands,pings,marks,meter,write(')
 t=t.replace('commands,pings,marks,read(', 'commands,pings,marks,meter,read(')
 t=t.replace('commands,pings,marks,reserve(', 'commands,pings,marks,meter,reserve(')
 t=constructors(t,'Tx',lambda b,pat: 'meter' if pat or b!='world,selected,[],[],[],[]' else '""',True)
 # Declaration already has its field; constructor processor appended an unwanted declaration item.
 t=t.replace('meter: String,meter}', 'meter: String}')
 # Patterns dropping fields still need to retain the diagnostic meter.
 t=constructors(t,'Committed',lambda b,pat:'meter')
 t=t.replace('meter: String,meter}', 'meter: String}')
 t=constructors(t,'Reverted',lambda b,pat:'meter')
 t=t.replace('meter: String,meter}', 'meter: String}')
 t=t.replace('case Tx{world,_,_,commands,pings,marks,meter}', 'case Tx{world,_,_,commands,pings,marks,meter}')
 # Drain record before dropping inverse/marks on success and before rollback.
 t=t.replace('Committed{world,List.reverse(&1,C,commands),List.reverse(&2,U32,pings),marks,meter}', 'Committed{world,List.reverse(&1,C,commands),List.reverse(&2,U32,pings),marks,meter ++ "finish-success;"}')
 t=t.replace('Reverted{unwind(W,H,restore_main,restore_ledger,undo,world),meter}', 'Reverted{unwind(W,H,restore_main,restore_ledger,undo,world),meter ++ "finish-failure;"}')
 # Diagnostic transport changes only private commit seam.
 t=t.replace('-> S.World<Schema,M,A,F,L,Mode> & List<&2,U32>:', '-> S.World<Schema,M,A,F,L,Mode> & (List<&2,U32> & String):')
 t=t.replace('commands)),pings)', 'commands)),(pings,meter ++ "commit;"))')
 t=t.replace('case Reverted{world,meter}: (world,[])', 'case Reverted{world,meter}: (world,([],meter ++ "rollback;"))')
 # Owner-carrying rollback transport records each actual inverse pop.
 t=t.replace('undo: List<&2,Inverse<H>>,world: W) -> W:', 'undo: List<&2,Inverse<H>>,world: W,+meter: String) -> W & String:')
 t=t.replace('case Nil{}: world\n    case Con{MainInverse', 'case Nil{}: (world,meter ++ "unwind:0;")\n    case Con{MainInverse')
 t=t.replace('Con{MainInverse{handle,old},rest}', 'Con{MainInverse{handle,old},+rest}').replace('Con{LedgerInverse{old},rest}', 'Con{LedgerInverse{old},+rest}')
 t=t.replace('restore_main(world,handle,old))', 'restore_main(world,handle,old),meter ++ "unwind:" ++ Nat.show(List.length(&2,Inverse<H>,rest)) ++ ";")')
 t=t.replace('restore_ledger(world,old))', 'restore_ledger(world,old),meter ++ "unwind:" ++ Nat.show(List.length(&2,Inverse<H>,rest)) ++ ";")')
 t=t.replace('Reverted{unwind(W,H,restore_main,restore_ledger,undo,world),meter ++ "finish-failure;"}', 'diag_reverted(W,C,H,unwind(W,H,restore_main,restore_ledger,undo,world,meter ++ "finish-failure;"))')
 idx=t.index('def tx_finish_failure(')
 helper='def diag_reverted(-W: Type,-C: Type,-H: Data,pair: W & String) -> Finished<W,C,H>:\n  match pair:\n    case (world,meter): Reverted{world,meter}\n'
 t=t[:idx]+helper+t[idx:]
 # Commit marks are inspected at each real storage_mark_all recursive pop.
 t=t.replace('marks: List<&2,S.Handle<Schema>>,world: S.World<Schema,M,A,F,L,Mode>,+tick: U32) -> S.World<Schema,M,A,F,L,Mode>:', 'marks: List<&2,S.Handle<Schema>>,world: S.World<Schema,M,A,F,L,Mode>,+tick: U32,+meter: String) -> S.World<Schema,M,A,F,L,Mode> & String:')
 t=t.replace('case Nil{}: world\n    case Con{handle,rest}: storage_mark_all', 'case Nil{}: (world,meter ++ "mark-drain:0;")\n    case Con{handle,rest}: storage_mark_all')
 t=t.replace('Con{handle,rest}: storage_mark_all','Con{handle,+rest}: storage_mark_all')
 t=t.replace('world,handle,tick),tick)', 'world,handle,tick),tick,meter ++ "mark-drain:" ++ Nat.show(List.length(&2,S.Handle<Schema>,rest)) ++ ";")')
 old='(S.publish(Schema,M,A,F,L,Mode,storage_mark_all(Schema,M,A,F,L,Mode,marks,world,tick),List.reverse(&1,S.Command<M,A,F>,commands)),(pings,meter ++ "commit;"))'
 new='diag_publish(Schema,M,A,F,L,Mode,commands,pings,storage_mark_all(Schema,M,A,F,L,Mode,marks,world,tick,meter))'
 assert old in t
 t=t.replace(old,new)
 idx=t.index('def storage_commit(')
 helper='def diag_publish(-Schema: Data,-M: Type,-A: Type,-F: Data,-L: Type,-Mode: Data,commands: List<S.Command<M,A,F>>,pings: List<&2,U32>,pair: S.World<Schema,M,A,F,L,Mode> & String) -> S.World<Schema,M,A,F,L,Mode> & (List<&2,U32> & String):\n  match pair:\n    case (world,meter): (S.publish(Schema,M,A,F,L,Mode,world,List.reverse(&1,S.Command<M,A,F>,commands)),(pings,meter ++ "commit;"))\n'
 t=t[:idx]+helper+t[idx:]
 # Insert traversal before first definition; no forward dependencies.
 i=t.index('def tx_begin(');t=t[:i]+HELPERS+'\n'+t[i:]
 t=t.replace('def storage_commit(', 'def diag_storage_commit(')
 t+='''

def diag_strip(-W: Type,result: W & (List<&2,U32> & String)) -> W & List<&2,U32>:
  match result:
    case (world,(pings,_)): (world,pings)
def storage_commit(-Schema: Data,-M: Type,-A: Type,-F: Data,-L: Type,-Mode: Data,result: Finished<S.World<Schema,M,A,F,L,Mode>,S.Command<M,A,F>,S.Handle<Schema>>,tick: U32) -> S.World<Schema,M,A,F,L,Mode> & List<&2,U32>:
  diag_strip(S.World<Schema,M,A,F,L,Mode>,diag_storage_commit(Schema,M,A,F,L,Mode,result,tick))
'''
 p.write_text(t)
 # Private adapter constructors must thread the extra owner field.
 for p in dest.glob('*.bend'):
  if p.name=='transaction.bend' or p.name.startswith('occupancy'):continue
  t=p.read_text()
  if p.name in ['measurement-readers.bend','transaction-dispatch-adapters.bend']: t=t.replace('X.storage_commit(', 'X.diag_storage_commit(')
  t=constructors(t,'X.Tx',lambda b,pat:'meter')
  if p.name=='failure-indexed-service-guard.bend':t=constructors(t,'A.RunResult',lambda b,pat:'meter')
  if p.name=='audited-invoker.bend':
   t=re.sub(r'(marks:List<&2,S.Handle<T\.(?:Motion|Health)Schema>>),',r'\1,meter:String,',t)
   t=t.replace('marks,outcome','marks,meter,outcome')
  if p.name=='transaction-dispatch-adapters.bend':
   t=t.replace('pings:List<&2,U32>}', 'pings:List<&2,U32>,meter:String}')
   t=t.replace('result:W & List<&2,U32>', 'result:W & (List<&2,U32> & String)')
   t=t.replace('case (world,pings): RunResult{world,outcome,escaped,observations,pings}', 'case (world,(pings,meter)): RunResult{world,outcome,escaped,observations,pings,meter}')
  if p.name=='host.bend':
   t=constructors(t,'TA.RunResult',lambda b,pat:'meter')
   # Wrap IO branch terms with print, without changing owner or callback quantity.
   lines=t.splitlines()
   for j,line in enumerate(lines):
    if 'case TA.RunResult{' in line and ': ' in line:
     prefix,term=line.split(': ',1);typ='D.Invoked<'+('MotionHost(),W.Handle<T.MotionSchema>>' if 'motion_' in term else 'HealthHost(),W.Handle<T.HealthSchema>>')
     lines[j]=prefix+': IO.bind(Unit,'+typ+',IO.print("txdiag:" ++ meter),_ => '+term+')'
    elif 'case IA.ServiceResult{TA.RunResult{' in line:
     term=lines[j+1].strip();typ='D.Invoked<'+('MotionHost(),W.Handle<T.MotionSchema>>' if 'motion_' in term else 'HealthHost(),W.Handle<T.HealthSchema>>')
     lines[j+1]='      IO.bind(Unit,'+typ+',IO.print("txdiag:" ++ meter),_ => '+term+')'
   t='\n'.join(lines)+'\n'
  if p.name=='measurement-readers.bend':
   t=t.replace('& List<&2,U32>) -> IO(', '& (List<&2,U32> & String)) -> IO(')
   lines=t.splitlines()
   for j,line in enumerate(lines):
    if 'case (world,pings):' in line:
     prefix,term=line.split(': ',1);prefix=prefix.replace('(world,pings)','(world,(pings,meter))');typ='D.Invoked<L.'+('MotionState,S.Handle<T.MotionSchema>>' if 'motion_' in term else 'HealthState,S.Handle<T.HealthSchema>>')
     lines[j]=prefix+': IO.bind(Unit,'+typ+',IO.print("txdiag:" ++ meter),_ => '+term+')'
   t='\n'.join(lines)+'\n'
  p.write_text(t)
