import pathlib,subprocess,json,hashlib,re,ctypes
P=pathlib.Path;out=P('/tmp/bendvy-native-lse-concrete-motion-v1');sha=lambda p:hashlib.sha256(P(p).read_bytes()).hexdigest();r=json.loads((out/'evidence.json').read_text());assert r['status']=='MOTION_CONCRETE_UNCHANGED_C_LSE_BUILD_AND_ELF_INSPECTION_PASS';files={};deps={};commands=[]
for tool in ['/usr/bin/nm','/usr/bin/objdump','/usr/bin/lscpu']:
 files[str(P(tool).resolve())]=sha(P(tool).resolve());x=subprocess.run(['taskset','-c','6','ldd',tool],capture_output=True,text=True,timeout=5);assert x.returncode==0 and 'not found'not in x.stdout;deps[tool]=x.stdout
 for n in re.findall(r'(/[^\s()]+)',x.stdout):files[str(P(n).resolve())]=sha(P(n).resolve())
receipt={'status':'INCOMPLETE','recipeSHA256':sha(__file__),'pinsBefore':files,'resolvedLibraries':deps,'inputBuildReceiptSHA256':sha(out/'evidence.json'),'commands':commands,'subjects':{}};save=lambda:(out/'fresh-elf-inspection.json').write_text(json.dumps(receipt,indent=2)+'\n');save()
x=subprocess.run(['taskset','-c','6','/usr/bin/lscpu'],capture_output=True,text=True,timeout=5);assert x.returncode==0;(out/'lscpu.txt').write_text(x.stdout);assert 'atomics'in x.stdout
for schema,b in r['subjects'].items():
 for kind,path,h in [('baseline',b['baselineNative'],b['baselineNativeSHA256']),('lse',b['native'],b['nativeSHA256'])]:
  assert sha(path)==h
  for tool in ['nm','objdump']:
   cmd=['taskset','-c','6','/usr/bin/'+tool,*(['-d']if tool=='objdump'else[]),path];x=subprocess.run(cmd,capture_output=True,text=True,timeout=5);assert x.returncode==0;name=schema+'-'+kind+'-fresh-'+tool+'.txt';(out/name).write_text(x.stdout);commands.append({'argv':cmd,'limitSeconds':5,'exit':x.returncode,'outputSHA256':sha(out/name),'output':name})
   if tool=='objdump':
    calls=re.findall(r'\bbl\s+[^\n]*<(__aarch64_[^>]+)>',x.stdout);lse=re.findall(r'\b(?:ldadd[a-z]*|cas[a-z]*|swp[a-z]*|ldclr[a-z]*|ldset[a-z]*|ldeor[a-z]*)\b',x.stdout);receipt['subjects'][schema+'-'+kind]={'nativeSHA256':h,'outlinedCallSites':{n:calls.count(n)for n in sorted(set(calls))},'lseInstructionSites':{n:lse.count(n)for n in sorted(set(lse))}}
  assert sha(path)==h;save()
 assert sha(b['inputC'])==b['inputCSHA256'];assert all(sha(P(b['sourceRoot'])/n)==h for n,h in b['source29'].items());assert all(sha(P(b['sourceRoot'])/n)==h for n,h in b['inputMaps'].items())
assert all(sha(n)==h for n,h in files.items());receipt.update(status='FRESH_RESOLVED_ELF_TOOLS_AND_SOURCE_BINARY_STABILITY_PASS',allPinnedBytesStableBeforeAfter=True);save()
