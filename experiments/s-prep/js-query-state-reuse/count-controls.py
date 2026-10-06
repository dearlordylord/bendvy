#!/usr/bin/env python3
import pathlib,json,hashlib,sys,os,argparse,importlib.util
H=pathlib.Path(__file__).resolve().parent;ROOT=pathlib.Path('/workspace/formal-proofs/bendvy');sys.path.insert(0,str(ROOT/'experiments/s-prep/fivehour-connected-gates'));from supervisor import execute
p=argparse.ArgumentParser();p.add_argument('--output',type=pathlib.Path,required=True);a=p.parse_args();a.output.mkdir(exist_ok=False);os.sched_setaffinity(0,{10});sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();r={'status':'INCOMPLETE','cpu':10,'commands':[],'counts':[],'controllers':[]}
def save():(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n')
def run(argv,name):
 code,out=execute(list(map(str,argv)),5);f=a.output/(name+'.txt');f.write_text(out);r['commands'].append({'argv':list(map(str,argv)),'exit':code,'capSeconds':5,'outputSHA256':sha(f)});save();assert code==0,out[-1000:];return out
try:
 r['catalogSHA256']=sha(H/'input-pins.json');r['recipeSHA256']=sha(H/'rewrite.cjs');r['runnerSHA256']=sha(pathlib.Path(__file__));cat=json.loads((H/'input-pins.json').read_text())
 spec=importlib.util.spec_from_file_location('validator',ROOT/'experiments/s-integrate/measurement-bend-run.py');v=importlib.util.module_from_spec(spec);spec.loader.exec_module(v)
 for digest,pin in cat.items():
  inp=pathlib.Path(pin['inputPath']);assert sha(inp)==digest;out=a.output/(pin['label']+'.js');run(['node','--expose-internals',H/'rewrite.cjs',inp,out],pin['label']+'-derive')
  if pin['label'].startswith('normal-'):
   schema=pin['schema'];tsfile=a.output/(schema+'-reference.mjs');run([sys.executable,ROOT/'experiments/s-prep/fivehour-measurement/prepare-ts.py','--source',ROOT/'experiments/s-integrate/measurement-samples-reference.mjs','--output',tsfile,'--schema',schema,'--batch','8'],schema+'-prepare');ts=json.loads(run(['node',tsfile],schema+'-ts'))
   for role,program in [('before',inp),('after',out)]:
    s=program.read_text();old='return $choose$(0, 256, 64);' if schema=='Motion' else 'return $choose$(1, 256, 64);'
    if s.count(old)!=1:old='return $motion_batch$(256, 64);' if schema=='Motion' else 'return $health_batch$(256, 64);'
    assert s.count(old)==1;derived=a.output/(schema+'-'+role+'-eight.js');s=s.replace(old,old.replace('64','8'),1);begin=s.index('function $'+schema.lower()+'_timed$(');end=s.index('\nfunction ',begin+1);body=s[begin:end];assert body.count('$IO$now$(_x_1)')==1 and body.count('$IO$now$(_x_6)')==1;body=body.replace('$IO$now$(_x_1)','(__allocation_phase("start"), $IO$now$(_x_1))').replace('$IO$now$(_x_6)','(__allocation_phase("end"), $IO$now$(_x_6))');s=s[:begin]+body+s[end:];derived.write_text(s);counted=a.output/(schema+'-'+role+'-counted.js');run(['node','--expose-internals',ROOT/'experiments/s-prep/js-allocation-map/instrument.cjs',derived,counted],schema+'-'+role+'-instrument');raw=run(['node',counted],schema+'-'+role+'-counts');records=[x for x in raw.splitlines() if x.startswith('{')];assert len(records)==9
    for line,expected in zip(records,[ts['warmup'],*ts['samples']]):v.validate(line,schema,False,256,expected);assert v.normalized(json.loads(line),schema)==expected['final']
    counts=json.loads(next(x.split(':',1)[1] for x in raw.splitlines() if x.startswith('ALLOCATION-COUNTS:')));sites=json.loads(pathlib.Path(str(counted)+'.sites.json').read_text())['sites'];kinds={}
    for n,site in zip(counts,sites):kinds[site['kind']]=kinds.get(site['kind'],0)+n
    r['counts'].append({'schema':schema,'role':role,'ordinaryConstructors':sum(counts),'kinds':kinds,'fullWorlds':9,'programSHA256':sha(program)});save()
  else:
   before=run(['node',inp],pin['label']+'-before');after=run(['node',out],pin['label']+'-after');assert before==after and len(before.splitlines())==72;r['controllers'].append({'label':pin['label'],'records':72,'inputSHA256':digest,'outputSHA256':sha(out)});save()
 assert len(r['counts'])==4;r.update(status='FRESH_NINE_WORLDS_BOTH_SCHEMAS_PASS')
except Exception as e:r.update(status='FAILED',error=repr(e))
save();print(json.dumps({'status':r['status'],'error':r.get('error'),'counts':r['counts'],'controllers':len(r['controllers'])}));sys.exit(0 if r['status']=='FRESH_NINE_WORLDS_BOTH_SCHEMAS_PASS' else 1)
