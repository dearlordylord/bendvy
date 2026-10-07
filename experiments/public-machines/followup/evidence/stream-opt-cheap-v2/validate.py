#!/usr/bin/env python3
"""Validate retained complete evidence with archived models; executes no child."""
import base64,gzip,hashlib,importlib.util,json,pathlib,tarfile,tempfile
HERE=pathlib.Path(__file__).resolve().parent
sha=lambda b:hashlib.sha256(b).hexdigest()
ROOT_MEMBER='machines-stream-opt-cheap-freeze-v2'
MEMBERS={'application.js','emit-js.stderr','emit-js.stdout.gz','expected.json.gz','plan.json','receipt.json','run-js.stderr','run-js.stdout.gz'}
def main():
 inventory=json.loads((HERE/'files.json').read_text());assert set(inventory)=={'frozen-sources.json.gz','cohort.tar.gz','installed-binary-pins.json','receipt.json'}
 before={n:sha((HERE/n).read_bytes()) for n in inventory};assert before==inventory
 sources=json.loads(gzip.decompress((HERE/'frozen-sources.json.gz').read_bytes()));assert len(sources)==103
 decoded={}
 for name,entry in sources.items():
  assert set(entry)=={'sha256','base64'}
  body=base64.b64decode(entry['base64'],validate=True);assert sha(body)==entry['sha256'];decoded[name]=body
 with tarfile.open(HERE/'cohort.tar.gz','r:gz') as archive:
  members=archive.getmembers();names=[m.name for m in members];assert len(names)==len(set(names))==9
  assert set(names)=={ROOT_MEMBER,*[ROOT_MEMBER+'/'+n for n in MEMBERS]}
  assert next(m for m in members if m.name==ROOT_MEMBER).isdir()
  assert all(m.isfile() for m in members if m.name!=ROOT_MEMBER)
  captured={n:archive.extractfile(ROOT_MEMBER+'/'+n).read() for n in MEMBERS}
 receipt=json.loads(captured['receipt.json']);plan=json.loads(captured['plan.json']);assert captured['receipt.json']==(HERE/'receipt.json').read_bytes()
 assert receipt['status']=='DEVELOPMENT_FULL65537_TWO_SCHEMA_COMPLETE_MODEL_PASS'
 assert receipt['planSHA256']==sha(captured['plan.json']) and receipt['generatedSHA256']==sha(captured['application.js'])
 assert set(receipt['artifacts'])==MEMBERS-{'receipt.json'}
 assert all(sha(captured[n])==h for n,h in receipt['artifacts'].items())
 excluded=json.loads((HERE/'installed-binary-pins.json').read_text())['pins']
 assert {n:v['sha256'] for n,v in sources.items()}|excluded==plan['sources']
 assert set(sources).isdisjoint(excluded) and len(excluded)==3
 assert len(receipt['commands'])==len(plan['commands'])==2
 assert plan['commands'][1]['argv'][-1]=='65537' and plan['commands'][1]['cap']==5
 assert plan['commands'][0]['cap']==30
 assert receipt['requestedCount']==65537 and receipt['capacity']==65536 and receipt['completeRowsPerSchema']==7
 assert all(got['argv']==want['argv'] and got['cap']==want['cap'] and got['label']==want['label'] for got,want in zip(receipt['commands'],plan['commands']))
 raw=gzip.decompress(captured['run-js.stdout.gz'])
 for command in receipt['commands']:
  label=command['label'];assert command['exit']==0 and command['failure'] is None
  assert sha(gzip.decompress(captured[label+'.stdout.gz']))==command['stdoutSHA256']
  assert sha(captured[label+'.stderr'])==command['stderrSHA256']
 assert len(raw)==19367810 and len(raw.splitlines())==16
 def source(suffix):
  names=[n for n in decoded if n.endswith(suffix)];assert len(names)==1;return decoded[names[0]]
 with tempfile.TemporaryDirectory(prefix='machines-retained-validator-') as directory:
  base=pathlib.Path(directory);follow=base/'followup';(follow/'evidence/primary-ts-v1').mkdir(parents=True)
  (base/'full-model.py').write_bytes(source('/experiments/public-machines/full-model.py'))
  (follow/'overflow-model.py').write_bytes(source('/experiments/public-machines/followup/overflow-model.py'))
  (follow/'evidence/primary-ts-v1/expected.json.gz').write_bytes(source('/experiments/public-machines/followup/evidence/primary-ts-v1/expected.json.gz'))
  spec=importlib.util.spec_from_file_location('retained_overflow_model',follow/'overflow-model.py');model=importlib.util.module_from_spec(spec);spec.loader.exec_module(model)
  expected=model.expected();assert sha(json.dumps(expected,sort_keys=True).encode())==plan['expectedSHA256']
  assert json.loads(gzip.decompress(captured['expected.json.gz']))==expected
  result=model.validate(raw);assert list(result)==['A','B'] and all(len(rows)==7 for rows in result.values())
 assert {n:sha((HERE/n).read_bytes()) for n in inventory}==before
 print(json.dumps({'status':'RETAINED_COMPLETE_MODEL_VALIDATION_PASS_NO_CHILD_EXECUTION','sourceRecords':103,'archiveMembers':9,'schemas':2,'rowsPerSchema':7,'requestedCount':65537,'capacity':65536,'rawBytes':len(raw),'receiptSHA256':sha(captured['receipt.json']),'installedResolverQualified':False}))
if __name__=='__main__':main()
