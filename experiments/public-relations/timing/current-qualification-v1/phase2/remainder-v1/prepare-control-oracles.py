"""Independent untimed control expectations; no backend observation."""
from pathlib import Path
import hashlib,json,runpy
HERE=Path(__file__).resolve().parent
sha=lambda data:hashlib.sha256(data).hexdigest()
def main():
 source=HERE/'controls-oracle.py';model=runpy.run_path(str(source));out=HERE/'control-expected';out.mkdir(exist_ok=True);manifest={'scope':'Authored separate nonpower/sparse/empty expected bytes only; no normal-family or backend/timing acceptance','sourceSHA256':sha(source.read_bytes()),'cases':[]}
 for control in ['nonpower','sparse','empty']:
  value=model['trace'](control,0);name=control+'-seed-0.json';data=(json.dumps(value,separators=(',',':'))+'\n').encode();path=out/name
  if path.exists():assert path.read_bytes()==data
  else:path.write_bytes(data)
  manifest['cases'].append({'control':control,'payloadSeed':0,'expected':name,'sha256':sha(data),'bytes':len(data),'records':sum(len(root['records']) for root in value['roots']),'operationCounts':model['operation_counts'](value)})
 (out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n');print([(case['control'],case['records'],case['bytes']) for case in manifest['cases']])
if __name__=='__main__':main()
