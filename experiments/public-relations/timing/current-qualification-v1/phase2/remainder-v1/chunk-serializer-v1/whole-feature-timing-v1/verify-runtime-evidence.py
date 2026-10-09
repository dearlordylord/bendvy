"""No-child retained full model/raw/receipt/marker verification; no timing ratios."""
from pathlib import Path
import gzip,hashlib,importlib.util,json,sys
sys.dont_write_bytecode=True
HERE=Path(__file__).resolve().parent
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def main():
 evidence=HERE/'runtime-evidence-v1'
 for name,digest in json.loads((evidence/'manifest.json').read_text()).items():assert sha(evidence/name)==digest
 spec=importlib.util.spec_from_file_location('force',HERE.parents[3]/'trace-cheap.py');F=importlib.util.module_from_spec(spec);spec.loader.exec_module(F)
 subjects=json.loads((HERE/'prepared/manifest.json').read_text())['cases'];cases={'-'.join(c['input']):c for c in subjects};total=0;guards=0
 for role,expected_count in [('ts',9),('js',8)]:
  receipt=json.loads((evidence/role/'receipt.json').read_text());assert receipt['status']=='SEMANTICS_PASS_NO_COMPARATIVE_TIMING';assert len(receipt['commands'])==expected_count
  assert len(receipt['guards'])==2+2*expected_count and all(g['unchanged'] is True for g in receipt['guards']);guards+=len(receipt['guards'])
  if role=='js':assert all(c['label']!='population-1024-0-0' for c in receipt['commands'])
  for command in receipt['commands']:
   assert command['exit']==0 and command['failure'] is None and command['fullOraclePass'] is True and command['walkPass'] is True
   label=command['label'];case=cases[label];raw=gzip.decompress((evidence/role/(label+'.stdout.gz')).read_bytes());expected=gzip.decompress((HERE/'prepared'/case['oracle']).read_bytes())
   assert raw==expected and len(raw)==case['bytes'] and hashlib.sha256(raw).hexdigest()==case['sha256']
   assert hashlib.sha256(raw).hexdigest()==receipt['logs'][label+'.stdout']
   err=evidence/role/(label+'.stderr');assert sha(err)==receipt['logs'][label+'.stderr'];markers=[json.loads(line) for line in err.read_bytes().splitlines()]
   assert len(markers)==2 and markers[0]=={'boundary':'begin'};stop=markers[1];duration=stop.pop('elapsedNs');assert type(duration)is str and duration.isascii() and duration.isdecimal()
   for field in ('nodes','characters','sum'):assert type(stop[field])is int
   assert stop=={'boundary':'complete-trace-forced',**F.force(json.loads(expected)),'region':'whole-feature-setup-operations-full-trace'};total+=1
 build=json.loads((evidence/'native-build/receipt.json').read_text());assert build['status']=='NATIVE_BUILD_PASS_RUNTIME_UNADMITTED';assert len(build['commands'])==1 and build['commands'][0]['exit']==0 and build['commands'][0]['failure'] is None
 assert len(build['guards'])==4 and all(g['unchanged'] is True for g in build['guards']);guards+=4
 for name,digest in build['logs'].items():assert (evidence/'native-build'/name).read_bytes()==b'' and sha(evidence/'native-build'/name)==digest
 print(json.dumps({'status':'RETAINED_FULL_RAW_MODEL_WALK_MARKERS_PASS','completeOutputs':total,'serializedGuards':guards,'nativeBuild':'Success, binary runtime not established by this packet','JS1024':'Blocked/unexecuted','timing':'No comparative inference'}))
if __name__=='__main__':main()
