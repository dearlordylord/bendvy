"""Bounded source derivation; context stays outside callback ownership, no callback rewrite."""
from pathlib import Path
import re,json,hashlib,shutil,difflib
BASE=Path('/tmp/bendvy-held-flat-both-reproduced-v5');OUT=Path('/tmp/bendvy-row-owner-split');HERE=Path(__file__).resolve().parent
assert not OUT.exists();shutil.copytree(BASE,OUT);p=OUT/'experiments/s-integrate/held-adapter.bend';old=p.read_text();start=old.index('def prototype_flatmain_motion_get(');end=old.index('\ndef motion_get(',start)
def parts(s):
 out=[];a=0;depth=0
 for i,c in enumerate(s):
  if c in '(<{[':depth+=1
  if c in ')>} ]'.replace(' ','') and not(c=='>' and i and s[i-1]=='-'):depth-=1
  if c==',' and depth==0:out.append(s[a:i]);a=i+1
 out.append(s[a:]);return out
def close(s,at,left,right):
 d=0
 for i in range(at,len(s)):
  if s[i]==left:d+=1
  elif s[i]==right and not(right=='>' and i and s[i-1]=='-'):
   d-=1
   if d==0:return i
 raise ValueError('unbalanced')
def owner_types(s):
 while 'PrototypeFlatHeld<' in s:
  at=s.index('PrototypeFlatHeld<');begin=at+len('PrototypeFlatHeld');stop=close(s,begin,'<','>');args=parts(s[begin+1:stop]);assert len(args)==7
  s=s[:at]+'PrototypeRowOwner<'+','.join(args[1:6])+'>'+s[stop+1:]
 return s
