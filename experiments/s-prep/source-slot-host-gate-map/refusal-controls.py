#!/usr/bin/env python3
"""Fresh malformed-map controls; original files are never edited."""
import argparse,pathlib,json,copy,subprocess,hashlib
p=argparse.ArgumentParser();p.add_argument('--map',type=pathlib.Path,required=True);p.add_argument('--config',type=pathlib.Path,required=True);p.add_argument('--output',type=pathlib.Path,required=True);a=p.parse_args();a.output.mkdir();base=json.loads(a.map.read_text());r=[];verifier=pathlib.Path(__file__).parent/'verify-cohort-map.py'
for name in ['missing-cohort','conflicting-runtime','missing-oracle','missing-anchor','missing-subject','missing-import','unknown-subject']:
 x=copy.deepcopy(base);s=x['cohorts'][0]['subjects'][0]
 if name=='missing-cohort':x['missingRequiredCohorts']=['static-world-sixteen']
 if name=='conflicting-runtime':s['actualRuntime29']['experiments/s-integrate/storage.bend']='0'*64
 if name=='missing-oracle':x['cohorts'][0]['oraclePins']={}
 if name=='missing-anchor':s['liveAnchorDefinitions']={}
 if name=='missing-subject':x['cohorts'][0]['subjects']=[]
 if name=='missing-import':
  extras=[f for f in s['sourceMap'] if pathlib.Path(f).name not in {pathlib.Path(n).name for n in base['baseSource29']} and f!=s['entry']];assert extras;del s['sourceMap'][extras[0]]
 if name=='unknown-subject':s['entry']=str(pathlib.Path(s['entry']).parent/'host-fixture.bend')
 f=a.output/(name+'.json');f.write_text(json.dumps(x));out=a.output/(name+'-verified.json');cmd=['python3',str(verifier),'--map',str(f),'--config',str(a.config),'--output',str(out)];v=subprocess.run(cmd,capture_output=True,text=True,timeout=5);assert v.returncode!=0 and not out.exists();r.append({'case':name,'command':cmd,'capSeconds':5,'exit':v.returncode,'intendedFailure':v.stderr.splitlines()[-1],'mutatedMapSHA256':hashlib.sha256(f.read_bytes()).hexdigest()})
(a.output/'evidence.json').write_text(json.dumps({'status':'SEVEN_FAIL_CLOSED_SOURCE_COHORT_MAP_REFUSALS_PASS','verifierSHA256':hashlib.sha256(verifier.read_bytes()).hexdigest(),'cases':r},indent=2)+'\n')
