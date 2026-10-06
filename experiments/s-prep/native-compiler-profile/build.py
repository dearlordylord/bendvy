#!/usr/bin/env python3
"""Compile unchanged emitted C with the installed GCC; no compatibility shims."""
import argparse,hashlib,json,os,sys
from pathlib import Path
sys.path.insert(0,'/workspace/formal-proofs/bendvy/experiments/s-prep/fivehour-connected-gates');import supervisor
p=argparse.ArgumentParser();p.add_argument('--c',type=Path,required=True);p.add_argument('--output',type=Path,required=True);p.add_argument('--instrument-profile',type=Path);p.add_argument('--use-profile',type=Path);a=p.parse_args();assert not(a.instrument_profile and a.use_profile);a.output.mkdir(exist_ok=False);os.sched_setaffinity(0,{9})
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();sourceSHA=sha(a.c)
code,version=supervisor.execute(['/usr/bin/gcc','--version'],5);assert code==0
argv=['/usr/bin/gcc','-O3',str(a.c),'-o',str(a.output/'batch-native'),'-lm','-pthread']
if a.instrument_profile:argv.insert(2,'-fprofile-generate='+str(a.instrument_profile.absolute()))
if a.use_profile:argv[2:2]=['-fprofile-use='+str(a.use_profile.absolute()),'-Werror=missing-profile']
code,out=supervisor.execute(argv,120);assert sha(a.c)==sourceSHA
r={'scope':'Existing GCC unchanged emitted-C feasibility; no qualified cohort, adoption, source/kernel/compiler edit or cap reset','cpu':9,'inputC':str(a.c.absolute()),'inputSHA256':sourceSHA,'compilerVersion':version,'compilerPath':'/usr/bin/gcc','argv':argv,'limitSeconds':120,'exit':code,'output':out,'status':'GCC_BUILD_PASS' if code==0 else 'GCC_COMPATIBILITY_OR_BUILD_FAILURE'}
if code==0:r['binarySHA256']=sha(a.output/'batch-native')
(a.output/'build.json').write_text(json.dumps(r,indent=2)+'\n');print(json.dumps({k:v for k,v in r.items() if k not in ['output','compilerVersion']}));sys.exit(0 if code==0 else 1)
