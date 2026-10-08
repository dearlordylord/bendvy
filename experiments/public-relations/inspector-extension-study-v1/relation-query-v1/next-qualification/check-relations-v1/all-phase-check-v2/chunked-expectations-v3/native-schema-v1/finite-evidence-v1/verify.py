"""Portable no-child audit of complete two-schema Native Check execution."""
from pathlib import Path
import hashlib,json,tarfile,runpy
H=Path(__file__).resolve().parent
sha=lambda b:hashlib.sha256(b).hexdigest()
def strict(x):
 if isinstance(x,dict):return ('dict',tuple((k,strict(v)) for k,v in sorted(x.items())))
 if isinstance(x,list):return ('list',tuple(map(strict,x)))
 return (type(x).__name__,x)
with tarfile.open(H/'evidence.tar.gz') as t:
 members=t.getmembers();assert len({m.name for m in members})==len(members) and all(m.isfile() for m in members);raw={m.name:t.extractfile(m).read() for m in members}
assert raw['index.json']==(H/'index.json').read_bytes();i=json.loads(raw['index.json']);rows={r['name']:r for r in i['records']};assert len(rows)==len(i['records']) and set(raw)=={'index.json'}|{'objects/'+r['SHA256'] for r in rows.values()}
f={}
for n,row in rows.items():
 b=raw['objects/'+row['SHA256']];assert sha(b)==row['SHA256'] and len(b)==row['bytes'];f[n]=b
prefix='/workspace/formal-proofs/bendvy-worktrees/parity-42-relations/'
def path(n):return 'worktree/'+n[len(prefix):] if n.startswith(prefix) else 'external/'+n.lstrip('/')
def obj(n):return json.loads(f[n])
a=i['actual'];p=obj(a+'/plan.json');r=obj(a+'/receipt.json');q=obj(a+'/prepare-receipt.json')
assert sha(f[a+'/plan.json'])=='48c07a77a03b4b0522fa14056055c28271e0b6d1b18e6c520c70cd6532cc8822'==r['planSHA256']
assert sha(f[a+'/receipt.json'])=='ef172eec439253dfbe447001c0a45e5f191e7fc4f2704efb90cd36849a722e46' and r['status']=='DEVELOPMENT_TWO_SCHEMA_NATIVE_CHECK320_PLUS192_DIAGNOSTICS_PASS_NOT_FULL55' and r.get('guardFailures',[])==[]
assert sha(f[a+'/prepare-receipt.json'])=='e8070bb8863ce08ffe8ea1152dc139d2ffd79f6feab7ad9dfae294b3bf408fe2' and q['status']=='OWNED_NATIVE_PREPARATION_PASS' and q.get('guardFailures',[])==[]
plans=[p]+[json.loads(b) for n,b in f.items() if n.endswith('/plan.json') and 'pins' in json.loads(b)]
private={x['privateEnvironment']:x['environmentSHA256'] for x in plans if 'privateEnvironment' in x};installed={}
for hp in plans:installed.update(hp.get('tools',{}).get('pins',{}))
for n,d in p['pins'].items():
 if path(n) in f:assert sha(f[path(n)])==d
 else:assert i['excluded'][n]['SHA256']==d
for n,row in i['excluded'].items():
 if n in private:assert row['SHA256']==private[n] and row['reason']=='private environment metadata only'
 elif n=='/home/node/.npmrc':assert row['reason']=='private participating configuration identity only' and p['configuration'][n]['SHA256']==row['SHA256']
 elif n in r['generated']:assert row['reason']=='actual Native executable identity only' and row['SHA256']==r['generated'][n] and not n.endswith('.c')
 else:assert row['reason']=='installed ELF identity only' and installed[n]==row['SHA256']
for record,folder,labels in ((q,'prepare-probes',['prepare-'+n for n in ('bend','node','python','taskset','clang')]),(r,'execution-probes',p['executionProbeLabels'])):
 assert record['probeCommandsExecuted']==len(labels) and len(labels) in (5,65)
 expected={a+'/'+folder+'/'+label+suffix for label in labels for suffix in ('.json','.stdout','.stderr')};assert set(map(path,record['probePins']))==expected=={n for n in f if n.startswith(a+'/'+folder+'/')}
 for n,d in record['probePins'].items():assert sha(f[path(n)])==d
 for label in labels:
  m=obj(a+'/'+folder+'/'+label+'.json');tool=label.rsplit('-',1)[-1]
  assert m['argv']==[p['tools']['taskset'],'-c','5',p['tools']['ldd'],p['tools']['tools'][tool]] and m['seconds']==5 and m['exit']==0 and m['failure'] is None and m.get('exception') is None and m['runnerSHA256']==p['pins'][prefix+'scripts/task_runner.py']
