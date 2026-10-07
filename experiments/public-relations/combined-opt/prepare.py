from pathlib import Path
import sys,json
R=Path(__file__).resolve().parents[3];D=Path(__file__).resolve().parent
sys.path.insert(0,str(R/'experiments/public-relations/timing'));import stage
projection=R/'experiments/public-relations/projection-opt/candidate'/stage.APP.relative_to(R)/'owned-world.bend'
capture=R/'experiments/public-relations/capture-opt/candidate';provenance=json.loads((D/'provenance.json').read_text())
assert stage.sha(stage.APP/'owned-world.bend')==provenance['projection']['originalSHA256'];assert stage.sha(projection)==provenance['projection']['candidateSHA256']
for name,row in provenance['capture']['files'].items():assert stage.sha(R/row['source'])==row['baselineSHA256'] and stage.sha(capture/name)==row['candidateSHA256']
for variant in ['baseline','candidate']:
 out=D/'stages'/variant;sys.argv=['stage.py','--output',str(out)];stage.main();p=out/'stage.json';s=json.loads(p.read_text());before=dict(s['stage_inventory']);extras=[Path(__file__).resolve(),D/'run.py',D/'provenance.json']
 if variant=='candidate':
  mapping={str((stage.APP/'owned-world.bend').relative_to(R)):projection,**{row['source']:capture/name for name,row in provenance['capture']['files'].items()}}
  for name,source in mapping.items():(out/'stage'/name).write_bytes(source.read_bytes())
  extras.extend(mapping.values())
 s['sources'].update({str(path.relative_to(R)):stage.sha(path) for path in extras});s['stage_inventory']=stage.inventory(out/'stage');changes={k:{'before':before[k],'after':h} for k,h in s['stage_inventory'].items() if before[k]!=h};assert set(changes)==(set(provenance['allowedChangedStagePaths']) if variant=='candidate' else set());s['intentionalChanges']=changes;s['combined_variant']=variant;s['status']='COMBINED_OBSERVER_PREPARED_ONLY';p.write_text(json.dumps(s,indent=2)+'\n')
