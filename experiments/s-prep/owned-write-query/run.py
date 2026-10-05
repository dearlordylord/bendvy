#!/usr/bin/env python3
import pathlib,subprocess,os,signal,json,hashlib,shutil,re,tempfile
HERE=pathlib.Path(__file__).resolve().parent;ROOT=HERE.parents[2];ART=pathlib.Path(os.environ.get('BENDVY_HELD_ARTIFACT','/tmp/bendvy-held-replay'));ART.mkdir(exist_ok=False);CPU=os.environ.get('BENDVY_CPU','5');e={'status':'INCOMPLETE','cases':[],'limits':{'checker':5,'runtime':5,'codegen':30,'clang':120},'sources':{}}
def run(args,limit=5,expected=0):
 p=subprocess.Popen(list(map(str,args)),stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,start_new_session=True)
 try:out,_=p.communicate(timeout=limit)
 except subprocess.TimeoutExpired:
  os.killpg(p.pid,signal.SIGKILL);out,_=p.communicate();e['cases'].append({'command':list(map(str,args)),'timeout':limit,'output':out});raise
 assert p.returncode==expected,(args,p.returncode,out)
 return out
try:
 run(['bend','version']);run(['bend','guide'])
 overlay=ART/'overlay';run(['python3',ROOT/'experiments/s-perf/overlay.py',overlay]);pkg=overlay/'experiments/s-integrate'
 for p in HERE.glob('*.bend'):shutil.copy2(p,pkg/p.name)
 src=(ROOT/'experiments/s-perf/candidate/measurement-bend.bend').read_text();copy=(HERE/'callbacks.bend').read_text();pins=json.loads((HERE/'callback-pins.json').read_text())
 for n,pin in pins.items():
  m=re.search(r'^def '+n+r'\(',src,re.M);end=min(x for x in [src.find('\ndef ',m.start()+1),src.find('\ntype ',m.start()+1),len(src)] if x>=0);part=src[m.start():end].rstrip()+'\n';assert part in copy and hashlib.sha256(part.encode()).hexdigest()==pin
 for p in [*HERE.glob('*.bend'),ROOT/'experiments/s-perf/candidate/storage.bend',pathlib.Path('/home/node/.bend/bin/bend'),pathlib.Path('/home/node/.bend/bend2/base.bend')]:e['sources'][str(p)]=hashlib.sha256(p.read_bytes()).hexdigest()
 def build(label):
  entry=pkg/'prototype.bend';out=run(['taskset','-c',CPU,'bend',entry,'--check-only']);assert 'ALL PROOFS CHECK' in out
  c=ART/(label+'.c');js=ART/(label+'.js');binary=ART/label
  run(['taskset','-c',CPU,'bend',entry,'-o',c],30);run(['taskset','-c',CPU,'bend',entry,'-o',js],30);run(['taskset','-c',CPU,'clang','-O3',c,'-o',binary,'-lm','-pthread'],120)
  native=run(['taskset','-c',CPU,binary,'--threads','1','--gpu','off']);javascript=run(['taskset','-c',CPU,'node',js]);assert native==javascript
  (ART/(label+'.txt')).write_text(native);return native
 original=build('original');reference=json.loads(run(['node',HERE/'reference.mjs']));lines=original.splitlines();assert len(lines)==28
 def vals(o):
  if isinstance(o,dict):
   if set(o)=={'a','b','c','d'}:return [o[x] for x in ['a','b','c','d']]
   return {k:vals(v) for k,v in o.items()}
  if isinstance(o,list):return [vals(v) for v in o]
  return o
 for i,r in enumerate(reference):
  l=lines[i*7:i*7+7];schema=r['schema'];assert l[0]==schema+':foreign:missing';l=l[1:];lookup=json.loads(l[0].split(':',2)[2]);snap=json.loads(l[1].split(':',2)[2]);assert vals(snap['rows'][0]['main'])==vals(lookup);assert vals(snap['rows'][0]['main'])==({"coordinates":[99,11,12,13],"frame":7} if schema=='motion' else {"levels":[99,11,12,13],"reserve":9,"class":2});assert vals(snap['ledger'])=={"totals":[88,101,102,103],"epoch":4}
  assert snap['rows'][1]['main'] is not None and snap['pending']==[] and [(x['added'],x['changed']) for x in snap['rows']]==[(3,4),(5,6)]
  assert l[2]==schema+':sum:'+str(r['sum']);assert l[3]==schema+':inverse:'+r['inverse'];assert l[4]==schema+':published-pings:'+''.join(str(x)+';' for x in r['pings'])
  world=json.loads(l[5].split(':',2)[2]);assert world['namespace']==7 and world['next']==3 and world['mode']==schema.title()+'On'
  assert world['pending']==([] if r['fail'] else [{"kind":"FlagView","id":2,"flag":{"group":9}},{"kind":"DespawnView","id":2}]),world['pending']
  assert [(x['added'],x['changed']) for x in world['rows']]==[(3,4 if r['fail'] else 9),(5,6)]
  rows=[{k:vals(v) for k,v in row.items() if k not in ['added','changed']} for row in world['rows']];assert rows==r['rows'],(rows,r['rows']);assert vals(world['ledger'])==r['ledger']
 e['cases'].append({'label':'fullfields NativeO3 JS freshbevy-ts','status':'PASS','lines':len(lines),'oracleLimits':'Bend identity/mode/tick metadata checked independently; TS payload/flags/aux/ledger/fullinverse values observed'})
 controls={
 'undeclared':'def bad(-Owner:Type,set:Owner -> T.VitalsToken -> U32 -> Owner,owner:Owner) -> Owner:\n  set(owner,T.PositionToken{},1)\n',
 'reconstruct':'def bad(-Owner:Type,owner:Owner) -> Owner:\n  T.Vitals{[1:U32^2n],9,2}\n',
 'duplicate':'def bad(-Owner:Type,owner:Owner) -> Owner & Owner:\n  (owner,owner)\n',
 'write-through-read':'def bad(-Owner:Type,owner:Owner) -> Owner:\n  P.vitals_swap(owner,1)\n'}
 for n,body in controls.items():
  f=pkg/(n+'.bend');f.write_text('import Base\nimport ./types.bend as T\nimport ./payload.bend as P\n'+body);out=run(['taskset','-c',CPU,'bend',f,'--check-only'],expected=1);assert 'Location: bad' in out and 'SOME PROOFS FAIL' in out;e['cases'].append({'label':n,'status':'PASS','output':out})
 held=(pkg/'held.bend').read_text();driver=(pkg/'prototype.bend').read_text()
 mutants={
 'wrong-slot':('prototype.bend',driver.replace('rows,1,main','rows,2,main')),
 'lost-owner':('prototype.bend',driver.replace('S.put_finish(T.Position,T.Velocity,T.Selected,S.put_rows(T.Position,T.Velocity,T.Selected,rows,1,main))','rows').replace('S.put_finish(T.Vitals,T.Armor,T.Tracked,S.put_rows(T.Vitals,T.Armor,T.Tracked,rows,1,main))','rows')),
 'foreign-lookup':('prototype.bend',driver.replace('Bool.and(U32.is_eq(ln,rn),U32.is_eq(li,ri))','True{}')),
 'inverse-order':('held.bend',held.replace('X.MainInverse{handle,old} <> undo','List.reverse(&2,X.Inverse<H>,X.MainInverse{handle,old} <> undo)'))}
 for n,(file,s) in mutants.items():
  assert s!=(driver if file=='prototype.bend' else held);(pkg/file).write_text(s);changed=build(n);assert changed!=original;e['cases'].append({'label':n,'status':'DETECTED','compilingBothBackends':True});(pkg/'held.bend').write_text(held);(pkg/'prototype.bend').write_text(driver)
 e['status']='PASS_BOUNDED'
except Exception as error:e['status']='INCOMPLETE';e['error']=repr(error);raise
finally:(ART/'evidence.json').write_text(json.dumps(e,indent=2)+'\n')
