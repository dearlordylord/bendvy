"""Portable checks of sealed model pins, canonical transports and scalar fixtures."""
from pathlib import Path
import gzip,json,hashlib
from common_model import compact,cells,fold
P=Path(__file__).parent;sha=lambda b:hashlib.sha256(b).hexdigest()
b=json.loads((P/'SOURCE-BASIS.json').read_text());r=json.loads((P/'PILOT-ORACLE-BASIS.json').read_text())
assert sha((P/'SOURCE-BASIS.json').read_bytes())==r['sourceBasisSHA256']
for n,h in r['modelPins'].items():assert sha((P/n).read_bytes())==h
for pin in b['originalSourcePins']:
 n=pin['copy'];relative=n.removeprefix('source/');h=b['parameterizedSourcePins'].get(relative,pin['sha256']);assert sha((P/n).read_bytes())==h
for pin in b['consumerSourcePins']+[b['tsReference']]:assert sha((P/pin['copy']).read_bytes())==pin['sha256']
q=b['qualifiedCanonical'];raw=gzip.decompress((P/q['path']).read_bytes());assert(len(raw),sha(raw))==(q['bytes'],q['sha256'])
worlds=json.loads(gzip.decompress((P/'observer-fixtures.json.gz').read_bytes()))
for f,s in zip(worlds,r['worlds']):
 assert len(f['common'])==578 and len(f['actors'])==128
 assert cells(f['common'])==f['tuple'] and fold(f['tuple'])==f['fold']==s['fold']
 assert len([x for x in f['common']if x['kind']=='Boundary'])==192
 assert len([x for x in f['common']if x['kind']=='Stage'])==384
 for role in ['bend','ts']:
  assert len(f['foreign'][role])==192;assert cells(f['foreign'][role])==f['foreignTuples'][role];assert fold(f['foreignTuples'][role])==f['foreignFolds'][role]
 raw=gzip.decompress((P/f"canonical-ns{f['namespace']}-{f['foreignNamespace']}.stdout.gz").read_bytes());assert(len(raw),sha(raw))==(s['canonical']['bytes'],s['canonical']['sha256'])
for role,out in r['oracles'].items():
 path=P/f'{role}-expected.stdout.gz';packed=path.read_bytes();raw=gzip.decompress(packed)
 assert(len(raw),sha(raw),len(packed),sha(packed))==(out['bytes'],out['sha256'],out['gzipBytes'],out['gzipSHA256'])
 assert raw==(P/f'{role}-expected.stdout').read_bytes()
 for label in [b'WARMUP',b'SAMPLE']:
  segment=raw.split(label+b'\nFORCE:',1)[1];assert segment.index(b'\nFOREIGN-FORCE:')<segment.index(b'\nTUPLE:')<segment.index(b'\nFOREIGN-TUPLE:')<segment.index(b'\nACTORS:')
assert worlds[0]['tuple']==worlds[1]['tuple']
assert worlds[0]['foreignTuples']['bend']!=worlds[1]['foreignTuples']['bend']
assert worlds[0]['foreignTuples']['ts']==worlds[1]['foreignTuples']['ts']
print('PASS: original LC2, two full role streams, 578 shared + 192 own-role foreign records/world; model/source pins; no subject execution')
