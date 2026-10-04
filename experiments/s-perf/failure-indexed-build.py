#!/usr/bin/env python3
import pathlib,sys,os,json,hashlib
os.sched_setaffinity(0,{7})
H=pathlib.Path(__file__).resolve().parent;R=H.parents[1];sys.path.insert(0,str(R/'experiments/t05'));from run import command
F=pathlib.Path('/tmp/bendvy-perf-failure-indexed');F.mkdir(exist_ok=True)
p=H/'failure-indexed-overlay/experiments/s-integrate/measurement-failure-driver.bend';record={'cpu':7,'limits_seconds':{'checker':5,'codegen':30,'clang':120},'compiler':command(['bend','version']).strip()}
for phase,args,limit in [('checker',['bend',p,'--check-only'],5),('c',['bend',p,'-o',F/'driver.c'],30),('native',['clang','-std=c11','-O3',F/'driver.c','-lpthread','-lm','-o',F/'driver-native'],120),('javascript',['bend',p,'-o',F/'driver.js'],30)]:
 try:record[phase]={'status':'PASS','output':command(args,timeout=limit)}
 except Exception as e:record[phase]={'status':'FAILED_OR_UNRESOLVED','diagnostic':str(e)};break
 (H/'failure-indexed-build-evidence.json').write_text(json.dumps(record,indent=2)+'\n')
 print(phase,record[phase]['status'],flush=True)
record['artifacts']={x.name:hashlib.sha256(x.read_bytes()).hexdigest() for x in F.glob('driver*') if x.is_file()};(H/'failure-indexed-build-evidence.json').write_text(json.dumps(record,indent=2)+'\n')
