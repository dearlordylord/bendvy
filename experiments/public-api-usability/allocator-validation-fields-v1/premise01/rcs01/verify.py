from pathlib import Path
import json,zipfile,hashlib,gzip,sys
L=Path(sys.argv[1]);sha=lambda b:hashlib.sha256(b).hexdigest();m=json.loads((L/'MANIFEST.json').read_text());assert sha((L/'EVIDENCE.zip').read_bytes())==m['zipSHA256'];files={}
with zipfile.ZipFile(L/'EVIDENCE.zip')as z:
 assert len(z.namelist())==len(m['members'])
 for r in m['members']:
  b=z.read(r['member']);assert(len(b),sha(b))==(r['bytes'],r['sha256']);files[r['origin']]=b
def one(suffix):
 a=[b for n,b in files.items()if n.endswith(suffix)];assert len(a)==1,suffix;return a[0]
assert b'--runtime-call-stats'in one('/v8-options.stdout')and b'--rcs-cpu-time'in one('/v8-options.stdout');receipt=json.loads(one('/RECEIPT.json'));assert len(receipt['rows'])==2
for r in receipt['rows']:
 role=r['role'];assert r['exit']==0 and r['capSeconds']==15 and r['rawStderrBytes']==0;wire=one('/'+role+'.stdout');assert wire==one('/'+role+'.wire.stdout')==gzip.decompress(files[r['gold']])and len(wire.splitlines())==10;assert one('/'+role+'.stderr')==b''and one('/'+role+'.table.stdout')==b'\n';assert sha(files[r['artifact']])==r['artifactSHA256'];assert files[r['artifact']]==one('/prior-'+role+'.js')
print(json.dumps({'status':'PORTABLE_PASS','members':len(files),'full10AppStreams':2,'rcsTableEmitted':False,'priorAndPinned02ArtifactsByteIdenticalBothRoles':True,'performanceQualification':False,'furtherProfileCampaign':False}))
