"""Actual closure affine quantity confinement, matched positive/negative."""
import pathlib,subprocess,hashlib,json
base=pathlib.Path(__file__).resolve().parent;root=base.parents[2];records=[]
for name in ['positive','duplicate']:
 p=base/(name+'.bend');q=subprocess.run(['bend',str(p),'--check-only'],capture_output=True,text=True,timeout=5)
 if name=='positive':assert q.returncode==0,q.stderr
 else:assert q.returncode!=0 and 'restore (consumed more than once)' in q.stderr+q.stdout
 records.append({'case':name,'command':['bend',str(p),'--check-only'],'cap':5,'exit':q.returncode,'source_sha256':hashlib.sha256(p.read_bytes()).hexdigest(),'stdout':q.stdout,'stderr':q.stderr})
sources={str(p.relative_to(root)):hashlib.sha256(p.read_bytes()).hexdigest() for p in sorted((root/'src/ecs').glob('*.bend'))};(base/'receipt.json').write_text(json.dumps({'status':'PASS','scope':'Affine restoration closure quantity only, not opaque raw constructors or performance','sources':sources,'cases':records},indent=2)+'\n');print('PASS')
