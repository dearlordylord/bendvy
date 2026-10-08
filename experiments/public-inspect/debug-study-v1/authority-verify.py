"""Portable source-authority evidence verification; no tools or original paths."""
from pathlib import Path
import hashlib,json,tarfile
H=Path(__file__).resolve().parent;E=H/'authority-evidence-v1';sha=lambda b:hashlib.sha256(b).hexdigest()
i=json.loads((E/'index.json').read_text());assert sha((E/'objects.tar.gz').read_bytes())==i['archiveSHA256']
with tarfile.open(E/'objects.tar.gz') as t:
 assert len(t.getnames())==len(set(t.getnames())) and set(t.getnames())==set(i['objects'])
 objects={n:t.extractfile(n).read() for n in t.getnames()}
assert all(sha(b)==h and len(b)==i['objects'][h] for h,b in objects.items())
assert all(h in objects for h in i['files'].values())
def at(n):return objects[i['files'][n]]
def path(n):return at(i['pathKeys'][n])
p=json.loads(at('cohort/plan.json'));r=json.loads(at('cohort/receipt.json'));prep=json.loads(at('cohort/prepare-receipt.json'));c=json.loads(at('delivery/authority-v1/CLASSIFICATION.json'))
assert sha(at('cohort/plan.json'))==r['planSHA256']=='bd5c98e84a8768496634b8c13d8569c0507a81a2f934b712789d8f0dad0cc808'
assert sha(at('cohort/receipt.json'))==c['receiptSHA256']=='1bf3960630e134c16b4a5d67f946a9e6a47c8698cb5c256f52fdffbb8732f727'
assert r['status']==c['rawReceiptStatusPreserved']=='SOURCE_CONTROLS_RAW_UNCLASSIFIED_NOT_PROOF_NOT_RUNTIME_NOT_DELIVERY' and r.get('guardFailures',[])==[]
assert len(r['commands'])==6 and [x['exit'] for x in r['commands']]==[0,1,1,1,1,1]
assert [x['argv'] for x in r['commands']]==[x['argv'] for x in p['commands']]
assert all(x['seconds']==5 and x['failure'] is None for x in r['commands'])
assert prep['status']=='ORDINARY_PREPARATION_PASS_NO_BACKEND' and len(prep['probes'])==2
assert [q['argv'] for q in prep['probes']]==p['preparationProbeCommands']
for q in prep['probes']+r['ordinaryGuardProbes']:assert q['seconds']==5 and q['result']['exit']==0 and q['result']['failure'] is None
assert len(r['ordinaryGuardProbes'])==28
labels=['positive','negative-schema','negative-token','negative-write','negative-owner','negative-undeclared']
assert set(r['logs'])=={label+'.'+stream for label in labels for stream in ['stdout','stderr']}
for label in labels:
 for stream in ['stdout','stderr']:assert sha(at('cohort/'+label+'.'+stream))==r['logs'][label+'.'+stream]
assert at('cohort/positive.stdout')==b'ALL PROOFS CHECK\nUse --verdict for mathematical validity.\n' and at('cohort/positive.stderr')==b''
needles=[(b'F.Filter<A.Schema, A.Token>',b'F.Filter<B.Schema, B.Token>'),(b'A.Token',b'B.Token'),(b'Cap.ValueWrite<',b'Cap.ValueRead<'),(b'world (consumed more than once)',),(b'check.Frame<A.Schema',b'wrong~H')]
for item,words in zip(c['controls'],needles):
 label=item['label'];out=at('cohort/'+label+'.stdout');err=at('cohort/'+label+'.stderr')
 assert out==b'' and sha(out)==item['stdoutSHA256'] and sha(err)==item['stderrSHA256']
 assert err.count(b'Error:')==1 and err.count(b'Location: wrong')==1 and all(w in err for w in words)
for name,digest in p['inventory'].items():assert sha(at('cohort/stage/'+name))==digest
assert {n[len('cohort/stage/'):]:h for n,h in i['files'].items() if n.startswith('cohort/stage/')}==p['inventory']
for n,h in p['pins'].items():
 if n in i['pathKeys']:assert sha(path(n))==h
 else:assert (n in i['excluded'] and i['excluded'][n]['sha256']==h) or n+'@'+h in i['historicalUnavailable']
for n,h in p['rootJoins'].items():assert sha(path(n))==h
print('PASS portable matched positive/five intended refusals; raw-unclassified receipt preserved; no proof/runtime/full56')
