#!/usr/bin/env python3
"""Run unchanged archived provider controls against explicitly new callback bytes."""
import argparse,hashlib,importlib.util,json,os,re,subprocess,tempfile
from pathlib import Path
ROOT=Path('/workspace/formal-proofs/bendvy')
p=argparse.ArgumentParser();p.add_argument('--overlay',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args();a.output.mkdir(exist_ok=False);os.sched_setaffinity(0,{8})
spec=importlib.util.spec_from_file_location('boundary',ROOT/'experiments/s-prep/fivehour-connected-gates/static_provider_boundary.py');b=importlib.util.module_from_spec(spec)
import sys;sys.path.insert(0,str(ROOT/'experiments/s-prep/fivehour-connected-gates'));spec.loader.exec_module(b)
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
m=json.loads((a.overlay/'overlay.json').read_text());assert all(sha(a.overlay/n)==v for n,v in m['sources'].items());assert len(m['sources'])==29
r={'scope':'Fresh unchanged archived provider controls on explicitly new token-reuse callback source; no original-callback-pin acceptance, proof or universal refinement','overlaySHA256':sha(a.overlay/'overlay.json'),'sourcePins':m['sources'],'checkerLimitSeconds':15,'cpu':[8],'cases':[]}
for name,contract in sorted(b.CASES.items()):
 archive=ROOT/'docs/research/static-provider-dispatch/controls'/(name+'.bend.txt');assert sha(archive)==contract['sourceSHA256'];text=archive.read_text()
 for relative in re.findall(r'^import (\S+)',text,re.M):
  if relative=='Base':continue
  assert relative.startswith('../JS/experiments/s-integrate/') and relative.endswith('.bend')
  text=text.replace('import '+relative+' as ','import '+str(a.overlay/'experiments/s-integrate'/Path(relative).name)+' as ')
 source=a.output/(name+'.bend');source.write_text(text);argv=['bend',str(source),'--check-only'];result=subprocess.run(argv,capture_output=True,text=True,timeout=15);out=result.stdout+result.stderr;(a.output/(name+'.txt')).write_text(out)
 assert result.returncode==contract['exit'],out
 assert ('ALL PROOFS CHECK' if contract['exit']==0 else 'SOME PROOFS FAIL') in out,out
 assert all(x in out for x in contract['diagnostics']),out
 r['cases'].append({'name':name,'command':argv,'expectedExit':contract['exit'],'exit':result.returncode,'sourceSHA256':sha(source),'outputSHA256':sha(a.output/(name+'.txt')),'archiveSHA256':sha(archive),'intendedDiagnostics':contract['diagnostics']})
r['status']='FRESH_NEW_SOURCE_EIGHT_PROVIDER_CONTROLS_PASS';(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n');print(r['status'])
