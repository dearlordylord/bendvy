#!/usr/bin/env python3
"""Approved isolated Clang19 build of unchanged pinned generated C."""
import hashlib,json,os,pathlib,signal,subprocess
HERE=pathlib.Path(__file__).resolve().parent;OUT=pathlib.Path('/tmp/bendvy-clang19-diagnostic');WRAPPER=OUT/'clang19';env=dict(os.environ,BENDVY_CLANG19_ROOT=str(OUT/'root'))
tool=json.loads((HERE/'toolchain.json').read_text());assert hashlib.sha256(WRAPPER.read_bytes()).hexdigest()==tool['wrapperSHA256']
for filename,pin in tool['ELF'].items():assert hashlib.sha256(pathlib.Path(filename).read_bytes()).hexdigest()==pin['sha256']
assert hashlib.sha256(pathlib.Path(tool['existingZ3']['path']).read_bytes()).hexdigest()==tool['existingZ3']['SHA256']
subjects=[('Motion','baseline','/tmp/bendvy-live-first-native-static'),('Motion','candidate','/tmp/bendvy-query-frozen-provider-motion-build-v2'),('Health','baseline','/tmp/bendvy-cache-box-baseline-health'),('Health','candidate','/tmp/bendvy-query-frozen-provider-health-build')]
r={'status':'INCOMPLETE','toolchainReceiptSHA256':hashlib.sha256((HERE/'toolchain.json').read_bytes()).hexdigest(),'wrapperSHA256':hashlib.sha256(WRAPPER.read_bytes()).hexdigest(),'compilerArguments':['-O3','-pthread','-lm'],'sourceEdited':False,'subjects':{}}
for schema,role,directory in subjects:
 d=pathlib.Path(directory);c=d/'batch.c';source=d/'batch.bend';name=schema.lower()+'-'+role;binary=OUT/(name+'.native');before=hashlib.sha256(c.read_bytes()).hexdigest();receipt={'CPath':str(c),'CSHA256':before,'entryPath':str(source),'entrySHA256':hashlib.sha256(source.read_bytes()).hexdigest(),'upstreamBuildReceiptSHA256':hashlib.sha256((d/'build.json').read_bytes()).hexdigest(),'binary':str(binary),'status':'INCOMPLETE'};r['subjects'][name]=receipt
 argv=['taskset','-c','11',str(WRAPPER),'-O3',str(c),'-pthread','-lm','-o',str(binary)];receipt['command']={'argv':argv,'limitSeconds':120};(HERE/'builds.json').write_text(json.dumps(r,indent=2)+'\n')
 child=subprocess.Popen(argv,env=env,text=True,stdout=subprocess.PIPE,stderr=subprocess.PIPE,start_new_session=True)
 try:out,err=child.communicate(timeout=120)
 except subprocess.TimeoutExpired:os.killpg(child.pid,signal.SIGKILL);out,err=child.communicate();receipt.update({'status':'TIMEOUT','out':out,'err':err});(HERE/'builds.json').write_text(json.dumps(r,indent=2)+'\n');raise
 receipt['command'].update({'exit':child.returncode,'stdout':out,'stderr':err});assert child.returncode==0,receipt;after=hashlib.sha256(c.read_bytes()).hexdigest();assert after==before
 receipt.update({'status':'UNCHANGED_C_CLANG19_BUILD_PASS','CAfterSHA256':after,'binarySHA256':hashlib.sha256(binary.read_bytes()).hexdigest()});(HERE/'builds.json').write_text(json.dumps(r,indent=2)+'\n');print(name,binary,flush=True)
r['status']='FOUR_UNCHANGED_C_SAME_CLANG19_BUILDS_PASS';(HERE/'builds.json').write_text(json.dumps(r,indent=2)+'\n')
