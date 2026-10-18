from pathlib import Path
import json,zipfile,hashlib,gzip,sys
L=Path(sys.argv[1]);sha=lambda b:hashlib.sha256(b).hexdigest();m=json.loads((L/'MANIFEST.json').read_text());assert sha((L/'EVIDENCE.zip').read_bytes())==m['zipSHA256'];files={}
with zipfile.ZipFile(L/'EVIDENCE.zip')as z:
 assert len(z.namelist())==len(m['members'])
 for r in m['members']:
  b=z.read(r['member']);assert(len(b),sha(b))==(r['bytes'],r['sha256']);files[r['origin']]=b
def one(suffix):
 a=[b for n,b in files.items()if n.endswith(suffix)];assert len(a)==1,suffix;return a[0]
a=json.loads(one('/ANALYSIS.json'));ir=one('/'+Path(a['ir']['path']).name);assert sha(ir)==a['ir']['sha256'];s=ir.decode();phases={};d=json.JSONDecoder()
for x in a['ir']['phaseIndex']:
 chunk=s[x['startCharacter']:x['endCharacterExclusive']];assert sha(chunk.encode())==x['recordSHA256'];v,end=d.raw_decode(chunk);assert end==len(chunk);phases[v['name']]=v
assert len(a['ir']['phaseIndex'])==56
b={n['id']:n for n in phases['V8.TFTypedLowering']['data']['nodes']};p={n['id']:n for n in phases['V8.TFEscapeAnalysis']['data']['nodes']};src=files[a['ir']['originalArtifact']].decode()
for x in a['ir']['allocationProof']:
 n=x['node'];assert b[n]['live']==x['beforeLive']and p[n]['live']==x['afterEscapeAnalysisLive']and p[n]['sourcePosition']==x['sourcePosition'];offset=x['sourcePosition']['scriptOffset'];assert src.splitlines()[src[:offset].count('\n')]==x['sourceLineText']
assert[p[n]['live']for n in [1152,1174,1238,1210]]==[False,False,True,True]
for role in ['baseline','candidate']:
 assert one('/'+role+'.stderr')==b'';wire=one('/'+role+'.stdout');gold=gzip.decompress(one('/regression73-20261018-allocator-fields04/pair-0-'+role+'-JS.stdout.gz'));assert wire==gold and len(wire.splitlines())==10
raw=one('/original02-ir.stdout');wire=b''.join(l+b'\n'for l in raw.splitlines()if l.startswith(b'{"format":1,"application":"Workshop",'));assert wire==gzip.decompress(one('/regression73-20261018-pinned02/pair-0-candidate-JS.stdout.gz'));lines=raw.splitlines();begin=next(i for i,l in enumerate(lines)if l.startswith(b'Begin compiling method '));assert sum(l.startswith(b'{"format":1,"application":"Workshop",')for l in lines[:begin])==8
print(json.dumps({'status':'PORTABLE_PASS','members':len(files),'completePhaseRecords':56,'intermediateWorldAndAllocatorDeadAfterEscape':True,'requiredReturnedObjectsLive':True,'outputsBeforeCompilation':8,'fullDiagnosticStreams':3,'performanceQualification':False}))