assert len(p['commands'])==len(r['commands'])==6 and set(r['logs'])=={pc['label']+suffix for pc in p['commands'] for suffix in ('.stdout','.stderr')}
for n,d in r['logs'].items():assert sha(f[a+'/'+n])==d
notice=f['worktree/experiments/public-relations/inspector-extension-study-v1/pinned-bend-notice.bytes'];assert sha(notice)=='57f1325a11b98d00f4bdbb487bda0cc9787e2baa240266722596845baee2e494' and len(notice)==42
schemaRaw={}
for pc,rc in zip(p['commands'],r['commands']):
 assert all(pc[k]==rc[k] for k in ('label','argv','seconds')) and rc['exit']==0 and rc['failure'] is None and rc['status']=='QUALIFIED' and pc['argv'][1:3]==['-c','5']
 stdout=f[a+'/'+pc['label']+'.stdout'];stderr=f[a+'/'+pc['label']+'.stderr']
 if pc['label'].startswith('emit-'):assert pc['seconds']==30 and stdout==b'' and stderr in (b'',notice)
 elif pc['label'].startswith('compile-'):assert pc['seconds']==120 and stdout==stderr==b'' and pc['argv'][3]=='/tmp/bendvy-clang19-diagnostic/clang19' and '-O3' in pc['argv']
 else:
  assert pc['seconds']==5 and pc['argv'][-4:]==['--threads','1','--gpu','off'] and stderr==b''
  text=stdout.decode();actual,end=json.JSONDecoder().raw_decode(text);assert text[end:].encode()==b'\n' and len(actual['schemas'])==1 and sum(len(phase['queries']) for phase in actual['schemas'][0]['phases'])==96
  assert strict(actual)==strict(obj(path(pc['oracle']))) and rc['fullOracleMatched'] is True and sha(f[path(pc['oracle'])])==rc['oracleSHA256']
  assert stdout.startswith(b'{"schemas":[') and stdout.endswith(b']}\n');schemaRaw[pc['family']]=stdout[len(b'{"schemas":['):-3]
assert set(schemaRaw)=={'workshop','garden'}
combined=b'{"schemas":['+schemaRaw['workshop']+b','+schemaRaw['garden']+b']}\n';assert sha(combined)==r['combinedFullRawSHA256']=='5d408e1462bda599a68cd0279b47536fe49fc90b4449d8261526794e195f96d8' and r['full192DiagnosticAnd320CheckJoinMatched'] is True
assert combined==f['worktree/.artifacts/check-relation55-chunk-standalone-js-1791457454442741470/js-check.stdout']
for n,d in r['generated'].items():
 if n.endswith('.c'):assert sha(f[path(n)])==d
 else:assert i['excluded'][n]['SHA256']==d
assert len(r['generated'])==4
assert {n for n in f if n.startswith(path(p['stage'])+'/')}=={path(str(Path(p['stage'])/n)) for n in p['inventory']}
for n,d in p['inventory'].items():assert sha(f[path(str(Path(p['stage'])/n))])==d
for row in p['stageImportJoins']:assert f[path(row['source'])]==f[path(row['copy'])] and sha(f[path(row['originalTarget'])])==sha(f[path(row['actualTarget'])])==row['SHA256']
root=H
while not (root/'experiments').is_dir():root=root.parent
for row in json.loads((H/'delivery-files.json').read_text())['files']:assert sha((root/row['path']).read_bytes())==row['SHA256']
for row in p['stageImportJoins']:assert sha((root/row['source'][len(prefix):]).read_bytes())==p['pins'][row['source']]
normal=H.parents[1]/'finite-js-evidence-v1';runpy.run_path(str(normal/'verify.py'),run_name='__main__')
print('PASS: complete Native Check320/192 diagnostic schema join; no backend replay/full55/proof/performance claim')
