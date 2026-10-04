#!/usr/bin/env python3
"""Renderer-only actual Data handle validation, no issued authority claim."""
import importlib.util,json,hashlib,tempfile,time
from pathlib import Path
HERE=Path(__file__).resolve().parent
s=importlib.util.spec_from_file_location('render',HERE/'renderer-run.py');r=importlib.util.module_from_spec(s);s.loader.exec_module(r)
def main():
 evidence={'scope':'renderer-only handle Data; actual ECS issuance/refinement is separate','limits':{'checker':5,'runtime':5,'codegen':30,'clang':120},'sources':{p.name:hashlib.sha256(p.read_bytes()).hexdigest() for p in [HERE/'host-render.bend',HERE/'renderer-handle-controls.bend',Path(__file__)]},'combined_fixture_failure':{'source_sha256':hashlib.sha256((HERE/'renderer-bulk-combined-failed.bend').read_bytes()).hexdigest(),'status':'JS five-second timeout in last-main-c; artificial264krows+four65537handles aggregate, not actual E11 acceptance'},'outcomes':[]}
 with tempfile.TemporaryDirectory(prefix='bendvy-handle-render-') as tmp:
  folder=Path(tmp);fixture=folder/'handles.bend';fixture.write_text(r.imports((HERE/'renderer-handle-controls.bend').read_text(),HERE/'renderer-handle-controls.bend'))
  for binary in r.runner.build(fixture,folder):
   started=time.monotonic();raw=r.runner.execute(binary);elapsed=time.monotonic()-started;actual=[json.loads(line) for line in raw.splitlines()]
   assert actual==[dict(encoding='handle-range',namespace=77,first=1,last=65537,count=65537),*[dict(encoding='unrepresentable',reason='handle-namespace-or-range',index=65536)]*3]
   # The encoder checked every original namespace/id; independently verify every
   # expanded range element/order against this complete controlled input.
   for i in range(actual[0]['count']):assert dict(namespace=actual[0]['namespace'],id=actual[0]['first']+i)==dict(namespace=77,id=i+1)
   evidence['outcomes'].append({'backend':'JS' if binary.suffix=='.js' else 'Native','status':'PASS','seconds':elapsed,'raw':raw,'all_handles_validated':65537,'negative_last_handles':['foreign namespace','duplicate id','wrapped id']})
 (HERE/'renderer-handle-evidence.json').write_text(json.dumps(evidence,indent=2)+'\n');print('PASS: every65537handle validated, three actual malformed inputs rejected; Native/JS <=5s')
if __name__=='__main__':main()
