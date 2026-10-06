#!/usr/bin/env python3
"""Independent fresh output reread, original protected oracles and numeric value pins."""
from pathlib import Path
import json,hashlib,importlib.util,sys,argparse
p=argparse.ArgumentParser();p.add_argument('--input',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args();R=Path('/workspace/formal-proofs/bendvy');sys.path.insert(0,str(R/'experiments/s-prep/fivehour-connected-gates'))
def load(n,p):
 s=importlib.util.spec_from_file_location(n,p);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
I=load('independent',R/'experiments/s-prep/owned-write-query-integration/controls-run.py');S=load('suppression',R/'experiments/s-prep/fivehour-connected-gates/suppressed-owner.py');e=json.loads((a.input/'evidence.json').read_text());assert e['status']=='FRESH_ACTUAL_PACKED_PAIRED_TX_AND_SUPPRESSED_576_PER_BACKEND_PASS';r={'status':'INCOMPLETE','inputReceiptSHA256':hashlib.sha256((a.input/'evidence.json').read_bytes()).hexdigest(),'scope':'Fresh decoded source/artifact/output hashes + unchanged protected independent/suppressed oracles and exact numeric callback values','programs':[]};sets={}
for rec in e['programs']:
 core=Path(rec['sourceRoot'])
 for n,h in rec['source29Pins'].items():assert hashlib.sha256((core/Path(n).name).read_bytes()).hexdigest()==h
 for n,h in rec['extraPins'].items():assert hashlib.sha256((core/n).read_bytes()).hexdigest()==h
 folder=core.parent
 for n,h in rec['generatedPins'].items():assert hashlib.sha256((folder/n).read_bytes()).hexdigest()==h
 for backend in ['js','native']:
  out=a.input/(rec['label']+'-'+backend+'-run.stdout');records=[json.loads(x) for x in out.read_text().splitlines()];assert len(records)==72;sets[(rec['label'],backend)]=records;r['programs'].append({'label':rec['label'],'backend':backend,'outputSHA256':hashlib.sha256(out.read_bytes()).hexdigest(),'records':72})
for backend in ['js','native']:
 baseline=None
 for suppressed in [False,True]:
  combined_getters=[]
  for getter in ['cached','raw']:
   combined=[]
   for scenario in range(9):
    for lane in ['motion','health']:combined.extend(sets[(('suppressed-' if suppressed else '')+getter+'-'+lane,backend)][scenario*8:scenario*8+8])
   if suppressed:assert combined==S.expected_noop(baseline) and combined!=baseline
   else:
    I.independent(combined);assert not I.differences(combined)
    for block in range(36):assert combined[block*4]['value']==(46 if block//4==0 else 3606 if block//4==8 else 4294967295)
    baseline=combined
   combined_getters.append(combined)
  assert combined_getters[0]==combined_getters[1]
assert all(sets[(rec['label'],'js')]==sets[(rec['label'],'native')] for rec in e['programs']);r.update(status='DECODED_SOURCE_ARTIFACTS_AND_PROTECTED_1152_RECORDS_PASS',recordsPerBackend=576,actualSubjects=8,normalCallbackNumericValuePins=True);a.output.write_text(json.dumps(r,indent=2)+'\n')
