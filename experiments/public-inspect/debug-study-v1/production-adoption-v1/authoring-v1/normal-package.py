"""Package already completed connected declaration evidence; no execution/probes."""
from pathlib import Path
import hashlib,io,json,tarfile
H=Path(__file__).resolve().parent
sha=lambda b:hashlib.sha256(b).hexdigest()
COHORTS=[
 ('reference','preflight/1791454914248485636','4978ee5066a5813c09ae86924dfdadeb8f99421a3b782f3532b69cba6977b579','a8245620dd681d40dc0647b9077c3c2f6aa3472aa0beaec8cd35a94bfa804754'),
 ('io','preflight/1791455746087739558','9af7bdda8c653abf080cc640292e65e95a98ff4012ab061fae825e1b95df988c','8e9d73bc7f853be56c81232c26d6de7d29009d4fd6d0761bdbcf93b4821f3c9a'),
 ('js','preflight/1791456504443000687','33317edaeb1d44694b6bb7c027fe75e1fce74ebd54d47a15d82550d3bcf7ccae','4e812fab89865451ef7b31ab54a2b05bce9be5c234b0f63fe34db648325151a2'),
 ('native','native-v1/1791457900265395915','22baa99fe2e712437f195f4bde1741dfa701f14672d79f67c8e2e8714853e80f','e5d50de39eb1eb71dbefe86c99b954700afe82ff067b09ed1110ecad95c69b38'),
 ('authority','preflight/1791456214515316866','98939e310125b66f307fac816324113c8834c8162711d6d4853e0bbac54153ae','46fc96482d5861439408b8e7cf4591bf4f4c2b14ec14a89bce48e33e65e96c75')]
records={};objects={};excluded={};cohorts={};environmentJoins={}
def add(path,digest=None):
 path=Path(path);b=path.read_bytes();actual=sha(b);assert digest is None or digest==actual
 # Installed executables and all private environments retain identities only.
 if 'private-environment.json' in str(path) or '/installs/node/' in str(path) or str(path) in ['/usr/bin/taskset','/usr/bin/python3.11','/usr/bin/python3','/home/node/.bend/bin/bend'] or str(path).startswith('/tmp/bendvy-clang19-diagnostic/'):
  excluded[str(path.resolve())]={'sha256':actual,'reason':'private environment or installed tool/resource identity; not redistributed'};return
 records[str(path.resolve())]=actual;objects[actual]=b
for label,folder,ps,rs in COHORTS:
 base=H/folder;assert sha((base/'plan.json').read_bytes())==ps and sha((base/'receipt.json').read_bytes())==rs
 p=json.loads((base/'plan.json').read_text());environmentJoins[p['environment']]={'fileSHA256':sha(Path(p['environment']).read_bytes()),'ownedCanonicalSHA256':sha(json.dumps(json.loads(Path(p['environment']).read_text()),sort_keys=True,separators=(',',':'),ensure_ascii=True).encode())};r=json.loads((base/'receipt.json').read_text());assert r['planSHA256']==ps and not r.get('guardFailures',[])
 for name,digest in p['pins'].items():add(name,digest)
 for name,digest in p.get('toolSnapshot',{}).get('pins',{}).items():
  assert sha(Path(name).read_bytes())==digest
  if records.get(name)!=digest:excluded[name]={'sha256':digest,'reason':'installed ordinary tool/resolver/resource snapshot identity; no redistributed executable/library/header bytes'}
 assert set(r['logs'])=={c['label']+'.'+stream for c in r['commands'] for stream in ['stdout','stderr']}
 for name,v in p.get('configs',{}).items():
  if v['kind']=='file':
   assert sha(Path(name).read_bytes())==v['sha256']
   if '/.references/bevy-ts/' in name or name.startswith(p['stage']+'/'):add(name,v['sha256'])
   elif records.get(name)!=v['sha256']:excluded[name]={'sha256':v['sha256'],'reason':'participating host/config identity only; no private configuration bytes redistributed'}
 for name,digest in r['logs'].items():add(base/name,digest)
 for name,digest in r.get('generated',{}).items():add(name,digest)
 stage=Path(p['stage']);assert {str(f.relative_to(stage)):sha(f.read_bytes()) for f in stage.rglob('*') if f.is_file()}==p['inventory']
 for file in stage.rglob('*'):
  if file.is_file():add(file)
 for name in ['plan.json','receipt.json','prepare-receipt.json']:
  if (base/name).exists():add(base/name)
 cohorts[label]={'planPath':str((base/'plan.json').resolve()),'planSHA256':ps,'receiptPath':str((base/'receipt.json').resolve()),'receiptSHA256':rs}
referencePlan=json.loads((H/'preflight/1791454914248485636/plan.json').read_text())
for name,digest in referencePlan['pins'].items():add(name,digest)
for name in ['AUTHORITY-CLASSIFICATION.json']:add(H/name)
O=H/'normal-evidence-v1';O.mkdir(exist_ok=True)
with tarfile.open(O/'objects.tar.gz','w:gz') as tar:
 for digest,b in sorted(objects.items()):
  member=tarfile.TarInfo(digest);member.size=len(b);member.mtime=0;tar.addfile(member,io.BytesIO(b))
(O/'index.json').write_text(json.dumps({'scope':'Actual multi-owner Description DTO2/World/threeRegistry/twoProvisioned normal plus source-authority slice; reached controls separate pending; no complete56/proof/performance/published-format claim','records':records,'excluded':excluded,'cohorts':cohorts,'environmentJoins':environmentJoins,'archiveSHA256':sha((O/'objects.tar.gz').read_bytes())},indent=2)+'\n')
print(len(records),len(objects),len(excluded))
