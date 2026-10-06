import json,pathlib,shutil,subprocess,hashlib
base=pathlib.Path(__file__).resolve().parents[2];import sys
out=pathlib.Path(sys.argv[2]) if len(sys.argv)>2 else pathlib.Path('/tmp/bendvy-final-direct-admission');out.mkdir(exist_ok=True);ps=json.load(open(sys.argv[1] if len(sys.argv)>1 else '/tmp/bendvy-direct-payload-tx-original-v2/probe-evidence.json'))['programs'];sha=lambda p:hashlib.sha256(pathlib.Path(p).read_bytes()).hexdigest();records=[]
stages=[('boxed','js-profile-composition/boxed'),('product','js-profile-composition/product'),('pool','js-profile-composition/pool'),('store','js-owner-store-elision'),('read','js-read-wrapper-fusion'),('swap','js-read-wrapper-fusion/swap-last'),('dead','js-final-profile-chain/dead-provider'),('payload','js-final-profile-chain/payload')]
world=out/'world';world.mkdir(exist_ok=True);shutil.copyfile(base/'js-owned-world-reuse/rewrite.cjs',world/'rewrite.cjs');templates=list(json.load(open(base/'js-owned-world-reuse/input-pins.json')).values());catalog={}
for i,p in enumerate(ps):
 root=pathlib.Path(p['source']).parent;mode='suppressed' if 'suppressed' in p['source'] else 'normal';getter='raw' if '/raw/' in p['source'] else 'cached';t=next(x for x in templates if x.get('schema')==p['schema'] and x.get('mode')==mode and x.get('getter')==getter);t=dict(t);t.update(sourceRoot=str(root),sourcePins={n:sha(root/n) for n in t['sourcePins']},inputPath=p['originalJS']);catalog[p['originalJSSHA256']]=t
(world/'input-pins.json').write_text(json.dumps(catalog,indent=2)+'\n')
current=[]
for i,p in enumerate(ps):
 target=out/f'{i}-world.js';v=subprocess.run(['taskset','-c','8','node','--expose-internals',str(world/'rewrite.cjs'),p['originalJS'],str(target),p['schema']],capture_output=True,text=True,timeout=5);assert v.returncode==0,v.stderr;current.append(target)

for stage,rel in stages:
 src=base/rel;dst=out/stage;dst.mkdir(exist_ok=True)
 for name in ['rewrite.cjs','source-facts.json','types-source.bend.gz']:
  if (src/name).exists():shutil.copyfile(src/name,dst/name)
 templates=json.load(open(src/'input-pins.json'));catalog={}
 for i,p in enumerate(ps):
  root=pathlib.Path(p['source']).parent;mode='suppressed' if 'suppressed' in p['source'] else 'normal';getter='raw' if '/raw/' in p['source'] else 'cached';label=f'{mode}-{getter}-{p["schema"]}';inp=current[i]
  if stage=='boxed':t=next(x for x in templates.values() if x.get('schema')==p['schema'] and x.get('mode')==mode and ('/'+getter+'/' in x.get('inputPath','')));t=dict(t);t['sourceRoot']=str(root);t['sourcePins']={n:sha(root/n) for n in t['sourcePins']}
  elif stage=='product':t=str(inp)
  elif stage=='pool':
   token='PositionToken' if p['schema']=='motion' else 'VitalsToken';ledger='MotionLedgerToken' if p['schema']=='motion' else 'HealthLedgerToken';t={'path':str(inp),'tags':['types.'+token,'types.'+ledger],'typesSHA256':sha(root/'types.bend'),'actualTypesPath':str(root/'types.bend'),'originalInputSHA256':p['originalJSSHA256']}
  elif stage in ['store','read']:
   t=next(x for x in templates.values() if x.get('label')==label);t=json.loads(json.dumps(t));t.update(sourceRoot=str(root),sourcePins=p['source29Pins'],inputPath=str(inp))
   if stage=='read':t.update(callbackSourcePath=str(root/'gate-callbacks.bend'),callbackSourceSHA256=sha(root/'gate-callbacks.bend'))
  elif stage in ['swap','dead']:t={'path':str(inp),'label':label,'sourceRoot':str(root),'runtimeSourcePins':p['source29Pins']};t.update(expectedSites=0) if stage=='dead' else None
  elif stage=='payload':t={'sourceRoot':str(root),'sourcePins':p['source29Pins'],'schema':p['schema'],'inputPath':str(inp),'label':label}
  catalog[sha(inp)]=t
 (dst/'input-pins.json').write_text(json.dumps(catalog,indent=2)+'\n');nextinputs=[];stageout=[]
 for i,p in enumerate(ps):
  target=out/f'{i}-{stage}.js';args=['taskset','-c','8','node','--expose-internals',str(dst/'rewrite.cjs'),str(current[i]),str(target)]
  if stage=='boxed':args+=[p['schema']]+(['--suppressed-main'] if 'suppressed' in p['source'] else [])
  v=subprocess.run(args,capture_output=True,text=True,timeout=5);stageout.append({'case':i,'input':str(current[i]),'inputSHA256':sha(current[i]),'accepted':v.returncode==0,'error':v.stderr,'output':str(target),'outputSHA256':sha(target) if target.exists() else None});print(stage,i,v.returncode,next((s for s in v.stderr.splitlines() if s.startswith('Error:')),''));nextinputs.append(target)
 records.append({'stage':stage,'recipeSHA256':sha(dst/'rewrite.cjs'),'catalogSHA256':sha(dst/'input-pins.json'),'cases':stageout});(out/'all-admission.json').write_text(json.dumps(records,indent=2)+'\n')
 if any(not x['accepted'] for x in stageout):break
 current=nextinputs
