from pathlib import Path
import subprocess,json,hashlib,os,signal
H=Path(__file__).resolve().parent;F=Path('/tmp/bendvy-slot-host-swap-selective-frozen-v1');O=Path('/tmp/bendvy-slot-host-swap-selective-independent-v1');O.mkdir(exist_ok=False);ROOT=Path('/workspace/formal-proofs/bendvy');sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();r={'status':'INCOMPLETE','scope':'Independent finite firstarg scalar swap review on exact4baa, no timing/adoption/SlotHost claim','commands':[]};save=lambda:(O/'evidence.json').write_text(json.dumps(r,indent=2)+'\n')
def run(args,cap,label):
 args=list(map(str,args));p=subprocess.Popen(args,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,start_new_session=True)
 try:out=p.communicate(timeout=cap)[0]
 except subprocess.TimeoutExpired:os.killpg(p.pid,signal.SIGKILL);out=p.communicate()[0];(O/(label+'.txt')).write_text(out);raise
 f=O/(label+'.txt');f.write_text(out);r['commands'].append({'argv':args,'cap':cap,'exit':p.returncode,'outputSHA256':sha(f)});save();assert p.returncode==0,out[-2500:];return out
freeze=json.loads((F/'freeze.json').read_text());r['freeze']=freeze
for n,d in freeze.items():assert sha(F/n)==d
for n in ['rewrite.cjs','input-pins.json']:assert sha(H/'recipe'/n)==freeze['recipe/'+n]
cat=json.loads((H/'recipe/input-pins.json').read_text())
for schema in ['motion','health']:
 pin=next(p for p in cat.values() if p['label']==schema);inp=Path(pin['inputPath']);out=O/(schema+'.js');run(['taskset','-c','9','node','--expose-internals',H/'recipe/rewrite.cjs',inp,out],5,schema+'-derive');assert sha(out)==freeze[schema+'.js'];text=run(['node','--expose-internals',H/'structural.cjs',inp,out,str(out)+'.recipe.json'],5,schema+'-structural');(O/(schema+'-structural.json')).write_text(text);run(['python3',ROOT/'experiments/s-prep/js-descending-cursor-transport/validate-full65.py','--cpu','9','--kind','js','--schema',schema.title(),'--program',out,'--output',O/(schema+'-full65')],20,schema+'-full65')
run(['python3',H/'recipe/scope-run.py',O/'scope'],120,'scope')
run(['python3',H/'recipe/controls.py','--output',O/'controls'],150,'controls')
run(['python3',H/'recipe/witness-run.py','--output',O/'witness'],90,'witness')
run(['python3',H/'recipe/mutants.py',O/'mutants'],30,'mutants')
run(['python3',H/'recipe/exception-run.py','--output',O/'exceptions'],30,'exceptions')
run(['python3',H/'recipe/live-mutants.py',O/'live-mutants'],60,'live-mutants')
r['status']='INDEPENDENT_COMPOSITION_BOTH65_TEN_EDGES_TX576_HELPER130_EXCEPTION6_GUARDS29_BRIDGE4_LIVE6_PASS';save();print(r['status'])
