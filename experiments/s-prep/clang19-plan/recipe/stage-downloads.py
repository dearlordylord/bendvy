#!/usr/bin/env python3
"""Download pinned archives as data only; does not extract, install or execute Clang."""
import argparse,hashlib,json,urllib.request
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('--destination',type=Path,required=True);a=p.parse_args();a.destination.mkdir(parents=True,exist_ok=False)
m=json.loads((Path(__file__).parents[1]/'metadata/packages.json').read_text());r={'scope':'Reversible archive download only; no payload extraction/install/execution','packages':[]}
for v in m['proposedPackages']:
 target=a.destination/Path(v['url']).name
 with urllib.request.urlopen(v['url'],timeout=30) as response,target.open('wb') as output:
  while chunk:=response.read(1024*1024):output.write(chunk)
 data=target.read_bytes();assert len(data)==v['bytes'],target;assert hashlib.sha256(data).hexdigest()==v['sha256'],target
 r['packages'].append({'archive':str(target),'verifiedSHA256':v['sha256'],'bytes':len(data),'url':v['url']})
(a.destination/'download-receipt.json').write_text(json.dumps(r,indent=2)+'\n');print(json.dumps(r))
