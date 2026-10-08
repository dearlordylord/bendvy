"""Portable read/hash-only verification of selected development controls."""
from pathlib import Path
import hashlib, json, os, re, tarfile
HERE=Path(__file__).resolve().parent
sha=lambda b:hashlib.sha256(b).hexdigest()
def strict(v):
 if isinstance(v,dict):return ('dict',tuple((k,strict(x)) for k,x in sorted(v.items())))
 if isinstance(v,list):return ('list',tuple(map(strict,v)))
 return (type(v).__name__,v)
def differences(e,o,p='$'):
 if type(e)!=type(o):return [{'path':p,'expected':e,'observed':o}]
 if isinstance(e,dict):
  if set(e)!=set(o):return [{'path':p,'expected':e,'observed':o}]
  return [d for k in e for d in differences(e[k],o[k],p+'.'+k)]
 if isinstance(e,list):
  rows=[d for i in range(min(len(e),len(o))) for d in differences(e[i],o[i],p+'['+str(i)+']')]
  if len(e)!=len(o):rows.append({'path':p+'.length','expected':len(e),'observed':len(o)})
  for i in range(min(len(e),len(o)),max(len(e),len(o))):rows.append({'path':p+'['+str(i)+']','expected':e[i] if i<len(e) else {'absent':True},'observed':o[i] if i<len(o) else {'absent':True}})
  return rows
 return [] if e==o else [{'path':p,'expected':e,'observed':o}]
def omit(v,target):
 if isinstance(v,list):return [omit(x,target) for x in v if not(isinstance(x,dict) and x.get('constructor')==target)]
 if isinstance(v,dict):return {k:omit(x,target) for k,x in v.items()}
 return v

