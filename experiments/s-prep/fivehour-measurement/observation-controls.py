#!/usr/bin/env python3
"""Raw observation integrity controls against retained passing construction."""
import argparse,json,subprocess,tempfile
from pathlib import Path
H=Path(__file__).resolve().parent
p=argparse.ArgumentParser();p.add_argument('--construction',type=Path,required=True);p.add_argument('--evidence',type=Path,required=True);a=p.parse_args();r={'scope':'No benchmarks or qualification; exact raw-field/census corruption controls','controls':[]}
source=a.construction/'Health/JS.txt';reference=a.construction/'Health/reference.json'
with tempfile.TemporaryDirectory(prefix='fivehour-method-controls-') as tmp:
 tmp=Path(tmp);lines=source.read_text().splitlines();worlds=[i for i,x in enumerate(lines) if not x.startswith('BATCH-MILLISECONDS:')];assert len(worlds)==17
 for name in ['lost-world','drop-cell','tampered-reference','wrong-output-batch']:
  bend=list(lines);ts=json.load(open(reference));batch=16
  if name=='lost-world':bend.pop(worlds[-1])
  elif name=='drop-cell':
   x=json.loads(bend[worlds[-1]]);schemafield='levels';x['world']['rows'][0]['main'][schemafield]['d']=0;bend[worlds[-1]]=json.dumps(x)
  elif name=='tampered-reference':ts['samples'][0]['final']['ledger']['totals'][3]=0
  else:batch=15
  out=tmp/(name+'.txt');ref=tmp/(name+'.json');out.write_text('\n'.join(bend)+'\n');ref.write_text(json.dumps(ts));receipt=tmp/(name+'-receipt.json')
  c=subprocess.run(['python3',H/'semantic-check.py','--bend-output',out,'--ts-output',ref,'--schema','Health','--batch',str(batch),'--evidence',receipt],capture_output=True,text=True,timeout=5)
  assert c.returncode!=0 and not receipt.exists();r['controls'].append({'name':name,'status':'INTENDED_FULL_FIELD_OR_RECORD_COUNT_REJECTION','exitCode':c.returncode,'diagnostic':c.stderr[-1200:]})
 r['status']='OBSERVATION_INTEGRITY_NEGATIVES_PASS'
with a.evidence.open('x') as f:f.write(json.dumps(r,indent=2)+'\n')
print(r['status'])
