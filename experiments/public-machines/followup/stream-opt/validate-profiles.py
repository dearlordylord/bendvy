#!/usr/bin/env python3
"""Validate retained matched diagnostics; no child, timing or acceptance verdict."""
import base64,collections,gzip,hashlib,json,pathlib,tarfile
HERE=pathlib.Path(__file__).resolve().parent;EVIDENCE=HERE.parent/'evidence';sha=lambda b:hashlib.sha256(b).hexdigest()
def validate(folder,archive_name,expected_receipt,source_count,expected_total):
 inventory=json.loads((folder/'files.json').read_text());assert set(inventory)=={'frozen-sources.json.gz',archive_name,'receipt.json'}
 assert all(sha((folder/n).read_bytes())==h for n,h in inventory.items());sources=json.loads(gzip.decompress((folder/'frozen-sources.json.gz').read_bytes()));assert len(sources)==source_count
 for name,record in sources.items():
  body=base64.b64decode(record['base64'],validate=True);assert sha(body)==record['sha256'];assert not body.startswith(b'\x7fELF');assert not name.endswith('environment.private.json')
 with tarfile.open(folder/archive_name,'r:gz') as archive:
  members=archive.getmembers();names=[m.name for m in members];assert len(names)==len(set(names));roots={n.split('/')[0] for n in names};assert len(roots)==1;root=next(iter(roots));assert all(m.name==root and m.isdir() or m.isfile() and m.name.startswith(root+'/') and '..' not in pathlib.PurePosixPath(m.name).parts for m in members)
  data={m.name[len(root)+1:]:archive.extractfile(m).read() for m in members if m.isfile()}
 assert not any(n.endswith('environment.private.json') for n in data)
 receipt=json.loads(data['receipt.json']);plan=json.loads(data['plan.json']);assert data['receipt.json']==(folder/'receipt.json').read_bytes();assert sha(data['receipt.json'])==expected_receipt
 assert receipt['planSHA256']==sha(data['plan.json']);assert {n:record['sha256'] for n,record in sources.items()}==plan['sources']
 assert set(data)==set(receipt['artifacts'])|{'receipt.json'} and all(sha(data[n])==h for n,h in receipt['artifacts'].items())
 for name,record in plan['stagePlan'].items():assert sha(data[name])==record['sha256']
 for command in receipt['commands']:
  label=command['label'];assert sha(gzip.decompress(data[label+'.stdout.gz']))==command['stdoutSHA256'];assert sha(data[label+'.stderr'])==command['stderrSHA256'];assert command['failure'] is None
 profile_subject=next(c for c in receipt['commands'] if 'instrumented.js' in ' '.join(c['argv']));assert profile_subject['exit']==75 and profile_subject['cap']==5 and profile_subject['argv'][-1]=='65537';assert gzip.decompress(data[profile_subject['label']+'.stdout.gz'])==b''
 progress=json.loads(data['progress.json']);assert progress['outcome']=='INCOMPLETE_INSTRUMENTED_PREFIX';assert progress['progress']=={'1260':{'requested':65537,'completed':9848,'remaining':55689}} and progress['samplingInterval']==32768
 heap=json.loads(data['allocation.heapprofile']);totals=collections.Counter()
 def walk(node):
  assert isinstance(node['selfSize'],int) and node['selfSize']>=0;totals[node['callFrame']['functionName']]+=node['selfSize']
  for child in node.get('children',[]):walk(child)
 walk(heap['head']);assert sum(totals.values())==expected_total
 cpu=json.loads(data['cpu.cpuprofile']);assert all(sample in {n['id'] for n in cpu['nodes']} for sample in cpu['samples'])
 return {'receiptSHA256':expected_receipt,'sourceRecords':source_count,'headSelfSizeEstimate':expected_total,'cpuSamples':len(cpu['samples']),'largest':totals.most_common(4),'progress':progress['progress']}
def main():
 before=validate(EVIDENCE/'allocation-v1','diagnostic.tar.gz','4657050dafd3b3ce7ab2fd2606060ab599ee7a67accce42994bbcdd24427ec6b',237,4768816368)
 after=validate(EVIDENCE/'stream-opt-matched-profile-v1','cohort.tar.gz','0807e63e4fdde807ddd26049cca9748f8f59b647d3a02f8b86f5cf3c0105a42a',343,119366440)
 print(json.dumps({'status':'RETAINED_MATCHED_DIAGNOSTICS_VALIDATED_NO_CHILD_EXECUTION','before':before,'after':after,'scope':'Sampling estimates only; no speed/RSS/Native/issue acceptance'}))
if __name__=='__main__':main()
