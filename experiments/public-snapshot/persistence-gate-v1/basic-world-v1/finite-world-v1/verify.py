"""Portable no-child read/hash verification of the complete named basicWorld fixture."""
import hashlib
import json
import re
import tarfile
from pathlib import Path
HERE=Path(__file__).resolve().parent
OWN=HERE.parents[4]
def sha(data):return hashlib.sha256(data).hexdigest()
def strict(a,e):
 assert type(a) is type(e)
 if isinstance(e,dict):
  assert a.keys()==e.keys()
  for k in e:strict(a[k],e[k])
 elif isinstance(e,list):
  assert len(a)==len(e)
  for x,y in zip(a,e):strict(x,y)
 else:assert a==e

def main():
 selection=json.loads((HERE/'selection.json').read_bytes())
 expected_delivery_paths=['experiments/public-snapshot/persistence-gate-v1/basic-world-v1/ORACLE-SCOPE.md', 'experiments/public-snapshot/persistence-gate-v1/basic-world-v1/PROPOSAL.md', 'experiments/public-snapshot/persistence-gate-v1/basic-world-v1/capacity-consumer-source-positive.bend', 'experiments/public-snapshot/persistence-gate-v1/basic-world-v1/capacity-repair-proposal.json', 'experiments/public-snapshot/persistence-gate-v1/basic-world-v1/capacity-repair.diff', 'experiments/public-snapshot/persistence-gate-v1/basic-world-v1/capacity-source-closure.json', 'experiments/public-snapshot/persistence-gate-v1/basic-world-v1/column-provider.bend', 'experiments/public-snapshot/persistence-gate-v1/basic-world-v1/consumer-io.bend', 'experiments/public-snapshot/persistence-gate-v1/basic-world-v1/consumer.bend', 'experiments/public-snapshot/persistence-gate-v1/basic-world-v1/driver.bend', 'experiments/public-snapshot/persistence-gate-v1/basic-world-v1/expected-consumer.json', 'experiments/public-snapshot/persistence-gate-v1/basic-world-v1/expected-reference.json', 'experiments/public-snapshot/persistence-gate-v1/basic-world-v1/expected-reference.stdout', 'experiments/public-snapshot/persistence-gate-v1/basic-world-v1/expected-world.json', 'experiments/public-snapshot/persistence-gate-v1/basic-world-v1/export.bend', 'experiments/public-snapshot/persistence-gate-v1/basic-world-v1/finite-world-v1/REPORT.md', 'experiments/public-snapshot/persistence-gate-v1/basic-world-v1/finite-world-v1/build.py', 'experiments/public-snapshot/persistence-gate-v1/basic-world-v1/finite-world-v1/evidence.tar.gz', 'experiments/public-snapshot/persistence-gate-v1/basic-world-v1/finite-world-v1/index.json', 'experiments/public-snapshot/persistence-gate-v1/basic-world-v1/finite-world-v1/verify.py', 'experiments/public-snapshot/persistence-gate-v1/basic-world-v1/fixture.bend', 'experiments/public-snapshot/persistence-gate-v1/basic-world-v1/format.bend', 'experiments/public-snapshot/persistence-gate-v1/basic-world-v1/generated-js-capacity-direction.json', 'experiments/public-snapshot/persistence-gate-v1/basic-world-v1/generated-js-capacity.py', 'experiments/public-snapshot/persistence-gate-v1/basic-world-v1/generated-js-direction.json', 'experiments/public-snapshot/persistence-gate-v1/basic-world-v1/generated-js-stage.py', 'experiments/public-snapshot/persistence-gate-v1/basic-world-v1/generated-js.py', 'experiments/public-snapshot/persistence-gate-v1/basic-world-v1/io-cheap.py', 'experiments/public-snapshot/persistence-gate-v1/basic-world-v1/io-proposal.json', 'experiments/public-snapshot/persistence-gate-v1/basic-world-v1/model.py', 'experiments/public-snapshot/persistence-gate-v1/basic-world-v1/output.bend', 'experiments/public-snapshot/persistence-gate-v1/basic-world-v1/owner.bend', 'experiments/public-snapshot/persistence-gate-v1/basic-world-v1/reference-cheap.py', 'experiments/public-snapshot/persistence-gate-v1/basic-world-v1/reference.mjs', 'experiments/public-snapshot/persistence-gate-v1/basic-world-v1/setup-source-positive.bend', 'experiments/public-snapshot/persistence-gate-v1/basic-world-v1/setup.bend', 'experiments/public-snapshot/persistence-gate-v1/basic-world-v1/source-closure.json', 'experiments/public-snapshot/persistence-gate-v1/basic-world-v1/source-positive.bend', 'experiments/public-snapshot/persistence-gate-v1/basic-world-v1/source-proposal.json', 'experiments/public-snapshot/persistence-gate-v1/basic-world-v1/validation.bend', 'experiments/public-snapshot/persistence-gate-v1/basic-world-v1/world-owner.bend']
 assert len(expected_delivery_paths)==41 and set(selection['files'])==set(expected_delivery_paths)
 for rel,digest in selection['files'].items():
  assert rel.startswith('experiments/public-snapshot/persistence-gate-v1/basic-world-v1/') and '..' not in Path(rel).parts
  assert sha((OWN/rel).read_bytes())==digest
 index=json.loads((HERE/'index.json').read_bytes());objects={}
 with tarfile.open(HERE/'evidence.tar.gz','r:gz') as archive:
  for member in archive.getmembers():
   assert member.isfile() and member.name not in objects and member.name.startswith('objects/')
   data=archive.extractfile(member).read();assert member.name=='objects/'+sha(data) and not data.startswith(b'\x7fELF');objects[member.name]=data
 records=index['records']
 def read(path):
  row=records[str(path)];data=objects[row['object']];assert sha(data)==row['sha256'] and len(data)==row['bytes'];return data
 def j(path):return json.loads(read(path))
 assert set(objects)=={r['object'] for r in records.values()}
 for path in records:read(path)
 def resource_members(root,value):
  if value.get('kind')=='file':return {root:value['sha256']}
  if value.get('kind')=='directory':
   result={}
   for child,row in value['inventory'].items():result.update(resource_members(root+'/'+child,row))
   return result
  if value.get('kind')=='symlink':return resource_members(value['resolvedPath'],value['resolved'])
  return {}
 def authorized(plan):
  result=dict(plan.get('snapshot',{}).get('pins',{}));result.update(plan.get('resourceMembers',{}))
  if 'installedMembership' in plan:result.update(resource_members(plan.get('installedResource') or plan['resourceRoots'][0],plan['installedMembership']))
  if isinstance(plan.get('command'),dict):
   for path in (plan['command']['argv'][0],plan['command']['argv'][3]):
    if path in plan.get('pins',{}):result[path]=plan['pins'][path]
  return result
 plans={name:j(name) for name in index['pinDispositions']}
 for name,rows in index['pinDispositions'].items():
  plan=plans[name];pins=plan.get('pins') or plan.get('sourcePins') or plan.get('consumedClosure',{}).get('sourcePins') or {}
  assert set(rows)==set(pins)
  for path,digest in pins.items():
   row=rows[path];assert row['sha256']==digest
   if row['disposition']=='archived':assert sha(read(row['record']))==digest
   elif row['disposition']=='excluded-private-environment':assert any(p.get('privateEnvironment')==path and p.get('environmentSHA256')==digest for p in plans.values())
   elif row['disposition']=='excluded-installed-identity':assert authorized(plans[row['association']['plan']]).get(path)==digest
   elif row['disposition']=='historical-unavailable-source':
    assert name.endswith('/snapshot58-basic-world-source-1791480955687464703/plan.json') and path.endswith('/basic-world-v1/source-positive.bend') and digest=='004762759ead8ad84d361a06bef6485051f53ab7c1c987456cfffe0c1dd1aa83'
   else:raise AssertionError('unclassified disposition')
 def pinned(plan_path,path):
  row=index['pinDispositions'][plan_path][str(path)];assert row['disposition']=='archived';return read(row['record'])
 base=index['historicalOwnRoot']+'/.artifacts/'
 normal=base+'snapshot58-world-capacity-js-1791485717075416264/'
 plan_path=normal+'plan.json';p=j(plan_path);r=j(normal+'receipt.json');prep=j(normal+'preparation.json')
 assert sha(read(plan_path))=='6f3b6e853afeafd7205f31aa087fa3e09b3ca55fbbc67a0b4cf60c597d65fb34'
 assert sha(read(normal+'receipt.json'))=='0597aef7fd6f0aeef84272e7cce600b3250a5eb35a7ea86aa3dbafb6e1569213'
 assert sha(read(normal+'preparation.json'))=='83ea76f87605d79175e53933cd53ee4beea70b5027d39ffbc70a47c1c4aa274f'
 assert r['status']=='DEVELOPMENT_PASS' and not r.get('guardFailures')
 assert prep['status']=='PREPARATION_PASS' and not prep.get('guardFailures')
 assert prep['planSHA256']==r['planSHA256']==sha(read(plan_path))
 names=('bend','node','taskset','shell');expected=[]
 for subject in ('emit','consumer'):
  expected.extend('before-'+subject+'-'+n for n in names);expected.append(subject);expected.extend('after-'+subject+'-'+n for n in names)
 expected.extend('final-'+n for n in names)
 assert [c['label'] for c in r['commands']]==expected
 assert [c['label'] for c in prep['commands']]==['prep-'+n for n in names]
 assert p['runnerSHA256']==p['pins'][index['historicalRoot']+'/scripts/task_runner.py']
 def raw_ledger(record,directory):
  assert set(record['logs'])=={c['label']+'.'+s for c in record['commands'] for s in ('stdout','stderr')}
  for c in record['commands']:
   assert c['capture']=='split' and c['runnerSHA256']==p['runnerSHA256']
   for stream in ('stdout','stderr'):
    b=read(directory+c['label']+'.'+stream);assert sha(b)==record['logs'][c['label']+'.'+stream]==c['streams'][stream]['sha256'] and len(b)==c['streams'][stream]['bytes']
 raw_ledger(prep,normal);raw_ledger(r,normal+'execution/')
 assert all(c['exit']==0 and c['failure'] is None for c in prep['commands']+r['commands'])
 for c in prep['commands']+[c for c in r['commands'] if c['label'] not in ('emit','consumer')]:
  name=c['label'].rsplit('-',1)[-1];assert c['argv']==[p['taskset'],'-c','5',p['ldd'],p['tools'][name]] and c['capSeconds']==5
 semantic=[c for c in r['commands'] if c['label'] in ('emit','consumer')]
 assert semantic[0]['argv']==[p['taskset'],'-c','5',p['tools']['bend'],p['stage']['entry'],'-o',p['artifact']] and semantic[0]['capSeconds']==30
 assert semantic[1]['argv']==[p['taskset'],'-c','5',p['tools']['node'],p['artifact']] and semantic[1]['capSeconds']==5
 assert read(normal+'execution/emit.stdout')==b'' and read(normal+'execution/emit.stderr') in (b'',b'bend 2.0.36 is available: run bend update\n')
 assert read(normal+'execution/consumer.stderr')==b''
 output=read(normal+'execution/consumer.stdout');oracle=pinned(plan_path,p['oracle']);assert sha(oracle)==p['oracleSHA256']=='683fac8c0e7dc1fb34077cc06ed21dcf0143488a121d4a4c080c616b19982c5b'
 assert len(oracle)==23361 and len(output)==8026 and sha(output)=='31d27daf1c7360d1f6adf2633a18ece2c6c0ab391b6186e8cd9dabd3ae0a7d0d'
 assert output.endswith(b'\n') and not output.endswith(b'\n\n');strict(json.loads(output),json.loads(oracle))
 assert set(r['generated'])=={p['artifact']} and len(read(p['artifact']))==333096 and sha(read(p['artifact']))==r['generated'][p['artifact']]['sha256']=='f7782523ad58861dbf60ac8cd0735feead31fea70cd58d54305fc79dd9657361'
 closure=p['originalConsumedClosure'];assert len(closure['sourcePins'])==90 and len(closure['importJoins'])==174
 for path,digest in closure['sourcePins'].items():assert p['pins'][path]==digest
 for edge in closure['importJoins']:assert closure['sourcePins'][edge['source']]==p['pins'][edge['source']] and closure['sourcePins'][edge['resolved']]==edge['sha256']
 stage=p['stage'];mapping={row['source']:row['copy'] for row in stage['sources']}
 members={normal+'stage/'+n:h for n,h in stage['inventory'].items()};assert len(members)==21
 assert stage['entry']==mapping[index['historicalSourceRoot']+'/consumer-io.bend']
 assert stage['entry'] in members and '..' not in Path(stage['entry']).parts
 assert sha(read(stage['entry']))==members[stage['entry']]==stage['inventory'][Path(stage['entry']).name]
 assert {path:row['sha256'] for path,row in records.items() if path.startswith(normal+'stage/')}==members and set(mapping.values())==set(members)
 pattern=re.compile(r'^(import\s+)(\S+)(.*)$',re.M);edges=[]
 for row in stage['sources']:
  source=row['source'];original=pinned(plan_path,source);assert sha(original)==row['sourceSHA256']
  def rewrite(match):
   name=match.group(2)
   if name=='Base':return match.group(0)
   target=str(Path(name) if Path(name).is_absolute() else Path(source).parent/name)
   # Historical paths normalize lexically; no current filesystem/backend lookup.
   import posixpath
   target=posixpath.normpath(target)
   assert target in mapping;edges.append((source,name,target,stage['sourcePins'][target]))
   return match.group(1)+'./'+Path(mapping[target]).name+match.group(3)
  rewritten=pattern.sub(rewrite,original.decode()).encode();assert rewritten==read(row['copy']) and sha(rewritten)==row['copySHA256']==members[row['copy']]
 assert sorted(edges)==sorted((e['source'],e['import'],e['target'],e['targetSHA256']) for e in stage['importJoins'])
 # Current owned delivery bodies match archived current bytes. External roots are historical evidence only.
 historical=index['historicalSourceRoot'];live=HERE.parent
 for path,row in records.items():
  if Path(path).parent==Path(historical):assert sha((live/Path(path).name).read_bytes())==row['sha256']
 ts=base+'snapshot58-world-reference-cheap-1791483992999401767/';tp=j(ts+'plan.json');tr=j(ts+'receipt.json')
 assert sha(read(ts+'plan.json'))=='9496ea6e515bbda421bd41ce589ab8791725923fa22c579120079f38d306a666' and sha(read(ts+'receipt.json'))=='1ac935224fe5c959c3379666694bc5e3958de9cc710cdf6fe6fc7881391ed18a'
 assert tr['status']=='DEVELOPMENT_PASS' and not tr.get('guardFailures') and len(tr['commands'])==1
 tc=tr['commands'][0];assert tc['argv']==tp['command']['argv']==[tp['command']['argv'][0],'-c','5',tp['command']['argv'][3],historical+'/reference.mjs'] and tc['capSeconds']==5 and tc['exit']==0 and tc['failure'] is None
 assert tc['runnerSHA256']==tp['runnerSHA256'] and tc['capture']=='split'
 assert tr['logs']=={'reference.stdout':'10a2ae3270f79645e27671eb78dba46f0c458c4ca9519ef4fab8026afea6e786','reference.stderr':sha(b'')}
 assert read(ts+'reference.stdout')==pinned(ts+'plan.json',tp['expectedOutput']) and len(read(ts+'reference.stdout'))==1768 and read(ts+'reference.stderr')==b''
 io=base+'snapshot58-world-io-cheap-1791484637066871097/';ir=j(io+'receipt.json');assert sha(read(io+'receipt.json'))=='818a70ba1dc6e39723b6165162d97c70aeecb95c12754c91cc8ad5d513ca7a2b'
 assert ir['status']=='INCOMPLETE' and ir['guardFailures']==[] and len(ir['commands'])==1 and ir['commands'][0]['failure']=='child deadline' and ir['commands'][0]['capSeconds']==5
 assert read(io+'consumer-io.stdout')==read(io+'consumer-io.stderr')==b''
 failed=base+'snapshot58-world-generated-js-1791484947448693445/';fr=j(failed+'receipt.json');assert sha(read(failed+'receipt.json'))=='5a3bef946918de94fc8eb041f747411c4822b84a2311a9cac0d0ebb46f432411'
 assert fr['status']=='INCOMPLETE' and len(fr['commands'])==19 and fr['commands'][-1]['label']=='final-bend' and fr['commands'][-1]['failure']=='child deadline'
 assert fr['guardFailures']==[{'guard':'tools','error':'ProbeFailure: ldd command refused'}]
 assert json.loads(read(failed+'execution/consumer.stdout'))!=json.loads(oracle)
 print('PASS: actual TS basicDTO+alias oracle and repaired whole Bend JS fixture/full owners/validation; all histories retained. No public save Gate/Native/full58 adoption.')
if __name__=='__main__':main()
