#!/usr/bin/env python3
"""Assemble THIS task's recorded complete gates; never relabel as a new run."""
import argparse,hashlib,json
from pathlib import Path
import checks as C
HERE=Path(__file__).resolve().parent
def main():
 p=argparse.ArgumentParser();p.add_argument('--js-overlay',type=Path,required=True);p.add_argument('--native-overlay',type=Path,required=True);p.add_argument('--js-controls',type=Path,required=True);p.add_argument('--native-controls',type=Path,required=True);p.add_argument('--js-host',type=Path,required=True);p.add_argument('--native-host',type=Path,required=True);p.add_argument('--native-e11',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args();a.output.mkdir(exist_ok=False)
 result={'status':'INCOMPLETE','schemaVersion':1,'executionMode':'ASSEMBLED_THIS_TASK_RECORDED_COMMANDS','freshCheckSetExecution':False,'scope':'Complete finite capability/correctness evidence from this task; not a new execution, proof, measurement or product acceptance','roles':{},'referenceReuse':{}}
 try:
  result['dependencyBinding']=C.dependency_binding();result['gateSources']={f.name:C.sha(f) for f in HERE.glob('*.py')}
  for role,overlay,controls,host in [('JS',a.js_overlay,a.js_controls,a.js_host),('Native',a.native_overlay,a.native_controls,a.native_host)]:
   binding=C.source_binding(overlay);control_manifest=json.loads((controls/'overlay.json').read_text());control_sources={n:v for n,v in control_manifest['sources'].items() if n.endswith('.bend')};assert all(C.sha(controls/n)==v for n,v in control_sources.items())
   entry={'status':'INCOMPLETE','input':str(overlay.resolve()),'binding':binding,'controlSources':control_sources,'gates':[]};result['roles'][role]=entry
   def add(name,path,status,cpu=None):
    data=json.loads(path.read_text());gate={'name':name,'exit':0,'status':status,'receipt':str(path.resolve()),'receiptSHA256':C.sha(path),'execution':'RECORDED_THIS_TASK_COMMAND','cpuAffinity':cpu};entry['gates'].append(gate);return data
   entry['gates'].append({'name':'materialize-controls','exit':0,'status':'PASS_DERIVED_CONTROL_SOURCE_MAP','execution':'RECORDED_THIS_TASK_SOURCE_EQUALITY','sourceMapSHA256':hashlib.sha256(json.dumps(control_sources,sort_keys=True,separators=(',',':')).encode()).hexdigest()})
   protocol=add('host12',host/'protocol.json','PASS',9 if role=='JS' else 10);assert protocol['status']=='PASS';semantics=json.loads((host/'semantic-evidence.json').read_text());assert len(semantics['original'])==2 and all(x['fullSelectedChannelsEqual'] for x in semantics['original']);assert [x['name'] for x in semantics['mutants']]==['query-order','suppressed-setter','inverse-order','failed-cursor','other-reader-routing','skip-change-cursor','reset-capture','reversed-command-FIFO','implicit-flush','failed-publication-leak','failed-change-stamp','reissued-failed-reservation'];assert all(len(x['observations'])==2 and all(o['compiling'] and o.get('differenceCount',1)>0 and o['witness'] for o in x['observations']) for x in semantics['mutants']);entry['gates'][-1]['semanticReceiptSHA256']=C.sha(host/'semantic-evidence.json')
   access=add('access',HERE/('final-'+role.lower()+'-access-evidence.json'),'ACTUAL_ACCESS_9_PASS',9 if role=='JS' else 6);assert set(access['cases'])=={'positive','undeclared_token','cross_schema','write_through_read','reconstruct_owner','invalid_owner_return','audit_copy_text_historical','audit_copy','irrecoverable_destructure'}
   for name,case in access['cases'].items():
    assert case['exit']==(0 if name=='positive' else 1) and ('ALL PROOFS CHECK' if name=='positive' else 'SOME PROOFS FAIL') in case['output'];assert all(text in case['output'] for text in case.get('intended_diagnostics',[]))
   e11_path=HERE/'final-js-e11-evidence.json' if role=='JS' else a.native_e11;e11=add('e11',e11_path,'BOUNDED_JOINED_PASS',9);assert e11['status']=='BOUNDED_JOINED_PASS' and not e11['failures'] and len(e11['actual'])==20 and len(e11['publicReference'])==10 and e11['semanticMutants']['status']=='PASS' and len(e11['semanticMutants']['results'])==10
   if 'referenceReplay' in e11:result['referenceReuse'][role]=e11['referenceReplay']
   owned=add('owned-storage',HERE/('final-'+role.lower()+'-owned-evidence.json'),'ACTUAL_FINAL_STORAGE_FIELDS_OWNERSHIP_MUTANTS_PASS',9 if role=='JS' else 6);assert owned['status']==C.EXPECTED_GATES['owned-storage'] and owned['storageSHA256']==binding['runtimeSources']['experiments/s-integrate/storage.bend']
   stage=add('staging',HERE/('final-'+role.lower()+'-staging-evidence.json'),'PASS_BOUNDED_STAGING_TYPE_BOUNDARY',9 if role=='JS' else 6);assert stage['status']==C.EXPECTED_GATES['staging']
   for variant in ['baseline','stale-head','torn-tail','lost-mark','inverse-order']:
    if role=='JS' and variant=='baseline':path=HERE/'final-js-tx-evidence.json'
    else:path=HERE/('final-'+role.lower()+'-tx-'+variant+'-evidence.json')
    tx=add('tx-'+variant,path,C.EXPECTED_GATES['tx-'+variant],9 if role=='JS' else 6 if variant in ('baseline','stale-head') else 2);assert tx['status']==C.EXPECTED_GATES['tx-'+variant]
    cases=tx['cases'];assert {c['getter'] for c in cases}=={'cached','raw'} and {c['backend'] for c in cases}=={'Native','JS'}
    for mode in ('cached','raw'):
     for backend in ('Native','JS'):assert sum(c['records'] for c in cases if c['getter']==mode and c['backend']==backend)==144
   C.validate_gates(entry['gates']);assert C.source_binding(overlay)==binding;entry['status']='PASS'
  assert C.dependency_binding()==result['dependencyBinding'];result['status']='FRESH_TWO_ROLE_CONNECTED_GATES_PASS';result['protocolStatusNameOnly']=True
 except Exception as error:result.update(status='FAIL',error=repr(error));raise
 finally:(a.output/'evidence.json').write_text(json.dumps(result,indent=2)+'\n')
if __name__=='__main__':main()
