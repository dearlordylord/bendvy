#!/usr/bin/env python3
"""Pin task-owned shared gate outputs and compare full rejoined raw oracle."""
import argparse,gzip,hashlib,importlib.util,json,pathlib,shutil
H=pathlib.Path(__file__).resolve().parent;ROOT=H.parents[2];sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
sp=importlib.util.spec_from_file_location('R',ROOT/'experiments/s-perf/occupancy-run.py');R=importlib.util.module_from_spec(sp);sp.loader.exec_module(R)
def main():
 p=argparse.ArgumentParser();p.add_argument('--output',type=pathlib.Path,required=True);p.add_argument('--overlay',type=pathlib.Path,required=True);p.add_argument('--gate-root',type=pathlib.Path,required=True);a=p.parse_args();e=json.loads((a.output/'evidence.json').read_text());assert e['status']=='FINITE_ACTUAL_TX_CACHE_FIELDS_PASS' and len(e['cases'])==8;manifest=json.loads((a.overlay/'overlay.json').read_text());assert all(sha(a.overlay/n)==v for n,v in manifest['sources'].items());expected=(ROOT/'experiments/s-prep/fivehour-native-columns/expected.jsonl').read_text();assert hashlib.sha256(expected.encode()).hexdigest()=='86470371004f767f76a13c0103f2b83d8a70b64ecc1b2eb80535c8782e21c3c4'
 receipt={'scope':'fresh shared split-schema gate actual144 full fields/journal original-vs-held, original raw-vs-cache; no timing','runtimeClosureSHA256':manifest['cacheSpecialization']['runtimeClosureSHA256'],'overlaySha256':sha(a.overlay/'overlay.json'),'sharedEvidenceSha256':sha(a.output/'evidence.json'),'cpu':11,'limitsSeconds':{'checker':5,'runtime':5,'codegen':30,'clang':120},'subjects':{},'sharedInputsSha256AtCollection':{name:sha(a.gate_root/name) for name in ['tx-controls-run.py','tx-controls.bend','materialize-controls.py','original-raw-observer.bend']},'buildHelperSha256AtCollection':sha(a.gate_root.parents[1]/'t05/run.py'),'expectedSha256':hashlib.sha256(expected.encode()).hexdigest()}
 for mode in ['cached','raw']:
  for backend,suffix in [('Native','-native'),('JS','.js')]:
   chunks={};subjects=[]
   for schema in ['motion','health']:
    folder=a.output/mode/schema;entry=a.output/mode/'core'/('cache-tx-'+schema+'-controls.bend');artifact=folder/('cache-tx-'+schema+'-controls'+suffix);output=pathlib.Path(str(artifact)+'.jsonl');rows=output.read_text().splitlines();assert len(rows)==72;chunks[schema]=rows
    case=next(v for v in e['cases'] if (v['getter'],v['schema'],v['backend'])==(mode,schema,backend));assert sha(artifact)==case['programSHA256'] and sha(output)==case['rawSHA256'];subjects.append({'schema':schema,'compiledEntrySha256':sha(entry),'programSha256':sha(artifact),'outputSha256':sha(output),'closure':R.closure(entry)})
   rejoined=[]
   for scenario in range(9):
    for schema in ['motion','health']:rejoined+=chunks[schema][scenario*8:scenario*8+8]
   out='\n'.join(rejoined)+'\n';assert out==expected;(H/('tx-'+mode+'-'+backend+'.jsonl.gz')).write_bytes(gzip.compress(out.encode(),mtime=0));receipt['subjects'][mode+'-'+backend]={'status':'ACTUAL_FULL144_RAW_FIELDS_JOURNAL_PASS','records':144,'outputSha256':hashlib.sha256(out.encode()).hexdigest(),'slices':subjects}
 receipt['status']='FRESH_COMBINED_TX144_CACHED_ORIGINAL_RAW_PASS';(H/'tx-evidence.json').write_text(json.dumps(e,indent=2)+'\n');(H/'tx-provenance.json').write_text(json.dumps(receipt,indent=2)+'\n');print(receipt['status'])
if __name__=='__main__':main()
