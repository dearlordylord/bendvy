"""Reconstruct the exact qualified public source stage, without executing tools."""
from pathlib import Path
import argparse,hashlib,io,json,shutil,tarfile
HERE=Path(__file__).resolve().parent
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
parser=argparse.ArgumentParser();parser.add_argument('--root',required=True);parser.add_argument('--out',required=True);args=parser.parse_args()
root=Path(args.root).resolve();out=Path(args.out).resolve();assert not out.exists()
proposalPath=HERE/'SOURCE-PROPOSAL.json';assert sha(proposalPath)=='0d5828b5fe642b5e037b724fdfee0c3d2abf4ce9b090e024c6aa97510497d27e'
proposal=json.loads(proposalPath.read_text());indexPath=HERE/'normal-evidence-v1/index.json';index=json.loads(indexPath.read_text());archivePath=HERE/'normal-evidence-v1/objects.tar.gz';assert sha(archivePath)==index['archiveSHA256']
objects={}
with tarfile.open(fileobj=io.BytesIO(archivePath.read_bytes()),mode='r:gz') as archive:
 for member in archive.getmembers():
  assert member.isfile() and '/' not in member.name and len(member.name)==64 and member.name not in objects
  data=archive.extractfile(member).read();assert hashlib.sha256(data).hexdigest()==member.name;objects[member.name]=data
assert set(objects)==set(index['records'].values())
cohort=index['cohorts']['authority'];assert cohort['planSHA256']=='dead905e4d29cf93ca34267bf7ecc2a08f5e9ab2dfe1be8d8e9b2ff9e9c40088'
planBytes=objects[index['records'][cohort['planPath']]];assert hashlib.sha256(planBytes).hexdigest()==cohort['planSHA256'];plan=json.loads(planBytes)
sources={}
for name,digest in proposal['productionFiles'].items():sources['candidate/src/ecs/'+name]=(HERE/'candidate/src/ecs'/name,digest)
for name,digest in proposal['copiedCurrentCoreFiles'].items():
 assert proposal['rootJoins']['/workspace/formal-proofs/bendvy/src/ecs/'+name]==digest
 sources['candidate/src/ecs/'+name]=(root/'src/ecs'/name,digest)
for name,digest in proposal['clientFiles'].items():sources['client/'+name]=(HERE/'client'/name,digest)
for name,digest in plan['inventory'].items():
 if name.startswith('authority-v1/'):sources[name]=(HERE/name,digest)
assert {n:d for n,(_,d) in sources.items()}==plan['inventory'] and len(sources)==49
before={str(source):sha(source) for source,_ in sources.values()};before[str(proposalPath)]=sha(proposalPath);before[str(indexPath)]=sha(indexPath);before[str(archivePath)]=sha(archivePath)
for name,(source,digest) in sources.items():
 assert before[str(source)]==digest and index['records'][plan['stage']+'/'+name]==digest
out.mkdir(parents=True)
for name,(source,digest) in sources.items():
 destination=out/name;destination.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(source,destination);assert sha(destination)==digest
assert {str(f.relative_to(out)):sha(f) for f in out.rglob('*') if f.is_file()}==plan['inventory']
assert all(sha(path)==digest for path,digest in before.items())
print('PASS reconstructed exact49 qualified public source files; no tools or children executed')