entries={m[1]:m[0] for m in re.finditer(r'^def (\w+)[\s\S]*?(?=^def |\Z)',old[start:end],re.M)}
newtype='\ntype PrototypeRowOwner<-Raw:Type,-View:Data,-L:Type,-LV:Data,-H:Data> is Type:\n  PrototypeRowOwner{main_raw:Raw,main_cached:View,ledger_raw:L,ledger_cached:LV,handle:H,undo:List<&2,X.Inverse<H>>,marks:List<&2,H>}\n'
block=newtype
for schema in ('motion','health'):
 stem='prototype_rowsplit_'+schema
 for suffix in ('get','ledger','set_fused_done','set','setledger_fused_done','setledger','invoke'):
  text=owner_types(entries['prototype_flatmain_'+schema+'_'+suffix]).replace('prototype_flatmain_','prototype_rowsplit_')
  line=text.splitlines()[0];at=line.index('(');stop=close(line,at,'(',')');args=parts(line[at+1:stop]);args=[x for x in args if x.split(':',1)[0].lstrip('+~ -') not in ('world','commands','pings')];newhead=line[:at+1]+','.join(args)+line[stop:];text=text.replace(line,newhead,1)
  while 'PrototypeFlatHeld{' in text:
   at=text.index('PrototypeFlatHeld{');begin=at+len('PrototypeFlatHeld');stop=close(text,begin,'{','}');args=parts(text[begin+1:stop]);assert len(args)==10;kept=[args[i] for i in [1,2,3,4,5,6,9]];text=text[:at]+'PrototypeRowOwner{'+','.join(kept)+'}'+text[stop+1:]
  for done in ('set_fused_done','setledger_fused_done'):
   needle=stem+'_'+done+'('
   # The definition is before the call; only body call needs field removal.
   bodyat=text.find(needle,text.index('\n')+1)
   if bodyat>=0:
    begin=bodyat+len(needle)-1;stop=close(text,begin,'(',')');args=parts(text[begin+1:stop]);args=[x for x in args if x not in ['world','commands','pings']];text=text[:begin+1]+','.join(args)+text[stop:]
  assert not re.search(r'\b(world|commands|pings)\b',text),suffix
  block+=text+'\n'
 raw='T.Position' if schema=='motion' else 'T.Vitals';view=raw+'View';ledger='T.MotionLedger' if schema=='motion' else 'T.HealthLedger';aux='T.Velocity' if schema=='motion' else 'T.Armor';flag='T.Selected' if schema=='motion' else 'T.Tracked';tag='T.MotionSchema' if schema=='motion' else 'T.HealthSchema';mode='T.MotionMode' if schema=='motion' else 'T.HealthMode'
 main='CC.Cache<'+raw+','+view+'>';lc='CC.Cache<'+ledger+',T.LedgerView>';cmd='S.Command<'+main+','+aux+','+flag+'>';rows='S.Rows<'+main+','+aux+','+flag+'>';handle='S.Handle<'+tag+'>';world='S.World<'+tag+','+main+','+aux+','+flag+','+lc+','+mode+'>';tx='X.Tx<'+world+','+handle+','+cmd+'>';owner='PrototypeRowOwner<'+raw+','+view+','+ledger+',T.LedgerView,'+handle+'>'
 block+='def '+stem+'_return(result:'+owner+' & U32,ns:U32,next:U32,rows:'+rows+',pending:List<'+cmd+'>,mode:'+mode+',commands:List<'+cmd+'>,pings:List<&2,U32>) -> '+tx+' & U32:\n  match result rows:\n    case (PrototypeRowOwner{main_raw,main_cached,ledger_raw,ledger_cached,S.Handle{+space,+id},undo,marks},total) S.Rows{columns,aux,meta,cap,depth,high}:\n      (X.Tx{S.World{ns,next,S.Rows{Array.set(Maybe<'+main+'>,columns,U32.sub(id,1),Some{CC.Cache{main_raw,main_cached}}),aux,meta,cap,depth,high},pending,Some{CC.Cache{ledger_raw,ledger_cached}},mode},S.Handle{space,id},undo,commands,pings,marks},total)\n\n'
 taken=entries['prototype_flatmain_'+schema+'_taken'].replace('prototype_flatmain_','prototype_rowsplit_');line=taken.splitlines()[0];assert taken.count('case (rows,S.Taken{CC.Cache{main_raw,main_cached}}) CC.Cache{ledger_raw,ledger_cached}:')==1
 taken=re.sub(r'(case \(rows,S.Taken\{CC.Cache\{main_raw,main_cached\}\}\) CC.Cache\{ledger_raw,ledger_cached\}:)[^\n]*',r'\1 '+stem+'_return('+stem+'_invoke(~client,PrototypeRowOwner{main_raw,main_cached,ledger_raw,ledger_cached,handle,undo,marks}),ns,next,rows,pending,mode,commands,pings)',taken)
 block+=taken+'\n'
new=old[:start]+block+old[end:];new=new.replace('case True{} Some{ledger}: prototype_flatmain_motion_taken','case True{} Some{ledger}: prototype_rowsplit_motion_taken').replace('case True{} Some{ledger}: prototype_flatmain_health_taken','case True{} Some{ledger}: prototype_rowsplit_health_taken');p.write_text(new)
(HERE/'held-adapter.patch').write_text(''.join(difflib.unified_diff(old.splitlines(True),new.splitlines(True),fromfile='a/experiments/s-integrate/held-adapter.bend',tofile='b/experiments/s-integrate/held-adapter.bend')))
pins={str(x.relative_to(OUT)):hashlib.sha256(x.read_bytes()).hexdigest() for x in OUT.rglob('*.bend')};cache=json.loads((OUT/'cache-specialization.json').read_text());cache['runtimeClosure']=pins;cache['specializedClosure']=pins;cache['runtimeClosureSHA256']=hashlib.sha256(json.dumps(pins,sort_keys=True,separators=(',',':')).encode()).hexdigest();over=json.loads((OUT/'overlay.json').read_text());over['sources']=pins;over['cacheSpecialization']=cache
(OUT/'cache-specialization.json').write_text(json.dumps(cache,indent=2)+'\n');(OUT/'overlay.json').write_text(json.dumps(over,indent=2)+'\n');print(OUT)
