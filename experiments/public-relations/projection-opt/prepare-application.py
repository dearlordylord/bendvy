from pathlib import Path
import sys,json,hashlib,importlib.util
R=Path(__file__).resolve().parents[3];D=Path(__file__).resolve().parent
sys.path.insert(0,str(R/'experiments/public-relations/timing'));import stage
sha=stage.sha
for variant in ['baseline','candidate']:
 out=D/'application-execution-v2'/variant;sys.argv=['stage.py','--output',str(out)];stage.main()
 p=out/'stage.json';s=json.loads(p.read_text());key=str((stage.APP/'owned-world.bend').relative_to(R));original=(out/'stage'/key).read_bytes()
 if variant=='candidate':
  source=D/'candidate'/key;assert sha(stage.APP/'owned-world.bend')==json.loads((D/'source-plan.json').read_text())['originalSHA256'];(out/'stage'/key).write_bytes(source.read_bytes());s['sources'][str(source.relative_to(R))]=sha(source)
 s['sources'][str(Path(__file__).resolve().relative_to(R))]=sha(Path(__file__));s['sources'][str((D/'run-application.py').relative_to(R))]=sha(D/'run-application.py')
 s['stage_inventory']=stage.inventory(out/'stage');s['projection_variant']=variant;s['originalObserverSHA256']=hashlib.sha256(original).hexdigest();s['actualObserverSHA256']=sha(out/'stage'/key);s['status']='PROJECTION_COMPLETE_APPLICATION_PREPARED_ONLY';p.write_text(json.dumps(s,indent=2)+'\n')
