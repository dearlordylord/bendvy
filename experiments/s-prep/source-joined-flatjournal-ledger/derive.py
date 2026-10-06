from pathlib import Path
import re,json,hashlib,shutil,difflib
H=Path('/tmp/bendvy-threehour-held-transport/experiments/s-prep/source-joined-flatjournal-ledger');BASE=Path('/tmp/bendvy-flat-journal-v4');OUT=Path('/tmp/bendvy-joined-flatjournal-ledger-v1')
# Development generator is also bound to the accepted immutable input recipe.
expected=json.loads((H/'input-pins.json').read_text())
actual={str(p.relative_to(BASE)):hashlib.sha256(p.read_bytes()).hexdigest() for p in BASE.rglob('*.bend')}
assert actual==expected and len(actual)==29,'Exact frozen input29 required before any output/copy'
assert not any(p.is_symlink() for p in BASE.rglob('*')),'Input symlinks refused'
input_overlay=json.loads((BASE/'overlay.json').read_text());input_cache=json.loads((BASE/'cache-specialization.json').read_text())
assert input_overlay['sources']==expected and input_overlay['cacheSpecialization']==input_cache,'Input receipts disagree'
assert input_cache['runtimeClosure']==expected and input_cache['specializedClosure']==expected,'Input closure maps disagree'
expected_digest=hashlib.sha256(json.dumps(expected,sort_keys=True,separators=(',',':')).encode()).hexdigest()
assert expected_digest=='bdba8a91c1b56f4961217454139b79dc5c1614ab2301f4dae766a0cd70934bb3' and input_cache['runtimeClosureSHA256']==expected_digest,'Frozen input closure differs'
assert not OUT.exists();shutil.copytree(BASE,OUT);p=OUT/'experiments/s-integrate/held-adapter.bend';old=p.read_text();text=old
schema='T.HealthSchema';main='CC.Cache<T.Vitals,T.VitalsView>';aux='T.Armor';flag='T.Tracked';mode='T.HealthMode';handle='S.Handle<T.HealthSchema>';cmd=f'S.Command<{main},{aux},{flag}>';world=f'S.World<{schema},{main},{aux},{flag},CC.Cache<T.HealthLedger,T.LedgerView>,{mode}>';tx=f'X.PrototypeFlatTx<{schema},{world},{cmd}>';flat='PrototypeJournalLedger<T.LedgerView>';state=f'PrototypeFlatFold<{schema},{main},{aux},{flag},{flat},{mode}>';ro=f'PrototypeJournalLedgerRowOwner<T.Vitals,T.VitalsView,T.LedgerView,{schema}>';pre='prototype_journalledger_health';client=re.search(r'^def prototype_flatfold_health\((.*),handles:',old,re.M).group(1)
fields=[('ns','U32'),('next','U32'),('columns',f'Array<Maybe<{main}>>'),('aux',f'Array<Maybe<{aux}>>'),('metadata',f'S.MetadataColumns<{flag}>'),('capacity','U32'),('depth','Nat'),('high','U32'),('pending',f'List<{cmd}>'),('ledger',f'Maybe<{flat}>'),('mode',mode),('selected',handle),('undo',f'X.PrototypeFlatInverse<{schema}>'),('commands',f'List<{cmd}>'),('pings','List<&2,U32>'),('marks',f'X.PrototypeFlatMark<{schema}>'),('total','U32')]
vals=','.join(n for n,t in fields);pat='PrototypeFlatFold{'+vals+'}'
rowfields='main_raw,main_cached,totals,epoch,ledger_cached,handle,undo,marks';rowpat='PrototypeJournalLedgerRowOwner{'+rowfields+'}'
block='''
# Private ledger transport only: nominal payloads/public callbacks remain unchanged.
type PrototypeJournalLedger<-LV:Data> is Type:
  PrototypeJournalLedger{totals:Array<U32>,epoch:U32,cached:LV}
type PrototypeJournalLedgerRowOwner<-Raw:Type,-View:Data,-LV:Data,-Schema:Data> is Type:
  PrototypeJournalLedgerRowOwner{main_raw:Raw,main_cached:View,totals:Array<U32>,epoch:U32,ledger_cached:LV,handle:S.Handle<Schema>,undo:X.PrototypeFlatInverse<Schema>,marks:X.PrototypeFlatMark<Schema>}
'''
worldpat='S.World{ns,next,S.Rows{columns,aux,metadata,capacity,depth,high},pending,LEDGER,mode}'
for fn,arg in [('pack',f'owner:{tx},total:U32'),('unpack',f'result:{tx} & U32,total:U32')]:
 block+=f'def {pre}_{fn}({arg}) -> {state}:\n  match '+('owner' if fn=='pack' else 'result')+':\n'
 for ledger,flatledger in [('Some{CC.Cache{T.HealthLedger{totals,epoch},cached}}','Some{PrototypeJournalLedger{totals,epoch,cached}}'),('None{}','None{}')]:
  lhs='X.PrototypeFlatTx{'+worldpat.replace('LEDGER',ledger)+',selected,undo,commands,pings,marks}';lhs='('+lhs+',value)' if fn=='unpack' else lhs
  total='U32.add(total,value)' if fn=='unpack' else 'total';args=vals.replace('pending,ledger,mode','pending,'+flatledger+',mode').rsplit(',total',1)[0]+','+total
  block+=f'    case {lhs}: PrototypeFlatFold{{{args}}}\n'
 block+='\n'
