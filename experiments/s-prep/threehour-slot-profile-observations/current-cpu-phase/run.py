#!/usr/bin/env python3
"""Read-only full65 V8 inlining/deopt diagnosis; no comparative clocks."""
from pathlib import Path
import sys,os,json,argparse,hashlib,importlib.util,re
R=Path('/workspace/formal-proofs/bendvy');sys.path.insert(0,str(R/'experiments/s-prep/fivehour-connected-gates'));from supervisor import execute
p=argparse.ArgumentParser();p.add_argument('--schema',choices=['Motion','Health'],required=True);p.add_argument('--program',type=Path,required=True);p.add_argument('--catalog',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args();a.output.mkdir(exist_ok=False);os.sched_setaffinity(0,{7});sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();r={'status':'INCOMPLETE','scope':'Actual full65 inlining/deoptimization diagnosis; no elapsed comparison','cpu':7,'commands':[],'roles':[]}
def run(args,label):
 code,out=execute(list(map(str,args)),5);f=a.output/(label+'.txt');f.write_text(out);r['commands'].append({'argv':list(map(str,args)),'cap':5,'exit':code,'outputSHA':sha(f)});assert code==0,out[-1000:];return out
try:
 ref=a.output/'reference.mjs';run([sys.executable,R/'experiments/s-prep/fivehour-measurement/prepare-ts.py','--source',R/'experiments/s-integrate/measurement-samples-reference.mjs','--output',ref,'--schema',a.schema,'--batch','64'],'prepare');ts=json.loads(run(['node',ref],'ts'))
 spec=importlib.util.spec_from_file_location('V',R/'experiments/s-integrate/measurement-bend-run.py');V=importlib.util.module_from_spec(spec);spec.loader.exec_module(V)
 program=a.program;role='JS';catalog=json.loads(a.catalog.read_text());r['catalogSHA256']=sha(a.catalog);pin=catalog[sha(program)]
 for name,digest in pin['files'].items():assert sha(Path(name))==digest
 r['sourceRoot']=pin['sourceRoot'];r['sourcePins']=pin['sourcePins'];r['inputSHA256']=sha(program)
 js=program.read_text();timed='$'+a.schema.lower()+'_timed$';begin=js.index('function '+timed+'(');end=js.index('\nfunction ',begin+1);body=js[begin:end];clocks=re.findall(r'\$IO\$now\$\([^()]*\)',body);assert len(clocks)==2 and len(set(clocks))==2
 r['phaseCertificate']={'function':timed,'originalBodySHA256':hashlib.sha256(body.encode()).hexdigest(),'clockCalls':clocks,'start':'immediately before first IO.now invocation','stop':'immediately before second IO.now, after execute returns and before dump/serialization'}
 for needle,phase in zip(clocks,['start','stop']):assert body.count(needle)==1;body=body.replace(needle,'(__phase_'+phase+'(), '+needle+')')
 prefix="""const __phase_fs=require('node:fs'),__phase_session=new(require('node:inspector').Session)();__phase_session.connect();let __phase_count=0,__phase_begin;
function __phase_post(method,params){let done=false,result;__phase_session.post(method,params,(err,value)=>{if(err)throw err;result=value;done=true;});if(!done)throw Error('inspector callback not synchronous');return result;}
__phase_post('Profiler.enable',{});__phase_post('Profiler.setSamplingInterval',{interval:100});
function __phase_start(){if(__phase_count++!==0)throw Error('phase start');__phase_post('Profiler.start',{});__phase_begin=Number(process.hrtime.bigint()/1000n);}
function __phase_stop(){if(__phase_count++!==1)throw Error('phase stop');const end=Number(process.hrtime.bigint()/1000n);const result=__phase_post('Profiler.stop',{});__phase_fs.writeFileSync(MARK_PATH,JSON.stringify({begin:__phase_begin,end}));__phase_fs.writeFileSync(PROFILE_PATH,JSON.stringify(result.profile));__phase_session.disconnect();}
if(!process.stdout._handle)throw Error('stdout');process.stdout._handle.setBlocking(true);
""".replace('PROFILE_PATH',json.dumps(str(a.output/'JS.cpuprofile'))).replace('MARK_PATH',json.dumps(str(a.output/'phase-marks.json')))
 derived=a.output/'phase.js';derived.write_text(prefix+js[:begin]+body+js[end:]);raw=run(['node',derived],'JS');records=[x for x in raw.splitlines() if x.startswith('{')];assert len(records)==65
 for line,w in zip(records,[ts['warmup'],*ts['samples']]):V.validate(line,a.schema,False,256,w);assert V.normalized(json.loads(line),a.schema)==w['final']
 prof=json.loads((a.output/'JS.cpuprofile').read_text());assert len(prof['samples'])==len(prof['timeDeltas']);nodes={x['id']:x for x in prof['nodes']};from collections import Counter
 counts=Counter()
 marks=json.loads((a.output/'phase-marks.json').read_text());assert prof['startTime']<=marks['begin']<marks['end']<=prof['endTime'];now=prof['startTime']
 for ident,dt in zip(prof['samples'],prof['timeDeltas']):
  end=now+dt;counts[ident]+=max(0,min(end,marks['end'])-max(now,marks['begin']));now=end
 total=sum(counts.values());assert total>0
 def label(frame):return re.sub(r'\$(\d{3})',lambda m:chr(int(m[1])),frame['functionName']).strip('$')
 top=[{'function':label(nodes[i]['callFrame']),'selfPercent':100*v/total,'sampleMicroseconds':v,'line':nodes[i]['callFrame']['lineNumber']+1,'node':i} for i,v in counts.most_common(30)]
 (a.output/'summary.json').write_text(json.dumps({'schema':a.schema,'topSelf':top,'sampleMicroseconds':total,'limits':'Perturbed phase CPU sampling only; no elapsed comparison or allocation count'},indent=2)+'\n')
 r['roles']=[{'role':'JS','inputSHA':sha(program),'derivedSHA':sha(derived),'worlds':65,'profileSHA':sha(a.output/'JS.cpuprofile')}]
 r['status']='PHASE_CPU_AND_FULL65_PASS'
except Exception as e:r.update(status='FAILED',error=repr(e))
(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n');print(json.dumps({'status':r['status'],'error':r.get('error'),'roles':r['roles']}));sys.exit(0 if r['status'].endswith('_PASS') else 1)