def main():
 selection=json.loads((HERE/'selection.json').read_text())
 assert selection['selfExemption']==['selection.json']
 assert set(selection['files'])=={'README.md','index.json','evidence.tar.gz','verify.py'}
 for name,h in selection['files'].items():assert sha((HERE/name).read_bytes())==h
 index=json.loads((HERE/'index.json').read_text());objects={}
 assert index['scope']=='development controls only; not full #63 delivery-tool protocol'
 with tarfile.open(HERE/'evidence.tar.gz','r:gz') as archive:
  for m in archive.getmembers():
   assert m.isfile() and re.fullmatch(r'objects/[0-9a-f]{64}',m.name) and m.name not in objects
   data=archive.extractfile(m).read();assert m.name=='objects/'+sha(data) and not data.startswith(b'\x7fELF');objects[m.name]=data
 records=index['records'];assert set(objects)=={r['object'] for r in records.values()}
 assert len(records)==index['recordCount']==536 and len(objects)==index['objectCount']==156
 assert sha((HERE/'evidence.tar.gz').read_bytes())==index['archiveSHA256']
 assert {p.name for p in HERE.iterdir() if p.is_file()}==set(selection['files'])|{'selection.json'}
 def read(path):
  row=records[path];data=objects[row['object']];assert sha(data)==row['sha256'] and len(data)==row['bytes'];return data
 def js(path):return json.loads(read(path))
 for path in records:read(path)
 assert not any(p.endswith('/main.js') for p in records)
 oracle=js('inputs/independent-expected.json');assert sha(read('inputs/independent-expected.json'))=='f821c68264eb25c33a674841d0f2abcf466a9d6372e888cfc40b7ae691ae071a'
 parser_bytes=read('inputs/parse-report.py');assert sha(parser_bytes)=='b9366c499da4cb11360464d068bce653972c3a50b6c6042e92f54f3a6e487110'
 parser={'__name__':'archived_report_parser'};exec(compile(parser_bytes,'archived-parse-report.py','exec'),parser)
 names=['positive','cross-schema','affine-duplicate','write-through-read','undeclared-event','omit-hit','omit-death']
 expected={'cross-schema':('Scenario.ScenarioExecution<Geometry.Garden>','Scenario.ScenarioExecution<Geometry.Workshop>','Location: workshop_run'),'write-through-read':('Cap.Write<body~H, Array<U32>, Geometry.Cell>','Cap.Read<body~H, Geometry.Cell>','Location: body'),'undeclared-event':('Cap.Send<body~H, Events.SimulationEvent>','Cap.Read<body~H, Geometry.Cell>','Location: body'),'affine-duplicate':('fail_b','fail_b (consumed more than once)','Location: read')}
 baseline=None
 for name in names+['affine-v2']:
  prefix='development/affine-source5-v2/' if name=='affine-v2' else 'development/source5-v1/'+name+'/'
  r=js(prefix+'result.json');m=js(prefix+'stage/stage.json');assert r['stage_unchanged'] is True and r['stage_manifest_sha256']==sha(read(prefix+'stage/stage.json'))
  assert r['lock']=='/tmp/bendvy-parity-heavy.lock' and r['command'][0]=='BEND_NO_TELEMETRY=1'
  assert sha(read('inputs/bend-check'))==r['script_sha256']
  assert len(m['files'])==51 and m['entry']=='experiments/public-simulation/bend-v1/main.bend'
  pins={x['source']:x['source_sha256'] for x in m['files']}
  if baseline is None:baseline=pins
  assert pins==baseline
  staged={prefix+'stage/'+x['stage'] for x in m['files']}
  assert staged=={p for p in records if p.startswith(prefix+'stage/') and p.endswith('.bend')}
  for x in m['files']:
   assert sha(read(prefix+'stage/'+x['stage']))==x['stage_sha256']
   assert sha(read('sources/'+x['source'].lstrip('/')))==x['source_sha256']
   original=read('sources/'+x['source'].lstrip('/')).decode();actual=read(prefix+'stage/'+x['stage']).decode()
   imports=re.compile(r'^(import\s+)(\S+)(\s+as\s+\S+.*)$',re.M)
   old=list(imports.finditer(original));new=list(imports.finditer(actual));assert len(old)==len(new)
   for a,b in zip(old,new):assert a.group(1)==b.group(1) and a.group(3)==b.group(3)
   cursor=iter(old);effective=imports.sub(lambda _:next(cursor).group(0),actual)
   if x['replaced']:
    assert sha(effective.encode())==m['candidate']['candidate_sha256']
    if name in index['semanticReplacements']:
     delta=index['semanticReplacements'][name]
     assert x['stage']==delta['sourceModule'] and original.count(delta['old'])==1
     assert original.replace(delta['old'],delta['new'])==effective
   else:assert effective==original
   mapping={row['source']:row['stage'] for row in m['files']}
   def rebuild(match):
    target=os.path.normpath(os.path.join(os.path.dirname(x['source']),match.group(2)))
    assert target in mapping
    imported=os.path.relpath(mapping[target],os.path.dirname(x['stage']))
    if not imported.startswith('.'):imported='./'+imported
    return match.group(1)+imported+match.group(3)
   assert imports.sub(rebuild,effective)==actual
  out=read(prefix+'stdout');err=read(prefix+'stderr').decode()
  if name in ('positive','omit-hit','omit-death'):
   assert r['exit']==0 and out==b'ALL PROOFS CHECK\nUse --verdict for mathematical validity.\n' and err==''
  else:
   assert r['exit']==1 and out==b'' and err.count('Error:')==1 and 'SOME PROOFS FAIL' in err
   e=expected[name] if name!='affine-v2' else ('pair','pair (consumed more than once)','Location: read')
   assert '- expected : '+e[0]+'\n' in err and '- observed : '+e[1]+'\n' in err and e[2] in err
   assert 'timeout' not in err and 'parser' not in err and 'missing import' not in err
 correction=js('inputs/candidate-source-correction.json');old=read(index['executedGeometry']);new=read('inputs/current-geometry.bend')
 assert sha(old)==correction['executedSha256']=='8a2ca38ca58d1c7cef89e241a37c44e9c2a5bcb152de665db0d039461399e823'
 assert sha(new)==correction['candidateSha256']=='fdfac549322d458d0ca0eeb8fa1c12f99800443c7b2ca5c8212bacc1aa4d0c97' and old==new+b'\n'
 for name,target,count,rawbytes in [('omit-hit','events.bend::SimulationHit',974,37888),('omit-death','events.bend::SimulationDeath',332,40070)]:
  prefix='development/mutant-js-v1/'+name+'/'
  plan=js(prefix+'plan.json');r=js(prefix+'receipt.json');m=js('development/source5-v1/'+name+'/stage/stage.json');assert r['all_guards_passed'] is True
  assert plan['stage_manifest_sha256']==r['stage_manifest_sha256']==sha(read('development/source5-v1/'+name+'/stage/stage.json'))
  assert plan['oracle_sha256']==sha(read('inputs/independent-expected.json')) and plan['parser_sha256']==sha(parser_bytes)
  assert plan['environment']=={'BEND_NO_TELEMETRY':'1'} and plan['lock']=='/tmp/bendvy-parity-heavy.lock'
  assert [c['label'] for c in r['commands']]==['emit','run'] and [c['capSeconds'] for c in r['commands']]==[30,5]
  for c,planned in zip(r['commands'],plan['commands']):
   assert c['argv']==planned[1] and c['capSeconds']==planned[2] and c['returncode']==0 and c['timeout'] is False and c['argv'][:3]==['taskset','-c','5']
  assert r['commands'][0]['argv'][3]=='bend' and r['commands'][1]['argv'][3]=='node'
  assert r['commands'][0]['argv'][4].endswith('/'+m['entry']) and r['commands'][0]['argv'][-1]==r['commands'][1]['argv'][-1]
  assert read(prefix+'run.stderr')==b''
  raw=read(prefix+'run.stdout').decode();assert len(raw.encode())==rawbytes
  parsed=parser['parse'](raw);assert parser['render'](parsed)==raw.strip() and strict(parsed)==strict(js(prefix+'parsed.json'))
  mapping=js(prefix+'constructor-map.json');assert len(mapping)==32
  for literal,row in mapping.items():
   module,ctor=row['neutral'].split('::');ev=row['evidence']
   if module=='Base':assert literal==ctor and sha(read('inputs/base.bend'))==ev['source_sha256']
   else:
    x=[x for x in m['files'] if x['stage']==ev['stage']];assert len(x)==1;x=x[0]
    assert x['source_sha256']==ev['source_sha256'] and x['stage_sha256']==ev['stage_sha256'] and Path(x['stage']).name==module
    path=Path(x['stage']);entry=Path(m['entry']);qualifier=os.path.relpath(path.with_suffix(''),entry.parent)
    assert literal==(ctor if path==entry else qualifier+'.'+ctor)
    text=read('development/source5-v1/'+name+'/stage/'+x['stage']).decode()
    assert any(re.search(r'\b'+re.escape(ctor)+r'\{',block) for block in re.findall(r'^type .*?(?=^def |^import |^type |\Z)',text,re.M|re.S))
  def neutral(v):
   if isinstance(v,list):return [neutral(x) for x in v]
   if isinstance(v,dict):
    if set(v)=={'constructor','fields'}:return {'constructor':mapping[v['constructor']]['neutral'],'fields':neutral(v['fields'])}
    assert set(v)=={'nat'};return dict(v)
   return v
  observed=neutral(parsed);assert strict(observed)==strict(js(prefix+'neutral.json')) and strict(observed)!=strict(oracle)
  diff=differences(oracle,observed);assert len(diff)==count and strict(diff)==strict(js(prefix+'full-diff.json'))
  assert strict(omit(oracle,target))==strict(observed)
  assert [len(s) for s in observed['fields']]==[14,14]
  assert [sum(strict(a)!=strict(b) for a,b in zip(e,o)) for e,o in zip(oracle['fields'],observed['fields'])]==[11,11]
  for e,o in zip(oracle['fields'],observed['fields']):
   ee=e[3]['fields'][0]['fields'][0]['fields'][0]['fields'][4];oe=o[3]['fields'][0]['fields'][0]['fields'][0]['fields'][4]
   assert [x['constructor'] for x in ee]==['events.bend::SimulationHit','events.bend::SimulationDeath']
   assert strict([x for x in ee if x['constructor']!=target])==strict(oe)
  artifacts=js(prefix+'artifacts.json')['files'];assert artifacts['run.stdout']==sha(read(prefix+'run.stdout'))
  assert index['excludedGeneratedJS'][name]['sha256']==artifacts['main.js']
 print('PASS selected development controls: source positive, four intended negatives (affine v1 inconclusive retained), two full-oracle JS mutation kills; old geometry bound; not full #63 delivery')
if __name__=='__main__':main()
