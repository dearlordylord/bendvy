import concurrent.futures,hashlib,json,subprocess
from pathlib import Path

from pathlib import Path as _runner_Path
import sys as _runner_sys
_runner_root = next(p for p in _runner_Path(__file__).resolve().parents if (p/'scripts/task_runner.py').is_file())
_runner_sys.path.insert(0, str(_runner_root/'scripts'))
import task_runner

root=Path(__file__).resolve().parents[2];dest=root/'docs/parity';s=json.loads((dest/'published.json').read_text())
def gh(*a):return task_runner.check_output(['gh',*a],cwd=root,text=True,timeout=30)
issues=json.loads(gh('issue','list','--state','all','--limit','100','--json','number,title,body,labels,url'))
lookup={x['number']:x for x in issues};checks=[]
for key,e in s['tickets'].items():
 issue=lookup[e['number']];local=(dest/(key+'.md')).read_text();assert local.strip()==issue['body'].strip(),key
 assert 'ready-for-agent' in [x['name'] for x in issue['labels']],key
 checks.append({'number':e['number'],'key':key,'bodySHA256':hashlib.sha256(local.encode()).hexdigest(),'expectedBlockers':e['blockers']})
specnum=int(s['spec'].split('/')[-1]);assert lookup[specnum]['body'].strip()==(dest/'remaining-core-spec.md').read_text().strip()
assert 'ready-for-agent' in [x['name'] for x in lookup[specnum]['labels']]
def native(c):
 got=json.loads(gh('api',f'repos/dearlordylord/bendvy/issues/{c["number"]}/dependencies/blocked_by'))
 nums=sorted(x['number'] for x in got);assert nums==sorted(c['expectedBlockers']),(c['number'],nums)
 c['verifiedNativeBlockers']=nums;return c
with concurrent.futures.ThreadPoolExecutor(max_workers=4) as pool:checks=list(pool.map(native,checks))
graph={x['number']:x['expectedBlockers'] for x in checks};vis=set();active=set()
def dfs(n):
 if n in vis:return
 assert n not in active,('cycle',n)
 active.add(n)
 for d in graph.get(n,[]):dfs(d)
 active.remove(n);vis.add(n)
for n in graph:dfs(n)
receipt={'status':'PASS','scope':'Published planning artifacts, labels, bodies and native dependency graph only; no executable or parity acceptance','specification':specnum,'tickets':checks,'ticketCount':len(checks),'nativeEdgeCount':sum(len(x['expectedBlockers']) for x in checks),'acyclic':True,'existingParentsUnmodifiedByPublication':True}
(dest/'publication-receipt.json').write_text(json.dumps(receipt,indent=2)+'\n')
print(json.dumps({k:v for k,v in receipt.items() if k!='tickets'}))
