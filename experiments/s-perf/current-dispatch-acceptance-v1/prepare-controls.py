"""Prepare only the agreed current-body source controls and live inverse defect."""
from pathlib import Path
import copy,gzip,hashlib,importlib.util,json,re,subprocess
W=Path(__file__).resolve().parents[3];D=Path(__file__).parent;R=Path('/workspace/formal-proofs/bendvy');sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest();base=Path('/tmp/bendvy21-current-dispatch-acceptance-actual02/normal/js/plan.json');old=json.loads(base.read_text());collector=R/'experiments/public-inspect/ordinary-declaration-v1/canonical-full-consumer-v1/development-v2.py';spec=importlib.util.spec_from_file_location('collector',collector);c=importlib.util.module_from_spec(spec);spec.loader.exec_module(c);commit=subprocess.check_output(['git','rev-parse','HEAD'],cwd=W,text=True).strip()
def inventory(entries):
 inv={};foreign={}
 def visit(p):
  p=p.resolve(strict=True)
  if str(p)in inv:return
  inv[str(p)]=sha(p)
  for t in re.findall(r'^import\s+(\S+)',p.read_text(),re.M):
   if t!='Base':visit(p.parent/t)
  for t in re.findall(r'^\s+import "([^\"]+)"',p.read_text(),re.M):
   f=(p.parent/t).resolve(strict=True);foreign[str(f)]=sha(f)
 for e in entries:visit(e)
 return inv,foreign
pins=dict(old['pins'])
for f in [Path(__file__),base,D/'CONTROLS-BASIS.json',D/'oracle/counter-model.py',D/'oracle/counter.inverse.stdout']:
 pins[str(f)]=sha(f)
for role in ['js','native']:
 f=Path('/tmp/bendvy21-current-dispatch-acceptance-actual02/normal')/role/'receipt.json';r=json.loads(f.read_text());assert r['status']=='COMPLETE_CONSUMER_DEVELOPMENT_PASS';pins[str(f)]=sha(f)
output=Path('/tmp/bendvy21-current-dispatch-controls-actual01');assert not output.exists();output.mkdir();oracle=output/'counter.inverse.stdout.gz';oracle.write_bytes(gzip.compress((D/'oracle/counter.inverse.stdout').read_bytes(),mtime=0));pins[str(oracle)]=sha(oracle)
for role in ['source','js','native']:
 q=output/role;q.mkdir();p=copy.deepcopy(old);rolepins=dict(pins);prefix=[p['tools']['taskset'],'-c','11'];p.pop('moduleInterpretation',None)
 if role=='source':
  entries=[D/'subject/scenario.bend',*[D/'controls'/f'{n}.bend'for n in ['write-through-read','duplicate-owner','cross-schema']]];inv,foreign=inventory(entries);diagnostics=[[],['SOME PROOFS FAIL','Cap.Write<refused~H','Cap.Read<refused~H'],['SOME PROOFS FAIL','owner (consumed more than once)'],['SOME PROOFS FAIL','- observed : W.World<Other']]
  commands=[{'label':'source-'+e.stem,'argv':prefix+[p['tools']['bend'],str(e),'--check-only'],'capSeconds':15,'expectedExit':0 if i==0 else 1,'stderrContains':diagnostics[i]}for i,e in enumerate(entries)]
 else:
  entries=[D/'controls/inverse-order/source'/((D/'subject/main.bend').relative_to(W))];inv,foreign=inventory(entries);generated=q/('scenario.js'if role=='js'else'scenario.c');native=q/'scenario.native';commands=[{'label':'emit','argv':prefix+[p['tools']['bend'],str(entries[0]),'-o',str(generated)],'capSeconds':60}]
  if role=='native':commands.append({'label':'build','argv':prefix+[p['tools']['clangWrapper'],'-O3',str(generated),'-o',str(native),'-pthread','-lm'],'capSeconds':120})
  else:
   package=q/'package.json';package.write_text('{"type":"commonjs"}\n');rolepins[str(package)]=sha(package);p['moduleInterpretation']={'path':str(package),'sha256':sha(package),'type':'commonjs','scope':'Output-local pinned module interpretation'}
  commands.append({'label':'consumer','argv':prefix+([p['tools']['node'],str(generated)]if role=='js'else[str(native),'--threads','1','--gpu','off']),'capSeconds':180});p.update(generated=str(generated),native=str(native))
 rolepins.update(inv);rolepins.update(foreign)
 p.update(scope='Current ordinary dispatch '+role+' authority/refusal'if role=='source'else'Current ordinary dispatch reached inverse-order defect; full independently presealed counter, normal oracle must differ offline',role='js'if role=='source'else role,entrypoint=str(entries[0]),stage=str(entries[0].parent),cwd=str(entries[0].parent),sourceInventory=inv,sourceEntries=[str(e)for e in entries],importClosure=c.validate_imports(entries[0].parent,inv,[str(e)for e in entries]),pins=rolepins,commands=commands,oracle=str(oracle),oracleBytes=3403,oracleSHA256=sha(D/'oracle/counter.inverse.stdout'),sourceCommit=commit,modelCommit='781f021c3',sourceFreeze={'path':str(D/'CONTROLS-BASIS.json'),'sha256':sha(D/'CONTROLS-BASIS.json')},foreignConsumption={'sidecars':foreign},postConsumer='Source expected exits+intended diagnostics, or complete counter oracle and empty consumer stderr; independent offline normal rejection required.')
 for f,h in rolepins.items():assert sha(f)==h,f
 plan=q/'plan.json';plan.write_text(json.dumps(p,indent=2)+'\n');print(role,plan,sha(plan),flush=True)