block+=f'def {pre}_finish(state:{state}) -> {tx} & U32:\n  match state:\n'
for ledger,oldledger in [('Some{PrototypeJournalLedger{totals,epoch,cached}}','Some{CC.Cache{T.HealthLedger{totals,epoch},cached}}'),('None{}','None{}')]:
 block+='    case '+pat.replace('pending,ledger,mode','pending,'+ledger+',mode')+': (X.PrototypeFlatTx{'+worldpat.replace('LEDGER',oldledger)+',selected,undo,commands,pings,marks},total)\n'
block+=f'\ndef {pre}_fallback_done({client},result:{tx} & U32) -> {state}:\n  match result:\n    case (owner,total): {pre}_unpack(prototype_flatfold_health_converted(client(X.Tx<{world},{handle},{cmd}>,A.health_read_main,A.health_set_main0,A.health_read_ledger,A.health_set_ledger0,X.prototype_flat_unpack(~{schema},~{world},~{cmd},owner))),total)\n\n'
block+=f'def {pre}_fallback({client},state:{state}) -> {state}:\n  {pre}_fallback_done(~client,{pre}_finish(state))\n\n'
block+=f'''def {pre}_get(owner:{ro},token:T.VitalsToken) -> {ro} & T.Access<T.VitalsView>:
  match owner token:
    case PrototypeJournalLedgerRowOwner{{main_raw,+main_cached,totals,epoch,ledger_cached,handle,undo,marks}} T.VitalsToken{{}}: ({rowpat},T.Found{{main_cached}})
def {pre}_ledger(owner:{ro},token:T.HealthLedgerToken) -> {ro} & Maybe<&2,T.LedgerView>:
  match owner token:
    case PrototypeJournalLedgerRowOwner{{main_raw,main_cached,totals,epoch,+ledger_cached,handle,undo,marks}} T.HealthLedgerToken{{}}: ({rowpat},Some{{ledger_cached}})
def {pre}_set_fused_done(totals:Array<U32>,epoch:U32,ledger_cached:T.LedgerView,+handle:{handle},undo:X.PrototypeFlatInverse<{schema}>,marks:X.PrototypeFlatMark<{schema}>,cached:T.VitalsView,value:U32,result:T.Vitals & U32) -> {ro}:
  match handle result:
    case S.Handle{{+space,+id}} Tuple{{raw,old}}: PrototypeJournalLedgerRowOwner{{raw,P.vitals_patch(cached,value),totals,epoch,ledger_cached,S.Handle{{space,id}},X.PrototypeFlatMain{{space,id,old,undo}},X.PrototypeFlatMark{{space,id,marks}}}}
def {pre}_set(owner:{ro},token:T.VitalsToken,value:U32) -> {ro}:
  match owner token:
    case PrototypeJournalLedgerRowOwner{{raw,cached,totals,epoch,ledger_cached,+handle,undo,marks}} T.VitalsToken{{}}:
      +value = value
      {pre}_set_fused_done(totals,epoch,ledger_cached,handle,undo,marks,cached,value,P.prototype_vitals_raw_swap(raw,value))
def {pre}_setledger_done(main_raw:T.Vitals,main_cached:T.VitalsView,epoch:U32,handle:{handle},undo:X.PrototypeFlatInverse<{schema}>,marks:X.PrototypeFlatMark<{schema}>,cached:T.LedgerView,+value:U32,result:Array<U32> & U32) -> {ro}:
  match result:
    case (totals,old): PrototypeJournalLedgerRowOwner{{main_raw,main_cached,Array.set(U32,totals,0,value),epoch,P.health_ledger_patch(cached,value),handle,X.PrototypeFlatLedger{{old,undo}},marks}}
def {pre}_setledger(owner:{ro},token:T.HealthLedgerToken,value:U32) -> {ro}:
  match owner token:
    case PrototypeJournalLedgerRowOwner{{main_raw,main_cached,totals,epoch,cached,handle,undo,marks}} T.HealthLedgerToken{{}}:
      +value = value
      {pre}_setledger_done(main_raw,main_cached,epoch,handle,undo,marks,cached,value,Array.get(U32,totals,0))
def {pre}_invoke({client},owner:{ro}) -> {ro} & U32:
  client({ro},{pre}_get,{pre}_set,{pre}_ledger,{pre}_setledger,owner)

'''
# Translate only private transport helpers; old functions and headers stay present.
start=old.index('def prototype_flatfold_health_returned(');end=old.index('def prototype_flatfold_health(',start);chunk=old[start:end]
chunk=chunk.replace('prototype_flatfold_health_',pre+'_').replace('prototype_flatrows_health_invoke',pre+'_invoke').replace('PrototypeFlatRowOwner<T.Vitals,T.VitalsView,T.HealthLedger,T.LedgerView,T.HealthSchema>',ro).replace('PrototypeFlatRowOwner{main_raw,main_cached,ledger_raw,ledger_cached,', 'PrototypeJournalLedgerRowOwner{main_raw,main_cached,totals,epoch,ledger_cached,').replace('CC.Cache<T.HealthLedger,T.LedgerView>',flat)
chunk=chunk.replace('Some{CC.Cache{ledger_raw,ledger_cached}}','Some{PrototypeJournalLedger{totals,epoch,ledger_cached}}').replace('PrototypeJournalLedger{ledger_raw,ledger_cached}', 'PrototypeJournalLedger{totals,epoch,ledger_cached}')
# old ledger pattern became Cache but new flat constructor has three fields.
chunk=chunk.replace('CC.Cache{ledger_raw,ledger_cached}', 'PrototypeJournalLedger{totals,epoch,ledger_cached}')
# Three fallback arms restore complete nominal Tx and consume every returned field.
lines=[]
for line in chunk.splitlines():
 if ': '+pre+'_fallback(client(' in line:
  left=line.split(': '+pre+'_fallback(client(',1)[0]
  ledger='Some{ledger}' if ('case (columns,_) ledger:' in line or 'case (metadata,False{}):' in line) else 'ledger'
  v=vals.replace('pending,ledger,mode','pending,'+ledger+',mode');line=left+': '+pre+'_fallback(~client,PrototypeFlatFold{'+v+'})'
 lines.append(line)
