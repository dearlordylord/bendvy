#!/usr/bin/env python3
"""Bounded fresh derived-helper snapshot checks and exact-input refusal receipts."""
import pathlib,json,hashlib,sys,os,argparse
H=pathlib.Path(__file__).resolve().parent;ROOT=pathlib.Path('/workspace/formal-proofs/bendvy');sys.path.insert(0,str(ROOT/'experiments/s-prep/fivehour-connected-gates'));from supervisor import execute
p=argparse.ArgumentParser();p.add_argument('--output',type=pathlib.Path,required=True);a=p.parse_args();a.output.mkdir(exist_ok=False);os.sched_setaffinity(0,{7});sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();r={'status':'INCOMPLETE','cpu':7,'commands':[],'snapshots':[],'refusals':[],'scope':'Finite emitted-helper snapshot/order and failclosed controls, no universal ownership/refinement claim'}
def run(argv,label,ok=True):
 code,out=execute(list(map(str,argv)),5);f=a.output/(label+'.txt');f.write_text(out);r['commands'].append({'argv':list(map(str,argv)),'capSeconds':5,'exit':code,'outputSHA256':sha(f)});assert (code==0)==ok,out[-1200:];return out
try:
 for schema in ['motion','health']:
  source=pathlib.Path('/tmp/bendvy-direct-tuple-'+schema+'-final.js');receipt=pathlib.Path(str(source)+'.recipe.json');x=json.loads(receipt.read_text());assert sha(source)==x['outputSHA256'] and sha(H/'rewrite.cjs')==x['recipeSHA256'] and sha(H/'analyze.cjs')==x['analysisSHA256'];target=a.output/(schema+'-snapshot.js');run(['node','--expose-internals',H/'snapshot-witness.cjs',source,target,schema],schema+'-derive');out=run(['node',target],schema+'-snapshot');w=json.loads(out);assert w['status']=='RETAINED_FROZEN_DATA_VIEWS_UNCHANGED_NEW_VIEWS_AND_TRUEOLD_PASS';r['snapshots'].append({'schema':schema,'programSHA256':sha(source),'receiptSHA256':sha(receipt),'harnessSHA256':sha(H/'snapshot-witness.cjs'),'derivedSHA256':sha(target),'observation':w})
 unknown=a.output/'unknown.js';unknown.write_text('function f(p){return p.fst;}f({$:"Tuple",fst:1,snd:2});\n');out=run(['node','--expose-internals',H/'rewrite.cjs',unknown,a.output/'refused.js'],'unknown-input',False);assert 'unapproved exact input' in out and not (a.output/'refused.js').exists();r['refusals'].append('unknown SHA')
 existing=a.output/'existing.js';existing.write_text('occupied');out=run(['node','--expose-internals',H/'rewrite.cjs','/tmp/bendvy-js-identity-query-motion-pool-v3.js',existing],'occupied-output',False);assert 'output must be absent' in out and existing.read_text()=='occupied';r['refusals'].append('occupied output')
 controls=a.output/'guard-controls.json';run(['node','--expose-internals',H/'guard-controls.cjs',controls],'structural-controls');r['structuralControlsSHA256']=sha(controls);r['status']='FRESH_SNAPSHOTS_REFUSALS_AND_STRUCTURAL_CONTROLS_PASS'
except Exception as e:r.update(status='FAILED',error=repr(e))
(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n');print(json.dumps({'status':r['status'],'error':r.get('error')}));sys.exit(0 if r['status']=='FRESH_SNAPSHOTS_REFUSALS_AND_STRUCTURAL_CONTROLS_PASS' else 1)
