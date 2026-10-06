#!/usr/bin/env python3
"""Observe phase CPU versus wall time while retaining full65 fields and limits."""
import argparse,hashlib,importlib.util,json,os,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3];sys.path.insert(0,str(ROOT/'experiments/s-prep/fivehour-connected-gates'));import supervisor
p=argparse.ArgumentParser();p.add_argument('--c',type=Path,required=True);p.add_argument('--js',type=Path,required=True);p.add_argument('--reference',type=Path,required=True);p.add_argument('--schema',choices=['Motion','Health'],required=True);p.add_argument('--output',type=Path,required=True);p.add_argument('--cpu',type=int,default=7);a=p.parse_args();a.output=a.output.absolute();a.output.mkdir(exist_ok=False);os.sched_setaffinity(0,{a.cpu});sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
r={'status':'INCOMPLETE','scope':'Phase CPU/wall diagnosis with small instrumentation; no speed/qualification/keep claim','schema':a.schema,'cpu':a.cpu,'originalPins':{k:sha(getattr(a,k)) for k in ['c','js','reference']},'recipeSHA256':sha(Path(__file__)),'commands':[]}
def command(args,limit=5,output=None):
 code,out=supervisor.execute(list(map(str,args)),limit);r['commands'].append({'argv':list(map(str,args)),'limitSeconds':limit,'exit':code,'outputSHA256':hashlib.sha256(out.encode()).hexdigest()})
 if output:(a.output/output).write_text(out)
 assert code==0,out[-1000:]
 return out
try:
 c=a.c.read_text();old='Term io_now_run(Env e, Term* f, IoWork* w) {\n  return (Term)(io_tick() / 1000000);\n}';assert c.count(old)==1 and 'phase_cpu_clocks' not in c
 new='''#include <sys/resource.h>
static unsigned phase_cpu_clocks;
static struct rusage phase_cpu_start;
static u64 phase_wall_start;
Term io_now_run(Env e, Term* f, IoWork* w) {
  unsigned n=++phase_cpu_clocks;
  if (n==3) { if(getrusage(RUSAGE_SELF,&phase_cpu_start)) abort(); phase_wall_start=io_tick(); }
  u64 tick=io_tick();
  if(n==4) {
    struct rusage end; if(getrusage(RUSAGE_SELF,&end)) abort();
    double user=(end.ru_utime.tv_sec-phase_cpu_start.ru_utime.tv_sec)*1000.0+(end.ru_utime.tv_usec-phase_cpu_start.ru_utime.tv_usec)/1000.0;
    double sys=(end.ru_stime.tv_sec-phase_cpu_start.ru_stime.tv_sec)*1000.0+(end.ru_stime.tv_usec-phase_cpu_start.ru_stime.tv_usec)/1000.0;
    fprintf(stderr,"PHASE-CPU:{\\"userMS\\":%.3f,\\"systemMS\\":%.3f,\\"wallMS\\":%.6f}\\n",user,sys,(tick-phase_wall_start)/1000000.0);
  }
  return (Term)(tick/1000000);
}'''
 (a.output/'cpu.c').write_text(c.replace(old,new,1))
 prefix='''let __phaseCPUStart, __phaseCPUEnd, __phaseWallStart, __phaseWallEnd;
function __phase_start(){if(__phaseCPUStart)throw Error('Duplicate phase');__phaseCPUStart=process.cpuUsage();__phaseWallStart=process.hrtime.bigint();}
function __phase_end(){__phaseWallEnd=process.hrtime.bigint();__phaseCPUEnd=process.cpuUsage(__phaseCPUStart);console.error('PHASE-CPU:'+JSON.stringify({userMS:__phaseCPUEnd.user/1000,systemMS:__phaseCPUEnd.system/1000,wallMS:Number(__phaseWallEnd-__phaseWallStart)/1e6}));}
process.on('exit',()=>{if(!__phaseCPUEnd)throw Error('Missing phase');});
'''
 js=a.js.read_text();assert '__phaseCPUStart' not in js
 name=a.schema.lower();start=js.index('function $'+name+'_timed$(');end=js.index('\nfunction ',start+1);body=js[start:end]
 for mark,old in [('start','$IO$now$(_x_1)'),('end','$IO$now$(_x_6)')]:assert body.count(old)==1;body=body.replace(old,'(__phase_'+mark+'(), '+old+')',1)
 (a.output/'cpu.js').write_text(prefix+js[:start]+body+js[end:])
 ts=a.reference.read_text();anchor='const start=performance.now();for(const owner of prepared)owner.run();const end=performance.now();';assert ts.count(anchor)==1
 (a.output/'reference.mjs').write_text(prefix+ts.replace(anchor,'__phase_start();'+anchor+'__phase_end();',1))
 r['derivedPins']={n:sha(a.output/n) for n in ['cpu.c','cpu.js','reference.mjs']}
 command(['env','BENDVY_CLANG19_ROOT=/tmp/bendvy-clang19-diagnostic/root','/tmp/bendvy-clang19-diagnostic/clang19','-O3',a.output/'cpu.c','-pthread','-lm','-o',a.output/'cpu.native'],120,'compile.txt');r['binarySHA256']=sha(a.output/'cpu.native')
 redir='import os,sys;fd=os.open(sys.argv[1],os.O_WRONLY|os.O_CREAT|os.O_EXCL,0o600);os.dup2(fd,2);os.close(fd);os.execvp(sys.argv[2],sys.argv[2:])'
 outputs={}
 for role,args in [('TS',['node',a.output/'reference.mjs']),('Native',[a.output/'cpu.native','--threads','1','--gpu','off']),('JS',['node',a.output/'cpu.js'])]:
  outputs[role]=command([sys.executable,'-c',redir,a.output/(role+'.stderr.txt'),*args],5,role+'.raw.txt')
  lines=(a.output/(role+'.stderr.txt')).read_text().splitlines();assert len(lines)==1 and lines[0].startswith('PHASE-CPU:');r.setdefault('phaseCPU',{})[role]=json.loads(lines[0].split(':',1)[1])
 ref=json.loads(outputs['TS']);assert ref['schema']==a.schema and len(ref['samples'])==64
 spec=importlib.util.spec_from_file_location('v',ROOT/'experiments/s-integrate/measurement-bend-run.py');v=importlib.util.module_from_spec(spec);spec.loader.exec_module(v)
 for role in ['Native','JS']:
  lines=[x for x in outputs[role].splitlines() if x.startswith('{')];assert len(lines)==65
  for line,w in zip(lines,[ref['warmup'],*ref['samples']]):v.validate(line,a.schema,False,256,w);assert v.normalized(json.loads(line),a.schema)==w['final']
 assert all(sha(getattr(a,k))==h for k,h in r['originalPins'].items())
 r.update(status='PHASE_CPU_AND_FULL65_FIELDS_PASS',allFullFieldsEqual=True,limits='CPU sums all process threads; instrumentation adds small boundary cost; wall/CPU differences do not independently prove scheduler causation. Not a performance metric.')
except Exception as e:r.update(status='FAILED',error=repr(e))
finally:(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n')
print(json.dumps({'status':r['status'],'phaseCPU':r.get('phaseCPU'),'error':r.get('error')}));sys.exit(0 if r['status']=='PHASE_CPU_AND_FULL65_FIELDS_PASS' else 1)
