"""Portable no-child exact source/refusal provenance verifier."""
import pathlib,json,hashlib,tarfile
HERE=pathlib.Path(__file__).resolve().parent
PLANS=['5c52b1638c63bb3c6594aebac02d9577a14cb74f7bb32b2b555d0e80ca1620a6','8b209996a8d97f8f5dfb280c251cd02644b567256e30b7ea75936579e20594e4','1394c377af7a384eb4b8c29a6a491872e24f3c2a5122283edc12cf5591609a5a']
def sha(b):return hashlib.sha256(b).hexdigest()
def verify():
 i=json.loads((HERE/'index.json').read_text());assert sha((HERE/'objects.tar.gz').read_bytes())==i['archiveSHA256'];objects={}
 with tarfile.open(HERE/'objects.tar.gz','r:gz') as t:
  ms=t.getmembers();expected={r['object'] for r in i['records'].values()};assert len(ms)==len(expected) and {m.name for m in ms}==expected
  for m in ms:
   assert m.isfile();b=t.extractfile(m).read();assert sha(b)==m.name.split('/')[1];objects[m.name]=b
 for n,r in i['records'].items():assert sha(objects[r['object']])==r['sha256'] and len(objects[r['object']])==r['bytes']
 def data(n):return objects[i['records'][str(n)]['object']]
 def js(n):return json.loads(data(n))
 positive=None;negative={}
 for idx,origin in enumerate(i['origins']):
  o=pathlib.Path(origin);p=js(o/'plan.json');r=js(o/'receipt.json');assert sha(data(o/'plan.json'))==PLANS[idx] and r['planSHA256']==PLANS[idx] and r.get('guardFailures',[])==[]
  pins=p.get('files',p.get('inputs',{}))
  for n,d in pins.items():
   if n in i['hashOnlyExclusions']:assert i['hashOnlyExclusions'][n]['sha256']==d and i['hashOnlyExclusions'][n]['reason'] in ['private environment','installed executable binary']
   else:assert sha(data(n))==d
  raws={str(o/n) for n in r['logs']};assert {n for n in i['records'] if pathlib.Path(n).parent==o and n.endswith('.raw')}==raws
  for n,d in r['logs'].items():assert sha(data(o/n))==d
  if idx==0:
   assert r['status']=='SOURCE_FEASIBILITY_PASS' and r['exit']==0 and r.get('failure') is None
   assert sha(data(o/'stdout.raw'))=='931f1e664a679af1355a9ca547ac1daef9f7b14137bc7cc21b110b0cc504b5b1' and data(o/'stderr.raw')==b'bend 2.0.36 is available: run bend update\n'
   assert p['command']==['taskset','-c','5',str(o.parents[1]/'scripts/bend-check'),str(pathlib.Path(p['target']))] and pathlib.Path(p['target']).name=='positive.bend'
   for n,d in p['sourceArchive'].items():assert sha(data(o/'source'/n))==d
   positive=(o,p,r)
  else:
   assert r['status']=='COMPLETE_RAW_UNCLASSIFIED_DIAGNOSTIC_COLLECTION' and len(r['commands'])==len(p['commands'])==3
   assert p['positivePlanSHA256']==PLANS[0] and data(p['positivePlan'])==data(positive[0]/'plan.json') and data(p['positiveReceipt'])==data(positive[0]/'receipt.json')
   for c,actual in zip(p['commands'],r['commands']):
    expected_target=o.parents[2]/'experiments/public-inspect/promotion-stage/component-query-v1/authority-controls-v1'/(c['label']+'.bend')
    assert c['argv']==['/usr/bin/taskset','-c','5',str(o.parents[2]/'scripts/bend-check'),str(expected_target)]
    assert c['label']==actual['label'] and actual['exit']==1 and actual['failure'] is None and actual['classification']=='UNCLASSIFIED'
    assert data(o/(c['label']+'.stdout.raw'))==b''
    stderr=data(o/(c['label']+'.stderr.raw'));assert stderr.count(b'Error:')==1 and stderr.count(b'Location:')==1
    assert b"D.T.execute_result(c['argv'],5," in data(next(n for n in pins if n.endswith('/authority-controls-v1/collect.py')))
    negative[c['label']]={'plan':PLANS[idx],'stderr':sha(stderr),'source':sha(data(c['argv'][-1]))}
 classification=js(i['classification']);assert len(classification['records'])==6 and {c['target'] for c in classification['records']}==set(negative)
 for c in classification['records']:
  n=negative[c['target']];assert c['status']=='INDEPENDENTLY_CLASSIFIED_INTENDED_REFUSAL' and c['originalCommandClassification']=='UNCLASSIFIED'
  assert c['planSHA256']==n['plan'] and c['fullStderrSHA256']==n['stderr'] and c['sourceSHA256']==n['source']
 result={'status':'FINITE_STATIC_SOURCE_CLASSIFICATIONS_VERIFIED','records':len(i['records']),'objects':len(objects),'refusals':6,'scope':i['scope']};return result
if __name__=='__main__':print(json.dumps(verify(),indent=2))
