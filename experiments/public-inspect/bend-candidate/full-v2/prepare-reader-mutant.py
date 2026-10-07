"""Prepare one compiling reader-consumption defect with a full predicted oracle."""
from pathlib import Path
import contextlib,hashlib,importlib.util,io,json,types
HERE=Path(__file__).resolve().parent
B=types.ModuleType('inspect_backend');B.__file__=str(HERE/'backends.py');exec((HERE/'backends.py').read_text().split('\np=argparse.ArgumentParser()')[0],B.__dict__)
stream=io.StringIO()
with contextlib.redirect_stdout(stream):B.prepare()
planpath=Path(stream.getvalue().splitlines()[0]);out=planpath.parent
original=out/'original-unexecuted-plan.json';planpath.rename(original);p=json.loads(original.read_text());stage=Path(p['stage']);joint=stage/'experiments/public-inspect/bend-candidate/joint.bend';before=joint.read_text()
needle='Active{oldCursor,registered,oldEventCursor,eventRegistered},Fail{error}'
replacement='Active{oldCursor,registered,(oldEventCursor + 1n : Nat),eventRegistered},Fail{error}'
assert before.count(needle)==1;joint.write_text(before.replace(needle,replacement));after=joint.read_text();assert after.count(replacement)==1
oraclepath=stage/'experiments/public-inspect/bend-candidate/full-v2/retained-oracle.json';o=json.loads(oraclepath.read_text());baseline=o['retained-bend'];variant=baseline.replace('|cursor=0/1/0/1','|cursor=0/1/1/1',1)
# Two nominal schemas each independently start at0 and consume on both failures.
lines=[]
for line in baseline.splitlines():
 if line.startswith('fail:') and 'lookup=[' in line:line=line.replace('|cursor=0/1/0/1','|cursor=0/1/1/1')
 elif line.startswith('fail:'):line=line.replace('|cursor=0/1/0/1','|cursor=0/1/2/1')
 elif line.startswith('success:') and '|cursor=3/1/' in line:line=line.replace('|events=[]/True','|events=[]/False')
 lines.append(line)
variant='\n'.join(lines)+'\n';assert variant!=baseline;o['retained-bend']=variant;oraclepath.write_text(json.dumps(o,indent=2)+'\n')
p['inventory']=B.inventory(stage);p['pins'][str(original)]=B.sha(original);p['pins'][str(Path(__file__).resolve())]=B.sha(Path(__file__))
p['semanticMutation']={'name':'consume-event-reader-on-failed-inspector','beforeSHA256':hashlib.sha256(before.encode()).hexdigest(),'afterSHA256':B.sha(joint),'needle':needle,'replacement':replacement,'changedSourceSites':1,'baselineFullOracleSHA256':hashlib.sha256(baseline.encode()).hexdigest(),'mutantFullOracleSHA256':hashlib.sha256(variant.encode()).hexdigest(),'witnesses':['warm-failure event cursor0→1 both schemas','mixed-failure event cursor0→2 both schemas','lag-retry event lagTrue→False both schemas'],'unaffectedFields':'Every other complete snapshot value including actual payload/resource owners, separate lifecycle logs/retainers and World clocks remains identical in the full literal oracle.'}
p['scope']='Reached compiling reader-consumption mutant development control, exact full8 predicted snapshots both JS/Native; deliberately wrong failure cursor. No production/refinement/proof/performance acceptance.'
path=out/'mutant-plan.json';path.write_text(json.dumps(p,indent=2)+'\n');print(path);print(B.sha(path))
