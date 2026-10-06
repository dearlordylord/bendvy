#!/usr/bin/env python3
"""Bounded V8 diagnostic; eight worlds, no performance acceptance or compiler edits."""
import argparse,hashlib,importlib.util,json,os,re,sys
from pathlib import Path
ROOT=Path('/workspace/formal-proofs/bendvy')
sys.path.insert(0,str(ROOT/'experiments/s-prep/fivehour-connected-gates'));import supervisor
H=ROOT/'experiments/s-prep/fivehour-measurement'
p=argparse.ArgumentParser();p.add_argument('--generated-js',type=Path,required=True);p.add_argument('--output',type=Path,required=True);p.add_argument('--cpu',type=int,default=11);p.add_argument("--no-gc",action="store_true",help="Disable GC tracing when only constructor counts are needed");a=p.parse_args();a.output.mkdir(exist_ok=False);os.sched_setaffinity(0,{a.cpu})
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
r={'status':'INCOMPLETE','scope':'CPU/GC diagnosis with equal eight fresh worlds; no timing acceptance','batch':8,'ticks':64,'entities':256,'cpu':a.cpu,'gcTracing':not a.no_gc,'generatedOriginalSHA256':sha(a.generated_js),'commands':[]}
def command(args,limit=5):
 code,text=supervisor.execute(list(map(str,args)),limit);r['commands'].append({'argv':list(map(str,args)),'limit':limit,'exit':code});assert code==0,text[-1000:];return text
try:
 js=a.generated_js.read_text()
 entries=[('return $choose$(0, 256, 64);','return $choose$(0, 256, 8);'),('return $health_batch$(256, 64);','return $health_batch$(256, 8);')]
 selected=[(old,new) for old,new in entries if js.count(old)==1]
 assert len(selected)==1 and sum(js.count(old) for old,_ in entries)==1,'Ambiguous or unsupported full64 Motion entry'
 old,new=selected[0];js=js.replace(old,new,1);r['entryAdaptation']={'original':old,'derived':new}
 begin=js.index('function $health_timed$(');end=js.index('\nfunction ',begin+1);body=js[begin:end];needle='$IO$now$(_x_1)';assert body.count(needle)==1;body=body.replace(needle,'(__profile_mark("start"), '+needle+')');needle='$IO$now$(_x_6)';assert body.count(needle)==1;body=body.replace(needle,'(__profile_mark("end"), '+needle+')');js=js[:begin]+body+js[end:]
 marker='function __profile_mark(phase) { if(typeof __allocation_phase === "function") __allocation_phase(phase); console.error("PROFILE-MARK:" + JSON.stringify({phase, micro:Number(process.hrtime.bigint()/1000n), uptimeMS:process.uptime()*1000})); }\n'
 # V8 writes GC traces directly to stdout. A pending asynchronous large JSON
 # write can be split by those traces; synchronously serialize outside the phase.
 transport='if (!process.stdout._handle || typeof process.stdout._handle.setBlocking !== "function") throw Error("Unsupported diagnostic stdout transport"); process.stdout._handle.setBlocking(true);\n'
 r['outputTransport']='Both roles use blocking stdout to prevent GC trace/JSON interleaving; setup/output remain outside the measured phase'
 js=marker+transport+'console.error("PROFILE-READY");\n'+js
 (a.output/'bend.js').write_text(js)
 command([sys.executable,H/'prepare-ts.py','--source',ROOT/'experiments/s-integrate/measurement-samples-reference.mjs','--output',a.output/'reference.mjs','--schema','Health','--batch','8'])
 ts=(a.output/'reference.mjs').read_text();needle='const start=performance.now();for(const owner of prepared)owner.run();const end=performance.now();';assert ts.count(needle)==1;ts=ts.replace(needle,'__profile_mark("start");'+needle+'__profile_mark("end");');(a.output/'reference.mjs').write_text(marker+transport+'console.error("PROFILE-READY");\n'+ts)
 r['derivedPins']={name:sha(a.output/name) for name in ['bend.js','reference.mjs']}
 outputs={}
 for role,entry in [('TS','reference.mjs'),('JS','bend.js')]:
  text=command(['node','--cpu-prof','--cpu-prof-interval=100','--cpu-prof-dir='+str(a.output),'--cpu-prof-name='+role+'.cpuprofile',*([] if a.no_gc else ['--trace-gc-nvp']),a.output/entry]);(a.output/(role+'.raw.txt')).write_text(text)
  lines=text.splitlines();marks=[json.loads(x.split('PROFILE-MARK:',1)[1]) for x in lines if x.startswith('PROFILE-MARK:')];assert [x['phase'] for x in marks]==['start','end'];r.setdefault('marks',{})[role]=marks
  clean=[x for x in lines if x.startswith('BATCH-MILLISECONDS:') or x.startswith('{')];outputs[role]='\n'.join(clean);(a.output/(role+'.observed.txt')).write_text(outputs[role]);assert (a.output/(role+'.cpuprofile')).exists()
 spec=importlib.util.spec_from_file_location('validator',ROOT/'experiments/s-integrate/measurement-bend-run.py');V=importlib.util.module_from_spec(spec);spec.loader.exec_module(V)
 ts=json.loads(outputs['TS']);records=[x for x in outputs['JS'].splitlines() if x.startswith('{')];assert len(records)==9 and len(ts['samples'])==8
 for line,world in zip(records,[ts['warmup'],*ts['samples']]):V.validate(line,'Health',False,256,world);assert V.normalized(json.loads(line),'Health')==world['final']
 r.update(status='PROFILE_AND_NINE_FULL_HEALTH_WORLDS_PASS',allFullFieldsEqual=True)
except Exception as e:r.update(status='FAILED',error=repr(e))
finally:(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n')
print(json.dumps(r));sys.exit(0 if r['status']=='PROFILE_AND_NINE_FULL_HEALTH_WORLDS_PASS' else 1)
