"""Freeze only Native for the already observed complete optional-resource fixture."""
from pathlib import Path
import contextlib,hashlib,io,json,shutil,types
HERE=Path(__file__).resolve().parent
B=types.ModuleType('inspect_backend');B.__file__=str(HERE/'backends.py');exec((HERE/'backends.py').read_text().split('\np=argparse.ArgumentParser()')[0],B.__dict__)
stream=io.StringIO()
with contextlib.redirect_stdout(stream):B.prepare()
path=Path(stream.getvalue().splitlines()[0]);out=path.parent;original=out/'original-unexecuted-plan.json';path.rename(original);p=json.loads(original.read_text());stage=Path(p['stage']);root=B.ROOT;files=set();B.closure(HERE/'retention-control-main.bend',files);files.add(HERE/'retention-control-oracle.json');files.add(HERE/'retention-backend-development.py');files.add(Path(__file__).resolve())
for source in sorted(files):
 target=stage/source.relative_to(root);target.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(source,target);assert B.sha(source)==B.sha(target);p['pins'][str(source)]=B.sha(source)
# The generic backend driver's literal slot is populated with the independently
# authored complete resource oracle, not with reduced selected observations.
resource=json.loads((HERE/'retention-control-oracle.json').read_text());oracle=stage/'experiments/public-inspect/bend-candidate/full-v2/retained-oracle.json';oracle.write_text(json.dumps({'retained-bend':resource},indent=2)+'\n')
p['commands']=p['commands'][2:]
for cmd in p['commands']:
 cmd['argv']=[a.replace('/full-v2/retained-main.bend','/full-v2/retention-control-main.bend') for a in cmd['argv']]
p['inventory']=B.inventory(stage);p['pins'][str(original)]=B.sha(original);p['executionProbeLabels']=['guard-'+str(k)+'-ldd-'+name for k in range(7) for name in ['bend','node','python','taskset','clang']]
p['scope']='Native only, complete12 actual retainer advancement/disposal observations across two nominal schemas. Separate interpreted/JS cheap complete oracle already passed. No foreign Inspector policy, proof, performance or full54 acceptance.'
p['oracleMapping']={'independentResourceOracleSHA256':B.sha(HERE/'retention-control-oracle.json'),'fullBendTextSHA256':hashlib.sha256(resource.encode()).hexdigest(),'genericLiteralSlot':'retained-bend','genericBackendStatusIsLiteralOnly':True}
path=out/'retention-native-plan.json';path.write_text(json.dumps(p,indent=2)+'\n');print(path);print(B.sha(path))
