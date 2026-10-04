#!/usr/bin/env python3
"""One-shot unchanged-source diagnostics; no replacement samples or optimization."""
import hashlib, importlib.util, json, os, pathlib, selectors, signal, subprocess, time, re
ROOT=pathlib.Path(__file__).resolve().parents[3]; HERE=pathlib.Path(__file__).resolve().parent
PIN='56b72f6'; CPU=6
os.sched_setaffinity(0,{CPU})
def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest()
def load(name,p):
 s=importlib.util.spec_from_file_location(name,p);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
def run(cmd,limit=5):
 start=time.monotonic();p=subprocess.Popen(list(map(str,cmd)),stdout=subprocess.PIPE,stderr=subprocess.PIPE,start_new_session=True)
 sel=selectors.DefaultSelector();sel.register(p.stdout,selectors.EVENT_READ,'stdout');sel.register(p.stderr,selectors.EVENT_READ,'stderr')
 chunks={'stdout':bytearray(),'stderr':bytearray()};first={}; expired=False; markers=[]; scan_tail=b''
 while sel.get_map():
  if time.monotonic()-start>=limit:
   expired=True;os.killpg(p.pid,signal.SIGKILL);break
  for key,_ in sel.select(min(.05,max(0,limit-(time.monotonic()-start)))):
   part=os.read(key.fd,65536)
   if part:
    first.setdefault(key.data,time.monotonic()-start);chunks[key.data].extend(part)
    if key.data=='stdout':
     scan=scan_tail+part
     lines=scan.split(b'\n');scan_tail=lines.pop()
     for line in lines:
      for match in re.finditer(rb'(FAILURE-FOLD:[0-9]+|FAILURE-TIMING:[0-9]+|"timingMilliseconds":[0-9]+)',line):
       markers.append({'marker':match.group().decode(),'observedSeconds':time.monotonic()-start})
     # Tuple lines are huge; only timing/fold line prefixes can carry markers.
     if len(scan_tail)>256:scan_tail=b''

   else:sel.unregister(key.fileobj)
 p.wait();sel.close()
 text=bytes(chunks['stdout']).decode(errors='replace')
 return {'command':list(map(str,cmd)),'limitSeconds':limit,'exitCode':p.returncode,'deadline':expired,'wallSeconds':time.monotonic()-start,'firstObservedByteSeconds':first,'stdoutBytes':len(chunks['stdout']),'markers':markers,'stdoutSHA256':hashlib.sha256(chunks['stdout']).hexdigest(),'stderr':bytes(chunks['stderr']).decode(errors='replace')[-1000:]},text
report={'sourceCommit':subprocess.check_output(['git','rev-parse',PIN],cwd=ROOT,text=True).strip(),'cpuAffinity':[CPU],'isolatedPhases':True,'machineExclusive':False,'sampling':'one execution per listed unchanged case/backend; no retries','limitsSeconds':{'checker':5,'runtime':5,'codegen':30,'clang':120},'tools':{},'references':{},'sources':{},'cases':[]}
for cmd in [['bend','version'],['bend','guide'],['node','--version'],['clang','--version']]:
 meta,out=run(cmd);report['tools'][' '.join(cmd)]={**meta,'outputSHA256':hashlib.sha256(out.encode()).hexdigest(),'firstLine':out.splitlines()[0] if out else ''}
manifest=json.loads((ROOT/'experiments/s-perf/baseline.json').read_text())
for name,pin in manifest['references'].items():
 actual=subprocess.check_output(['git','-C','/workspace/formal-proofs/bendvy/.references/'+name,'rev-parse','HEAD'],text=True).strip();report['references'][name]={'expected':pin['commit'],'actual':actual};assert actual==pin['commit']
for path in ['experiments/s-perf/candidate/storage.bend','experiments/s-perf/candidate/query.bend','experiments/s-perf/failure-quiet-driver.py','experiments/s-perf/failure-quiet-codec.bend','experiments/s-perf/failure-quiet-reference.mjs','experiments/s-perf/readers-reference.mjs','experiments/s-integrate/measurement-samples-readers.bend','experiments/s-perf/failure-validate.py','experiments/s-integrate/measurement-samples-readers-run.py']:
 report['sources'][path]=sha(ROOT/path)
R=load('method_readers',ROOT/'experiments/s-integrate/measurement-samples-readers-run.py')
V=load('method_failure',ROOT/'experiments/s-perf/failure-validate.py')
def save(): (HERE/'evidence.json').write_text(json.dumps(report,indent=2)+'\n')
for workload in ['readers','failed-transaction']:
 refmeta,refout=run(['node',ROOT/'experiments/s-integrate/measurement-reference.mjs','Motion',workload,'1024']);ref=json.loads(refout) if refmeta['exitCode']==0 else None
 report['cases'].append({'phase':'unchanged-full-reference','workload':workload,**refmeta,'oracle':'REFERENCE_OBSERVED' if ref else 'UNAVAILABLE'});save()
 folder=pathlib.Path('/tmp/bendvy-indexed-readers3' if workload=='readers' else '/tmp/bendvy-perf-failure-quiet-fair')
 historical=json.loads((ROOT/('experiments/s-perf/indexed-readers-evidence.json' if workload=='readers' else 'experiments/s-perf/failure-quiet-build-evidence.json')).read_text())
 artifacts=historical['artifacts'];names=['measurement-samples-readers-native','measurement-samples-readers.js'] if workload=='readers' else ['driver-native','driver.js']
 for name in names:assert sha(folder/name)==artifacts[name],('artifact drift',name)
 for backend in ['Native','JS','TS']:
  if backend=='TS':cmd=['node',ROOT/('experiments/s-perf/readers-reference.mjs' if workload=='readers' else 'experiments/s-perf/failure-quiet-reference.mjs'),'Motion','1024']
  else:
   program=folder/names[backend=='JS'];cmd=([program] if backend=='Native' else ['node',program])+['0','1024']+([] if workload=='readers' else ['64'])+(['--threads','1','--gpu','off'] if backend=='Native' else [])
  meta,out=run(cmd);case={'phase':'unchanged-runtime','workload':workload,'schema':'Motion','count':1024,'backend':backend,**meta,'oracle':'UNAVAILABLE: deadline/nonzero output cannot pass full fields'}
  if backend!='TS':case['artifactSHA256']=sha(program)
  if meta['exitCode']==0 and not meta['deadline'] and ref:
   output_file=HERE/'temporary-output.txt';ref_file=HERE/'temporary-reference.json'
   output_file.write_text(out);ref_file.write_text(json.dumps(ref))
   vm,validated=run(['python3',HERE/'validate.py',workload,backend,output_file,output_file,ref_file])
   case['validatorPhase']=vm
   output_file.unlink();ref_file.unlink()
   if vm['exitCode']==0 and not vm['deadline']:
    case.update(json.loads(validated));case['oracle']='PASS unchanged full-field validator'
   else:case['oracle']='FAILED_OR_UNAVAILABLE';case['methodError']='bounded full-field validator unavailable: '+str(vm)
  report['cases'].append(case);save();print(workload,backend,case['oracle'],meta['wallSeconds'],flush=True)
report['interpretation']='Observed first-byte and whole-child boundaries are not isolated ECS costs. No replacement seven rotations, margin acceptance, or ready gate.';save()