chunk='\n'.join(lines)+'\n'
block+=chunk
block+=f'def {pre}({client},handles:List<&2,{handle}>,owner:{tx},total:U32) -> {tx} & U32:\n  {pre}_finish({pre}_loop(~client,handles,{pre}_pack(owner,total)))\n\n'
# New definitions precede their sole public entry call.
pos=text.index('def prototype_flatfold_health(');text=text[:pos]+block+text[pos:]
oldbody='  prototype_flatfold_health_finish(prototype_flatfold_health_loop(~client,handles,prototype_flatfold_health_pack(owner,total)))';assert text.count(oldbody)==1;text=text.replace(oldbody,f'  {pre}(~client,handles,owner,total)');p.write_text(text)
# Header preservation is exact; only one source changes.
headers=[x for x in old.splitlines() if x.startswith(('def ','type '))];assert all(x in text.splitlines() for x in headers)
pins=json.loads((BASE/'overlay.json').read_text())['sources'];newpins={n:hashlib.sha256((OUT/n).read_bytes()).hexdigest() for n in pins};assert [n for n in pins if pins[n]!=newpins[n]]==['experiments/s-integrate/held-adapter.bend'];cache=json.loads((OUT/'cache-specialization.json').read_text());cache['runtimeClosure']=newpins;cache['specializedClosure']=newpins.copy();cache['runtimeClosureSHA256']=hashlib.sha256(json.dumps(newpins,sort_keys=True,separators=(',',':')).encode()).hexdigest();manifest=json.loads((OUT/'overlay.json').read_text());manifest['sources']=newpins;manifest['cacheSpecialization']=cache
for n,v in [('overlay.json',manifest),('cache-specialization.json',cache)]: (OUT/n).write_text(json.dumps(v,indent=2)+'\n')
(H/'input-pins.json').write_text(json.dumps(pins,indent=2)+'\n');(H/'held-adapter.patch').write_text(''.join(difflib.unified_diff(old.splitlines(True),text.splitlines(True),fromfile='a/experiments/s-integrate/held-adapter.bend',tofile='b/experiments/s-integrate/held-adapter.bend')));print(cache['runtimeClosureSHA256'])
