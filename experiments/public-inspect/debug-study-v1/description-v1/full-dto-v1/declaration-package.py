"""Package already completed connected declaration evidence; no execution/probes."""
from pathlib import Path
import hashlib,io,json,tarfile
H=Path(__file__).resolve().parent
sha=lambda b:hashlib.sha256(b).hexdigest()
COHORTS=[
 ('io','preflight/1791448589811718074','d2036f262c4de1462729b41320a929dc0c1e21916daf9f4896179150223fef71','36fa439a795b31b46810ad7f0ffa518d219450a43ae89d586b797dc87bc6d9b5'),
 ('js','preflight/1791449185489792748','4e9987d1d36ec92de0f84b8737eb4c90217bfcb0bb9b0bf45297394e0c968be2','4f653e876a0940c85aaf12a6c590bbcfaa1c6627ac32a6faf65a932a598cb4dc'),
 ('native','native-v1/1791449863737556923','27ab529d6e5861a4ad3dc609406912bb6e062ddc7014bc86ff8caf0b66431b27','ba68e6569547be823a6ed0df4659cdac9d22fc419a181d5d9f84c2e5582f8b99'),
 ('authority-original','preflight/1791449573255487719','64256e4e061dee05ee22a6cbb8aee0d9084e7dd835908e21edcf03f3775cfdbc','e4149ea5d8f07e8978a77f943c4d9d2f5ed86afe9da7b7e7afb306a03e857376'),
 ('authority-repair','preflight/1791449997015261084','8f3de82ded3e662d840226c94aba8058c21ba799b901882318919b0f8fe62686','f1c89a715ffd184fc1b285b9d1fbc9f6b8ba5b2a8aae192e66e8774506cb6fee'),
 ('mutant-source','preflight/1791449754460089371','c342cbfd574a2ec63491ab6a01ee9c5a04b6a52ed0b9872f1fd7b0dfcff29ea9','e875ec6501fbc503cf06fe3db4b9b1ee352c841e0a742e12a9187b4943e756a9')]
COHORTS.append(('mutant-js','preflight/1791450200608763092','12c1bab8b9bd323f6131bf7fab0469b9e8da4785b9dfb7065ce45e7cdac928c0','c1193f91b0b1bc2b9474d0913a1baf94d87975515c2811421bacb7ab1646816c'))
COHORTS.append(('mutant-native','native-v1/1791450594548196489','c5b55a31e5c42c4ddb17e36724353427a42e4bc54f4ff1a3e566a7945f3e0594','e85b77fa5dee40f1b531a44147c0d5358743d82320a34e5dba095ff4379d8fba'))
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
referencePlan=json.loads((H/'preflight/1791445919387571114/plan.json').read_text())
for name,digest in referencePlan['pins'].items():add(name,digest)
for name in ['AUTHORITY-V2-CLASSIFICATION.json','AUTHORITY-V3-CLASSIFICATION.json']:add(H/name)
O=H/'declaration-evidence-v1';O.mkdir(exist_ok=True)
with tarfile.open(O/'objects.tar.gz','w:gz') as tar:
 for digest,b in sorted(objects.items()):
  member=tarfile.TarInfo(digest);member.size=len(b);member.mtime=0;tar.addfile(member,io.BytesIO(b))
(O/'index.json').write_text(json.dumps({'scope':'Actual connected declaration full DTO2/owners/requirements development slice; no complete56/proof/performance/published-format claim','records':records,'excluded':excluded,'cohorts':cohorts,'environmentJoins':environmentJoins,'archiveSHA256':sha((O/'objects.tar.gz').read_bytes())},indent=2)+'\n')
print(len(records),len(objects),len(excluded))
