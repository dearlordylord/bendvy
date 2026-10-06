#!/usr/bin/env python3
"""Independent exact recipe/witness/refusal replay, with five-second child caps."""
import pathlib,argparse,json,hashlib,subprocess,os,signal
p=argparse.ArgumentParser();p.add_argument('--recipe',type=pathlib.Path,required=True);p.add_argument('--output',type=pathlib.Path,required=True);a=p.parse_args();a.output.mkdir();os.sched_setaffinity(0,{8});sha=lambda b:hashlib.sha256(b).hexdigest();catalog=json.loads((a.recipe/'input-pins.json').read_text());r={'status':'INCOMPLETE','scope':'Independent frozen two-schema generatedJS recipe/fullshape witness/refusal replay; no source or universal acceptance','recipePins':{n:sha((a.recipe/n).read_bytes()) for n in ['rewrite.cjs','input-pins.json','fold-witness.cjs']},'commands':[],'cases':[]}
def run(cmd,label,expected=0):
 proc=subprocess.Popen(list(map(str,cmd)),stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,start_new_session=True)
 try:out,_=proc.communicate(timeout=5)
 except subprocess.TimeoutExpired:os.killpg(proc.pid,signal.SIGKILL);out,_=proc.communicate();raise RuntimeError(label+' timeout')
 (a.output/(label+'.txt')).write_text(out);r['commands'].append({'argv':list(map(str,cmd)),'capSeconds':5,'exit':proc.returncode,'outputSHA256':sha(out.encode())});assert proc.returncode==expected,(label,out[-1000:]);return out
try:
 for schema in ['motion','health']:
  items=[(h,v) for h,v in catalog.items() if v['label']==schema];assert len(items)==1;digest,pin=items[0];parent=pathlib.Path(pin['inputPath']);assert sha(parent.read_bytes())==digest;candidate=pathlib.Path('/tmp/bendvy-followup-'+schema+'.js');out=a.output/(schema+'.js');run(['node','--expose-internals',a.recipe/'rewrite.cjs',parent,out],schema+'-derive');assert out.read_bytes()==candidate.read_bytes();logs=[]
  for role,program in [('parent',parent),('candidate',out)]:
   witness=a.output/(schema+'-'+role+'-witness.js');run(['node','--expose-internals',a.recipe/'fold-witness.cjs',program,witness,schema],schema+'-'+role+'-witness-derive');logs.append(run(['node',witness],schema+'-'+role+'-witness-run'));assert len(logs[-1].splitlines())==65
  assert logs[0]==logs[1];r['cases'].append({'schema':schema,'parentSHA256':digest,'candidateSHA256':sha(out.read_bytes()),'finiteRecords':65,'parentCandidateLiteralEqual':True})
 # Exact-input unknown edit and output reuse must refuse before emitting candidate.
 parent=pathlib.Path(catalog[next(k for k,v in catalog.items() if v['label']=='motion')]['inputPath']);changed=a.output/'edited-input.js';changed.write_bytes(parent.read_bytes()+b'\n// unknown bytes\n');refused=a.output/'refused.js';msg=run(['node','--expose-internals',a.recipe/'rewrite.cjs',changed,refused],'unknown-input-refusal',1);assert 'unknown input' in msg and not refused.exists();existing=a.output/'motion.js';msg=run(['node','--expose-internals',a.recipe/'rewrite.cjs',parent,existing],'output-reuse-refusal',1);assert 'fresh output required' in msg
 r['status']='FRESH_TWO_SCHEMA_REPLAY_130_RECORDS_TWO_REFUSALS_PASS'
finally:(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n')
