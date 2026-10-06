#!/usr/bin/env python3
"""Verify exact source staging and concatenated observations, independent of sliced runner."""
import pathlib,json,hashlib,argparse,importlib.util,sys
p=argparse.ArgumentParser();p.add_argument('--sliced',type=pathlib.Path,required=True);p.add_argument('--cached',type=pathlib.Path,required=True);a=p.parse_args();ROOT=pathlib.Path('/workspace/formal-proofs/bendvy');path=ROOT/'experiments/s-prep/fivehour-connected-gates/static-world-run.py';sys.path.insert(0,str(path.parent));s=importlib.util.spec_from_file_location('expected',path);E=importlib.util.module_from_spec(s);s.loader.exec_module(E);sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();r={'status':'INCOMPLETE','expectedSourceSHA256':sha(path),'cases':[]}
for schema in ('motion','health'):
 full=(a.sliced/('raw-'+schema)/'core/retained-controls.bend').read_text();want=[]
 for foreign in (True,False):
  for ns in (1,2):
   rec=E.expected(schema,ns,foreign)
   if not foreign:rec['value']=1;rec['world']['rows'][0]['main']['coordinates' if schema=='motion' else 'levels']['a']=30;rec['world']['ledger']['totals']['a']=200
   want.extend([{'command':'MissingEntity'},rec])
 for branch,removed in [('foreign','False'),('local','True')]:
  actual=(a.sliced/('raw-'+schema)/branch/'core/retained-controls.bend').read_text();assert actual==full.replace('    '+schema+'_start('+removed+'{})\n',''), 'Partition altered authored reachable definitions'
 for backend in ('retained-controls-native','retained-controls.js'):
  files=[a.sliced/('raw-'+schema)/branch/(backend+'.jsonl') for branch in ('foreign','local')];records=[json.loads(line) for f in files for line in f.read_text().splitlines()];cached=a.cached/('cached-'+schema)/(backend+'.jsonl');cachedrecords=[json.loads(x) for x in cached.read_text().splitlines()];assert records==want==cachedrecords
  r['cases'].append({'schema':schema,'backend':backend,'records':len(records),'partSHA256':[sha(f) for f in files],'cachedSHA256':sha(cached),'status':'EXACT_SOURCE_AND_CONCATENATED_FULL_FIELDS_PASS'})
r['status']='PASS';(a.sliced/'concatenation.json').write_text(json.dumps(r,indent=2)+'\n')
